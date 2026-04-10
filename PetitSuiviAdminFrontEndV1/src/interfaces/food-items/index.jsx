/**
 * @file food-items/index.jsx
 * @description Food Items Management Interface.
 *
 * PURPOSE:
 * Manages the master catalogue of food items used in weekly meal planning.
 * Items are split into two categories: Lunch and Snack. When AI is enabled,
 * adding an item cross-references it against known food
 * exceptions so kitchen staff can be alerted to allergen conflicts immediately.
 *
 * API ENDPOINTS:
 * - GET /admin/parameters : Checks if AI features (ai_enabled) are turned on.
 * - GET /admin/meals : Fetches all configured food items with their categories.
 * - GET /admin/food-exceptions : Fetches children's food exceptions mapped to meal IDs.
 * - POST /admin/meals : 
 *     Payload: { name: string, category: 'lunch'|'snack', exceptions?: array }
 *     Creates a new food item and maps optional confirmed exceptions.
 * - POST /admin/meals/check-exceptions : 
 *     Payload: { meal_name: string, ingredients: [] }
 *     Requests AI to scan a given meal against known child dietary restrictions.
 * - POST /admin/meals/save-exceptions :
 *     Payload: { meal_name: string, exceptions: array }
 *     Saves the manually scanned/confirmed AI exceptions for an existing meal.
 * - PATCH /admin/inscriptions/:childId/dietary-comment :
 *     Payload: { dietary_comment: string }
 *     Overrides a child's global dietary comment to fix false positive AI detections.
 * - DELETE /admin/meals/:id :
 *     Deletes a meal from the system.
 *
 * KEY STATE:
 * - `lunchOptions` / `snackOptions` – Separate item arrays for each meal category.
 * - `newItem`       – Controlled input value for the "add item" text field.
 * - `activeTab`     – Which category tab is active: 0 = Lunch, 1 = Snack.
 * - `aiEnabled`     – Whether AI exception-detection is on (read from parameters).
 * - `loading`       – Loading state for datagrid.
 * - `aiState` / etc — Various dialog & confirmation flows.
 *
 * DEPENDENCIES:
 * - Axios (`api`) → Laravel REST API → MySQL database.
 * - MUI components – Tabs, DataGrid, Dialog, Chip, CircularProgress, etc.
 */
import { Box, Button, Typography, Dialog, DialogTitle, DialogContent, DialogActions, TextField, Tab, Tabs, CircularProgress, Chip, Switch, FormControlLabel, IconButton, Tooltip } from "@mui/material";
import { DataGrid, GridToolbarContainer, GridToolbarFilterButton } from "@mui/x-data-grid";
import { tokens } from "../../theme";
import Header from "../../components/Header";
import { useTheme } from "@mui/material";
import { useEffect, useState, useCallback } from "react";
import api from "../../api/axios";
import { getAdminPrimaryButtonSx } from "../../utils/adminActionButtons";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import RestaurantMenuOutlinedIcon from "@mui/icons-material/RestaurantMenuOutlined";
import BakeryDiningOutlinedIcon from "@mui/icons-material/BakeryDiningOutlined";
import AddRoundedIcon from "@mui/icons-material/AddRounded";
import CloseIcon from "@mui/icons-material/Close";

/**
 * FoodItems Component
 * 
 * Manages the master food items catalog, including category separation (Lunch/Snack)
 * and AI-driven allergen/exception detection during item creation.
 * 
 * @component
 * @returns {JSX.Element} The rendered Food Items management board.
 */
