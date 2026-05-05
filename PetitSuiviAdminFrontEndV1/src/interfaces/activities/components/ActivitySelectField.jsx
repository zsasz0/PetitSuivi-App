import React from "react";
import { FormControl, InputLabel, Select, MenuItem, Box, Typography } from "@mui/material";

export const ActivitySelectField = ({ addActivityForm, setAddActivityForm, allActivities, colors, styles }) => (
  <FormControl variant="outlined" fullWidth sx={styles.filledInputSx}>
    <InputLabel shrink>Sélectionner une activité</InputLabel>
    <Select
      value={addActivityForm.activityId}
      onChange={(e) => setAddActivityForm((f) => ({ ...f, activityId: e.target.value }))}
      renderValue={(selectedId) => {
        const a = allActivities.find((act) => act.id === selectedId);
        return a ? a.title : "";
      }}
      label="Sélectionner une activité"
      MenuProps={{
        PaperProps: {
          sx: { backgroundColor: colors.primary[400], backgroundImage: "none", borderRadius: "12px", boxShadow: "0 8px 32px rgba(0,0,0,0.3)", p: 1 },
        },
      }}
    >
      {allActivities.map((a) => {
        const isSelected = addActivityForm.activityId === a.id;
        return (
          <MenuItem
            key={a.id}
            value={a.id}
            sx={{
              display: "flex", alignItems: "center", gap: "12px", borderRadius: "8px", my: "4px", transition: "all 0.2s",
              backgroundColor: isSelected ? `${colors.blueAccent[500]}15` : "transparent",
              "&:hover": { backgroundColor: isSelected ? `${colors.blueAccent[500]}25` : "rgba(255,255,255,0.08)" },
            }}
          >
            <Box
              sx={{
                width: "20px", height: "20px", borderRadius: "5px", flexShrink: 0,
                border: `2px solid ${isSelected ? colors.blueAccent[500] : colors.grey[500]}`,
                backgroundColor: isSelected ? colors.blueAccent[500] : "transparent",
                display: "flex", alignItems: "center", justifyContent: "center", transition: "all 0.2s ease-in-out",
              }}
            >
              {isSelected && <Typography color="#fff" fontSize="12px" fontWeight="bold">✓</Typography>}
            </Box>
            <Typography color={isSelected ? colors.blueAccent[400] : colors.grey[100]} fontWeight={isSelected ? "bold" : "normal"}>
              {a.title}
            </Typography>
          </MenuItem>
        );
      })}
    </Select>
  </FormControl>
);
