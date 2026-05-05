import { Box, Button, Typography, Dialog, DialogTitle, DialogContent, DialogActions, TextField, CircularProgress, Chip, Switch, FormControlLabel, IconButton } from "@mui/material";
import { DataGrid, GridToolbarContainer, GridToolbarFilterButton, frFR } from "@mui/x-data-grid";
import RestaurantMenuOutlinedIcon from "@mui/icons-material/RestaurantMenuOutlined";
import BakeryDiningOutlinedIcon from "@mui/icons-material/BakeryDiningOutlined";
import AddRoundedIcon from "@mui/icons-material/AddRounded";
import CloseIcon from "@mui/icons-material/Close";

const FR_LOCALE = frFR.components.MuiDataGrid.defaultProps.localeText;

export const AiDisabledBannerMeals = ({ colors }) => (
    <Box mb="15px" p="12px" borderRadius="8px" backgroundColor="rgba(239,68,68,0.1)" border="1px solid rgba(239,68,68,0.3)" display="flex" alignItems="center" gap="10px">
        <Typography fontSize="18px">⚠️</Typography>
        <Typography color={colors.redAccent[400]} fontSize="0.85rem">
            <strong>IA désactivée</strong> — La détection automatique des exceptions alimentaires est désactivée. Les aliments seront ajoutés sans vérification IA. Après réactivation, supprimez puis rajoutez un aliment pour relancer la détection.
        </Typography>
    </Box>
);

export const StatsCardsMeals = ({ lunchCount, snackCount, colors, styles }) => (
    <Box sx={styles.summaryGrid}>
        {[
            { label: "Déjeuners", value: lunchCount, accent: colors.greenAccent[500], icon: <RestaurantMenuOutlinedIcon fontSize="small" /> },
            { label: "Goûters", value: snackCount, accent: colors.blueAccent[400], icon: <BakeryDiningOutlinedIcon fontSize="small" /> },
        ].map((item) => (
            <Box key={item.label} sx={styles.summaryCard(item.accent)}>
                <Box>
                    <Typography sx={styles.summaryLabel}>{item.label}</Typography>
                    <Typography sx={styles.summaryValue}>{item.value}</Typography>
                </Box>
                <Box sx={styles.summaryIconWrap(item.accent)}>{item.icon}</Box>
            </Box>
        ))}
    </Box>
);

const FoodToolbar = ({ colors, isDark }) => (
    <GridToolbarContainer sx={{ px: "16px", py: "14px", borderBottom: `1px solid ${isDark ? "rgba(148, 163, 184, 0.16)" : "rgba(148, 163, 184, 0.28)"}`, backgroundColor: isDark ? "rgba(148, 163, 184, 0.08)" : "#eef2f7" }}>
        <GridToolbarFilterButton sx={{ borderRadius: "999px", px: "14px", py: "6px", textTransform: "none", fontWeight: 700 }} />
    </GridToolbarContainer>
);

export const DataGridSection = ({ loading, currentList, columns, styles, colors, isDark }) => (
    <Box sx={styles.sectionCard}>
        <Box sx={styles.sectionHeader}>
            <Box>
                <Typography sx={styles.sectionTitle}>Catalogue alimentaire</Typography>
                <Typography sx={styles.sectionSubtitle}>Retrouvez une liste plus compacte avec un en-tête adouci et des actions discrètes.</Typography>
            </Box>
        </Box>
        <Box height="60vh" sx={styles.dataGrid}>
            <DataGrid loading={loading} rows={currentList} columns={columns} components={{ Toolbar: FoodToolbar }} componentsProps={{ toolbar: { colors, isDark } }} pageSize={10} rowsPerPageOptions={[10, 50, 100]} disableSelectionOnClick rowHeight={74} localeText={FR_LOCALE} />
        </Box>
    </Box>
);

export const AddSection = ({ activeTab, styles, setAddError, setNewItem, setIsAddDialogOpen }) => (
    <Box sx={styles.sectionCard}>
        <Box sx={{ ...styles.sectionHeader, display: "flex", justifyContent: "space-between", alignItems: { xs: "flex-start", md: "center" }, gap: "14px", flexDirection: { xs: "column", md: "row" } }}>
            <Box>
                <Typography sx={styles.sectionTitle}>Ajouter un {activeTab === 0 ? "déjeuner" : "goûter"}</Typography>
                <Typography sx={styles.sectionSubtitle}>Ouvrez une fenêtre dédiée pour ajouter un aliment avec un flux plus propre, comme sur les classes.</Typography>
            </Box>
            <Button variant="contained" startIcon={<AddRoundedIcon fontSize="small" />} sx={styles.primaryButton} onClick={() => { setAddError(""); setNewItem(""); setIsAddDialogOpen(true); }}>
                Ajouter un {activeTab === 0 ? "déjeuner" : "goûter"}
            </Button>
        </Box>
    </Box>
);

