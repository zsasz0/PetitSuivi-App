import { Box, Typography } from "@mui/material";
import ArchiveOutlinedIcon from "@mui/icons-material/ArchiveOutlined";
import AssignmentOutlinedIcon from "@mui/icons-material/AssignmentOutlined";
import FactCheckOutlinedIcon from "@mui/icons-material/FactCheckOutlined";
import PendingActionsOutlinedIcon from "@mui/icons-material/PendingActionsOutlined";
import PersonOutlineOutlinedIcon from "@mui/icons-material/PersonOutlineOutlined";

const StatsCards = ({ stats, colors, styles, isDark }) => {
    const items = [
        {
            title: "Total inscriptions",
            value: stats.total,
            icon: <AssignmentOutlinedIcon />,
            iconBg: isDark ? "rgba(96,165,250,0.14)" : "rgba(37,99,235,0.12)",
            iconColor: isDark ? colors.blueAccent[300] : "#1d4ed8",
        },
        {
            title: "Approuvées",
            value: stats.approved,
            icon: <FactCheckOutlinedIcon />,
            iconBg: isDark ? "rgba(134,239,172,0.14)" : "rgba(22,163,74,0.12)",
            iconColor: isDark ? colors.greenAccent[300] : "#166534",
        },
        {
            title: "En attente",
            value: stats.pending,
            icon: <PendingActionsOutlinedIcon />,
            iconBg: isDark ? "rgba(245,158,11,0.14)" : "rgba(245,158,11,0.12)",
            iconColor: isDark ? "#fbbf24" : "#b45309",
        },
        {
            title: "Rejetées",
            value: stats.rejected,
            icon: <PersonOutlineOutlinedIcon />,
            iconBg: isDark ? "rgba(248,113,113,0.14)" : "rgba(220,38,38,0.12)",
            iconColor: isDark ? colors.redAccent[300] : "#991b1b",
        },
        {
            title: "Archivées",
            value: stats.archived,
            icon: <ArchiveOutlinedIcon />,
            iconBg: isDark ? "rgba(148,163,184,0.14)" : "rgba(148,163,184,0.14)",
            iconColor: isDark ? colors.grey[300] : "#64748b",
        },
    ];

    return (
        <Box sx={styles.statsGrid}>
            {items.map((item) => (
                <Box key={item.title} sx={styles.statCard}>
                    <Box sx={{ ...styles.statIcon, background: item.iconBg, color: item.iconColor }}>
                        {item.icon}
                    </Box>
                    <Box minWidth={0}>
                        <Typography variant="body2" color={colors.grey[300]}>{item.title}</Typography>
                        <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mt="4px">{item.value}</Typography>
                    </Box>
                </Box>
            ))}
        </Box>
    );
};

export default StatsCards;
