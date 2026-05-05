import { useState, useCallback, useEffect } from "react";
import { getTeachers, getClasses, getActivitiesByDate } from "../api/apiService";
import { computeTeacherActivity } from "../utils/calculations";

export const useTeacherData = () => {
    const [teachers, setTeachers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [activeTeacherCount, setActiveTeacherCount] = useState(0);

    const fetchTeacherData = useCallback(async () => {
        try {
            setLoading(true);
            const today = new Date();
            const todayKey = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;

            const [teachersResult, classesResult, activitiesResult] = await Promise.allSettled([
                getTeachers(), getClasses(), getActivitiesByDate(todayKey)
            ]);

            if (teachersResult.status === 'rejected') throw teachersResult.reason;
            
            const { formattedData, activeTodayCount } = computeTeacherActivity(
                teachersResult.value.data?.data || [], 
                classesResult, 
                activitiesResult
            );
            
            setActiveTeacherCount(activeTodayCount);
            setTeachers(formattedData);
        } catch (error) {
            console.error("Failed to fetch teachers", error);
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchTeacherData();
    }, [fetchTeacherData]);

    return { teachers, setTeachers, loading, activeTeacherCount, fetchTeacherData };
};