export const AddItemDialog = ({ open, onClose, activeTab, aiEnabled, newItem, setNewItem, handleAddItem, addError, addSaving, checkingExceptions, colors, styles }) => (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={{ ...styles.dialogTitle, display: "flex", alignItems: "center", justifyContent: "space-between", gap: "12px" }}>
            <Box>
                <Typography fontWeight="bold" fontSize="1.08rem">Ajouter un {activeTab === 0 ? "déjeuner" : "goûter"}</Typography>
                <Typography variant="body2" color={colors.grey[300]} mt="4px">
                    Utilisez une fenêtre plus claire et plus structurée pour enrichir votre catalogue alimentaire.
                </Typography>
            </Box>
            <IconButton onClick={onClose} sx={{ color: colors.grey[100] }}><CloseIcon /></IconButton>
        </DialogTitle>
        <form onSubmit={(e) => { handleAddItem(e); }}>
            <DialogContent sx={{ mt: 2 }}>
                <Box sx={styles.formCard}>
                    {aiEnabled && (
                        <Box sx={styles.helperPanel} mb="20px">
                            <Typography color={colors.grey[100]} fontSize="0.85rem">
                                <strong>Astuce IA :</strong> Précisez les ingrédients clés entre parenthèses pour améliorer la détection des allergies. <br />
                                <span style={{ color: colors.blueAccent[300], fontStyle: "italic", marginTop: "4px", display: "inline-block" }}>Exemple : "Couscous au lait (amandes, sucre, lait)".</span>
                            </Typography>
                        </Box>
                    )}

                    {addError && <Typography color={colors.redAccent[500]} mb="15px" textAlign="center">{addError}</Typography>}

                    <TextField variant="outlined" label={`Nom du ${activeTab === 0 ? "déjeuner" : "goûter"}`} value={newItem} onChange={(e) => setNewItem(e.target.value)} fullWidth required autoFocus InputLabelProps={{ shrink: true }} sx={styles.filledInputSx} />

                    {checkingExceptions && (
                        <Box display="flex" alignItems="center" gap="10px" mt="16px" p="12px" borderRadius="14px" backgroundColor={styles.surfaceAlt} border={`1px solid ${styles.borderColor}`}>
                            <CircularProgress size={20} sx={{ color: colors.greenAccent[500] }} />
                            <Typography color={colors.grey[200]} fontSize="0.85rem">Vérification des exceptions alimentaires...</Typography>
                        </Box>
                    )}

                    {!aiEnabled && (
                        <Box mt="12px" p="8px 12px" borderRadius="6px" backgroundColor="rgba(245,158,11,0.08)" border="1px solid rgba(245,158,11,0.2)">
                            <Typography variant="caption" color="#f59e0b">
                                IA désactivée — cet aliment sera ajouté sans détection d'exceptions. Réactivez l'IA puis supprimez et rajoutez l'aliment si vous voulez relancer la détection.
                            </Typography>
                        </Box>
                    )}
                </Box>
            </DialogContent>
            <DialogActions sx={styles.dialogActions}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
                <Button type="submit" variant="contained" disabled={addSaving} sx={styles.primaryButton}>
                    {addSaving ? "Ajout..." : "Ajouter"}
                </Button>
            </DialogActions>
        </form>
    </Dialog>
);

export const DeleteDialog = ({ isDeleteDialogOpen, setIsDeleteDialogOpen, handleDeleteConfirm, deletingItem, colors, styles }) => (
    <Dialog open={isDeleteDialogOpen} onClose={() => setIsDeleteDialogOpen(false)} PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>Confirmer la suppression</DialogTitle>
        <DialogContent sx={{ mt: 2 }}><Typography color={colors.grey[200]}>Supprimer "{deletingItem?.name}" ?</Typography></DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={() => setIsDeleteDialogOpen(false)} sx={{ color: colors.grey[100] }}>Annuler</Button>
            <Button onClick={handleDeleteConfirm} variant="contained" sx={{ backgroundColor: colors.redAccent[500], color: "#fff" }}>Supprimer</Button>
        </DialogActions>
    </Dialog>
);

/* ═══════════════════════════════════════════════════════════
   ExceptionDialogItem – Individual child exception card
   in the AI exception review dialog
   ═══════════════════════════════════════════════════════════ */
