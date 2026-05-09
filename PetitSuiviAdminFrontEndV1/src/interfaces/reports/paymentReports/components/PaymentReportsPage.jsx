import { Box, Dialog, DialogContent, DialogTitle, IconButton, Typography, useTheme } from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";
import Header from "../../../../components/Header";
import { tokens } from "../../../../theme";
import { usePaymentReportsController } from "../hooks/usePaymentReportsController";
import { getStyles } from "../utils/styles";
import { formatMonth } from "../utils/formatters";
import { FINANCE_COLORS } from "../utils/constants";
import { PlanningToolbar } from "./PlanningToolbar";
import { SummaryCards } from "./SummaryCards";
import { LoadingSkeleton, ModalSkeleton } from "./Skeletons";
import { CollectionProgressCard, MonthlyStatusChart, PaymentStatusDonut } from "./PaymentReportCharts";
import { ParentTableSection } from "./PaymentModalComponents";

const PaymentReportsPage = () => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";
  const styles = getStyles(colors, isDark);

  const {
    plannings,
    selectedPlanningId,
    setSelectedPlanningId,
    reportData,
    loading,
    modalOpen,
    setModalOpen,
    modalMonth,
    modalData,
    modalLoading,
    handleMonthClick,
  } = usePaymentReportsController();

  return (
    <Box m="20px">
      <Header title="RAPPORTS DE PAIEMENT" />

      <PlanningToolbar
        colors={colors}
        isDark={isDark}
        plannings={plannings}
        selectedPlanningId={selectedPlanningId}
        setSelectedPlanningId={setSelectedPlanningId}
      />

      {loading ? (
        <LoadingSkeleton colors={colors} isDark={isDark} />
      ) : reportData ? (
        <>
          <SummaryCards colors={colors} isDark={isDark} summary={reportData.summary} />

          <Box sx={styles.chartsGrid}>
            <PaymentStatusDonut colors={colors} isDark={isDark} summary={reportData.summary} />
            <CollectionProgressCard colors={colors} isDark={isDark} summary={reportData.summary} />
          </Box>

          <MonthlyStatusChart
            colors={colors}
            isDark={isDark}
            data={reportData.monthly_status_data}
            onMonthClick={handleMonthClick}
          />
        </>
      ) : (
        <Box sx={styles.emptyChartState}>
          <Typography sx={styles.emptyChartTitle}>Aucun rapport financier disponible</Typography>
          <Typography sx={styles.emptyChartText}>Les statistiques financières apparaîtront ici une fois les données chargées.</Typography>
        </Box>
      )}

      <Dialog
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        maxWidth="lg"
        fullWidth
        slotProps={{
          backdrop: {
            sx: {
              backgroundColor: "rgba(2, 6, 23, 0.68)",
              backdropFilter: "blur(8px)",
            },
          },
        }}
        PaperProps={{ sx: styles.modalPaper }}
      >
        <DialogTitle sx={styles.modalTitleRow}>
          <Box>
            <Typography sx={styles.modalTitle}>Détail des paiements</Typography>
            <Typography sx={styles.modalSubtitle}>{formatMonth(modalMonth)}</Typography>
          </Box>
          <IconButton onClick={() => setModalOpen(false)} sx={styles.modalCloseButton}>
            <CloseIcon />
          </IconButton>
        </DialogTitle>
        <DialogContent sx={{ px: { xs: 2, md: 3 }, pb: 3 }}>
          {modalLoading ? (
            <ModalSkeleton colors={colors} isDark={isDark} />
          ) : modalData ? (
            <Box>
              <ParentTableSection
                colors={colors}
                isDark={isDark}
                list={modalData.paid_fully}
                title="Payé"
                color={FINANCE_COLORS.paid}
              />
              <ParentTableSection
                colors={colors}
                isDark={isDark}
                list={modalData.paid_partially}
                title="Partiellement payé"
                color={FINANCE_COLORS.partial}
              />
              <ParentTableSection
                colors={colors}
                isDark={isDark}
                list={modalData.not_paid}
                title="Non payé"
                color={FINANCE_COLORS.pending}
              />

              {!modalData.paid_fully?.length && !modalData.paid_partially?.length && !modalData.not_paid?.length && (
                <Box sx={styles.emptyChartState}>
                  <Typography sx={styles.emptyChartTitle}>Aucune inscription mensuelle</Typography>
                  <Typography sx={styles.emptyChartText}>Aucune ligne de paiement n'a été trouvée pour ce mois.</Typography>
                </Box>
              )}
            </Box>
          ) : (
            <Box sx={styles.emptyChartState}>
              <Typography sx={styles.emptyChartTitle}>Erreur de chargement</Typography>
              <Typography sx={styles.emptyChartText}>Les données de détail n'ont pas pu être récupérées pour ce mois.</Typography>
            </Box>
          )}
        </DialogContent>
      </Dialog>
    </Box>
  );
};

export default PaymentReportsPage;
