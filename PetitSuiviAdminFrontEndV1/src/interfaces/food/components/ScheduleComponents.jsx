import React from "react";
import { Box, Typography, Button, IconButton, Dialog, DialogTitle, DialogContent, DialogActions, Chip, TextField, Select, MenuItem, FormControl } from "@mui/material";
import RestaurantMenuOutlinedIcon from "@mui/icons-material/RestaurantMenuOutlined";
import BakeryDiningOutlinedIcon from "@mui/icons-material/BakeryDiningOutlined";
import CloseIcon from "@mui/icons-material/Close";
import { formatDisplayDate } from "../utils/scheduleHelpers";

/* ═══════════════════════════════════════════════════════════
   StatsCards – Lunch / Snack item counts
   ═══════════════════════════════════════════════════════════ */
export const StatsCards = ({ lunchCount, snackCount, colors, styles }) => (
    <Box sx={styles.statsGrid}>
        {[
            { label: "Déjeuners disponibles", value: lunchCount, accent: colors.greenAccent[500], icon: <RestaurantMenuOutlinedIcon fontSize="small" /> },
            { label: "Goûters disponibles", value: snackCount, accent: colors.blueAccent[400], icon: <BakeryDiningOutlinedIcon fontSize="small" /> },
        ].map((item) => (
            <Box key={item.label} sx={styles.statCard(item.accent)}>
                <Box>
                    <Typography sx={styles.statLabel}>{item.label}</Typography>
                    <Typography sx={styles.statValue}>{item.value}</Typography>
                </Box>
                <Box sx={styles.statIcon(item.accent)}>{item.icon}</Box>
            </Box>
        ))}
    </Box>
);

/* ═══════════════════════════════════════════════════════════
   AiDisabledBanner
   ═══════════════════════════════════════════════════════════ */
export const AiDisabledBanner = ({ colors, styles }) => (
    <Box mb="15px" display="flex" alignItems="center" gap="10px" sx={styles.aiDisabledBanner}>
        <Typography fontSize="18px">⚠️</Typography>
        <Typography color={colors.redAccent[400]} fontSize="0.85rem">
            <strong>IA désactivée</strong> — Les colonnes d'exceptions alimentaires sont masquées.
        </Typography>
    </Box>
);

/* ═══════════════════════════════════════════════════════════
   YearSelector – Academic year planning dropdown
   ═══════════════════════════════════════════════════════════ */