export const ExceptionDialogItem = ({ exc, isIgnored, colors, styles, pendingMeal, ignoredExceptions, setIgnoredExceptions, editingCommentId, setEditingCommentId, overrideText, setOverrideText, handleOverrideComment }) => (
    <Box sx={styles.exceptionItemCard(isIgnored)}>
        <Box sx={styles.exceptionItemHeader}>
            <Box sx={styles.exceptionItemIdentity}>
                <Box sx={styles.exceptionAvatar(isIgnored)}>
                    {(exc.child_name || "?").charAt(0).toUpperCase()}
                </Box>
                <Box flex="1" minWidth={0}>
                    <Box display="flex" alignItems="center" gap="8px" flexWrap="wrap">
                        <Typography fontWeight={800} color={isIgnored ? colors.grey[400] : colors.grey[100]} fontSize="0.95rem" sx={{ textDecoration: isIgnored ? "line-through" : "none" }}>
                            {exc.child_name}
                        </Typography>
                        {exc.parent_phone ? <Chip label={`📞 ${exc.parent_phone}`} size="small" sx={styles.exceptionPhoneChip} /> : null}
                    </Box>
                    <Typography variant="caption" color={isIgnored ? colors.grey[500] : colors.grey[400]}>
                        Enfant concerné par l'analyse du repas
                    </Typography>
                </Box>
            </Box>

            {pendingMeal ? (
                <FormControlLabel
                    sx={{ m: 0, gap: "4px" }}
                    control={
                        <Switch
                            checked={!isIgnored}
                            onChange={(e) => {
                                if (!e.target.checked) setIgnoredExceptions(prev => [...prev, exc.child_id]);
                                else setIgnoredExceptions(prev => prev.filter(id => id !== exc.child_id));
                            }}
                            color="error"
                            size="small"
                        />
                    }
                    label={<Chip label={isIgnored ? "Ignoré" : "Valide"} size="small" sx={styles.exceptionStateChip(isIgnored)} />}
                    labelPlacement="start"
                />
            ) : !isIgnored ? <Chip label="Conflit actif" size="small" sx={styles.exceptionConflictChip} /> : null}
        </Box>

        <Box sx={styles.exceptionReasonCard(isIgnored)}>
            <Typography variant="caption" color={isIgnored ? colors.grey[500] : colors.grey[400]} sx={{ display: "block", mb: "4px", textTransform: "uppercase", letterSpacing: "0.04em" }}>
                Raison détectée
            </Typography>
            <Typography color={isIgnored ? colors.grey[400] : colors.grey[100]} fontSize="0.9rem" sx={{ textDecoration: isIgnored ? "line-through" : "none" }}>
                {exc.reason}
            </Typography>
        </Box>

        {isIgnored && pendingMeal && (
            <Box sx={styles.exceptionOverridePanel}>
                <Typography variant="caption" color={colors.grey[300]} display="block" mb="8px" fontWeight={700}>
                    Corriger le profil de l'enfant pour les prochaines fois
                </Typography>

                {editingCommentId !== exc.child_id ? (
                    <Box display="flex" gap="8px" flexWrap="wrap">
                        <Button size="small" variant="outlined" color="primary" onClick={() => { setEditingCommentId(exc.child_id); setOverrideText(exc.reason); }} sx={styles.exceptionActionButton}>
                            Saisie manuelle
                        </Button>
                    </Box>
                ) : (
                    <Box display="flex" flexDirection="column" gap="8px">
                        <TextField
                            size="small" fullWidth multiline rows={2}
                            value={overrideText} onChange={(e) => setOverrideText(e.target.value)}
                            placeholder="Tapez la restriction ici"
                            sx={styles.exceptionOverrideInput}
                        />
                        <Box display="flex" gap="8px" justifyContent="flex-end" flexWrap="wrap">
                            <Button size="small" onClick={() => setEditingCommentId(null)} sx={styles.exceptionInlineTextButton}>Annuler</Button>
                            <Button size="small" variant="contained" color="success" onClick={() => handleOverrideComment(exc.child_id, overrideText)} disabled={!overrideText.trim()} sx={styles.exceptionSaveButton}>
                                Enregistrer
                            </Button>
                        </Box>
                    </Box>
                )}
            </Box>
        )}
    </Box>
);

/* ═══════════════════════════════════════════════════════════
   ExceptionDialog – AI exception review dialog (confirm/cancel)
   ═══════════════════════════════════════════════════════════ */
