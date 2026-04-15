export const getSharedStyles = (colors, isDark) => ({
    statCard: {
        backgroundColor: colors.primary[400],
        display: "flex",
        alignItems: "center",
        gap: "14px",
        p: "16px 18px",
        borderRadius: "14px",
        border: `1px solid ${colors.primary[500]}`,
        boxShadow: `0px 10px 24px rgba(0, 0, 0, 0.08)`
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
    gridContainer: {
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
        "& .MuiCheckbox-root": { color: `${colors.greenAccent[200]} !important` },
        "& .MuiDataGrid-toolbarContainer": {
            padding: "12px 14px",
            borderBottom: `1px solid ${colors.primary[500]}`,
            gap: "8px",
            backgroundColor: isDark ? "rgba(51, 65, 85, 0.24)" : "rgba(238, 242, 247, 0.88)",
        },
        "& .MuiDataGrid-toolbarContainer .MuiButton-text": { color: `${isDark ? colors.grey[100] : "#0f172a"} !important` },
        "& .MuiDataGrid-cell:focus, & .MuiDataGrid-columnHeader:focus": { outline: "none" },
        "& .MuiDataGrid-row:last-of-type .MuiDataGrid-cell": { borderBottom: "none" },
    },
    dialogPaper: {
        backgroundColor: colors.primary[400],
        color: colors.grey[100],
        borderRadius: "12px",
        boxShadow: "0px 0px 15px rgba(0,0,0,0.5)"
    },
    formCard: {
        backgroundColor: isDark ? colors.primary[500] : "rgba(255,255,255,0.98)",
        border: `1px solid ${isDark ? colors.primary[600] : "rgba(148, 163, 184, 0.22)"}`,
        borderRadius: "16px",
        padding: "18px",
        boxShadow: isDark ? "0 12px 28px rgba(0,0,0,0.12)" : "0 14px 32px rgba(15,23,42,0.08)"
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
            marginLeft: 0,
        },
    },
    dialogTitle: {
        fontWeight: "bold",
        fontSize: "1.2rem",
        borderBottom: `1px solid ${colors.primary[500]}`
    },
    dialogActions: {
        p: 2,
        borderTop: `1px solid ${colors.primary[500]}`
    },
    compactMenuPaper: {
        backgroundColor: colors.primary[400],
        color: colors.grey[100],
        borderRadius: "14px",
        border: `1px solid ${colors.primary[500]}`,
        boxShadow: "0 16px 32px rgba(15,23,42,0.18)",
    },
    childrenPill: {
        px: "10px",
        py: "6px",
        borderRadius: "999px",
        backgroundColor: isDark ? "rgba(148,163,184,0.16)" : "rgba(226,232,240,0.72)",
        color: colors.grey[100],
        fontWeight: 700,
        fontSize: "0.75rem",
        lineHeight: 1,
    },
    childrenSelect: {
        minWidth: 160,
        borderRadius: "999px",
        backgroundColor: isDark ? "rgba(255,255,255,0.04)" : "#ffffff",
        boxShadow: isDark ? "inset 0 1px 0 rgba(255,255,255,0.03)" : "0 2px 8px rgba(15,23,42,0.05)",
        transition: "border-color 0.18s ease, box-shadow 0.18s ease, background-color 0.18s ease",
        ".MuiOutlinedInput-notchedOutline": { borderColor: isDark ? "rgba(148,163,184,0.28)" : "rgba(148,163,184,0.24)" },
        "&:hover .MuiOutlinedInput-notchedOutline": { borderColor: isDark ? "rgba(148,163,184,0.42)" : "rgba(100,116,139,0.35)" },
        "&.Mui-focused": {
            boxShadow: isDark ? "0 0 0 3px rgba(148,163,184,0.12)" : "0 0 0 3px rgba(148,163,184,0.14)",
        },
        "&.Mui-focused .MuiOutlinedInput-notchedOutline": { borderColor: isDark ? "#94a3b8" : "#64748b" },
        "& .MuiSelect-select": {
            py: "8px",
            px: "12px 14px",
            fontSize: "0.85rem",
            fontWeight: 700,
            color: isDark ? colors.grey[100] : "#0f172a",
            display: "flex",
            alignItems: "center",
            gap: "8px",
        },
        "& .MuiSelect-icon": {
            color: isDark ? colors.grey[300] : "#64748b",
            right: 10,
        },
    },
    statusSelect: (statusColor) => ({
        minWidth: 140,
        color: statusColor,
        fontSize: "0.85rem",
        borderRadius: "999px",
        backgroundColor: isDark ? "rgba(255,255,255,0.03)" : "rgba(248,250,252,0.9)",
        ".MuiOutlinedInput-notchedOutline": { borderColor: statusColor },
        "&:hover .MuiOutlinedInput-notchedOutline": { borderColor: statusColor },
        "&.Mui-focused .MuiOutlinedInput-notchedOutline": { borderColor: statusColor },
        "& .MuiSelect-select": { py: "8px", px: "12px", display: 'flex', alignItems: 'center', fontWeight: "bold" },
    }),
});
