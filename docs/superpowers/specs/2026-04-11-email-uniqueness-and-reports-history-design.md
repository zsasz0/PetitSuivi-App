# Email Uniqueness And Reports History Design

## Summary

This change enforces global, case-insensitive email uniqueness across the `Account` table for all account types, with validation in the backend, clear error handling in Flutter and React admin, and a final database trigger guard. It also removes the delete action from the admin behavioral analysis history page at `/management/reports?tab=history`.

## Goals

- Prevent parent registration from creating an account with an email already used by any other account.
- Prevent admin teacher creation or update from using an email already used by any other account.
- Treat `test@example.com` and `TEST@example.com` as duplicates.
- Keep the API response user-friendly so the frontend can show an inline error on the `email` field.
- Add a database trigger on `Account` as the final safety net.
- Remove the delete button from behavioral history in the React admin frontend.

## Non-Goals

- Removing the backend delete endpoint for report analysis history.
- Refactoring unrelated account flows.
- Adding live "email availability" API endpoints.

## Current Context

Relevant code paths already found in the repository:

- Mobile parent registration backend: `PetitSuiviBackendV1/app/Http/Controllers/Api/Mobile/AuthController.php`
- Admin parent management backend: `PetitSuiviBackendV1/app/Http/Controllers/Api/Admin/ParentController.php`
- Admin teacher management backend: `PetitSuiviBackendV1/app/Http/Controllers/Api/Admin/TeacherController.php`
- React admin teacher interface: `PetitSuiviAdminFrontEndV1/src/interfaces/teachers/index.jsx`
- React admin parent interface: `PetitSuiviAdminFrontEndV1/src/interfaces/parents/index.jsx`
- React admin behavioral history UI: `PetitSuiviAdminFrontEndV1/src/interfaces/behavioral-history/index.jsx`

The backend already applies simple uniqueness validation in some admin flows using `unique:Account,Email`, but the mobile parent registration flow does not currently enforce a global uniqueness rule strongly enough, and the behavior is not explicit about case-insensitive matching.

## Recommended Approach

Enforce the rule in three layers:

1. Backend validation for all relevant create and update paths.
2. Frontend handling that maps duplicate-email validation back onto the `email` field.
3. Database trigger on `Account` to reject any duplicate normalized email that bypasses application checks.

This provides good UX while still protecting data integrity.

## Functional Design

### 1. Backend Validation Rules

All account-creation and account-update flows that accept an email must validate uniqueness against normalized email values.

Normalization rule:

- `normalized_email = LOWER(TRIM(email))`

Behavior:

- Reject create when any other `Account` row already has the same normalized email.
- Reject update when any other `Account` row already has the same normalized email, excluding the current row.
- Return a field-level validation error for `email` with a consistent user-facing message.

Primary backend paths in scope:

- `Api\Mobile\AuthController::register`
- `Api\Admin\ParentController::store`
- `Api\Admin\ParentController::update`
- `Api\Admin\TeacherController::store`
- `Api\Admin\TeacherController::update`

Implementation notes:

- Trim incoming email before validation and persistence.
- Prefer explicit custom validation logic or `Rule`-based query constraints that compare normalized values, instead of relying only on `unique:Account,Email`.
- Persist the trimmed email value so stored data is cleaner even before the trigger executes.
- If a DB exception still occurs from the trigger, catch it and map it to the same validation-style `email` error when practical.

### 2. Mobile Flutter Parent Registration

The Flutter parent registration UI should continue to validate email format locally, but must rely on the backend for the final duplicate-email decision.

Expected behavior:

- On submit, if the backend returns a duplicate-email validation error, show it on the email field.
- Do not allow the registration flow to continue after this error.
- Use the same user-facing message as the admin frontend for consistency.

No separate preflight availability endpoint is required for this fix.

### 3. React Admin Teacher Interface

The React teacher management page must surface duplicate-email errors on both create and update.

Expected behavior:

- Keep existing client-side format validation.
- When the backend rejects the request because of duplicate email, attach the error to `errors.email` so the form field shows it inline.
- Preserve the existing submission flow and keep changes minimal.

The same pattern can be reused for admin parent interfaces if those screens also create or update accounts through editable email fields.

### 4. Database Trigger

The database must reject duplicate normalized emails even if they come from direct SQL, old clients, or future code paths.

Rule:

- For inserts and updates on `Account`, if `LOWER(TRIM(Email))` matches another row's normalized email, reject the write.
- Allow `NULL` emails to remain unaffected.
- Ignore the current row during updates by comparing `AccountID`.

