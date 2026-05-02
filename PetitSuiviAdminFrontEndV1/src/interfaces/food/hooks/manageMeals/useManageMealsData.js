import { useState, useCallback, useEffect } from 'react';
import { fetchMeals, fetchExceptionsForMeals, fetchParameters } from '../../api/foodItemsService';

export const useManageMealsData = () => {
    const [loading, setLoading] = useState(true);
    const [lunchOptions, setLunchOptions] = useState([]); 
    const [snackOptions, setSnackOptions] = useState([]); 
    const [scannedMealIds, setScannedMealIds] = useState(new Set()); 
    const [aiEnabled, setAiEnabled] = useState(true);

    const checkAiStatus = useCallback(async () => {
        try {
            const arr = await fetchParameters();
            const aiParam = arr.find(p => p.name === 'ai_enabled');
            if (aiParam) {
                const enabled = aiParam.value === 'true' || aiParam.value === '1';
                setAiEnabled(enabled);
                return enabled;
            }
        } catch { /* ignore */ }
        return aiEnabled;
    }, [aiEnabled]);

    const loadData = useCallback(async () => {
        try {
            setLoading(true);
            const rows = await fetchMeals();
            const mapMeal = (m, type) => ({
                id: m.id,
                name: m.name || '',
                type,
                isUsedInMenu: Boolean(m.is_used_in_menu),
                menuUsageCount: Number(m.menu_usage_count || 0),
                isUsedInException: Boolean(m.is_used_in_exception),
                exceptionUsageCount: Number(m.exception_usage_count || 0),
                isDeletable: Boolean(m.is_deletable),
            });

            setLunchOptions(rows.filter(m => (m?.category?.name || '').toLowerCase() === 'lunch').map(m => mapMeal(m, 'lunch')));
            setSnackOptions(rows.filter(m => {
                const cat = (m?.category?.name || '').toLowerCase();
                return cat === 'snack' || cat === 'snacks';
            }).map(m => mapMeal(m, 'snack')));

            try {
                const excData = await fetchExceptionsForMeals();
                const scannedIds = new Set();
                excData.forEach(child => {
                    (child.exceptions || []).forEach(exc => {
                        if (exc.meal_id) scannedIds.add(exc.meal_id);
                    });
                });
                setScannedMealIds(scannedIds);
            } catch { /* ignore */ }
        } catch (error) { console.error(error); } finally { setLoading(false); }
    }, []);

    useEffect(() => { loadData(); checkAiStatus(); }, [loadData, checkAiStatus]);

    return {
        loading, lunchOptions, snackOptions, scannedMealIds, aiEnabled,
        loadData, checkAiStatus
    };
};
