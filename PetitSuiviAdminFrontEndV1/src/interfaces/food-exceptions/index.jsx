/**
 * @file food-exceptions/index.jsx
 * @description Food Exceptions Viewer Interface.
 *
 * PURPOSE:
 * Displays all dietary restrictions and food exceptions (allergies,
 * intolerances, contraindications) recorded for enrolled children in the
 * selected academic planning year. Exceptions are originally extracted from
 * children's medical forms through AI analysis triggered during inscription
 * approval or when a new food item is added.
 *
 * KEY STATE:
 * - `children`           – Array of child-exception objects, each with a
 *                           nested `exceptions[]` array. Scoped to the
 *                           selected planning year.
 * - `plannings`          – All available planning year options from API.
 * - `selectedPlanningId` – The currently active planning-year filter.
 * - `loading`            – Boolean flag indicating an active data fetch.
 * - `error`              – Error string for display on fetch failure.
 * - `expandedChild`      – ChildID of the accordion card currently open.
 * - `searchTerm`         – Client-side search string for filtering.
 * - `aiEnabled`          – System parameter controlling the AI notice banner.
 *
 * KEY FUNCTIONS:
 * - `fetchPlannings()`       – GET /admin/plannings
 *                               Loads all academic year ranges. Auto-selects the
 *                               current active year based on today's date.
 * - `fetchAiEnabled()`       – GET /admin/parameters
 *                               Reads the `ai_enabled` system parameter to
 *                               conditionally show/hide the AI-disabled banner.
 * - `fetchExceptions(id)`    – GET /admin/food-exceptions?planning_id={id}
 *                               Retrieves all child food-exception records scoped
 *                               to the given planning year. Returns an array of
 *                               children, each with:
 *                                 child_id, child_name, class_name,
 *                                 exception_count, dietary_comment,
 *                                 exceptions[{ meal_id, meal_name, reason }]
 *
 * AI INTEGRATION:
 * - Exceptions are *created* by the AI during inscription approval
 *   (`inscriptions/index.jsx → handleRescanMedical`) and when a food item
 *   is saved (`food-items/index.jsx → handleRescanMeal`).
 * - This interface is READ-ONLY — it only *displays* pre-detected exceptions.
 *
 * BACKEND API ENDPOINTS:
 * ┌─────────────────────────────────────────────────────────────────────────┐
 * │ GET /api/admin/plannings                                                │
 * │    → Returns: { data: [{ id, label, start_date, end_date, ... }] }     │
 * │                                                                         │
 * │ GET /api/admin/parameters                                               │
 * │    → Returns: { data: [{ name, value }] }                               │
 * │    → Used to read: ai_enabled                                           │
 * │                                                                         │
 * │ GET /api/admin/food-exceptions?planning_id={id}                         │
 * │    Controller: FoodExceptionController@index                            │
 * │    → Returns: {                                                         │
 * │         success: true,                                                  │
 * │         data: [{                                                        │
 * │           child_id: int,                                                │
 * │           child_name: string,                                           │
 * │           class_name: string,                                           │
 * │           exception_count: int,                                         │
 * │           dietary_comment: string,                                      │
 * │           exceptions: [{                                                │
 * │             meal_id: int,                                               │
 * │             meal_name: string,                                          │
 * │             reason: string                                              │
 * │           }]                                                            │
 * │         }]                                                              │
 * │       }                                                                 │
 * └─────────────────────────────────────────────────────────────────────────┘
 *
 * DEPENDENCIES:
 * - Axios (`api`) → Laravel REST API → MySQL database.
 * - MUI components – Box, Typography, TextField, Collapse, Select,
 *                    MenuItem, FormControl, CircularProgress.
 */

import {
    Box,
    Typography,
    TextField,
    Collapse,
    Select,
    MenuItem,
    FormControl,
    CircularProgress,
    Button,
    IconButton,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    Autocomplete,
    Chip,
    InputAdornment,
} from "@mui/material";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import AddCircleOutlineIcon from "@mui/icons-material/AddCircleOutline";
import SearchIcon from "@mui/icons-material/Search";
import RestaurantOutlinedIcon from "@mui/icons-material/RestaurantOutlined";
import Groups2OutlinedIcon from "@mui/icons-material/Groups2Outlined";
import { useTheme } from "@mui/material";
import { useEffect, useState, useMemo } from "react";
import { tokens } from "../../theme";
import Header from "../../components/Header";
import api from "../../api/axios";
import { getAdminPrimaryButtonSx } from "../../utils/adminActionButtons";

