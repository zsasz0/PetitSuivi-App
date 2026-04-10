/**
 * @file meals/index.jsx
 * @description Weekly Meal Planning Interface.
 *
 * PURPOSE:
 * Allows administrators to build and manage the school's weekly meal schedule.
 * Each cell in the grid represents a meal slot (Lunch or Snack) for a day of
 * the week. The interface supports week navigation, preset save/load, and
 * AI-driven exception analysis per meal slot.
 *
 * KEY STATE:
 * - `weekPlan`        – 2D structure mapping days → meal types → food item names.
 * - `currentWeek`     – The ISO week number currently displayed.
 * - `planningId`      – Active planning-year ID; scopes all reads/writes.
 * - `presets`         – Saved week-plan templates the admin can reuse.
 * - `exceptions`      – Per-slot exception data returned from the AI scan.
 * - `aiEnabled`       – Global AI on/off flag read from application parameters.
 * - `presetDialogOpen`– Controls the "save as preset" / "load preset" dialog.
 *
 * BACKEND API ENDPOINTS CONSUMED:
 * ─────────────────────────────────────────────────────────────────────────────
 * | Method | Endpoint                                | Purpose                          |
 * |--------|------------------------------------------|----------------------------------|
 * | GET    | /admin/meals                             | Master food-item catalog         |
 * | GET    | /admin/meals/by-week/{date}              | Weekly meal plan grid data       |
 * | GET    | /admin/menu-plannings                    | List saved preset templates      |
 * | GET    | /admin/menu-plannings/{id}               | Fetch single preset with days    |
 * | POST   | /admin/menu-plannings                    | Save current week as preset      |
 * | POST   | /admin/menu-plannings/apply-week         | Persist week plan to DB          |
 * | DELETE | /admin/menu-plannings/{id}               | Delete a preset template         |
 * | GET    | /admin/food-exceptions?meal_type=x       | Children food exceptions by type |
 * | GET    | /admin/child-food-exception-overrides    | Per-child meal overrides by week |
 * | POST   | /admin/child-food-exception-overrides    | Save/update overrides            |
 * | GET    | /admin/plannings                         | Academic year list               |
 * | GET    | /admin/parameters                       | System parameters (AI toggle)    |
 * ─────────────────────────────────────────────────────────────────────────────
 *
 * KEY FUNCTIONS:
 * - `handleSaveWeek()`          – POST/PUT to persist the week plan via REST API.
 * - `renderExceptionColumn(day, mealType)` – Renders the exception badge/notes for
 *                                 a specific cell, including AI-detected conflict info.
 * - `handleLoadPreset(preset)`  – Populates the week grid from a saved preset.
 * - `handleSavePreset(name)`    – Saves the current week layout as a named preset.
 * - `handleWeekChange(dir)`     – Navigates forward or backward by one week.
 *
 * SUB-COMPONENTS (pure functional, props-driven):
 * - StatsCards           – Lunch/Snack item count cards
 * - YearSelector         – Academic year planning dropdown
 * - WeekNavigator        – Previous/next/today week navigation bar
 * - BlankSlate           – Empty week prompt
 * - WeekGrid             – The main 5-row meal grid with exception columns
 * - ActionButtons        – Save/load/preset buttons below the grid
 * - WeekConflictsTable   – AI-driven exception summary table
 * - MealPickerDialog     – Modal for selecting meals per cell
 * - SavedMenusDialog     – Load/delete preset templates dialog
 * - SavePresetDialog     – Name and save a new preset dialog
 *
 * DEPENDENCIES:
 * - Axios (`api`) → Laravel REST API → MySQL database.
 * - AI service (backend endpoint) – Per-meal exception analysis against child dietary profiles.
 * - MUI components – Select, Dialog, Checkbox, Chip, etc.
 */
import { Box, Button, Typography, Select, MenuItem, FormControl, Chip, Dialog, DialogTitle, DialogContent, DialogActions, CircularProgress, TextField, IconButton } from "@mui/material";
import { tokens } from "../../theme";
import Header from "../../components/Header";
import { useTheme } from "@mui/material";
import { useEffect, useState, useMemo, useCallback } from "react";
import api from "../../api/axios";
import { getAdminPrimaryButtonSx } from "../../utils/adminActionButtons";
import RestaurantMenuOutlinedIcon from "@mui/icons-material/RestaurantMenuOutlined";
import BakeryDiningOutlinedIcon from "@mui/icons-material/BakeryDiningOutlined";
import CloseIcon from "@mui/icons-material/Close";

const WEEKDAYS = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];

const getMonday = (d) => {
    const date = new Date(d);
    const day = date.getDay();
    const diff = date.getDate() - day + (day === 0 ? -6 : 1);
    date.setDate(diff);
    date.setHours(0, 0, 0, 0);
    return date;
};

const formatDate = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;

const isSnackCategory = (name) => {
    const n = String(name || '').toLowerCase().trim();
    return n === 'snack' || n === 'snacks' || n === 'goûter' || n === 'gouter';
};

const formatDisplayDate = (d) => {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return `${d.getDate()} ${months[d.getMonth()]} ${d.getFullYear()}`;
};

/* ═══════════════════════════════════════════════════════════
   Pure Functional Sub-Components
   ═══════════════════════════════════════════════════════════ */

/**
 * StatsCards – Displays lunch and snack item counts.
 * @param {{ lunchCount: number, snackCount: number, colors: object }} props
 */
const StatsCards = ({ lunchCount, snackCount, colors }) => {
    const s = getStyles(colors);
    return (
        <Box sx={s.statsGrid}>
            {[
                { label: "Déjeuners disponibles", value: lunchCount, accent: colors.greenAccent[500], icon: <RestaurantMenuOutlinedIcon fontSize="small" /> },
                { label: "Goûters disponibles", value: snackCount, accent: colors.blueAccent[400], icon: <BakeryDiningOutlinedIcon fontSize="small" /> },
            ].map((item) => (
                <Box key={item.label} sx={s.statCard(item.accent)}>
                    <Box>
                        <Typography sx={s.statLabel}>{item.label}</Typography>
                        <Typography sx={s.statValue}>{item.value}</Typography>
                    </Box>
                    <Box sx={s.statIcon(item.accent)}>{item.icon}</Box>
                </Box>
            ))}
        </Box>
    );
};

/**
 * YearSelector – Academic year planning dropdown.
 */
const YearSelector = ({ plannings, selectedPlanningId, setSelectedPlanningId, colors }) => {
    const s = getStyles(colors);
    return (
        <Box sx={s.yearSelectorRow}>
            <Box display="flex" alignItems={{ xs: "stretch", sm: "center" }} gap="12px" flexDirection={{ xs: "column", sm: "row" }}>
            <Typography sx={s.toolbarLabel}>Année scolaire</Typography>
            <FormControl variant="outlined" size="small" sx={s.selectControl}>
                <Select value={selectedPlanningId} onChange={(e) => setSelectedPlanningId(e.target.value)} sx={{ fontSize: '0.9rem' }}>
                    {plannings.map(p => (
                        <MenuItem key={p.id} value={String(p.id)}>
                            {p.label || `${p.startDate || p.start_date} — ${p.endDate || p.end_date}`}
                        </MenuItem>
                    ))}
                </Select>
            </FormControl>
            </Box>
            <Typography color={colors.grey[400]} fontSize="0.8rem" fontStyle="italic">
                Les exceptions affichées concernent uniquement les enfants inscrits cette année.
            </Typography>
        </Box>
    );
};

/**
 * WeekNavigator – Previous/next/today week navigation bar.
 */
const WeekNavigator = ({ weekStart, weekEndDate, isCurrentWeek, navigationBounds, goToPreviousWeek, goToNextWeek, goToThisWeek, colors }) => {
    const s = getStyles(colors);
    return (
        <Box sx={s.weekNavRow}>
            <Button onClick={goToPreviousWeek} disabled={navigationBounds.isPrevDisabled}
                sx={s.navButton(navigationBounds.isPrevDisabled)}>
                ← Précédente
            </Button>
            <Box display="flex" alignItems="center" gap="16px">
                <Typography variant="h5" fontWeight="bold" color={colors.grey[100]} textAlign="center">
                    {formatDisplayDate(weekStart)} — {formatDisplayDate(weekEndDate)}
                </Typography>
                {!isCurrentWeek && (
                    <Button variant="outlined" size="small" onClick={goToThisWeek}
                        sx={s.todayButton}>
                        Aujourd'hui
                    </Button>
                )}
            </Box>
            <Button onClick={goToNextWeek} disabled={navigationBounds.isNextDisabled}
                sx={s.navButton(navigationBounds.isNextDisabled)}>
                Suivante →
            </Button>
        </Box>
    );
};

