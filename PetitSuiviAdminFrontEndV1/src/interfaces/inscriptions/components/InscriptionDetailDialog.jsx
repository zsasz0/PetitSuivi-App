import { Box, Button, Chip, Dialog, DialogActions, DialogContent, DialogTitle, TextField, Typography } from "@mui/material";
import StatusBadge from "./StatusBadge";
import MedicalFormDocument from "./MedicalFormDocument";
import MealExceptionReviewBox from "./MealExceptionReviewBox";

const InscriptionDetailDialog = ({
    open,
    child,
    dietary,
    health,
    mealScanLoading,
    mealExceptions,
    mealReviewDirty,
    dirty,
    saving,
    aiEditMode,
    decisionLoading,
    onDietaryChange,
    onHealthChange,
    onScanMeals,
    onMealToggle,
    onSave,
    onEditToggle,
    onPrint,
    onClose,
    onApprove,
    onReject,
    onResetPending,
    onArchiveToggle,
    onOpenAssign,
    colors,
    styles,
    isDark,
    medicalDocRef,
}) => {
    if (!child) return null;

    const form = child.medicalApplication;
    const isEmpty = !form || typeof form !== "object" || Object.keys(form).length === 0;
    const formData = form?.form_data || form;
    const isFormDataEmpty = !formData || typeof formData !== "object" || Object.keys(formData).length === 0;
    const showTemplate = isEmpty || isFormDataEmpty;
    const isApproved = child.approval === "approved";

    return (
        <Dialog open={open} onClose={saving || decisionLoading ? undefined : onClose} fullWidth maxWidth="lg" PaperProps={{ sx: { ...styles.dialogPaper, minHeight: "82vh" } }}>
            <DialogTitle sx={styles.dialogTitle}>Fiche d&apos;inscription</DialogTitle>
            <DialogContent sx={{ mt: 2 }}>
                <Box display="flex" flexDirection="column" gap="18px">
                    <Box sx={styles.topProfileCard}>
                        <Box display="flex" justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }} flexDirection={{ xs: "column", md: "row" }} gap="16px">
                            <Box>
                                <Typography variant="h4" fontWeight="800">{child.name}</Typography>
                                <Box display="flex" alignItems="center" gap="8px" flexWrap="wrap" mt="8px">
                                    <Box component="span" sx={styles.infoBadge}>{child.age} ans</Box>
                                    <StatusBadge status={child.approval} styles={styles} />
                                    <Box component="span" sx={styles.infoBadge}>{child.parent}</Box>
                                </Box>
                            </Box>
                        </Box>
                        <Box sx={{ ...styles.metaGrid, mt: "18px" }}>
                            <Box sx={styles.metaItem}>
                                <Typography variant="caption" color={colors.grey[300]}>Type souhaité</Typography>
                                <Typography fontWeight="700" mt="6px">{child.inscriptionType}</Typography>
                            </Box>
                            <Box sx={styles.metaItem}>
                                <Typography variant="caption" color={colors.grey[300]}>Paiement</Typography>
                                <Typography fontWeight="700" mt="6px">{child.paymentMethod}</Typography>
                            </Box>
                            <Box sx={styles.metaItem}>
                                <Typography variant="caption" color={colors.grey[300]}>Montant total</Typography>
                                <Typography fontWeight="700" mt="6px">{child.totalAmount}</Typography>
                            </Box>
                            <Box sx={styles.metaItem}>
                                <Typography variant="caption" color={colors.grey[300]}>Inscriptions précédentes</Typography>
                                <Typography fontWeight="700" mt="6px">{child.previousInscriptions}</Typography>
                            </Box>
                            <Box sx={styles.metaItem}>
                                <Typography variant="caption" color={colors.grey[300]}>Classe</Typography>
                                <Box mt="8px">
                                    {child.approval === "approved" ? (
                                        child.inscriptionClass ? (
                                            <Chip
                                                label={child.inscriptionClass}
                                                size="small"
                                                sx={{
                                                    backgroundColor: isDark ? "rgba(34,197,94,0.18)" : "rgba(22,163,74,0.12)",
                                                    color: isDark ? colors.greenAccent[300] : "#166534",
                                                    border: `1px solid ${isDark ? "rgba(34,197,94,0.22)" : "rgba(22,163,74,0.18)"}`,
                                                    fontWeight: 700,
                                                }}
                                            />
                                        ) : (
                                            <Box component="span" sx={styles.infoBadge}>Non assignée</Box>
                                        )
                                    ) : (
                                        <Button variant="outlined" onClick={() => onOpenAssign(child)} sx={styles.assignBadge}>
                                            Assigner
                                        </Button>
                                    )}
                                </Box>
                            </Box>
                            <Box sx={styles.metaItem}>
                                <Typography variant="caption" color={colors.grey[300]}>Date d&apos;inscription</Typography>
                                <Typography fontWeight="700" mt="6px">{child.inscriptionDate}</Typography>
                            </Box>
                        </Box>
                    </Box>

                    <Box sx={styles.stackedCard}>
                        <Typography variant="h6" fontWeight="700">Décision et archivage</Typography>
                        <Typography variant="body2" color={colors.grey[300]} mt="4px" mb="16px">
                            Prenez la décision administrative depuis cette carte, puis archivez l&apos;inscription si nécessaire.
                        </Typography>
                        <Box display="flex" gap="10px" flexWrap="wrap">
                            <Button
                                variant={child.approval === "approved" ? "contained" : "outlined"}
                                onClick={() => onApprove(child)}
                                disabled={decisionLoading || child.approval === "approved"}
                                sx={child.approval === "approved" ? styles.approveButton : { ...styles.mutedButton, color: isDark ? colors.greenAccent[300] : "#166534", borderColor: isDark ? colors.greenAccent[400] : "#16a34a" }}
                            >
                                {decisionLoading && child.approval !== "approved" ? "Traitement..." : "Approuver"}
                            </Button>
                            <Button
                                variant={child.approval === "pending" ? "contained" : "outlined"}
                                onClick={() => onResetPending(child)}
                                disabled={decisionLoading || child.approval === "pending"}
                                sx={child.approval === "pending" ? styles.neutralButton : styles.mutedButton}
                            >
                                En attente
                            </Button>
                            <Button
                                variant={child.approval === "rejected" ? "contained" : "outlined"}
                                onClick={() => onReject(child)}
                                disabled={decisionLoading || child.approval === "rejected"}
                                sx={child.approval === "rejected" ? { ...styles.neutralButton, backgroundColor: colors.redAccent[500], "&:hover": { backgroundColor: colors.redAccent[400] } } : { ...styles.mutedButton, color: colors.redAccent[400], borderColor: colors.redAccent[400] }}
                            >
                                Rejeter
                            </Button>
                            <Button variant="outlined" onClick={() => onArchiveToggle(child)} disabled={decisionLoading} sx={styles.mutedButton}>
                                {child.is_archived ? "Désarchiver" : "Archiver"}
                            </Button>
                        </Box>
                    </Box>

                    <Box display="grid" gridTemplateColumns={{ xs: "1fr", lg: "1fr 1fr" }} gap="18px">
                        <Box sx={styles.stackedCard}>
                            <Box display="flex" justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }} gap="12px" flexDirection={{ xs: "column", md: "row" }} mb="14px">
                                <Box>
                                    <Typography variant="h6" fontWeight="700">Dossier médical</Typography>
                                    <Typography variant="body2" color={colors.grey[300]} mt="4px">
                                        Fiche transmise lors de l&apos;inscription.
                                    </Typography>
                                </Box>
                            </Box>
                            <Box ref={medicalDocRef} sx={styles.medicalPreview} className="medical-print-root">
                                <MedicalFormDocument
                                    form={showTemplate ? undefined : form}
                                    childName={child.name}
                                    parentName={child.parent}
                                    isTemplate={showTemplate}
                                />
                            </Box>
                            <Box mt="14px" display="flex" justifyContent="flex-end">
                                <Button onClick={onPrint} sx={{ color: isDark ? colors.blueAccent[300] : "#334155", textTransform: "none", fontWeight: 700 }}>
                                    Imprimer le dossier médical
                                </Button>
                            </Box>
                        </Box>

                        <Box sx={styles.stackedCard}>
                            <Typography variant="h6" fontWeight="700">Résumé IA</Typography>
                            <Typography variant="body2" color={colors.grey[300]} mt="4px" mb="14px">
                                {isApproved
                                    ? "La fiche est maintenant éditable. Modifiez puis sauvegardez les commentaires si nécessaire."
                                    : "Approuvez l'inscription pour générer et modifier la fiche de l'élève."}
                            </Typography>

                            {!isApproved ? (
                                <Box sx={styles.lockedPanel}>
                                    <Typography color={colors.grey[300]} maxWidth="320px">
                                        Approuvez l&apos;inscription pour générer et modifier la fiche de l&apos;élève.
                                    </Typography>
                                </Box>
                            ) : (
                                <Box display="flex" flexDirection="column" gap="16px">
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
                                            disabled={!aiEditMode}
                                            InputLabelProps={{ shrink: true }}
                                            sx={styles.floatingField}
                                        />
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
                                            disabled={!aiEditMode}
                                            InputLabelProps={{ shrink: true }}
                                            sx={styles.floatingField}
                                        />
                                    </Box>
                                    {aiEditMode && (
                                        <MealExceptionReviewBox
                                            title="Scanner les repas"
                                            description="Relancez le scan après modification pour recalculer les repas à risque de cet enfant."
                                            exceptions={mealExceptions}
                                            loading={mealScanLoading}
                                            onScan={onScanMeals}
                                            onToggle={onMealToggle}
                                            colors={colors}
                                            styles={styles}
                                            isDark={isDark}
                                        />
                                    )}
                                    <Box display="flex" justifyContent="flex-end" gap="10px" flexWrap="wrap">
                                        {!aiEditMode ? (
                                            <Button variant="outlined" onClick={onEditToggle} sx={styles.mutedButton}>
                                                Modifier la fiche
                                            </Button>
                                        ) : (
                                            <>
                                                <Button variant="outlined" onClick={onEditToggle} disabled={saving} sx={styles.mutedButton}>
                                                    Annuler
                                                </Button>
                                                <Button variant="contained" onClick={onSave} disabled={saving || (!dirty && !mealReviewDirty)} sx={styles.neutralButton}>
                                                    {saving ? "Sauvegarde..." : "Sauvegarder la fiche"}
                                                </Button>
                                            </>
                                        )}
                                    </Box>
                                </Box>
                            )}
                        </Box>
                    </Box>
                </Box>
            </DialogContent>
            <DialogActions sx={styles.dialogActions}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Fermer</Button>
            </DialogActions>
        </Dialog>
    );
};

export default InscriptionDetailDialog;
