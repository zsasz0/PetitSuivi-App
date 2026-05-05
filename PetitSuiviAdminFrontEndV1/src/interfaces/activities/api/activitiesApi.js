import api from "../../../api/axios";

export const activitiesApi = {
  getPlannings: () => api.get("/admin/plannings").catch(() => ({ data: { data: [] } })),
  getClasses: () => api.get("/admin/classes").catch(() => ({ data: { data: [] } })),
  getCriteria: () => api.get("/admin/criteria").catch(() => ({ data: { data: [] } })),
  getActivities: () => api.get("/admin/activities").catch(() => ({ data: { data: [] } })),
  getParameters: () => api.get("/admin/parameters"),
  
  getPlannedActivities: (planningId) => api.get(`/admin/plannings/${planningId}/activities`),
  addPlannedActivity: (planningId, payload) => api.post(`/admin/plannings/${planningId}/activities`, payload),
  deletePlannedActivity: (planningId, activityId) => api.delete(`/admin/plannings/${planningId}/activities/${activityId}`),

  addCriteria: (payload) => api.post("/admin/criteria", payload),
  deleteCriteria: (id) => api.delete(`/admin/criteria/${id}`),

  addActivity: (payload) => api.post("/admin/activities", payload),
  updateActivity: (id, payload) => api.put(`/admin/activities/${id}`, payload),
  deleteActivity: (id) => api.delete(`/admin/activities/${id}`),

  suggestCriteria: (payload) => api.post("/admin/ai/suggest-activity-criteria", payload),
};
