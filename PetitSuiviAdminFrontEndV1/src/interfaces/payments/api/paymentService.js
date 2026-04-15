import api from "../../../api/axios";

/**
 * @file api/paymentService.js
 * @description API wrapper for payment-related operations.
 */

export const getPaymentsRequest = async () => {
    const response = await api.get("/admin/payments");
    return response.data?.data || [];
};

export const getInscriptionsRequest = async () => {
    const response = await api.get("/admin/inscriptions");
    return response.data?.data || [];
};

export const getParametersRequest = async () => {
    try {
        const response = await api.get("/admin/parameters");
        return response.data?.data || response.data || [];
    } catch {
        return [];
    }
};

export const getPlanningsRequest = async () => {
    try {
        const response = await api.get("/admin/plannings");
        return response.data?.data || response.data || [];
    } catch {
        return [];
    }
};

export const postTransaction = async (inscriptionId, childId, payload) => {
    return await api.post(`/admin/payments/${inscriptionId}/${childId}/transactions`, payload);
};

export const patchToggleFrais = async (inscriptionId, checked) => {
    return await api.patch(`/admin/inscriptions/${inscriptionId}/frais`, { checked });
};
