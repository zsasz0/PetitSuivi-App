import { useUIStates } from "./useUIStates";
import { usePlanningData } from "./usePlanningData";
import { useActivityForms } from "./useActivityForms";

export const useActivitiesController = () => {
  const ui = useUIStates();
  const data = usePlanningData({
    dayTimelineInfo: ui.dayTimelineInfo,
    selectedClassForWeekId: ui.selectedClassForWeekId,
    setVisibleYear: ui.setVisibleYear,
  });
  const forms = useActivityForms({ ui, data });

  // Expose everything cleanly, without the static utility constants.
  return {
    ...ui,
    ...data,
    ...forms,
  };
};
