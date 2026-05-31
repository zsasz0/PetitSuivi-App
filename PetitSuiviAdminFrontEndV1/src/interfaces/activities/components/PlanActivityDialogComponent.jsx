import React from "react";
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Typography,
  Box,
  Button,
  IconButton,
} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";

import { ActivitySelectField } from "./ActivitySelectField";
import { DateSelectField } from "./DateSelectField";
import { TimeRangeSelector } from "./TimeRangeSelector";
import { ClassMultipleSelectField } from "./ClassMultipleSelectField";

export const PlanActivityDialogComponent = (props) => {
  const {
    theme,
    colors,
    styles,
    modals,
    closeModal,
    addActivityForm,
    setAddActivityForm,
    addActivityError,
    setAddActivityError,
    addActivitySaving,
    handleAddActivity,
    allActivities,
    classOptions,
    isWeekendDate,
    selectedPlanning,
  } = props;

  return (
    <Dialog
      open={modals.plan}
      onClose={() => {
        closeModal("plan");
        setAddActivityError("");
      }}
      fullWidth
      maxWidth="sm"
      PaperProps={{ sx: styles.dialogPaper }}
    >
      <DialogTitle sx={{ ...styles.dialogTitle, display: "flex", alignItems: "center", justifyContent: "space-between", gap: "12px" }}>
        <Box>
          <Typography fontWeight="bold" fontSize="1.1rem">Planifier une activité</Typography>
          <Typography variant="body2" color={colors.grey[300]} mt="4px">
            Utilisez la même logique douce que dans les classes pour planifier proprement une activité.
          </Typography>
        </Box>
        <IconButton onClick={() => { closeModal("plan"); setAddActivityError(""); }} sx={{ color: colors.grey[100] }}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <DialogContent sx={{ mt: 2, px: 3 }}>
        {addActivityError && (
          <Typography color={colors.redAccent[500]} mb="15px" textAlign="center" p="10px" borderRadius="8px" backgroundColor="rgba(239,68,68,0.1)">
            {addActivityError}
          </Typography>
        )}
        <form id="plan-activity-form" onSubmit={handleAddActivity}>
          <Box sx={styles.formCard} display="flex" flexDirection="column" gap="20px" mt="10px">
            
            <ActivitySelectField 
              addActivityForm={addActivityForm} 
              setAddActivityForm={setAddActivityForm} 
              allActivities={allActivities} 
              colors={colors} 
              styles={styles} 
            />

            <DateSelectField 
              addActivityForm={addActivityForm} 
              setAddActivityForm={setAddActivityForm} 
              setAddActivityError={setAddActivityError} 
              isWeekendDate={isWeekendDate} 
              styles={styles} 
              selectedPlanning={selectedPlanning}
            />

            <TimeRangeSelector 
              addActivityForm={addActivityForm} 
              setAddActivityForm={setAddActivityForm} 
              theme={theme} 
              colors={colors} 
              styles={styles} 
            />

            <ClassMultipleSelectField 
              addActivityForm={addActivityForm} 
              setAddActivityForm={setAddActivityForm} 
              classOptions={classOptions} 
              theme={theme} 
              colors={colors} 
              styles={styles} 
            />
            
          </Box>
        </form>
      </DialogContent>
      <DialogActions sx={styles.dialogActions}>
        <Button onClick={() => { closeModal("plan"); setAddActivityError(""); }} sx={{ color: colors.grey[100] }}>Annuler</Button>
        <Button type="submit" form="plan-activity-form" variant="contained" disabled={addActivitySaving} sx={styles.primaryButton}>
          {addActivitySaving ? "Planification..." : "Planifier l'activité"}
        </Button>
      </DialogActions>
    </Dialog>
  );
};