export const YearSelector = ({ plannings, selectedPlanningId, setSelectedPlanningId, colors, styles }) => (
    <Box sx={styles.yearSelectorRow}>
        <Box display="flex" alignItems={{ xs: "stretch", sm: "center" }} gap="12px" flexDirection={{ xs: "column", sm: "row" }}>
            <Typography sx={styles.toolbarLabel}>Année scolaire</Typography>
            <FormControl variant="outlined" size="small" sx={styles.selectControl}>
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

/* ═══════════════════════════════════════════════════════════
   WeekNavigator – Previous/next/today week navigation bar
   ═══════════════════════════════════════════════════════════ */
export const WeekNavigator = ({ weekStart, weekEndDate, isCurrentWeek, navigationBounds, goToPreviousWeek, goToNextWeek, goToThisWeek, colors, styles }) => (
    <Box sx={styles.weekNavRow}>
        <Button onClick={goToPreviousWeek} disabled={navigationBounds.isPrevDisabled}
            sx={styles.navButton(navigationBounds.isPrevDisabled)}>
            ← Précédente
        </Button>
        <Box display="flex" alignItems="center" gap="16px">
            <Typography variant="h5" fontWeight="bold" color={colors.grey[100]} textAlign="center">
                {formatDisplayDate(weekStart)} — {formatDisplayDate(weekEndDate)}
            </Typography>
            {!isCurrentWeek && (
                <Button variant="outlined" size="small" onClick={goToThisWeek} sx={styles.todayButton}>
                    Aujourd'hui
                </Button>
            )}
        </Box>
        <Button onClick={goToNextWeek} disabled={navigationBounds.isNextDisabled}
            sx={styles.navButton(navigationBounds.isNextDisabled)}>
            Suivante →
        </Button>
    </Box>
);

/* ═══════════════════════════════════════════════════════════
   BlankSlate – Empty week prompt with create/load buttons
   ═══════════════════════════════════════════════════════════ */
export const BlankSlate = ({ handleCreateFromScratch, openSavedMenus, colors, styles }) => (
    <Box sx={styles.blankSlateBox}>
        <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mb="10px">Aucun plan pour cette semaine</Typography>
        <Typography color={colors.grey[300]} mb="20px">Créez un plan à partir de zéro ou chargez un menu enregistré.</Typography>
        <Box display="flex" gap="16px">
            <Button variant="contained" onClick={handleCreateFromScratch} sx={styles.createBtn}>Créer à partir de zéro</Button>
            <Button variant="contained" onClick={openSavedMenus} sx={styles.loadBtn}>Charger un modèle</Button>
        </Box>
    </Box>
);

/* ═══════════════════════════════════════════════════════════
   ActionButtons – Save/load/preset buttons below the grid
   ═══════════════════════════════════════════════════════════ */
export const ActionButtons = ({ openSavedMenus, openPresetPrompt, handleSaveWeek, saving, colors, styles }) => (
    <Box display="flex" justifyContent="flex-end" gap="12px" mt="20px">
        <Button variant="contained" onClick={openSavedMenus} sx={styles.outlinedBlue}>Charger un modèle</Button>
        <Button variant="contained" onClick={openPresetPrompt} sx={styles.outlinedGreen}>Sauvegarder comme modèle</Button>
        <Button variant="contained" onClick={handleSaveWeek} disabled={saving} sx={styles.saveWeekBtn}>
            {saving ? "Enregistrement..." : "Enregistrer la semaine"}
        </Button>
    </Box>
);

/* ═══════════════════════════════════════════════════════════
   WeekGrid – 5-row meal grid with AI exception columns
   ═══════════════════════════════════════════════════════════ */
export const WeekGrid = ({
    aiEnabled, weeklyMeals, weekStart,
    dbExceptionsDejeuner, dbExceptionsGouter,
    openDropdown, setOpenDropdown,
    expandedChild, setExpandedChild,
    childMealOverrides,
    checkChildConflict, isExceptionResolved,
    toggleDropdown, toggleChildExpansion,
    openMealPicker, colors, styles
}) => {
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
                <Box sx={styles.exceptionStatusBadge(allResolved)} onClick={() => toggleDropdown(dayId, type)}>
                    <Typography fontWeight="bold">
                        {allResolved ? `✅ ${conflictCount} résolue(s)` : `⚠️ ${conflictCount - resolvedCount}/${conflictCount} non résolue(s)`}
                        {' '}{isOpen ? '▲' : '▼'}
                    </Typography>
                </Box>

                {isOpen && (
                    <>
                        <Box position="fixed" top={0} left={0} right={0} bottom={0} zIndex={90} onClick={() => setOpenDropdown(null)} />
                        <Box position="absolute" top="100%" left={0} mt="8px" zIndex={100} minWidth="280px" sx={styles.exceptionDropdown}>
                            {allConflicts.map((conflict, idx) => {
                                const { child, mealName, reason } = conflict;
                                const resolved = isExceptionResolved(child.child_id, dayId, mealName);
                                const overrideKey = `${child.child_id}-${dayId}-${mealName}`;
                                const overrideNames = childMealOverrides[overrideKey] || [];
                                const childKey = `${dayId}-${type}-${child.child_id}-${mealName}`;
                                const isExpanded = expandedChild === childKey;

                                return (
                                    <Box key={`${child.child_id}-${idx}`} sx={styles.exceptionDropdownItem(resolved)}>
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
                                            <Box sx={styles.exceptionDropdownReason(resolved)}>
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
        <Box sx={styles.gridContainer}>
            {/* Header row */}
            <Box display="grid" gridTemplateColumns={aiEnabled ? "150px 1.5fr 1fr 1.5fr 1fr" : "150px 1fr 1fr"} sx={styles.gridHeaderRow}>
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
                    <Box key={i} display="grid" gridTemplateColumns={aiEnabled ? "150px 1.5fr 1fr 1.5fr 1fr" : "150px 1fr 1fr"} sx={styles.gridDayRow}>
                        {/* Day Name */}
                        <Box sx={styles.gridCellLeft}>
                            <Box>
                                <Typography fontWeight="bold" color={colors.grey[100]}>{day.day}</Typography>
                                <Typography variant="caption" color={colors.grey[400]}>{d.getDate()}/{d.getMonth() + 1}</Typography>
                            </Box>
                        </Box>

                        {/* Lunch Cell */}
                        <Box sx={styles.gridCellClickable} onClick={() => openMealPicker(i, "lunch")}>
                            {day.lunch.length > 0 ? (
                                day.lunch.map((name, j) => (<Chip key={j} label={name} size="small" sx={styles.lunchChip} />))
                            ) : (
                                <Typography color={colors.grey[500]} fontSize="0.8rem" fontStyle="italic" mt="5px">Cliquer pour ajouter...</Typography>
                            )}
                        </Box>

                        {/* Lunch Exceptions */}
                        {aiEnabled && <Box sx={styles.gridCellException}>{renderExceptionColumn(day.id, "lunch", day.lunch)}</Box>}

                        {/* Snack Cell */}
                        <Box sx={styles.gridCellClickable} onClick={() => openMealPicker(i, "snack")}>
                            {day.snack.length > 0 ? (
                                day.snack.map((name, j) => (<Chip key={j} label={name} size="small" sx={styles.snackChip} />))
                            ) : (
                                <Typography color={colors.grey[500]} fontSize="0.8rem" fontStyle="italic" mt="5px">Cliquer pour ajouter...</Typography>
                            )}
                        </Box>

                        {/* Snack Exceptions */}
                        {aiEnabled && <Box sx={styles.gridCellBase}>{renderExceptionColumn(day.id, "snack", day.snack)}</Box>}
                    </Box>
                );
            })}
        </Box>
    );
};

/* ═══════════════════════════════════════════════════════════
   WeekConflictsTable – AI-driven exception summary table
   ═══════════════════════════════════════════════════════════ */
export const WeekConflictsTable = ({
    weeklyMeals, dbExceptionsDejeuner, dbExceptionsGouter, checkChildConflict,
    lunchOptions, snackOptions, childMealOverrides, setChildMealOverrides, weekStart, allMeals, colors, styles,
    saveOverrideToApi
}) => {
    const WEEKDAYS = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];

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

    const handleOverrideChange = async (e, overrideKey, row, alternatives) => {
        let selectedNames = e.target.value;
        if (selectedNames[selectedNames.length - 1] === "Aucun (Retirer ce plat)") {
            selectedNames = ["Aucun (Retirer ce plat)"];
        } else if (selectedNames.includes("Aucun (Retirer ce plat)") && selectedNames.length > 1) {
            selectedNames = selectedNames.filter(n => n !== "Aucun (Retirer ce plat)");
        }

        setChildMealOverrides(prev => ({ ...prev, [overrideKey]: selectedNames }));

        if (saveOverrideToApi) {
            saveOverrideToApi(row, selectedNames);
        }
    };

    return (
        <Box sx={styles.conflictsContainer}>
            <Box display="flex" alignItems="center" gap="10px" mb="20px">
                <Typography variant="h5" fontWeight="bold" color={colors.grey[100]}>Enfants avec exceptions cette semaine ({weekConflicts.length})</Typography>
            </Box>

            <Box display="grid" gridTemplateColumns="1.2fr 0.8fr 1.2fr 1fr 1fr 1fr" gap="2px" mb="2px">
                {['Enfant', 'Classe', 'Problème', 'Jour', 'Repas actuel', 'Repas alternatif'].map(h => (
                    <Box key={h} sx={styles.conflictsHeaderCell}>
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
                    <Box key={row.key} sx={styles.conflictsRowGrid}>
                        <Box sx={styles.conflictsCell(isResolved)}>
                            <Box sx={styles.avatarBox(isResolved)}>
                                {isResolved ? '✓' : (row.childName || '?').charAt(0).toUpperCase()}
                            </Box>
                            <Typography fontWeight="bold" color={isResolved ? colors.greenAccent[400] : colors.grey[100]} fontSize="0.85rem">
                                {row.childName}
                            </Typography>
                        </Box>
                        <Box sx={styles.conflictsCell(isResolved)}>
                            <Typography color={colors.grey[200]} fontSize="0.85rem">{row.className}</Typography>
                        </Box>
                        <Box sx={styles.conflictsCell(isResolved)}>
                            <Typography color={isResolved ? colors.greenAccent[500] : colors.redAccent[400]} fontSize="0.8rem" fontStyle="italic">
                                {isResolved ? ' Résolu' : row.problem}
                            </Typography>
                        </Box>
                        <Box sx={styles.conflictsCell(isResolved)}>
                            <Typography color={colors.grey[200]} fontSize="0.85rem">{row.dayName}</Typography>
                        </Box>
                        <Box sx={styles.conflictsCell(isResolved)}>
                            <Chip label={row.currentMeal} size="small" sx={styles.conflictCurrentMealChip(isResolved)} />
                        </Box>
                        <Box sx={styles.conflictsSelectCell(isResolved)}>
                            <FormControl variant="filled" size="small" fullWidth>
                                <Select
                                    multiple value={currentOverrides}
                                    onChange={(e) => handleOverrideChange(e, overrideKey, row, alternatives)}
                                    renderValue={(sel) => (
                                        <Box display="flex" flexWrap="wrap" gap="3px">
                                            {sel.map(name => (<Chip key={name} label={name} size="small" sx={styles.overrideChip} />))}
                                        </Box>
                                    )}
                                    sx={styles.overrideSelect} MenuProps={{ PaperProps: { sx: styles.overrideSelectMenu } }}>
                                    {["Aucun (Retirer ce plat)", ...alternatives.filter(m => m !== row.currentMeal && !checkChildConflict(row.child, m))].map(m => {
                                        const isOverriden = currentOverrides.includes(m);
                                        return (
                                            <MenuItem key={m} value={m} sx={styles.overrideMenuItem(isOverriden)}>
                                                <Box sx={styles.overrideMenuCheckbox(isOverriden)}>
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
   MealPickerDialog – Modal for selecting meals per cell
   ═══════════════════════════════════════════════════════════ */
export const MealPickerDialog = ({ open, onClose, pickCategory, pickDayIndex, weeklyMeals, lunchOptions, snackOptions, toggleMealSelection, colors, styles }) => {
    const WEEKDAYS = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];
    const options = pickCategory === "lunch" ? lunchOptions : snackOptions;
    const currentDayMeals = weeklyMeals && pickDayIndex !== null ? (weeklyMeals[pickDayIndex]?.[pickCategory] || []) : [];

    return (
        <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm" PaperProps={{ sx: styles.dialogPaper }}>
            <DialogTitle sx={styles.dialogTitle}>
                {pickCategory === "lunch" ? "🍽️ Choisir les déjeuners" : "🍪 Choisir les goûters"} — {pickDayIndex !== null ? WEEKDAYS[pickDayIndex] : ""}
            </DialogTitle>
            <DialogContent sx={{ mt: 2, p: "24px" }}>
                <Box display="flex" flexDirection="column" gap="12px">
                    {options.map(mealName => {
                        const isSelected = currentDayMeals.includes(mealName);
                        return (
                            <Box key={mealName} sx={styles.mealPickerRow(isSelected)} onClick={() => toggleMealSelection(mealName)}>
                                <Box sx={styles.checkboxIcon(isSelected)}>
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

/* ═══════════════════════════════════════════════════════════
   SavedMenusDialog – Load/delete preset templates dialog
   ═══════════════════════════════════════════════════════════ */
export const SavedMenusDialog = ({ open, onClose, presets, onLoadPreset, onDeletePreset, colors, styles }) => (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={{ ...styles.dialogTitle, display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '12px' }}>
            <Box display="flex" alignItems="center" gap="12px">
                
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
            <Box sx={styles.dialogContentCard}>
                {presets.length === 0 ? (
                    <Typography color={colors.grey[300]} textAlign="center" py="30px">Aucun modèle enregistré.</Typography>
                ) : (
                    <Box display="flex" flexDirection="column" gap="10px">
                        {presets.map(menu => (
                            <Box key={menu.id} sx={styles.presetRow}>
                                <Box>
                                    <Typography fontWeight="bold" color={colors.grey[100]}>{menu.name}</Typography>
                                    <Typography variant="caption" color={colors.grey[400]}>Modèle réutilisable pour le planning hebdomadaire</Typography>
                                </Box>
                                <Box display="flex" gap="8px">
                                    <Button variant="contained" size="small" onClick={() => onLoadPreset(menu)}
                                        sx={styles.presetLoadButton}>
                                        Charger
                                    </Button>
                                    <IconButton size="small" onClick={() => onDeletePreset(menu)} sx={styles.presetDeleteButton}>
                                        <CloseIcon fontSize="small" />
                                    </IconButton>
                                </Box>
                            </Box>
                        ))}
                    </Box>
                )}
            </Box>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Fermer</Button>
        </DialogActions>
    </Dialog>
);

/* ═══════════════════════════════════════════════════════════
   SavePresetDialog – Name and save a new preset dialog
   ═══════════════════════════════════════════════════════════ */
export const SavePresetDialog = ({ open, onClose, presetName, setPresetName, presetError, onSave, colors, styles }) => (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={{ ...styles.dialogTitle, display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '12px' }}>
            <Box>
                <Typography fontWeight="bold" fontSize="1.08rem">Sauvegarder comme modèle</Typography>
                <Typography variant="body2" color={colors.grey[300]} mt="4px">Enregistrez cette semaine dans une fiche plus propre, comme sur les autres pages admin.</Typography>
            </Box>
            <IconButton onClick={onClose} sx={{ color: colors.grey[100] }}>
                <CloseIcon />
            </IconButton>
        </DialogTitle>
        <DialogContent sx={{ mt: 2 }}>
            <Box sx={styles.dialogContentCard}>
                <Typography color={colors.grey[300]} mb="15px">Donnez un nom à ce modèle de menu :</Typography>
                {presetError && <Typography color={colors.redAccent[400]} mb="12px">{presetError}</Typography>}
                <TextField variant="outlined" label="Nom du modèle" value={presetName} onChange={(e) => setPresetName(e.target.value)} fullWidth autoFocus InputLabelProps={{ shrink: true }} sx={styles.dialogField} />
            </Box>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
            <Button variant="contained" disabled={!presetName.trim()} onClick={onSave} sx={styles.saveWeekBtn}>
                Sauvegarder
            </Button>
        </DialogActions>
    </Dialog>
);
