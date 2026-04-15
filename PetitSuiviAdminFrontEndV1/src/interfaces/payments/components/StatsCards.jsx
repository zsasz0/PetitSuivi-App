import { Box, Typography } from "@mui/material";
import CheckCircleOutlineOutlinedIcon from "@mui/icons-material/CheckCircleOutlineOutlined";
import PaymentsOutlinedIcon from "@mui/icons-material/PaymentsOutlined";
import HourglassEmptyOutlinedIcon from "@mui/icons-material/HourglassEmptyOutlined";
import CalendarMonthOutlinedIcon from "@mui/icons-material/CalendarMonthOutlined";
import RequestQuoteOutlinedIcon from "@mui/icons-material/RequestQuoteOutlined";

/**
 * @file components/StatsCards.jsx
 * Renders the 5-card summary row: Paid, Partial, Pending, Monthly, Annual.
 */
const StatsCards = ({ stats, colors, isDark }) => {
  const cards = [
    {
      label: "Payés",
      value: stats.paid,
      color: colors.greenAccent[500],
      desc: "Totalement réglés",
      icon: <CheckCircleOutlineOutlinedIcon />,
      iconBg: isDark ? "rgba(134,239,172,0.14)" : "rgba(22,163,74,0.12)",
    },
    {
      label: "Partiels",
      value: stats.partial,
      color: "#f59e0b",
      desc: "Paiements en cours",
      icon: <PaymentsOutlinedIcon />,
      iconBg: isDark ? "rgba(245,158,11,0.14)" : "rgba(245,158,11,0.12)",
    },
    {
      label: "En attente",
      value: stats.pending,
      color: colors.redAccent[500],
      desc: "Aucun paiement",
      icon: <HourglassEmptyOutlinedIcon />,
      iconBg: isDark ? "rgba(248,113,113,0.14)" : "rgba(220,38,38,0.12)",
    },
    {
      label: "Mensuel",
      value: stats.monthly,
      color: colors.blueAccent[300],
      desc: "Méthode par mois",
      icon: <CalendarMonthOutlinedIcon />,
      iconBg: isDark ? "rgba(96,165,250,0.14)" : "rgba(37,99,235,0.12)",
    },
    {
      label: "Annuel",
      value: stats.annual,
      color: colors.blueAccent[300],
      desc: "Paiement unique",
      icon: <RequestQuoteOutlinedIcon />,
      iconBg: isDark ? "rgba(148,163,184,0.14)" : "rgba(148,163,184,0.14)",
    },
  ];

  return (
    <Box
      display="grid"
      gridTemplateColumns={{ xs: "1fr", sm: "repeat(2, 1fr)", xl: "repeat(5, 1fr)" }}
      gap="14px"
      mb="20px"
    >
      {cards.map((s, i) => (
        <Box
          key={i}
          backgroundColor={colors.primary[400]}
          display="flex"
          alignItems="center"
          gap="14px"
          p="16px 18px"
          borderRadius="14px"
          border={`1px solid ${colors.primary[500]}`}
          boxShadow="0px 10px 24px rgba(0,0,0,0.08)"
        >
          <Box
            width="48px"
            height="48px"
            borderRadius="14px"
            display="inline-flex"
            alignItems="center"
            justifyContent="center"
            sx={{ backgroundColor: s.iconBg, color: s.color, flexShrink: 0 }}
          >
            {s.icon}
          </Box>
          <Box minWidth={0}>
            <Typography variant="body2" color={colors.grey[300]}>
              {s.label}
            </Typography>
            <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mt="4px">
              {s.value}
            </Typography>
            <Typography variant="caption" color={colors.grey[400]}>
              {s.desc}
            </Typography>
          </Box>
        </Box>
      ))}
    </Box>
  );
};

export default StatsCards;
