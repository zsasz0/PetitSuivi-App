import { Box, CircularProgress, Typography, useTheme } from "@mui/material";
import HistoryEduOutlinedIcon from "@mui/icons-material/HistoryEduOutlined";
import Header from "../../../../components/Header";
import { tokens } from "../../../../theme";
import { useBehavioralHistoryController } from "../hooks/useBehavioralHistoryController";
import { getStyles } from "../utils/styles";
import { SummaryBar, Toolbar } from "./BehavioralHistorySummary";
import { HistoryList } from "./HistoryList";

const BehavioralHistoryPage = ({ showHeader = true }) => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";
  const styles = getStyles(colors, isDark);

  const {
    plannings,
    selectedPlanningId,
    setSelectedPlanningId,
    loadingHistory,
    expandedHistoryId,
    setExpandedHistoryId,
    page,
    setPage,
    searchTerm,
    setSearchTerm,
    filteredHistory,
    totalPages,
    paginatedHistory,
    stats,
  } = useBehavioralHistoryController();

  return (
    <Box {...(showHeader ? { m: "20px" } : {})}>
      {showHeader && <Header title="HISTORIQUE COMPORTEMENTAL" />}

      <Toolbar
        colors={colors}
        isDark={isDark}
        plannings={plannings}
        selectedPlanningId={selectedPlanningId}
        setSelectedPlanningId={setSelectedPlanningId}
        searchTerm={searchTerm}
        setSearchTerm={setSearchTerm}
      />

      <SummaryBar
        colors={colors}
        isDark={isDark}
        totalAnalyses={stats.totalAnalyses}
        uniqueChildren={stats.uniqueChildren}
        totalSignals={stats.totalSignals}
      />

      <Box sx={styles.panelShell}>
        <Box sx={styles.panelHeader}>
          <Box>
            <Typography sx={styles.panelTitle}>Historique des analyses</Typography>
            <Typography sx={styles.panelSubtitle}>{filteredHistory.length} entrée(s) pour l'année et les filtres sélectionnés</Typography>
          </Box>
          <Box sx={styles.panelTitleIconWrap}>
            <HistoryEduOutlinedIcon sx={{ color: colors.greenAccent[400], fontSize: 20 }} />
          </Box>
        </Box>

        {loadingHistory ? (
          <Box sx={styles.loadingState}>
            <CircularProgress size={28} sx={{ color: colors.greenAccent[500] }} />
            <Typography sx={styles.loadingText}>Chargement de l'historique...</Typography>
          </Box>
        ) : filteredHistory.length === 0 ? (
          <Box sx={styles.emptyState}>
            <Box sx={styles.emptyStateIconWrap}>
              <HistoryEduOutlinedIcon sx={{ color: colors.greenAccent[400], fontSize: 24 }} />
            </Box>
            <Typography sx={styles.emptyStateTitle}>Aucune analyse sauvegardée</Typography>
            <Typography sx={styles.emptyStateText}>
              {searchTerm
                ? "Aucun élève ne correspond à votre recherche."
                : "Les analyses générées apparaîtront ici pour l'année scolaire sélectionnée."}
            </Typography>
          </Box>
        ) : (
          <HistoryList
            colors={colors}
            isDark={isDark}
            paginatedHistory={paginatedHistory}
            expandedHistoryId={expandedHistoryId}
            setExpandedHistoryId={setExpandedHistoryId}
            totalPages={totalPages}
            page={page}
            setPage={setPage}
          />
        )}
      </Box>
    </Box>
  );
};

export default BehavioralHistoryPage;