/**
 * BlankSlate – Empty week prompt with create/load buttons.
 */
const BlankSlate = ({ handleCreateFromScratch, openSavedMenus, colors }) => {
    const s = getStyles(colors);
    return (
        <Box sx={s.blankSlateBox}>
            <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mb="10px"> Aucun plan pour cette semaine</Typography>
            <Typography color={colors.grey[300]} mb="20px">Créez un plan à partir de zéro ou chargez un menu enregistré.</Typography>
            <Box display="flex" gap="16px">
                <Button variant="contained" onClick={handleCreateFromScratch} sx={s.createBtn}>Créer à partir de zéro</Button>
                <Button variant="contained" onClick={openSavedMenus} sx={s.loadBtn}>Charger un modèle</Button>
            </Box>
        </Box>
    );
};



/**
 * ActionButtons – Save/load/preset buttons below the grid.
 */
const ActionButtons = ({ openSavedMenus, openPresetPrompt, handleSaveWeek, saving, colors }) => {
    const s = getStyles(colors);
    return (
        <Box display="flex" justifyContent="flex-end" gap="12px" mt="20px">
            <Button variant="outlined" onClick={openSavedMenus} sx={s.outlinedBlue}>Charger un modèle</Button>
            <Button variant="outlined" onClick={openPresetPrompt} sx={s.outlinedGreen}>Sauvegarder comme modèle</Button>
            <Button variant="contained" onClick={handleSaveWeek} disabled={saving} sx={s.saveWeekBtn}>
                {saving ? "Enregistrement..." : "Enregistrer la semaine"}
            </Button>
        </Box>
    );
};

/**
 * MealPickerDialog – Modal for selecting meals per cell.
 */
const MealPickerDialog = ({ open, onClose, pickCategory, pickDayIndex, weeklyMeals, lunchOptions, snackOptions, toggleMealSelection, colors }) => {
    const s = getStyles(colors);
    const options = pickCategory === "lunch" ? lunchOptions : snackOptions;
    const currentDayMeals = weeklyMeals && pickDayIndex !== null ? (weeklyMeals[pickDayIndex]?.[pickCategory] || []) : [];

    return (
        <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm" PaperProps={{ sx: s.dialogPaper }}>
            <DialogTitle sx={s.dialogTitle}>
                {pickCategory === "lunch" ? "🍽️ Choisir les déjeuners" : "🍪 Choisir les goûters"} — {pickDayIndex !== null ? WEEKDAYS[pickDayIndex] : ""}
            </DialogTitle>
            <DialogContent sx={{ mt: 2, p: "24px" }}>
                <Box display="flex" flexDirection="column" gap="12px">
                    {options.map(mealName => {
                        const isSelected = currentDayMeals.includes(mealName);
                        return (
                            <Box key={mealName} sx={s.mealPickerRow(isSelected)} onClick={() => toggleMealSelection(mealName)}>
                                <Box sx={s.checkboxIcon(isSelected)}>
                                    {isSelected && <Typography color="#fff" fontSize="16px" fontWeight="bold">✓</Typography>}
                                </Box>
                                <Typography color={isSelected ? colors.greenAccent[400] : colors.grey[100]} fontWeight={isSelected ? "bold" : "500"} fontSize="1.05rem" sx={{ flexGrow: 1 }}>
                                    {mealName}
                                </Typography>
                            </Box>
                        );
                    })}
                    {options.length === 0 && (
                        <Box p="30px" textAlign="center" borderRadius="12px" backgroundColor="rgba(255,255,255,0.02)" border="1px dashed rgba(255,255,255,0.1)">
                            <Typography color={colors.grey[400]} fontSize="1rem">Aucun aliment disponible. Ajoutez-en dans "Gérer les Aliments".</Typography>
                        </Box>
                    )}
                </Box>
            </DialogContent>
            <DialogActions sx={{ p: 2, borderTop: `1px solid ${colors.primary[500]}` }}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Fermer</Button>
            </DialogActions>
        </Dialog>
    );
};

/**
 * SavedMenusDialog – Load/delete preset templates dialog.
 */
const SavedMenusDialog = ({ open, onClose, presets, onLoadPreset, onDeletePreset, colors }) => {
    const s = getStyles(colors);
    return (
        <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm" PaperProps={{ sx: s.dialogPaper }}>
            <DialogTitle sx={{ ...s.dialogTitle, display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '12px' }}>
                <Box display="flex" alignItems="center" gap="12px">
                    <Box sx={s.presetIconBox}>📚</Box>
                    <Box>
                        <Typography fontWeight="bold" fontSize="1.08rem">Modèles de menu enregistrés</Typography>
                        <Typography variant="body2" color={colors.grey[300]} mt="4px">Chargez ou supprimez un modèle depuis une fenêtre plus propre et plus dense.</Typography>
                    </Box>
                </Box>
                <IconButton onClick={onClose} sx={{ color: colors.grey[100] }}>
                    <CloseIcon />
                </IconButton>
            </DialogTitle>
            <DialogContent sx={{ mt: 2 }}>
                <Box sx={s.dialogContentCard}>
                {presets.length === 0 ? (
                    <Typography color={colors.grey[300]} textAlign="center" py="30px">Aucun modèle enregistré.</Typography>
                ) : (
                    <Box display="flex" flexDirection="column" gap="10px">
                        {presets.map(menu => (
                            <Box key={menu.id} sx={s.presetRow}>
                                <Box>
                                    <Typography fontWeight="bold" color={colors.grey[100]}>{menu.name}</Typography>
                                    <Typography variant="caption" color={colors.grey[400]}>Modèle réutilisable pour le planning hebdomadaire</Typography>
                                </Box>
                                <Box display="flex" gap="8px">
                                    <Button variant="contained" size="small" onClick={() => onLoadPreset(menu)}
                                        sx={s.presetLoadButton}>
                                        Charger
                                    </Button>
                                    <IconButton size="small" onClick={() => onDeletePreset(menu)} sx={s.presetDeleteButton}>
                                        <CloseIcon fontSize="small" />
                                    </IconButton>
                                </Box>
                            </Box>
                        ))}
                    </Box>
                )}
                </Box>
            </DialogContent>

            <DialogActions sx={s.dialogActions}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Fermer</Button>
            </DialogActions>
        </Dialog>
    );
};

/**
 * SavePresetDialog – Name and save a new preset dialog.
 */
const SavePresetDialog = ({ open, onClose, presetName, setPresetName, presetError, onSave, colors }) => {
    const s = getStyles(colors);
    return (
        <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm" PaperProps={{ sx: s.dialogPaper }}>
            <DialogTitle sx={{ ...s.dialogTitle, display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '12px' }}>
                <Box>
                    <Typography fontWeight="bold" fontSize="1.08rem">Sauvegarder comme modèle</Typography>
                    <Typography variant="body2" color={colors.grey[300]} mt="4px">Enregistrez cette semaine dans une fiche plus propre, comme sur les autres pages admin.</Typography>
                </Box>
                <IconButton onClick={onClose} sx={{ color: colors.grey[100] }}>
                    <CloseIcon />
                </IconButton>
            </DialogTitle>
            <DialogContent sx={{ mt: 2 }}>
                <Box sx={s.dialogContentCard}>
                    <Typography color={colors.grey[300]} mb="15px">Donnez un nom à ce modèle de menu :</Typography>
                    {presetError && <Typography color={colors.redAccent[400]} mb="12px">{presetError}</Typography>}
                    <TextField variant="outlined" label="Nom du modèle" value={presetName} onChange={(e) => setPresetName(e.target.value)} fullWidth autoFocus InputLabelProps={{ shrink: true }} sx={s.dialogField} />
                </Box>
            </DialogContent>
            <DialogActions sx={s.dialogActions}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
                <Button variant="contained" disabled={!presetName.trim()} onClick={onSave}
                    sx={s.saveWeekBtn}>
                    Sauvegarder
                </Button>
            </DialogActions>
        </Dialog>
    );
};