const FoodItems = () => {
    // ----------------------------------------------------
    // 1. ALL HOOKS AT THE TOP
    // ----------------------------------------------------
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const isDark = theme.palette.mode === "dark";
    const styles = getStyles(colors, isDark);

    const [loading, setLoading] = useState(true);

    // List State
    const [lunchOptions, setLunchOptions] = useState([]); 
    const [snackOptions, setSnackOptions] = useState([]); 
    const [activeTab, setActiveTab] = useState(0); 

    // Create new meal state
    const [newItem, setNewItem] = useState(""); 
    const [addSaving, setAddSaving] = useState(false); 
    const [addError, setAddError] = useState(""); 
    const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);

    // Global AI Feature config
    const [aiEnabled, setAiEnabled] = useState(true);

    // Scanned state tracking
    // eslint-disable-next-line no-unused-vars
    const [scannedMealIds, setScannedMealIds] = useState(new Set()); 

    // Deletion Modal State
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
    const [deletingItem, setDeletingItem] = useState(null);

    // Exception detection flow state (during meal add)
    const [checkingExceptions, setCheckingExceptions] = useState(false); 
    const [exceptionResults, setExceptionResults] = useState(null); 
    const [ignoredExceptions, setIgnoredExceptions] = useState([]); 

    // Pending creation state flow
    const [pendingMeal, setPendingMeal] = useState(null); 
    const [confirmSaving, setConfirmSaving] = useState(false); 
    
    // Manual exception override state
    const [editingCommentId, setEditingCommentId] = useState(null); 
    const [overrideText, setOverrideText] = useState(""); 

    // ----------------------------------------------------
    // 2. DATA FETCHING METHODS
    // ----------------------------------------------------
    const fetchAiEnabled = useCallback(async () => {
        try {
            const res = await api.get("/admin/parameters");
            const data = res.data?.data || res.data || [];
            const arr = Array.isArray(data) ? data : [];
            const aiParam = arr.find(p => p.name === 'ai_enabled');
            if (aiParam) {
                const enabled = aiParam.value === 'true' || aiParam.value === '1';
                setAiEnabled(enabled);
                return enabled;
            }
        } catch (err) { console.error('Failed to fetch AI status:', err); }
        // TODO: Remove aiEnabled from deps - return false/undefined on error instead of stale state
        return aiEnabled;
    }, [aiEnabled]);

    const fetchMeals = useCallback(async () => {
        try {
            setLoading(true);
            const response = await api.get("/admin/meals");
            const rows = Array.isArray(response.data?.data) ? response.data.data : [];
            setLunchOptions(rows
                .filter(m => (m?.category?.name || '').toLowerCase() === 'lunch')
                .map(m => ({ id: m.id, name: m.name || '', type: 'lunch' }))
            );
            setSnackOptions(rows
                .filter(m => {
                    const cat = (m?.category?.name || '').toLowerCase();
                    return cat === 'snack' || cat === 'snacks';
                })
                .map(m => ({ id: m.id, name: m.name || '', type: 'snack' }))
            );

            try {
                const excRes = await api.get('/admin/food-exceptions');
                const excData = excRes.data?.data || [];
                const scannedIds = new Set();
                excData.forEach(child => {
                    (child.exceptions || []).forEach(exc => {
                        if (exc.meal_id) scannedIds.add(exc.meal_id);
                    });
                });
                setScannedMealIds(scannedIds);
            } catch { /* ignore */ }
        } catch (error) { console.error("Failed to fetch meals", error); } finally { setLoading(false); }
    }, []);

    useEffect(() => { 
        fetchMeals(); 
        fetchAiEnabled(); 
    }, [fetchMeals, fetchAiEnabled]);

    // ----------------------------------------------------
    // 3. ACTION HANDLERS
    // ----------------------------------------------------
    const currentList = activeTab === 0 ? lunchOptions : snackOptions;

    const handleAddItem = async (e) => {
        e.preventDefault();
        const mealName = newItem.trim();
        if (!mealName) return;

        // VERIFY UNIQUENESS BEFORE COSTLY AI SCAN
        const existingMeal = [...lunchOptions, ...snackOptions].find(m => m.name.toLowerCase() === mealName.toLowerCase());
        if (existingMeal) {
            setAddError(`L'aliment "${mealName}" existe déjà !`);
            return;
        }

        const category = activeTab === 0 ? 'lunch' : 'snack';
        setAddError(""); setAddSaving(true);
        try {
            const latestAiEnabled = await fetchAiEnabled();
            if (latestAiEnabled) {
                setCheckingExceptions(true);
                try {
                    const checkRes = await api.post('/admin/meals/check-exceptions', {
                        meal_name: mealName,
                        ingredients: [],
                    });
                    if (checkRes.data?.success !== true) {
                        setAddError((checkRes.data?.message || "La vérification IA a échoué.") + " Désactivez l'IA dans Paramètres pour continuer sans vérification.");
                        return;
                    }
                    const exceptions = checkRes.data?.exceptions || [];
                    setPendingMeal({ name: mealName, category });
                    setExceptionResults({ mealName, exceptions, aiChecked: true });
                    setNewItem("");
                    setIsAddDialogOpen(false);
                } catch (checkErr) {
                    console.error('Exception check failed:', checkErr);
                    setAddError((checkErr?.response?.data?.message || "La vérification IA a échoué.") + " Désactivez l'IA dans Paramètres pour continuer sans vérification.");
                    return;
                } finally { setCheckingExceptions(false); }
            } else {
                await api.post("/admin/meals", { name: mealName, category });
                setNewItem(""); setIsAddDialogOpen(false); fetchMeals();
            }
        } catch (err) {
            setAddError(err?.response?.data?.message || "Erreur.");
        } finally { setAddSaving(false); }
    };

    const handleConfirmSave = async () => {
        if (!pendingMeal || !exceptionResults) return;
        setConfirmSaving(true);
        try {
            const validExceptions = (exceptionResults.exceptions || [])
                .filter(exc => !ignoredExceptions.includes(exc.child_id))
                .map(exc => ({
                    child_id: exc.child_id,
                    reason: exc.reason,
                }));

            await api.post("/admin/meals", {
                name: pendingMeal.name,
                category: pendingMeal.category,
                exceptions: validExceptions,
            });
            fetchMeals();
        } catch (err) {
            alert(err?.response?.data?.message || "Erreur lors de la sauvegarde.");
        } finally {
            setConfirmSaving(false);
            setPendingMeal(null);
            setExceptionResults(null);
            setIgnoredExceptions([]);
        }
    };

    const handleCancelPending = () => {
        setPendingMeal(null);
        setExceptionResults(null);
        setIgnoredExceptions([]);
        setEditingCommentId(null);
        setOverrideText("");
    };

    const handleOverrideComment = async (childId, newComment) => {
        try {
            await api.put(`/admin/inscriptions/${childId}/ai-comments`, {
                dietary_comment: newComment
            });
            alert('Profil de l\'enfant mis à jour avec succès.');
            setEditingCommentId(null);
            setOverrideText("");
        } catch (err) {
            alert('Erreur: ' + (err?.response?.data?.message || err.message));
        }
    };

    const handleDeleteClick = (item) => {
        setDeletingItem(item); setIsDeleteDialogOpen(true);
    };

    const handleDeleteConfirm = async () => {
        if (!deletingItem) return;
        try {
            await api.delete(`/admin/meals/${deletingItem.id}`);
            fetchMeals();
            setIsDeleteDialogOpen(false); setDeletingItem(null);
        } catch (err) { alert(err?.response?.data?.message || "Erreur."); }
    };

    // ----------------------------------------------------
    // 4. DATAGRID COLUMNS
    // ----------------------------------------------------
    const columns = [
        { field: "id", headerName: "ID", flex: 0.25, minWidth: 64, align: "center", headerAlign: "center" },
        {
            field: "name",
            headerName: "Nom",
            flex: 1,
            cellClassName: "name-column--cell",
            renderCell: ({ value }) => (
                <Box display="flex" alignItems="center" height="100%" py="8px">
                    <Typography fontWeight={700} color={colors.grey[100]}>{value}</Typography>
                </Box>
            ),
        },
        {
            field: "actions", headerName: "Actions", flex: 0.28, minWidth: 96, align: "center", headerAlign: "center", sortable: false, filterable: false,
            renderCell: ({ row }) => (
                <Tooltip title="Supprimer">
                    <IconButton sx={styles.dangerIconButton} size="small" onClick={() => handleDeleteClick(row)}>
                        <DeleteOutlineIcon fontSize="small" />
                    </IconButton>
                </Tooltip>
            ),
        },
    ];

    // ----------------------------------------------------
    // 5. RENDER
    // ----------------------------------------------------
    return (
        <Box m="20px">
            <Header title="GÉRER LES ALIMENTS" />

            {!aiEnabled && <AiDisabledBanner colors={colors} />}

            <StatsCards 
                lunchCount={lunchOptions.length} 
                snackCount={snackOptions.length} 
                colors={colors}
                styles={styles}
            />

            <Box sx={styles.tabsWrap}>
                <Tabs value={activeTab} onChange={(_, v) => setActiveTab(v)} sx={styles.tabs}>
                    <Tab label=" Déjeuner" />
                    <Tab label=" Goûter" />
                </Tabs>
            </Box>

            <AddSection 
                activeTab={activeTab} 
                styles={styles}
                setAddError={setAddError}
                setNewItem={setNewItem}
                setIsAddDialogOpen={setIsAddDialogOpen}
            />

            <DataGridSection loading={loading} currentList={currentList} columns={columns} styles={styles} colors={colors} isDark={isDark} />

            <AddItemDialog
                open={isAddDialogOpen}
                onClose={() => {
                    setIsAddDialogOpen(false);
                    setAddError("");
                    setNewItem("");
                }}
                activeTab={activeTab}
                aiEnabled={aiEnabled}
                newItem={newItem}
                setNewItem={setNewItem}
                handleAddItem={handleAddItem}
                addError={addError}
                addSaving={addSaving}
                checkingExceptions={checkingExceptions}
                colors={colors}
                styles={styles}
            />

            <DeleteDialog 
                isDeleteDialogOpen={isDeleteDialogOpen} 
                setIsDeleteDialogOpen={setIsDeleteDialogOpen} 
                handleDeleteConfirm={handleDeleteConfirm}
                deletingItem={deletingItem} 
                colors={colors}
                styles={styles}
            />

            <ExceptionDialog 
                exceptionResults={exceptionResults}
                handleCancelPending={handleCancelPending}
                pendingMeal={pendingMeal}
                ignoredExceptions={ignoredExceptions}
                setIgnoredExceptions={setIgnoredExceptions}
                editingCommentId={editingCommentId}
                setEditingCommentId={setEditingCommentId}
                overrideText={overrideText}
                setOverrideText={setOverrideText}
                handleOverrideComment={handleOverrideComment}
                handleConfirmSave={handleConfirmSave}
                confirmSaving={confirmSaving}
                colors={colors}
                styles={styles}
            />

        </Box>
    );
};

