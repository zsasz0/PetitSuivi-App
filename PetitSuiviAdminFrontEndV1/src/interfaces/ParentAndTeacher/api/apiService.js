import api from "../../../api/axios";

/**
 * TEACHER API SERVICES
 */
export const getTeachers = () => api.get("/admin/teachers");
export const createTeacher = (payload) => api.post("/admin/teachers", payload);
export const updateTeacher = (cin, payload) => api.put(`/admin/teachers/${cin}`, payload);
export const deleteTeacher = (cin) => api.delete(`/admin/teachers/${cin}`);
export const toggleTeacherArchive = (cin) => api.patch(`/admin/teachers/${cin}/toggle-archive`);

/**
 * PARENT API SERVICES
 */
export const getParents = () => api.get("/admin/parents");
export const updateParent = (cin, payload) => api.put(`/admin/parents/${cin}`, payload);
export const deleteParent = (cin) => api.delete(`/admin/parents/${cin}`);
export const toggleParentArchive = (cin) => api.patch(`/admin/parents/${cin}/toggle-archive`);
export const updateParentApprovalStatus = (cin, status) => api.patch(`/admin/parents/${cin}/approval-status`, { status });

/**
 * SHARED DEPENDENCIES
 */
export const getClasses = () => api.get("/admin/classes");
export const getActivitiesByDate = (dateKey) => api.get(`/admin/activities/by-date/${dateKey}`);