Because the user wants the trigger in Markdown for manual copy/paste into the database, the exact SQL is included below.

## Trigger SQL

The syntax below is for MySQL / MariaDB style trigger support.

```sql
DROP TRIGGER IF EXISTS before_account_insert_unique_email;
DROP TRIGGER IF EXISTS before_account_update_unique_email;

DELIMITER $$

CREATE TRIGGER before_account_insert_unique_email
BEFORE INSERT ON Account
FOR EACH ROW
BEGIN
    IF NEW.Email IS NOT NULL AND TRIM(NEW.Email) <> '' THEN
        IF EXISTS (
            SELECT 1
            FROM Account
            WHERE Email IS NOT NULL
              AND LOWER(TRIM(Email)) = LOWER(TRIM(NEW.Email))
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Duplicate email is not allowed in Account';
        END IF;

        SET NEW.Email = TRIM(NEW.Email);
    END IF;
END$$

CREATE TRIGGER before_account_update_unique_email
BEFORE UPDATE ON Account
FOR EACH ROW
BEGIN
    IF NEW.Email IS NOT NULL AND TRIM(NEW.Email) <> '' THEN
        IF EXISTS (
            SELECT 1
            FROM Account
            WHERE AccountID <> NEW.AccountID
              AND Email IS NOT NULL
              AND LOWER(TRIM(Email)) = LOWER(TRIM(NEW.Email))
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Duplicate email is not allowed in Account';
        END IF;

        SET NEW.Email = TRIM(NEW.Email);
    END IF;
END$$

DELIMITER ;
```

### Pre-Deployment Data Check

Before creating the trigger, the production database should be checked for existing duplicate normalized emails. If duplicates already exist, trigger creation may succeed, but future updates and inserts could become inconsistent with current data.

Recommended query:

```sql
SELECT LOWER(TRIM(Email)) AS normalized_email, COUNT(*) AS duplicate_count
FROM Account
WHERE Email IS NOT NULL AND TRIM(Email) <> ''
GROUP BY LOWER(TRIM(Email))
HAVING COUNT(*) > 1;
```

If this query returns rows, those duplicates should be cleaned before rollout.

## API Error Contract

Preferred user-facing message:

```text
Cet email est deja utilise.
```

Preferred API shape should remain compatible with existing Laravel validation responses so both frontend clients can read the `email` field error without extra parsing.

## UI Change For Reports History

File in scope:

- `PetitSuiviAdminFrontEndV1/src/interfaces/behavioral-history/index.jsx`

Change:

- Remove the delete action button from each history row in the `historyActions` area.
- Remove the associated `handleDeleteHistory` call path and any now-unused delete-specific styling or imports if they become dead code.

Behavior after change:

- Users can still browse, search, paginate, and expand history entries.
- Users can no longer delete history entries from `/management/reports?tab=history`.

## Testing Strategy

### Backend

- Create parent with an email already used by a teacher account: must fail.
- Create teacher with an email already used by a parent account: must fail.
- Update teacher email to another account's email: must fail.
- Update parent email to another account's email: must fail.
- Try same email with different casing: must fail.
- Try same email with leading or trailing spaces: must fail and/or be normalized.

### Flutter

- Submit parent registration with duplicate email and verify the email field shows the duplicate-email message.

### React Admin

- Create teacher with duplicate email and verify the email field shows the duplicate-email message.
- Update teacher with duplicate email and verify the email field shows the duplicate-email message.
- Visit `/management/reports?tab=history` and verify the delete button is no longer visible.

### Database

- Direct `INSERT` with duplicate normalized email: must fail.
- Direct `UPDATE` to duplicate another row's normalized email: must fail.

## Risks And Mitigations

- Existing duplicates in production data could complicate rollout.
  Mitigation: run the duplicate scan query before enabling the trigger.

- DB trigger errors may surface as generic 500 responses if not translated in application code.
  Mitigation: keep application-level validation in place and add graceful exception mapping where needed.

- Other account-editing endpoints outside the identified paths may still allow conflicting updates.
  Mitigation: the trigger protects final integrity, and follow-up work can expand application-level validation if more account-editing endpoints are discovered.

## Implementation Boundaries

This design is intentionally minimal:

- no new service layer unless existing code patterns clearly justify it
- no schema redesign
- no new availability API
- no backend endpoint removal for history deletion as part of this request

## Rollout Notes

Suggested order:

1. Scan for existing duplicates in `Account`.
2. Update backend validation and frontend error handling.
3. Remove the reports history delete button in React admin.
4. Apply the DB trigger SQL.
5. Verify create/update flows in both clients.
