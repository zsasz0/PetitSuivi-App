/**
 * @file utils/styles.js
 * @description Centralized UI Styling Configuration for Payments Interface.
 */

export const getNeutralSurfaceSx = (isDark) => ({
  backgroundColor: isDark ? "rgba(15,23,42,0.36)" : "#f8fafc",
  border: `1px solid ${isDark ? "rgba(148,163,184,0.18)" : "#e2e8f0"}`,
  borderRadius: "10px",
});

export const getSecondaryButtonSx = (colors, isDark) => ({
  color: isDark ? colors.grey[100] : "#0f172a",
  borderColor: isDark ? "rgba(148,163,184,0.28)" : "#cbd5e1",
  backgroundColor: isDark ? "rgba(51,65,85,0.24)" : "rgba(255,255,255,0.88)",
  "&:hover": {
    borderColor: isDark ? "rgba(148,163,184,0.4)" : "#94a3b8",
    backgroundColor: isDark ? "rgba(51,65,85,0.34)" : "#ffffff",
  },
});

export const getPrimaryButtonSx = (isDark) => ({
  backgroundColor: isDark ? "#e2e8f0" : "#0f172a",
  color: isDark ? "#0f172a" : "#ffffff",
  fontWeight: 700,
  "&:hover": {
    backgroundColor: isDark ? "#cbd5e1" : "#1e293b",
  },
});

/**
 * Returns a map of reusable sx-style objects keyed by widget name.
 * Keeps all DataGrid and repeated styling centralized.
 * @param {object} colors - The theme color tokens.
 * @param {boolean} isDark - Whether the theme is dark.
 * @returns {object} Style map.
 */
export function getStyles(colors, isDark) {
  return {
    dataGrid: {
      "& .MuiDataGrid-root": {
        border: `1px solid ${colors.primary[500]}`,
        borderRadius: "16px",
        overflow: "hidden",
        backgroundColor: colors.primary[400],
      },
      "& .MuiDataGrid-cell": {
        borderBottom: `1px solid ${colors.primary[500]}`,
        display: "flex",
        alignItems: "center",
      },
      "& .name-column--cell": { color: colors.greenAccent[300] },
      "& .MuiDataGrid-columnHeaders": {
        backgroundColor: isDark ? "#334155" : "#eef2f7",
        borderBottom: `1px solid ${colors.primary[500]}`,
        color: isDark ? colors.grey[100] : "#0f172a",
      },
      "& .MuiDataGrid-virtualScroller": {
        backgroundColor: colors.primary[400],
      },
      "& .MuiDataGrid-footerContainer": {
        borderTop: `1px solid ${colors.primary[500]}`,
        backgroundColor: isDark ? "#334155" : "#eef2f7",
        color: isDark ? colors.grey[100] : "#0f172a",
      },
      "& .MuiDataGrid-toolbarContainer": {
        padding: "12px 14px",
        borderBottom: `1px solid ${colors.primary[500]}`,
        gap: "8px",
        backgroundColor: isDark ? "rgba(51, 65, 85, 0.24)" : "rgba(238, 242, 247, 0.88)",
      },
      "& .MuiDataGrid-toolbarContainer .MuiButton-text": {
        color: `${isDark ? colors.grey[100] : "#0f172a"} !important`,
      },
      "& .MuiDataGrid-cell:focus, & .MuiDataGrid-columnHeader:focus": {
        outline: "none",
      },
    },
  };
}
