import { Box } from "@mui/material";
import ChildCareIcon from "@mui/icons-material/ChildCare";
import SchoolIcon from "@mui/icons-material/School";
import PeopleIcon from "@mui/icons-material/People";
import ClassIcon from "@mui/icons-material/Class";
import StatCard from "./StatCard";

const StatsSection = ({ stats, isDark, colors }) => {
  const statCards = [
    {
      title: String(stats.totalChildren),
      subtitle: "Enfants inscrits approuvés",
      increase: `${stats.approvedChildrenThisWeek} cette semaine`,
      icon: (
        <ChildCareIcon
          sx={{ color: isDark ? "#93c5fd" : "#1d4ed8", fontSize: "22px" }}
        />
      ),
      iconBg: isDark
        ? "linear-gradient(135deg, rgba(59,130,246,0.28), rgba(96,165,250,0.12))"
        : "linear-gradient(135deg, rgba(37,99,235,0.18), rgba(147,197,253,0.3))",
    },
    {
      title: String(stats.totalTeachers),
      subtitle: "Enseignants",
      increase: `${stats.activeTeachers} actifs`,
      icon: (
        <SchoolIcon
          sx={{ color: isDark ? "#d8b4fe" : "#7e22ce", fontSize: "22px" }}
        />
      ),
      iconBg: isDark
        ? "linear-gradient(135deg, rgba(168,85,247,0.26), rgba(216,180,254,0.12))"
        : "linear-gradient(135deg, rgba(126,34,206,0.16), rgba(221,214,254,0.34))",
    },
    {
      title: String(stats.totalParents),
      subtitle: "Parents",
      increase: `${stats.activeParents} actifs`,
      icon: (
        <PeopleIcon
          sx={{ color: isDark ? "#fdba74" : "#c2410c", fontSize: "22px" }}
        />
      ),
      iconBg: isDark
        ? "linear-gradient(135deg, rgba(249,115,22,0.26), rgba(253,186,116,0.12))"
        : "linear-gradient(135deg, rgba(234,88,12,0.16), rgba(254,215,170,0.36))",
    },
    {
      title: String(stats.totalClasses),
      subtitle: "Classes",
      increase: `${stats.activeClasses} actives`,
      icon: (
        <ClassIcon
          sx={{ color: isDark ? "#99f6e4" : "#0f766e", fontSize: "22px" }}
        />
      ),
      iconBg: isDark
        ? "linear-gradient(135deg, rgba(45,212,191,0.24), rgba(153,246,228,0.12))"
        : "linear-gradient(135deg, rgba(13,148,136,0.16), rgba(153,246,228,0.34))",
    },
  ];

  return (
    <Box
      display="grid"
      gridTemplateColumns={{
        xs: "repeat(2, minmax(0, 1fr))",
        lg: "repeat(4, minmax(0, 1fr))",
      }}
      gap="12px"
      mb="16px"
    >
      {statCards.map((card, index) => (
        <StatCard
          key={index}
          {...card}
          isDark={isDark}
          colors={colors}
        />
      ))}
    </Box>
  );
};

export default StatsSection;