/**
 * Formats a month string into a localized short month and year.
 * @param {string} value - The month string in "YYYY-MM" format.
 * @returns {string} The localized month string.
 */
export const formatMonth = (value) => {
  if (typeof value !== "string" || !value.includes("-")) return value;
  const [year, month] = value.split("-");
  const date = new Date(Number(year), Number(month) - 1, 1);
  if (Number.isNaN(date.getTime())) return value;
  return date.toLocaleDateString("fr-FR", { month: "short", year: "numeric" });
};

/**
 * Formats an amount using French locale.
 * @param {number|string} value - The amount to format.
 * @returns {string} The formatted amount.
 */
export const formatAmount = (value) => Number(value || 0).toLocaleString("fr-FR");

/**
 * Determines the current planning ID based on today's date.
 * @param {Array} planningList - The list of available plannings.
 * @returns {string} The ID of the current planning, or the first one if none is current.
 */
export const getCurrentPlanningId = (planningList) => {
  if (!planningList.length) return "";

  return planningList.slice().sort((a, b) => {
    const aYear = Number(a.startYear || a.start_year) || 0;
    const bYear = Number(b.startYear || b.start_year) || 0;
    return bYear - aYear;
  })[0].id;
};

/**
 * Checks if a given month string represents a future month relative to the current date.
 * @param {string} monthKey - The month string in "YYYY-MM" format.
 * @returns {boolean} True if the month is in the future.
 */
export const isFutureMonth = (monthKey) => {
  if (typeof monthKey !== "string" || !monthKey.includes("-")) return false;
  const [year, month] = monthKey.split("-").map(Number);
  const monthDate = new Date(year, month - 1, 1);
  if (Number.isNaN(monthDate.getTime())) return false;

  const current = new Date();
  const currentMonth = new Date(current.getFullYear(), current.getMonth(), 1);
  return monthDate > currentMonth;
};
