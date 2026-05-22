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
  Chip,
} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";

// Note: TIMELINE_COLORS defined in constants
import { TIMELINE_COLORS, MONTHS_FR, WEEKDAYS_FR } from "../utils/constants";
import { getStatusLabel, getStatusColor, parseTimeToMinutes, formatMinutesToHourLabel } from "../utils/activitiesUtils";

export const DayTimelineDialogComponent = (props) => {
  const {
    colors,
    styles,
    dayTimelineInfo,
    setDayTimelineInfo,
    classOptions,
    selectedClassForWeekId,
    isArchived,
    openAddForDate,
    dayTimelineActivities,
    timelineWindow,
    handleDeletePlannedActivity,
  } = props;

  return (
    <Dialog
      open={!!dayTimelineInfo}
      onClose={() => setDayTimelineInfo(null)}
      fullWidth
      maxWidth="md"
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
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}
      >
        {dayTimelineInfo &&
          `Horaires • ${WEEKDAYS_FR[dayTimelineInfo.dow]} ${dayTimelineInfo.day} ${MONTHS_FR[dayTimelineInfo.month]} ${dayTimelineInfo.year}`}
        <IconButton size="small" onClick={() => setDayTimelineInfo(null)} sx={{ color: colors.grey[100] }}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <DialogContent sx={{ mt: 2, minHeight: "400px" }}>
        <Box display="flex" justifyContent="space-between" alignItems="center" mb="20px">
          <Typography variant="h5" color={colors.grey[100]} fontWeight="bold">
            {classOptions.find((c) => c.id === Number(selectedClassForWeekId))?.name || "-"}
          </Typography>
          {!isArchived && (
            <Button variant="contained" onClick={() => openAddForDate(dayTimelineInfo?.dateStr)} sx={styles.primaryButton}>
              + Ajouter
            </Button>
          )}
        </Box>

        {dayTimelineActivities.length === 0 ? (
          <Typography color={colors.grey[500]} fontStyle="italic" textAlign="center" py="40px">
            Aucune activité planifiée pour ce jour.
          </Typography>
        ) : (
          <Box>
            {/* Horizontal visual timeline */}
            <Box
              position="relative"
              height="50px"
              backgroundColor={colors.primary[500]}
              borderRadius="6px"
              mb="30px"
              overflow="hidden"
              border={`1px solid ${colors.primary[600]}`}
            >
              {dayTimelineActivities.map((act, idx) => {
                const start = parseTimeToMinutes(act.startTime);
                const end = parseTimeToMinutes(act.endTime);
                const range = Math.max(1, timelineWindow.end - timelineWindow.start);
                const safeStart = start === null ? timelineWindow.start : Math.max(timelineWindow.start, Math.min(start, timelineWindow.end));
                const safeEnd = end === null ? safeStart + 30 : Math.max(safeStart + 15, Math.min(end, timelineWindow.end));
                const leftPct = ((safeStart - timelineWindow.start) / range) * 100;
                const widthPct = Math.max(2, ((safeEnd - safeStart) / range) * 100);
                const color = TIMELINE_COLORS[idx % TIMELINE_COLORS.length];

                return (
                  <Box
                    key={act.id}
                    position="absolute"
                    top="10%"
                    bottom="10%"
                    sx={{
                      left: `${leftPct}%`,
                      width: `${widthPct}%`,
                      backgroundColor: color,
                      borderRadius: "4px",
                      boxShadow: "0px 2px 5px rgba(0,0,0,0.2)",
                      "&:hover": { filter: "brightness(1.1)" },
                    }}
                    title={`${act.title} (${act.startTime || "--:--"} - ${act.endTime || "--:--"})`}
                  />
                );
              })}
            </Box>

            <Box display="flex" justifyContent="space-between" color={colors.grey[400]} fontSize="0.75rem" mt="-25px" mb="20px">
              <Typography>{formatMinutesToHourLabel(timelineWindow.start)}</Typography>
              <Typography>{formatMinutesToHourLabel(timelineWindow.end)}</Typography>
            </Box>

            {/* List of activities */}
            <Box display="flex" flexDirection="column" gap="10px">
              {dayTimelineActivities.map((act, idx) => {
                const color = TIMELINE_COLORS[idx % TIMELINE_COLORS.length];
                return (
                  <Box
                    key={act.id}
                    display="flex"
                    justifyContent="space-between"
                    alignItems="center"
                    p="15px"
                    borderLeft={`5px solid ${color}`}
                    backgroundColor={colors.primary[500]}
                    borderRadius="4px"
                  >
                    <Box>
                      <Typography fontWeight="bold" fontSize="16px" color={colors.grey[100]}>{act.title}</Typography>
                      <Typography color={colors.grey[300]}>{act.startTime || "--:--"} — {act.endTime || "--:--"}</Typography>
                    </Box>
                    <Box display="flex" alignItems="center" gap="8px" flexWrap="wrap">
                      <Chip
                        label={getStatusLabel(act.status)}
                        sx={{ backgroundColor: getStatusColor(act.status, colors), color: "#fff", fontSize: "0.75rem" }}
                      />
                      {!isArchived && String(act.status || "").toLowerCase() === "approved" && (
                        <IconButton color="error" onClick={() => handleDeletePlannedActivity(act.id)}>
                          <DeleteOutlineIcon />
                        </IconButton>
                      )}
                    </Box>
                  </Box>
                );
              })}
            </Box>
          </Box>
        )}
      </DialogContent>
      <DialogActions sx={{ p: 2, borderTop: `1px solid ${colors.primary[500]}` }}>
        <Button onClick={() => setDayTimelineInfo(null)} sx={{ color: colors.grey[100] }}>Fermer</Button>
      </DialogActions>
    </Dialog>
  );
};
