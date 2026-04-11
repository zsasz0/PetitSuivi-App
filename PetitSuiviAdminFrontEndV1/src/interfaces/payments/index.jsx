/**
 * @file payments/index.jsx
 * @description Payment Transaction Management Interface — Admin Ledger.
 *
 * PURPOSE:
 * Manages financial transactions for nursery inscriptions. Administrators can
 * view the payment status of each enrolled child (paid / partial / pending),
 * record new payment instalments (monthly or one-shot), toggle the annual
 * inscription fee checkbox, and track cumulative payment progress against
 * the total amount due per inscription.
 *
 * SUB-COMPONENTS (defined in this file for colocation):
 *  - StatsCards            — 5-card summary row (Paid, Partial, Pending, Monthly, Annual).
 *  - PaymentsDataGrid      — MUI DataGrid with column definitions and toolbar.
 *  - RecentTransactionsPanel — Chronological flat-list of the 10 latest transactions.
 *  - TransactionHistoryDialog — Modal with monthly schedule or standard payment form.
 *  - ConfirmPaymentDialog   — Small confirmation modal before persisting a payment.
 *
 * COMPANION FILES (not modified during this refactor):
 *  - PaymentInvoiceDialog.jsx  — Full-screen print-ready invoice preview.
 *  - PaymentReceiptDialog.jsx  — Full-screen print-ready receipt preview.
 *
 * ─── API ENDPOINTS CONSUMED ───────────────────────────────────────────────
 *
 * 1. GET  /api/admin/payments
 *    Returns all Payment rows joined with inscription, child, class, status,
 *    and nested partial_payments[]. Used to build the master DataGrid.
 *
 * 2. GET  /api/admin/inscriptions
 *    Returns all inscription records. Client-side joined with payments via
 *    composite key (inscription_id + child_id) to enrich parent/class info.
 *
 * 3. GET  /api/admin/parameters
 *    System-wide configuration key/value pairs (e.g. "frais_inscription",
 *    "company_name", meal plan costs). Used for fee calculation fallbacks
 *    and invoice/receipt branding.
 *
 * 4. GET  /api/admin/plannings
 *    Academic year planning periods (start/end year, dates). Used for the
 *    school-year filter dropdown and monthly payment schedule range.
 *
 * 5. POST /api/admin/payments/{inscriptionId}/{childId}/transactions
 *    Body: { amount: number, date: "YYYY-MM-DD", target_month?: "YYYY-MM" }
 *    Records a new partial payment instalment. On success the grid auto-refreshes.
 *
 * 6. PATCH /api/admin/inscriptions/{id}/frais
 *    Body: { checked: boolean }
 *    Toggles whether the annual inscription fee has been collected.
 *    Returns { data: { frais_inscription_amount: number|null } }.
 *
 * ──────────────────────────────────────────────────────────────────────────
 *
 * @module Payments
 */
import {
  Box,
  Button,
  Typography,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  LinearProgress,
  Checkbox,
  MenuItem,
  Select,
  FormControl,
  InputLabel,
  IconButton,
  Tooltip,
} from "@mui/material";
import { DataGrid, GridToolbarContainer, GridToolbarFilterButton } from "@mui/x-data-grid";
import { tokens } from "../../theme";
import Header from "../../components/Header";
import { useTheme } from "@mui/material";
import { useEffect, useState, useMemo, useCallback } from "react";
import api from "../../api/axios";
import PaymentInvoiceDialog from "./PaymentInvoiceDialog";
import PaymentReceiptDialog from "./PaymentReceiptDialog";
import MoreVertOutlinedIcon from "@mui/icons-material/MoreVertOutlined";
import PaymentsOutlinedIcon from "@mui/icons-material/PaymentsOutlined";
import HourglassEmptyOutlinedIcon from "@mui/icons-material/HourglassEmptyOutlined";
import CheckCircleOutlineOutlinedIcon from "@mui/icons-material/CheckCircleOutlineOutlined";
import CalendarMonthOutlinedIcon from "@mui/icons-material/CalendarMonthOutlined";
import RequestQuoteOutlinedIcon from "@mui/icons-material/RequestQuoteOutlined";

// ─── Pure Utility Helpers ─────────────────────────────────────────────────────

/**
 * formatCurrency
 * Standardizes monetary values into the TND currency format for the UI.
 * @param {number|string} amount - The numeric value to format.
 * @returns {string} Formatted currency string (e.g., "1 000 TND").
 */
const formatCurrency = (amount) =>
  new Intl.NumberFormat("fr-FR", { minimumFractionDigits: 0 }).format(
    Number(amount || 0),
  ) + " TND";

const getNeutralSurfaceSx = (isDark) => ({
  backgroundColor: isDark ? "rgba(15,23,42,0.36)" : "#f8fafc",
  border: `1px solid ${isDark ? "rgba(148,163,184,0.18)" : "#e2e8f0"}`,
  borderRadius: "10px",
});

const getSecondaryButtonSx = (colors, isDark) => ({
  color: isDark ? colors.grey[100] : "#0f172a",
  borderColor: isDark ? "rgba(148,163,184,0.28)" : "#cbd5e1",
  backgroundColor: isDark ? "rgba(51,65,85,0.24)" : "rgba(255,255,255,0.88)",
  "&:hover": {
    borderColor: isDark ? "rgba(148,163,184,0.4)" : "#94a3b8",
    backgroundColor: isDark ? "rgba(51,65,85,0.34)" : "#ffffff",
  },
});

const getPrimaryButtonSx = (isDark) => ({
  backgroundColor: isDark ? "#e2e8f0" : "#0f172a",
  color: isDark ? "#0f172a" : "#ffffff",
  fontWeight: 700,
  "&:hover": {
    backgroundColor: isDark ? "#cbd5e1" : "#1e293b",
  },
});

/**
 * mapStatusToUi
 * Maps backend payment status names to standardized UI tags.
 * @param {string} statusName - The raw status name from the API.
 * @returns {string} Standardized tag ('paid'|'partial'|'pending').
 */
const mapStatusToUi = (statusName) => {
  const n = (statusName || "").toLowerCase();
  if (n === "payé" || n === "paye" || n === "paid") return "paid";
  if (n === "partiel" || n === "partial") return "partial";
  return "pending";
};

/**
 * normalizePaymentMethod
 * Flattens various naming conventions for payment methods into reliable constants.
 * @param {string} method - The raw method string.
 * @returns {string} Normalized method key ('monthlyPartial'|'oneShot').
 */
