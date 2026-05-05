import { useState } from "react";
import { createClass, updateClass } from "../api/classService";
import { getDefaultPlanning } from "../utils/planningUtils";
import { validateClassForm } from "../../../utils/validation";

export const useClassForms = ({ ui, data, typeName }) => {
    const [addFormData, setAddFormData] = useState({ name: "", year: "", capacity: "", teacher_ids: [] });
    const [addFormError, setAddFormError] = useState("");
    const [addFormErrors, setAddFormErrors] = useState({});
    const [addSaving, setAddSaving] = useState(false);

    const [editFormData, setEditFormData] = useState({ name: "", year: "", capacity: "", teacher_ids: [] });
    const [editFormError, setEditFormError] = useState("");
    const [editFormErrors, setEditFormErrors] = useState({});
    const [editSaving, setEditSaving] = useState(false);

    const handleClassFormChange = (setter) => (event) => {
        const { name, value } = event.target;
        setter((prev) => ({ ...prev, [name]: value }));
    };

    const openAddDialog = () => {
        const defaultPlanning = getDefaultPlanning(data.plannings, new Date());
        setAddFormData({ name: "", year: defaultPlanning ? defaultPlanning.label : "", capacity: "", teacher_ids: [] });
        setAddFormError("");
        setAddFormErrors({});
        ui.setIsAddDialogOpen(true);
    };

    const handleAddSubmit = async (event) => {
        event.preventDefault();
        setAddFormError("");
        setAddFormErrors({});

        const validationErrs = validateClassForm(addFormData);
        if (Object.keys(validationErrs).length > 0) {
            setAddFormErrors(validationErrs);
            return;
        }

        if (!data.typeId) {
            setAddFormError(`Type '${typeName}' introuvable. Veuillez d'abord creer une classe de ce type.`);
            return;
        }

        setAddSaving(true);
        try {
            const selectedPlanning = data.plannings.find((planning) => planning.label === addFormData.year);
            const resolvedYear = selectedPlanning ? selectedPlanning.startYear : new Date().getFullYear();
            await createClass({
                name: addFormData.name.trim(),
                year: resolvedYear,
                capacity: Number(addFormData.capacity) || null,
                type_id: data.typeId,
                teacher_ids: addFormData.teacher_ids,
            });
            ui.setIsAddDialogOpen(false);
            data.loadClasses();
        } catch (error) {
            const validationErrors = error.response?.data?.errors;
            if (validationErrors) {
                const firstKey = Object.keys(validationErrors)[0];
                setAddFormError(validationErrors[firstKey][0]);
            } else {
                setAddFormError(error.response?.data?.message || "Erreur lors de l'ajout.");
            }
        } finally {
            setAddSaving(false);
        }
    };

    const handleEditClick = (classItem) => {
        data.setSelectedClass(classItem);
        const classYear = classItem.year !== "-" ? Number(classItem.year) : null;
        const matchedPlanning = classYear ? data.plannings.find((planning) => planning.startYear === classYear) : null;
        setEditFormData({
            name: classItem.name,
            year: matchedPlanning ? matchedPlanning.label : (classItem.year !== "-" ? String(classItem.year) : ""),
            capacity: classItem.capacity || "",
            teacher_ids: classItem.teacher_ids || [],
        });
        setEditFormError("");
        setEditFormErrors({});
        ui.setIsEditDialogOpen(true);
    };

    const handleEditSubmit = async (event) => {
        event.preventDefault();
        setEditFormError("");
        setEditFormErrors({});

        if (!data.selectedClass) return;

        const validationErrs = validateClassForm(editFormData);
        if (Object.keys(validationErrs).length > 0) {
            setEditFormErrors(validationErrs);
            return;
        }

        setEditSaving(true);
        try {
            const selectedPlanning = data.plannings.find((planning) => planning.label === editFormData.year);
            const resolvedYear = selectedPlanning
                ? selectedPlanning.startYear
                : (editFormData.year ? parseInt(String(editFormData.year).split("/")[0], 10) : new Date().getFullYear());
            await updateClass(data.selectedClass.id, {
                name: editFormData.name.trim(),
                year: resolvedYear,
                capacity: Number(editFormData.capacity) || null,
                teacher_ids: editFormData.teacher_ids,
            });
            ui.setIsEditDialogOpen(false);
            data.setSelectedClass(null);
            data.loadClasses();
        } catch (error) {
            const validationErrors = error.response?.data?.errors;
            if (validationErrors) {
                const firstKey = Object.keys(validationErrors)[0];
                setEditFormError(validationErrors[firstKey][0]);
            } else {
                setEditFormError(error.response?.data?.message || "Erreur lors de la modification.");
            }
        } finally {
            setEditSaving(false);
        }
    };

    return {
        addFormData, setAddFormData,
        addFormError, setAddFormError,
        addFormErrors, setAddFormErrors,
        addSaving, setAddSaving,
        editFormData, setEditFormData,
        editFormError, setEditFormError,
        editFormErrors, setEditFormErrors,
        editSaving, setEditSaving,
        handleClassFormChange,
        openAddDialog,
        handleAddSubmit,
        handleEditClick,
        handleEditSubmit,
    };
};
