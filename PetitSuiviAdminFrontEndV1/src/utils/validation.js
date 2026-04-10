/**
 * @file validation.js
 * @description Centralized validation logic for various forms and inputs across the application.
 * 
 * ROLE:
 * This utility file exports a collection of pure functions responsible for validating user input.
 * It contains:
 * 1. Granular field-level validators (e.g., email, phone, CIN format, birthdate).
 * 2. Form-level validators (e.g., Teacher, Parent, Class) that combine field validators
 *    to return a comprehensive error object for use in React form states.
 * 3. Security checks (e.g., basic anti-XSS to reject HTML/Script tags).
 */

/**
 * Checks if a string contains HTML tags or script tags to prevent basic XSS attacks.
 * @param {string} value - The input string to check.
 * @returns {boolean} True if HTML tags are detected, otherwise false.
 */
export const isHtmlOrScript = (value) => {
    if (typeof value !== 'string') return false;
    const regex = /<[^>]*>/;
    return regex.test(value);
};

/**
 * Validates a Tunisian CIN (National Identity Card).
 * @param {string|number} cin - The CIN to validate.
 * @returns {string|null} Error message if invalid, or null if valid.
 */
export const validateCin = (cin) => {
    if (!cin) return "Le CIN est requis.";
    if (!/^\d{8}$/.test(String(cin))) return "Le CIN doit comporter exactement 8 chiffres.";
    return null;
};

/**
 * Validates an email address format using a regular expression.
 * @param {string} email - The email to validate.
 * @returns {string|null} Error message if invalid, or null if valid.
 */
export const validateEmail = (email) => {
    if (!email) return "L'email est requis.";
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(String(email))) return "Format d'email invalide.";
    return null;
};

/**
 * Validates a phone number, ensuring it has at least 8 digits.
 * @param {string|number} phone - The phone number to validate.
 * @returns {string|null} Error message if invalid, or null if valid.
 */
export const validatePhone = (phone) => {
    if (!phone) return "Le téléphone est requis.";
    if (!/^\d{8,}$/.test(String(phone).replace(/\s+/g, ''))) return "Numéro de téléphone invalide (au moins 8 chiffres).";
    return null;
};

/**
 * Validates a teacher's birthdate to ensure they are age-appropriate (22 to 70 years old).
 * @param {string|Date} birthdate - The birthdate to validate.
 * @returns {string|null} Error message if invalid, or null if valid.
 */
export const validateTeacherBirthdate = (birthdate) => {
    if (!birthdate) return "La date de naissance est requise.";
    const dob = new Date(birthdate);
    if (isNaN(dob.getTime())) return "Date invalide.";

    const today = new Date();
    if (dob > today) return "La date de naissance ne peut pas être dans le futur.";

    let age = today.getFullYear() - dob.getFullYear();
    const m = today.getMonth() - dob.getMonth();
    // Adjust age if the birthday hasn't occurred yet this year
    if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) {
        age--;
    }

    if (age < 22 || age > 70) return "L'enseignant doit avoir entre 22 et 70 ans.";
    return null;
};

/**
 * Validates a parent's birthdate to ensure they are at least 18 years old.
 * @param {string|Date} birthdate - The birthdate to validate.
 * @returns {string|null} Error message if invalid, or null if valid.
 */
export const validateParentBirthdate = (birthdate) => {
    if (!birthdate) return "La date de naissance est requise.";
    const dob = new Date(birthdate);
    if (isNaN(dob.getTime())) return "Date invalide.";

    const today = new Date();
    if (dob > today) return "La date de naissance ne peut pas être dans le futur.";

    let age = today.getFullYear() - dob.getFullYear();
    const m = today.getMonth() - dob.getMonth();
    // Adjust age if the birthday hasn't occurred yet this year
    if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) {
        age--;
    }

    if (age < 18) return "Le parent doit être majeur.";
    return null;
};

/**
 * Validates that a given input is a positive number.
 * @param {any} num - The value to check.
 * @param {string} fieldName - Label to use in the error message.
 * @returns {string|null} Error message if invalid, or null if valid.
 */
export const validatePositiveNumber = (num, fieldName = "Ce champ") => {
    if (num === null || num === undefined || num === '') return `${fieldName} est requis.`;
    if (isNaN(Number(num))) return `${fieldName} doit être un nombre.`;
    if (Number(num) < 0) return `${fieldName} ne peut pas être négatif.`;
    return null;
};

/**
 * Validates a name strictly, ensuring it is present and does not contain unauthorized HTML/Scripts.
 * @param {string} name - The name to validate.
 * @param {string} fieldName - Label to use in the error message.
 * @returns {string|null} Error message if invalid, or null if valid.
 */