// ─────────────────────────────────────────────────────────────────────────────
// PURE FUNCTIONAL SUB-COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

/**
 * AiDisabledBanner
 *
 * Renders a warning strip when the AI feature flag is off. Notifies the admin
 * that automated exception detection is inactive while still showing existing
 * records.
 *
 * @param {object}  props
 * @param {object}  props.colors  – MUI color tokens from the active theme.
 * @param {object}  props.sx      – Merged style object from `getStyles()`.
 */
const AiDisabledBanner = ({ colors, sx }) => (
    <Box sx={sx.aiBanner}>
        <Typography fontSize="18px">⚠️</Typography>
        <Typography color={colors.redAccent[400]} fontSize="0.85rem">
            <strong>IA désactivée</strong> — La détection automatique des
            exceptions alimentaires est désactivée. Les exceptions affichées sont
            celles déjà enregistrées.
        </Typography>
    </Box>
);

/**
 * ControlsBar
 *
 * Renders the planning-year selector dropdown and the child search field.
 *
 * @param {object}   props
 * @param {Array}    props.plannings           – List of planning year objects.
 * @param {string}   props.selectedPlanningId  – Currently selected year ID.
 * @param {Function} props.onPlanningChange    – Handler for year selection.
 * @param {string}   props.searchTerm          – Current search input value.
 * @param {Function} props.onSearchChange      – Handler for search input.
 * @param {object}   props.colors              – MUI color tokens.
 * @param {object}   props.sx                  – Merged style object.
 */
const ControlsBar = ({
    plannings,
    selectedPlanningId,
    onPlanningChange,
    searchTerm,
    onSearchChange,
    colors,
    sx,
}) => (
    <Box sx={sx.controlsBar}>
        <Box display="flex" alignItems={{ xs: "stretch", sm: "center" }} gap="12px" flexDirection={{ xs: "column", sm: "row" }}>
            <Typography sx={sx.toolbarLabel}>Année scolaire</Typography>
            <FormControl variant="outlined" size="small" sx={sx.selectControl}>
                <Select value={selectedPlanningId} onChange={onPlanningChange}>
                    {plannings.map((p) => (
                        <MenuItem key={p.id} value={String(p.id)}>
                            {p.label ||
                                `${p.startDate || p.start_date} — ${p.endDate || p.end_date}`}
                        </MenuItem>
                    ))}
                </Select>
            </FormControl>
        </Box>
        <TextField
            variant="outlined"
            placeholder="Rechercher un enfant ou une classe"
            value={searchTerm}
            onChange={onSearchChange}
            sx={sx.searchField}
            InputProps={{
                startAdornment: (
                    <InputAdornment position="start">
                        <SearchIcon sx={{ color: colors.grey[400] }} fontSize="small" />
                    </InputAdornment>
                ),
            }}
        />
    </Box>
);

/**
 * InfoBanner
 *
 * Displays a contextual information strip showing the total number of children
 * currently flagged with food exceptions after client-side filtering.
 *
 * @param {object} props
 * @param {number} props.count   – Number of filtered children.
 * @param {object} props.colors  – MUI color tokens.
 * @param {object} props.sx      – Merged style object.
 */
const InfoBanner = ({ count, colors, sx }) => (
    <Box sx={sx.infoBanner}>
        <Typography color={colors.grey[200]} variant="body2">
            Seuls les enfants ayant des problèmes de santé alimentaires sont
            affichés. <strong>{count}</strong> enfant(s) concerné(s).
        </Typography>
    </Box>
);

/**
 * LoadingState
 *
 * Renders a centered spinner while async data is being fetched.
 *
 * @param {object} props
 * @param {object} props.colors – MUI color tokens.
 */
const LoadingState = ({ colors }) => (
    <Box textAlign="center" py="40px">
        <CircularProgress sx={{ color: colors.greenAccent[500] }} />
        <Typography color={colors.grey[300]} mt="10px">
            Chargement...
        </Typography>
    </Box>
);

/**
 * EmptyState
 *
 * Displayed when no food exceptions are found for the selected year/filter.
 * Conveys an "all clear" status with a visual indicator.
 *
 * @param {object} props
 * @param {object} props.colors – MUI color tokens.
 * @param {object} props.sx     – Merged style object.
 */
