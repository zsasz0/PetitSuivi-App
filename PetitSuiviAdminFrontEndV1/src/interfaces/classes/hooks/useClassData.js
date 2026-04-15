import { useState, useCallback } from "react";
import {
    deleteClass,
    fetchClasses,
    fetchClassTypes,
    fetchPlannings,
    fetchTeachers,
    toggleArchiveClass,
} from "../api/classService";
import { getDefaultPlanning, mapPlanningFromApi } from "../utils/planningUtils";

export const useClassData = ({ ui, typeName, showToast }) => {
    const [classesList, setClassesList] = useState([]);
    const [teachersList, setTeachersList] = useState([]);
    const [plannings, setPlannings] = useState([]);
    const [typeId, setTypeId] = useState(null);
    const [selectedClass, setSelectedClass] = useState(null);

    const loadClassTypes = async () => {
        try {
            const types = await fetchClassTypes();
            const targetType = types.find((type) => (type.name || "").toLowerCase() === typeName.toLowerCase());
            if (targetType) setTypeId(targetType.id);
        } catch (error) {
            console.error("Failed to fetch class types", error);
        }
    };

    const loadPlannings = async () => {
        try {
            const data = await fetchPlannings();
            const rows = (Array.isArray(data) ? data : []).map(mapPlanningFromApi).sort((a, b) => b.startYear - a.startYear);
            setPlannings(rows);
            return rows;
        } catch (error) {
            console.error("Failed to fetch plannings", error);
            return [];
        }
    };

    const loadTeachers = async () => {
        try {
            const data = await fetchTeachers();
            setTeachersList(data);
        } catch (error) {
            console.error("Failed to fetch teachers", error);
        }
    };

    const loadClassesCustomLoad = async () => {
        const data = await fetchClasses();
        const filteredClasses = data.filter((classItem) => (classItem.type?.name || "").toLowerCase() === typeName.toLowerCase());
        const formatted = filteredClasses.map((classItem) => ({
            id: classItem.id,
            name: classItem.name || "",
            year: classItem.year || "-",
            capacity: classItem.capacity || 0,
            teachers: classItem.teachers || [],
            teacher_ids: (classItem.teachers || []).map((teacher) => String(teacher.cin || teacher.id)),
            students: classItem.students || [],
            studentsCount: (classItem.students || []).length,
            is_archived: !!classItem.is_archived,
        }));
        setClassesList(formatted);
    };

    const loadClasses = async () => {
        try {
            ui.setLoading(true);
            await loadClassesCustomLoad();
        } catch (error) {
            console.error("Failed to fetch classes", error);
        } finally {
            ui.setLoading(false);
        }
    };

    const loadData = useCallback((setAddFormData) => {
        ui.setLoading(true);

        // Fetch visual table data FIRST so it gets 100% of the backend resources
        loadClassesCustomLoad().finally(() => {
            ui.setLoading(false);

            // Once the table is fully painted and loaded, quietly fetch form prerequisites
            loadClassTypes();
            loadTeachers();
            loadPlannings().then((rows) => {
                const defaultPlanning = getDefaultPlanning(rows || [], new Date());
                if (defaultPlanning && setAddFormData) {
                    setAddFormData((prev) => ({ ...prev, year: defaultPlanning.label }));
                }
            });
        });
    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [typeName]);

    const handleDeleteClick = (classItem) => {
        ui.setActionMenuPosition(null);
        ui.setActionMenuClass(null);
        setSelectedClass(classItem);
        ui.setIsDeleteDialogOpen(true);
    };

    const handleDeleteConfirm = async () => {
        if (!selectedClass) return;

        try {
            await deleteClass(selectedClass.id);
            setClassesList((prev) => prev.filter((classItem) => classItem.id !== selectedClass.id));
            ui.setIsDeleteDialogOpen(false);
            setSelectedClass(null);
        } catch (error) {
            alert(error.response?.data?.message || "Erreur lors de la suppression.");
        }
    };

    const handleToggleArchiveClick = async (classItem) => {
        try {
            ui.closeActionMenu();
            await toggleArchiveClass(classItem.id);
            await loadClasses();
            if (!classItem.is_archived) {
                showToast("Archiver une classe la retire des listes actives. Pour la reutiliser, desarchivez-la.", "warning");
            } else {
                showToast("La classe a ete reactivee.", "success");
            }
        } catch (error) {
            alert(error.response?.data?.message || "Erreur lors de l'archivage.");
        }
    };

    return {
        classesList, setClassesList,
        teachersList, setTeachersList,
        plannings, setPlannings,
        typeId, setTypeId,
        selectedClass, setSelectedClass,
        loadData,
        loadClasses,
        handleDeleteClick,
        handleDeleteConfirm,
        handleToggleArchiveClick,
    };
};
