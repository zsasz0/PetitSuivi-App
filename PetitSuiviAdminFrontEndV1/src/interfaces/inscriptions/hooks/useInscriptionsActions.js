import { useState, useMemo, useEffect } from "react";
import {
    updateInscriptionStatus, fetchAiMealExceptionsScan,
    saveAiMealExceptions, updateAiComments, triggerMedicalRescan
} from "../api/inscriptionService";
import { isWithinPlanningMargin } from "../utils/formatters";

export const useInscriptionsActions = ({ ui, data }) => {
    const [detailInscriptionId, setDetailInscriptionId] = useState(null);
    const [assignTargetId, setAssignTargetId] = useState(null);
    const [selectedClassId, setSelectedClassId] = useState("");
    const [classAssignError, setClassAssignError] = useState("");

    const [detailDietary, setDetailDietary] = useState("");
    const [detailHealth, setDetailHealth] = useState("");
    const [detailMealExceptions, setDetailMealExceptions] = useState(null);
    const [detailAiEditMode, setDetailAiEditMode] = useState(false);

    const [aiReviewContext, setAiReviewContext] = useState(null);
    const [aiReviewDietary, setAiReviewDietary] = useState("");
    const [aiReviewHealth, setAiReviewHealth] = useState("");
    const [aiReviewMealExceptions, setAiReviewMealExceptions] = useState(null);

    const detailChild = useMemo(
        () => data.mergedData.find((row) => row.inscriptionId === detailInscriptionId) || null,
        [data.mergedData, detailInscriptionId]
    );

    const assignTargetChild = useMemo(
        () => data.mergedData.find((row) => row.inscriptionId === assignTargetId) || null,
        [data.mergedData, assignTargetId]
    );

    const { setDetailMealScanLoading } = ui;
    useEffect(() => {
        setDetailDietary(detailChild?.dietary_comment || "");
        setDetailHealth(detailChild?.health_comment || "");
        setDetailMealExceptions(null);
        setDetailMealScanLoading(false);
        setDetailAiEditMode(false);
    }, [detailChild?.inscriptionId, detailChild?.dietary_comment, detailChild?.health_comment, setDetailMealScanLoading]);

    const detailDirty = !!detailChild && (
        detailDietary !== (detailChild.dietary_comment || "") ||
        detailHealth !== (detailChild.health_comment || "")
    );

    const classOptionsForAssign = useMemo(() => {
        if (!assignTargetChild) return [];
        const preferredTypeId = assignTargetChild.inscriptionTypeId ? Number(assignTargetChild.inscriptionTypeId) : null;
        const currentClassId = assignTargetChild.classId ? Number(assignTargetChild.classId) : null;
        return data.classesList
            .filter((schoolClass) => {
                const isNotArchived = !schoolClass.is_archived;
                const isPlanningActive = !schoolClass.planning_is_archived;
                const matchesType = preferredTypeId === null || Number(schoolClass?.type?.id) === preferredTypeId;
                const matchesPlanningWindow = isWithinPlanningMargin(
                    assignTargetChild.rawInscriptionDate,
                    schoolClass.planning_start_date,
                    schoolClass.planning_end_date,
                );
                return isNotArchived && isPlanningActive && matchesType && matchesPlanningWindow;
            })
            .map((schoolClass) => ({
                id: schoolClass.id,
                name: schoolClass.name,
                enrolled: Array.isArray(schoolClass.students) ? schoolClass.students.length : 0,
                capacity: schoolClass.capacity == null ? null : Number(schoolClass.capacity),
                isFull: schoolClass.capacity != null && Number(schoolClass.capacity) >= 0 && Array.isArray(schoolClass.students) && schoolClass.students.length >= Number(schoolClass.capacity) && Number(schoolClass.id) !== currentClassId,
            }));
    }, [data.classesList, assignTargetChild]);

    const closeAiReviewDialog = () => {
        if (ui.aiReviewSaving) return;
        setAiReviewContext(null);
        setAiReviewDietary("");
        setAiReviewHealth("");
        setAiReviewMealExceptions(null);
        ui.setAiReviewMealScanLoading(false);
    };

    const toggleMealExceptionChecked = (setState, index, checked) => {
        setState((prev) => Array.isArray(prev)
            ? prev.map((exception, exceptionIndex) => (
                exceptionIndex === index ? { ...exception, checked } : exception
            ))
            : prev);
    };

    const handleUpdateStatusWrapper = async (child, nextStatus, classId = null) => {
        if (!child?.inscriptionId) return { success: false, message: "Inscription introuvable." };
        try {
            await updateInscriptionStatus(child, nextStatus, classId);
            return { success: true };
        } catch (error) {
            return { success: false, message: error?.response?.data?.message || "Échec de la mise à jour." };
        }
    };

    const openAssignDialog = async (child) => {
        setAssignTargetId(child.inscriptionId);
        setSelectedClassId(child.classId ? String(child.classId) : "");
        setClassAssignError("");
        await data.loadClassesForAssign();
    };

    const closeAssignDialog = () => {
        setAssignTargetId(null);
        setSelectedClassId("");
        setClassAssignError("");
    };

    const openDetailDialog = (row) => {
        setDetailInscriptionId(row.inscriptionId);
    };

    const closeDetailDialog = () => {
        if (ui.detailSaving || ui.decisionLoading) return;
        setDetailInscriptionId(null);
    };

    const handleSaveSummary = async () => {
        if (!detailChild?.childId) return;
        ui.setDetailSaving(true);
        try {
            await updateAiComments(detailChild.childId, detailDietary, detailHealth);
            await saveAiMealExceptions(detailChild.childId, detailMealExceptions);
            await data.fetchInscriptions();
            setDetailMealExceptions(null);
            setDetailAiEditMode(false);
            ui.showToast("La fiche IA a été sauvegardée.", "success");
        } catch (error) {
            window.alert(error?.response?.data?.message || "Erreur lors de la sauvegarde de la fiche.");
        } finally {
            ui.setDetailSaving(false);
        }
    };

    const handleDetailScanMeals = async () => {
        if (!detailChild?.childId) return;
        ui.setDetailMealScanLoading(true);
        try {
            const exceptions = await fetchAiMealExceptionsScan(detailChild.childId, detailDietary, detailHealth);
            setDetailMealExceptions(exceptions);
            if (exceptions.length === 0) {
                ui.showToast("Aucun repas problématique détecté pour cet enfant.", "success");
            }
        } catch (error) {
            ui.showToast(error?.response?.data?.message || error.message || "Erreur lors du scan des repas.", "error");
        } finally {
            ui.setDetailMealScanLoading(false);
        }
    };

    const handlePrintMedical = () => {
        if (!ui.medicalDocRef.current || !detailChild) return;

        const printableHtml = ui.medicalDocRef.current.innerHTML;
        const stylesHtml = Array.from(document.querySelectorAll('style, link[rel="stylesheet"]'))
            .map((node) => node.outerHTML)
            .join("\n");

        const printFrame = document.createElement("iframe");
        printFrame.style.position = "fixed";
        printFrame.style.left = "-2000px";
        printFrame.style.top = "0";
        printFrame.style.width = "1200px";
        printFrame.style.height = "1600px";
        printFrame.style.border = "0";
        printFrame.style.opacity = "0";
        printFrame.style.pointerEvents = "none";
        printFrame.setAttribute("aria-hidden", "true");
        document.body.appendChild(printFrame);

        const frameWindow = printFrame.contentWindow;
        if (!frameWindow) {
            printFrame.remove();
            window.alert("Impossible d'ouvrir l'impression.");
            return;
        }

        frameWindow.document.open();
        frameWindow.document.write(`
            <!DOCTYPE html>
            <html lang="fr">
                <head>
                    <meta charset="utf-8" />
                    <title></title>
                    ${stylesHtml}
                    <style>
                        html, body { margin: 0; padding: 0; background: #ffffff; width: 100%; }
                        body { padding: 16px; font-family: Tahoma, Arial, sans-serif; color: #000; }
                        .medical-print-shell { max-width: 1100px; margin: 0 auto; }
                        .medical-print-root, .medical-print-root * { visibility: visible !important; }
                        @media print {
                            body * { visibility: hidden; }
                            html, body { background: #ffffff !important; }
                            body { padding: 0; }
                            .medical-print-root, .medical-print-root * { visibility: visible !important; }
                            .medical-print-root { position: absolute; left: 0; top: 0; width: 100%; }
                            .medical-print-shell { max-width: none; margin: 0; }
                            .mf-cover, .mf-page { break-after: page; page-break-after: always; break-inside: avoid-page; page-break-inside: avoid; }
                            .mf-page:last-of-type, .mf-cover:last-of-type { break-after: auto; page-break-after: auto; }
                            .mf-sign-strip { display: grid !important; grid-template-columns: 1.1fr 0.9fr 1.1fr !important; gap: 20px !important; }
                        }
                        @page { size: A4 portrait; margin: 8mm; }
                    </style>
                </head>
                <body>
                    <div class="medical-print-root medical-print-shell">${printableHtml}</div>
                </body>
            </html>
        `);
        frameWindow.document.close();

        let didPrint = false;
        const cleanup = () => {
            window.removeEventListener("afterprint", cleanup);
            setTimeout(() => { printFrame.remove(); }, 100);
        };

        const runPrint = () => {
            if (didPrint) return;
            didPrint = true;
            window.addEventListener("afterprint", cleanup, { once: true });
            frameWindow.focus();
            frameWindow.print();
            setTimeout(cleanup, 1500);
        };

        printFrame.onload = () => setTimeout(runPrint, 350);
    };

    const handleApproveFromDialog = async (child) => {
        await openAssignDialog(child);
    };

    const clearAiComments = async (childId) => {
        if (!childId) return;
        await updateAiComments(childId, "", "");
    };

    const clearMealExceptions = async (childId) => {
        if (!childId) return;
        await saveAiMealExceptions(childId, []);
    };

    const handleRejectFromDialog = async (child) => {
        if (!window.confirm("Êtes-vous sûr de vouloir rejeter cette inscription ?")) return;
        ui.setDecisionLoading(true);
        try {
            const result = await handleUpdateStatusWrapper(child, "rejected");
            if (!result.success) {
                window.alert(result.message || "Échec.");
                return;
            }
            await clearAiComments(child.childId);
            await clearMealExceptions(child.childId);
            setDetailDietary("");
            setDetailHealth("");
            setDetailMealExceptions(null);
            await data.fetchInscriptions();
            ui.showToast("L'inscription a été rejetée.", "warning");
        } catch (error) {
            window.alert(error?.response?.data?.message || "Erreur lors de la réinitialisation de l'inscription.");
        } finally {
            ui.setDecisionLoading(false);
        }
    };

    const handleResetPending = async (child) => {
        ui.setDecisionLoading(true);
        try {
            const result = await handleUpdateStatusWrapper(child, "pending");
            if (!result.success) {
                window.alert(result.message || "Échec.");
                return;
            }
            await clearAiComments(child.childId);
            await clearMealExceptions(child.childId);
            setDetailDietary("");
            setDetailHealth("");
            setDetailMealExceptions(null);
            await data.fetchInscriptions();
            ui.showToast("L'inscription a été remise en attente.", "info");
        } catch (error) {
            window.alert(error?.response?.data?.message || "Erreur lors de la réinitialisation de l'inscription.");
        } finally {
            ui.setDecisionLoading(false);
        }
    };

    const runApprovalFlow = async (child, classId) => {
        const medicalForm = child.medicalApplication;
        const hasMedicalForm = medicalForm && typeof medicalForm === "object" && Object.keys(medicalForm).length > 0;
        let nextDietary = child.dietary_comment || "";
        let nextHealth = child.health_comment || "";
        const aiCurrentlyEnabled = await data.fetchAiEnabled();
        const isFreePlan = child.meal_plan_id === 4;

        if (aiCurrentlyEnabled && hasMedicalForm && child.childId) {
            if (isFreePlan) {
                // Automatically set the safe AI comments and immediately approve
                nextDietary = "✅ Aucune restriction alimentaire détectée.";
                nextHealth = "✅ Aucun problème de santé notable détecté.";
                try {
                    await updateAiComments(child.childId, nextDietary, nextHealth);
                    await saveAiMealExceptions(child.childId, []);
                } catch (e) {
                    console.error("Failed to auto-save default comments for free plan", e);
                }
            } else {
                try {
                    const response = await triggerMedicalRescan(child.childId);
                    nextDietary = response?.dietary_comment || "✅ Aucune restriction alimentaire détectée.";
                    nextHealth = response?.health_comment || "✅ Aucun problème de santé notable détecté.";

                    const mealExceptions = await fetchAiMealExceptionsScan(child.childId, nextDietary, nextHealth);
                    setAiReviewContext({ child, classId });
                    setAiReviewDietary(nextDietary);
                    setAiReviewHealth(nextHealth);
                    setAiReviewMealExceptions(mealExceptions);
                    return { success: true, reviewRequired: true };
                } catch (error) {
                    const message = error?.response?.data?.message || error.message || "Le service IA a échoué pendant l'approbation.";
                    const aiError = new Error(message);
                    aiError.code = "AI_APPROVAL_FAILED";
                    throw aiError;
                }
            }
        }

        const result = await handleUpdateStatusWrapper(child, "approved", classId);
        if (!result.success) {
            return result;
        }

        setDetailDietary(nextDietary);
        setDetailHealth(nextHealth);
        return { success: true, reviewRequired: false };
    };

    const handleAiReviewScanMeals = async () => {
        if (!aiReviewContext?.child?.childId) return;
        ui.setAiReviewMealScanLoading(true);
        try {
            const exceptions = await fetchAiMealExceptionsScan(aiReviewContext.child.childId, aiReviewDietary, aiReviewHealth);
            setAiReviewMealExceptions(exceptions);
            if (exceptions.length === 0) {
                ui.showToast("Aucun repas problématique détecté pour cet enfant.", "success");
            }
        } catch (error) {
            ui.showToast(error?.response?.data?.message || error.message || "Erreur lors du scan des repas.", "error");
        } finally {
            ui.setAiReviewMealScanLoading(false);
        }
    };

    const handleConfirmApprovalReview = async () => {
        if (!aiReviewContext?.child?.childId) return;
        ui.setAiReviewSaving(true);
        try {
            await updateAiComments(aiReviewContext.child.childId, aiReviewDietary, aiReviewHealth);
            await saveAiMealExceptions(aiReviewContext.child.childId, aiReviewMealExceptions);

            const result = await handleUpdateStatusWrapper(aiReviewContext.child, "approved", aiReviewContext.classId);
            if (!result.success) {
                ui.showToast(result.message || "Erreur lors de l'approbation.", "error");
                return;
            }

            await data.fetchInscriptions();
            closeAiReviewDialog();
            setDetailDietary(aiReviewDietary);
            setDetailHealth(aiReviewHealth);
            ui.showToast("L'inscription a été approuvée.", "success");
        } catch (error) {
            ui.showToast(error?.response?.data?.message || error.message || "Erreur lors de l'approbation.", "error");
        } finally {
            ui.setAiReviewSaving(false);
        }
    };

    const handleConfirmAssign = async () => {
        if (!assignTargetChild) return;
        if (!selectedClassId) {
            setClassAssignError("Veuillez sélectionner une classe.");
            return;
        }

        ui.setAssignLoading(true);
        try {
            const result = await runApprovalFlow(assignTargetChild, Number(selectedClassId));
            if (!result.success) {
                setClassAssignError(result.message || "Erreur lors de l'approbation.");
                return;
            }
            if (result.reviewRequired) {
                closeAssignDialog();
                ui.showToast("Analyse IA terminée. Vérifiez les repas à risque avant de confirmer.", "info");
                return;
            }
            await data.fetchInscriptions();
            closeAssignDialog();
            ui.showToast("L'inscription a été approuvée.", "success");
        } catch (error) {
            const errorMessage = error?.response?.data?.message || error.message || "Erreur lors du traitement.";
            if (error?.code === "AI_APPROVAL_FAILED") {
                ui.showToast(`${errorMessage} Pour bypass ce blocage, désactivez le paramètre IA dans l'interface Paramètres (mettre ai_enabled à false).`, "error");
                setClassAssignError("");
                return;
            }
            setClassAssignError(errorMessage);
        } finally {
            ui.setAssignLoading(false);
        }
    };

    return {
        detailInscriptionId, setDetailInscriptionId,
        assignTargetId, setAssignTargetId,
        selectedClassId, setSelectedClassId,
        classAssignError, setClassAssignError,
        detailDietary, setDetailDietary,
        detailHealth, setDetailHealth,
        detailMealExceptions, setDetailMealExceptions,
        detailAiEditMode, setDetailAiEditMode,
        aiReviewContext, setAiReviewContext,
        aiReviewDietary, setAiReviewDietary,
        aiReviewHealth, setAiReviewHealth,
        aiReviewMealExceptions, setAiReviewMealExceptions,
        
        detailChild, assignTargetChild, detailDirty, classOptionsForAssign,
        
        closeAiReviewDialog,
        toggleMealExceptionChecked,
        openAssignDialog,
        closeAssignDialog,
        openDetailDialog,
        closeDetailDialog,
        handleSaveSummary,
        handleDetailScanMeals,
        handlePrintMedical,
        handleApproveFromDialog,
        handleRejectFromDialog,
        handleResetPending,
        handleAiReviewScanMeals,
        handleConfirmApprovalReview,
        handleConfirmAssign,
    };
};
