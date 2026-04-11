<?php

namespace App\Support;

use Closure;
use Illuminate\Support\Facades\DB;

class AccountEmailUniqueness
{
    public const DUPLICATE_EMAIL_MESSAGE = 'Cet email est deja utilise.';
    public const DUPLICATE_TRIGGER_MESSAGE = 'Duplicate email is not allowed in Account';

    public static function normalize(?string $email): string
    {
        return mb_strtolower(trim((string) $email));
    }

    public static function trim(?string $email): string
    {
        return trim((string) $email);
    }

    public static function exists(?string $email, ?int $ignoreAccountId = null): bool
    {
        $trimmedEmail = self::trim($email);
        if ($trimmedEmail === '') {
            return false;
        }

        $query = DB::table('Account')
            ->whereNotNull('Email')
            ->whereRaw('LOWER(TRIM(Email)) = ?', [self::normalize($trimmedEmail)]);

        if ($ignoreAccountId !== null) {
            $query->where('AccountID', '<>', $ignoreAccountId);
        }

        return $query->exists();
    }

    public static function validationRule(?int $ignoreAccountId = null): Closure
    {
        return function (string $attribute, mixed $value, Closure $fail) use ($ignoreAccountId): void {
            if (self::exists((string) $value, $ignoreAccountId)) {
                $fail(self::DUPLICATE_EMAIL_MESSAGE);
            }
        };
    }

    public static function isDuplicateTriggerException(\Throwable $exception): bool
    {
        return str_contains($exception->getMessage(), self::DUPLICATE_TRIGGER_MESSAGE);
    }
}
