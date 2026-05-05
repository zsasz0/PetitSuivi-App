/**
 * Helper transformations and mapping.
 */

/**
 * Maps payment method to readable label.
 * @param {string} method 
 * @returns {string} Readable label
 */
export const mapPaymentMethod = (method) => {
    if (method === "monthlyPartial") return "Paiement mensuel";
    if (method === "oneShot") return "Paiement annuel";
    return method || "-";
};

/**
 * Maps type name to readable label.
 * @param {string} typeName 
 * @returns {string} Readable label
 */
export const mapTypeLabel = (typeName) => {
    const normalized = String(typeName || "").trim().toLowerCase();
    if (normalized === "kindergarten") return "Maternelle";
    if (normalized === "preschool") return "Préscolaire";
    return typeName || "-";
};

/**
 * Formats value as currency.
 * @param {number|string} value 
 * @returns {string} Formatted currency
 */
export const formatCurrency = (value) => {
    const amount = Number(value);
    if (!Number.isFinite(amount)) return "-";
    return `${new Intl.NumberFormat("fr-TN", { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(amount)} TND`;
};

/**
 * Formats date to a readable standard.
 * @param {string} value 
 * @returns {string} Formatted date string
 */
export const formatDate = (value) => {
    if (!value) return "-";
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return value;
    return date.toLocaleDateString("fr-FR");
};

/**
 * Parses date safely.
 * @param {string} value 
 * @returns {Date|null}
 */
export const parseDateValue = (value) => {
    if (!value) return null;
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
};

/**
 * Checks if inscription date is within planning window dynamically.
 * @param {string} inscriptionDateValue 
 * @param {string} planningStartValue 
 * @param {string} planningEndValue 
 * @returns {boolean}
 */
export const isWithinPlanningMargin = (inscriptionDateValue, planningStartValue, planningEndValue) => {
    const inscriptionDate = parseDateValue(inscriptionDateValue);
    const planningStartDate = parseDateValue(planningStartValue);
    const planningEndDate = parseDateValue(planningEndValue);

    if (!inscriptionDate || !planningStartDate || !planningEndDate) {
        return false;
    }

    const effectiveStart = new Date(planningStartDate);
    effectiveStart.setMonth(effectiveStart.getMonth() - 2);

    return inscriptionDate >= effectiveStart && inscriptionDate <= planningEndDate;
};
