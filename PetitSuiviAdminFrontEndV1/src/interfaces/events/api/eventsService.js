import api from "../../../api/axios";

export const eventsService = {
  getEvents: async () => {
    const res = await api.get("/admin/events");
    return (res.data?.data || []).map((event) => ({ ...event, id: event.id }));
  },
  
  getReferenceData: async () => {
    const [classesRes, teachersRes, parentsRes] = await Promise.all([
      api.get("/admin/classes").catch(() => ({ data: { data: [] } })),
      api.get("/admin/teachers").catch(() => ({ data: { data: [] } })),
      api.get("/admin/parents").catch(() => ({ data: { data: [] } })),
    ]);

    const classes = (classesRes.data?.data || []).filter((c) => !c.is_archived).map((c) => ({ id: c.id, name: c.name }));
    const teachers = (teachersRes.data?.data || []).map((t) => ({
      cin: t.cin,
      name: `${t.firstName || ""} ${t.lastName || ""}`.trim(),
      email: t.email || "",
    }));

    const allChildren = [{ id: "ALL", name: "Envoyer à tous", parentName: "Tous les parents" }];
    (parentsRes.data?.data || []).forEach((parent) => {
      (parent.children || []).forEach((child, index) => {
        allChildren.push({
          id: child.id || child.ChildID || `${parent.cin || "parent"}-${index}-${child.firstName}`,
          name: `${child.firstName || ""} ${child.lastName || ""}`.trim(),
          parentName: `${parent.firstName || ""} ${parent.lastName || ""}`.trim(),
        });
      });
    });

    return { classes, teachers, children: allChildren };
  },

  checkConflict: async (params) => {
    const res = await api.get("/admin/events/check-conflict", { params });
    return res.data;
  },

  createEvent: async (payload) => {
    const res = await api.post("/admin/events", payload);
    return res.data;
  },

  updateEvent: async (id, payload) => {
    const res = await api.put(`/admin/events/${id}`, payload);
    return res.data;
  },

  deleteEvent: async (id) => {
    await api.delete(`/admin/events/${id}`);
  },

  toggleStatus: async (id, newStatus) => {
    const res = await api.patch(`/admin/events/${id}/status`, { status: newStatus });
    return res.data;
  }
};
