import api from "../../../api/axios";

export const fetchClassTypes = async () => {
    const response = await api.get("/admin/class-types");
    return response.data?.data || [];
};

export const fetchPlannings = async () => {
    const response = await api.get("/admin/plannings");
    return response.data?.data || [];
};

export const fetchTeachers = async () => {
    const response = await api.get("/admin/teachers");
    return response.data?.data || [];
};

export const fetchClasses = async () => {
    const response = await api.get("/admin/classes");
    return response.data?.data || [];
};

export const createClass = async (classData) => {
    const response = await api.post("/admin/classes", classData);
    return response.data;
};

export const updateClass = async (id, classData) => {
    const response = await api.put(`/admin/classes/${id}`, classData);
    return response.data;
};

export const deleteClass = async (id) => {
    const response = await api.delete(`/admin/classes/${id}`);
    return response.data;
};

export const toggleArchiveClass = async (id) => {
    const response = await api.patch(`/admin/classes/${id}/toggle-archive`);
    return response.data;
};