export const ExceptionDialog = ({
    exceptionResults, handleCancelPending, pendingMeal,
    ignoredExceptions, setIgnoredExceptions,
    editingCommentId, setEditingCommentId,
    overrideText, setOverrideText, handleOverrideComment,
    handleConfirmSave, confirmSaving, colors, styles
}) => {
    const exceptionCount = exceptionResults?.exceptions?.length || 0;

    return (
    <Dialog open={!!exceptionResults} onClose={handleCancelPending} fullWidth maxWidth="sm"
        PaperProps={{ sx: styles.exceptionDialogPaper }}>
        <DialogTitle sx={styles.exceptionDialogTitle}>
            <Box>
                <Typography fontSize="1.05rem" fontWeight={800} color={colors.grey[100]}>
                    {exceptionCount > 0 ? 'Exceptions alimentaires détectées' : 'Analyse alimentaire terminée'}
                </Typography>
                <Typography color={colors.grey[400]} fontSize="0.84rem" mt="2px">
                    Résultat du contrôle IA avant l'enregistrement du repas
                </Typography>
            </Box>
            <Chip
                label={exceptionCount > 0 ? `${exceptionCount} conflit${exceptionCount > 1 ? 's' : ''}` : 'Aucun conflit'}
                size="small"
                sx={exceptionCount > 0 ? styles.exceptionCountChip : styles.exceptionSuccessChip}
            />
        </DialogTitle>
        <DialogContent sx={{ mt: 2 }}>
            {exceptionCount > 0 ? (
                <>
                    <Box sx={styles.exceptionSummaryPanel("danger")}>
                        <Typography color={colors.grey[100]} mb="6px" fontWeight={700}>
                            Le repas <strong>"{exceptionResults?.mealName}"</strong> pose problème pour <strong>{exceptionCount}</strong> enfant(s).
                        </Typography>
                        <Typography color={colors.grey[300]} fontSize="0.9rem">
                            Vérifiez les profils détectés ci-dessous puis confirmez uniquement les conflits à conserver.
                        </Typography>
                    </Box>
                    <Box display="flex" flexDirection="column" gap="12px">
                        {(exceptionResults?.exceptions || []).map((exc, idx) => {
                            const isIgnored = ignoredExceptions.includes(exc.child_id);
                            return (
                                <ExceptionDialogItem
                                    key={idx}
                                    exc={exc}
                                    isIgnored={isIgnored}
                                    colors={colors}
                                    styles={styles}
                                    pendingMeal={pendingMeal}
                                    ignoredExceptions={ignoredExceptions}
                                    setIgnoredExceptions={setIgnoredExceptions}
                                    editingCommentId={editingCommentId}
                                    setEditingCommentId={setEditingCommentId}
                                    overrideText={overrideText}
                                    setOverrideText={setOverrideText}
                                    handleOverrideComment={handleOverrideComment}
                                />
                            );
                        })}
                    </Box>
                </>
            ) : (
                <Box sx={styles.exceptionSummaryPanel("success")}>
                    <Typography color={colors.grey[100]} mb="8px">
                        L'IA a vérifié le repas <strong>"{exceptionResults?.mealName}"</strong> et n'a détecté aucun conflit alimentaire actif.
                    </Typography>
                    <Typography color={colors.grey[300]} fontSize="0.9rem">
                        Confirmez pour enregistrer ce repas dans le catalogue.
                    </Typography>
                </Box>
            )}
            {pendingMeal && (
                <Box sx={styles.exceptionFooterNotice("warning")}>
                    <Typography color={styles.warningText} fontSize="0.85rem" fontWeight="bold">
                         Le repas n'a pas encore été sauvegardé. Veuillez confirmer pour enregistrer le repas avec ses exceptions.
                    </Typography>
                </Box>
            )}
            {!pendingMeal && (
                <Box sx={styles.exceptionFooterNotice("success")}>
                    <Typography color={colors.greenAccent[400]} fontSize="0.85rem" fontWeight="bold">
                         Ces exceptions ont été enregistrées dans la base de données.
                    </Typography>
                </Box>
            )}
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={handleCancelPending} sx={{ color: colors.grey[100] }}>
                {pendingMeal ? 'Annuler' : 'Fermer'}
            </Button>
            {pendingMeal && (
                <Button onClick={handleConfirmSave} variant="contained" disabled={confirmSaving}
                    sx={styles.primaryButton}>
                    {confirmSaving ? '...' : '✓ Confirmer & Sauvegarder'}
                </Button>
            )}
        </DialogActions>
    </Dialog>
    );
};
