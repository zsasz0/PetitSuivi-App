import React from "react";
import { TextField } from "@mui/material";

export const DateSelectField = ({ addActivityForm, setAddActivityForm, setAddActivityError, isWeekendDate, styles, selectedPlanning }) => {
  const minDate = selectedPlanning?.start_date ? selectedPlanning.start_date.substring(0, 10) : undefined;
  const maxDate = selectedPlanning?.end_date ? selectedPlanning.end_date.substring(0, 10) : undefined;

  return (
  <TextField
    variant="outlined"
    label="Date"
    type="date"
    InputLabelProps={{ shrink: true }}
    inputProps={{ min: minDate, max: maxDate }}
    value={addActivityForm.date}
    onChange={(e) => {
      const nextDate = e.target.value;
      setAddActivityForm((f) => ({ ...f, date: nextDate }));
      
      let error = "";
      if (isWeekendDate(nextDate)) {
        error = "Les activités ne peuvent être planifiées que du lundi au vendredi.";
      } else if (minDate && maxDate && (nextDate < minDate || nextDate > maxDate)) {
        error = "La date doit être comprise dans la période du planning sélectionné.";
      }
      
      setAddActivityError(error);
    }}
    fullWidth
    required
    helperText={
      minDate && maxDate 
        ? `Plage autorisée : du ${minDate} au ${maxDate}. Uniquement en semaine.`
        : "Les activités sont autorisées uniquement du lundi au vendredi."
    }
    sx={styles.filledInputSx}
  />
  );
};
