import React from "react";
import { Autocomplete, TextField, Box, Typography } from "@mui/material";

export const TimeRangeSelector = ({ addActivityForm, setAddActivityForm, theme, colors, styles }) => {
  const commonAutoProps = {
    freeSolo: true,
    forcePopupIcon: true,
    disableClearable: true,
    componentsProps: { paper: { sx: { backgroundColor: colors.primary[400], borderRadius: "12px", boxShadow: "0 8px 32px rgba(0,0,0,0.3)", p: 1 } } },
    sx: { flex: 1, "& .MuiOutlinedInput-root": { borderRadius: "12px", backgroundColor: theme.palette.mode === "dark" ? colors.primary[400] : "#f8fafc" } }
  };

  const updateTime = (field, part, newValue) => {
    setAddActivityForm((f) => {
      const current = f[field] || (field === "startTime" ? "09:00" : "11:00");
      let [h, m] = current.split(":");
      if (!h) h = field === "startTime" ? "09" : "11";
      if (!m) m = "00";
      
      if (part === "hour") {
        let newH = newValue.replace(/\D/g, "").substring(0, 2);
        if (newH !== "" && parseInt(newH) > 23) newH = "23";
        return { ...f, [field]: `${newH || h.padStart(2, "0")}:${m}` };
      } else {
        let newM = newValue.replace(/\D/g, "").substring(0, 2);
        if (newM !== "" && parseInt(newM) > 59) newM = "59";
        return { ...f, [field]: `${h}:${newM || m.padStart(2, "0")}` };
      }
    });
  };

  const getPart = (field, part) => {
    const current = addActivityForm[field] || (field === "startTime" ? "09:00" : "11:00");
    const [h, m] = current.split(":");
    return part === "hour" ? (h || (field === "startTime" ? "09" : "11")) : (m || "00");
  };

  return (
    <Box>
      <Typography variant="caption" color={colors.grey[300]} mb="6px" display="block" fontWeight="bold" textTransform="uppercase" letterSpacing="0.5px">
        🕐 Horaires
      </Typography>
      <Box display="grid" gridTemplateColumns="1fr 1fr" gap="12px">
        <Box display="flex" gap="8px">
          <Autocomplete
            {...commonAutoProps}
            options={Array.from({ length: 24 }).map((_, i) => String(i).padStart(2, "0"))}
            value={getPart("startTime", "hour")}
            onInputChange={(e, val) => updateTime("startTime", "hour", val)}
            onBlur={(e) => updateTime("startTime", "hour", e.target.value)}
            renderInput={(params) => <TextField {...params} variant="outlined" label="Début (H)" InputLabelProps={{ shrink: true }} sx={styles.filledInputSx} />}
          />
          <Autocomplete
            {...commonAutoProps}
            options={["00", "15", "30", "45"]}
            value={getPart("startTime", "min")}
            onInputChange={(e, val) => updateTime("startTime", "min", val)}
            onBlur={(e) => updateTime("startTime", "min", e.target.value)}
            renderInput={(params) => <TextField {...params} variant="outlined" label="Min" InputLabelProps={{ shrink: true }} sx={styles.filledInputSx} />}
          />
        </Box>
        <Box display="flex" gap="8px">
          <Autocomplete
            {...commonAutoProps}
            options={Array.from({ length: 24 }).map((_, i) => String(i).padStart(2, "0"))}
            value={getPart("endTime", "hour")}
            onInputChange={(e, val) => updateTime("endTime", "hour", val)}
            onBlur={(e) => updateTime("endTime", "hour", e.target.value)}
            renderInput={(params) => <TextField {...params} variant="outlined" label="Fin (H)" InputLabelProps={{ shrink: true }} sx={styles.filledInputSx} />}
          />
          <Autocomplete
            {...commonAutoProps}
            options={["00", "15", "30", "45"]}
            value={getPart("endTime", "min")}
            onInputChange={(e, val) => updateTime("endTime", "min", val)}
            onBlur={(e) => updateTime("endTime", "min", e.target.value)}
            renderInput={(params) => <TextField {...params} variant="outlined" label="Min" InputLabelProps={{ shrink: true }} sx={styles.filledInputSx} />}
          />
        </Box>
      </Box>
    </Box>
  );
};
