import api from "../../../../api/axios";

export const paymentReportsService = {
  /**
   * Fetches the list of all school plannings.
   * @returns {Promise<Array>} The list of plannings.
   */
  async fetchPlannings() {
    const response = await api.get("/admin/plannings");
    return response.data?.data || [];
  },

  /**
   * Fetches the overarching payment report for a specific planning.
   * @param {string} planningId - The planning ID.
   * @returns {Promise<Object>} The report data.
   */
  async fetchReport(planningId) {
    const response = await api.get(`/admin/plannings/${planningId}/payment-report`);
    return response.data;
  },

  /**
   * Fetches the detailed payment data for a specific month within a planning.
   * @param {string} planningId - The planning ID.
   * @param {string} month - The month in "YYYY-MM" format.
   * @returns {Promise<Object>} The month details.
   */
  async fetchMonthDetails(planningId, month) {
    const response = await api.get(`/admin/plannings/${planningId}/payment-report/month/${month}`);
    return response.data;
  }
};