const EmptyState = ({ colors, sx }) => (
    <Box sx={sx.emptyState}>
        <Typography variant="h4" mb="10px">
            ✅
        </Typography>
        <Typography variant="h5" color={colors.greenAccent[500]}>
            Aucune exception alimentaire
        </Typography>
        <Typography color={colors.grey[300]}>
            Tous les enfants peuvent manger tous les repas.
        </Typography>
    </Box>
);

/**
 * ExceptionItem
 *
 * Renders a single forbidden-meal row inside an expanded child card. Displays
 * the meal name and the reason (AI-derived restriction explanation).
 *
 * @param {object} props
 * @param {object} props.exc     – Exception item { meal_id, meal_name, reason }.
 * @param {object} props.colors  – MUI color tokens.
 * @param {object} props.sx      – Merged style object.
 */
const ExceptionItem = ({ exc, colors, sx, onDelete }) => (
    <Box key={exc.meal_id} sx={sx.exceptionItem}>
        <Box sx={sx.exceptionDot} />
        <Box flex="1">
            <Typography fontWeight="bold" color={colors.redAccent[400]} fontSize="0.9rem">
                {exc.meal_name || "Repas inconnu"}
            </Typography>
            <Typography variant="caption" color={colors.grey[400]}>
                {exc.reason || "Raison non spécifiée"}
            </Typography>
        </Box>
        {onDelete && (
            <IconButton size="small" onClick={() => onDelete(exc.exception_id)} sx={{ color: colors.redAccent[400] }}>
                <DeleteOutlineIcon fontSize="small" />
            </IconButton>
        )}
    </Box>
);

/**
 * ExpandedDetail
 *
 * Accordion body rendered inside an expanded ChildCard. Shows the full
 * dietary comment (AI summary) and the list of forbidden meals.
 *
 * @param {object}   props
 * @param {object}   props.child   – Child data object from the API.
 * @param {boolean}  props.isOpen  – Whether the accordion is expanded.
 * @param {object}   props.colors  – MUI color tokens.
 * @param {object}   props.sx      – Merged style object.
 */
const ExpandedDetail = ({ child, isOpen, colors, sx, onDeleteException }) => (
    <Collapse in={isOpen}>
        <Box sx={sx.expandedBody}>
            <Typography variant="body2" color={colors.grey[200]} mb="16px">
                <strong>Commentaire diététique :</strong>{" "}
                {child.dietary_comment || "Aucun"}
            </Typography>

            <Typography
                variant="body2"
                fontWeight="bold"
                color={colors.grey[100]}
                mb="12px"
            >
                Repas interdits ({child.exception_count || 0})
            </Typography>

            {(child.exception_count || 0) === 0 ? (
                <Typography variant="body2" color={colors.greenAccent[500]}>
                    Aucun repas spécifique interdit.
                </Typography>
            ) : (
                <Box display="flex" flexDirection="column" gap="8px">
                    {(child.exceptions || []).map((exc) => (
                        <ExceptionItem
                            key={exc.meal_id}
                            exc={exc}
                            colors={colors}
                            sx={sx}
                            onDelete={onDeleteException}
                        />
                    ))}
                </Box>
            )}
        </Box>
    </Collapse>
);

/**
 * ChildCard
 *
 * A collapsible accordion card representing one child's exception profile.
 * The main row shows avatar, name, class, badge count, and truncated comment.
 * Clicking anywhere on the row toggles the expanded detail section.
 *
 * @param {object}   props
 * @param {object}   props.child          – Child exception object from the API.
 * @param {boolean}  props.isExpanded     – Whether this card is currently open.
 * @param {Function} props.onToggle       – Callback to toggle expansion.
 * @param {Function} props.getSeverityColor – Returns badge color based on count.
 * @param {object}   props.colors         – MUI color tokens.
 * @param {object}   props.sx             – Merged style object.
 */
