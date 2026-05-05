import { useState, useEffect, useMemo } from 'react';
import { getPlannings, getParameters, getFoodExceptions } from '../../api/foodExceptionsService';

export const useManageExceptionsData = ({ ui }) => {
    const [children, setChildren] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [aiEnabled, setAiEnabled] = useState(true);
    const [plannings, setPlannings] = useState([]);
    const [selectedPlanningId, setSelectedPlanningId] = useState("");
    const [allChildren, setAllChildren] = useState([]);
    const [allMeals, setAllMeals] = useState([]);

    useEffect(() => {
        getPlannings().then(list => {
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

        getParameters().then(arr => {
            const aiParam = arr.find(p => p.name === "ai_enabled");
            if (aiParam) setAiEnabled(aiParam.value === "true" || aiParam.value === "1");
        }).catch(() => {});
    }, []);

    useEffect(() => {
        if (!selectedPlanningId) return;
        setLoading(true); setError("");
        getFoodExceptions(selectedPlanningId)
            .then(res => setChildren(res.data?.data || []))
            .catch(err => setError(err?.response?.data?.message || "Échec du chargement."))
            .finally(() => setLoading(false));
    }, [selectedPlanningId]);

    const filteredChildren = useMemo(() => {
        if (!ui.searchTerm) return children;
        const term = ui.searchTerm.toLowerCase();
        return children.filter(c => 
            (c.child_name || "").toLowerCase().includes(term) ||
            (c.class_name || "").toLowerCase().includes(term) ||
            (c.dietary_comment || "").toLowerCase().includes(term)
        );
    }, [children, ui.searchTerm]);

    return {
        children, setChildren,
        loading, error, aiEnabled, plannings,
        selectedPlanningId, setSelectedPlanningId,
        allChildren, setAllChildren,
        allMeals, setAllMeals,
        filteredChildren
    };
};
