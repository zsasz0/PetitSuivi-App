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
            setLunchOptions(rows.filter(m => (m?.category?.name || '').toLowerCase() === 'lunch').map(m => ({ id: m.id, name: m.name || '', type: 'lunch' })));
            setSnackOptions(rows.filter(m => {
                const cat = (m?.category?.name || '').toLowerCase();
                return cat === 'snack' || cat === 'snacks';
            }).map(m => ({ id: m.id, name: m.name || '', type: 'snack' })));

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
