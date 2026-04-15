import { useState, useMemo, useCallback, useEffect } from 'react';
import { getPlannings, getParameters, getMeals, getExceptionsByType, getWeekMeals, getMenuPlannings, getOverrides } from '../../api/scheduleService';
import { getMonday, WEEKDAYS, formatDate, isSnackCategory } from '../../utils/scheduleHelpers';

export const useScheduleData = ({ ui }) => {
    const { weekStart, setWeekStart, setWeeklyMeals, setShowBlankSlate, setChildMealOverrides } = ui;

    const [loading, setLoading] = useState(true);
    const [aiEnabled, setAiEnabled] = useState(true);
    const [allMeals, setAllMeals] = useState([]);
    const [lunchOptions, setLunchOptions] = useState([]);
    const [snackOptions, setSnackOptions] = useState([]);
    const [dbExceptionsDejeuner, setDbExceptionsDejeuner] = useState([]);
    const [dbExceptionsGouter, setDbExceptionsGouter] = useState([]);
    const [presets, setPresets] = useState([]);
    const [plannings, setPlannings] = useState([]);
    const [selectedPlanningId, setSelectedPlanningId] = useState("");
    const [loadExceptionOverrides] = useState(true);

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

    const fetchMealsData = useCallback(async () => {
        try {
            const response = await getMeals();
            const rows = Array.isArray(response.data?.data) ? response.data.data : [];
            setAllMeals(rows);
            setLunchOptions([...new Set(rows.filter(m => (m?.category?.name || '').toLowerCase() === 'lunch').map(m => String(m.name).trim()))]);
            setSnackOptions([...new Set(rows.filter(m => isSnackCategory(m?.category?.name)).map(m => String(m.name).trim()))]);
        } catch (e) { console.error("Failed to fetch meals", e); }
    }, []);

    const fetchExceptions = useCallback(async (planningId) => {
        try {
            const [resDej, resGou] = await Promise.all([
                getExceptionsByType('dejeuner', planningId),
                getExceptionsByType('gouter', planningId)
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
            const response = await getWeekMeals(dateStr);
            const data = response.data?.data || [];
            const rows = mapApiWeekToGrid(data);
            const hasMeals = rows.some(r => r.lunch.length > 0 || r.snack.length > 0);
            if (hasMeals) { setWeeklyMeals(rows); setShowBlankSlate(false); }
            else { setWeeklyMeals(null); setShowBlankSlate(true); }
        } catch (e) { setWeeklyMeals(null); setShowBlankSlate(true); }
        finally { setLoading(false); }
    }, [weekStart, mapApiWeekToGrid, setWeeklyMeals, setShowBlankSlate]);

    const fetchPresets = useCallback(async () => {
        try {
            const response = await getMenuPlannings();
            setPresets(response.data?.data || []);
        } catch (e) { console.error("Failed to fetch presets", e); }
    }, []);

    const fetchOverrides = useCallback(async () => {
        try {
            const dateStr = formatDate(weekStart);
            const response = await getOverrides(dateStr);
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
    }, [weekStart, allMeals, setChildMealOverrides]);

    useEffect(() => {
        fetchMealsData(); fetchPresets();
        getPlannings().then(res => {
            const list = res.data?.data || [];
            setPlannings(list);
            if (list.length > 0) {
                const sorted = [...list].sort((a, b) => {
                    const aYear = Number(a.startYear || a.start_year) || 0;
                    const bYear = Number(b.startYear || b.start_year) || 0;
                    return bYear - aYear;
                });
                setSelectedPlanningId(String(sorted[0].id));
            }
        }).catch(() => setPlannings([]));
        getParameters().then(res => {
            const arr = Array.isArray(res.data?.data) ? res.data.data : [];
            const ai = arr.find(p => p.name === 'ai_enabled');
            if (ai) setAiEnabled(ai.value === 'true' || ai.value === '1');
        }).catch(() => {});
    }, [fetchMealsData, fetchPresets]);

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
    }, [activePlanning, weekStart, setWeekStart]);

    return {
        loading, aiEnabled, allMeals, lunchOptions, snackOptions, dbExceptionsDejeuner, dbExceptionsGouter,
        presets, plannings, selectedPlanningId, setSelectedPlanningId, loadExceptionOverrides,
        weekDates, navigationBounds, fetchWeekData, fetchPresets, fetchOverrides
    };
};
