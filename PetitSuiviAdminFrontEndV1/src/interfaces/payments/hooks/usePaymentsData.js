import { useState, useCallback, useMemo, useEffect } from "react";
import {
  getPaymentsRequest, getInscriptionsRequest, getParametersRequest, getPlanningsRequest, getDocumentSignatureRequest
} from "../api/paymentService";
import { mapStatusToUi, normalizePaymentMethod, normalizeTextForMatch } from "../utils/formatters";

export const usePaymentsData = ({ ui }) => {
  const { setLoading, setError } = ui;
  const [paymentsRows, setPaymentsRows] = useState([]);
  const [selectedYear, setSelectedYear] = useState("all");
  const [planningsList, setPlanningsList] = useState([]);
  const [companyParams, setCompanyParams] = useState({});
  const [signatureUrl, setSignatureUrl] = useState("");

  const loadPayments = useCallback(async () => {
    try {
      setLoading(true);
      setError("");
      const [paymentRows, inscriptionsRows, parametersRows, planningsRows, signatureData] =
        await Promise.all([
          getPaymentsRequest(),
          getInscriptionsRequest(),
          getParametersRequest(),
          getPlanningsRequest(),
          getDocumentSignatureRequest(),
        ]);

      const inscriptionByKey = new Map(inscriptionsRows.map((r) => [`${r?.id}-${r?.child_id}`, r]));
      const parametersByName = new Map(parametersRows.map((p) => [normalizeTextForMatch(p?.name), p?.value]));

      setCompanyParams({
        companyName: parametersByName.get("company_name") || "PETIT SUIVI",
        address: parametersByName.get("kindergarten_address") || "123 Avenue des Écoles, Tunis, Tunisie",
        phone: parametersByName.get("contact_phone") || "+216 71 123 456",
        email: parametersByName.get("contact_email") || "contact@petitsuivi.tn",
        directorName: parametersByName.get("director_name") || "mahmoud",
      });
      setSignatureUrl(signatureData?.url || "");

      const planningsByYear = new Map(planningsRows.map((p) => [Number(p?.start_year || p?.startYear), p]));
      const planningsById = new Map(planningsRows.map((p) => [String(p?.id), p]));

      const rows = paymentRows
        .filter((r) => (r?.inscription_status?.name || "").toLowerCase() === "approved")
        .map((row, idx) => {
          const key = `${row?.inscription_id}-${row?.child_id}`;
          const inscription = inscriptionByKey.get(key);
          const serverStatus = mapStatusToUi(row?.payment_status?.name);
          const totalAmount = Number(row?.amount || 0);
          const partialPayments = Array.isArray(row?.partial_payments) ? row.partial_payments : [];
          const partialPaid = partialPayments.reduce((s, tx) => s + Number(tx.value || 0), 0);
          const status = totalAmount > 0 && partialPaid >= totalAmount ? "paid" : partialPaid > 0 ? "partial" : serverStatus;
          const paidAmount = status === "paid" ? totalAmount : partialPaid;
          const payMethod = normalizePaymentMethod(row?.payment_method || inscription?.payment_method);
          const isOneShot = payMethod === "oneShot";
          const fraisAmount = row?.frais_inscription_amount !== null ? Number(row.frais_inscription_amount) : 0;
          let fraisSnapshot = row?.frais_inscription_snapshot !== null ? Number(row.frais_inscription_snapshot) : 0;
          const parentName = inscription?.parent?.full_name || "Inconnu";
          const parentCin = inscription?.parent?.cin;
          const mealPlan = row?.meal_plan || inscription?.meal_plan;

          let mealPlanCost = Number(row?.meal_plan_fee || inscription?.meal_plan_fee || 0);
          let baseFee = Number(row?.base_fee || inscription?.base_fee || 0);

          if (fraisSnapshot === 0) {
            const fraisParam = parametersByName.get("frais_inscription");
            if (fraisParam !== undefined && fraisParam !== null && !isNaN(Number(fraisParam))) {
              fraisSnapshot = Number(fraisParam);
            }
          }

          if (mealPlanCost === 0 && baseFee === 0 && mealPlan) {
            const costStr = parametersByName.get(normalizeTextForMatch(mealPlan));
            if (costStr !== undefined && costStr !== null && !isNaN(Number(costStr))) {
              mealPlanCost = Number(costStr);
            }
          }

          const classYear = Number(row?.class?.year || inscription?.class?.year || new Date(row?.inscription_date).getFullYear());
          const planning = planningsById.get(String(row?.class?.planning_id || "")) || planningsByYear.get(classYear);
          const planningStartYear = planning?.start_year || planning?.startYear || classYear;
          const planningEndYear = planning?.end_year || planning?.endYear || classYear + 1;
          const planningStartDate = row?.class?.planning_start || planning?.start_date || planning?.startDate || `${planningStartYear}-09-01`;
          const planningEndDate = row?.class?.planning_end || planning?.end_date || planning?.endDate || `${planningEndYear}-06-30`;
          const planningId = row?.class?.planning_id || planning?.id || null;

          return {
            id: `${row?.inscription_id}-${row?.child_id}-${idx}`,
            inscriptionId: row?.inscription_id,
            childId: row?.child_id,
            name: row?.child_full_name || "Inconnu",
            inscriptionDate: row?.inscription_date || "",
            paymentDate: row?.payment_date || "",
            className: row?.class?.name || inscription?.class?.name || "—",
            totalAmount, paidAmount, remaining: Math.max(totalAmount - paidAmount, 0),
            paymentMethod: payMethod, paymentMethodLabel: payMethod === "monthlyPartial" ? "Paiement Mensuel" : "Paiement Annuel",
            reachedTxLimit: isOneShot && partialPayments.length >= 1, paymentStatus: status,
            statusLabel: status === "paid" ? "Payé" : status === "partial" ? "Partiel" : "En attente",
            transactions: partialPayments, txCount: partialPayments.length,
            fraisAmount, fraisSnapshot, parentName, parentCin, mealPlan, mealPlanCost, baseFee,
            planningStartYear, planningEndYear, planningStartDate, planningEndDate, planningId,
          };
        });
      setPaymentsRows(rows);
      setPlanningsList(planningsRows);
      
      setPaymentsRows((currentRows) => {
          setSelectedYear((prevYear) => {
              if (prevYear === "all" && planningsRows.length > 0) {
                  const sorted = [...planningsRows].sort((a, b) => {
                      const aYear = Number(a.startYear || a.start_year) || 0;
                      const bYear = Number(b.startYear || b.start_year) || 0;
                      return bYear - aYear;
                  });
                  return sorted[0].id;
              }
              return prevYear;
          });
          return rows;
      });
    } catch (err) {
      setError(err?.response?.data?.message || "Échec du chargement.");
      setPaymentsRows([]);
      setSignatureUrl("");
    } finally {
      setLoading(false);
    }
  }, [setLoading, setError]);

  useEffect(() => {
    loadPayments();
  }, [loadPayments]);

  const filteredRows = useMemo(() => {
    if (selectedYear === "all") return paymentsRows;
    return paymentsRows.filter((r) => String(r.planningId) === String(selectedYear));
  }, [paymentsRows, selectedYear]);

  const stats = useMemo(() => ({
    paid: filteredRows.filter((r) => r.paymentStatus === "paid").length,
    partial: filteredRows.filter((r) => r.paymentStatus === "partial").length,
    pending: filteredRows.filter((r) => r.paymentStatus === "pending").length,
    monthly: filteredRows.filter((r) => r.paymentMethod === "monthlyPartial").length,
    annual: filteredRows.filter((r) => r.paymentMethod === "oneShot").length,
  }), [filteredRows]);

  const allTransactions = useMemo(() => {
    const txs = [];
    filteredRows.forEach((child) => {
      (child.transactions || []).forEach((tx) => {
        txs.push({
          id: tx.id || `${child.inscriptionId}-${tx.date}`, amount: Number(tx.value || 0),
          date: tx.date, childName: child.name, className: child.className, isFrais: false,
        });
      });
      if (child.fraisAmount > 0) {
        txs.push({
          id: `frais-${child.inscriptionId}`, amount: child.fraisAmount,
          date: child.inscriptionDate, childName: child.name, className: child.className, isFrais: true,
        });
      }
    });
    return txs.sort((a, b) => new Date(b.date) - new Date(a.date));
  }, [filteredRows]);

  return {
    paymentsRows, setPaymentsRows,
    selectedYear, setSelectedYear,
    planningsList, setPlanningsList,
    companyParams, setCompanyParams,
    signatureUrl, setSignatureUrl,
    loadPayments, filteredRows, stats, allTransactions,
  };
};
