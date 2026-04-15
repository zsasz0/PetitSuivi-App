export function getStyles(colors, isDark) {
  return {
    card: {
      backgroundColor: colors.primary[400],
      borderRadius: "16px",
      padding: "22px",
      boxShadow: "0 12px 28px rgba(15,23,42,0.08)",
      border: `1px solid ${colors.primary[500]}`,
      height: "100%",
      display: "flex",
      flexDirection: "column",
    },
    featureCard: (enabled) => ({
      backgroundColor: isDark ? colors.primary[500] : "rgba(255,255,255,0.96)",
      borderRadius: "14px",
      border: `1px solid ${isDark ? colors.primary[600] : "rgba(148,163,184,0.18)"}`,
      padding: "16px",
      opacity: enabled ? 1 : 0.42,
      filter: enabled ? "none" : "grayscale(0.25)",
      transition: "opacity 0.2s ease, filter 0.2s ease",
      height: "100%",
      display: "flex",
      flexDirection: "column",
      justifyContent: "flex-start",
    }),
    subtlePanel: (enabled) => ({
      backgroundColor: isDark ? colors.primary[500] : "rgba(248,250,252,0.9)",
      borderRadius: "14px",
      border: `1px solid ${colors.primary[500]}`,
      padding: "16px",
      opacity: enabled ? 1 : 0.42,
      filter: enabled ? "none" : "grayscale(0.35)",
      transition: "opacity 0.2s ease, filter 0.2s ease",
      flex: 1,
      display: "flex",
      flexDirection: "column",
    }),
    field: {
      "& .MuiOutlinedInput-root": {
        borderRadius: "12px",
        backgroundColor: isDark ? colors.primary[500] : "#f8fafc",
        minHeight: 54,
        alignItems: "flex-start",
      },
      "& .MuiOutlinedInput-input": {
        paddingTop: "16px",
        paddingBottom: "16px",
      },
      "& .MuiInputBase-inputMultiline": {
        paddingTop: "16px",
        paddingBottom: "16px",
      },
      "& .MuiInputLabel-root": {
        color: colors.grey[300],
        fontWeight: 600,
        transformOrigin: "top left",
      },
      "& .MuiInputLabel-root.Mui-focused": {
        color: isDark ? "#94a3b8" : "#475569",
      },
      "& .MuiOutlinedInput-notchedOutline": {
        borderColor: colors.primary[600],
      },
      "& .MuiOutlinedInput-root:hover .MuiOutlinedInput-notchedOutline": {
        borderColor: colors.grey[400],
      },
      "& .MuiOutlinedInput-root.Mui-focused .MuiOutlinedInput-notchedOutline": {
        borderColor: isDark ? "#94a3b8" : "#475569",
        borderWidth: "1px",
      },
      "& .MuiFormHelperText-root": {
        minHeight: 20,
        marginLeft: 0,
        marginRight: 0,
      },
    },
    primaryBtn: {
      backgroundColor: isDark ? "#475569" : "#334155",
      color: "#fff",
      fontWeight: 700,
      textTransform: "none",
      borderRadius: "999px",
      paddingInline: "18px",
      boxShadow: "none",
      "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569", boxShadow: "none" },
    },
    secondaryBtn: {
      borderRadius: "999px",
      textTransform: "none",
      fontWeight: 700,
      boxShadow: "none",
    },
    switch: (enabled) => ({
      "& .MuiSwitch-switchBase.Mui-checked": { color: colors.greenAccent[500] },
      "& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track": { backgroundColor: colors.greenAccent[500] },
      "& .MuiSwitch-track": { backgroundColor: enabled ? colors.greenAccent[500] : colors.redAccent[500] },
      transform: "scale(1.15)",
    }),
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
      padding: "16px",
      borderTop: `1px solid ${colors.primary[500]}`,
    },
  };
}
