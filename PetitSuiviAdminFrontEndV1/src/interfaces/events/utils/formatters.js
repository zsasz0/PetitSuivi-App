/**
 * Formats a date string to French locale format (DD/MM/YYYY)
 * @param {string|Date} value - The date to format
 * @returns {string} Formatted date string or original value if invalid
 */
export const formatDate = (value) => {
  if (!value) return "-";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return date.toLocaleDateString("fr-FR");
};

/**
 * Formats a time string to HH:MM
 * @param {string} value - Time string
 * @returns {string} Formatted short time
 */
export const formatShortTime = (value) => (value || "").slice(0, 5) || "--:--";

/**
 * Combines a date and a time into a native Date object
 * @param {string} date - Date string
 * @param {string} time - Time string
 * @returns {Date} Date object
 */
export const toEventDateTime = (date, time) => new Date(`${String(date).slice(0, 10)}T${String(time).slice(0, 5)}:00`);

/**
 * Calculates the difference in minutes between two dates
 * @param {Date} a - First date (later)
 * @param {Date} b - Second date (earlier)
 * @returns {number} Difference in minutes
 */
export const minutesDiff = (a, b) => Math.round((a.getTime() - b.getTime()) / 60000);

/**
 * Formats a relative time string based on a minute count
 * @param {number} minutes - Minutes difference
 * @returns {string} Relative time message
 */
export const formatRelativeTime = (minutes) => {
  if (minutes <= 0) return "maintenant";
  const hours = Math.floor(minutes / 60);
  const remaining = minutes % 60;
  if (hours <= 0) return `dans ${remaining} min`;
  if (remaining === 0) return `dans ${hours} h`;
  return `dans ${hours} h ${remaining} min`;
};

/**
 * Generates progress metadata (percentage, colors, labels) for an event timeline
 * @param {Object} event - The event object
 * @param {Date} [now=new Date()] - The current date reference
 * @returns {Object|null} Progress metadata
 */
export const getTimeProgressMeta = (event, now = new Date()) => {
  if (!event?.date || !event?.start_time || !event?.end_time) return null;

  const eventDate = String(event.date).slice(0, 10);
  const today = now.toISOString().slice(0, 10);
  if (eventDate !== today) return null;

  const start = toEventDateTime(event.date, event.start_time);
  const end = toEventDateTime(event.date, event.end_time);
  const total = Math.max(1, minutesDiff(end, start));

  if (now >= end) {
    return {
      label: "Terminé aujourd'hui",
      percent: 100,
      barColor: "rgba(148,163,184,0.65)",
      trackColor: "rgba(148,163,184,0.22)",
      isMuted: true,
      tooltip: "Événement terminé",
    };
  }

  if (now <= start) {
    return {
      label: `Commence ${formatRelativeTime(minutesDiff(start, now))}`,
      percent: 0,
      barColor: "rgba(148,163,184,0.65)",
      trackColor: "rgba(148,163,184,0.22)",
      isMuted: false,
      tooltip: `Débute ${formatRelativeTime(minutesDiff(start, now))}`,
    };
  }

  const elapsed = minutesDiff(now, start);
  return {
    label: `${Math.max(0, minutesDiff(end, now))} min restantes`,
    percent: Math.min(100, Math.max(0, Math.round((elapsed / total) * 100))),
    barColor: "#64748b",
    trackColor: "rgba(148,163,184,0.22)",
    isMuted: false,
    tooltip: "Événement en cours",
  };
};

/**
 * Computes status UI metadata (label and colors)
 * @param {string} status - Event status
 * @param {Object} colors - Theme colors
 * @param {boolean} isDark - Dark mode active
 * @returns {Object} Status metadata
 */
export const getStatusMeta = (status, colors, isDark) => {
  if (status === "executed") {
    return {
      label: "Exécuté",
      backgroundColor: isDark ? "rgba(34,197,94,0.18)" : "rgba(22,163,74,0.12)",
      color: isDark ? colors.greenAccent[300] : "#166534",
      borderColor: isDark ? "rgba(34,197,94,0.22)" : "rgba(22,163,74,0.18)",
    };
  }

  return {
    label: "En attente",
    backgroundColor: isDark ? "rgba(245,158,11,0.16)" : "rgba(245,158,11,0.12)",
    color: isDark ? "#fbbf24" : "#92400e",
    borderColor: isDark ? "rgba(245,158,11,0.22)" : "rgba(245,158,11,0.18)",
  };
};
