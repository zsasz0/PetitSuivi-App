/**
 * Retrieves the specific styles mapping based on the theme colors.
 * @param {Object} colors - The theme tokens
 * @param {boolean} isDark - Dark mode flag
 * @returns {Object} Extracted MUI styles object
 */
export const getStyles = (colors, isDark) => ({
  statCard: {
    backgroundColor: colors.primary[400],
    display: "flex",
    alignItems: "center",
    gap: "14px",
    p: "16px 18px",
    borderRadius: "14px",
    border: `1px solid ${colors.primary[500]}`,
    boxShadow: "0px 10px 24px rgba(0, 0, 0, 0.08)",
  },
  statIcon: {
    width: 48,
    height: 48,
    borderRadius: "14px",
    display: "inline-flex",
    alignItems: "center",
    justifyContent: "center",
    flexShrink: 0,
  },
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
    "& .MuiDataGrid-columnHeaderTitle": { fontWeight: 700 },
    "& .MuiDataGrid-virtualScroller": { backgroundColor: colors.primary[400] },
    "& .MuiDataGrid-footerContainer": {
      borderTop: `1px solid ${colors.primary[500]}`,
      backgroundColor: isDark ? "#334155" : "#eef2f7",
      color: isDark ? colors.grey[100] : "#0f172a",
    },
    "& .MuiDataGrid-toolbarContainer": {
      padding: "12px 14px",
      borderBottom: `1px solid ${colors.primary[500]}`,
      gap: "8px",
      backgroundColor: isDark ? "rgba(51,65,85,0.24)" : "rgba(238,242,247,0.88)",
    },
    "& .MuiDataGrid-toolbarContainer .MuiButton-text": {
      color: `${isDark ? colors.grey[100] : "#0f172a"} !important`,
    },
    "& .MuiDataGrid-row": {
      transition: "background 0.2s",
      "&:hover": { backgroundColor: `${colors.primary[500]} !important` },
    },
    "& .MuiDataGrid-cell:focus, & .MuiDataGrid-columnHeader:focus": { outline: "none" },
  },
  dialogPaper: {
    backgroundColor: colors.primary[400],
    color: colors.grey[100],
    borderRadius: "16px",
    boxShadow: "0px 0px 15px rgba(0,0,0,0.5)",
  },
  dialogTitle: {
    fontWeight: 700,
    borderBottom: `1px solid ${colors.primary[500]}`,
  },
  dialogActions: {
    p: "16px",
    borderTop: `1px solid ${colors.primary[500]}`,
  },
  formCard: {
    backgroundColor: isDark ? colors.primary[500] : "rgba(255,255,255,0.98)",
    border: `1px solid ${isDark ? colors.primary[600] : "rgba(148,163,184,0.22)"}`,
    borderRadius: "16px",
    padding: "18px",
    boxShadow: isDark ? "0 12px 28px rgba(0,0,0,0.12)" : "0 14px 32px rgba(15,23,42,0.08)",
  },
  floatingField: {
    "& .MuiOutlinedInput-root": {
      borderRadius: "12px",
      backgroundColor: isDark ? colors.primary[400] : "#f8fafc",
    },
    "& .MuiInputLabel-root": {
      color: colors.grey[300],
      fontWeight: 600,
    },
    "& .MuiInputLabel-root.Mui-focused": {
      color: isDark ? "#94a3b8" : "#475569",
    },
    "& .MuiOutlinedInput-notchedOutline": { borderColor: colors.primary[600] },
    "& .MuiOutlinedInput-root:hover .MuiOutlinedInput-notchedOutline": { borderColor: colors.grey[400] },
    "& .MuiOutlinedInput-root.Mui-focused .MuiOutlinedInput-notchedOutline": {
      borderColor: isDark ? "#94a3b8" : "#475569",
      borderWidth: "1px",
    },
  },
  conflictBox: {
    p: "12px",
    borderRadius: "12px",
    backgroundColor: "rgba(239,68,68,0.1)",
    border: "1px solid rgba(239,68,68,0.3)",
  },
  errorBox: {
    color: colors.redAccent[500],
    p: "10px 12px",
    borderRadius: "12px",
    backgroundColor: "rgba(239,68,68,0.1)",
  },
  submitBtn: {
    backgroundColor: isDark ? "#475569" : "#334155",
    color: "#fff",
    fontWeight: 700,
    textTransform: "none",
    "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569" },
  },
  deleteBtn: {
    backgroundColor: colors.redAccent[600],
    color: "#fff",
    fontWeight: 700,
    textTransform: "none",
    "&:hover": { backgroundColor: colors.redAccent[700] },
  },
  menuPaper: {
    backgroundColor: colors.primary[400],
    color: colors.grey[100],
    borderRadius: "14px",
    border: `1px solid ${colors.primary[500]}`,
    boxShadow: "0 16px 32px rgba(15,23,42,0.18)",
  },
});
