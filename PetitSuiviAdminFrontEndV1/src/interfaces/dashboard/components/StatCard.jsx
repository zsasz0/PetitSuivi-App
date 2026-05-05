import { Box } from "@mui/material";
import StatBox from "../../../components/StatBox";


const StatCard = ({
  title,
  subtitle,
  increase,
  icon,
  iconBg,
  isDark,
  colors,
}) => {
  return (
    <Box
      backgroundColor={colors.primary[400]}
      borderRadius="16px"
      minHeight="124px"
      sx={{
        border: isDark
          ? "1px solid rgba(255,255,255,0.06)"
          : "1px solid rgba(148,163,184,0.16)",
        padding: "12px",
      }}
    >
      <StatBox
        title={title}
        subtitle={subtitle}
        increase={increase}
        iconBg={iconBg}
        icon={icon}
      />
    </Box>
  );
};

export default StatCard;