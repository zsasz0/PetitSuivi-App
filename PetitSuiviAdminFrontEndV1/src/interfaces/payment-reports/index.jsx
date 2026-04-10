import {
  Box,
  Chip,
  Dialog,
  DialogContent,
  DialogTitle,
  FormControl,
  IconButton,
  MenuItem,
  Paper,
  Select,
  Skeleton,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Typography,
  useTheme,
} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";
import AccountBalanceWalletOutlinedIcon from "@mui/icons-material/AccountBalanceWalletOutlined";
import SavingsOutlinedIcon from "@mui/icons-material/SavingsOutlined";
import PendingActionsOutlinedIcon from "@mui/icons-material/PendingActionsOutlined";
import InsightsOutlinedIcon from "@mui/icons-material/InsightsOutlined";
import PaidOutlinedIcon from "@mui/icons-material/PaidOutlined";
import Header from "../../components/Header";
import { tokens } from "../../theme";
import { useEffect, useMemo, useRef, useState } from "react";
import api from "../../api/axios";
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Legend,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

const FINANCE_COLORS = {
  expected: "#243b6b",
  paid: "#17855d",
  pending: "#e68472",
  partial: "#c28c3b",
  future: "#cbd5e1",
};

const formatMonth = (value) => {
  if (typeof value !== "string" || !value.includes("-")) return value;
  const [year, month] = value.split("-");
  const date = new Date(Number(year), Number(month) - 1, 1);
  if (Number.isNaN(date.getTime())) return value;
  return date.toLocaleDateString("fr-FR", { month: "short", year: "numeric" });
};

const formatAmount = (value) => Number(value || 0).toLocaleString("fr-FR");

const getCurrentPlanningId = (planningList) => {
  if (!planningList.length) return "";

  const today = new Date().toISOString().slice(0, 10);
  const currentPlanning = planningList.find(
    (planning) => (planning.startDate || planning.start_date) <= today && (planning.endDate || planning.end_date) >= today
  );

  return currentPlanning ? currentPlanning.id : planningList[0].id;
};

const isFutureMonth = (monthKey) => {
  if (typeof monthKey !== "string" || !monthKey.includes("-")) return false;
  const [year, month] = monthKey.split("-").map(Number);
  const monthDate = new Date(year, month - 1, 1);
  if (Number.isNaN(monthDate.getTime())) return false;

  const current = new Date();
  const currentMonth = new Date(current.getFullYear(), current.getMonth(), 1);
  return monthDate > currentMonth;
};

