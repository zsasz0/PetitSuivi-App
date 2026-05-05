import { Box, Button, CircularProgress, Dialog, DialogActions, DialogContent, DialogTitle, TextField, Typography } from "@mui/material";
import MealExceptionReviewBox from "./MealExceptionReviewBox";

const ApprovalReviewDialog = ({
    open,
    child,
    dietary,
    health,
    mealExceptions,
    mealScanLoading,
    saving,
    onDietaryChange,
    onHealthChange,
    onScanMeals,
    onMealToggle,
    onConfirm,
    onClose,
    colors,
    styles,
    isDark,
}) => (
    <Dialog open={open} onClose={saving ? undefined : onClose} fullWidth maxWidth="md" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>Validation IA avant approbation</DialogTitle>
        <DialogContent sx={{ mt: 2 }}>
            <Box display="flex" flexDirection="column" gap="18px">
                <Box sx={styles.stackedCard}>
                    <Typography variant="h6" fontWeight="700">{child?.child?.name || child?.child?.child_full_name || child?.child?.childName || "Élève"}</Typography>
                    <Typography variant="body2" color={colors.grey[300]} mt="4px">
                        Vérifiez le résumé IA et les repas à risque avant de confirmer l'approbation.
                    </Typography>
                </Box>

                <Box display="grid" gridTemplateColumns={{ xs: "1fr", lg: "1fr 1fr" }} gap="18px">
                    <Box sx={styles.aiBlock}>
                        <Typography variant="caption" color={isDark ? colors.greenAccent[300] : "#166534"} fontWeight="700" mb="8px" display="block">
                            Résumé diététique
                        </Typography>
                        <TextField
                            fullWidth
                            multiline
                            minRows={6}
                            value={dietary}
                            onChange={(event) => onDietaryChange(event.target.value)}
                            InputLabelProps={{ shrink: true }}
                            sx={styles.floatingField}
                        />
                        <Box mt="12px" display="flex" gap="10px" flexWrap="wrap">
                            <Button variant="outlined" onClick={() => onDietaryChange("✅ Aucune restriction alimentaire détectée.")} sx={styles.mutedButton}>
                                Aucune restriction
                            </Button>
                        </Box>
                    </Box>
                    <Box sx={styles.aiBlock}>
                        <Typography variant="caption" color={isDark ? colors.blueAccent[300] : "#1d4ed8"} fontWeight="700" mb="8px" display="block">
                            Résumé santé générale
                        </Typography>
                        <TextField
                            fullWidth
                            multiline
                            minRows={6}
                            value={health}
                            onChange={(event) => onHealthChange(event.target.value)}
                            InputLabelProps={{ shrink: true }}
                            sx={styles.floatingField}
                        />
                        <Box mt="12px" display="flex" gap="10px" flexWrap="wrap">
                            <Button variant="outlined" onClick={() => onHealthChange("✅ Aucun problème de santé notable détecté.")} sx={styles.mutedButton}>
                                Aucun problème notable
                            </Button>
                        </Box>
                    </Box>
                </Box>

                <MealExceptionReviewBox
                    title="Scanner les repas"
                    description="Le scan tient compte du résumé diététique et des notes de santé ayant un impact alimentaire."
                    exceptions={mealExceptions}
                    loading={mealScanLoading}
                    onScan={onScanMeals}
                    onToggle={onMealToggle}
                    colors={colors}
                    styles={styles}
                    isDark={isDark}
                />
            </Box>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={onClose} sx={{ color: colors.grey[100] }} disabled={saving}>Annuler</Button>
            <Button onClick={onConfirm} variant="contained" disabled={saving} sx={styles.approveButton}>
                {saving ? <CircularProgress size={18} sx={{ color: "#fff" }} /> : "Confirmer l'approbation"}
            </Button>
        </DialogActions>
    </Dialog>
);

export default ApprovalReviewDialog;