const ChildCard = ({ child, isExpanded, onToggle, getSeverityColor, colors, sx, onDeleteException }) => {
    const severityColor = getSeverityColor(child.exception_count);

    return (
        <Box sx={sx.card}>
            {/* ── Main clickable row ── */}
            <Box sx={sx.cardRow} onClick={onToggle}>
                {/* Avatar */}
                <Box sx={sx.avatar}>
                    {(child.child_name || "?").charAt(0).toUpperCase()}
                </Box>

                {/* Name + class */}
                <Box flex="1" minWidth="150px">
                    <Typography fontWeight="bold" color={colors.grey[100]} fontSize="0.95rem">
                        {child.child_name || "Inconnu"}
                    </Typography>
                    <Typography color={colors.grey[300]} fontSize="0.8rem">
                        🏫 {child.class_name || "Non assigné"}
                    </Typography>
                </Box>

                {/* Exception count badge */}
                <Box
                    px="12px"
                    py="5px"
                    borderRadius="20px"
                    fontSize="12px"
                    fontWeight="bold"
                    flexShrink={0}
                    sx={{
                        backgroundColor: severityColor + "22",
                        color: severityColor,
                    }}
                >
                    🚫 {child.exception_count || 0} repas interdit
                    {(child.exception_count || 0) > 1 ? "s" : ""}
                </Box>

                {/* Dietary comment (truncated, desktop only) */}
                <Box flex="1.5" minWidth="200px" display={{ xs: "none", md: "block" }}>
                    <Typography
                        variant="body2"
                        color={colors.grey[300]}
                        fontStyle="italic"
                        noWrap
                        title={child.dietary_comment || ""}
                    >
                        💬 {child.dietary_comment || "Aucun commentaire"}
                    </Typography>
                </Box>

                {/* Expand icon */}
                <Typography color={colors.grey[300]} fontSize="1rem" flexShrink={0}>
                    {isExpanded ? "▲" : "▼"}
                </Typography>
            </Box>

            {/* ── Expanded accordion body ── */}
            <ExpandedDetail
                child={child}
                isOpen={isExpanded}
                colors={colors}
                sx={sx}
                onDeleteException={onDeleteException}
            />
        </Box>
    );
};

/**
 * AddExceptionDialog — Dialog to manually add a food exception for a child.
 */
const AddExceptionDialog = ({ open, onClose, onSubmit, colors, allChildren, allMeals, saving, selectedPlanningId }) => {
    const theme = useTheme();
    const sx = getStyles(colors, theme.palette.mode === "dark");
    const [selectedChild, setSelectedChild] = useState(null);
    const [selectedMeals, setSelectedMeals] = useState([]);
    const [reason, setReason] = useState("");

    const handleSubmit = () => {
        if (!selectedChild || selectedMeals.length === 0 || !reason.trim()) return;
        onSubmit({
            child_id: selectedChild.child_id,
            meal_ids: selectedMeals.map(m => m.id || m.MealsID),
            reason: reason.trim(),
            planning_id: selectedPlanningId ? Number(selectedPlanningId) : undefined,
        });
        setSelectedChild(null);
        setSelectedMeals([]);
        setReason("");
    };

    return (
        <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm"
            PaperProps={{ sx: sx.dialogPaper }}>
            <DialogTitle sx={sx.dialogTitle}>Ajouter une exception alimentaire</DialogTitle>
            <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: '16px', mt: 1 }}>
                <Box sx={sx.formCard}>
                <Autocomplete
                    options={allChildren}
                    getOptionLabel={(opt) => [opt.child_name, opt.class_name].filter(Boolean).join(" • ")}
                    value={selectedChild}
                    onChange={(_, val) => setSelectedChild(val)}
                    renderInput={(params) => <TextField {...params} label="Enfant" variant="outlined" InputLabelProps={{ shrink: true }} sx={sx.filledInputSx} />}
                    isOptionEqualToValue={(o, v) => o.child_id === v.child_id}
                />
                <Autocomplete
                    multiple
                    options={allMeals}
                    getOptionLabel={(opt) => opt.name || opt.Name || ""}
                    value={selectedMeals}
                    onChange={(_, val) => setSelectedMeals(val)}
                    renderInput={(params) => <TextField {...params} label="Repas à interdire" variant="outlined" InputLabelProps={{ shrink: true }} sx={sx.filledInputSx} />}
                    renderTags={(value, getTagProps) =>
                        value.map((opt, index) => {
                            const mealLabel = opt.name || opt.Name || "";
                            const mealId = opt.id || opt.MealsID;
                            return (
                            <Chip label={mealLabel} {...getTagProps({ index })} key={mealId}
                                sx={sx.mealChip} />
                        )})
                    }
                    isOptionEqualToValue={(o, v) => (o.id || o.MealsID) === (v.id || v.MealsID)}
                />
                <TextField
                    label="Raison de la restriction"
                    variant="outlined"
                    multiline
                    minRows={2}
                    value={reason}
                    onChange={(e) => setReason(e.target.value)}
                    InputLabelProps={{ shrink: true }}
                    sx={sx.filledInputSx}
                />
                </Box>
            </DialogContent>
            <DialogActions sx={sx.dialogActions}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
                <Button
                    variant="contained"
                    disabled={!selectedChild || selectedMeals.length === 0 || !reason.trim() || saving}
                    onClick={handleSubmit}
                    sx={sx.primaryButton}
                >
                    {saving ? <CircularProgress size={18} sx={{ color: '#fff' }} /> : 'Ajouter'}
                </Button>
            </DialogActions>
        </Dialog>
    );
};

