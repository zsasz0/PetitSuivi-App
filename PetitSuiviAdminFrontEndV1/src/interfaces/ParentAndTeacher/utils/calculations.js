/**
 * Generates a random alphanumeric password containing secure characters.
 * @param {number} length Length of the password
 * @returns {string} Randomly generated password
 */
export const generateRandomPassword = (length = 10) => {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%';
    return Array.from({ length }).map(() => chars.charAt(Math.floor(Math.random() * chars.length))).join('');
};

/**
 * Calculate parent dashboard stats.
 * @param {Array} parentsList List of fetched parents
 * @returns {Object} Calculated stats
 */
export const calculateParentStats = (parentsList = []) => ({
    total: parentsList.length,
    approved: parentsList.filter((parent) => parent.approval_status === "approved").length,
    pending: parentsList.filter((parent) => parent.approval_status === "pending").length,
    rejected: parentsList.filter((parent) => parent.approval_status === "rejected").length,
    archived: parentsList.filter((parent) => parent.is_archived).length,
});

/**
 * Process the active teacher checks based on classes and daily activities.
 * Returns a configured teacher list and the active count.
 * @param {Array} teacherData Master teacher API data
 * @param {Array} classesResult Classes API data
 * @param {Array} activitiesResult Activities API data
 * @returns {Object} Resulting mapped teachers and count
 */
export const computeTeacherActivity = (teacherData, classesResult, activitiesResult) => {
    const teacherCinsByClassId = {};
    if (classesResult.status === 'fulfilled') {
        const classes = classesResult.value.data?.data || [];
        classes.forEach((schoolClass) => {
            const classId = String(schoolClass?.id || '');
            if (!classId) return;
            teacherCinsByClassId[classId] = (schoolClass.teachers || []).map(t => String(t?.cin || '')).filter(Boolean);
        });
    }

    const teacherCinSet = new Set(
        teacherData.map((teacher) => String(teacher?.cin || '')).filter(Boolean)
    );

    const activeSet = new Set();
    if (activitiesResult.status === 'fulfilled') {
        (activitiesResult.value.data?.data || []).forEach(activity => {
            const classId = String(activity?.class?.id || '');
            const classTeacherCins = teacherCinsByClassId[classId] || [];

            if (classTeacherCins.length > 0) {
                classTeacherCins.forEach((cin) => activeSet.add(cin));
                return;
            }

            const directTeacherCin = String(activity?.teacher_id || activity?.teacher?.cin || '');
            if (teacherCinSet.has(directTeacherCin)) {
                activeSet.add(directTeacherCin);
            }
        });
    }

    let activeTodayCount = 0;
    const formattedData = teacherData.map((t) => {
        const cinStr = String(t.cin || '');
        const isActive = activeSet.has(cinStr);
        const isArchived = !!t.is_archived;
        if (!isArchived && isActive) activeTodayCount++;

        return {
            id: t.cin, cin: t.cin,
            name: `${t.firstName || ""} ${t.lastName || ""}`.trim(),
            firstName: t.firstName || "", lastName: t.lastName || "",
            birthdate: t.birthdate || "-", phone: t.phone || "-", email: t.email || "-", adresse: t.adresse || "",
            is_archived: isArchived, status: isArchived ? 'Archivé' : (isActive ? 'En classe' : 'Disponible')
        };
    });

    return { formattedData, activeTodayCount };
};

/** Map of known English Laravel validation messages → French translations */
const ERROR_TRANSLATIONS = {
    "The cin has already been taken.": "Ce CIN est déjà utilisé.",
    "The email has already been taken.": "Cette adresse e-mail est déjà utilisée.",
    "The name has already been taken.": "Ce nom est déjà utilisé.",
};

const translateError = (msg) => ERROR_TRANSLATIONS[msg] ?? msg;

/**
 * Safely format api errors for the forms
 */
export const applyApiErrors = (validationErrors, setFieldErrors, setGlobalError, fallbackMessage) => {
    if (validationErrors?.email?.[0]) {
        const msg = translateError(validationErrors.email[0]);
        setFieldErrors((previous) => ({ ...previous, email: msg }));
        setGlobalError(msg);
        return;
    }

    if (validationErrors) {
        const firstKey = Object.keys(validationErrors)[0];
        const firstMessage = validationErrors[firstKey]?.[0];
        if (firstMessage) {
            setGlobalError(translateError(firstMessage));
            return;
        }
    }

    setGlobalError(fallbackMessage);
};
