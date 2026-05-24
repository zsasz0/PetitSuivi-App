import api from "../../../api/axios";
/**
 * Fetches all dashboard-related backend data in parallel.
 * Handles API fallback safety.
 */
export const fetchDashboardData = async () => {
  const [
    parentsRes,
    teachersRes,
    classesRes,
    inscriptionsRes,
    paymentsRes,
    planningsRes,
    eventsRes,
    dashStatsRes,
  ] = await Promise.all([
    api.get("/admin/parents").catch(() => ({ data: { data: [] } })),
    api.get("/admin/teachers").catch(() => ({ data: { data: [] } })),
    api.get("/admin/classes").catch(() => ({ data: { data: [] } })),
    api
      .get("/admin/inscriptions", {
        params: { include_unapproved_parent_children: 1 },
      })
      .catch(() => ({ data: { data: [] } })),
    api.get("/admin/payments").catch(() => ({ data: { data: [] } })),
    api.get("/admin/plannings").catch(() => ({ data: { data: [] } })),
    api.get("/admin/events/upcoming").catch(() => ({ data: { data: [] } })),
    api.get("/admin/dashboard/stats").catch(() => ({ data: { data: {} } })),
  ]);

  return {
    parents: parentsRes.data?.data || [],
    teachers: teachersRes.data?.data || [],
    classes: classesRes.data?.data || [],
    inscriptions: inscriptionsRes.data?.data || [],
    payments: paymentsRes.data?.data || [],
    plannings: planningsRes.data?.data || [],
    events: eventsRes.data?.data || [],
    dashData: dashStatsRes.data?.data || {},
  };
};
