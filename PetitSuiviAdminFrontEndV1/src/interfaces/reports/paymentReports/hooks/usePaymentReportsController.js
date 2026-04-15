import { useState, useEffect } from "react";
import { paymentReportsService } from "../api/paymentReportsService";
import { getCurrentPlanningId } from "../utils/formatters";

/**
 * Controller hook for managing the state and business logic of the payment reports interface.
 */
export const usePaymentReportsController = () => {
  const [plannings, setPlannings] = useState([]);
  const [selectedPlanningId, setSelectedPlanningId] = useState("");
  const [reportData, setReportData] = useState(null);
  const [loading, setLoading] = useState(false);
  
  const [modalOpen, setModalOpen] = useState(false);
  const [modalMonth, setModalMonth] = useState("");
  const [modalData, setModalData] = useState(null);
  const [modalLoading, setModalLoading] = useState(false);

  useEffect(() => {
    const initPlannings = async () => {
      try {
        const planningList = await paymentReportsService.fetchPlannings();
        setPlannings(planningList);
        setSelectedPlanningId(getCurrentPlanningId(planningList));
      } catch (error) {
        console.error(error);
      }
    };

    initPlannings();
  }, []);

  useEffect(() => {
    if (!selectedPlanningId) return;

    const loadReport = async () => {
      setLoading(true);
      try {
        const data = await paymentReportsService.fetchReport(selectedPlanningId);
        setReportData(data);
      } catch (error) {
        console.error(error);
      } finally {
        setLoading(false);
      }
    };

    loadReport();
  }, [selectedPlanningId]);

  const handleMonthClick = async (payload) => {
    const month = payload?.month || payload?.activePayload?.[0]?.payload?.month;
    if (!month) return;

    setModalMonth(month);
    setModalOpen(true);
    setModalLoading(true);
    setModalData(null);

    try {
      const data = await paymentReportsService.fetchMonthDetails(selectedPlanningId, month);
      setModalData(data);
    } catch (error) {
      console.error(error);
    } finally {
      setModalLoading(false);
    }
  };

  return {
    plannings,
    selectedPlanningId,
    setSelectedPlanningId,
    reportData,
    loading,
    modalOpen,
    setModalOpen,
    modalMonth,
    modalData,
    modalLoading,
    handleMonthClick,
  };
};