/**
 * WeekGrid – The main 5-row meal grid with exception columns.
 */
const WeekGrid = ({
    aiEnabled, weeklyMeals, weekStart, lunchOptions, snackOptions,
    dbExceptionsDejeuner, dbExceptionsGouter, openDropdown, setOpenDropdown,
    expandedChild, setExpandedChild, childMealOverrides, setChildMealOverrides,
    checkChildConflict, isExceptionResolved, toggleDropdown, toggleChildExpansion,
    openMealPicker, colors
}) => {
    const s = getStyles(colors);

    const renderExceptionColumn = (dayId, type, mainMeal) => {
        const allConflicts = [];
        const relevantExceptions = type === 'lunch' ? dbExceptionsDejeuner : dbExceptionsGouter;
        
        relevantExceptions.forEach(child => {
            const mealsArray = Array.isArray(mainMeal) ? mainMeal : [mainMeal];
            mealsArray.forEach(mealName => {
                if (mealName) {
                    const conflict = checkChildConflict(child, mealName);
                    if (conflict) allConflicts.push({ child, mealName, reason: conflict.reason });
                }
            });
        });

        const dropdownKey = `${dayId}-${type}`;
        const isOpen = openDropdown === dropdownKey;
        const conflictCount = allConflicts.length;

        if (conflictCount === 0) {
            return (
                <Box display="flex" alignItems="center" gap="8px" p="10px" color={colors.grey[300]}>
                    <Typography>✓ 0 exceptions</Typography>
                </Box>
            );
        }

        const resolvedCount = allConflicts.filter(c => isExceptionResolved(c.child.child_id, dayId, c.mealName)).length;
        const allResolved = resolvedCount === conflictCount;

        return (
            <Box position="relative">
                <Box sx={s.exceptionStatusBadge(allResolved)} onClick={() => toggleDropdown(dayId, type)}>
                    <Typography fontWeight="bold">
                        {allResolved ? `✅ ${conflictCount} résolue(s)` : `⚠️ ${conflictCount - resolvedCount}/${conflictCount} non résolue(s)`}
                        {' '}{isOpen ? '▲' : '▼'}
                    </Typography>
                </Box>

                {isOpen && (
                    <>
                        <Box position="fixed" top={0} left={0} right={0} bottom={0} zIndex={90} onClick={() => setOpenDropdown(null)} />
                        <Box position="absolute" top="100%" left={0} mt="8px" zIndex={100} minWidth="280px" sx={s.exceptionDropdown}>
                            {allConflicts.map((conflict, idx) => {
                                const { child, mealName, reason } = conflict;
                                const resolved = isExceptionResolved(child.child_id, dayId, mealName);
                                const overrideKey = `${child.child_id}-${dayId}-${mealName}`;
                                const overrideNames = childMealOverrides[overrideKey] || [];
                                const childKey = `${dayId}-${type}-${child.child_id}-${mealName}`;
                                const isExpanded = expandedChild === childKey;

                                return (
                                    <Box key={`${child.child_id}-${idx}`} sx={s.exceptionDropdownItem(resolved)}>
                                        <Box p="10px" sx={{ cursor: "pointer", "&:hover": { backgroundColor: colors.primary[500] } }}
                                            onClick={() => toggleChildExpansion(childKey)} display="flex" justifyContent="space-between" alignItems="center">
                                            <Box>
                                                <Typography fontWeight="bold" color={resolved ? colors.greenAccent[400] : colors.grey[100]}>
                                                    {resolved ? '✅ ' : '⚠️ '}{child.child_name}
                                                </Typography>
                                                {resolved && overrideNames.length > 0 && (
                                                    <Typography variant="caption" color={colors.greenAccent[500]}>
                                                        → {overrideNames.join(', ')}
                                                    </Typography>
                                                )}
                                                {!resolved && (
                                                    <Typography variant="caption" fontStyle="italic" color={colors.grey[400]}>
                                                        {mealName}
                                                    </Typography>
                                                )}
                                            </Box>
                                            <Typography color={resolved ? colors.greenAccent[500] : colors.redAccent[500]}>
                                                {isExpanded ? '▼' : (resolved ? '✓' : '⚠️')}
                                            </Typography>
                                        </Box>
                                        {isExpanded && (
                                            <Box sx={s.exceptionDropdownReason(resolved)}>
                                                {reason}
                                            </Box>
                                        )}
                                    </Box>
                                );
                            })}
                        </Box>
                    </>
                )}
            </Box>
        );
    };

    return (
        <Box sx={s.gridContainer}>
            {/* Header row */}
            <Box display="grid" gridTemplateColumns={aiEnabled ? "150px 1.5fr 1fr 1.5fr 1fr" : "150px 1fr 1fr"} sx={s.gridHeaderRow}>
                <Box p="16px" backgroundColor="#eef2f7"><Typography fontWeight="bold" color="#0f172a">Jour</Typography></Box>
                <Box p="16px" backgroundColor="#eef2f7"><Typography fontWeight="bold" color="#0f172a">Déjeuner</Typography></Box>
                {aiEnabled && <Box p="16px" backgroundColor="#eef2f7"><Typography fontWeight="bold" color="#0f172a">Exceptions</Typography></Box>}
                <Box p="16px" backgroundColor="#eef2f7"><Typography fontWeight="bold" color="#0f172a">Goûter</Typography></Box>
                {aiEnabled && <Box p="16px" backgroundColor="#eef2f7"><Typography fontWeight="bold" color="#0f172a">Exceptions</Typography></Box>}
            </Box>

            {/* Day Rows */}
            {weeklyMeals.map((day, i) => {
                const d = new Date(weekStart);
                d.setDate(d.getDate() + i);
                return (
                    <Box key={i} display="grid" gridTemplateColumns={aiEnabled ? "150px 1.5fr 1fr 1.5fr 1fr" : "150px 1fr 1fr"} sx={s.gridDayRow}>
                        {/* Day Name */}
                        <Box sx={s.gridCellLeft}>
                            <Box>
                                <Typography fontWeight="bold" color={colors.grey[100]}>{day.day}</Typography>
                                <Typography variant="caption" color={colors.grey[400]}>{d.getDate()}/{d.getMonth() + 1}</Typography>
                            </Box>
                        </Box>

                        {/* Lunch Cell */}
                        <Box sx={s.gridCellClickable} onClick={() => openMealPicker(i, "lunch")}>
                            {day.lunch.length > 0 ? (
                                day.lunch.map((name, j) => (<Chip key={j} label={name} size="small" sx={s.lunchChip} />))
                            ) : (
                                <Typography color={colors.grey[500]} fontSize="0.8rem" fontStyle="italic" mt="5px">Cliquer pour ajouter...</Typography>
                            )}
                        </Box>

                        {/* Lunch Exceptions */}
                        {aiEnabled && <Box sx={s.gridCellException}>{renderExceptionColumn(day.id, "lunch", day.lunch)}</Box>}

                        {/* Snack Cell */}
                        <Box sx={s.gridCellClickable} onClick={() => openMealPicker(i, "snack")}>
                            {day.snack.length > 0 ? (
                                day.snack.map((name, j) => (<Chip key={j} label={name} size="small" sx={s.snackChip} />))
                            ) : (
                                <Typography color={colors.grey[500]} fontSize="0.8rem" fontStyle="italic" mt="5px">Cliquer pour ajouter...</Typography>
                            )}
                        </Box>

                        {/* Snack Exceptions */}
                        {aiEnabled && <Box sx={s.gridCellBase}>{renderExceptionColumn(day.id, "snack", day.snack)}</Box>}
                    </Box>
                );
            })}
        </Box>
    );
};

/**
 * WeekConflictsTable – AI-driven exception summary table shown at the bottom.
 */
