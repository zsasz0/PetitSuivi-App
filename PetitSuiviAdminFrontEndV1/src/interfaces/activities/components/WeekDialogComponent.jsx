import React from "react";
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Typography,
  Box,
  Button,
} from "@mui/material";
import { MONTHS_FR, WEEKDAYS_FR } from "../utils/constants";

export const WeekDialogComponent = (props) => {
  const {
    colors,
    weekModalInfo,
    setWeekModalInfo,
    selectedClassForWeekId,
    setSelectedClassForWeekId,
    setDayTimelineInfo,
    classOptions,
  } = props;
  
  return (
    <Dialog
      open={!!weekModalInfo}
      onClose={() => setWeekModalInfo(null)}
      fullWidth
      maxWidth="sm"
      PaperProps={{
        sx: {
          backgroundColor: colors.primary[400],
          color: colors.grey[100],
          borderRadius: "12px",
        },
      }}
    >
      <DialogTitle
        sx={{
          fontWeight: "bold",
          borderBottom: `1px solid ${colors.primary[500]}`,
        }}
      >
        {weekModalInfo &&
          `Semaine ${weekModalInfo.weekIndex} • ${MONTHS_FR[weekModalInfo.month]} ${weekModalInfo.year}`}
      </DialogTitle>
      <DialogContent sx={{ mt: 2 }}>
        <FormControl variant="filled" fullWidth sx={{ mb: "20px", "& .MuiFilledInput-root": { backgroundColor: colors.primary[500], borderRadius: "8px" } }}>
          <InputLabel sx={{ color: colors.grey[300] }}>Classe</InputLabel>
          <Select
            value={selectedClassForWeekId}
            onChange={(e) => setSelectedClassForWeekId(e.target.value)}
            sx={{ color: colors.grey[100] }}
          >
            <MenuItem value="">
              <em>Sélectionner une classe</em>
            </MenuItem>
            {classOptions.map((c) => (
              <MenuItem key={c.id} value={c.id}>
                {c.label} - date de création: {c.creation_year}
              </MenuItem>
            ))}
          </Select>
        </FormControl>

        {!selectedClassForWeekId ? (
          <Typography
            color={colors.grey[500]}
            fontStyle="italic"
            textAlign="center"
            py="20px"
          >
            Choisissez une classe pour charger les activités.
          </Typography>
        ) : (
          <Box display="flex" flexDirection="column" gap="10px">
            {weekModalInfo?.week?.map((dayInfo) => (
              <Box
                key={dayInfo.dateStr}
                p="16px"
                borderRadius="8px"
                backgroundColor={colors.primary[500]}
                sx={{ cursor: "pointer", "&:hover": { opacity: 0.8 } }}
                onClick={() => {
                  setDayTimelineInfo({
                    dateStr: dayInfo.dateStr,
                    day: dayInfo.day,
                    month: dayInfo.date.getMonth(),
                    year: dayInfo.date.getFullYear(),
                    dow: dayInfo.dow,
                  });
                  setWeekModalInfo(null);
                }}
              >
                <Typography fontWeight="bold" color={colors.grey[100]}>
                  {WEEKDAYS_FR[dayInfo.dow]} {dayInfo.day}{" "}
                  {MONTHS_FR[dayInfo.date.getMonth()]}
                </Typography>
              </Box>
            ))}
          </Box>
        )}
      </DialogContent>
      <DialogActions sx={{ p: 2, borderTop: `1px solid ${colors.primary[500]}` }}>
        <Button onClick={() => setWeekModalInfo(null)} sx={{ color: colors.grey[100] }}>
          Fermer
        </Button>
      </DialogActions>
    </Dialog>
  );
};
