import { useUIStates } from "./useUIStates";
import { usePlanningsData } from "./usePlanningsData";
import { useParametersData } from "./useParametersData";

export const useParametersController = () => {
  const ui = useUIStates();
  const planningsData = usePlanningsData({ ui });
  const paramData = useParametersData({ ui, planningsData });

  return {
    state: {
      params: paramData.params,
      loading: ui.loading,
      saving: ui.saving,
      error: ui.error,
      success: ui.success,

      aiEnabled: paramData.aiEnabled,
      savingAi: ui.savingAi,
      inscriptionsOpen: paramData.inscriptionsOpen,
      savingInscriptions: ui.savingInscriptions,

      archiveConfirmOpen: ui.archiveConfirmOpen,
      archiveLoading: ui.archiveLoading,
      archiveResult: ui.archiveResult,
      archiveError: ui.archiveError,

      plannings: planningsData.plannings,
      selectedPlanningId: planningsData.selectedPlanningId,
      planningForm: planningsData.planningForm,
      savingPlanning: ui.savingPlanning,
      planningMessage: ui.planningMessage,
      selectedPlanning: planningsData.selectedPlanning,
      deletePlanningConfirmOpen: ui.deletePlanningConfirmOpen,

      toggleConfirm: ui.toggleConfirm,
      toast: ui.toast,
      visibleParams: paramData.visibleParams,
      groupedParams: paramData.groupedParams,
      hasParamValidationError: paramData.hasParamValidationError,
    },
    actions: {
      setArchiveConfirmOpen: ui.setArchiveConfirmOpen,
      setSelectedPlanningId: planningsData.setSelectedPlanningId,
      setPlanningForm: planningsData.setPlanningForm,
      closeToast: ui.closeToast,
      handleChange: paramData.handleChange,
      confirmToggle: ui.confirmToggle,
      closeToggleConfirm: ui.closeToggleConfirm,
      handleToggleAi: paramData.handleToggleAi,
      handleToggleInscriptions: paramData.handleToggleInscriptions,
      handleArchiveYear: planningsData.handleArchiveYear,
      handleSaveParams: paramData.handleSaveParams,
      handleSavePlanning: planningsData.handleSavePlanning,
      handleCreatePlanning: planningsData.handleCreatePlanning,
      requestRemovePlanning: planningsData.requestRemovePlanning,
      confirmRemovePlanning: planningsData.handleRemovePlanning,
      cancelRemovePlanning: () => ui.setDeletePlanningConfirmOpen(false),
    }
  };
};
