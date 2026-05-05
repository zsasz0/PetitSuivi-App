import api from "../../../../api/axios";

export const behavioralHistoryService = {
  async fetchPlannings() {
    const response = await api.get("/admin/plannings");
    return response.data?.data || [];
  },

  async fetchHistory(planningId) {
    const response = await api.get(`/admin/reports/analysis-history?planning_id=${planningId}`);
    return response.data?.data || [];
  }
};
