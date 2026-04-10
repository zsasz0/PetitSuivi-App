/**
 * @file ProgressCircle.jsx
 * @description A dynamic progress circle component for visual statistics.
 */

import { Box, useTheme } from "@mui/material";
import { tokens } from "../theme";

/**
 * Renders a circular progress bar with dynamic background gradients.
 * 
 * @param {Object} props - Component props.
 * @param {string|number} [props.progress="0.75"] - A value between 0 and 1 representing the progress.
 * @param {string|number} [props.size="40"] - The diameter of the circle in pixels.
 * @returns {JSX.Element} The rendered progress circle.
 */
const ProgressCircle = ({ progress = "0.75", size = "40" }) => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const angle = progress * 360;
  return (
    <Box
      sx={{
        background: `radial-gradient(${colors.primary[400]} 55%, transparent 56%),
            conic-gradient(transparent 0deg ${angle}deg, ${colors.blueAccent[500]} ${angle}deg 360deg),
            ${colors.greenAccent[500]}`,
        borderRadius: "50%",
        width: `${size}px`,
        height: `${size}px`,
      }}
    />
  );
};

export default ProgressCircle;
