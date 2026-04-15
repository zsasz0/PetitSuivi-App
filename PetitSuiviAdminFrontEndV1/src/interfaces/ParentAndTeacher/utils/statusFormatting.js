/**
 * Determines visual representation (dot color, text color, label) for a teacher's status.
 * @param {Object} teacher The teacher record
 * @param {Object} colors Theme colors object
 * @param {boolean} isDark Is dark mode active
 * @returns {Object|null} Meta configuration for rendering status
 */
export const getTeacherStatusMeta = (teacher, colors, isDark) => {
    if (!teacher) return null;
    if (teacher.is_archived) {
        return {
            label: "Archivé",
            dotColor: isDark ? colors.grey[400] : "#94a3b8",
            textColor: colors.grey[300],
        };
    }

    if (teacher.status === "En classe") {
        return {
            label: "Actif",
            dotColor: isDark ? colors.greenAccent[400] : "#16a34a",
            textColor: isDark ? colors.greenAccent[300] : "#166534",
        };
    }

    return {
        label: "Disponible",
        dotColor: isDark ? colors.blueAccent[400] : "#2563eb",
        textColor: isDark ? colors.blueAccent[300] : "#1d4ed8",
    };
};

/**
 * Determines visual representation (dot color, text color, label) for a parent's status.
 * @param {Object} parent The parent record
 * @param {Object} colors Theme colors object
 * @param {boolean} isDark Is dark mode active
 * @returns {Object} Meta configuration for rendering status
 */
export const getParentStatusMeta = (parent, colors, isDark) => {
    if (!parent) return null;
    if (parent.is_archived) {
        return {
            label: "Archivé",
            dotColor: isDark ? colors.grey[400] : "#94a3b8",
            textColor: colors.grey[300],
        };
    }

    if (parent.approval_status === "approved") {
        return {
            label: "Approuvé",
            dotColor: isDark ? colors.greenAccent[400] : "#16a34a",
            textColor: isDark ? colors.greenAccent[300] : "#166534",
        };
    }

    if (parent.approval_status === "rejected") {
        return {
            label: "Rejeté",
            dotColor: isDark ? colors.redAccent[400] : "#dc2626",
            textColor: isDark ? colors.redAccent[300] : "#991b1b",
        };
    }

    return {
        label: "En attente",
        dotColor: "#f59e0b",
        textColor: isDark ? "#fbbf24" : "#92400e",
    };
};
