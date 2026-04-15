import { Box, Typography } from "@mui/material";
import CalendarMonthOutlinedIcon from "@mui/icons-material/CalendarMonthOutlined";
import CampaignOutlinedIcon from "@mui/icons-material/CampaignOutlined";
import EventAvailableOutlinedIcon from "@mui/icons-material/EventAvailableOutlined";
import PendingActionsOutlinedIcon from "@mui/icons-material/PendingActionsOutlined";
import ScheduleOutlinedIcon from "@mui/icons-material/ScheduleOutlined";
import { getStyles } from "../utils/styles";

const StatsCards = ({ stats, colors, isDark }) => {
  const styles = getStyles(colors, isDark);
  const cards = [
    {
      label: "Total événements",
      value: stats.total,
      desc: "Toutes périodes confondues",
      color: isDark ? colors.blueAccent[300] : "#1d4ed8",
      bg: isDark ? "rgba(96,165,250,0.14)" : "rgba(37,99,235,0.12)",
      icon: <CalendarMonthOutlinedIcon />,
    },
    {
      label: "Aujourd'hui",
      value: stats.today,
      desc: "Événements de la journée",
      color: isDark ? colors.grey[200] : "#475569",
      bg: isDark ? "rgba(148,163,184,0.14)" : "rgba(148,163,184,0.14)",
      icon: <ScheduleOutlinedIcon />,
    },
    {
      label: "Exécutés",
      value: stats.executed,
      desc: "Terminés ou validés",
      color: isDark ? colors.greenAccent[300] : "#166534",
      bg: isDark ? "rgba(134,239,172,0.14)" : "rgba(22,163,74,0.12)",
      icon: <EventAvailableOutlinedIcon />,
    },
    {
      label: "En attente",
      value: stats.pending,
      desc: "À réaliser",
      color: isDark ? "#fbbf24" : "#92400e",
      bg: isDark ? "rgba(245,158,11,0.14)" : "rgba(245,158,11,0.12)",
      icon: <PendingActionsOutlinedIcon />,
    },
    {
      label: "Notifiés",
      value: stats.notified,
      desc: "Notifications envoyées",
      color: isDark ? colors.greenAccent[300] : "#166534",
      bg: isDark ? "rgba(134,239,172,0.14)" : "rgba(22,163,74,0.12)",
      icon: <CampaignOutlinedIcon />,
    },
  ];

  return (
    <Box display="grid" gridTemplateColumns={{ xs: "1fr", sm: "repeat(2, 1fr)", xl: "repeat(5, 1fr)" }} gap="14px" mb="20px">
      {cards.map((card) => (
        <Box key={card.label} sx={styles.statCard}>
          <Box sx={{ ...styles.statIcon, backgroundColor: card.bg, color: card.color }}>
            {card.icon}
          </Box>
          <Box minWidth={0}>
            <Typography variant="body2" color={colors.grey[300]}>{card.label}</Typography>
            <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mt="4px">{card.value}</Typography>
            <Typography variant="caption" color={colors.grey[400]}>{card.desc}</Typography>
          </Box>
        </Box>
      ))}
    </Box>
  );
};

export default StatsCards;
