import React from "react";
import { FormControl, InputLabel, Select, MenuItem, Box, Typography, Chip } from "@mui/material";

export const ClassMultipleSelectField = ({ addActivityForm, setAddActivityForm, classOptions, theme, colors, styles }) => (
  <FormControl variant="outlined" fullWidth sx={styles.filledInputSx}>
    <InputLabel shrink>Sélectionner les classes</InputLabel>
    <Select
      multiple
      value={addActivityForm.classIds}
      onChange={(e) => setAddActivityForm((f) => ({ ...f, classIds: e.target.value }))}
      renderValue={(sel) => (
        <Box display="flex" flexWrap="wrap" gap="4px">
          {sel.map((id) => {
            const c = classOptions.find((x) => x.id === id);
            return (
              <Chip
                key={id}
                label={c?.name || id}
                size="small"
                sx={{
                  backgroundColor: theme.palette.mode === "dark" ? "rgba(20, 184, 166, 0.14)" : "rgba(13, 148, 136, 0.10)",
                  color: colors.greenAccent[400],
                  border: `1px solid ${theme.palette.mode === "dark" ? "rgba(45, 212, 191, 0.16)" : "rgba(13, 148, 136, 0.16)"}`,
                  fontWeight: 700,
                }}
              />
            );
          })}
        </Box>
      )}
      label="Sélectionner les classes"
      MenuProps={{
        PaperProps: { sx: { backgroundColor: colors.primary[400], backgroundImage: "none", borderRadius: "12px", boxShadow: "0 8px 32px rgba(0,0,0,0.3)", p: 1 } },
      }}
    >
      {classOptions.map((c) => {
        const isSelected = addActivityForm.classIds.includes(c.id);
        return (
          <MenuItem
            key={c.id} value={c.id}
            sx={{
              display: "flex", alignItems: "center", gap: "12px", borderRadius: "8px", my: "4px", transition: "all 0.2s",
              backgroundColor: isSelected ? `${colors.blueAccent[500]}15` : "transparent",
              "&:hover": { backgroundColor: isSelected ? `${colors.blueAccent[500]}25` : "rgba(255,255,255,0.08)" },
            }}
          >
            <Box sx={{
              width: "20px", height: "20px", borderRadius: "5px", flexShrink: 0,
              border: `2px solid ${isSelected ? colors.blueAccent[500] : colors.grey[500]}`,
              backgroundColor: isSelected ? colors.blueAccent[500] : "transparent",
              display: "flex", alignItems: "center", justifyContent: "center", transition: "all 0.2s ease-in-out",
            }}>
              {isSelected && <Typography color="#fff" fontSize="12px" fontWeight="bold">✓</Typography>}
            </Box>
            <Typography color={isSelected ? colors.blueAccent[400] : colors.grey[100]} fontWeight={isSelected ? "bold" : "normal"}>{c.name}</Typography>
          </MenuItem>
        );
      })}
    </Select>
  </FormControl>
);
