import React from "react";
import { Box, Typography, Button, IconButton } from "@mui/material";
import AddRoundedIcon from "@mui/icons-material/AddRounded";
import EventRepeatOutlinedIcon from "@mui/icons-material/EventRepeatOutlined";
import TaskAltOutlinedIcon from "@mui/icons-material/TaskAltOutlined";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import ExpandLessIcon from "@mui/icons-material/ExpandLess";
import { getWeeksOfMonth } from "../utils/activitiesUtils";
import { MONTH_ICONS, MONTHS_FR } from "../utils/constants";

export const PlannedActivitiesTab = (props) => {
  const {
    colors,
    isDark,
    styles,
    activitiesList,
    selectedPlanning,
    planningMonthKeys,
    isArchived,
    openAddForDate,
    expandedMonth,
    setExpandedMonth,
    visibleYear,
    setVisibleYear,
    planningStartYear,
    planningEndYear,
    setWeekModalInfo,
    setSelectedClassForWeekId,
    activityMap,
    monthActivityCounts,
    today,
  } = props;

  return (
    <>
      <Box sx={styles.sectionCard} mb="18px">
        <Box sx={styles.sectionHeader}>
          <Box>
            <Typography sx={styles.sectionTitle}>Planning annuel des activités</Typography>
            <Typography sx={styles.sectionSubtitle}>
              Ouvrez un mois, puis une semaine, pour planifier vos activités avec une navigation plus fluide.
            </Typography>
          </Box>
          {!isArchived && (
            <Button
              variant="contained"
              startIcon={<AddRoundedIcon fontSize="small" />}
              onClick={() => openAddForDate("")}
              sx={styles.sectionActionButton}
            >
              Planifier une activité
            </Button>
          )}
        </Box>
      </Box>

      <Box sx={styles.summaryGrid}>
        {[
          {
            label: "Total planifiées",
            value: activitiesList.length,
            accent: colors.greenAccent[500],
            icon: <EventRepeatOutlinedIcon fontSize="small" />,
          },
          {
            label: "Exécutées",
            value: activitiesList.filter((a) => a.status === "executed").length,
            accent: colors.blueAccent[400],
            icon: <TaskAltOutlinedIcon fontSize="small" />,
          },
          {
            label: "Non exécutées",
            value: activitiesList.filter((a) => a.status !== "executed").length,
            accent: colors.redAccent[400],
            icon: <DeleteOutlineIcon fontSize="small" />,
          },
        ].map((item) => (
          <Box key={item.label} sx={styles.summaryCard(item.accent)}>
            <Box>
              <Typography sx={styles.summaryLabel}>{item.label}</Typography>
              <Typography sx={styles.summaryValue}>{item.value}</Typography>
            </Box>
            <Box sx={styles.summaryIconWrap(item.accent)}>{item.icon}</Box>
          </Box>
        ))}
      </Box>

      {/* Year Navigation */}
      <Box display="flex" justifyContent="center" mb="20px">
        <Box sx={styles.monthNavCard}>
        <Button
          disabled={visibleYear <= planningStartYear}
          onClick={() =>
            setVisibleYear((y) => Math.max(planningStartYear, y - 1))
          }
          sx={styles.monthNavButton}
        >
          ←
        </Button>
        <Typography variant="h4" fontWeight="bold" color={colors.grey[100]}>
          {visibleYear}
        </Typography>
        <Button
          disabled={visibleYear >= planningEndYear}
          onClick={() =>
            setVisibleYear((y) => Math.min(planningEndYear, y + 1))
          }
          sx={styles.monthNavButton}
        >
          →
        </Button>
        </Box>
      </Box>

      {/* Calendar Grid */}
      <Box sx={styles.calendarGrid}>
        {Array.from({ length: 12 }, (_, monthIdx) => {
          const monthKey = `${visibleYear}-${String(monthIdx + 1).padStart(2, "0")}`;
          const isInPlanning = planningMonthKeys.has(monthKey);
          const actCount = monthActivityCounts[monthKey] || 0;
          const isExpanded = expandedMonth === monthKey;
          const isCurrentMonth =
            today.getFullYear() === visibleYear &&
            today.getMonth() === monthIdx;
          const weeks = isExpanded
            ? getWeeksOfMonth(visibleYear, monthIdx)
            : [];

          return (
            <Box
              key={monthKey}
              sx={styles.monthCard(isInPlanning, isCurrentMonth)}
            >
              {/* Month Header */}
              <Box
                display="flex"
                alignItems="center"
                justifyContent="space-between"
                p="16px"
                sx={styles.monthHeader(isInPlanning)}
                onClick={() => {
                  if (isInPlanning)
                    setExpandedMonth(isExpanded ? null : monthKey);
                }}
              >
                <Box display="flex" alignItems="center" gap="10px">
                  <Box
                    sx={{
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      color: colors.greenAccent[400],
                    }}
                  >
                    {MONTH_ICONS[monthIdx]}
                  </Box>
                  <Box>
                    <Typography fontWeight="bold" color={colors.grey[100]}>
                      {MONTHS_FR[monthIdx]}
                    </Typography>
                    {actCount > 0 && isInPlanning && (
                      <Typography
                        variant="caption"
                        color={colors.greenAccent[400]}
                      >
                        {actCount} activité{actCount > 1 ? "s" : ""}
                      </Typography>
                    )}
                    {!isInPlanning && (
                      <Typography
                        variant="caption"
                        color={colors.grey[500]}
                        fontStyle="italic"
                        display="block"
                      >
                        Hors planning
                      </Typography>
                    )}
                  </Box>
                </Box>
                {isInPlanning && (
                  <IconButton size="small" sx={{ color: colors.grey[300] }}>
                    {isExpanded ? <ExpandLessIcon /> : <ExpandMoreIcon />}
                  </IconButton>
                )}
              </Box>

              {/* Expanded: List Weeks */}
              {isExpanded && (
                <Box px="16px" pb="16px">
                  {weeks.map((week, wi) => {
                    const planStartStr =
                      selectedPlanning?.start_date?.slice(0, 10) ||
                      selectedPlanning?.startDate?.slice(0, 10) ||
                      "0000-00-00";
                    const planEndStr =
                      selectedPlanning?.end_date?.slice(0, 10) ||
                      selectedPlanning?.endDate?.slice(0, 10) ||
                      "9999-99-99";

                    const filteredWeek = week.filter(
                      (d) =>
                        d.dateStr >= planStartStr && d.dateStr <= planEndStr,
                    );

                    if (filteredWeek.length === 0) return null;

                    const startD = filteredWeek[0];
                    const endD = filteredWeek[filteredWeek.length - 1];
                    const startMonth = startD.date.getMonth();
                    const endMonth = endD.date.getMonth();

                    let startStr = `${startD.day}`;
                    if (
                      startMonth !== endMonth ||
                      startD.dateStr === endD.dateStr
                    ) {
                      startStr += ` ${MONTHS_FR[startMonth]}`;
                    }
                    const endStr = `${endD.day} ${MONTHS_FR[endMonth]}`;

                    const displayRange =
                      startD.dateStr === endD.dateStr
                        ? startStr
                        : `${startStr} – ${endStr}`;

                    const weekDatesStr = filteredWeek
                      .filter((d) => d.inMonth)
                      .map((d) => d.dateStr);
                    const weekActivities = weekDatesStr.flatMap(
                      (ds) => activityMap[ds] || [],
                    );

                    return (
                      <Box
                        key={wi}
                        mb="8px"
                        backgroundColor={colors.primary[500]}
                        borderRadius="8px"
                        p="12px"
                        sx={{
                          cursor: "pointer",
                          border: `1px solid transparent`,
                          "&:hover": { borderColor: colors.greenAccent[500] },
                        }}
                        onClick={() => {
                          setWeekModalInfo({
                            year: visibleYear,
                            month: monthIdx,
                            weekIndex: wi + 1,
                            week: filteredWeek,
                          });
                          setSelectedClassForWeekId("");
                        }}
                      >
                        <Typography fontWeight="bold" color={colors.grey[200]}>
                          Semaine {wi + 1}: {displayRange}
                          {weekActivities.length > 0 && (
                            <Typography
                              component="span"
                              color={colors.greenAccent[400]}
                              ml="8px"
                              fontSize="0.8rem"
                            >
                              ({weekActivities.length})
                            </Typography>
                          )}
                        </Typography>
                      </Box>
                    );
                  })}
                </Box>
              )}
            </Box>
          );
        })}
      </Box>
    </>
  );
};
