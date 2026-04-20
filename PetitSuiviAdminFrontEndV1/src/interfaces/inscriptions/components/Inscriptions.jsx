import { Box, Portal, Snackbar, Tab, Tabs, Typography, useTheme, Alert } from "@mui/material";
import { DataGrid, frFR } from "@mui/x-data-grid";
import Header from "../../../components/Header";
import { tokens } from "../../../theme";
import "./MedicalForm.css";

// Utils
import { getStyles } from "../utils/styles";

// Services (Controller Hook)
import { useInscriptionsController } from "../hooks/useInscriptionsController";

// Components
import { getInscriptionsColumns } from "./inscriptionsColumns";
import AiDisabledBanner from "./AiDisabledBanner";
import StatsCards from "./StatsCards";
import InscriptionsGridToolbar from "./InscriptionsGridToolbar";
import ClassAssignDialog from "./ClassAssignDialog";
import InscriptionDetailDialog from "./InscriptionDetailDialog";
import ApprovalReviewDialog from "./ApprovalReviewDialog";

const FR_LOCALE = frFR.components.MuiDataGrid.defaultProps.localeText;

const Inscriptions = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const isDark = theme.palette.mode === "dark";
    const styles = getStyles(colors, isDark);

    const {
        loading,
        aiEnabled,
        inscriptionTab,
        setInscriptionTab,
        selectedClassId,
        setSelectedClassId,
        classAssignError,
        assignLoading,
        decisionLoading,

        detailSaving,
        detailDietary,
        setDetailDietary,
        detailHealth,
        setDetailHealth,
        detailMealScanLoading,
        detailMealExceptions,
        detailAiEditMode,
        setDetailAiEditMode,

        aiReviewContext,
        aiReviewDietary,
        setAiReviewDietary,
        aiReviewHealth,
        setAiReviewHealth,
        aiReviewMealExceptions,
        aiReviewMealScanLoading,
        aiReviewSaving,

        toast,
        closeToast,
        medicalDocRef,

        detailChild,
        assignTargetChild,
        detailDirty,
        stats,
        activeRows,
        archivedRows,
        classOptionsForAssign,
        mealReviewDirty,

        openDetailDialog,
        closeDetailDialog,
        closeAssignDialog,
        closeAiReviewDialog,
        handleSaveSummary,
        handleDetailScanMeals,
        handlePrintMedical,
        handleApproveFromDialog,
        handleRejectFromDialog,
        handleResetPending,
        handleAiReviewScanMeals,
        handleConfirmApprovalReview,
        handleConfirmAssign,
        handleToggleArchiveClick,
        
        toggleDetailMealExceptionChecked,
        toggleAiReviewMealExceptionChecked,
    } = useInscriptionsController();

    const columns = getInscriptionsColumns({ colors, isDark, styles, openDetailDialog });

    return (
        <Box m="20px">
            <Header title="INSCRIPTIONS" />

            {!aiEnabled && <AiDisabledBanner colors={colors} isDark={isDark} />}

            <StatsCards stats={stats} colors={colors} styles={styles} isDark={isDark} />

            <Box display="flex" justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }} flexDirection={{ xs: "column", md: "row" }} gap="12px" mb="14px">
                <Box>
                    <Typography variant="h5" fontWeight="bold" color={colors.grey[100]}>
                        Gestion des inscriptions
                    </Typography>
                    <Typography variant="body2" color={colors.grey[300]} mt="4px">
                        Ouvrez la fiche d&apos;un élève pour gérer les décisions, le dossier médical et le résumé IA sans surcharger le tableau.
                    </Typography>
                </Box>
                <Tabs
                    value={inscriptionTab}
                    onChange={(_, value) => setInscriptionTab(value)}
                    textColor="inherit"
                    indicatorColor="secondary"
                    sx={{
                        minHeight: 42,
                        "& .MuiTabs-flexContainer": { gap: "8px" },
                        "& .MuiTab-root": {
                            minHeight: 42,
                            borderRadius: "999px",
                            textTransform: "none",
                            fontWeight: 700,
                            color: colors.grey[300],
                            backgroundColor: colors.primary[400],
                            border: `1px solid ${colors.primary[500]}`,
                        },
                        "& .MuiTab-root.Mui-selected": {
                            color: isDark ? "#ffffff" : "#0f172a",
                            backgroundColor: isDark ? "#475569" : "#cbd5e1",
                        },
                        "& .MuiTabs-indicator": { display: "none" },
                    }}
                >
                    <Tab value="active" label={`Actives (${activeRows.length})`} />
                    <Tab value="archived" label={`Archivées (${archivedRows.length})`} />
                </Tabs>
            </Box>

            <Box height="66vh" sx={styles.gridContainer}>
                <DataGrid
                    loading={loading}
                    rows={inscriptionTab === "active" ? activeRows : archivedRows}
                    columns={columns}
                    pageSize={10}
                    rowsPerPageOptions={[10, 50, 100]}
                    disableSelectionOnClick
                    localeText={FR_LOCALE}
                    components={{ Toolbar: InscriptionsGridToolbar }}
                    componentsProps={{ toolbar: { colors, isDark } }}
                    initialState={{ columns: { columnVisibilityModel: { inscriptionYear: false } } }}
                />
            </Box>

            <ClassAssignDialog
                open={!!assignTargetChild}
                child={assignTargetChild}
                selectedClassId={selectedClassId}
                onClassChange={setSelectedClassId}
                classOptions={classOptionsForAssign}
                error={classAssignError}
                loading={assignLoading}
                onConfirm={handleConfirmAssign}
                onClose={closeAssignDialog}
                colors={colors}
                styles={styles}
            />

            <InscriptionDetailDialog
                open={!!detailChild}
                child={detailChild}
                dietary={detailDietary}
                health={detailHealth}
                dirty={detailDirty}
                saving={detailSaving}
                aiEditMode={detailAiEditMode}
                mealScanLoading={detailMealScanLoading}
                mealExceptions={detailMealExceptions}
                mealReviewDirty={mealReviewDirty}
                decisionLoading={decisionLoading}
                onDietaryChange={setDetailDietary}
                onHealthChange={setDetailHealth}
                onScanMeals={handleDetailScanMeals}
                onMealToggle={toggleDetailMealExceptionChecked}
                onSave={handleSaveSummary}
                onEditToggle={() => {
                    if (detailAiEditMode) {
                        setDetailDietary(detailChild?.dietary_comment || "");
                        setDetailHealth(detailChild?.health_comment || "");
                        // We would need a setDetailMealExceptions(null) if we want to perfect it,
                        // but setting detail ai edit mode to false effectively hides it anyway.
                    }
                    setDetailAiEditMode((prev) => !prev);
                }}
                onPrint={handlePrintMedical}
                onClose={closeDetailDialog}
                onApprove={handleApproveFromDialog}
                onReject={handleRejectFromDialog}
                onResetPending={handleResetPending}
                onArchiveToggle={handleToggleArchiveClick}
                onOpenAssign={handleApproveFromDialog} // Same handler reuse
                colors={colors}
                styles={styles}
                isDark={isDark}
                medicalDocRef={medicalDocRef}
            />

            <ApprovalReviewDialog
                open={!!aiReviewContext}
                child={aiReviewContext}
                dietary={aiReviewDietary}
                health={aiReviewHealth}
                mealExceptions={aiReviewMealExceptions}
                mealScanLoading={aiReviewMealScanLoading}
                saving={aiReviewSaving}
                onDietaryChange={setAiReviewDietary}
                onHealthChange={setAiReviewHealth}
                onScanMeals={handleAiReviewScanMeals}
                onMealToggle={toggleAiReviewMealExceptionChecked}
                onConfirm={handleConfirmApprovalReview}
                onClose={closeAiReviewDialog}
                colors={colors}
                styles={styles}
                isDark={isDark}
            />

            <Portal>
                <Snackbar
                    open={toast.open}
                    autoHideDuration={5000}
                    onClose={closeToast}
                    anchorOrigin={{ vertical: "top", horizontal: "right" }}
                    sx={{ zIndex: 2001 }}
                >
                    <Alert onClose={closeToast} severity={toast.severity} variant="outlined" sx={{ width: "100%", maxWidth: "420px", alignItems: "center", borderRadius: "14px", boxShadow: "0 12px 28px rgba(15,23,42,0.12)", backgroundColor: isDark ? "rgba(17,24,39,0.96)" : "rgba(255,250,242,0.98)", color: isDark ? colors.grey[100] : "#3f2a12", borderColor: "rgba(245,158,11,0.35)" }}>
                        {toast.message}
                    </Alert>
                </Snackbar>
            </Portal>
        </Box>
    );
};

export default Inscriptions;