// ─────────────────────────────────────────────────────────────────────────────
// MAIN COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

/**
 * FoodExceptions
 *
 * Root component for the Food Exceptions management interface.
 * Displays a read-only, filterable, accordion-style list of children with
 * AI-detected dietary restrictions grouped by academic planning year.
 *
 * @component
 * @returns {JSX.Element}
 */
const FoodExceptions = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const isDark = theme.palette.mode === "dark";

    // ── State ──────────────────────────────────────────────────────────────
    const [children, setChildren] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [expandedChild, setExpandedChild] = useState(null);
    const [searchTerm, setSearchTerm] = useState("");
    const [aiEnabled, setAiEnabled] = useState(true);
    const [plannings, setPlannings] = useState([]);
    const [selectedPlanningId, setSelectedPlanningId] = useState("");
    const [addDialogOpen, setAddDialogOpen] = useState(false);
    const [addSaving, setAddSaving] = useState(false);
    const [allChildren, setAllChildren] = useState([]);
    const [allMeals, setAllMeals] = useState([]);

    // ── Effects ────────────────────────────────────────────────────────────

    /**
     * On mount: fetch the list of academic planning years and the AI toggle
     * configuration parameter. Auto-selects the current academic year.
     */
    useEffect(() => {
        const fetchPlannings = async () => {
            try {
                const res = await api.get("/admin/plannings");
                const list = res.data?.data || [];
                setPlannings(list);
                const today = new Date().toISOString().slice(0, 10);
                const current = list.find(
                    (p) =>
                        (p.startDate || p.start_date) <= today &&
                        (p.endDate || p.end_date) >= today
                );
                if (current) setSelectedPlanningId(String(current.id));
                else if (list.length > 0) setSelectedPlanningId(String(list[0].id));
            } catch {
                setPlannings([]);
            }
        };

        const fetchAiEnabled = async () => {
            try {
                const res = await api.get("/admin/parameters");
                const data = res.data?.data || res.data || [];
                const arr = Array.isArray(data) ? data : [];
                const aiParam = arr.find((p) => p.name === "ai_enabled");
                if (aiParam)
                    setAiEnabled(aiParam.value === "true" || aiParam.value === "1");
            } catch {
                /* silently ignore — assume enabled */
            }
        };

        fetchPlannings();
        fetchAiEnabled();
    }, []);

    /**
     * Whenever the planning-year selection changes, re-fetch the food exceptions
     * scoped to that year from the backend.
     *
     * Endpoint: GET /admin/food-exceptions?planning_id={selectedPlanningId}
     */
    useEffect(() => {
        if (!selectedPlanningId) return;

        const fetchExceptions = async () => {
            try {
                setLoading(true);
                setError("");
                const res = await api.get(
                    `/admin/food-exceptions?planning_id=${selectedPlanningId}`
                );
                setChildren(res.data?.data || []);
            } catch (err) {
                setError(
                    err?.response?.data?.message || "Échec du chargement."
                );
            } finally {
                setLoading(false);
            }
        };

        fetchExceptions();
    }, [selectedPlanningId]);

    // ── Derived State ──────────────────────────────────────────────────────

    /**
     * Client-side filtered children list. Matches against:
     *   - child_name
     *   - class_name
     *   - dietary_comment
     */
    const filteredChildren = useMemo(() => {
        if (!searchTerm) return children;
        const term = searchTerm.toLowerCase();
        return children.filter(
            (c) =>
                (c.child_name || "").toLowerCase().includes(term) ||
                (c.class_name || "").toLowerCase().includes(term) ||
                (c.dietary_comment || "").toLowerCase().includes(term)
        );
    }, [children, searchTerm]);

    // ── Handlers ───────────────────────────────────────────────────────────

    /**
     * Toggles the accordion expansion for a specific child card.
     * @param {number} childId – ChildID from the API response.
     */
    const toggleExpand = (childId) => {
        setExpandedChild((prev) => (prev === childId ? null : childId));
    };

    /**
     * Returns a severity color code based on the number of food exceptions.
     * @param  {number} count – Number of forbidden meals.
     * @returns {string} CSS-compatible color string.
     */
    const getSeverityColor = (count) => {
        if (count >= 3) return colors.redAccent[500];
        if (count >= 1) return "#f59e0b";
        return colors.greenAccent[500];
    };

    // ── Styles ─────────────────────────────────────────────────────────────
    const sx = getStyles(colors, isDark);

    const totalExceptions = useMemo(() => filteredChildren.reduce((sum, child) => sum + (child.exception_count || 0), 0), [filteredChildren]);

    // ── Add / Delete handlers ──────────────────────────────────────────────

    const handleOpenAddDialog = async () => {
        try {
            const [childRes, mealRes] = await Promise.all([
                api.get(selectedPlanningId ? `/admin/children?planning_id=${selectedPlanningId}` : '/admin/children'),
                api.get('/admin/meals'),
            ]);
            const childList = (childRes.data?.data || []).map(c => ({
                child_id: c.id || c.child_id || c.ChildID,
                class_name: c.class_name || c.className || '',
                child_name: `${c.firstName || c.Firstname || ''} ${c.lastName || c.Lastname || ''}`.trim(),
            }));
            setAllChildren(childList);
            setAllMeals(mealRes.data?.data || mealRes.data || []);
        } catch { /* ignore */ }
        setAddDialogOpen(true);
    };

    const handleAddException = async (payload) => {
        setAddSaving(true);
        try {
            await api.post('/admin/food-exceptions', payload);
            setAddDialogOpen(false);
            // Refresh list
            if (selectedPlanningId) {
                const res = await api.get(`/admin/food-exceptions?planning_id=${selectedPlanningId}`);
                setChildren(res.data?.data || []);
            }
        } catch (err) {
            alert('Erreur: ' + (err?.response?.data?.message || err.message));
        } finally {
            setAddSaving(false);
        }
    };

    const handleDeleteException = async (exceptionId) => {
        if (!window.confirm('Supprimer cette exception alimentaire ?')) return;
        try {
            await api.delete(`/admin/food-exceptions/${exceptionId}`);
            // Refresh list
            if (selectedPlanningId) {
                const res = await api.get(`/admin/food-exceptions?planning_id=${selectedPlanningId}`);
                setChildren(res.data?.data || []);
            }
        } catch (err) {
            alert('Erreur: ' + (err?.response?.data?.message || err.message));
        }
    };

    // ── Render ─────────────────────────────────────────────────────────────
    return (
        <Box m="20px">
            <Box display="flex" justifyContent="space-between" alignItems="center">
                <Header title="EXCEPTIONS ALIMENTAIRES" />
                <Button
                    variant="contained"
                    startIcon={<AddCircleOutlineIcon />}
                    onClick={handleOpenAddDialog}
                    sx={sx.sectionActionButton}
                >
                    Ajouter une exception
                </Button>
            </Box>

            {/* AI Disabled Banner (conditional) */}
            {!aiEnabled && <AiDisabledBanner colors={colors} sx={sx} />}

            {/* Year selector + Search bar */}
            <ControlsBar
                plannings={plannings}
                selectedPlanningId={selectedPlanningId}
                onPlanningChange={(e) => setSelectedPlanningId(e.target.value)}
                searchTerm={searchTerm}
                onSearchChange={(e) => setSearchTerm(e.target.value)}
                colors={colors}
                sx={sx}
            />

            <Box sx={sx.summaryGrid}>
                {[
                    { label: "Enfants concernés", value: filteredChildren.length, accent: colors.greenAccent[500], icon: <Groups2OutlinedIcon fontSize="small" /> },
                    { label: "Repas interdits", value: totalExceptions, accent: colors.redAccent[400], icon: <RestaurantOutlinedIcon fontSize="small" /> },
                ].map((item) => (
                    <Box key={item.label} sx={sx.summaryCard(item.accent)}>
                        <Box>
                            <Typography sx={sx.summaryLabel}>{item.label}</Typography>
                            <Typography sx={sx.summaryValue}>{item.value}</Typography>
                        </Box>
                        <Box sx={sx.summaryIconWrap(item.accent)}>{item.icon}</Box>
                    </Box>
                ))}
            </Box>

            {/* Info count banner */}
            <InfoBanner count={filteredChildren.length} colors={colors} sx={sx} />

            {/* Loading indicator */}
            {loading && <LoadingState colors={colors} />}

            {/* Error message */}
            {error && (
                <Typography color={colors.redAccent[500]} textAlign="center" mb="20px">
                    {error}
                </Typography>
            )}

            {/* Empty state */}
            {!loading && !error && filteredChildren.length === 0 && (
                <EmptyState colors={colors} sx={sx} />
            )}

            {/* Children accordion list */}
            {!loading && !error && filteredChildren.length > 0 && (
                <Box display="flex" flexDirection="column" gap="12px">
                    {filteredChildren.map((child) => (
                        <ChildCard
                            key={child.child_id}
                            child={child}
                            isExpanded={expandedChild === child.child_id}
                            onToggle={() => toggleExpand(child.child_id)}
                            getSeverityColor={getSeverityColor}
                            colors={colors}
                            sx={sx}
                            onDeleteException={handleDeleteException}
                        />
                    ))}
                </Box>
            )}

            {/* Add Exception Dialog */}
            <AddExceptionDialog
                open={addDialogOpen}
                onClose={() => setAddDialogOpen(false)}
                onSubmit={handleAddException}
                colors={colors}
                allChildren={allChildren}
                allMeals={allMeals}
                saving={addSaving}
                selectedPlanningId={selectedPlanningId}
            />
        </Box>
    );
};

