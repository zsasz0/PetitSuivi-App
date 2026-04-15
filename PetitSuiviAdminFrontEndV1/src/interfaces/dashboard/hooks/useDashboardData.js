import { useState, useEffect } from "react";
import { fetchDashboardData } from "../api/dashboardService";
import { calculateDashboardStats } from "../utils/dashboardCalculations";

export const useDashboardData = () => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const [stats, setStats] = useState({
    totalChildren: 0,
    totalTeachers: 0,
    totalParents: 0,
    totalClasses: 0,
    approvedChildrenThisWeek: 0,
    activeTeachers: 0,
    activeParents: 0,
    activeClasses: 0,
    revenueCollected: 0,
    revenueExpected: 0,
    recentInscriptions: [],
    academicYear: "",
    yearEnded: false,
    yearEndedMessage: null,
    yearArchived: false,
  });

  const [upcomingEvents, setUpcomingEvents] = useState([]);

  useEffect(() => {
    const load = async () => {
      try {
        setLoading(true);
        setError(null);

        const {
          parents,
          teachers,
          classes,
          inscriptions,
          payments,
          plannings,
          events,
          dashData,
        } = await fetchDashboardData();

        setUpcomingEvents(events || []);

        const computed = calculateDashboardStats({
          inscriptions,
          teachers,
          parents,
          classes,
          payments,
          plannings,
        });

        setStats({
          ...computed,
          totalTeachers: teachers.length,
          totalParents: parents.length,
          totalClasses: classes.length,
          yearEnded: dashData.year_ended || false,
          yearEndedMessage: dashData.year_ended_message || null,
          yearArchived: dashData.year_archived || false,
        });
      } catch (err) {
        console.error("Dashboard load error:", err);
        setError("Failed to load dashboard data");
      } finally {
        setLoading(false);
      }
    };

    load();
  }, []);

  return {
    loading,
    error,
    stats,
    upcomingEvents,
  };
};
