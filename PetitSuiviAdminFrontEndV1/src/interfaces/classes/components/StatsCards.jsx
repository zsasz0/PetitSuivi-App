import React from "react";
import { Box, Typography } from "@mui/material";
import SchoolOutlinedIcon from "@mui/icons-material/SchoolOutlined";
import GroupOutlinedIcon from "@mui/icons-material/GroupOutlined";
import PeopleOutlineIcon from "@mui/icons-material/PeopleOutline";
import ArchiveOutlinedIcon from "@mui/icons-material/ArchiveOutlined";

const StatsCards = ({ stats, colors, styles, isDark }) => {
    const items = [
        {
            title: "Classes actives",
            value: stats.totalClasses,
            icon: <SchoolOutlinedIcon />,
            iconBg: isDark ? "rgba(96,165,250,0.14)" : "rgba(37,99,235,0.12)",
            iconColor: isDark ? colors.blueAccent[300] : "#1d4ed8",
        },
        {
            title: "Capacité totale",
            value: stats.totalCapacity,
            icon: <GroupOutlinedIcon />,
            iconBg: isDark ? "rgba(134,239,172,0.14)" : "rgba(22,163,74,0.12)",
            iconColor: isDark ? colors.greenAccent[300] : "#166534",
        },
        {
            title: "Élèves inscrits",
            value: stats.totalStudents,
            icon: <PeopleOutlineIcon />,
            iconBg: isDark ? "rgba(148,163,184,0.14)" : "rgba(100,116,139,0.12)",
            iconColor: isDark ? colors.grey[200] : "#475569",
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
        <Box display="grid" gridTemplateColumns={{ xs: "1fr", sm: "repeat(2, 1fr)", xl: "repeat(4, 1fr)" }} gap="14px" mb="20px">
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