export default FoodExceptions;

// ─────────────────────────────────────────────────────────────────────────────
// STYLES
// ─────────────────────────────────────────────────────────────────────────────

/**
 * getStyles
 *
 * Centralized style factory for the FoodExceptions interface. Returns
 * an object of named `sx` prop objects keyed by component/element name.
 *
 * @param  {object} colors – MUI color tokens derived from the active theme.
 * @returns {object}        Named sx prop objects.
 */
const getStyles = (colors, isDark) => {
    const surface = isDark ? "rgba(15, 23, 32, 0.88)" : "rgba(255, 255, 255, 0.82)";
    const surfaceAlt = isDark ? "rgba(19, 28, 39, 0.92)" : "#f8fafc";
    const border = isDark ? "rgba(148, 163, 184, 0.16)" : "rgba(148, 163, 184, 0.28)";
    return ({
    aiBanner: {
        mb: "15px",
        p: "12px",
        borderRadius: "14px",
        backgroundColor: "rgba(239,68,68,0.1)",
        border: "1px solid rgba(239,68,68,0.3)",
        display: "flex",
        alignItems: "center",
        gap: "10px",
    },
    controlsBar: {
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        mb: "20px",
        flexWrap: "wrap",
        gap: "15px",
        px: { xs: "14px", md: "18px" },
        py: { xs: "14px", md: "16px" },
        borderRadius: "18px",
        background: surface,
        border: `1px solid ${border}`,
        boxShadow: isDark ? "0 16px 30px rgba(2, 6, 23, 0.24)" : "0 14px 28px rgba(148, 163, 184, 0.16)",
    },
    toolbarLabel: { fontSize: "0.82rem", fontWeight: 700, color: colors.grey[300], whiteSpace: "nowrap" },
    selectControl: { minWidth: 210, "& .MuiOutlinedInput-root": { borderRadius: "12px", backgroundColor: surfaceAlt } },
    searchField: { minWidth: 280, ml: { md: "auto" }, "& .MuiOutlinedInput-root": { borderRadius: "12px", backgroundColor: surfaceAlt } },
    summaryGrid: { display: "grid", gridTemplateColumns: { xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }, gap: "14px", mb: "18px" },
    summaryCard: (accent) => ({ display: "flex", alignItems: "center", justifyContent: "space-between", gap: "14px", px: "18px", py: "16px", borderRadius: "18px", background: surface, border: `1px solid ${border}`, boxShadow: isDark ? "0 18px 34px rgba(2, 6, 23, 0.26)" : "0 16px 32px rgba(148, 163, 184, 0.16)", borderLeft: `4px solid ${accent}` }),
    summaryLabel: { fontSize: "0.78rem", letterSpacing: "0.04em", textTransform: "uppercase", color: colors.grey[400], mb: "4px" },
    summaryValue: { fontSize: "1.45rem", lineHeight: 1, fontWeight: 800, color: colors.grey[100] },
    summaryIconWrap: (accent) => ({ width: 42, height: 42, borderRadius: "14px", display: "flex", alignItems: "center", justifyContent: "center", backgroundColor: `${accent}12`, border: `1px solid ${accent}28`, color: accent, flexShrink: 0 }),
    infoBanner: {
        background: surface,
        borderRadius: "16px",
        p: "15px",
        mb: "20px",
        display: "flex",
        alignItems: "center",
        gap: "10px",
        border: `1px solid ${border}`,
    },
    emptyState: {
        textAlign: "center",
        py: "40px",
        background: surface,
        borderRadius: "18px",
        border: `1px solid ${border}`,
    },
    card: {
        background: surface,
        borderRadius: "18px",
        overflow: "hidden",
        border: `1px solid ${border}`,
        boxShadow: isDark ? "0 14px 28px rgba(2,6,23,0.20)" : "0 12px 24px rgba(148,163,184,0.14)",
        transition: "box-shadow 0.2s",
        "&:hover": { boxShadow: "0px 4px 15px rgba(0,0,0,0.25)" },
    },
    cardRow: {
        display: "flex",
        alignItems: "center",
        p: "16px 20px",
        gap: "16px",
        flexWrap: "wrap",
        cursor: "pointer",
        transition: "background 0.2s",
        "&:hover": { backgroundColor: isDark ? "rgba(30,41,59,0.64)" : "rgba(241,245,249,0.92)" },
    },
    avatar: {
        width: "42px",
        height: "42px",
        borderRadius: "10px",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontWeight: "bold",
        color: "#fff",
        fontSize: "16px",
        flexShrink: 0,
        background: `linear-gradient(135deg, #0f766e, #2dd4bf)`,
    },
    expandedBody: {
        px: "24px",
        py: "16px",
        backgroundColor: surfaceAlt,
        borderTop: `1px solid ${border}`,
    },
    exceptionItem: {
        p: "12px 16px",
        borderRadius: "12px",
        backgroundColor: surface,
        display: "flex",
        alignItems: "center",
        gap: "12px",
        border: `1px solid ${colors.redAccent[900]}33`,
    },
    exceptionDot: {
        width: "8px",
        height: "8px",
        borderRadius: "50%",
        backgroundColor: colors.redAccent[400],
        flexShrink: 0,
    },
    sectionActionButton: { ...getAdminPrimaryButtonSx({ px: "16px", py: "10px" }) },
    dialogPaper: { backgroundColor: colors.primary[400], backgroundImage: 'none', color: colors.grey[100], borderRadius: "16px", boxShadow: "0px 8px 30px rgba(0,0,0,0.5)", overflow: "hidden" },
    dialogTitle: { fontWeight: "bold", fontSize: "1.1rem", borderBottom: `1px solid ${colors.primary[500]}` },
    dialogActions: { px: 3, pb: 2, pt: 2, borderTop: `1px solid ${colors.primary[500]}` },
    formCard: { backgroundColor: isDark ? colors.primary[500] : "rgba(255,255,255,0.98)", border: `1px solid ${isDark ? colors.primary[600] : "rgba(148, 163, 184, 0.22)"}`, borderRadius: "16px", padding: "18px", boxShadow: isDark ? "0 12px 28px rgba(0,0,0,0.12)" : "0 14px 32px rgba(15,23,42,0.08)", display: 'flex', flexDirection: 'column', gap: '16px' },
    filledInputSx: { "& .MuiOutlinedInput-root": { borderRadius: "12px", backgroundColor: isDark ? colors.primary[400] : "#f8fafc" }, "& .MuiInputLabel-root": { color: colors.grey[300], fontWeight: 600 }, "& .MuiInputLabel-root.Mui-focused": { color: isDark ? "#94a3b8" : "#475569" }, "& .MuiInputBase-input": { color: isDark ? colors.grey[100] : "#0f172a" } },
    mealChip: { backgroundColor: isDark ? "rgba(239,68,68,0.16)" : "rgba(254,226,226,0.92)", color: colors.redAccent[400], border: `1px solid ${isDark ? "rgba(248,113,113,0.18)" : "rgba(248,113,113,0.22)"}` },
    primaryButton: { ...getAdminPrimaryButtonSx({ px: "18px" }) },
});
};
