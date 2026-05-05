import api from "../../../api/axios";

export const fetchMeals = () => api.get("/admin/meals").then(res => res.data?.data || []);
export const fetchExceptionsForMeals = () => api.get('/admin/food-exceptions').then(res => res.data?.data || []);
export const fetchParameters = () => api.get("/admin/parameters").then(res => res.data?.data || res.data || []);
export const checkMealExceptions = (payload) => api.post('/admin/meals/check-exceptions', payload);
export const addMeal = (payload) => api.post("/admin/meals", payload);
export const updateDietaryComment = (childId, payload) => api.put(`/admin/inscriptions/${childId}/ai-comments`, payload);
export const deleteMeal = (id) => api.delete(`/admin/meals/${id}`);
