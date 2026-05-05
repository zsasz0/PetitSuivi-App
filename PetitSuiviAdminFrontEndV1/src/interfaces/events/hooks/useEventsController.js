import { useEventsUIStates } from "./useEventsUIStates";
import { useEventsData } from "./useEventsData";
import { useEventsForms } from "./useEventsForms";

export const useEventsController = () => {
  const ui = useEventsUIStates();
  const data = useEventsData({ ui });
  const forms = useEventsForms({ ui, data });

  return {
    ...ui,
    ...data,
    ...forms,
  };
};
