/**
 * @file dashboard/index.jsx
 * @description Dashboard orchestrator (data layer only)
 */

import { Box, CircularProgress, Alert } from "@mui/material";
import WarningAmberIcon from "@mui/icons-material/WarningAmber";

import Header from "../../../components/Header";

import StatsSection from "./StatsSection";
import RecentInscriptionsFeed from "./RecentInscriptionsFeed";
import UpcomingEventsFeed from "./UpcomingEventsFeed";
import BilanFinancier from "./BilanFinancier";

import { useDashboardController } from "../hooks/useDashboardController";

const Dashboard = () => {
  const {
    loading,
    error,
    stats,
    upcomingEvents,
    revenuePct,
    colors,
    isDark,
    handleYearNavigation
  } = useDashboardController();

  if (loading) {
    return (
      <Box
        m="20px"
        display="flex"
        justifyContent="center"
        alignItems="center"
        height="60vh"
      >
        <CircularProgress sx={{ color: colors.greenAccent[500] }} />
      </Box>
    );
  }

  return (
    <Box m="16px" pb="28px">
      <Header
        title="TABLEAU DE BORD"
        subtitle="Bienvenue dans votre tableau de bord — Toutes les années scolaires"
      />

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      {stats.yearEnded && (
        <Alert
          severity={stats.yearArchived ? "info" : "warning"}
          icon={stats.yearArchived ? undefined : <WarningAmberIcon />}
          sx={{ mb: 2, cursor: "pointer" }}
          onClick={handleYearNavigation}
        >
          {stats.yearArchived
            ? "Année archivée. Créez-en une nouvelle."
            : "Année terminée. Cliquez pour archiver."}
        </Alert>
      )}

      <StatsSection stats={stats} isDark={isDark} colors={colors} />

      <Box display="grid" gridTemplateColumns="repeat(12, 1fr)" gap="16px">
        <RecentInscriptionsFeed
          inscriptions={stats.recentInscriptions}
          colors={colors}
          isDark={isDark}
        />

        <UpcomingEventsFeed
          events={upcomingEvents}
          colors={colors}
          isDark={isDark}
        />

        <BilanFinancier
          stats={stats}
          revenuePct={revenuePct}
          colors={colors}
        />
      </Box>
    </Box>
  );
};

export default Dashboard;