// --------------------------------------------------------
// PURE FUNCTIONAL SUB-COMPONENTS
// --------------------------------------------------------

const AiDisabledBanner = ({ colors }) => (
    <Box mb="15px" p="12px" borderRadius="8px" backgroundColor="rgba(239,68,68,0.1)" border="1px solid rgba(239,68,68,0.3)" display="flex" alignItems="center" gap="10px">
        <Typography fontSize="18px">⚠️</Typography>
        <Typography color={colors.redAccent[400]} fontSize="0.85rem">
            <strong>IA désactivée</strong> — La détection automatique des exceptions alimentaires est désactivée. Les aliments seront ajoutés sans vérification IA. Après réactivation, supprimez puis rajoutez un aliment pour relancer la détection.
        </Typography>
    </Box>
);

const StatsCards = ({ lunchCount, snackCount, colors, styles }) => (
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

const DataGridSection = ({ loading, currentList, columns, styles, colors, isDark }) => (
    <Box sx={styles.sectionCard}>
        <Box sx={styles.sectionHeader}>
            <Box>
                <Typography sx={styles.sectionTitle}>Catalogue alimentaire</Typography>
                <Typography sx={styles.sectionSubtitle}>Retrouvez une liste plus compacte avec un en-tête adouci et des actions discrètes.</Typography>
            </Box>
        </Box>
        <Box height="60vh" sx={styles.dataGrid}>
            <DataGrid loading={loading} rows={currentList} columns={columns} components={{ Toolbar: FoodToolbar }} componentsProps={{ toolbar: { colors, isDark } }} pageSize={10} rowsPerPageOptions={[10, 50, 100]} disableSelectionOnClick rowHeight={74} />
        </Box>
    </Box>
);

const AddSection = ({ activeTab, styles, setAddError, setNewItem, setIsAddDialogOpen }) => (
    <Box sx={styles.sectionCard}>
        <Box sx={{ ...styles.sectionHeader, display: "flex", justifyContent: "space-between", alignItems: { xs: "flex-start", md: "center" }, gap: "14px", flexDirection: { xs: "column", md: "row" } }}>
            <Box>
                <Typography sx={styles.sectionTitle}>Ajouter un {activeTab === 0 ? "déjeuner" : "goûter"}</Typography>
                <Typography sx={styles.sectionSubtitle}>Ouvrez une fenêtre dédiée pour ajouter un aliment avec un flux plus propre, comme sur les classes.</Typography>
            </Box>
            <Button
                variant="contained"
                startIcon={<AddRoundedIcon fontSize="small" />}
                sx={styles.primaryButton}
                onClick={() => {
                    setAddError("");
                    setNewItem("");
                    setIsAddDialogOpen(true);
                }}
            >
                Ajouter un {activeTab === 0 ? "déjeuner" : "goûter"}
            </Button>
        </Box>
    </Box>
);

const AddItemDialog = ({ open, onClose, activeTab, aiEnabled, newItem, setNewItem, handleAddItem, addError, addSaving, checkingExceptions, colors, styles }) => (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={{ ...styles.dialogTitle, display: "flex", alignItems: "center", justifyContent: "space-between", gap: "12px" }}>
            <Box>
                <Typography fontWeight="bold" fontSize="1.08rem">Ajouter un {activeTab === 0 ? "déjeuner" : "goûter"}</Typography>
                <Typography variant="body2" color={colors.grey[300]} mt="4px">
                    Utilisez une fenêtre plus claire et plus structurée pour enrichir votre catalogue alimentaire.
                </Typography>
            </Box>
            <IconButton onClick={onClose} sx={{ color: colors.grey[100] }}>
                <CloseIcon />
            </IconButton>
        </DialogTitle>
        <form onSubmit={(e) => {
            handleAddItem(e);
        }}>
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

                    <TextField
                        variant="outlined"
                        label={`Nom du ${activeTab === 0 ? "déjeuner" : "goûter"}`}
                        value={newItem}
                        onChange={(e) => setNewItem(e.target.value)}
                        fullWidth
                        required
                        autoFocus
                        InputLabelProps={{ shrink: true }}
                        sx={styles.filledInputSx}
                    />

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

const DeleteDialog = ({ isDeleteDialogOpen, setIsDeleteDialogOpen, handleDeleteConfirm, deletingItem, colors, styles }) => (
    <Dialog open={isDeleteDialogOpen} onClose={() => setIsDeleteDialogOpen(false)}
        PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>Confirmer la suppression</DialogTitle>
        <DialogContent sx={{ mt: 2 }}>
            <Typography color={colors.grey[200]}>Supprimer "{deletingItem?.name}" ?</Typography>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={() => setIsDeleteDialogOpen(false)} sx={{ color: colors.grey[100] }}>Annuler</Button>
            <Button onClick={handleDeleteConfirm} variant="contained" sx={{ backgroundColor: colors.redAccent[500], color: "#fff" }}>Supprimer</Button>
        </DialogActions>
    </Dialog>
);

const ExceptionDialogItem = ({ exc, isIgnored, colors, styles, pendingMeal, ignoredExceptions, setIgnoredExceptions, editingCommentId, setEditingCommentId, overrideText, setOverrideText, handleOverrideComment }) => (
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
                        <Button size="small" variant="outlined" color="success" onClick={() => handleOverrideComment(exc.child_id, "✅ Aucune restriction alimentaire détectée.")} sx={styles.exceptionActionButton}>
                            Marquer "Aucun problème"
                        </Button>
                        <Button size="small" variant="outlined" color="primary" onClick={() => { setEditingCommentId(exc.child_id); setOverrideText(exc.reason); }} sx={styles.exceptionActionButton}>
                            Saisie manuelle
                        </Button>
                    </Box>
                ) : (
                    <Box display="flex" flexDirection="column" gap="8px">
                        <TextField
                            size="small"
                            fullWidth
                            multiline
                            rows={2}
                            value={overrideText}
                            onChange={(e) => setOverrideText(e.target.value)}
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

const ExceptionDialog = ({ 
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

// --------------------------------------------------------
// CENTRALIZED STYLES
// --------------------------------------------------------

/**
 * Extracted centralized styles hook.
 */
function getStyles(colors, isDark) {
    const surface = isDark ? "rgba(15, 23, 32, 0.88)" : "rgba(255, 255, 255, 0.82)";
    const surfaceAlt = isDark ? "rgba(19, 28, 39, 0.92)" : "#f8fafc";
    const borderColor = isDark ? "rgba(148, 163, 184, 0.16)" : "rgba(148, 163, 184, 0.28)";
    return {
        surfaceAlt,
        borderColor,
        summaryGrid: { display: "grid", gridTemplateColumns: { xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }, gap: "14px", mb: "18px" },
        summaryCard: (accent) => ({ display: "flex", alignItems: "center", justifyContent: "space-between", gap: "14px", px: "18px", py: "16px", borderRadius: "18px", background: surface, border: `1px solid ${borderColor}`, boxShadow: isDark ? "0 18px 34px rgba(2, 6, 23, 0.26)" : "0 16px 32px rgba(148, 163, 184, 0.16)", borderLeft: `4px solid ${accent}` }),
        summaryLabel: { fontSize: "0.78rem", letterSpacing: "0.04em", textTransform: "uppercase", color: colors.grey[400], mb: "4px" },
        summaryValue: { fontSize: "1.45rem", lineHeight: 1, fontWeight: 800, color: colors.grey[100] },
        summaryIconWrap: (accent) => ({ width: 42, height: 42, borderRadius: "14px", display: "flex", alignItems: "center", justifyContent: "center", backgroundColor: `${accent}12`, border: `1px solid ${accent}28`, color: accent, flexShrink: 0 }),
        tabsWrap: { borderBottom: `1px solid ${borderColor}`, mb: "20px", px: { xs: 0, md: 1 } },
        tabs: {
            minHeight: 46,
            "& .MuiTab-root": { color: colors.grey[300], textTransform: "none", fontSize: "0.95rem", fontWeight: 600, opacity: 1, minHeight: 46, px: 0, mr: 3 },
            "& .MuiTab-root.Mui-selected": { color: `${colors.greenAccent[500]} !important`, fontWeight: 800 },
            "& .MuiTabs-indicator": { backgroundColor: colors.greenAccent[500], height: "4px", borderRadius: "999px" }
        },
        sectionCard: { borderRadius: "22px", background: surface, border: `1px solid ${borderColor}`, boxShadow: isDark ? "0 18px 34px rgba(2, 6, 23, 0.28)" : "0 16px 32px rgba(148, 163, 184, 0.16)", overflow: "hidden", mb: "20px" },
        sectionHeader: { px: { xs: "16px", md: "22px" }, py: { xs: "16px", md: "18px" }, borderBottom: `1px solid ${borderColor}` },
        sectionTitle: { fontSize: "1.02rem", fontWeight: 800, color: colors.grey[100] },
        sectionSubtitle: { mt: "4px", fontSize: "0.84rem", color: colors.grey[400], lineHeight: 1.6 },
        dataGrid: {
            "& .MuiDataGrid-root": { border: "none", backgroundColor: "transparent" }, 
            "& .MuiDataGrid-cell": { borderBottom: `1px solid ${borderColor}`, color: colors.grey[100], py: "14px", alignItems: "center" },
            "& .name-column--cell": { color: colors.grey[100] },
            "& .MuiDataGrid-columnHeaders": { backgroundColor: isDark ? "rgba(148, 163, 184, 0.08)" : "#eef2f7", borderBottom: `1px solid ${borderColor}` },
            "& .MuiDataGrid-columnHeader": { color: colors.grey[300], fontSize: "0.78rem", fontWeight: 800, textTransform: "uppercase", letterSpacing: "0.05em" },
            "& .MuiDataGrid-virtualScroller": { backgroundColor: surface },
            "& .MuiDataGrid-row:hover": { backgroundColor: `${isDark ? "rgba(30, 41, 59, 0.58)" : "rgba(241, 245, 249, 0.92)"} !important` },
            "& .MuiDataGrid-footerContainer": { borderTop: `1px solid ${borderColor}`, backgroundColor: surfaceAlt },
            "& .MuiDataGrid-toolbarContainer .MuiButton-text": { color: `${colors.grey[100]} !important` },
        },
        dangerIconButton: { width: 32, height: 32, borderRadius: "10px", border: `1px solid ${isDark ? "rgba(248, 113, 113, 0.16)" : "rgba(248, 113, 113, 0.18)"}`, backgroundColor: isDark ? "rgba(127, 29, 29, 0.14)" : "rgba(254, 226, 226, 0.72)", color: colors.redAccent[400], "&:hover": { backgroundColor: isDark ? "rgba(127, 29, 29, 0.22)" : "rgba(254, 226, 226, 0.92)" } },
        formCard: { background: surface, borderRadius: "22px", border: `1px solid ${borderColor}`, boxShadow: isDark ? "0 18px 34px rgba(2, 6, 23, 0.28)" : "0 16px 32px rgba(148, 163, 184, 0.16)", p: { xs: "18px", md: "22px" }, mt: "20px" },
        formHeaderRow: { display: "flex", alignItems: "center", gap: "12px", mb: "18px" },
        helperPanel: { p: "12px 14px", borderRadius: "14px", backgroundColor: surfaceAlt, border: `1px solid ${borderColor}` },
        filledInputSx: { "& .MuiOutlinedInput-root": { borderRadius: "14px", backgroundColor: surfaceAlt }, "& .MuiInputLabel-root": { color: colors.grey[400], fontWeight: 600, px: "6px", backgroundColor: surfaceAlt, borderRadius: "999px" }, "& .MuiInputLabel-root.Mui-focused": { color: isDark ? "#94a3b8" : "#475569", backgroundColor: surfaceAlt }, "& .MuiInputLabel-root.MuiInputLabel-shrink": { color: isDark ? colors.grey[300] : "#475569", backgroundColor: surfaceAlt }, "& .MuiInputBase-input": { color: isDark ? colors.grey[100] : "#0f172a" } },
        primaryButton: { ...getAdminPrimaryButtonSx({ whiteSpace: "nowrap", px: "18px" }) },
        dialogPaper: { backgroundColor: colors.primary[400], color: colors.grey[100], borderRadius: "16px", boxShadow: "0px 8px 30px rgba(0,0,0,0.5)", overflow: "hidden" },
        dialogTitle: { fontWeight: "bold", fontSize: "1.1rem", borderBottom: `1px solid ${colors.primary[500]}` },
        dialogActions: { p: 2, borderTop: `1px solid ${colors.primary[500]}` },
        warningText: isDark ? "#fbbf24" : "#b45309",
        exceptionDialogPaper: { background: surface, color: colors.grey[100], borderRadius: "18px", border: `1px solid ${borderColor}`, boxShadow: isDark ? "0 24px 44px rgba(2, 6, 23, 0.34)" : "0 22px 38px rgba(148, 163, 184, 0.22)", overflow: "hidden", backdropFilter: "blur(10px)" },
        exceptionDialogTitle: { display: "flex", alignItems: "flex-start", justifyContent: "space-between", gap: "14px", borderBottom: `1px solid ${borderColor}`, px: { xs: 2, sm: 3 }, py: 2.25 },
        exceptionCountChip: { backgroundColor: isDark ? "rgba(239, 68, 68, 0.14)" : "rgba(254, 226, 226, 0.92)", color: colors.redAccent[400], border: `1px solid ${isDark ? "rgba(248, 113, 113, 0.2)" : "rgba(248, 113, 113, 0.24)"}`, fontWeight: 700 },
        exceptionSuccessChip: { backgroundColor: isDark ? "rgba(16, 185, 129, 0.14)" : "rgba(220, 252, 231, 0.92)", color: colors.greenAccent[400], border: `1px solid ${isDark ? "rgba(52, 211, 153, 0.2)" : "rgba(16, 185, 129, 0.24)"}`, fontWeight: 700 },
        exceptionSummaryPanel: (tone) => ({ mb: "16px", p: "16px", borderRadius: "16px", border: `1px solid ${tone === "danger"
            ? isDark ? "rgba(248, 113, 113, 0.2)" : "rgba(248, 113, 113, 0.24)"
            : isDark ? "rgba(52, 211, 153, 0.2)" : "rgba(16, 185, 129, 0.24)"}`,
            backgroundColor: tone === "danger"
                ? isDark ? "rgba(127, 29, 29, 0.14)" : "rgba(254, 242, 242, 0.96)"
                : isDark ? "rgba(6, 95, 70, 0.14)" : "rgba(240, 253, 244, 0.96)"
        }),
        exceptionItemCard: (isIgnored) => ({ p: "14px", borderRadius: "16px", backgroundColor: isIgnored ? (isDark ? "rgba(30, 41, 59, 0.52)" : "rgba(241, 245, 249, 0.92)") : surfaceAlt, border: `1px solid ${isIgnored ? borderColor : (isDark ? "rgba(248, 113, 113, 0.18)" : "rgba(248, 113, 113, 0.2)")}`, opacity: isIgnored ? 0.8 : 1, transition: "all 0.2s ease" }),
        exceptionItemHeader: { display: "flex", alignItems: { xs: "flex-start", sm: "center" }, justifyContent: "space-between", gap: "12px", flexWrap: "wrap" },
        exceptionItemIdentity: { display: "flex", alignItems: "center", gap: "12px", minWidth: 0, flex: 1 },
        exceptionAvatar: (isIgnored) => ({ width: 42, height: 42, borderRadius: "14px", display: "flex", alignItems: "center", justifyContent: "center", fontWeight: 800, color: "#fff", fontSize: "0.95rem", flexShrink: 0, background: isIgnored ? (isDark ? "linear-gradient(135deg, #475569, #64748b)" : "linear-gradient(135deg, #94a3b8, #cbd5e1)") : `linear-gradient(135deg, ${colors.redAccent[500]}, ${colors.redAccent[700]})`, boxShadow: isIgnored ? "none" : "0 10px 18px rgba(127, 29, 29, 0.22)" }),
        exceptionPhoneChip: { height: 24, backgroundColor: isDark ? "rgba(59, 130, 246, 0.12)" : "rgba(219, 234, 254, 0.96)", color: isDark ? colors.blueAccent[300] : "#1d4ed8", border: `1px solid ${isDark ? "rgba(96, 165, 250, 0.16)" : "rgba(96, 165, 250, 0.22)"}` },
        exceptionStateChip: (isIgnored) => ({ fontWeight: 700, backgroundColor: isIgnored ? (isDark ? "rgba(148, 163, 184, 0.14)" : "rgba(226, 232, 240, 0.92)") : (isDark ? "rgba(239, 68, 68, 0.14)" : "rgba(254, 226, 226, 0.92)"), color: isIgnored ? colors.grey[300] : colors.redAccent[400], border: `1px solid ${isIgnored ? borderColor : (isDark ? "rgba(248, 113, 113, 0.2)" : "rgba(248, 113, 113, 0.24)")}` }),
        exceptionConflictChip: { fontWeight: 700, backgroundColor: isDark ? "rgba(239, 68, 68, 0.14)" : "rgba(254, 226, 226, 0.92)", color: colors.redAccent[400], border: `1px solid ${isDark ? "rgba(248, 113, 113, 0.2)" : "rgba(248, 113, 113, 0.24)"}` },
        exceptionReasonCard: (isIgnored) => ({ mt: "12px", p: "12px 14px", borderRadius: "14px", backgroundColor: isIgnored ? (isDark ? "rgba(15, 23, 42, 0.36)" : "rgba(248, 250, 252, 0.96)") : (isDark ? "rgba(127, 29, 29, 0.1)" : "rgba(254, 242, 242, 0.96)"), border: `1px solid ${isIgnored ? borderColor : (isDark ? "rgba(248, 113, 113, 0.16)" : "rgba(248, 113, 113, 0.2)")}` }),
        exceptionOverridePanel: { mt: "12px", p: "12px", borderRadius: "14px", backgroundColor: isDark ? "rgba(15, 23, 42, 0.42)" : "rgba(255, 255, 255, 0.96)", border: `1px dashed ${borderColor}` },
        exceptionActionButton: { fontSize: "0.74rem", textTransform: "none", py: "4px", borderRadius: "10px", fontWeight: 700 },
        exceptionOverrideInput: { "& .MuiOutlinedInput-root": { borderRadius: "12px", backgroundColor: surfaceAlt, fontSize: "0.82rem" } },
        exceptionInlineTextButton: { color: colors.grey[300], fontSize: "0.74rem", minWidth: "auto", px: "10px", py: "4px", textTransform: "none" },
        exceptionSaveButton: { fontSize: "0.74rem", minWidth: "auto", px: "10px", py: "4px", textTransform: "none", fontWeight: 700, borderRadius: "10px" },
        exceptionFooterNotice: (tone) => ({ mt: "16px", p: "12px 14px", borderRadius: "14px", border: `1px solid ${tone === "warning"
            ? isDark ? "rgba(251, 191, 36, 0.2)" : "rgba(245, 158, 11, 0.24)"
            : isDark ? "rgba(52, 211, 153, 0.2)" : "rgba(16, 185, 129, 0.24)"}`,
            backgroundColor: tone === "warning"
                ? isDark ? "rgba(120, 53, 15, 0.16)" : "rgba(255, 251, 235, 0.96)"
                : isDark ? "rgba(6, 95, 70, 0.14)" : "rgba(240, 253, 244, 0.96)"
        }),
        addButton: { 
            backgroundColor: "#3e4396", 
            color: "#fff", 
            fontWeight: "bold", 
            whiteSpace: "nowrap", 
            "&:hover": { backgroundColor: "#31357c" } 
        },
    };
}

export default FoodItems;
