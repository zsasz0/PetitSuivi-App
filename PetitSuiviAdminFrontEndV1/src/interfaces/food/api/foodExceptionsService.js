import api from "../../../api/axios";

export const getPlannings = () => api.get("/admin/plannings").then(res => res.data?.data || []);
export const getParameters = () => api.get("/admin/parameters").then(res => res.data?.data || res.data || []);
export const getFoodExceptions = (planningId) => api.get(`/admin/food-exceptions${planningId ? `?planning_id=${planningId}` : ""}`);
export const getChildren = (planningId) => api.get(planningId ? `/admin/children?planning_id=${planningId}` : '/admin/children');
export const getMeals = () => api.get("/admin/meals");
export const addFoodException = (payload) => api.post('/admin/food-exceptions', payload);
export const deleteFoodException = (id) => api.delete(`/admin/food-exceptions/${id}`);
