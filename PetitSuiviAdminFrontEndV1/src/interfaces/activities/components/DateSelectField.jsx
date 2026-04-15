import React from "react";
import { TextField } from "@mui/material";

export const DateSelectField = ({ addActivityForm, setAddActivityForm, setAddActivityError, isWeekendDate, styles }) => (
  <TextField
    variant="outlined"
    label="Date"
    type="date"
    InputLabelProps={{ shrink: true }}
    value={addActivityForm.date}
    onChange={(e) => {
      const nextDate = e.target.value;
      setAddActivityForm((f) => ({ ...f, date: nextDate }));
      if (isWeekendDate(nextDate)) {
        setAddActivityError("Les activités ne peuvent être planifiées que du lundi au vendredi.");
      } else {
        setAddActivityError("");
      }
    }}
    fullWidth
    required
    helperText="Les activités sont autorisées uniquement du lundi au vendredi."
    sx={styles.filledInputSx}
  />
);
