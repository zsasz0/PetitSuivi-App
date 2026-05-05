import { useEffect, useState, useMemo } from "react";
import { getInscriptionsRequest, getClassesRequest, getAiEnabledStatus, toggleArchiveInscription } from "../api/inscriptionService";
import { formatDate, formatCurrency, mapTypeLabel, mapPaymentMethod } from "../utils/formatters";

export const useInscriptionsData = ({ ui }) => {
    const [inscriptionsList, setInscriptionsList] = useState([]);
    const [classesList, setClassesList] = useState([]);
    const [aiEnabled, setAiEnabled] = useState(true);

    useEffect(() => {
        fetchInscriptions();
        fetchAiEnabled();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    const fetchAiEnabled = async () => {
        try {
            const enabled = await getAiEnabledStatus();
            setAiEnabled(enabled);
            return enabled;
        } catch (error) {
            console.error("Failed to fetch AI status:", error);
            return aiEnabled;
        }
    };

    const fetchInscriptions = async () => {
        try {
            ui.setLoading(true);
            const data = await getInscriptionsRequest();
            setInscriptionsList(data);
        } catch (error) {
            console.error("Failed to fetch inscriptions", error);
        } finally {
            ui.setLoading(false);
        }
    };

    const loadClassesForAssign = async () => {
        try {
            const data = await getClassesRequest();
            setClassesList(data);
        } catch (error) {
            console.error("Failed to load classes", error);
        }
    };

    const mergedData = useMemo(() => (
        inscriptionsList.map((row) => {
            const inscriptionDate = row?.inscription_date || "";
            const parsedYear = inscriptionDate ? String(new Date(inscriptionDate).getFullYear()) : "";
            return {
                id: row?.id,
                inscriptionId: row?.id,
                childId: row?.child_id,
                name: row?.child_full_name || "Inconnu",
                age: row?.age ?? "-",
                parent: row?.parent?.full_name || "-",
                rawInscriptionDate: inscriptionDate,
                inscriptionDate: formatDate(inscriptionDate),
                inscriptionYear: parsedYear,
                approval: row?.status?.name || "pending",
                classId: row?.class?.id || null,
                inscriptionClass: row?.class?.name || "",
                inscriptionTypeId: row?.preferred_type?.id || null,
                inscriptionType: mapTypeLabel(row?.preferred_type?.name || row?.class?.type || ""),
                paymentMethod: mapPaymentMethod(row?.payment_method),
                totalAmount: formatCurrency(row?.total_amount),
                medicalApplication: row?.medical_file || null,
                dietary_comment: row?.dietary_comment || "",
                health_comment: row?.health_comment || "",
                is_archived: !!row?.is_archived,
                previousInscriptions: row?.previous_inscriptions_count || 0,
                meal_plan_id: row?.meal_plan_id,
            };
        })
    ), [inscriptionsList]);

    const stats = useMemo(() => ({
        total: mergedData.length,
        approved: mergedData.filter((row) => row.approval === "approved").length,
        pending: mergedData.filter((row) => row.approval === "pending").length,
        rejected: mergedData.filter((row) => row.approval === "rejected").length,
        archived: mergedData.filter((row) => row.is_archived).length,
    }), [mergedData]);

    const activeRows = useMemo(() => mergedData.filter((row) => !row.is_archived), [mergedData]);
    const archivedRows = useMemo(() => mergedData.filter((row) => row.is_archived), [mergedData]);

    const handleToggleArchiveClick = async (inscription) => {
        ui.setDecisionLoading(true);
        try {
            await toggleArchiveInscription(inscription.inscriptionId);
            setInscriptionsList((prev) => prev.map((row) => (
                row.id === inscription.inscriptionId ? { ...row, is_archived: !row.is_archived } : row
            )));
            ui.showToast(inscription.is_archived ? "L'inscription a été désarchivée." : "L'inscription a été archivée.", inscription.is_archived ? "success" : "warning");
        } catch (error) {
            window.alert(error.response?.data?.message || "Erreur lors de l'archivage.");
        } finally {
            ui.setDecisionLoading(false);
        }
    };

    return {
        inscriptionsList, setInscriptionsList,
        classesList, setClassesList,
        aiEnabled, setAiEnabled,
        mergedData, stats, activeRows, archivedRows,
        fetchInscriptions, loadClassesForAssign, fetchAiEnabled,
        handleToggleArchiveClick
    };
};
