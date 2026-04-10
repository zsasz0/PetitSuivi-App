export const getAdminPrimaryButtonSx = (overrides = {}) => ({
  color: "#fff",
  fontWeight: 700,
  textTransform: "none",
  borderRadius: "12px",
  backgroundColor: "#334155",
  boxShadow: "none",
  "&:hover": {
    backgroundColor: "#475569",
    boxShadow: "none",
  },
  "&.Mui-disabled": {
    color: "#f8fafc",
    backgroundColor: "#94a3b8",
  },
  ...overrides,
});

export const getAdminSecondaryButtonSx = (overrides = {}) => ({
  color: "#fff",
  fontWeight: 700,
  textTransform: "none",
  borderRadius: "12px",
  backgroundColor: "#475569",
  boxShadow: "none",
  "&:hover": {
    backgroundColor: "#64748b",
    boxShadow: "none",
  },
  "&.Mui-disabled": {
    color: "#f8fafc",
    backgroundColor: "#94a3b8",
  },
  ...overrides,
});