export const validateName = (name, fieldName = "Le nom") => {
    if (!name || String(name).trim() === '') return `${fieldName} est requis.`;
    if (isHtmlOrScript(String(name))) return `${fieldName} contient des caractères non autorisés.`;
    return null;
};

/**
 * A generic string validator ensuring the field is not empty and is safe from HTML injection.
 * @param {string} str - The string to validate.
 * @param {string} fieldName - Label to use in the error message.
 * @returns {string|null} Error message if invalid, or null if valid.
 */
export const validateGenericString = (str, fieldName = "Ce champ") => {
    if (!str || String(str).trim() === '') return `${fieldName} est requis.`;
    if (isHtmlOrScript(String(str))) return `${fieldName} contient des caractères non autorisés.`;
    return null;
};

/**
 * Validates an optional string field. Empty values are allowed, but provided
 * values must still be safe from HTML/script injection.
 *
 * @param {string} str - The optional string to validate.
 * @param {string} fieldName - Label to use in the error message.
 * @returns {string|null} Error message if invalid, or null if valid.
 */
export const validateOptionalGenericString = (str, fieldName = "Ce champ") => {
    if (str === null || str === undefined || String(str).trim() === '') return null;
    if (isHtmlOrScript(String(str))) return `${fieldName} contient des caractères non autorisés.`;
    return null;
};

/**
 * COMPOSITE VALIDATOR: Teacher Form
 * Evaluates the entire teacher data object and compiles all field errors.
 * 
 * @param {Object} data - The teacher form state.
 * @param {boolean} isEdit - Flag determining if this is an update (skips CIN check usually).
 * @returns {Object} An object mapping field names to their specific error messages. Empty if valid.
 */
export const validateTeacherForm = (data, isEdit = false) => {
    const errors = {};
    if (!isEdit) {
        const cinError = validateCin(data.cin);
        if (cinError) errors.cin = cinError;

        const addressError = validateGenericString(data.adresse, "L'adresse");
        if (addressError) errors.adresse = addressError;
    } else {
        const addressError = validateOptionalGenericString(data.adresse, "L'adresse");
        if (addressError) errors.adresse = addressError;
    }

    const firstNameError = validateName(data.firstName, "Le prénom");
    if (firstNameError) errors.firstName = firstNameError;

    const lastNameError = validateName(data.lastName, "Le nom");
    if (lastNameError) errors.lastName = lastNameError;

    const emailError = validateEmail(data.email);
    if (emailError) errors.email = emailError;

    const phoneError = validatePhone(data.phone);
    if (phoneError) errors.phone = phoneError;

    const birthdateError = validateTeacherBirthdate(data.birthdate);
    if (birthdateError) errors.birthdate = birthdateError;

    return errors;
};

/**
 * COMPOSITE VALIDATOR: Parent Form
 * Evaluates the entire parent data object and compiles all field errors.
 * 
 * @param {Object} data - The parent form state.
 * @param {boolean} isEdit - Flag determining if this is an update.
 * @returns {Object} An object mapping field names to their specific error messages.
 */
export const validateParentForm = (data, isEdit = false) => {
    const errors = {};
    if (!isEdit) {
        const cinError = validateCin(data.cin);
        if (cinError) errors.cin = cinError;
    }

    const addressError = validateOptionalGenericString(data.adresse, "L'adresse");
    if (addressError) errors.adresse = addressError;

    const firstNameError = validateName(data.firstName, "Le prénom");
    if (firstNameError) errors.firstName = firstNameError;

    const lastNameError = validateName(data.lastName, "Le nom");
    if (lastNameError) errors.lastName = lastNameError;

    const emailError = validateEmail(data.email);
    if (emailError) errors.email = emailError;

    const phoneError = validatePhone(data.phone);
    if (phoneError) errors.phone = phoneError;

    const birthdateError = validateParentBirthdate(data.birthdate);
    if (birthdateError) errors.birthdate = birthdateError;

    return errors;
};

/**
 * COMPOSITE VALIDATOR: Class Form
 * Evaluates the class creation/edit data object.
 * 
 * @param {Object} data - The class form state.
 * @returns {Object} An object containing errors for name, year, or capacity.
 */
export const validateClassForm = (data) => {
    const errors = {};

    const nameError = validateName(data.name, "Le nom de la classe");
    if (nameError) errors.name = nameError;

    const yearError = validateGenericString(data.year, "L'année");
    if (yearError) errors.year = yearError;

    const capacityError = validatePositiveNumber(data.capacity, "La capacité");
    if (capacityError) errors.capacity = capacityError;

    return errors;
};
