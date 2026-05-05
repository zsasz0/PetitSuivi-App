import { Box, Typography, Checkbox, LinearProgress, IconButton, Tooltip } from "@mui/material";
import MoreVertOutlinedIcon from "@mui/icons-material/MoreVertOutlined";
import { formatCurrency, getPaymentPercent } from "../utils/formatters";

/**
 * @file components/PaymentColumns.jsx
 * Defines the columns for the Payments DataGrid.
 */

export const getPaymentColumns = ({
  theme,
  colors,
  handleToggleFrais,
  handleHistoryClick,
}) => [
  {
    field: "name",
    headerName: "Nom",
    flex: 1,
    minWidth: 150,
    cellClassName: "name-column--cell",
  },
  { field: "className", headerName: "Classe", flex: 0.7, minWidth: 100 },
  {
    field: "inscriptionDate",
    headerName: "Date inscription",
    flex: 0.7,
    minWidth: 120,
  },
  {
    field: "paymentMethodLabel",
    headerName: "Méthode",
    flex: 0.7,
    minWidth: 120,
  },
  {
    field: "payment",
    headerName: "Paiement",
    flex: 1.2,
    minWidth: 200,
    renderCell: ({ row }) => {
      const pct = getPaymentPercent(row.paidAmount, row.totalAmount);
      const barColor =
        row.paymentStatus === "paid"
          ? (theme.palette.mode === "dark" ? colors.greenAccent[400] : "#16a34a")
          : row.paymentStatus === "partial"
            ? (theme.palette.mode === "dark" ? "#94a3b8" : "#64748b")
            : (theme.palette.mode === "dark" ? "rgba(148,163,184,0.5)" : "#94a3b8");
      return (
        <Box
          width="100%"
          display="flex"
          flexDirection="column"
          justifyContent="center"
          py="8px"
          alignItems="stretch"
        >
          <Typography variant="body2" textAlign="right" fontWeight="700" color={colors.grey[100]} mb="6px">
            {formatCurrency(row.paidAmount)} /{" "}
            {formatCurrency(row.totalAmount)}
          </Typography>
          <LinearProgress
            variant="determinate"
            value={pct}
            sx={{
              height: 4,
              borderRadius: 999,
              backgroundColor: theme.palette.mode === "dark" ? "rgba(148,163,184,0.18)" : "rgba(203,213,225,0.8)",
              "& .MuiLinearProgress-bar": {
                backgroundColor: barColor,
                borderRadius: 999,
              },
            }}
          />
        </Box>
      );
    },
  },
  {
    field: "fraisInscription",
    headerName: "Frais Inscription",
    flex: 0.6,
    minWidth: 120,
    sortable: false,
    filterable: false,
    renderCell: ({ row }) => {
      const isChecked = row.fraisAmount > 0;
      return (
        <Box
          display="flex"
          alignItems="center"
          justifyContent="center"
          width="100%"
        >
          <Checkbox
            checked={isChecked}
            onChange={() => handleToggleFrais(row.inscriptionId, isChecked)}
            sx={{
              color: colors.greenAccent[300],
              "&.Mui-checked": { color: colors.greenAccent[500] },
            }}
          />
        </Box>
      );
    },
  },
  {
    field: "txCount",
    headerName: "Transactions",
    flex: 0.5,
    minWidth: 100,
    type: "number",
  },
  {
    field: "paymentStatus",
    headerName: "Statut",
    flex: 0.7,
    minWidth: 100,
    renderCell: ({ row }) => {
      const statusStyles =
        row.paymentStatus === "paid"
          ? {
              backgroundColor:
                theme.palette.mode === "dark"
                  ? "rgba(34,197,94,0.18)"
                  : "rgba(22,163,74,0.12)",
              color:
                theme.palette.mode === "dark"
                  ? colors.greenAccent[300]
                  : "#166534",
              borderColor:
                theme.palette.mode === "dark"
                  ? "rgba(34,197,94,0.22)"
                  : "rgba(22,163,74,0.18)",
            }
          : row.paymentStatus === "partial"
            ? {
                backgroundColor:
                theme.palette.mode === "dark"
                    ? "rgba(245,158,11,0.16)"
                    : "rgba(245,158,11,0.12)",
                color:
                  theme.palette.mode === "dark"
                    ? "#fbbf24"
                    : "#92400e",
                borderColor:
                  theme.palette.mode === "dark"
                    ? "rgba(245,158,11,0.22)"
                    : "rgba(245,158,11,0.18)",
              }
            : {
                backgroundColor:
                  theme.palette.mode === "dark"
                    ? "rgba(239,68,68,0.18)"
                    : "rgba(220,38,38,0.12)",
                color:
                  theme.palette.mode === "dark"
                    ? colors.redAccent[300]
                    : "#991b1b",
                borderColor:
                  theme.palette.mode === "dark"
                    ? "rgba(239,68,68,0.22)"
                    : "rgba(220,38,38,0.18)",
              };
      return (
        <Box
          component="span"
          sx={{
            px: "10px",
            py: "6px",
            borderRadius: "999px",
            border: "1px solid",
            fontWeight: 700,
            fontSize: "0.75rem",
            lineHeight: 1,
            display: "inline-flex",
            alignItems: "center",
            ...statusStyles,
          }}
        >
          {row.statusLabel}
        </Box>
      );
    },
  },
  {
    field: "actions",
    headerName: "Plus",
    flex: 0.4,
    minWidth: 90,
    sortable: false,
    filterable: false,
    headerAlign: "right",
    align: "right",
    renderCell: ({ row }) => (
      <Box display="flex" justifyContent="flex-end" width="100%">
        <Tooltip title="Détails & paiements">
          <IconButton
            size="small"
            onClick={() => handleHistoryClick(row)}
            sx={{
              color: colors.grey[200],
              backgroundColor: "rgba(148,163,184,0.14)",
              "&:hover": { backgroundColor: "rgba(148,163,184,0.22)" },
            }}
          >
            <MoreVertOutlinedIcon fontSize="small" />
          </IconButton>
        </Tooltip>
      </Box>
    ),
  },
];
