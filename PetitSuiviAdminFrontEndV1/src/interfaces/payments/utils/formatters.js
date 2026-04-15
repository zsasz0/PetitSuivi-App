/**
 * @file utils/formatters.js
 * @description Pure Utility Helpers for Payments.
 */

/**
 * Standardizes monetary values into the TND currency format for the UI.
 * @param {number|string} amount - The numeric value to format.
 * @returns {string} Formatted currency string (e.g., "1 000 TND").
 */
export const formatCurrency = (amount) =>
  new Intl.NumberFormat("fr-FR", { minimumFractionDigits: 0 }).format(
    Number(amount || 0),
  ) + " TND";

/**
 * Maps backend payment status names to standardized UI tags.
 * @param {string} statusName - The raw status name from the API.
 * @returns {string} Standardized tag ('paid'|'partial'|'pending').
 */
export const mapStatusToUi = (statusName) => {
  const n = (statusName || "").toLowerCase();
  if (n === "payé" || n === "paye" || n === "paid") return "paid";
  if (n === "partiel" || n === "partial") return "partial";
  return "pending";
};

/**
 * Flattens various naming conventions for payment methods into reliable constants.
 * @param {string} method - The raw method string.
 * @returns {string} Normalized method key ('monthlyPartial'|'oneShot').
 */
export const normalizePaymentMethod = (method) => {
  const n = (method || "").toLowerCase();
  if (
    n === "monthlypartial" ||
    n === "monthly_partial" ||
    n === "monthly partial"
  )
    return "monthlyPartial";
  return "oneShot";
};

/**
 * Strips accents from a string to ensure accurate dictionary mapping.
 * @param {string} text - The input text.
 * @returns {string} Normalized text.
 */
export const normalizeTextForMatch = (text) => {
  return (text || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim();
};

/**
 * Parses a year-month string.
 * @param {string} value - YYYY-MM formatted string.
 * @returns {{year: number, month: number} | null} Parsed year and month.
 */
export const parseYearMonth = (value) => {
  const match = /^(\d{4})-(\d{2})/.exec(value || "");
  if (!match) return null;
  return {
    year: Number(match[1]),
    month: Number(match[2]),
  };
};

/**
 * Formats a given year and month to a local string label.
 * @param {number} year - The year.
 * @param {number} month - The month (1-12).
 * @returns {string} Formatted month label.
 */
export const formatMonthLabel = (year, month) => {
  return new Date(year, month - 1, 1).toLocaleString("fr-FR", {
    month: "long",
    year: "numeric",
  });
};

/**
 * Ensures target month format is consistently a string pad-started with '0'.
 * @param {string|number} targetMonth 
 * @returns {string|null} Normalzed target month key.
 */
export const getTargetMonthKey = (targetMonth) => {
  if (targetMonth === null || targetMonth === undefined || targetMonth === "") {
    return null;
  }

  if (typeof targetMonth === "string" && /^\d{4}-\d{2}$/.test(targetMonth)) {
    return targetMonth;
  }

  const monthNumber = Number(targetMonth);
  if (Number.isNaN(monthNumber) || monthNumber < 1 || monthNumber > 12) {
    return null;
  }

  return String(monthNumber).padStart(2, "0");
};

/**
 * Generates array of month options between two dates.
 * @param {string} startDate - Planning start date (YYYY-MM-DD)
 * @param {string} endDate - Planning end date (YYYY-MM-DD)
 * @returns {Array<{value: string, label: string}>} Array of month options
 */
export const getMonthsInRange = (startDate, endDate) => {
  const months = [];
  if (!startDate || !endDate) return months;

  const start = parseYearMonth(startDate);
  const end = parseYearMonth(endDate);
  if (!start || !end) return months;

  const monthNames = [
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    "Juin",
    "Juillet",
    "Août",
    "Septembre",
    "Octobre",
    "Novembre",
    "Décembre",
  ];

  let year = start.year;
  let month = start.month;
  while (year < end.year || (year === end.year && month <= end.month)) {
    const value = `${year}-${String(month).padStart(2, "0")}`;
    const label = `${monthNames[month - 1]} ${year}`;
    months.push({ value, label });

    month += 1;
    if (month > 12) {
      month = 1;
      year += 1;
    }
  }

  return months;
};

/**
 * Helper returning completion ratio (0..100) strictly capped.
 * @param {number} paid - Amount already paid.
 * @param {number} total - Total amount due.
 * @returns {number} Percentage value (0-100).
 */
export const getPaymentPercent = (paid, total) => {
  if (!total) return 0;
  return Math.min(Math.round((paid / total) * 100), 100);
};
