import React from "react";
import { Box, Typography, TextField } from "@mui/material";
import { getLabel, isNameField, isValidNameValue } from "../utils/parametersUtils";

export const SettingsGroupCard = ({ title, description, params, columns = 2, colors, styles, handleChange, getInputType, sanitizeNumericInput }) => {
  if (params.length === 0) return null;

  return (
    <Box sx={styles.featureCard(true)}>
      <Typography variant="h6" fontWeight="700" color={colors.grey[100]} mb="6px">{title}</Typography>
      <Typography variant="body2" color={colors.grey[300]} mb="16px">{description}</Typography>
      <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: `repeat(${columns}, minmax(0, 1fr))` }} gap="16px" sx={{ flex: 1, alignItems: "start" }}>
        {params.map((param) => {
          const isNumber = getInputType(param.name) === "number";
          const isName = isNameField(param.name);
          const numValid = !isNumber || /^\d*\.?\d*$/.test(param.value);
          const nameValid = !isName || isValidNameValue(param.value);
          const isValid = numValid && nameValid;
          const normalized = String(param.name).toLowerCase();
          const span = normalized.includes("address") || normalized.includes("adresse") ? { xs: "span 1", md: "span 2" } : { xs: "span 1", md: "span 1" };
          const helperText = !numValid ? "Seuls les nombres positifs sont autorisés" : !nameValid ? "Ce champ doit contenir uniquement des lettres et des espaces." : " ";
          return (
            <Box key={param.id} gridColumn={span}>
              <TextField
                variant="outlined"
                label={getLabel(param.name)}
                value={param.value}
                onChange={(e) => handleChange(param.id, isNumber ? sanitizeNumericInput(e.target.value) : e.target.value)}
                type={isNumber ? "text" : getInputType(param.name)}
                fullWidth
                error={!isValid}
                helperText={helperText}
                InputLabelProps={{ shrink: true }}
                sx={styles.field}
                inputProps={isNumber ? { inputMode: "decimal", pattern: "[0-9.]*" } : undefined}
              />
            </Box>
          );
        })}
      </Box>
    </Box>
  );
};
