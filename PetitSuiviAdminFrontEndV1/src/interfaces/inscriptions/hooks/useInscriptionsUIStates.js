import { useState, useRef } from "react";

export const useInscriptionsUIStates = () => {
    const [loading, setLoading] = useState(true);
    const [inscriptionTab, setInscriptionTab] = useState("active");
    const [assignLoading, setAssignLoading] = useState(false);
    const [decisionLoading, setDecisionLoading] = useState(false);
    const [detailSaving, setDetailSaving] = useState(false);
    const [detailMealScanLoading, setDetailMealScanLoading] = useState(false);
    const [aiReviewMealScanLoading, setAiReviewMealScanLoading] = useState(false);
    const [aiReviewSaving, setAiReviewSaving] = useState(false);
    
    const [toast, setToast] = useState({ open: false, message: "", severity: "info" });
    const medicalDocRef = useRef(null);

    const showToast = (message, severity = "info") => setToast({ open: true, message, severity });
    const closeToast = (_, reason) => {
        if (reason === "clickaway") return;
        setToast((prev) => ({ ...prev, open: false }));
    };

    return {
        loading, setLoading,
        inscriptionTab, setInscriptionTab,
        assignLoading, setAssignLoading,
        decisionLoading, setDecisionLoading,
        detailSaving, setDetailSaving,
        detailMealScanLoading, setDetailMealScanLoading,
        aiReviewMealScanLoading, setAiReviewMealScanLoading,
        aiReviewSaving, setAiReviewSaving,
        toast, setToast,
        medicalDocRef,
        showToast, closeToast
    };
};
