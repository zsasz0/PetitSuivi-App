import api from "../../../api/axios";

export const getInscriptionsRequest = async () => {
    const response = await api.get("/admin/inscriptions");
    return Array.isArray(response.data?.data) ? response.data.data : [];
};

export const getClassesRequest = async () => {
    const response = await api.get("/admin/classes");
    return Array.isArray(response.data?.data) ? response.data.data : [];
};

export const getAiEnabledStatus = async () => {
    const response = await api.get("/admin/parameters");
    const data = response.data?.data || response.data || [];
    const arr = Array.isArray(data) ? data : [];
    const aiParam = arr.find((param) => param.name === "ai_enabled");
    return aiParam ? (aiParam.value === "true" || aiParam.value === "1") : false;
};

export const updateInscriptionStatus = async (child, nextStatus, classId = null) => {
    const payload = { status: nextStatus };
    if (nextStatus === "approved" && classId) {
        payload.class_id = classId;
    } else if (nextStatus !== "approved") {
        payload.class_id = null;
    }
    await api.patch(`/admin/inscriptions/${child.inscriptionId}/status`, payload);
};

export const fetchAiMealExceptionsScan = async (childId, dietaryComment, healthComment) => {
    const response = await api.post(`/admin/inscriptions/${childId}/scan-meals`, {
        dietary_comment: dietaryComment,
        health_comment: healthComment,
    });
    if (response.data?.success !== true) {
        throw new Error(response.data?.message || "Le scan des repas a échoué.");
    }
    const exceptions = Array.isArray(response.data?.exceptions) ? response.data.exceptions : [];
    return exceptions.map((exception) => ({ ...exception, checked: true }));
};

export const saveAiMealExceptions = async (childId, mealExceptions) => {
    if (!childId || mealExceptions === null) return;
    const checkedExceptions = mealExceptions
        .filter((exception) => exception.checked !== false)
        .map((exception) => ({
            meal_id: exception.meal_id,
            reason: exception.reason,
        }));
    await api.post(`/admin/inscriptions/${childId}/save-food-exceptions`, {
        exceptions: checkedExceptions,
    });
};

export const updateAiComments = async (childId, dietaryComment, healthComment) => {
    await api.put(`/admin/inscriptions/${childId}/ai-comments`, {
        dietary_comment: dietaryComment,
        health_comment: healthComment,
    });
};

export const triggerMedicalRescan = async (childId) => {
    const response = await api.post(`/admin/inscriptions/${childId}/rescan-medical`, { save_to_db: false });
    if (response.data?.success !== true) {
        throw new Error(response.data?.message || "Le module IA a échoué pendant l'approbation.");
    }
    return response.data;
};

export const toggleArchiveInscription = async (inscriptionId) => {
    await api.patch(`/admin/inscriptions/${inscriptionId}/toggle-archive`);
};