const WeekConflictsTable = ({
    weeklyMeals, dbExceptionsDejeuner, dbExceptionsGouter, checkChildConflict,
    lunchOptions, snackOptions, childMealOverrides, setChildMealOverrides, weekStart, allMeals, colors
}) => {
    const s = getStyles(colors);

    if (!weeklyMeals || (dbExceptionsDejeuner.length === 0 && dbExceptionsGouter.length === 0)) return null;
    const weekConflicts = [];
    weeklyMeals.forEach((day, dayIdx) => {
        (day.lunch || []).forEach(mealName => {
            dbExceptionsDejeuner.forEach(child => {
                const conflict = checkChildConflict(child, mealName);
                if (conflict) {
                    weekConflicts.push({
                        key: `${child.child_id}-${dayIdx}-${mealName}`, childId: child.child_id, childName: child.child_name,
                        child: child, className: child.class_name, problem: conflict.reason || child.dietary_comment || 'Exception',
                        currentMeal: mealName, dayName: WEEKDAYS[dayIdx], dayIdx,
                    });
                }
            });
        });
        (day.snack || []).forEach(mealName => {
            dbExceptionsGouter.forEach(child => {
                const conflict = checkChildConflict(child, mealName);
                if (conflict) {
                    weekConflicts.push({
                        key: `${child.child_id}-${dayIdx}-${mealName}`, childId: child.child_id, childName: child.child_name,
                        child: child, className: child.class_name, problem: conflict.reason || child.dietary_comment || 'Exception',
                        currentMeal: mealName, dayName: WEEKDAYS[dayIdx], dayIdx,
                    });
                }
            });
        });
    });

    if (weekConflicts.length === 0) return null;

    const handleOverrideChange = async (e, overrideKey, row, alternatives, currentOverrides) => {
        let selectedNames = e.target.value;
        if (selectedNames[selectedNames.length - 1] === "Aucun (Retirer ce plat)") {
            selectedNames = ["Aucun (Retirer ce plat)"];
        } else if (selectedNames.includes("Aucun (Retirer ce plat)") && selectedNames.length > 1) {
            selectedNames = selectedNames.filter(n => n !== "Aucun (Retirer ce plat)");
        }

        setChildMealOverrides(prev => ({ ...prev, [overrideKey]: selectedNames }));

        try {
            const norm = (str) => (str || '').toString().trim().toLowerCase();
            const originalMealName = norm(row.currentMeal);
            const originalMeal = allMeals.find(m => norm(m.name) === originalMealName);
            const replacementMealIds = selectedNames.map(name => {
                if (name === "Aucun (Retirer ce plat)") return null;
                const matchedMeal = allMeals.find(m => norm(m.name) === norm(name));
                return matchedMeal ? matchedMeal.id : undefined;
            }).filter(id => id !== undefined);

            if (originalMeal) {
                await api.post('/admin/child-food-exception-overrides', {
                    child_id: row.childId,
                    original_meal_id: originalMeal.id,
                    replacement_meal_ids: replacementMealIds,
                    day_index: row.dayIdx,
                    week_start: formatDate(weekStart)
                });
            }
        } catch (err) { console.error("Failed to save override", err); }
    };

    return (
        <Box sx={s.conflictsContainer}>
            <Box display="flex" alignItems="center" gap="10px" mb="20px">
                <Typography variant="h5" fontWeight="bold" color={colors.grey[100]}>Enfants avec exceptions cette semaine ({weekConflicts.length})</Typography>
            </Box>

            <Box display="grid" gridTemplateColumns="1.2fr 0.8fr 1.2fr 1fr 1fr 1fr" gap="2px" mb="2px">
                {['Enfant', 'Classe', 'Problème', 'Jour', 'Repas actuel', 'Repas alternatif'].map(h => (
                    <Box key={h} sx={s.conflictsHeaderCell}>
                        <Typography fontWeight="bold" color="#0f172a" fontSize="0.8rem">{h}</Typography>
                    </Box>
                ))}
            </Box>

            {weekConflicts.map(row => {
                const overrideKey = row.key;
                const currentOverrides = childMealOverrides[overrideKey] || [];
                const isLunch = (lunchOptions || []).includes(row.currentMeal);
                const alternatives = isLunch ? lunchOptions : snackOptions;
                const isResolved = currentOverrides.length > 0;

                return (
                    <Box key={row.key} sx={s.conflictsRowGrid}>
                        <Box sx={s.conflictsCell(isResolved)}>
                            <Box sx={s.avatarBox(isResolved)}>
                                {isResolved ? '✓' : (row.childName || '?').charAt(0).toUpperCase()}
                            </Box>
                            <Typography fontWeight="bold" color={isResolved ? colors.greenAccent[400] : colors.grey[100]} fontSize="0.85rem">
                                {row.childName}
                            </Typography>
                        </Box>
                        <Box sx={s.conflictsCell(isResolved)}>
                            <Typography color={colors.grey[200]} fontSize="0.85rem">{row.className}</Typography>
                        </Box>
                        <Box sx={s.conflictsCell(isResolved)}>
                            <Typography color={isResolved ? colors.greenAccent[500] : colors.redAccent[400]} fontSize="0.8rem" fontStyle="italic">
                                {isResolved ? '✅ Résolu' : row.problem}
                            </Typography>
                        </Box>
                        <Box sx={s.conflictsCell(isResolved)}>
                            <Typography color={colors.grey[200]} fontSize="0.85rem">{row.dayName}</Typography>
                        </Box>
                        <Box sx={s.conflictsCell(isResolved)}>
                            <Chip label={row.currentMeal} size="small" sx={s.conflictCurrentMealChip(isResolved)} />
                        </Box>
                        <Box sx={s.conflictsSelectCell(isResolved)}>
                            <FormControl variant="filled" size="small" fullWidth>
                                <Select
                                    multiple value={currentOverrides}
                                    onChange={(e) => handleOverrideChange(e, overrideKey, row, alternatives, currentOverrides)}
                                    renderValue={(sel) => (
                                        <Box display="flex" flexWrap="wrap" gap="3px">
                                            {sel.map(name => (<Chip key={name} label={name} size="small" sx={s.overrideChip} />))}
                                        </Box>
                                    )}
                                    sx={s.overrideSelect} MenuProps={{ PaperProps: { sx: s.overrideSelectMenu } }}>
                                    {["Aucun (Retirer ce plat)", ...alternatives.filter(m => m !== row.currentMeal && !checkChildConflict(row.child, m))].map(m => {
                                        const isOverriden = currentOverrides.includes(m);
                                        return (
                                            <MenuItem key={m} value={m} sx={s.overrideMenuItem(isOverriden)}>
                                                <Box sx={s.overrideMenuCheckbox(isOverriden)}>
                                                    {isOverriden && <Typography color="#fff" fontSize="12px" fontWeight="bold">✓</Typography>}
                                                </Box>
                                                <Typography color={isOverriden ? colors.greenAccent[400] : colors.grey[100]} fontWeight={isOverriden ? "bold" : "normal"}>
                                                    {m}
                                                </Typography>
                                            </MenuItem>
                                        );
                                    })}
                                </Select>
                            </FormControl>
                        </Box>
                    </Box>
                );
            })}
        </Box>
    );
};

/* ═══════════════════════════════════════════════════════════
   Main Component & State Logic
   ═══════════════════════════════════════════════════════════ */

