import { Box, CircularProgress, Typography, useTheme, Snackbar, Alert } from "@mui/material";
import Header from "../../../../components/Header";
import { tokens } from "../../../../theme";
import { useBehaviorReportsController } from "../hooks/useBehaviorReportsController";
import { getStyles } from "../utils/styles";
import { PlanningToolbar, SummaryBar } from "./BehavioralSummary";
import { ChildrenListSection } from "./ChildrenListComponents";

const BehaviorReportsPage = ({ showHeader = true }) => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";
  const styles = getStyles(colors, isDark);

  const {
    toast,
    closeToast,
    plannings,
    selectedPlanningId,
    setSelectedPlanningId,
    reportData,
    loading,
    aiEnabled,
    aiAnalysis,
    isAnalyzing,
    analysisHistory,
    searchTerm,
    setSearchTerm,
    expandedChild,
    setExpandedChild,
    isAiPanelOpen,
    setIsAiPanelOpen,
    allFlaggedChildren,
    filteredChildren,
    totalSignalements,
    analyzedSignalementIds,
    handleAnalyze
  } = useBehaviorReportsController();

  return (
    <Box {...(showHeader ? { m: "20px" } : {})}>
      {showHeader && <Header title="SIGNALEMENTS COMPORTEMENTAUX" />}

      <PlanningToolbar
        colors={colors}
        isDark={isDark}
        plannings={plannings}
        selectedPlanningId={selectedPlanningId}
        setSelectedPlanningId={setSelectedPlanningId}
        searchTerm={searchTerm}
        setSearchTerm={setSearchTerm}
      />

      {loading ? (
        <Box sx={styles.loadingState}>
          <CircularProgress sx={{ color: colors.greenAccent[500] }} />
          <Typography sx={styles.loadingText}>Chargement des signalements...</Typography>
        </Box>
      ) : !reportData ? (
        <Box sx={styles.emptyPanel}>
          <Typography sx={styles.emptyStateTitle}>Aucune donnée disponible</Typography>
          <Typography sx={styles.emptyStateText}>Les signalements de l'année sélectionnée n'ont pas pu être chargés.</Typography>
        </Box>
      ) : (
        <>
          <SummaryBar
            colors={colors}
            isDark={isDark}
            totalSignalements={totalSignalements}
            flaggedCount={allFlaggedChildren.length}
            classCount={new Set(allFlaggedChildren.map((child) => child.class_id)).size}
          />

          <ChildrenListSection
            colors={colors}
            isDark={isDark}
            filteredChildren={filteredChildren}
            expandedChild={expandedChild}
            setExpandedChild={setExpandedChild}
            analyzedSignalementIds={analyzedSignalementIds}
            aiEnabled={aiEnabled}
            isAnalyzing={isAnalyzing}
            aiAnalysis={aiAnalysis}
            analysisHistory={analysisHistory}
            onAnalyze={handleAnalyze}
            isAiPanelOpen={isAiPanelOpen}
            setIsAiPanelOpen={setIsAiPanelOpen}
          />
        </>
      )}

      <Snackbar
        open={toast.open}
        autoHideDuration={6000}
        onClose={closeToast}
        anchorOrigin={{ vertical: "top", horizontal: "right" }}
        sx={{ zIndex: 3000 }}
      >
        <Alert onClose={closeToast} severity={toast.severity} sx={{ width: "100%" }} variant="filled">
          {toast.message}
        </Alert>
      </Snackbar>
    </Box>
  );
};

export default BehaviorReportsPage;