const PlanningToolbar = ({ colors, isDark, plannings, selectedPlanningId, setSelectedPlanningId }) => {
  const styles = getStyles(colors, isDark);

  return (
    <Box sx={styles.toolbarShell}>
      <Box sx={styles.toolbarGroup}>
        <Typography sx={styles.toolbarLabel}>Année scolaire</Typography>
        <FormControl variant="outlined" size="small" sx={styles.selectControl}>
          <Select value={selectedPlanningId} onChange={(event) => setSelectedPlanningId(event.target.value)}>
            {plannings.map((planning) => (
              <MenuItem key={planning.id} value={planning.id}>
                {planning.label}
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      </Box>
    </Box>
  );
};

const SummaryCards = ({ colors, isDark, summary }) => {
  const styles = getStyles(colors, isDark);
  const items = [
    {
      label: "Revenus attendus",
      value: summary?.total_expected || 0,
      color: FINANCE_COLORS.expected,
      icon: AccountBalanceWalletOutlinedIcon,
    },
    {
      label: "Revenus collectés",
      value: summary?.total_paid || 0,
      color: FINANCE_COLORS.paid,
      icon: SavingsOutlinedIcon,
    },
    {
      label: "En attente",
      value: summary?.total_pending || 0,
      color: FINANCE_COLORS.pending,
      icon: PendingActionsOutlinedIcon,
    },
  ];

  return (
    <Box sx={styles.summaryGrid}>
      {items.map(({ label, value, color, icon: Icon }) => (
        <Box key={label} sx={styles.summaryCard(color)}>
          <Box sx={styles.summaryCardTopRow}>
            <Box>
              <Typography sx={styles.summaryLabel}>{label}</Typography>
              <Typography sx={styles.summaryValue}>
                {formatAmount(value)}
                <Typography component="span" sx={styles.summaryCurrency}>
                  TND
                </Typography>
              </Typography>
            </Box>
            <Box sx={styles.summaryIconWrap(color)}>
              <Icon sx={{ fontSize: 20, color }} />
            </Box>
          </Box>
        </Box>
      ))}
    </Box>
  );
};

const LoadingSkeleton = ({ colors, isDark }) => {
  const styles = getStyles(colors, isDark);

  return (
    <>
      <Box sx={styles.summaryGrid}>
        {[1, 2, 3].map((item) => (
          <Box key={item} sx={styles.summarySkeletonCard}>
            <Skeleton variant="text" width="44%" height={22} />
            <Skeleton variant="text" width="58%" height={42} />
          </Box>
        ))}
      </Box>

      <Box sx={styles.chartsGrid}>
        {[1, 2].map((item) => (
          <Box key={item} sx={styles.chartCard}>
            <Skeleton variant="text" width="48%" height={28} />
            <Skeleton variant="rectangular" height={280} sx={{ borderRadius: "18px", mt: 1.5 }} />
          </Box>
        ))}
      </Box>

      <Box sx={styles.chartCard}>
        <Skeleton variant="text" width="32%" height={28} />
        <Skeleton variant="text" width="44%" height={22} />
        <Skeleton variant="rectangular" height={320} sx={{ borderRadius: "18px", mt: 1.5 }} />
      </Box>
    </>
  );
};

const FinanceTooltip = ({ active, payload, label, isMonthly = false }) => {
  if (!active || !payload?.length) return null;

  return (
    <Box
      sx={{
        backgroundColor: "rgba(15, 23, 32, 0.96)",
        color: "#f8fafc",
        border: "1px solid rgba(148, 163, 184, 0.18)",
        borderRadius: "14px",
        p: "10px 12px",
        minWidth: 160,
        boxShadow: "0 16px 28px rgba(2, 6, 23, 0.28)",
      }}
    >
      <Typography sx={{ fontSize: "0.8rem", fontWeight: 700, mb: 0.75 }}>{isMonthly ? formatMonth(label) : label}</Typography>
      {payload.map((entry) => (
        <Box key={entry.dataKey || entry.name} display="flex" alignItems="center" justifyContent="space-between" gap="12px" mb={0.5}>
          <Box display="flex" alignItems="center" gap="8px">
            <Box sx={{ width: 8, height: 8, borderRadius: "999px", backgroundColor: entry.color || entry.fill }} />
            <Typography sx={{ fontSize: "0.78rem", color: "rgba(248,250,252,0.76)" }}>{entry.name}</Typography>
          </Box>
          <Typography sx={{ fontSize: "0.82rem", fontWeight: 700 }}>{formatAmount(entry.value)}</Typography>
        </Box>
      ))}
    </Box>
  );
};

const MonthlyLegend = ({ colors, isDark, payload }) => {
  const styles = getStyles(colors, isDark);

  if (!payload?.length) return null;

  return (
    <Box sx={styles.monthlyLegendRow}>
      {payload.map((entry) => {
        const label = entry.value || entry.dataKey;
        const color = label === "Non payé" ? FINANCE_COLORS.pending : FINANCE_COLORS.paid;

        return (
          <Box key={label} sx={styles.monthlyLegendItem}>
            <Box sx={styles.monthlyLegendMarker(color)} />
            <Typography sx={styles.monthlyLegendText(color)}>{label}</Typography>
          </Box>
        );
      })}
    </Box>
  );
};

const CollectionProgressCard = ({ colors, isDark, summary }) => {
  const styles = getStyles(colors, isDark);
  const totalExpected = Number(summary?.total_expected || 0);
  const totalPaid = Number(summary?.total_paid || 0);
  const totalPending = Number(summary?.total_pending || 0);
  const paidPercent = totalExpected > 0 ? Math.min((totalPaid / totalExpected) * 100, 100) : 0;
  const pendingPercent = totalExpected > 0 ? Math.min((totalPending / totalExpected) * 100, 100) : 0;

  return (
    <Box sx={[styles.chartCard, styles.progressCard]}>
      <Box sx={styles.progressCardBody}>
        <Box sx={styles.sectionTitleRow}>
          <Box>
            <Typography sx={styles.sectionTitle}>Progression de collecte</Typography>
            <Typography sx={styles.sectionSubtitle}>Lecture rapide du montant collecté par rapport au revenu attendu.</Typography>
          </Box>
          <Box sx={styles.metricBadgeWrap}>
            <InsightsOutlinedIcon sx={{ fontSize: 18, color: colors.greenAccent[400] }} />
          </Box>
        </Box>

        <Box sx={styles.progressTrack}>
          <Box sx={styles.progressPaid(paidPercent)} />
          <Box sx={styles.progressPending(Math.max(0, pendingPercent), paidPercent)} />
        </Box>

        <Box sx={styles.progressLegendRow}>
          <Box sx={styles.progressLegendItem}>
            <Box sx={styles.progressLegendDot(FINANCE_COLORS.paid)} />
            <Typography sx={styles.progressLegendLabel}>Collecté</Typography>
            <Typography sx={styles.progressLegendValue}>{paidPercent.toFixed(1)}%</Typography>
          </Box>
          <Box sx={styles.progressLegendItem}>
            <Box sx={styles.progressLegendDot(FINANCE_COLORS.pending)} />
            <Typography sx={styles.progressLegendLabel}>En attente</Typography>
            <Typography sx={styles.progressLegendValue}>{pendingPercent.toFixed(1)}%</Typography>
          </Box>
        </Box>
      </Box>
    </Box>
  );
};

const PaymentStatusDonut = ({ colors, isDark, summary }) => {
  const styles = getStyles(colors, isDark);
  const data = [
    { name: "Payé", value: summary?.count_paid || 0, fill: FINANCE_COLORS.paid },
    { name: "Partiel", value: summary?.count_partial || 0, fill: FINANCE_COLORS.partial },
    { name: "En attente", value: summary?.count_pending || 0, fill: FINANCE_COLORS.pending },
  ];

  return (
    <Box sx={styles.chartCard}>
      <Box sx={styles.sectionTitleRow}>
        <Box>
          <Typography sx={styles.sectionTitle}>Distribution des statuts</Typography>
          <Typography sx={styles.sectionSubtitle}>Répartition des dossiers selon leur état de paiement.</Typography>
        </Box>
        <Box sx={styles.metricBadgeWrap}>
          <PaidOutlinedIcon sx={{ fontSize: 18, color: colors.greenAccent[400] }} />
        </Box>
      </Box>

      <Box sx={styles.donutWrap}>
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie data={data} dataKey="value" nameKey="name" cx="50%" cy="50%" innerRadius={76} outerRadius={104} paddingAngle={2} strokeWidth={2}>
              {data.map((entry) => (
                <Cell key={entry.name} fill={entry.fill} stroke={isDark ? "#0f1720" : "#f8fafc"} />
              ))}
            </Pie>
            <Tooltip content={<FinanceTooltip />} />
            <Legend verticalAlign="bottom" iconType="circle" wrapperStyle={{ paddingTop: 12 }} />
          </PieChart>
        </ResponsiveContainer>
        <Box sx={styles.donutCenterLabel}>
          <Typography sx={styles.donutCenterTitle}>Collecté</Typography>
          <Typography sx={styles.donutCenterValue}>{formatAmount(summary?.total_paid || 0)}</Typography>
          <Typography sx={styles.donutCenterCurrency}>TND</Typography>
        </Box>
      </Box>
    </Box>
  );
};

const MonthlyStatusChart = ({ colors, isDark, data, onMonthClick }) => {
  const styles = getStyles(colors, isDark);
  const chartWrapRef = useRef(null);

  const chartData = useMemo(
    () =>
      (data || []).map((item) => ({
        month: item.month,
        paid: item.paid || 0,
        pending: (item.pending || 0) + (item.partial || 0),
        futurePending: isFutureMonth(item.month) && (item.paid || 0) === 0 && ((item.pending || 0) + (item.partial || 0)) > 0,
      })),
    [data]
  );

  const updateHoveredMonthVisual = (month) => {
    const root = chartWrapRef.current;
    if (!root) return;

    const cells = root.querySelectorAll("[data-month-key]");

    cells.forEach((cell) => {
      const cellMonth = cell.getAttribute("data-month-key");
      const cellType = cell.getAttribute("data-bar-type");
      const isFuture = cell.getAttribute("data-future") === "true";
      const isActive = month && cellMonth === month;

      if (!month) {
        cell.style.opacity = "1";
        cell.style.stroke = isFuture ? "#cbd5e1" : "transparent";
        cell.style.strokeWidth = isFuture ? "1" : "0";
        return;
      }

      cell.style.opacity = isActive ? "1" : cellType === "paid" ? "0.24" : "0.18";

      if (isActive) {
        cell.style.stroke = cellType === "paid"
          ? "rgba(23,133,93,0.68)"
          : isFuture
            ? "#cbd5e1"
            : "rgba(230,132,114,0.68)";
        cell.style.strokeWidth = "1";
      } else {
        cell.style.stroke = isFuture ? "#cbd5e1" : "transparent";
        cell.style.strokeWidth = isFuture ? "1" : "0";
      }
    });
  };

  return (
    <Box sx={styles.chartCard}>
      <Box sx={styles.sectionTitleRow}>
        <Box>
          <Typography sx={styles.sectionTitle}>Statut des paiements mensuels</Typography>
          <Typography sx={styles.sectionSubtitle}>Les mois à venir sont affichés avec un motif neutre plutôt qu'un signal d'alerte.</Typography>
        </Box>
        <Box sx={styles.helperPill}>Cliquer pour ouvrir le détail</Box>
      </Box>

      <Box sx={{ height: 340 }} ref={chartWrapRef} onMouseLeave={() => updateHoveredMonthVisual(null)}>
        {chartData.length > 0 ? (
          <ResponsiveContainer width="100%" height="100%">
            <BarChart
              data={chartData}
              margin={{ top: 20, right: 16, left: 0, bottom: 12 }}
            >
              <defs>
                <pattern id="futurePendingPattern" width="8" height="8" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
                  <rect width="8" height="8" fill="#eef2f7" />
                  <line x1="0" y1="0" x2="0" y2="8" stroke="#cbd5e1" strokeWidth="4" />
                </pattern>
              </defs>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke={isDark ? "rgba(148,163,184,0.14)" : "rgba(148,163,184,0.26)"} />
              <XAxis dataKey="month" tick={{ fill: colors.grey[300], fontSize: 12 }} tickFormatter={formatMonth} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: colors.grey[300], fontSize: 12 }} axisLine={false} tickLine={false} />
              <Tooltip content={<FinanceTooltip isMonthly />} isAnimationActive={false} />
              <Legend verticalAlign="top" height={36} content={<MonthlyLegend colors={colors} isDark={isDark} />} />
              <Bar dataKey="paid" name="Payé" stackId="payments" radius={[8, 8, 0, 0]} isAnimationActive={false}>
                {chartData.map((entry) => (
                  <Cell
                    key={`paid-${entry.month}`}
                    fill={FINANCE_COLORS.paid}
                    data-month-key={entry.month}
                    data-bar-type="paid"
                    data-future="false"
                    onMouseEnter={() => updateHoveredMonthVisual(entry.month)}
                    onClick={() => onMonthClick(entry)}
                    style={{ cursor: "pointer" }}
                  />
                ))}
              </Bar>
              <Bar dataKey="pending" name="Non payé" stackId="payments" radius={[8, 8, 0, 0]} isAnimationActive={false}>
                {chartData.map((entry) => (
                  <Cell
                    key={`pending-${entry.month}`}
                    fill={entry.futurePending ? "url(#futurePendingPattern)" : FINANCE_COLORS.pending}
                    stroke={entry.futurePending ? "#cbd5e1" : "transparent"}
                    strokeWidth={entry.futurePending ? 1 : 0}
                    data-month-key={entry.month}
                    data-bar-type="pending"
                    data-future={entry.futurePending ? "true" : "false"}
                    onMouseEnter={() => updateHoveredMonthVisual(entry.month)}
                    onClick={() => onMonthClick(entry)}
                    style={{ cursor: "pointer" }}
                  />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        ) : (
          <Box sx={styles.emptyChartState}>
            <Typography sx={styles.emptyChartTitle}>Aucune donnée disponible</Typography>
            <Typography sx={styles.emptyChartText}>Les données mensuelles apparaîtront ici dès qu'elles seront disponibles.</Typography>
          </Box>
        )}
      </Box>
    </Box>
  );
};

const ParentTableSection = ({ colors, isDark, list, title, color }) => {
  const styles = getStyles(colors, isDark);
  if (!list?.length) return null;

  return (
    <Box sx={{ mb: 2.5 }}>
      <Box display="flex" alignItems="center" gap="10px" mb="10px">
        <Chip label={`${title} (${list.length})`} sx={styles.statusChip(color)} />
      </Box>
      <TableContainer component={Paper} elevation={0} sx={styles.modalTableWrap}>
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell sx={styles.headCell}>Enfant</TableCell>
              <TableCell sx={styles.headCell}>Parent</TableCell>
              <TableCell sx={styles.headCell}>Téléphone</TableCell>
              <TableCell align="right" sx={styles.headCell}>Attendu</TableCell>
              <TableCell align="right" sx={styles.headCellLast}>Payé</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {list.map((item, index) => (
              <TableRow key={`${item.child_name}-${index}`} sx={styles.modalTableRow}>
                <TableCell sx={styles.bodyCell}>{item.child_name}</TableCell>
                <TableCell sx={styles.bodyCell}>{item.parent_name || "-"}</TableCell>
                <TableCell sx={styles.bodyCell}>{item.parent_phone || "-"}</TableCell>
                <TableCell align="right" sx={styles.amountCellExpected}>{formatAmount(item.expected_monthly || 0)} TND</TableCell>
                <TableCell align="right" sx={styles.amountCellPaid}>{formatAmount(item.paid_amount || 0)} TND</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
};

const ModalSkeleton = ({ colors, isDark }) => {
  return (
    <Box>
      <Box display="flex" gap="12px" mb="18px" flexWrap="wrap">
        <Skeleton variant="rounded" width={160} height={32} />
        <Skeleton variant="rounded" width={160} height={32} />
      </Box>
      {[1, 2].map((item) => (
        <Box key={item} sx={{ mb: 2.5 }}>
          <Skeleton variant="text" width="28%" height={24} />
          <Skeleton variant="rectangular" height={160} sx={{ borderRadius: "16px", mt: 1 }} />
        </Box>
      ))}
    </Box>
  );
};

const PaymentReports = () => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";
  const styles = getStyles(colors, isDark);

  const [plannings, setPlannings] = useState([]);
  const [selectedPlanningId, setSelectedPlanningId] = useState("");
  const [reportData, setReportData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [modalOpen, setModalOpen] = useState(false);
  const [modalMonth, setModalMonth] = useState("");
  const [modalData, setModalData] = useState(null);
  const [modalLoading, setModalLoading] = useState(false);

  useEffect(() => {
    const fetchPlannings = async () => {
      try {
        const response = await api.get("/admin/plannings");
        const planningList = response.data?.data || [];
        setPlannings(planningList);
        setSelectedPlanningId(getCurrentPlanningId(planningList));
      } catch (error) {
        console.error(error);
      }
    };

    fetchPlannings();
  }, []);

  useEffect(() => {
    if (!selectedPlanningId) return;

    const fetchReport = async () => {
      setLoading(true);
      try {
        const response = await api.get(`/admin/plannings/${selectedPlanningId}/payment-report`);
        setReportData(response.data);
      } catch (error) {
        console.error(error);
      } finally {
        setLoading(false);
      }
    };

    fetchReport();
  }, [selectedPlanningId]);

  const handleMonthClick = async (payload) => {
    const month = payload?.month || payload?.activePayload?.[0]?.payload?.month;
    if (!month) return;

    setModalMonth(month);
    setModalOpen(true);
    setModalLoading(true);
    setModalData(null);

    try {
      const response = await api.get(`/admin/plannings/${selectedPlanningId}/payment-report/month/${month}`);
      setModalData(response.data);
    } catch (error) {
      console.error(error);
    } finally {
      setModalLoading(false);
    }
  };

  return (
    <Box m="20px">
      <Header title="RAPPORTS FINANCIERS" />

      <PlanningToolbar
        colors={colors}
        isDark={isDark}
        plannings={plannings}
        selectedPlanningId={selectedPlanningId}
        setSelectedPlanningId={setSelectedPlanningId}
      />

      {loading ? (
        <LoadingSkeleton colors={colors} isDark={isDark} />
      ) : reportData ? (
        <>
          <SummaryCards colors={colors} isDark={isDark} summary={reportData.summary} />

          <Box sx={styles.chartsGrid}>
            <PaymentStatusDonut colors={colors} isDark={isDark} summary={reportData.summary} />
            <CollectionProgressCard colors={colors} isDark={isDark} summary={reportData.summary} />
          </Box>

          <MonthlyStatusChart
            colors={colors}
            isDark={isDark}
            data={reportData.monthly_status_data}
            onMonthClick={handleMonthClick}
          />
        </>
      ) : (
        <Box sx={styles.emptyChartState}>
          <Typography sx={styles.emptyChartTitle}>Aucun rapport financier disponible</Typography>
          <Typography sx={styles.emptyChartText}>Les statistiques financières apparaîtront ici une fois les données chargées.</Typography>
        </Box>
      )}

      <Dialog
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        maxWidth="lg"
        fullWidth
        slotProps={{
          backdrop: {
            sx: {
              backgroundColor: "rgba(2, 6, 23, 0.68)",
              backdropFilter: "blur(8px)",
            },
          },
        }}
        PaperProps={{ sx: styles.modalPaper }}
      >
        <DialogTitle sx={styles.modalTitleRow}>
          <Box>
            <Typography sx={styles.modalTitle}>Détail des paiements</Typography>
            <Typography sx={styles.modalSubtitle}>{formatMonth(modalMonth)}</Typography>
          </Box>
          <IconButton onClick={() => setModalOpen(false)} sx={styles.modalCloseButton}>
            <CloseIcon />
          </IconButton>
        </DialogTitle>
        <DialogContent sx={{ px: { xs: 2, md: 3 }, pb: 3 }}>
          {modalLoading ? (
            <ModalSkeleton colors={colors} isDark={isDark} />
          ) : modalData ? (
            <Box>
              <ParentTableSection
                colors={colors}
                isDark={isDark}
                list={modalData.paid_fully}
                title="Payé"
                color={FINANCE_COLORS.paid}
              />
              <ParentTableSection
                colors={colors}
                isDark={isDark}
                list={modalData.paid_partially}
                title="Partiellement payé"
                color={FINANCE_COLORS.partial}
              />
              <ParentTableSection
                colors={colors}
                isDark={isDark}
                list={modalData.not_paid}
                title="Non payé"
                color={FINANCE_COLORS.pending}
              />

              {!modalData.paid_fully?.length && !modalData.paid_partially?.length && !modalData.not_paid?.length && (
                <Box sx={styles.emptyChartState}>
                  <Typography sx={styles.emptyChartTitle}>Aucune inscription mensuelle</Typography>
                  <Typography sx={styles.emptyChartText}>Aucune ligne de paiement n'a été trouvée pour ce mois.</Typography>
                </Box>
              )}
            </Box>
          ) : (
            <Box sx={styles.emptyChartState}>
              <Typography sx={styles.emptyChartTitle}>Erreur de chargement</Typography>
              <Typography sx={styles.emptyChartText}>Les données de détail n'ont pas pu être récupérées pour ce mois.</Typography>
            </Box>
          )}
        </DialogContent>
      </Dialog>
    </Box>
  );
};

export default PaymentReports;

function getStyles(colors, isDark) {
  const surface = isDark ? "rgba(15, 23, 32, 0.88)" : "rgba(255, 255, 255, 0.82)";
  const surfaceAlt = isDark ? "rgba(19, 28, 39, 0.92)" : "#f8fafc";
  const border = isDark ? "rgba(148, 163, 184, 0.16)" : "rgba(148, 163, 184, 0.28)";

  return {
    toolbarShell: {
      mb: "18px",
      px: { xs: "14px", md: "18px" },
      py: { xs: "14px", md: "16px" },
      borderRadius: "18px",
      background: surface,
      border: `1px solid ${border}`,
      display: "flex",
      alignItems: { xs: "stretch", md: "center" },
      justifyContent: "space-between",
      gap: "14px",
      flexDirection: { xs: "column", md: "row" },
      boxShadow: isDark ? "0 16px 30px rgba(2, 6, 23, 0.24)" : "0 14px 28px rgba(148, 163, 184, 0.16)",
    },
    toolbarGroup: {
      display: "flex",
      alignItems: { xs: "stretch", sm: "center" },
      gap: "12px",
      flexDirection: { xs: "column", sm: "row" },
    },
    toolbarLabel: {
      fontSize: "0.82rem",
      fontWeight: 700,
      color: colors.grey[300],
      whiteSpace: "nowrap",
    },
    selectControl: {
      minWidth: 210,
      "& .MuiOutlinedInput-root": {
        borderRadius: "12px",
        backgroundColor: surfaceAlt,
      },
    },
    summaryGrid: {
      display: "grid",
      gridTemplateColumns: { xs: "1fr", md: "repeat(3, minmax(0, 1fr))" },
      gap: "16px",
      mb: "18px",
    },
    summaryCard: (color) => ({
      p: "22px 22px 24px",
      borderRadius: "20px",
      background: surface,
      border: `1px solid ${border}`,
      borderLeft: `4px solid ${color}`,
      boxShadow: isDark ? "0 18px 34px rgba(2, 6, 23, 0.28)" : "0 16px 32px rgba(148, 163, 184, 0.18)",
    }),
    summaryCardTopRow: {
      display: "flex",
      alignItems: "flex-start",
      justifyContent: "space-between",
      gap: "16px",
    },
    summaryLabel: {
      fontSize: "0.82rem",
      fontWeight: 700,
      color: colors.grey[400],
      textTransform: "uppercase",
      letterSpacing: "0.04em",
      mb: "10px",
    },
    summaryValue: {
      fontSize: { xs: "1.5rem", md: "1.7rem" },
      lineHeight: 1.1,
      fontWeight: 800,
      color: colors.grey[100],
    },
    summaryCurrency: {
      ml: 1,
      fontSize: "0.78rem",
      fontWeight: 700,
      color: colors.grey[400],
      letterSpacing: "0.04em",
      textTransform: "uppercase",
    },
    summaryIconWrap: (color) => ({
      width: 42,
      height: 42,
      borderRadius: "14px",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      backgroundColor: isDark ? "rgba(255,255,255,0.04)" : "rgba(15,23,42,0.04)",
      border: `1px solid ${isDark ? "rgba(255,255,255,0.06)" : "rgba(15,23,42,0.06)"}`,
      boxShadow: `inset 0 0 0 1px ${color}14`,
    }),
    summarySkeletonCard: {
      p: "22px 22px 24px",
      borderRadius: "20px",
      background: surface,
      border: `1px solid ${border}`,
    },
    chartsGrid: {
      display: "grid",
      gridTemplateColumns: { xs: "1fr", xl: "repeat(2, minmax(0, 1fr))" },
      gap: "18px",
      mb: "18px",
    },
    chartCard: {
      p: { xs: "18px", md: "22px" },
      borderRadius: "22px",
      background: surface,
      border: `1px solid ${border}`,
      boxShadow: isDark ? "0 18px 34px rgba(2, 6, 23, 0.28)" : "0 16px 32px rgba(148, 163, 184, 0.18)",
    },
    progressCard: {
      display: "flex",
      flexDirection: "column",
    },
    progressCardBody: {
      width: "100%",
      my: "auto",
    },
    sectionTitleRow: {
      display: "flex",
      alignItems: "flex-start",
      justifyContent: "space-between",
      gap: "12px",
      mb: "16px",
      flexWrap: "wrap",
    },
    sectionTitle: {
      fontSize: "1rem",
      fontWeight: 800,
      color: colors.grey[100],
    },
    sectionSubtitle: {
      mt: "4px",
      fontSize: "0.84rem",
      color: colors.grey[400],
      maxWidth: 460,
      lineHeight: 1.6,
    },
    metricBadgeWrap: {
      width: 36,
      height: 36,
      borderRadius: "14px",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      backgroundColor: isDark ? "rgba(45, 212, 191, 0.10)" : "rgba(13, 148, 136, 0.08)",
      border: `1px solid ${isDark ? "rgba(45, 212, 191, 0.16)" : "rgba(13, 148, 136, 0.14)"}`,
    },
    donutWrap: {
      position: "relative",
      height: 320,
    },
    donutCenterLabel: {
      position: "absolute",
      top: "50%",
      left: "50%",
      transform: "translate(-50%, -50%)",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      pointerEvents: "none",
    },
    donutCenterTitle: {
      fontSize: "0.75rem",
      color: colors.grey[400],
      textTransform: "uppercase",
      letterSpacing: "0.04em",
      mb: "2px",
    },
    donutCenterValue: {
      fontSize: "1.25rem",
      fontWeight: 800,
      color: colors.grey[100],
      lineHeight: 1.1,
    },
    donutCenterCurrency: {
      fontSize: "0.72rem",
      color: colors.grey[400],
      textTransform: "uppercase",
      letterSpacing: "0.05em",
      mt: "2px",
    },
    progressTrack: {
      position: "relative",
      height: 16,
      borderRadius: "999px",
      overflow: "hidden",
      backgroundColor: isDark ? "rgba(51, 65, 85, 0.52)" : "#e2e8f0",
      mb: "18px",
    },
    progressPaid: (width) => ({
      position: "absolute",
      inset: 0,
      width: `${width}%`,
      background: `linear-gradient(90deg, ${FINANCE_COLORS.paid}, #22a06b)`,
    }),
    progressPending: (width, offset) => ({
      position: "absolute",
      top: 0,
      bottom: 0,
      left: `${offset}%`,
      width: `${width}%`,
      background: `linear-gradient(90deg, ${FINANCE_COLORS.pending}, #f29b88)`,
    }),
    progressLegendRow: {
      display: "flex",
      gap: "14px",
      flexWrap: "wrap",
      mb: "18px",
    },
    progressLegendItem: {
      display: "flex",
      alignItems: "center",
      gap: "8px",
      backgroundColor: surfaceAlt,
      border: `1px solid ${border}`,
      borderRadius: "999px",
      px: "12px",
      py: "8px",
    },
    progressLegendDot: (color) => ({
      width: 8,
      height: 8,
      borderRadius: "999px",
      backgroundColor: color,
    }),
    progressLegendLabel: {
      fontSize: "0.8rem",
      color: colors.grey[400],
    },
    progressLegendValue: {
      fontSize: "0.8rem",
      fontWeight: 800,
      color: colors.grey[100],
    },
    monthlyLegendRow: {
      display: "flex",
      alignItems: "center",
      gap: "16px",
      paddingBottom: "6px",
      flexWrap: "wrap",
    },
    monthlyLegendItem: {
      display: "flex",
      alignItems: "center",
      gap: "8px",
    },
    monthlyLegendMarker: (color) => ({
      width: 9,
      height: 9,
      borderRadius: "999px",
      backgroundColor: color,
      boxShadow: `0 0 0 3px ${color}1f`,
    }),
    monthlyLegendText: (color) => ({
      fontSize: "0.82rem",
      fontWeight: 700,
      color,
    }),
    helperPill: {
      px: "12px",
      py: "8px",
      borderRadius: "999px",
      border: `1px solid ${border}`,
      backgroundColor: surfaceAlt,
      fontSize: "0.78rem",
      fontWeight: 700,
      color: colors.grey[300],
    },
    emptyChartState: {
      minHeight: 220,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      textAlign: "center",
      gap: "8px",
      px: "20px",
    },
    emptyChartTitle: {
      fontSize: "1rem",
      fontWeight: 800,
      color: colors.grey[100],
    },
    emptyChartText: {
      fontSize: "0.84rem",
      color: colors.grey[400],
      maxWidth: 440,
      lineHeight: 1.6,
    },
    modalPaper: {
      backgroundColor: isDark ? "rgba(11, 18, 29, 0.94)" : "rgba(255, 255, 255, 0.96)",
      backgroundImage: "none",
      borderRadius: "24px",
      border: `1px solid ${border}`,
      boxShadow: "0 32px 64px rgba(2,6,23,0.34)",
      overflow: "hidden",
    },
    modalTitleRow: {
      display: "flex",
      justifyContent: "space-between",
      alignItems: "center",
      gap: "12px",
      px: { xs: 2, md: 3 },
      py: { xs: 2, md: 2.5 },
    },
    modalTitle: {
      fontSize: "1.05rem",
      fontWeight: 800,
      color: colors.grey[100],
    },
    modalSubtitle: {
      mt: "4px",
      fontSize: "0.84rem",
      color: colors.grey[400],
    },
    modalCloseButton: {
      color: colors.grey[300],
      border: `1px solid ${border}`,
      backgroundColor: surfaceAlt,
      "&:hover": {
        backgroundColor: isDark ? "rgba(30, 41, 59, 0.92)" : "#eef2f7",
      },
    },
    statusChip: (color) => ({
      backgroundColor: `${color}20`,
      color,
      fontWeight: 800,
      border: `1px solid ${color}40`,
    }),
    modalTableWrap: {
      backgroundColor: surfaceAlt,
      borderRadius: "18px",
      border: `1px solid ${border}`,
    },
    headCell: {
      color: colors.grey[300],
      fontWeight: 800,
      fontSize: "0.78rem",
      textTransform: "uppercase",
      letterSpacing: "0.04em",
      borderBottom: `1px solid ${border}`,
      backgroundColor: isDark ? "rgba(148, 163, 184, 0.08)" : "#eef2f7",
    },
    headCellLast: {
      color: colors.grey[300],
      fontWeight: 800,
      fontSize: "0.78rem",
      textTransform: "uppercase",
      letterSpacing: "0.04em",
      borderBottom: `1px solid ${border}`,
      backgroundColor: isDark ? "rgba(148, 163, 184, 0.08)" : "#eef2f7",
    },
    modalTableRow: {
      "&:hover": {
        backgroundColor: isDark ? "rgba(30, 41, 59, 0.48)" : "rgba(241, 245, 249, 0.92)",
      },
    },
    bodyCell: {
      color: colors.grey[100],
      borderBottom: `1px solid ${border}`,
    },
    amountCellExpected: {
      color: FINANCE_COLORS.expected,
      fontWeight: 700,
      borderBottom: `1px solid ${border}`,
    },
    amountCellPaid: {
      color: FINANCE_COLORS.paid,
      fontWeight: 700,
      borderBottom: `1px solid ${border}`,
    },
  };
}
