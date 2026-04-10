/**
 * @file StatBox.jsx
 * @description Displays a compact statistic card with a title, subtitle, icon, and contextual hint.
 */

import { Box, Typography, useTheme } from "@mui/material";
import { tokens } from "../theme";

/**
 * Renders a box showing a specific KPI stat, an icon, and its trend.
 * 
 * @param {Object} props - Component props.
 * @param {string} props.title - The primary statistic value/string.
 * @param {string} props.subtitle - Descriptive label for the statistic.
 * @param {React.ReactNode} props.icon - Icon element associated with the stat.
 * @param {string} props.increase - Contextual indicator shown in the footer.
 * @param {string} props.iconBg - Background applied behind the icon.
 * @returns {JSX.Element} The rendered StatBox component.
 */
const StatBox = ({ title, subtitle, icon, increase, iconBg }) => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);

  return (
    <Box width="100%" height="100%" px="14px" py="12px" display="flex" flexDirection="column" justifyContent="space-between">
      <Box display="flex" alignItems="flex-start" justifyContent="space-between" gap="12px">
        <Box
          width="44px"
          height="44px"
          borderRadius="14px"
          display="flex"
          alignItems="center"
          justifyContent="center"
          sx={{
            background: iconBg || colors.primary[500],
            boxShadow: `inset 0 1px 0 rgba(255,255,255,0.12), 0 10px 24px rgba(0,0,0,0.12)`,
          }}
        >
          {icon}
        </Box>
        <Box flex="1" minWidth={0}>
          <Typography
            variant="body2"
            sx={{ color: colors.grey[300], mb: "4px", fontSize: "0.82rem" }}
          >
            {subtitle}
          </Typography>
          <Typography
            variant="h4"
            fontWeight="bold"
            sx={{ color: colors.grey[100] }}
          >
            {title}
          </Typography>
        </Box>
      </Box>
      {increase ? (
        <Typography
          variant="body2"
          fontWeight="600"
          sx={{ color: colors.greenAccent[400], mt: "10px", fontSize: "0.8rem" }}
        >
          {increase}
        </Typography>
      ) : null}
    </Box>
  );
};

export default StatBox;
