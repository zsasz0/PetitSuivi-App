import api from "../../../api/axios";

export const getPlannings = () => api.get("/admin/plannings");
export const getParameters = () => api.get("/admin/parameters");
export const getMeals = () => api.get("/admin/meals");
export const getExceptionsByType = (type, planningId) => {
    const base = planningId ? `planning_id=${planningId}&` : '';
    return api.get(`/admin/food-exceptions?${base}meal_type=${type}`);
};
export const getWeekMeals = (dateStr) => api.get(`/admin/meals/by-week/${dateStr}`);
export const getMenuPlannings = () => api.get("/admin/menu-plannings");
export const getOverrides = (dateStr) => api.get(`/admin/child-food-exception-overrides?week_start=${dateStr}`);
export const applyWeekMenu = (payload) => api.post("/admin/menu-plannings/apply-week", payload);
export const saveExceptionOverrides = (payload) => api.post('/admin/child-food-exception-overrides', payload);
export const loadMenuPlanning = (id) => api.get(`/admin/menu-plannings/${id}`);
export const deleteMenuPlanning = (id) => api.delete(`/admin/menu-plannings/${id}`);
export const createMenuPlanning = (payload) => api.post('/admin/menu-plannings', payload);
