/**
 * @file Header.jsx
 * @description A reusable header component for page titles and subtitles.
 */

import { Typography, Box, useTheme } from "@mui/material";
import { tokens } from "../theme";

/**
 * Renders a header with a bold title and a colored subtitle.
 * 
 * @param {Object} props - Component props.
 * @param {string} props.title - The main title text.
 * @param {string} props.subtitle - The descriptive subtitle text.
 * @returns {JSX.Element} The rendered header.
 */
const Header = ({ title, subtitle }) => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  return (
    <Box mb="30px">
      <Typography
        variant="h2"
        color={colors.grey[100]}
        fontWeight="bold"
        sx={{ m: "0 0 5px 0" }}
      >
        {title}
      </Typography>
      <Typography variant="h5" color={colors.greenAccent[400]}>
        {subtitle}
      </Typography>
    </Box>
  );
};

export default Header;
