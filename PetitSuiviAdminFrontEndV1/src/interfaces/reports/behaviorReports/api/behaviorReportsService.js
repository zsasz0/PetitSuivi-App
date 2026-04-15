import api from "../../../../api/axios";

export const behaviorReportsService = {
  async fetchPlannings() {
    const response = await api.get("/admin/plannings");
    return response.data?.data || [];
  },

  async fetchAiEnabled() {
    const response = await api.get("/admin/parameters");
    const data = response.data?.data || response.data || [];
    const parameterList = Array.isArray(data) ? data : [];
    const aiParameter = parameterList.find((parameter) => parameter.name === "ai_enabled");
    return aiParameter ? (aiParameter.value === "true" || aiParameter.value === "1") : true;
  },

  async fetchHistory(planningId) {
    const response = await api.get(`/admin/reports/analysis-history?planning_id=${planningId}`);
    return response.data?.data || [];
  },

  async fetchReport(planningId) {
    const response = await api.get(`/admin/plannings/${planningId}/report`);
    return response.data;
  },

  async requestAiAnalysis(childrenText) {
    const response = await api.post("/admin/ai/analyze-reports", {
      childrenText,
      max_tokens: 3500,
    });
    return response.data;
  },

  async saveAnalysisHistory(planningId, childId, childResult, analyzedSignalementIds) {
    return api.post("/admin/reports/analysis-history", {
      planning_id: planningId,
      child_id: childId,
      analysis_result: JSON.stringify(childResult),
      analyzed_signalement_ids: analyzedSignalementIds,
    });
  }
};