const MealsPlanning = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);

    const [weekStart, setWeekStart] = useState(() => getMonday(new Date()));
    const [weeklyMeals, setWeeklyMeals] = useState(null);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [aiEnabled, setAiEnabled] = useState(true);
    const [allMeals, setAllMeals] = useState([]);
    const [lunchOptions, setLunchOptions] = useState([]);
    const [snackOptions, setSnackOptions] = useState([]);
    const [dbExceptionsDejeuner, setDbExceptionsDejeuner] = useState([]);
    const [dbExceptionsGouter, setDbExceptionsGouter] = useState([]);
    const [openDropdown, setOpenDropdown] = useState(null);
    const [expandedChild, setExpandedChild] = useState(null);
    const [pickDialogOpen, setPickDialogOpen] = useState(false);
    const [pickDayIndex, setPickDayIndex] = useState(null);
    const [pickCategory, setPickCategory] = useState("lunch");
    const [presets, setPresets] = useState([]);
    const [showBlankSlate, setShowBlankSlate] = useState(false);
    const [savedMenusDialogOpen, setSavedMenusDialogOpen] = useState(false);
    const [presetNamePromptOpen, setPresetNamePromptOpen] = useState(false);
    const [presetName, setPresetName] = useState("");
    const [presetError, setPresetError] = useState("");
    const [loadExceptionOverrides] = useState(true);
    const [childMealOverrides, setChildMealOverrides] = useState({});
    const [plannings, setPlannings] = useState([]);
    const [selectedPlanningId, setSelectedPlanningId] = useState("");

    const weekDates = useMemo(() => WEEKDAYS.map((_, i) => {
        const d = new Date(weekStart); d.setDate(d.getDate() + i); return formatDate(d);
    }), [weekStart]);

    const activePlanning = useMemo(() => plannings.find(p => String(p.id) === String(selectedPlanningId)), [plannings, selectedPlanningId]);

    const navigationBounds = useMemo(() => {
        let isPrevDisabled = false, isNextDisabled = false;
        if (activePlanning) {
            const pStart = new Date(activePlanning.startDate || activePlanning.start_date);
            const pEnd = new Date(activePlanning.endDate || activePlanning.end_date);
            const weekStartMs = weekStart.getTime();
            const pStartMonday = getMonday(pStart).getTime();
            const pEndMonday = getMonday(pEnd).getTime();
            if (weekStartMs <= pStartMonday) isPrevDisabled = true;
            if (weekStartMs >= pEndMonday) isNextDisabled = true;
        }
        return { isPrevDisabled, isNextDisabled };
    }, [activePlanning, weekStart]);

    const mapApiWeekToGrid = useCallback((apiDays) => {
        const byDate = new Map((Array.isArray(apiDays) ? apiDays : []).map(row => [row?.date, row]));
        return WEEKDAYS.map((dayName, index) => {
            const d = new Date(weekStart); d.setDate(d.getDate() + index);
            const isoDate = formatDate(d);
            const apiDay = byDate.get(isoDate);
            const plans = Array.isArray(apiDay?.plans) ? apiDay.plans : [];
            const planMeals = plans.flatMap(plan => (Array.isArray(plan?.meals) ? plan.meals : []));
            return {
                id: index, date: isoDate, day: dayName,
                lunch: [...new Set(planMeals.filter(m => String(m?.category?.name || '').toLowerCase() === 'lunch').map(m => m?.name).filter(Boolean))],
                snack: [...new Set(planMeals.filter(m => isSnackCategory(m?.category?.name)).map(m => m?.name).filter(Boolean))],
            };
        });
    }, [weekStart]);

    const fetchMeals = useCallback(async () => {
        try {
            const response = await api.get("/admin/meals");
            const rows = Array.isArray(response.data?.data) ? response.data.data : [];
            setAllMeals(rows);
            setLunchOptions([...new Set(rows.filter(m => (m?.category?.name || '').toLowerCase() === 'lunch').map(m => String(m.name).trim()))]);
            setSnackOptions([...new Set(rows.filter(m => isSnackCategory(m?.category?.name)).map(m => String(m.name).trim()))]);
        } catch (e) { console.error("Failed to fetch meals", e); }
    }, []);

    const fetchExceptions = useCallback(async (planningId) => {
        try {
            const base = planningId ? `planning_id=${planningId}&` : '';
            const [resDej, resGou] = await Promise.all([
                api.get(`/admin/food-exceptions?${base}meal_type=dejeuner`),
                api.get(`/admin/food-exceptions?${base}meal_type=gouter`),
            ]);
            setDbExceptionsDejeuner(Array.isArray(resDej?.data?.data) ? resDej.data.data : []);
            setDbExceptionsGouter(Array.isArray(resGou?.data?.data) ? resGou.data.data : []);
        } catch (e) {
            setDbExceptionsDejeuner([]); setDbExceptionsGouter([]);
        }
    }, []);

    const fetchWeekData = useCallback(async () => {
        try {
            setLoading(true);
            const dateStr = formatDate(weekStart);
            const response = await api.get(`/admin/meals/by-week/${dateStr}`);
            const data = response.data?.data || [];
            const rows = mapApiWeekToGrid(data);
            const hasMeals = rows.some(r => r.lunch.length > 0 || r.snack.length > 0);
            if (hasMeals) { setWeeklyMeals(rows); setShowBlankSlate(false); }
            else { setWeeklyMeals(null); setShowBlankSlate(true); }
        } catch (e) { setWeeklyMeals(null); setShowBlankSlate(true); }
        finally { setLoading(false); }
    }, [weekStart, mapApiWeekToGrid]);

    const fetchPresets = useCallback(async () => {
        try {
            const response = await api.get("/admin/menu-plannings");
            setPresets(response.data?.data || []);
        } catch (e) { console.error("Failed to fetch presets", e); }
    }, []);

    const fetchOverrides = useCallback(async () => {
        try {
            const dateStr = formatDate(weekStart);
            const response = await api.get(`/admin/child-food-exception-overrides?week_start=${dateStr}`);
            const overridesMap = {};
            (response.data?.data || []).forEach(ov => {
                const meal = allMeals.find(m => m.id === ov.original_meal_id);
                if (meal) {
                    const key = `${ov.child_id}-${ov.day_index}-${meal.name}`;
                    if (!overridesMap[key]) overridesMap[key] = [];
                    if (ov.replacement_meal_id === null) overridesMap[key].push("Aucun (Retirer ce plat)");
                    else {
                        const rep = allMeals.find(m => m.id === ov.replacement_meal_id);
                        if (rep) overridesMap[key].push(rep.name);
                    }
                }
            });
            setChildMealOverrides(overridesMap);
        } catch (e) { console.error("Failed to fetch overrides", e); }
    }, [weekStart, allMeals]);

    useEffect(() => {
        fetchMeals(); fetchPresets();
        api.get('/admin/plannings').then(res => {
            const list = res.data?.data || [];
            setPlannings(list);
            const t = new Date().toISOString().slice(0, 10);
            const c = list.find(p => (p.startDate || p.start_date) <= t && (p.endDate || p.end_date) >= t);
            if (c) setSelectedPlanningId(String(c.id)); else if (list.length > 0) setSelectedPlanningId(String(list[0].id));
        }).catch(() => setPlannings([]));
        api.get('/admin/parameters').then(res => {
            const arr = Array.isArray(res.data?.data) ? res.data.data : [];
            const ai = arr.find(p => p.name === 'ai_enabled');
            if (ai) setAiEnabled(ai.value === 'true' || ai.value === '1');
        }).catch(() => {});
    }, [fetchMeals, fetchPresets]);

    useEffect(() => { if (selectedPlanningId) fetchExceptions(selectedPlanningId); }, [selectedPlanningId, fetchExceptions]);
    useEffect(() => { fetchWeekData(); fetchOverrides(); }, [fetchWeekData, fetchOverrides]);
    useEffect(() => {
        if (activePlanning) {
            const pStart = new Date(activePlanning.startDate || activePlanning.start_date);
            const pEnd = new Date(activePlanning.endDate || activePlanning.end_date);
            const cur = weekStart.getTime();
            if (cur < getMonday(pStart).getTime()) setWeekStart(getMonday(pStart));
            else if (cur > getMonday(pEnd).getTime()) setWeekStart(getMonday(pEnd));
        }
    }, [activePlanning, weekStart]);

    const handleCreateFromScratch = () => {
        setWeeklyMeals(WEEKDAYS.map((day, i) => ({ id: i, date: weekDates[i], day, lunch: [], snack: [] })));
        setShowBlankSlate(false);
    };

    const toggleMealSelection = (mealName) => {
        if (!weeklyMeals || pickDayIndex === null) return;
        setWeeklyMeals(prev => prev.map((day, idx) => {
            if (idx !== pickDayIndex) return day;
            const list = [...(day[pickCategory] || [])];
            const i = list.indexOf(mealName);
            if (i >= 0) list.splice(i, 1); else list.push(mealName);
            return { ...day, [pickCategory]: list };
        }));
    };

    const handleSaveWeek = async () => {
        if (!weeklyMeals) return;
        setSaving(true);
        const mapIds = new Map(allMeals.map(m => [String(m?.name || '').trim().toLowerCase(), Number(m?.id)]));
        const missing = new Set();
        const days = weeklyMeals.map((day, i) => {
            const ids = [...new Set([...(day.lunch || []), ...(day.snack || [])].map(n => {
                const id = mapIds.get(n.toLowerCase());
                if (!id) missing.add(n); return id;
            }).filter(Boolean))];
            return { day_index: i, meal_ids: ids };
        });
        if (missing.size > 0) {
            alert(`Repas inconnus : ${Array.from(missing).join(', ')}`);
            setSaving(false); return;
        }
        try {
            await api.post("/admin/menu-plannings/apply-week", { week_start: formatDate(weekStart), days });
            await fetchWeekData();
        } catch (e) { alert(e?.response?.data?.message || "Erreur."); }
        finally { setSaving(false); }
    };

    const handleLoadPreset = async (menu) => {
        if (!window.confirm('Charger ce modèle pour la semaine actuelle ?')) return;
        try {
            const res = await api.get(`/admin/menu-plannings/${menu.id}`);
            const data = res?.data?.data;
            if (!data?.days) return;
            const daysPayload = Array.from({ length: 5 }).map((_, i) => ({
                day_index: i, meal_ids: Array.isArray(data.days.find(d => d.id === i + 1)?.meal_ids) ? data.days.find(d => d.id === i + 1).meal_ids : []
            }));
            await api.post('/admin/menu-plannings/apply-week', { week_start: formatDate(weekStart), days: daysPayload });
            if (loadExceptionOverrides && data.exception_overrides?.length > 0) {
                const overrides = data.exception_overrides.map(ov => ({
                    child_id: ov.child_id, original_meal_id: ov.original_meal_id,
                    replacement_meal_id: ov.replacement_meal_id, day_index: ov.day_index,
                    week_start: formatDate(weekStart)
                }));
                await api.post('/admin/child-food-exception-overrides', { overrides });
                await fetchOverrides();
            } else {
                // User chose NOT to load exceptions — clear local override state
                setChildMealOverrides({});
            }
            await fetchWeekData();
            setSavedMenusDialogOpen(false);
        } catch (e) { alert(e?.response?.data?.message || 'Échec.'); }
    };

    const handleDeletePreset = async (menu) => {
        if (!window.confirm('Supprimer ce modèle ?')) return;
        try { await api.delete(`/admin/menu-plannings/${menu.id}`); fetchPresets(); }
        catch (e) { alert(e?.response?.data?.message || 'Échec.'); }
    };

    const handleSavePreset = async () => {
        const normalizedPresetName = presetName.trim().toLowerCase();
        if (!normalizedPresetName || !weeklyMeals) return;
        const duplicatePreset = presets.find(menu => String(menu.name || '').trim().toLowerCase() === normalizedPresetName);
        if (duplicatePreset) {
            setPresetError("Un modèle avec ce nom existe déjà.");
            return;
        }
        const mapIds = new Map(allMeals.map(m => [String(m?.name || '').trim().toLowerCase(), Number(m?.id)]));
        const days = weeklyMeals.map((day, i) => {
            const ids = [...(day.lunch || []), ...(day.snack || [])].map(n => mapIds.get(n.toLowerCase())).filter(Boolean);
            return ids.length ? { day_index: i, meal_ids: ids } : null;
        }).filter(Boolean);
        if (!days.length) { alert('Aucun repas.'); return; }
        const overrides = [];
        Object.entries(childMealOverrides).forEach(([key, repNames]) => {
            const p = key.split('-'); const cid = parseInt(p[0]), didx = parseInt(p[1]), orig = allMeals.find(m => m.name === p.slice(2).join('-'));
            if (!orig || !Array.isArray(repNames)) return;
            repNames.forEach(rn => {
                if (rn === "Aucun (Retirer ce plat)") overrides.push({ child_id: cid, original_meal_id: orig.id, replacement_meal_id: null, day_index: didx });
                else {
                    const rm = allMeals.find(m => m.name === rn);
                    if (rm) overrides.push({ child_id: cid, original_meal_id: orig.id, replacement_meal_id: rm.id, day_index: didx });
                }
            });
        });
        try {
            await api.post('/admin/menu-plannings', { name: presetName.trim(), days, exception_overrides: overrides });
            setPresetError("");
            setPresetNamePromptOpen(false); fetchPresets();
        } catch (e) { alert(e?.response?.data?.message || 'Échec.'); }
    };

    const checkChildConflict = (child, mealData) => {
        if (!mealData || !child?.exceptions) return null;
        for (const mn of Array.isArray(mealData) ? mealData : [mealData]) {
            if (!mn) continue;
            const nm = mn.toLowerCase().trim();
            const m = child.exceptions.find(e => (e.meal_name || '').toLowerCase().trim() === nm);
            if (m) return m;
        }
        return null;
    };
    const isExceptionResolved = (cid, didx, mname) => Array.isArray(childMealOverrides[`${cid}-${didx}-${mname}`]) && childMealOverrides[`${cid}-${didx}-${mname}`].length > 0;

    return (
        <Box m="20px">
            <Header title="PLANNING DES REPAS" />

            {!aiEnabled && (
                <Box mb="15px" display="flex" alignItems="center" gap="10px" sx={getStyles(colors).aiDisabledBanner}>
                    <Typography fontSize="18px">⚠️</Typography>
                    <Typography color={colors.redAccent[400]} fontSize="0.85rem">
                        <strong>IA désactivée</strong> — Les colonnes d'exceptions alimentaires sont masquées.
                    </Typography>
                </Box>
            )}

            <StatsCards lunchCount={lunchOptions.length} snackCount={snackOptions.length} colors={colors} />
            <YearSelector plannings={plannings} selectedPlanningId={selectedPlanningId} setSelectedPlanningId={setSelectedPlanningId} colors={colors} />
            <WeekNavigator weekStart={weekStart} weekEndDate={new Date(weekStart.getTime() + 4 * 86400000)} isCurrentWeek={getMonday(new Date()).getTime() === weekStart.getTime()}
                navigationBounds={navigationBounds} goToPreviousWeek={() => setWeekStart(new Date(weekStart.getTime() - 7 * 86400000))} goToNextWeek={() => setWeekStart(new Date(weekStart.getTime() + 7 * 86400000))} goToThisWeek={() => setWeekStart(getMonday(new Date()))} colors={colors} />

            {loading ? (
                <Box display="flex" justifyContent="center" p="40px"><CircularProgress sx={{ color: colors.greenAccent[500] }} /></Box>
            ) : showBlankSlate ? (
                <BlankSlate handleCreateFromScratch={handleCreateFromScratch} openSavedMenus={() => setSavedMenusDialogOpen(true)} colors={colors} />
            ) : weeklyMeals ? (
                <>
                    <WeekGrid aiEnabled={aiEnabled} weeklyMeals={weeklyMeals} weekStart={weekStart} lunchOptions={lunchOptions} snackOptions={snackOptions} dbExceptionsDejeuner={dbExceptionsDejeuner} dbExceptionsGouter={dbExceptionsGouter} openDropdown={openDropdown} setOpenDropdown={setOpenDropdown} expandedChild={expandedChild} setExpandedChild={setExpandedChild} childMealOverrides={childMealOverrides} setChildMealOverrides={setChildMealOverrides} checkChildConflict={checkChildConflict} isExceptionResolved={isExceptionResolved} toggleDropdown={(d, t) => setOpenDropdown(prev => prev === `${d}-${t}` ? null : `${d}-${t}`)} toggleChildExpansion={(k) => setExpandedChild(prev => prev === k ? null : k)} openMealPicker={(d, c) => { setPickDayIndex(d); setPickCategory(c); setPickDialogOpen(true); }} colors={colors} />
                    <ActionButtons openSavedMenus={() => setSavedMenusDialogOpen(true)} openPresetPrompt={() => { setPresetName(""); setPresetError(""); setPresetNamePromptOpen(true); }} handleSaveWeek={handleSaveWeek} saving={saving} colors={colors} />
                    {aiEnabled && <WeekConflictsTable weeklyMeals={weeklyMeals} dbExceptionsDejeuner={dbExceptionsDejeuner} dbExceptionsGouter={dbExceptionsGouter} checkChildConflict={checkChildConflict} lunchOptions={lunchOptions} snackOptions={snackOptions} childMealOverrides={childMealOverrides} setChildMealOverrides={setChildMealOverrides} weekStart={weekStart} allMeals={allMeals} colors={colors} />}
                </>
            ) : null}

            <MealPickerDialog open={pickDialogOpen} onClose={() => setPickDialogOpen(false)} pickCategory={pickCategory} pickDayIndex={pickDayIndex} weeklyMeals={weeklyMeals} lunchOptions={lunchOptions} snackOptions={snackOptions} toggleMealSelection={toggleMealSelection} colors={colors} />
            <SavedMenusDialog open={savedMenusDialogOpen} onClose={() => setSavedMenusDialogOpen(false)} presets={presets} onLoadPreset={handleLoadPreset} onDeletePreset={handleDeletePreset} colors={colors} />
            <SavePresetDialog open={presetNamePromptOpen} onClose={() => { setPresetNamePromptOpen(false); setPresetError(""); }} presetName={presetName} setPresetName={setPresetName} presetError={presetError} onSave={handleSavePreset} colors={colors} />
        </Box>
    );
};

