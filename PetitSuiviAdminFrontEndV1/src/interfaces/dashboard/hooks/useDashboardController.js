import { useTheme } from "@mui/material";
import { useNavigate } from "react-router-dom";
import { tokens } from "../../../theme";
import { useDashboardData } from "./useDashboardData";
import { formatRevenuePercentage } from "../utils/formatRevenue";

export const useDashboardController = () => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";
  const navigate = useNavigate();

  const { loading, error, stats, upcomingEvents } = useDashboardData();

  const revenuePct = formatRevenuePercentage(
    stats.revenueCollected,
    stats.revenueExpected
  );

  const handleYearNavigation = () => {
    navigate("/management/parameters");
  };

  return {
    loading,
    error,
    stats,
    upcomingEvents,
    revenuePct,
    colors,
    isDark,
    handleYearNavigation
  };
};
