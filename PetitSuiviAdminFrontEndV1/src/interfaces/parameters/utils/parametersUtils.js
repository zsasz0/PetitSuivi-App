/**
 * Labels mapping for parameter names.
 */
export const PARAM_LABELS = {
  school_name: "Nom de l'établissement",
  school_year: "Année scolaire",
  inscription_fee: "Frais d'inscription (TND)",
  frais_inscription: "Frais d'inscription (TND)",
  max_capacity: "Capacité maximale",
  kindergarten_address: "Adresse",
  contact_email: "Email",
  contact_phone: "Téléphone",
  director_name: "Nom du directeur",
  facebook_link: "Facebook",
  instagram_link: "Instagram",
  whatsapp_link: "WhatsApp",
};

/**
 * List of hidden parameter names.
 */
export const HIDDEN_PARAMS = ["ai_enabled", "Exceptions dejeuner : verification enfant", "inscriptions_open", "document_signature_path"];

/**
 * Formats the planning label from start and end years.
 * @param {number|string} startYear
 * @param {number|string} endYear
 * @returns {string} The formatted label
 */
export function getPlanningLabel(startYear, endYear) {
  return `${startYear}/${endYear}`;
}

/**
 * Maps planning data from the API response to a consistent format.
 * @param {Object} planning - The raw planning object from API.
 * @returns {Object} Mapped planning object.
 */
export function mapPlanningFromApi(planning) {
  const startYear = Number(planning.startYear ?? planning.start_year);
  const endYear = Number(planning.endYear ?? planning.end_year);
  const startDate = typeof (planning.startDate ?? planning.start_date) === "string"
    ? (planning.startDate ?? planning.start_date).slice(0, 10)
    : "";
  const endDate = typeof (planning.endDate ?? planning.end_date) === "string"
    ? (planning.endDate ?? planning.end_date).slice(0, 10)
    : "";

  return {
    id: planning.id,
    startYear,
    endYear,
    startDate,
    endDate,
    label: planning.label || getPlanningLabel(startYear, endYear),
    isActive: !planning.is_archived,
    isArchived: !!planning.is_archived,
    classesCount: Number(planning.classes_count || 0),
    plandaysCount: Number(planning.plandays_count || 0),
    isDeletable: planning.is_deletable !== false,
    deleteBlockers: Array.isArray(planning.delete_blockers) ? planning.delete_blockers : [],
  };
}

export function getPlanningDeleteBlockedMessage(planning) {
  if (!planning) return "Sélectionnez une année scolaire.";
  if ((planning.deleteBlockers || []).includes("archived")) return "Impossible de supprimer une année scolaire archivée.";
  if ((planning.deleteBlockers || []).includes("has_classes")) return "Impossible de supprimer cette année scolaire car des classes y sont rattachées.";
  if ((planning.deleteBlockers || []).includes("has_plandays")) return "Impossible de supprimer cette année scolaire car des jours planifiés y sont rattachés.";
  return "Impossible de supprimer cette année scolaire.";
}

/**
 * Finds the default planning to select based on current date or active status.
 * @param {Array} planningRows - Mapped planning rows.
 * @param {Date} referenceDate - Date used to determine the current planning.
 * @returns {Object|null} The default planning object.
 */
export function getDefaultPlanning(planningRows, referenceDate) {
  if (!Array.isArray(planningRows) || planningRows.length === 0) return null;

  return planningRows.slice().sort((a, b) => {
    const aYear = Number(a.startYear) || 0;
    const bYear = Number(b.startYear) || 0;
    return bYear - aYear;
  })[0];
}

/**
 * Validates planning dates and extracts years if valid.
 * @param {string} startDate
 * @param {string} endDate
 * @returns {Object|null} The validated dates and years, or null if invalid.
 */
export function validatePlanningDates(startDate, endDate) {
  if (!startDate || !endDate) return null;
  const start = new Date(`${startDate}T00:00:00`);
  const end = new Date(`${endDate}T00:00:00`);
  if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime()) || end < start) return null;
  const startYear = start.getFullYear();
  const endYear = end.getFullYear();
  if (startYear < 2000 || startYear > 2100 || endYear < 2000 || endYear > 2100) return null;
  return { startYear, endYear, startDate, endDate };
}

/**
 * Gets the readable label for a given parameter name.
 * @param {string} name - Parameter name.
 * @returns {string} The display label.
 */
export function getLabel(name) {
  return PARAM_LABELS[name] || String(name).replace(/_/g, " ").replace(/\b\w/g, (letter) => letter.toUpperCase());
}

/**
 * Determines the HTML input type for a given parameter name.
 * @param {string} name - Parameter name.
 * @returns {string} The input type (text, number, email, etc).
 */
export function getInputType(name) {
  const normalized = String(name).toLowerCase();
  if (normalized.includes("fee") || normalized.includes("capacity") || normalized.includes("amount") || normalized.includes("prix") || normalized.includes("frais") || normalized.includes("enfant") || normalized.includes("tarif")) return "number";
  return normalized.includes("email") ? "email" : "text";
}

/**
 * Sanitizes numeric input to allow only digits and a single decimal point.
 * @param {string|number} value - The input value.
 * @returns {string} Sanitized numeric string.
 */
export function sanitizeNumericInput(value) {
  const sanitized = String(value).replace(/[^0-9.]/g, "");
  const firstDotIndex = sanitized.indexOf(".");
  if (firstDotIndex === -1) return sanitized;
  return `${sanitized.slice(0, firstDotIndex + 1)}${sanitized.slice(firstDotIndex + 1).replace(/\./g, "")}`;
}

/**
 * Determines the category of a parameter based on its name.
 * @param {string} name - Parameter name.
 * @returns {string} Category name (identity, meals, contact, fees, other).
 */
export function getParamCategory(name) {
  const normalized = String(name).toLowerCase();
  if (normalized === "school_name" || normalized === "director_name" || normalized.includes("address") || normalized.includes("adresse") || normalized.includes("school_year") || normalized.includes("director") || normalized.includes("directeur")) return "identity";
  if (normalized.includes("dejeuner") || normalized.includes("déjeuner") || normalized.includes("gouter") || normalized.includes("goûter") || normalized.includes("cantine") || normalized.includes("meal") || normalized.includes("repas") || normalized.includes("tarif") || normalized.includes("prix")) return "meals";
  if (normalized.includes("email") || normalized.includes("phone") || normalized.includes("tel") || normalized.includes("facebook") || normalized.includes("instagram") || normalized.includes("whatsapp") || normalized.includes("contact") || normalized.includes("site") || normalized.includes("website")) return "contact";
  if (normalized.includes("frais") || normalized.includes("fee") || normalized.includes("capacity") || normalized.includes("amount")) return "fees";
  return "other";
}
