import { applyWeekMenu, saveExceptionOverrides, loadMenuPlanning, deleteMenuPlanning, createMenuPlanning } from '../../api/scheduleService';
import { formatDate, WEEKDAYS } from '../../utils/scheduleHelpers';
import { useCallback } from 'react';

export const useScheduleActions = ({ ui, data }) => {
    const handleCreateFromScratch = () => {
        ui.setWeeklyMeals(WEEKDAYS.map((dayName, i) => ({ id: i, date: data.weekDates[i], day: dayName, lunch: [], snack: [] })));
        ui.setShowBlankSlate(false);
    };

    const toggleMealSelection = (mealName) => {
        if (!ui.weeklyMeals || ui.pickDayIndex === null) return;
        ui.setWeeklyMeals(prev => prev.map((day, idx) => {
            if (idx !== ui.pickDayIndex) return day;
            const list = [...(day[ui.pickCategory] || [])];
            const i = list.indexOf(mealName);
            if (i >= 0) list.splice(i, 1); else list.push(mealName);
            return { ...day, [ui.pickCategory]: list };
        }));
    };

    const handleSaveWeek = async () => {
        if (!ui.weeklyMeals) return;
        ui.setSaving(true);
        const mapIds = new Map(data.allMeals.map(m => [String(m?.name || '').trim().toLowerCase(), Number(m?.id)]));
        const missing = new Set();
        const days = ui.weeklyMeals.map((day, i) => {
            const ids = [...new Set([...(day.lunch || []), ...(day.snack || [])].map(n => {
                const id = mapIds.get(n.toLowerCase());
                if (!id) missing.add(n); return id;
            }).filter(Boolean))];
            return { day_index: i, meal_ids: ids };
        });
        if (missing.size > 0) {
            alert(`Repas inconnus : ${Array.from(missing).join(', ')}`);
            ui.setSaving(false); return;
        }
        try {
            await applyWeekMenu({ week_start: formatDate(ui.weekStart), days });
            await data.fetchWeekData();
        } catch (e) { alert(e?.response?.data?.message || "Erreur."); }
        finally { ui.setSaving(false); }
    };

    const handleLoadPresetLocal = async (menu) => {
        if (!window.confirm('Charger ce modèle pour la semaine actuelle ?')) return;
        try {
            const res = await loadMenuPlanning(menu.id);
            const mdata = res?.data?.data;
            if (!mdata?.days) return;
            const daysPayload = Array.from({ length: 5 }).map((_, i) => ({
                day_index: i, meal_ids: Array.isArray(mdata.days.find(d => d.id === i + 1)?.meal_ids) ? mdata.days.find(d => d.id === i + 1).meal_ids : []
            }));
            await applyWeekMenu({ week_start: formatDate(ui.weekStart), days: daysPayload });
            if (data.loadExceptionOverrides && mdata.exception_overrides?.length > 0) {
                const overrides = mdata.exception_overrides.map(ov => ({
                    child_id: ov.child_id, original_meal_id: ov.original_meal_id,
                    replacement_meal_id: ov.replacement_meal_id, day_index: ov.day_index,
                    week_start: formatDate(ui.weekStart)
                }));
                await saveExceptionOverrides({ overrides });
                await data.fetchOverrides();
            } else {
                ui.setChildMealOverrides({});
            }
            await data.fetchWeekData();
            ui.setSavedMenusDialogOpen(false);
        } catch (e) { alert(e?.response?.data?.message || 'Échec.'); }
    };

    const handleDeletePresetLocal = async (menu) => {
        if (!window.confirm('Supprimer ce modèle ?')) return;
        try { await deleteMenuPlanning(menu.id); data.fetchPresets(); }
        catch (e) { alert(e?.response?.data?.message || 'Échec.'); }
    };

    const handleSavePresetLocal = async () => {
        const normalizedPresetName = ui.presetName.trim().toLowerCase();
        if (!normalizedPresetName || !ui.weeklyMeals) return;
        const duplicatePreset = data.presets.find(menu => String(menu.name || '').trim().toLowerCase() === normalizedPresetName);
        if (duplicatePreset) { ui.setPresetError("Un modèle avec ce nom existe déjà."); return; }
        const mapIds = new Map(data.allMeals.map(m => [String(m?.name || '').trim().toLowerCase(), Number(m?.id)]));
        const days = ui.weeklyMeals.map((day, i) => {
            const ids = [...(day.lunch || []), ...(day.snack || [])].map(n => mapIds.get(n.toLowerCase())).filter(Boolean);
            return ids.length ? { day_index: i, meal_ids: ids } : null;
        }).filter(Boolean);
        if (!days.length) { alert('Aucun repas.'); return; }
        const overrides = [];
        Object.entries(ui.childMealOverrides).forEach(([key, repNames]) => {
            const p = key.split('-'); const cid = parseInt(p[0]), didx = parseInt(p[1]), orig = data.allMeals.find(m => m.name === p.slice(2).join('-'));
            if (!orig || !Array.isArray(repNames)) return;
            repNames.forEach(rn => {
                if (rn === "Aucun (Retirer ce plat)") overrides.push({ child_id: cid, original_meal_id: orig.id, replacement_meal_id: null, day_index: didx });
                else {
                    const rm = data.allMeals.find(m => m.name === rn);
                    if (rm) overrides.push({ child_id: cid, original_meal_id: orig.id, replacement_meal_id: rm.id, day_index: didx });
                }
            });
        });
        try {
            await createMenuPlanning({ name: ui.presetName.trim(), days, exception_overrides: overrides });
            ui.setPresetError(""); ui.setPresetNamePromptOpen(false); data.fetchPresets();
        } catch (e) { alert(e?.response?.data?.message || 'Échec.'); }
    };

    const checkChildConflict = useCallback((child, mealData) => {
        if (!mealData || !child?.exceptions) return null;
        for (const mn of Array.isArray(mealData) ? mealData : [mealData]) {
            if (!mn) continue;
            const nm = mn.toLowerCase().trim();
            const m = child.exceptions.find(e => (e.meal_name || '').toLowerCase().trim() === nm);
            if (m) return m;
        }
        return null;
    }, []);

    const isExceptionResolved = useCallback((cid, didx, mname) => Array.isArray(ui.childMealOverrides[`${cid}-${didx}-${mname}`]) && ui.childMealOverrides[`${cid}-${didx}-${mname}`].length > 0, [ui.childMealOverrides]);

    return {
        handleCreateFromScratch, toggleMealSelection, handleSaveWeek,
        handleLoadPresetLocal, handleDeletePresetLocal, handleSavePresetLocal,
        checkChildConflict, isExceptionResolved
    };
};
