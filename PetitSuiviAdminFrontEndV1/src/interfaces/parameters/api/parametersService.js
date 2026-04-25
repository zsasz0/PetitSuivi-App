import api from "../../../api/axios";

export const parametersService = {
  fetchParameters: async () => {
    return api.get("/admin/parameters");
  },
  fetchPlannings: async () => {
    return api.get("/admin/plannings");
  },
  updateParameters: async (parameters) => {
    return api.put("/admin/parameters", { parameters });
  },
  fetchSignature: async () => {
    return api.get("/admin/parameters/signature");
  },
  uploadSignature: async (file) => {
    const formData = new FormData();
    formData.append("signature", file);
    return api.post("/admin/parameters/signature", formData, {
      headers: { "Content-Type": "multipart/form-data" },
    });
  },
  deleteSignature: async () => {
    return api.delete("/admin/parameters/signature");
  },
  archiveCurrentYear: async () => {
    return api.post("/admin/plannings/archive-current-year");
  },
  createPlanning: async (data) => {
    return api.post("/admin/plannings", data);
  },
  updatePlanning: async (id, data) => {
    return api.put(`/admin/plannings/${id}`, data);
  },
  deletePlanning: async (id) => {
    return api.delete(`/admin/plannings/${id}`);
  },
};