export default MealsPlanning;


/* ═══════════════════════════════════════════════════════════
   Styles Helper
   ═══════════════════════════════════════════════════════════ */
const getStyles = (colors) => ({
    statsGrid: { display: "grid", gridTemplateColumns: { xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }, gap: "14px", mb: "18px" },
    statCard: (accent) => ({ backgroundColor: colors.primary[400], display: "flex", alignItems: "center", justifyContent: "space-between", gap: "14px", p: "18px", borderRadius: "18px", border: `1px solid ${colors.primary[500]}`, borderLeft: `4px solid ${accent}`, boxShadow: "0px 12px 24px rgba(0,0,0,0.10)" }),
    statLabel: { fontSize: "0.8rem", letterSpacing: "0.04em", textTransform: "uppercase", color: colors.grey[400], marginBottom: "4px" },
    statValue: { fontSize: "1.5rem", fontWeight: 800, color: colors.grey[100], lineHeight: 1 },
    statIcon: (accent) => ({ width: 42, height: 42, borderRadius: "14px", display: "flex", alignItems: "center", justifyContent: "center", backgroundColor: `${accent}12`, border: `1px solid ${accent}28`, color: accent }),
    yearSelectorRow: { display: "flex", alignItems: { xs: "stretch", md: "center" }, justifyContent: "space-between", gap: "14px", flexDirection: { xs: "column", md: "row" }, mb: "18px", backgroundColor: colors.primary[400], borderRadius: "18px", p: "14px 18px", border: `1px solid ${colors.primary[500]}`, boxShadow: "0px 12px 24px rgba(0,0,0,0.10)" },
    toolbarLabel: { fontSize: "0.82rem", fontWeight: 700, color: colors.grey[300], whiteSpace: "nowrap" },
    selectControl: { minWidth: 210, "& .MuiOutlinedInput-root": { borderRadius: "12px", backgroundColor: colors.primary[400] } },
    weekNavRow: { display: "flex", alignItems: { xs: "stretch", md: "center" }, justifyContent: "space-between", mb: "20px", backgroundColor: colors.primary[400], borderRadius: "18px", p: "16px", border: `1px solid ${colors.primary[500]}`, boxShadow: "0px 12px 24px rgba(0,0,0,0.10)", gap: "12px", flexDirection: { xs: "column", md: "row" } },
    navButton: (disabled) => ({ color: disabled ? colors.grey[500] : colors.grey[100], fontWeight: 700, textTransform: "none", borderRadius: "999px", border: `1px solid ${colors.primary[500]}`, backgroundColor: colors.primary[500], px: "14px" }),
    todayButton: { color: colors.greenAccent[400], borderColor: colors.greenAccent[400], textTransform: "none", borderRadius: "999px", fontWeight: 700 },
    blankSlateBox: { display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", p: "60px", backgroundColor: colors.primary[400], borderRadius: "18px", boxShadow: "0px 12px 24px rgba(0,0,0,0.10)", border: `1px solid ${colors.primary[500]}` },
    createBtn: { ...getAdminPrimaryButtonSx() },
    loadBtn: { backgroundColor: colors.primary[500], color: "#fff", fontWeight: 700, textTransform: "none", borderRadius: "12px", "&:hover": { backgroundColor: colors.primary[600] } },
    outlinedBlue: { color: colors.grey[100], borderColor: colors.primary[500], fontWeight: 700, textTransform: "none", borderRadius: "12px", "&:hover": { borderColor: colors.blueAccent[300], backgroundColor: 'rgba(59,130,246,0.08)' } },
    outlinedGreen: { color: colors.grey[100], borderColor: colors.primary[500], fontWeight: 700, textTransform: "none", borderRadius: "12px", "&:hover": { borderColor: colors.greenAccent[300], backgroundColor: 'rgba(16,185,129,0.08)' } },
    saveWeekBtn: { ...getAdminPrimaryButtonSx({ px: "24px" }) },
    dialogPaper: { backgroundColor: colors.primary[400], color: colors.grey[100], borderRadius: "16px", boxShadow: "0px 8px 30px rgba(0,0,0,0.5)", overflow: "hidden" },
    dialogTitle: { fontWeight: "bold", borderBottom: `1px solid ${colors.primary[500]}`, fontSize: "1.1rem" },
    dialogActions: { p: 2, borderTop: `1px solid ${colors.primary[500]}` },
    dialogContentCard: { backgroundColor: colors.primary[500], border: `1px solid ${colors.primary[600]}`, borderRadius: "16px", padding: "18px", boxShadow: "0 12px 24px rgba(0,0,0,0.10)" },
    dialogField: { "& .MuiOutlinedInput-root": { borderRadius: "12px", backgroundColor: colors.primary[400] }, "& .MuiInputLabel-root": { color: colors.grey[300], fontWeight: 600 }, "& .MuiInputLabel-root.Mui-focused": { color: colors.greenAccent[400] }, "& .MuiInputBase-input": { color: colors.grey[100] } },
    aiDisabledBanner: { p: "12px", borderRadius: "14px", backgroundColor: "rgba(239,68,68,0.1)", border: "1px solid rgba(239,68,68,0.3)" },
    gridContainer: { backgroundColor: colors.primary[400], borderRadius: "18px", overflow: "visible", boxShadow: "0px 12px 24px rgba(0,0,0,0.10)", border: `1px solid ${colors.primary[500]}` },
    gridHeaderRow: { borderBottom: `2px solid ${colors.primary[500]}` },
    gridDayRow: { borderBottom: `1px solid ${colors.primary[500]}` },
    gridCellLeft: { p: "16px", display: "flex", alignItems: "center", borderRight: `1px solid ${colors.primary[500]}` },
    gridCellClickable: { p: "16px", display: "flex", flexWrap: "wrap", gap: "6px", borderRight: `1px solid ${colors.primary[500]}`, cursor: "pointer", "&:hover": { backgroundColor: colors.primary[500] }, minHeight: "88px" },
    gridCellException: { p: "16px", display: "flex", alignItems: "flex-start", borderRight: `2px solid ${colors.primary[500]}` },
    gridCellBase: { p: "16px", display: "flex", alignItems: "flex-start" },
    lunchChip: { backgroundColor: 'rgba(16,185,129,0.16)', color: colors.greenAccent[400], fontSize: "0.75rem", border: `1px solid rgba(16,185,129,0.24)` },
    snackChip: { backgroundColor: 'rgba(59,130,246,0.16)', color: colors.blueAccent[300], fontSize: "0.75rem", border: `1px solid rgba(59,130,246,0.24)` },
    exceptionStatusBadge: (allResolved) => ({ display: "flex", alignItems: "center", gap: "8px", p: "6px 12px", borderRadius: "6px", backgroundColor: allResolved ? 'rgba(16,185,129,0.15)' : 'rgba(239, 68, 68, 0.15)', color: allResolved ? colors.greenAccent[500] : colors.redAccent[500], cursor: "pointer", border: `1px solid ${allResolved ? colors.greenAccent[500] : colors.redAccent[500]}`, "&:hover": { opacity: 0.8 } }),
    exceptionDropdown: { backgroundColor: colors.primary[400], borderRadius: "8px", boxShadow: "0 10px 25px rgba(0,0,0,0.5)", border: `1px solid ${colors.primary[500]}` },
    exceptionDropdownItem: (resolved) => ({ display: "flex", flexDirection: "column", borderBottom: `1px solid ${colors.primary[500]}`, backgroundColor: resolved ? 'rgba(16,185,129,0.05)' : 'transparent' }),
    exceptionDropdownReason: (resolved) => ({ p: "8px 12px", backgroundColor: resolved ? 'rgba(16,185,129,0.1)' : 'rgba(239, 68, 68, 0.1)', color: resolved ? colors.greenAccent[400] : colors.redAccent[400], fontSize: "0.75rem" }),
    mealPickerRow: (isSelected) => ({ display: "flex", alignItems: "center", gap: "16px", p: "14px 20px", borderRadius: "12px", backgroundColor: isSelected ? `${colors.greenAccent[500]}15` : 'rgba(255,255,255,0.03)', border: `1px solid ${isSelected ? colors.greenAccent[500] : 'rgba(255,255,255,0.08)'}`, cursor: "pointer", transition: "all 0.3s cubic-bezier(0.4, 0, 0.2, 1)", backdropFilter: "blur(10px)", "&:hover": { backgroundColor: isSelected ? `${colors.greenAccent[500]}25` : 'rgba(255,255,255,0.08)', transform: "translateY(-2px)", boxShadow: isSelected ? `0 8px 16px ${colors.greenAccent[500]}30` : "0 8px 16px rgba(0,0,0,0.15)" } }),
    checkboxIcon: (isSelected) => ({ width: "24px", height: "24px", borderRadius: "6px", border: `2px solid ${isSelected ? colors.greenAccent[500] : colors.grey[500]}`, backgroundColor: isSelected ? colors.greenAccent[500] : "transparent", display: "flex", alignItems: "center", justifyContent: "center", transition: "all 0.2s ease-in-out", boxShadow: isSelected ? `0 0 10px ${colors.greenAccent[500]}80` : "none" }),
    presetIconBox: { width: 32, height: 32, borderRadius: '8px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '16px', background: `linear-gradient(135deg, ${colors.greenAccent[500]}, ${colors.greenAccent[700]})` },
    presetRow: { display: "flex", justifyContent: "space-between", alignItems: "center", gap: "12px", p: "14px 16px", borderRadius: "12px", backgroundColor: colors.primary[500], border: `1px solid ${colors.primary[600]}`, transition: 'all 0.2s', '&:hover': { backgroundColor: colors.primary[600] } },
    presetLoadButton: { backgroundColor: colors.primary[600], color: '#fff', textTransform: 'none', fontWeight: 700, borderRadius: '10px', '&:hover': { backgroundColor: colors.primary[700] } },
    presetDeleteButton: { width: 32, height: 32, borderRadius: '10px', border: `1px solid rgba(248,113,113,0.18)`, backgroundColor: 'rgba(127,29,29,0.18)', color: colors.redAccent[400], '&:hover': { backgroundColor: 'rgba(127,29,29,0.26)' } },
    presetToggleCard: { mt: '14px', p: '14px 16px', borderRadius: '14px', border: `1px solid ${colors.primary[600]}`, backgroundColor: colors.primary[500] },
    toggleButton: (active) => ({ textTransform: 'none', fontWeight: 700, borderRadius: '10px', px: '14px', py: '8px', color: active ? '#fff' : colors.grey[100], backgroundColor: active ? colors.greenAccent[600] : colors.primary[600], '&:hover': { backgroundColor: active ? colors.greenAccent[700] : colors.primary[700] } }),
    exceptionCheckboxRow: { px: "24px", py: "16px", display: "flex", alignItems: "center", gap: "12px", borderTop: `1px solid rgba(255,255,255,0.05)`, backgroundColor: "rgba(0,0,0,0.15)", cursor: "pointer", "&:hover .custom-checkbox": { borderColor: colors.greenAccent[400] } },
    customCheckbox: (checked) => ({ width: "22px", height: "22px", borderRadius: "6px", border: `2px solid ${checked ? colors.greenAccent[500] : colors.grey[500]}`, backgroundColor: checked ? colors.greenAccent[500] : "rgba(255,255,255,0.05)", display: "flex", alignItems: "center", justifyContent: "center", transition: "all 0.2s ease-in-out", boxShadow: checked ? `0 0 10px ${colors.greenAccent[500]}60` : "none" }),
    conflictsContainer: { mt: "30px", backgroundColor: colors.primary[400], borderRadius: "18px", p: "24px", boxShadow: "0px 12px 24px rgba(0,0,0,0.10)", border: `1px solid ${colors.primary[500]}` },
    conflictsHeaderCell: { p: "12px 16px", backgroundColor: "#eef2f7" },
    conflictsRowGrid: { display: "grid", gridTemplateColumns: "1.2fr 0.8fr 1.2fr 1fr 1fr 1fr", gap: "2px", mb: "1px" },
    conflictsCell: (isResolved) => ({ p: "12px 16px", backgroundColor: isResolved ? 'rgba(16,185,129,0.08)' : colors.primary[500], display: "flex", alignItems: "center", gap: "8px", transition: 'background 0.3s' }),
    conflictsSelectCell: (isResolved) => ({ p: "8px 16px", backgroundColor: isResolved ? 'rgba(16,185,129,0.08)' : colors.primary[500], display: "flex", alignItems: "center" }),
    avatarBox: (isResolved) => ({ width: "28px", height: "28px", borderRadius: "7px", display: "flex", alignItems: "center", justifyContent: "center", fontWeight: "bold", color: "#fff", fontSize: "12px", background: isResolved ? `linear-gradient(135deg, ${colors.greenAccent[500]}, ${colors.greenAccent[700]})` : `linear-gradient(135deg, ${colors.blueAccent[500]}, ${colors.blueAccent[700]})` }),
    conflictCurrentMealChip: (isResolved) => ({ backgroundColor: isResolved ? 'rgba(16,185,129,0.2)' : 'rgba(239,68,68,0.2)', color: isResolved ? colors.greenAccent[400] : colors.redAccent[400], fontWeight: 'bold', textDecoration: isResolved ? 'none' : 'line-through' }),
    overrideSelect: { fontSize: '0.85rem', '& .MuiSelect-select': { py: '8px' }, backgroundColor: 'rgba(255,255,255,0.03)', backdropFilter: 'blur(10px)', borderRadius: '8px', '&:hover': { backgroundColor: 'rgba(255,255,255,0.06)' } },
    overrideSelectMenu: { backgroundColor: colors.primary[400], backgroundImage: 'none', borderRadius: '12px', boxShadow: '0 8px 32px rgba(0,0,0,0.3)', p: 1 },
    overrideChip: { backgroundColor: colors.greenAccent[700], color: '#fff', fontSize: '0.7rem', height: '22px' },
    overrideMenuItem: (isOverriden) => ({ display: 'flex', alignItems: 'center', gap: '12px', borderRadius: '8px', my: '4px', transition: 'all 0.2s', backgroundColor: isOverriden ? `${colors.greenAccent[500]}15` : 'transparent', '&:hover': { backgroundColor: isOverriden ? `${colors.greenAccent[500]}25` : 'rgba(255,255,255,0.08)' } }),
    overrideMenuCheckbox: (isOverriden) => ({ width: "20px", height: "20px", borderRadius: "5px", flexShrink: 0, border: `2px solid ${isOverriden ? colors.greenAccent[500] : colors.grey[500]}`, backgroundColor: isOverriden ? colors.greenAccent[500] : "transparent", display: "flex", alignItems: "center", justifyContent: "center", transition: "all 0.2s ease-in-out" }),
});
