/**
 * Formats a given date value into a specified format.
 * @param {string|Date} value - The date to format.
 * @param {Object} options - Date formatting options.
 * @returns {string} The formatted date string.
 */
export const formatDate = (value, options = { day: "2-digit", month: "short", year: "numeric" }) => {
  if (!value) return "Date indisponible";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "Date indisponible";
  return date.toLocaleDateString("fr-FR", options);
};

/**
 * Returns a background gradient array based on a seed.
 * @param {string} seed - The seed string (e.g., child id).
 * @param {boolean} isDark - Whether dark mode is active.
 * @returns {string[]} An array of two colors for a gradient.
 */
export const getAvatarGradient = (seed, isDark) => {
  const palettes = isDark
    ? [
        ["#0f766e", "#14b8a6"],
        ["#1d4ed8", "#38bdf8"],
        ["#334155", "#64748b"],
        ["#115e59", "#2dd4bf"],
      ]
    : [
        ["#0f766e", "#2dd4bf"],
        ["#0369a1", "#38bdf8"],
        ["#475569", "#94a3b8"],
        ["#0f766e", "#5eead4"],
      ];

  const hash = String(seed || "")
    .split("")
    .reduce((sum, char) => sum + char.charCodeAt(0), 0);

  return palettes[hash % palettes.length];
};
