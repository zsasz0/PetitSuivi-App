import React from "react";
import { GridToolbarContainer, GridToolbarFilterButton } from "@mui/x-data-grid";

export const ActivitiesFilterToolbar = ({ colors, isDark }) => {
  const toolbarBg = isDark ? "rgba(148, 163, 184, 0.08)" : "#eef2f7";
  const border = isDark ? "rgba(148, 163, 184, 0.16)" : "rgba(148, 163, 184, 0.28)";

  return (
    <GridToolbarContainer
      sx={{
        px: "16px",
        py: "14px",
        borderBottom: `1px solid ${border}`,
        backgroundColor: toolbarBg,
      }}
    >
      <GridToolbarFilterButton
        sx={{
          borderRadius: "999px",
          px: "14px",
          py: "6px",
          textTransform: "none",
          fontWeight: 700,
          color: colors.grey[200],
          border: `1px solid ${border}`,
          backgroundColor: isDark ? "rgba(15, 23, 42, 0.42)" : "rgba(255,255,255,0.82)",
        }}
      />
    </GridToolbarContainer>
  );
};