const normalizePaymentMethod = (method) => {
  const n = (method || "").toLowerCase();
  if (
    n === "monthlypartial" ||
    n === "monthly_partial" ||
    n === "monthly partial"
  )
    return "monthlyPartial";
  return "oneShot";
};

/**
 * normalizeTextForMatch
 * Strips accents from a string to ensure accurate dictionary mapping.
 * @param {string} text
 * @returns {string}
 */
const normalizeTextForMatch = (text) => {
  return (text || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim();
};

const parseYearMonth = (value) => {
  const match = /^(\d{4})-(\d{2})/.exec(value || "");
  if (!match) return null;
  return {
    year: Number(match[1]),
    month: Number(match[2]),
  };
};

const formatMonthLabel = (year, month) => {
  return new Date(year, month - 1, 1).toLocaleString("fr-FR", {
    month: "long",
    year: "numeric",
  });
};

const getTargetMonthKey = (targetMonth) => {
  if (targetMonth === null || targetMonth === undefined || targetMonth === "") {
    return null;
  }

  if (typeof targetMonth === "string" && /^\d{4}-\d{2}$/.test(targetMonth)) {
    return targetMonth;
  }

  const monthNumber = Number(targetMonth);
  if (Number.isNaN(monthNumber) || monthNumber < 1 || monthNumber > 12) {
    return null;
  }

  return String(monthNumber).padStart(2, "0");
};

/**
 * getMonthsInRange
 * Generates array of month options between two dates.
 * @param {string} startDate - Planning start date (YYYY-MM-DD)
 * @param {string} endDate - Planning end date (YYYY-MM-DD)
 * @returns {Array<{value: string, label: string}>} Array of month options
 */
const getMonthsInRange = (startDate, endDate) => {
  const months = [];
  if (!startDate || !endDate) return months;

  const start = parseYearMonth(startDate);
  const end = parseYearMonth(endDate);
  if (!start || !end) return months;

  const monthNames = [
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    "Juin",
    "Juillet",
    "Août",
    "Septembre",
    "Octobre",
    "Novembre",
    "Décembre",
  ];

  let year = start.year;
  let month = start.month;
  while (year < end.year || (year === end.year && month <= end.month)) {
    const value = `${year}-${String(month).padStart(2, "0")}`;
    const label = `${monthNames[month - 1]} ${year}`;
    months.push({ value, label });

    month += 1;
    if (month > 12) {
      month = 1;
      year += 1;
    }
  }

  return months;
};

/**
 * getPaymentPercent
 * Helper returning completion ratio (0..100) strictly capped.
 * @param {number} paid - Amount already paid.
 * @param {number} total - Total amount due.
 * @returns {number} Percentage value (0-100).
 */
const getPaymentPercent = (paid, total) => {
  if (!total) return 0;
  return Math.min(Math.round((paid / total) * 100), 100);
};

// ─── Sub-Components ───────────────────────────────────────────────────────────

/**
 * StatsCards
 * Renders the 5-card summary row: Paid, Partial, Pending, Monthly, Annual.
 * @param {{ stats: object, colors: object }} props
 */
const StatsCards = ({ stats, colors, isDark }) => {
  const cards = [
    {
      label: "Payés",
      value: stats.paid,
      color: colors.greenAccent[500],
      desc: "Totalement réglés",
      icon: <CheckCircleOutlineOutlinedIcon />,
      iconBg: isDark ? "rgba(134,239,172,0.14)" : "rgba(22,163,74,0.12)",
    },
    {
      label: "Partiels",
      value: stats.partial,
      color: "#f59e0b",
      desc: "Paiements en cours",
      icon: <PaymentsOutlinedIcon />,
      iconBg: isDark ? "rgba(245,158,11,0.14)" : "rgba(245,158,11,0.12)",
    },
    {
      label: "En attente",
      value: stats.pending,
      color: colors.redAccent[500],
      desc: "Aucun paiement",
      icon: <HourglassEmptyOutlinedIcon />,
      iconBg: isDark ? "rgba(248,113,113,0.14)" : "rgba(220,38,38,0.12)",
    },
    {
      label: "Mensuel",
      value: stats.monthly,
      color: colors.blueAccent[300],
      desc: "Méthode par mois",
      icon: <CalendarMonthOutlinedIcon />,
      iconBg: isDark ? "rgba(96,165,250,0.14)" : "rgba(37,99,235,0.12)",
    },
    {
      label: "Annuel",
      value: stats.annual,
      color: colors.blueAccent[300],
      desc: "Paiement unique",
      icon: <RequestQuoteOutlinedIcon />,
      iconBg: isDark ? "rgba(148,163,184,0.14)" : "rgba(148,163,184,0.14)",
    },
  ];

  return (
    <Box
      display="grid"
      gridTemplateColumns={{ xs: "1fr", sm: "repeat(2, 1fr)", xl: "repeat(5, 1fr)" }}
      gap="14px"
      mb="20px"
    >
      {cards.map((s, i) => (
        <Box
          key={i}
          backgroundColor={colors.primary[400]}
          display="flex"
          alignItems="center"
          gap="14px"
          p="16px 18px"
          borderRadius="14px"
          border={`1px solid ${colors.primary[500]}`}
          boxShadow="0px 10px 24px rgba(0,0,0,0.08)"
        >
          <Box
            width="48px"
            height="48px"
            borderRadius="14px"
            display="inline-flex"
            alignItems="center"
            justifyContent="center"
            sx={{ backgroundColor: s.iconBg, color: s.color, flexShrink: 0 }}
          >
            {s.icon}
          </Box>
          <Box minWidth={0}>
            <Typography variant="body2" color={colors.grey[300]}>
              {s.label}
            </Typography>
            <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mt="4px">
              {s.value}
            </Typography>
            <Typography variant="caption" color={colors.grey[400]}>
              {s.desc}
            </Typography>
          </Box>
        </Box>
      ))}
    </Box>
  );
};

const PaymentsGridToolbar = ({ colors, isDark }) => (
  <GridToolbarContainer sx={{ display: "flex", justifyContent: "flex-start", p: "10px 14px" }}>
    <GridToolbarFilterButton
      sx={{
        borderRadius: "999px",
        px: "12px",
        py: "4px",
        textTransform: "none",
        fontWeight: 700,
        color: isDark ? colors.grey[100] : "#0f172a",
        border: `1px solid ${isDark ? "rgba(148,163,184,0.24)" : "rgba(148,163,184,0.28)"}`,
        backgroundColor: isDark ? "rgba(51,65,85,0.24)" : "rgba(255,255,255,0.72)",
      }}
    />
  </GridToolbarContainer>
);

/**
 * PaymentsDataGrid
 * Wraps the MUI DataGrid with column definitions, toolbar, and styling.
 * @param {{ loading, rows, columns, colors }} props
 */
const PaymentsDataGrid = ({ loading, rows, columns, colors, isDark }) => {
  const styles = getStyles(colors, isDark);

  return (
    <Box m="20px 0 0 0" height="65vh" sx={styles.dataGrid}>
      <DataGrid
        loading={loading}
        rows={rows}
        columns={columns}
        components={{ Toolbar: PaymentsGridToolbar }}
        componentsProps={{ toolbar: { colors, isDark } }}
        getRowHeight={() => "auto"}
        pageSize={10}
        rowsPerPageOptions={[10, 50, 100]}
        disableSelectionOnClick
      />
    </Box>
  );
};

/**
 * RecentTransactionsPanel
 * Displays the 10 most recent transactions in a chronological flat-list.
 * @param {{ allTransactions: Array, colors: object }} props
 */
const RecentTransactionsPanel = ({ allTransactions, colors }) => (
  <Box
    mt="20px"
    backgroundColor={colors.primary[400]}
    borderRadius="12px"
    p="20px"
  >
    <Typography
      variant="h5"
      fontWeight="bold"
      color={colors.grey[100]}
      mb="15px"
    >
      Historique récent des transactions ({Math.min(10, allTransactions.length)}
      )
    </Typography>
    {allTransactions.length === 0 ? (
      <Typography color={colors.grey[300]} textAlign="center" py="20px">
        Aucune transaction enregistrée.
      </Typography>
    ) : (
      <Box
        display="flex"
        flexDirection="column"
        gap="8px"
        maxHeight="300px"
        overflow="auto"
      >
        {allTransactions.slice(0, 10).map((tx) => (
          <Box
            key={tx.id}
            display="flex"
            justifyContent="space-between"
            alignItems="center"
            p="10px 15px"
            borderRadius="8px"
            backgroundColor={
              tx.isFrais ? colors.blueAccent[800] : colors.primary[500]
            }
          >
            <Box>
              <Typography fontWeight="bold" color={colors.greenAccent[400]}>
                {tx.childName}
              </Typography>
              <Typography
                variant="caption"
                color={tx.isFrais ? colors.blueAccent[200] : colors.grey[300]}
              >
                {tx.className} · {tx.date}{" "}
                {tx.isFrais && "· Frais d'Inscription"}
              </Typography>
            </Box>
            <Typography
              fontWeight="bold"
              color={
                tx.isFrais ? colors.blueAccent[300] : colors.greenAccent[500]
              }
            >
              +{formatCurrency(tx.amount)}
            </Typography>
          </Box>
        ))}
      </Box>
    )}
  </Box>
);

/**
 * ConfirmPaymentDialog
 * Small confirmation modal displayed before persisting any payment.
 * @param {{ open, onClose, confirmPayData, txSubmitting, onConfirmStandard, onConfirmMonthly, colors }} props
 */
const ConfirmPaymentDialog = ({
  open,
  onClose,
  confirmPayData,
  txSubmitting,
  onConfirmStandard,
  onConfirmMonthly,
  colors,
}) => {
  const theme = useTheme();
  const isDark = theme.palette.mode === "dark";

  return <Dialog
    open={open}
    onClose={() => !txSubmitting && onClose()}
    maxWidth="xs"
    fullWidth
    PaperProps={{
      sx: {
        backgroundColor: isDark ? "#111c2d" : "#ffffff",
        color: isDark ? colors.grey[100] : "#0f172a",
        borderRadius: "12px",
        border: `1px solid ${isDark ? "rgba(148,163,184,0.18)" : "#e2e8f0"}`,
      },
    }}
  >
    <DialogTitle
      sx={{
        fontWeight: "bold",
        borderBottom: `1px solid ${isDark ? "rgba(148,163,184,0.18)" : "#e2e8f0"}`,
      }}
    >
      Confirmer le paiement
    </DialogTitle>
    <DialogContent sx={{ mt: 2 }}>
      <Typography>
        {confirmPayData?.type === "standard" ? (
          <>
            Voulez-vous confirmer le paiement de{" "}
            <strong>
              {confirmPayData ? formatCurrency(confirmPayData.amount) : ""}
            </strong>
            {confirmPayData?.targetMonthLabel && (
              <>
                {" "}
                pour le mois de{" "}
                <strong>{confirmPayData.targetMonthLabel}</strong>
              </>
            )}{" "}
            ?
          </>
        ) : (
          <>
            Voulez-vous confirmer le paiement de{" "}
            <strong>
              {confirmPayData ? formatCurrency(confirmPayData.amount) : ""}
            </strong>{" "}
            pour le mois de <strong>{confirmPayData?.targetMonthLabel}</strong>{" "}
            ?
          </>
        )}
      </Typography>
    </DialogContent>
    <DialogActions sx={{ p: 2, borderTop: `1px solid ${isDark ? "rgba(148,163,184,0.18)" : "#e2e8f0"}` }}>
      <Button
        onClick={onClose}
        disabled={txSubmitting}
        sx={{ color: isDark ? colors.grey[100] : "#334155" }}
      >
        Annuler
      </Button>
      <Button
        onClick={() => {
          if (confirmPayData?.type === "standard") {
            onConfirmStandard();
          } else if (confirmPayData) {
            onConfirmMonthly(
              confirmPayData.row,
              confirmPayData.amount,
              confirmPayData.targetMonthValue,
            );
            onClose();
          }
        }}
        variant="contained"
        disabled={txSubmitting}
        sx={getPrimaryButtonSx(isDark)}
      >
        {txSubmitting ? "Traitement..." : "Confirmer"}
      </Button>
    </DialogActions>
  </Dialog>
};

// ─── Main Component ───────────────────────────────────────────────────────────

/**
 * Payments Component
 * Primary ledger interface for tracking student payment statuses,
 * recording installments, and managing administrative fees.
 * @component
 * @returns {JSX.Element} The rendered global Payments ledger.
 */
const Payments = () => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";

  // ── All State Declarations ──────────────────────────────────────────────

  // Core State
  const [paymentsRows, setPaymentsRows] = useState([]);
  const [selectedYear, setSelectedYear] = useState("all");
  const [planningsList, setPlanningsList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  // Transaction History & Details Dialog State
  const [isHistoryDialogOpen, setIsHistoryDialogOpen] = useState(false);
  const [historyRow, setHistoryRow] = useState(null);
  const [txAmount, setTxAmount] = useState("");
  const [txDate, setTxDate] = useState(new Date().toISOString().slice(0, 10));
  const [txTargetMonth, setTxTargetMonth] = useState("");
  const [txError, setTxError] = useState("");
  const [txSubmitting, setTxSubmitting] = useState(false);

  // Invoice Dialog State
  const [isInvoiceDialogOpen, setIsInvoiceDialogOpen] = useState(false);
  const [invoiceRow, setInvoiceRow] = useState(null);

  // Receipt Dialog State
  const [isReceiptDialogOpen, setIsReceiptDialogOpen] = useState(false);
  const [receiptData, setReceiptData] = useState(null);
  const [companyParams, setCompanyParams] = useState({});

  // Confirmation Dialog State
  const [isConfirmPayOpen, setIsConfirmPayOpen] = useState(false);
  const [confirmPayData, setConfirmPayData] = useState(null);

  // ── Data Fetching ───────────────────────────────────────────────────────

  /**
   * loadPayments
   * Orchestrates dual-endpoint fetching to join Inscription metadata with
   * Payment ledger records. Computes real-time balances and status overrides.
   * @async
   * @returns {Promise<void>}
   */
  const loadPayments = useCallback(async () => {
    try {
      setLoading(true);
      setError("");
      const [paymentsRes, inscriptionsRes, parametersRes, planningsRes] =
        await Promise.all([
          api.get("/admin/payments"),
          api.get("/admin/inscriptions"),
          api.get("/admin/parameters").catch(() => ({ data: { data: [] } })),
          api.get("/admin/plannings").catch(() => ({ data: { data: [] } })),
        ]);

      const paymentRows = Array.isArray(paymentsRes?.data?.data)
        ? paymentsRes.data.data
        : [];
      const inscriptionsRows = Array.isArray(inscriptionsRes?.data?.data)
        ? inscriptionsRes.data.data
        : [];
      const parametersRows = Array.isArray(parametersRes?.data?.data)
        ? parametersRes.data.data
        : Array.isArray(parametersRes?.data)
          ? parametersRes.data
          : [];
      const planningsRows = Array.isArray(planningsRes?.data?.data)
        ? planningsRes.data.data
        : Array.isArray(planningsRes?.data)
          ? planningsRes.data
          : [];

      const inscriptionByKey = new Map(
        inscriptionsRows.map((r) => [`${r?.id}-${r?.child_id}`, r]),
      );
      const parametersByName = new Map(
        parametersRows.map((p) => [normalizeTextForMatch(p?.name), p?.value]),
      );

      setCompanyParams({
        companyName: parametersByName.get("company_name") || "PETIT SUIVI",
        address:
          parametersByName.get("kindergarten_address") ||
          "123 Avenue des Écoles, Tunis, Tunisie",
        phone: parametersByName.get("contact_phone") || "+216 71 123 456",
        email: parametersByName.get("contact_email") || "contact@petitsuivi.tn",
      });

      const planningsByYear = new Map(
        planningsRows.map((p) => [Number(p?.start_year || p?.startYear), p]),
      );
      const planningsById = new Map(
        planningsRows.map((p) => [String(p?.id), p]),
      );

      const rows = paymentRows
        .filter(
          (r) =>
            (r?.inscription_status?.name || "").toLowerCase() === "approved",
        )
        .map((row, idx) => {
          const key = `${row?.inscription_id}-${row?.child_id}`;
          const inscription = inscriptionByKey.get(key);
          const serverStatus = mapStatusToUi(row?.payment_status?.name);
          const totalAmount = Number(row?.amount || 0);
          const partialPayments = Array.isArray(row?.partial_payments)
            ? row.partial_payments
            : [];
          const partialPaid = partialPayments.reduce(
            (s, tx) => s + Number(tx.value || 0),
            0,
          );
          const status =
            totalAmount > 0 && partialPaid >= totalAmount
              ? "paid"
              : partialPaid > 0
                ? "partial"
                : serverStatus;
          const paidAmount = status === "paid" ? totalAmount : partialPaid;
          const payMethod = normalizePaymentMethod(
            row?.payment_method || inscription?.payment_method,
          );
          const isOneShot = payMethod === "oneShot";
          const fraisAmount =
            row?.frais_inscription_amount !== null
              ? Number(row.frais_inscription_amount)
              : 0;
          let fraisSnapshot =
            row?.frais_inscription_snapshot !== null
              ? Number(row.frais_inscription_snapshot)
              : 0;

          const parentName = inscription?.parent?.full_name || "Inconnu";
          const parentCin = inscription?.parent?.cin;
          const mealPlan = row?.meal_plan || inscription?.meal_plan;

          let mealPlanCost = Number(
            row?.meal_plan_fee || inscription?.meal_plan_fee || 0,
          );
          let baseFee = Number(row?.base_fee || inscription?.base_fee || 0);

          if (fraisSnapshot === 0) {
            const fraisParam = parametersByName.get("frais_inscription");
            if (
              fraisParam !== undefined &&
              fraisParam !== null &&
              !isNaN(Number(fraisParam))
            ) {
              fraisSnapshot = Number(fraisParam);
            }
          }

          if (mealPlanCost === 0 && baseFee === 0 && mealPlan) {
            const costStr = parametersByName.get(
              normalizeTextForMatch(mealPlan),
            );
            if (
              costStr !== undefined &&
              costStr !== null &&
              !isNaN(Number(costStr))
            ) {
              mealPlanCost = Number(costStr);
            }
          }

          const classYear = Number(
            row?.class?.year ||
              inscription?.class?.year ||
              new Date(row?.inscription_date).getFullYear(),
          );
          const planning =
            planningsById.get(String(row?.class?.planning_id || "")) ||
            planningsByYear.get(classYear);
          const planningStartYear =
            planning?.start_year || planning?.startYear || classYear;
          const planningEndYear =
            planning?.end_year || planning?.endYear || classYear + 1;
          const planningStartDate =
            row?.class?.planning_start ||
            planning?.start_date ||
            planning?.startDate ||
            `${planningStartYear}-09-01`;
          const planningEndDate =
            row?.class?.planning_end ||
            planning?.end_date ||
            planning?.endDate ||
            `${planningEndYear}-06-30`;
          const planningId = row?.class?.planning_id || planning?.id || null;

          return {
            id: `${row?.inscription_id}-${row?.child_id}-${idx}`,
            inscriptionId: row?.inscription_id,
            childId: row?.child_id,
            name: row?.child_full_name || "Inconnu",
            inscriptionDate: row?.inscription_date || "",
            className: row?.class?.name || inscription?.class?.name || "—",
            totalAmount,
            paidAmount,
            remaining: Math.max(totalAmount - paidAmount, 0),
            paymentMethod: payMethod,
            paymentMethodLabel:
              payMethod === "monthlyPartial"
                ? "Paiement Mensuel"
                : "Paiement Annuel",
            reachedTxLimit: isOneShot && partialPayments.length >= 1,
            paymentStatus: status,
            statusLabel:
              status === "paid"
                ? "Payé"
                : status === "partial"
                  ? "Partiel"
                  : "En attente",
            transactions: partialPayments,
            txCount: partialPayments.length,
            fraisAmount,
            fraisSnapshot,
            parentName,
            parentCin,
            mealPlan,
            mealPlanCost,
            baseFee,
            planningStartYear,
            planningEndYear,
            planningStartDate,
            planningEndDate,
            planningId,
          };
        });
      setPaymentsRows(rows);
      setPlanningsList(planningsRows);
    } catch (err) {
      setError(err?.response?.data?.message || "Échec du chargement.");
      setPaymentsRows([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadPayments();
  }, [loadPayments]);

  // ── Derived / Computed Data ─────────────────────────────────────────────

  const filteredRows = useMemo(() => {
    if (selectedYear === "all") return paymentsRows;
    return paymentsRows.filter(
      (r) => String(r.planningId) === String(selectedYear),
    );
  }, [paymentsRows, selectedYear]);

  const stats = useMemo(
    () => ({
      paid: filteredRows.filter((r) => r.paymentStatus === "paid").length,
      partial: filteredRows.filter((r) => r.paymentStatus === "partial").length,
      pending: filteredRows.filter((r) => r.paymentStatus === "pending").length,
      monthly: filteredRows.filter((r) => r.paymentMethod === "monthlyPartial")
        .length,
      annual: filteredRows.filter((r) => r.paymentMethod === "oneShot").length,
    }),
    [filteredRows],
  );

  /**
   * allTransactions
   * Creates a chronologically sorted global flatlist of every individual payment
   * instalment mapping across the entire system. Feeds the timeline view block.
   */
  const allTransactions = useMemo(() => {
    const txs = [];
    filteredRows.forEach((child) => {
      (child.transactions || []).forEach((tx) => {
        txs.push({
          id: tx.id || `${child.inscriptionId}-${tx.date}`,
          amount: Number(tx.value || 0),
          date: tx.date,
          childName: child.name,
          className: child.className,
          isFrais: false,
        });
      });
      if (child.fraisAmount > 0) {
        txs.push({
          id: `frais-${child.inscriptionId}`,
          amount: child.fraisAmount,
          date: child.inscriptionDate,
          childName: child.name,
          className: child.className,
          isFrais: true,
        });
      }
    });
    return txs.sort((a, b) => new Date(b.date) - new Date(a.date));
  }, [filteredRows]);

  // ── Event Handlers ──────────────────────────────────────────────────────

  /**
   * handleConfirmTransaction
   * Persists a standard (form-based) payment instalment to the backend.
   * @async
   */
  const handleConfirmTransaction = async () => {
    try {
      setTxSubmitting(true);
      setTxError("");
      const payload = {
        amount: confirmPayData.amount,
        date: confirmPayData.date,
      };
      if (confirmPayData.targetMonth) {
        payload.target_month = confirmPayData.targetMonth;
      }
      await api.post(
        `/admin/payments/${historyRow.inscriptionId}/${historyRow.childId}/transactions`,
        payload,
      );
      await loadPayments();

      setPaymentsRows((prev) => {
        const updatedRow = prev.find(
          (r) =>
            r.inscriptionId === historyRow.inscriptionId &&
            r.childId === historyRow.childId,
        );
        if (updatedRow && updatedRow.id === historyRow?.id) {
          setHistoryRow(updatedRow);
        }
        return prev;
      });

      setTxAmount("");
      setIsConfirmPayOpen(false);
      setConfirmPayData(null);
    } catch (error) {
      console.error("Failed to submit transaction", error);
      setTxError(
        error?.response?.data?.message || "Erreur lors de la transaction.",
      );
    } finally {
      setTxSubmitting(false);
    }
  };

  /**
   * submitTransaction
   * Validates input against remaining balances and payment method rules,
   * then opens the confirmation dialog.
   * @param {React.FormEvent} e - Form submission event.
   */
  const submitTransaction = async (e) => {
    e.preventDefault();
    if (!historyRow) return;

    if (historyRow.reachedTxLimit) {
      setTxError("Limite de transactions atteinte.");
      return;
    }
    const amountValue = Number(txAmount);
    if (!amountValue || amountValue <= 0) {
      setTxError("Veuillez saisir un montant valide.");
      return;
    }
    if (
      historyRow.paymentMethod === "oneShot" &&
      Math.round(amountValue * 100) !== Math.round(historyRow.totalAmount * 100)
    ) {
      setTxError("Le montant doit être égal au montant total.");
      return;
    }
    if (amountValue > historyRow.remaining) {
      setTxError(
        `Le montant ne peut pas dépasser ${formatCurrency(historyRow.remaining)}.`,
      );
      return;
    }

    if (historyRow.paymentMethod === "monthlyPartial" && !txTargetMonth) {
      setTxError("Veuillez sélectionner le mois concerné par ce paiement.");
      return;
    }

    setConfirmPayData({
      type: "standard",
      amount: amountValue,
      date: txDate,
      targetMonth:
        historyRow.paymentMethod === "monthlyPartial" ? txTargetMonth : null,
      targetMonthLabel:
        historyRow.paymentMethod === "monthlyPartial"
          ? getMonthsInRange(
              historyRow.planningStartDate,
              historyRow.planningEndDate,
            ).find((m) => m.value === txTargetMonth)?.label
          : null,
    });
    setIsConfirmPayOpen(true);
  };

  /**
   * handleToggleFrais
   * Toggles the annual inscription fee checkbox via PATCH.
   * Uses optimistic local update.
   * @async
   * @param {number} inscriptionId
   * @param {boolean} currentVal
   */
  const handleToggleFrais = async (inscriptionId, currentVal) => {
    try {
      const nextVal = !currentVal;
      const response = await api.patch(
        `/admin/inscriptions/${inscriptionId}/frais`,
        { checked: nextVal },
      );
      const newAmount = response.data?.data?.frais_inscription_amount;
      setPaymentsRows((prev) =>
        prev.map((row) =>
          row.inscriptionId === inscriptionId
            ? {
                ...row,
                fraisAmount: newAmount !== null ? Number(newAmount) : 0,
              }
            : row,
        ),
      );
    } catch (error) {
      console.error("Failed to toggle frais inscription", error);
      alert("Erreur lors de la modification des frais d'inscription.");
    }
  };

  /** Opens the history/details dialog for a specific row */
  const handleHistoryClick = (row) => {
    setHistoryRow(row);
    setTxAmount(
      row?.paymentMethod === "oneShot" ? String(row?.totalAmount || "") : "",
    );
    setTxDate(new Date().toISOString().slice(0, 10));
    setTxTargetMonth("");
    setTxError("");
    setIsHistoryDialogOpen(true);
  };

  /**
   * handlePayMonth
   * Records a monthly instalment from checkbox click.
   * @async
   * @param {Object} row
   * @param {number} monthlyAmount
   * @param {string} targetMonth - YYYY-MM format
   */
  const handlePayMonth = async (row, monthlyAmount, targetMonth) => {
    try {
      setTxSubmitting(true);
      await api.post(
        `/admin/payments/${row.inscriptionId}/${row.childId}/transactions`,
        {
          amount: Math.round(monthlyAmount * 100) / 100,
          date: new Date().toISOString().slice(0, 10),
          target_month: targetMonth,
        },
      );
      await loadPayments();

      setPaymentsRows((prev) => {
        const updatedRow = prev.find(
          (r) =>
            r.inscriptionId === row.inscriptionId && r.childId === row.childId,
        );
        if (updatedRow && updatedRow.id === historyRow?.id) {
          setHistoryRow(updatedRow);
        }
        return prev;
      });
    } catch (error) {
      console.error("Failed to add monthly payment", error);
      alert("Erreur lors du paiement mensuel.");
    } finally {
      setTxSubmitting(false);
    }
  };

  // ── Dialog Content Renderers ────────────────────────────────────────────

  /** Renders the monthly payment schedule with checkboxes inside the history dialog */
  const renderMonthlySchedule = () => {
    if (!historyRow) return null;

    const start = parseYearMonth(historyRow.planningStartDate);
    const end = parseYearMonth(historyRow.planningEndDate);
    if (!start || !end) return null;

    let monthsCount = (end.year - start.year) * 12;
    monthsCount -= start.month;
    monthsCount += end.month;
    monthsCount += 1;
    if (monthsCount <= 0 || isNaN(monthsCount)) monthsCount = 10;

    const monthlyAmount = historyRow.totalAmount / monthsCount;

    const monthsList = [];
    let currentYear = start.year;
    let currentMonth = start.month;
    for (let i = 0; i < monthsCount; i++) {
      const mName = formatMonthLabel(currentYear, currentMonth);
      const monthValue = `${currentYear}-${String(currentMonth).padStart(2, "0")}`;
      monthsList.push({
        index: i,
        label: mName.charAt(0).toUpperCase() + mName.slice(1),
        value: monthValue,
        date: new Date(currentYear, currentMonth - 1, 1),
      });

      currentMonth += 1;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear += 1;
      }
    }

    const txs = historyRow.transactions || [];
    const transactionsByMonth = new Map();

    txs.forEach((tx) => {
      const targetMonthKey = getTargetMonthKey(tx?.target_month);
      if (!targetMonthKey) return;

      transactionsByMonth.set(targetMonthKey, tx);
    });

    const firstUnpaidIndex = monthsList.findIndex((month) => {
      return !transactionsByMonth.has(month.value) && !transactionsByMonth.has(month.value.slice(5));
    });

    return (
      <Box display="flex" flexDirection="column" gap="8px" mt="15px">
        <Typography
          variant="h6"
          color={isDark ? colors.grey[100] : "#0f172a"}
          mb="5px"
          fontWeight="bold"
        >
          Échéancier Mensuel ({formatCurrency(monthlyAmount)} / mois)
        </Typography>
        {monthsList.map((m, i) => {
          const txForMonth = transactionsByMonth.get(m.value) || transactionsByMonth.get(m.value.slice(5)) || null;
          const isPaid = Boolean(txForMonth);
          const isNext = !isPaid && (firstUnpaidIndex === -1 ? false : i === firstUnpaidIndex);

          return (
            <Box
              key={m.index}
              display="flex"
              justifyContent="space-between"
              p="10px 15px"
              sx={getNeutralSurfaceSx(isDark)}
              borderRadius="8px"
              alignItems="center"
            >
              <Box display="flex" alignItems="center" gap="10px">
                <Checkbox
                  checked={isPaid}
                  disabled={isPaid || !isNext || txSubmitting}
                  onChange={() => {
                    setConfirmPayData({
                      row: historyRow,
                      amount: monthlyAmount,
                      targetMonthValue: m.value,
                      targetMonthLabel: m.label,
                    });
                    setIsConfirmPayOpen(true);
                  }}
                  sx={{
                    color: isNext ? (isDark ? colors.grey[300] : "#64748b") : colors.grey[500],
                    "&.Mui-checked": { color: isDark ? colors.grey[100] : "#0f172a" },
                  }}
                />
                <Box>
                  <Typography
                    color={isDark ? colors.grey[100] : "#0f172a"}
                    fontWeight={isPaid ? "bold" : "normal"}
                  >
                    {m.label}
                  </Typography>
                  {isPaid && txForMonth && (
                    <Typography variant="caption" color={isDark ? colors.grey[400] : "#64748b"}>
                      Payé le {txForMonth.date}
                    </Typography>
                  )}
                </Box>
              </Box>

              {isPaid && txForMonth && (
                <Box display="flex" alignItems="center" gap="12px">
                  <Typography fontWeight="bold" color={isDark ? colors.grey[100] : "#0f172a"}>
                    +{formatCurrency(txForMonth.value || monthlyAmount)}
                  </Typography>
                  <Button
                    variant="outlined"
                    size="small"
                    onClick={() => {
                      setReceiptData({
                        ...historyRow,
                        transaction: txForMonth,
                        targetMonthLabel: m.label,
                      });
                      setIsReceiptDialogOpen(true);
                    }}
                    sx={{ ...getSecondaryButtonSx(colors, isDark), py: "2px", minWidth: "auto", fontSize: "11px" }}
                  >
                    Reçu
                  </Button>
                </Box>
              )}
            </Box>
          );
        })}
      </Box>
    );
  };

  /** Renders the standard (non-monthly) payment form + history inside the dialog */
  const renderStandardPayments = () => {
    if (!historyRow) return null;

    const hasNoTransactions =
      historyRow.transactions.length === 0 &&
      (!historyRow.fraisAmount || historyRow.fraisAmount <= 0);
    const canAddTransaction =
      historyRow.remaining > 0 && !historyRow.reachedTxLimit;

    return (
      <Box display="flex" flexDirection="column" gap="15px">
        {/* Add payment form */}
        {canAddTransaction && (
          <Box
            component="form"
            onSubmit={submitTransaction}
            p="15px"
            sx={getNeutralSurfaceSx(isDark)}
            display="flex"
            flexDirection="column"
            gap="12px"
          >
            <Typography variant="h6" fontWeight="bold" color={isDark ? colors.grey[100] : "#0f172a"}>
              Ajouter un paiement
            </Typography>
            {txError && (
              <Typography color={colors.redAccent[500]} fontSize="13px">
                {txError}
              </Typography>
            )}
            <Box display="flex" gap="10px" flexWrap="wrap">
              <TextField
                variant="filled"
                label="Montant"
                type="number"
                inputProps={{ min: 0.01, step: 0.01 }}
                value={txAmount}
                onChange={(e) => setTxAmount(e.target.value)}
                sx={{ flex: 1, minWidth: "120px" }}
                required
                size="small"
                disabled={historyRow.paymentMethod === "oneShot"}
              />
              {historyRow.paymentMethod !== "oneShot" && (
                <>
                  <TextField
                    variant="filled"
                    label="Date"
                    type="date"
                    InputLabelProps={{ shrink: true }}
                    value={txDate}
                    onChange={(e) => setTxDate(e.target.value)}
                    sx={{ flex: 1, minWidth: "120px" }}
                    required
                    size="small"
                    inputProps={{ max: new Date().toISOString().slice(0, 10) }}
                  />
                  <FormControl
                    variant="filled"
                    size="small"
                    sx={{ flex: 1, minWidth: "150px" }}
                    required
                  >
                    <InputLabel>Mois concerné</InputLabel>
                    <Select
                      value={txTargetMonth}
                      onChange={(e) => setTxTargetMonth(e.target.value)}
                      label="Mois concerné"
                    >
                      {getMonthsInRange(
                        historyRow.planningStartDate,
                        historyRow.planningEndDate,
                      ).map((m) => (
                        <MenuItem key={m.value} value={m.value}>
                          {m.label}
                        </MenuItem>
                      ))}
                    </Select>
                  </FormControl>
                </>
              )}
            </Box>
            <Button
              type="submit"
              variant="contained"
              disabled={txSubmitting}
              sx={{ ...getPrimaryButtonSx(isDark), alignSelf: "flex-end" }}
            >
              {txSubmitting ? "..." : "Enregistrer"}
            </Button>
          </Box>
        )}

        {/* Transaction history list */}
        <Typography variant="h6" fontWeight="bold" color={isDark ? colors.grey[100] : "#0f172a"}>
          Historique des versements
        </Typography>
        {hasNoTransactions ? (
          <Typography color={colors.grey[300]} textAlign="center" py="20px">
            Aucune transaction.
          </Typography>
        ) : (
          <Box display="flex" flexDirection="column" gap="8px">
            {historyRow?.fraisAmount > 0 && (
              <Box
                display="flex"
                justifyContent="space-between"
                p="10px 15px"
                sx={getNeutralSurfaceSx(isDark)}
              >
                <Box>
                  <Typography color={isDark ? colors.grey[200] : "#334155"}>
                    {historyRow.inscriptionDate}
                  </Typography>
                  <Typography
                    variant="caption"
                    color={isDark ? colors.grey[400] : "#64748b"}
                    fontWeight="bold"
                  >
                    Frais Annuel d'Inscription
                  </Typography>
                </Box>
                <Box display="flex" alignItems="center" gap="12px">
                  <Typography fontWeight="bold" color={isDark ? colors.grey[100] : "#0f172a"}>
                    +{formatCurrency(historyRow.fraisAmount)}
                  </Typography>
                  <Button
                    variant="outlined"
                    size="small"
                    onClick={() => {
                      setReceiptData({
                        ...historyRow,
                        transaction: {
                          id: "FRAIS",
                          value: historyRow.fraisAmount,
                          payment_date: historyRow.inscriptionDate,
                          isFrais: true,
                        },
                      });
                      setIsReceiptDialogOpen(true);
                    }}
                    sx={{ ...getSecondaryButtonSx(colors, isDark), py: "2px", minWidth: "auto", fontSize: "11px" }}
                  >
                    Reçu
                  </Button>
                </Box>
              </Box>
            )}
            {(historyRow?.transactions || []).map((tx, i) => (
              <Box
                key={i}
                display="flex"
                justifyContent="space-between"
                p="10px 15px"
                sx={getNeutralSurfaceSx(isDark)}
                alignItems="center"
              >
                <Box>
                  <Typography color={isDark ? colors.grey[200] : "#334155"}>{tx.date}</Typography>
                  <Typography variant="caption" color={isDark ? colors.grey[400] : "#64748b"}>
                    Paiement standard
                  </Typography>
                </Box>
                <Box display="flex" alignItems="center" gap="12px">
                  <Typography fontWeight="bold" color={isDark ? colors.grey[100] : "#0f172a"}>
                    +{formatCurrency(tx.value)}
                  </Typography>
                  <Button
                    variant="outlined"
                    size="small"
                    onClick={() => {
                      setReceiptData({ ...historyRow, transaction: tx });
                      setIsReceiptDialogOpen(true);
                    }}
                    sx={{ ...getSecondaryButtonSx(colors, isDark), py: "2px", minWidth: "auto", fontSize: "11px" }}
                  >
                    Reçu
                  </Button>
                </Box>
              </Box>
            ))}
          </Box>
        )}
      </Box>
    );
  };

  // ── Column Definitions ──────────────────────────────────────────────────

  const columns = [
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

  // ── Render ──────────────────────────────────────────────────────────────

  return (
    <Box m="20px">
      {/* Header + Year Filter */}
      <Box display="flex" justifyContent="space-between" alignItems="center">
        <Header title="PAIEMENTS" />
        <FormControl variant="filled" sx={{ minWidth: 200, mb: "20px" }}>
          <InputLabel id="year-filter-label" sx={{ color: colors.grey[100] }}>
            Année Scolaire
          </InputLabel>
          <Select
            labelId="year-filter-label"
            value={selectedYear}
            onChange={(e) => setSelectedYear(e.target.value)}
            sx={{
              color: colors.grey[100],
              backgroundColor: colors.primary[400],
            }}
          >
            <MenuItem value="all">Toutes les années</MenuItem>
            {planningsList.map((p) => (
              <MenuItem key={p.id} value={p.id}>
                {p.label}
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      </Box>

      {error && (
        <Typography color={colors.redAccent[500]} mb="12px">
          {error}
        </Typography>
      )}

      {/* Stats Cards */}
      <StatsCards stats={stats} colors={colors} isDark={theme.palette.mode === "dark"} />

      {/* DataGrid */}
      <PaymentsDataGrid
        loading={loading}
        rows={filteredRows}
        columns={columns}
        colors={colors}
        isDark={theme.palette.mode === "dark"}
      />

      {/* Recent Transactions */}
      <RecentTransactionsPanel
        allTransactions={allTransactions}
        colors={colors}
      />

      {/* Transaction History Dialog */}
        <Dialog
        open={isHistoryDialogOpen}
        onClose={() => setIsHistoryDialogOpen(false)}
        fullWidth
        maxWidth="sm"
        PaperProps={{
          sx: {
            backgroundColor: isDark ? "#111c2d" : "#ffffff",
            color: isDark ? colors.grey[100] : "#0f172a",
            borderRadius: "12px",
            border: `1px solid ${isDark ? "rgba(148,163,184,0.18)" : "#e2e8f0"}`,
          },
        }}
      >
        <DialogTitle
          sx={{
            fontWeight: "bold",
            borderBottom: `1px solid ${isDark ? "rgba(148,163,184,0.18)" : "#e2e8f0"}`,
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          <Box>Détails & Paiements – {historyRow?.name}</Box>
          <Button
            variant="contained"
            size="small"
            onClick={() => {
              setInvoiceRow(historyRow);
              setIsInvoiceDialogOpen(true);
            }}
            sx={getPrimaryButtonSx(isDark)}
          >
            Facture
          </Button>
        </DialogTitle>
        <DialogContent sx={{ mt: 2 }}>
          {historyRow && historyRow.paymentMethod === "monthlyPartial" ? (
            <Box display="flex" flexDirection="column" gap="8px">
              {historyRow?.fraisAmount > 0 && (
                <Box
                  display="flex"
                  justifyContent="space-between"
                  p="10px 15px"
                  sx={getNeutralSurfaceSx(isDark)}
                >
                  <Box>
                    <Typography color={isDark ? colors.grey[200] : "#334155"}>
                      {historyRow.inscriptionDate}
                    </Typography>
                    <Typography
                      variant="caption"
                      color={isDark ? colors.grey[400] : "#64748b"}
                      fontWeight="bold"
                    >
                      Frais Annuel d'Inscription
                    </Typography>
                  </Box>
                  <Box display="flex" alignItems="center" gap="12px">
                    <Typography
                      fontWeight="bold"
                      color={isDark ? colors.grey[100] : "#0f172a"}
                    >
                      +{formatCurrency(historyRow.fraisAmount)}
                    </Typography>
                    <Button
                      variant="outlined"
                      size="small"
                      onClick={() => {
                        setReceiptData({
                          ...historyRow,
                          transaction: {
                            id: "FRAIS",
                            value: historyRow.fraisAmount,
                            payment_date: historyRow.inscriptionDate,
                            isFrais: true,
                          },
                        });
                        setIsReceiptDialogOpen(true);
                      }}
                      sx={{ ...getSecondaryButtonSx(colors, isDark), py: "2px", minWidth: "auto", fontSize: "11px" }}
                    >
                      Reçu
                    </Button>
                  </Box>
                </Box>
              )}
              {renderMonthlySchedule()}
            </Box>
          ) : (
            renderStandardPayments()
          )}
        </DialogContent>
        <DialogActions
          sx={{ p: 2, borderTop: `1px solid ${isDark ? "rgba(148,163,184,0.18)" : "#e2e8f0"}` }}
        >
          <Button
            onClick={() => setIsHistoryDialogOpen(false)}
            sx={{ color: isDark ? colors.grey[100] : "#334155" }}
          >
            Fermer
          </Button>
        </DialogActions>
      </Dialog>

      {/* Invoice & Receipt Dialogs */}
      <PaymentInvoiceDialog
        open={isInvoiceDialogOpen}
        onClose={() => setIsInvoiceDialogOpen(false)}
        invoiceData={invoiceRow}
        companyParams={companyParams}
      />
      <PaymentReceiptDialog
        open={isReceiptDialogOpen}
        onClose={() => setIsReceiptDialogOpen(false)}
        receiptData={receiptData}
        companyParams={companyParams}
      />

      {/* Confirmation Dialog */}
      <ConfirmPaymentDialog
        open={isConfirmPayOpen}
        onClose={() => setIsConfirmPayOpen(false)}
        confirmPayData={confirmPayData}
        txSubmitting={txSubmitting}
        onConfirmStandard={handleConfirmTransaction}
        onConfirmMonthly={handlePayMonth}
        colors={colors}
      />
    </Box>
  );
};

export default Payments;

// ─── Centralized Styles ─────────────────────────────────────────────────────

/**
 * getStyles
 * Returns a map of reusable sx-style objects keyed by widget name.
 * Keeps all DataGrid and repeated styling centralized at the bottom.
 * @param {object} colors - The theme color tokens.
 * @returns {object} Style map.
 */
function getStyles(colors, isDark) {
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
