/**
 * @file dashboard/index.jsx
 * @description Central administrative Dashboard hub.
 * Orchestrates concurrent API requests to gather metrics from Personnel, Financial, and Academic subsystems.
 * 
 * Connected Backend APIs:
 * - GET /api/admin/parents (List of registered parents)
 * - GET /api/admin/teachers (List of registered teachers)
 * - GET /api/admin/classes (List of school classes)
 * - GET /api/admin/inscriptions (Recent student registrations)
 * - GET /api/admin/payments (Financial transaction history)
 * - GET /api/admin/plannings (Academic year plannings)
 * - GET /api/admin/events/upcoming (Future events calendar)
 * - GET /api/admin/dashboard/stats (System flags like year archiving status)
 */
import { Box, Typography, useTheme, CircularProgress, Alert } from "@mui/material";
import { PieChart, Pie, Cell, ResponsiveContainer } from "recharts";
import { tokens } from "../../theme";
import Header from "../../components/Header";
import StatBox from "../../components/StatBox";
import ChildCareIcon from "@mui/icons-material/ChildCare";
import SchoolIcon from "@mui/icons-material/School";
import PeopleIcon from "@mui/icons-material/People";
import ClassIcon from "@mui/icons-material/Class";
import WarningAmberIcon from "@mui/icons-material/WarningAmber";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import api from "../../api/axios";

// -----------------------------------------------------------------------------
// Pure Presentation Sub-Components
// -----------------------------------------------------------------------------

const RecentInscriptionsFeed = ({ inscriptions, colors, isDark }) => (
  <Box
    gridColumn={{ xs: "span 12", xl: "span 6" }}
    gridRow="span 2"
    backgroundColor={colors.primary[400]}
    overflow="auto"
    borderRadius="16px"
    sx={{
      boxShadow: "0 10px 24px rgba(0,0,0,0.07)",
      border: isDark ? "1px solid rgba(255,255,255,0.06)" : "1px solid rgba(148,163,184,0.16)",
    }}
  >
    <Box
      display="flex"
      justifyContent="space-between"
      alignItems="flex-start"
      borderBottom={`1px solid ${colors.primary[500]}`}
      p="14px 16px"
    >
      <Box>
        <Typography color={colors.grey[100]} variant="h6" fontWeight="700">
        8 dernières inscriptions enregistrées
        </Typography>
        <Typography color={colors.grey[300]} variant="body2" sx={{ mt: "4px", fontSize: "0.82rem" }}>
          Vue rapide des derniers dossiers ajoutés.
        </Typography>
      </Box>
      <Box
        px="9px"
        py="5px"
        borderRadius="999px"
        sx={{ backgroundColor: colors.primary[500], color: colors.grey[200], fontSize: "11px", fontWeight: 700 }}
      >
        {inscriptions.length} affichées
      </Box>
    </Box>
    {inscriptions.length === 0 ? (
      <Typography color={colors.grey[300]} p="20px" textAlign="center">Aucune inscription récente.</Typography>
    ) : (
      inscriptions.map((insc, i) => {
        const childName = insc.child_full_name || `${insc.child?.firstName || ''} ${insc.child?.lastName || ''}`.trim() || 'Inconnu';
        const rawDate = insc.inscription_date || insc.date || null;
        const date = rawDate ? new Date(rawDate).toLocaleDateString("fr-FR", { day: "2-digit", month: "short", year: "numeric" }) : '-';
        const status = (insc.status?.name || insc.inscription_status?.name || insc.status || 'pending').toLowerCase();
        const statusColor = status === 'approved' ? colors.greenAccent[500] : status === 'rejected' ? colors.redAccent[500] : '#f59e0b';
        const statusLabel = status === 'approved' ? 'Approuvée' : status === 'rejected' ? 'Rejetée' : 'En attente';
        return (
          <Box
            key={`insc-${i}`}
            display="flex"
            alignItems="center"
            gap="12px"
            p="12px 16px"
            sx={{
              mx: "10px",
              mt: i === 0 ? "10px" : 0,
              mb: i === inscriptions.length - 1 ? "10px" : "8px",
              borderRadius: "14px",
              backgroundColor: isDark ? "rgba(255,255,255,0.03)" : "rgba(255,255,255,0.78)",
              boxShadow: isDark ? "0 8px 18px rgba(0,0,0,0.18)" : "0 8px 20px rgba(15, 23, 42, 0.06)",
              border: isDark ? "1px solid rgba(255,255,255,0.05)" : "1px solid rgba(148,163,184,0.18)",
            }}
          >
            <Box
              width="36px"
              height="36px"
              borderRadius="12px"
              display="flex"
              alignItems="center"
              justifyContent="center"
              sx={{
                background: isDark
                  ? `linear-gradient(135deg, ${colors.greenAccent[800]}, ${colors.primary[500]})`
                  : "linear-gradient(135deg, rgba(22,163,74,0.18), rgba(134,239,172,0.42))",
                color: isDark ? colors.greenAccent[300] : "#166534",
                fontWeight: 700,
              }}
            >
              {childName.charAt(0).toUpperCase()}
            </Box>
            <Box flex="1" minWidth={0}>
              <Typography color={colors.grey[100]} variant="body1" fontWeight="700" noWrap>
                {childName}
              </Typography>
              <Typography color={colors.grey[300]} variant="body2" noWrap sx={{ fontSize: "0.8rem" }}>
                {insc.class?.name || 'Classe non assignée'}
              </Typography>
            </Box>
            <Box display="flex" flexDirection="column" alignItems="flex-end" gap="6px" flexShrink={0}>
              <Box
                px="9px"
                py="4px"
                borderRadius="999px"
                sx={{ backgroundColor: colors.primary[500], color: colors.grey[100], fontSize: "11px", fontWeight: 600 }}
              >
                {date}
              </Box>
              <Box backgroundColor={statusColor} p="4px 9px" borderRadius="999px" color="#fff" fontWeight="bold" fontSize="11px">
                {statusLabel}
              </Box>
            </Box>
          </Box>
        );
      })
    )}
  </Box>
);

const FinancialBilanWidget = ({ stats, revenuePct, colors }) => {
  const theme = useTheme();
  const isDark = theme.palette.mode === "dark";
  const pendingAmount = Math.max(0, stats.revenueExpected - stats.revenueCollected);
  const pendingColor = isDark ? colors.redAccent[400] : "#d66a63";
  const chartData = [
    { name: "Collecté", value: stats.revenueCollected },
    { name: "En attente", value: pendingAmount },
  ].filter((item) => item.value > 0);

  return (
    <Box gridColumn="span 12" gridRow="span 2" backgroundColor={colors.primary[400]} p="18px" borderRadius="16px" sx={{ boxShadow: "0 10px 24px rgba(0,0,0,0.07)", border: isDark ? "1px solid rgba(255,255,255,0.06)" : "1px solid rgba(148,163,184,0.16)" }}>
      <Typography variant="h6" fontWeight="700" mb="16px" color={colors.grey[100]}>
        Bilan Financier (Global / Toutes années)
      </Typography>

      <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "220px 1fr" }} gap="18px" alignItems="center">
        <Box height="190px" position="relative">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie data={chartData} dataKey="value" cx="50%" cy="50%" innerRadius={50} outerRadius={72} paddingAngle={3} stroke="none">
                {chartData.map((entry) => (
                  <Cell key={entry.name} fill={entry.name === "Collecté" ? colors.greenAccent[500] : pendingColor} />
                ))}
              </Pie>
            </PieChart>
          </ResponsiveContainer>
          <Box position="absolute" top="50%" left="50%" sx={{ transform: "translate(-50%, -50%)" }} textAlign="center">
            <Typography variant="h5" fontWeight="800" color={colors.grey[100]}>{revenuePct}</Typography>
            <Typography variant="body2" color={colors.grey[300]}>collecté</Typography>
          </Box>
        </Box>

        <Box display="flex" flexDirection="column" gap="12px">
          <Box display="flex" justifyContent="space-between" alignItems="baseline" gap="12px">
            <Typography color={colors.grey[300]}>Revenus attendus</Typography>
            <Typography variant="h6" fontWeight="800" color={colors.blueAccent[500]}>{stats.revenueExpected.toLocaleString('fr-FR')} TND</Typography>
          </Box>
          <Box display="flex" justifyContent="space-between" alignItems="baseline" gap="12px">
            <Typography color={colors.grey[300]}>Revenus collectés</Typography>
            <Typography variant="h6" fontWeight="800" color={colors.greenAccent[500]}>{stats.revenueCollected.toLocaleString('fr-FR')} TND</Typography>
          </Box>
          <Box display="flex" justifyContent="space-between" alignItems="baseline" gap="12px">
            <Typography color={colors.grey[300]}>En attente</Typography>
            <Typography variant="h6" fontWeight="800" color={pendingColor}>{pendingAmount.toLocaleString('fr-FR')} TND</Typography>
          </Box>

          <Box mt="4px">
            <Box display="flex" justifyContent="space-between" alignItems="center" mb="6px">
              <Typography variant="body2" color={colors.grey[300]}>Progression du recouvrement</Typography>
              <Typography variant="body2" fontWeight="700" color={colors.grey[100]}>{revenuePct} collecté</Typography>
            </Box>
            <Box height="12px" borderRadius="999px" backgroundColor={colors.primary[500]} overflow="hidden">
              <Box
                height="100%"
                width={revenuePct}
                borderRadius="999px"
                sx={{ background: `linear-gradient(90deg, ${colors.greenAccent[500]}, ${colors.blueAccent[400]})` }}
              />
            </Box>
          </Box>

          <Box display="flex" gap="14px" flexWrap="wrap" pt="2px">
            <Box display="flex" alignItems="center" gap="8px">
              <Box width="10px" height="10px" borderRadius="999px" backgroundColor={colors.greenAccent[500]} />
              <Typography variant="body2" color={colors.grey[300]}>Collecté</Typography>
            </Box>
            <Box display="flex" alignItems="center" gap="8px">
              <Box width="10px" height="10px" borderRadius="999px" backgroundColor={pendingColor} />
              <Typography variant="body2" color={colors.grey[300]}>En attente</Typography>
            </Box>
          </Box>
        </Box>
      </Box>
    </Box>
  );
};

const UpcomingEventsFeed = ({ events, colors, isDark }) => (
  <Box
    gridColumn={{ xs: "span 12", xl: "span 6" }}
    gridRow="span 2"
    backgroundColor={colors.primary[400]}
    overflow="auto"
    borderRadius="16px"
    sx={{
      boxShadow: "0 10px 24px rgba(0,0,0,0.07)",
      border: isDark ? "1px solid rgba(255,255,255,0.06)" : "1px solid rgba(148,163,184,0.16)",
    }}
  >
    <Box
      display="flex"
      justifyContent="space-between"
      alignItems="flex-start"
      borderBottom={`1px solid ${colors.primary[500]}`}
      p="14px 16px"
    >
      <Box>
        <Typography color={colors.grey[100]} variant="h6" fontWeight="700">
        Événements à venir
        </Typography>
        <Typography color={colors.grey[300]} variant="body2" sx={{ mt: '4px', fontSize: '0.82rem' }}>
        Affichage des événements prévus pour le reste de cette semaine
        </Typography>
      </Box>
      <Box
        px="9px"
        py="5px"
        borderRadius="999px"
        sx={{ backgroundColor: colors.primary[500], color: colors.grey[200], fontSize: "11px", fontWeight: 700 }}
      >
        {events.length} affichés
      </Box>
    </Box>
    {events.length === 0 ? (
      <Typography color={colors.grey[300]} p="20px" textAlign="center">Aucun événement prévu pour le reste de la semaine.</Typography>
    ) : (
      events.map((evt, i) => {
        const eventDateObj = evt.date ? new Date(evt.date) : null;
        const eventDate = eventDateObj ? eventDateObj.toLocaleDateString("fr-FR", { weekday: "short", day: "2-digit", month: "2-digit" }) : "-";
        const eventDay = eventDateObj ? eventDateObj.toLocaleDateString("fr-FR", { day: "2-digit" }) : "-";
        const eventMonth = eventDateObj ? eventDateObj.toLocaleDateString("fr-FR", { month: "short" }).replace('.', '').toUpperCase() : "-";
        const statusColor = evt.status === "executed" ? colors.greenAccent[500] : "#f59e0b";
        const statusLabel = evt.status === "executed" ? "Exécuté" : "Prévu";
        return (
          <Box
            key={`evt-${i}`}
            display="flex"
            justifyContent="space-between"
            alignItems="center"
            gap="12px"
            p="12px 16px"
            sx={{
              mx: "10px",
              mt: i === 0 ? "10px" : 0,
              mb: i === events.length - 1 ? "10px" : "8px",
              borderRadius: "14px",
              backgroundColor: isDark ? "rgba(255,255,255,0.03)" : "rgba(255,255,255,0.78)",
              boxShadow: isDark ? "0 8px 18px rgba(0,0,0,0.18)" : "0 8px 20px rgba(15, 23, 42, 0.06)",
              border: isDark ? "1px solid rgba(255,255,255,0.05)" : "1px solid rgba(148,163,184,0.18)",
            }}
          >
            <Box
              width="36px"
              height="36px"
              borderRadius="12px"
              display="flex"
              alignItems="center"
              justifyContent="center"
              sx={{
                background: isDark
                  ? `linear-gradient(135deg, ${colors.blueAccent[700]}, ${colors.primary[500]})`
                  : "linear-gradient(135deg, rgba(37,99,235,0.16), rgba(191,219,254,0.46))",
                color: isDark ? colors.blueAccent[300] : "#1d4ed8",
                fontWeight: 700,
              }}
            >
              <Box display="flex" flexDirection="column" alignItems="center" lineHeight={1}>
                <Typography sx={{ fontSize: "12px", fontWeight: 800, color: "inherit" }}>{eventDay}</Typography>
                <Typography sx={{ fontSize: "8px", fontWeight: 700, color: "inherit", opacity: 0.9 }}>{eventMonth}</Typography>
              </Box>
            </Box>
            <Box flex="1" minWidth={0}>
              <Typography color={colors.grey[100]} variant="body1" fontWeight="700" noWrap>
                {evt.name}
              </Typography>
              <Typography color={colors.grey[300]} variant="body2" noWrap sx={{ fontSize: "0.8rem" }}>
                {eventDate} • {(evt.start_time || "").slice(0, 5)} - {(evt.end_time || "").slice(0, 5)}
              </Typography>
            </Box>
            <Box backgroundColor={statusColor} p="4px 9px" borderRadius="999px" color="#fff" fontWeight="bold" fontSize="11px" flexShrink={0}>
              {statusLabel}
            </Box>
          </Box>
        );
      })
    )}
  </Box>
);

// -----------------------------------------------------------------------------
// Main Dashboard Component
// -----------------------------------------------------------------------------
const Dashboard = () => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const navigate = useNavigate();
  const isDark = theme.palette.mode === "dark";

  // Unified State
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    totalChildren: 0, totalTeachers: 0, totalParents: 0, totalClasses: 0,
    approvedChildrenThisWeek: 0, activeTeachers: 0, activeParents: 0, activeClasses: 0,
    revenueCollected: 0, revenueExpected: 0,
    recentInscriptions: [], academicYear: "",
    yearEnded: false, yearEndedMessage: null, yearArchived: false,
  });
  const [upcomingEvents, setUpcomingEvents] = useState([]);

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        setLoading(true);

        const [parentsRes, teachersRes, classesRes, inscriptionsRes, paymentsRes, planningsRes, eventsRes, dashStatsRes] = await Promise.all([
          api.get("/admin/parents").catch(() => ({ data: { data: [] } })),
          api.get("/admin/teachers").catch(() => ({ data: { data: [] } })),
          api.get("/admin/classes").catch(() => ({ data: { data: [] } })),
          api.get("/admin/inscriptions").catch(() => ({ data: { data: [] } })),
          api.get("/admin/payments").catch(() => ({ data: { data: [] } })),
          api.get("/admin/plannings").catch(() => ({ data: { data: [] } })),
          api.get("/admin/events/upcoming").catch(() => ({ data: { data: [] } })),
          api.get("/admin/dashboard/stats").catch(() => ({ data: { data: {} } }))
        ]);

        const parents = parentsRes.data?.data || [];
        const teachers = teachersRes.data?.data || [];
        const classes = classesRes.data?.data || [];
        const inscriptions = inscriptionsRes.data?.data || [];
        const payments = paymentsRes.data?.data || [];
        const plannings = planningsRes.data?.data || [];
        const dashData = dashStatsRes.data?.data || {};
        
        setUpcomingEvents(eventsRes.data?.data || []);

        // Derived calculations
        const totalChildren = inscriptions.filter(insc => {
          const status = (insc.status?.name || insc.inscription_status?.name || insc.status || 'pending').toLowerCase();
          return status === 'approved';
        }).length;

        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
        const approvedChildrenThisWeek = inscriptions.filter(insc => {
          const status = (insc.status?.name || insc.inscription_status?.name || insc.status || 'pending').toLowerCase();
          const inscriptionDate = new Date(insc.inscription_date || insc.date || 0);
          return status === 'approved' && !Number.isNaN(inscriptionDate.getTime()) && inscriptionDate >= sevenDaysAgo;
        }).length;

        const activeTeachers = teachers.filter(t => !t?.is_archived).length;
        const activeParents = parents.filter(p => !p?.is_archived).length;
        const activeClasses = classes.filter(c => !c?.is_archived).length;

        const revenueCollected = payments.reduce((sum, p) => {
          const partials = Array.isArray(p?.partial_payments) ? p.partial_payments : [];
          return sum + partials.reduce((s, tx) => s + Number(tx.value || 0), 0);
        }, 0);
        const revenueExpected = payments.reduce((sum, p) => sum + Number(p?.amount || 0), 0);

        const recentInscriptions = [...inscriptions]
          .sort((a, b) => new Date(b.inscription_date || b.date || 0) - new Date(a.inscription_date || a.date || 0))
          .slice(0, 8);

        const activePlanning = plannings.find(p => p.is_active) || plannings[0] || {};
        const academicYear = activePlanning.label || activePlanning.academic_year || new Date().getFullYear().toString();

        setStats({
          totalChildren, totalTeachers: teachers.length, totalParents: parents.length, totalClasses: classes.length,
          approvedChildrenThisWeek, activeTeachers, activeParents, activeClasses,
          revenueCollected, revenueExpected, recentInscriptions, academicYear,
          yearEnded: dashData.year_ended || false,
          yearEndedMessage: dashData.year_ended_message || null,
          yearArchived: dashData.year_archived || false,
        });

      } catch (err) { 
        console.error("Dashboard load error:", err); 
      } finally { 
        setLoading(false); 
      }
    };
    fetchDashboardData();
  }, []);

  const revenuePct = stats.revenueExpected > 0 ? `${Math.round((stats.revenueCollected / stats.revenueExpected) * 100)}%` : "0%";

  if (loading) {
    return (
      <Box m="20px" display="flex" justifyContent="center" alignItems="center" height="60vh">
        <CircularProgress sx={{ color: colors.greenAccent[500] }} />
      </Box>
    );
  }

  return (
    <Box m="16px" pb="28px">
      <Box display="flex" justifyContent="space-between" alignItems="center">
        <Header title="TABLEAU DE BORD" subtitle="Bienvenue dans votre tableau de bord — Toutes les années scolaires" />
      </Box>

      {/* Year-End Alert Banner */}
      {stats.yearEnded && (
        <Alert
          severity={stats.yearArchived ? "info" : "warning"}
          icon={stats.yearArchived ? undefined : <WarningAmberIcon />}
          sx={{ mb: "20px", cursor: "pointer", fontSize: "14px" }}
          onClick={() => navigate("/management/parameters")}
        >
          {stats.yearArchived
            ? `✅ ${stats.yearEndedMessage || "L'année scolaire est archivée."} Cliquez ici pour créer une nouvelle année scolaire.`
            : (stats.yearEndedMessage || "L'année scolaire est terminée. Cliquez ici pour archiver et préparer la nouvelle année.")}
        </Alert>
      )}

      <Box
        display="grid"
        gridTemplateColumns={{ xs: "repeat(2, minmax(0, 1fr))", lg: "repeat(4, minmax(0, 1fr))" }}
        gap="12px"
        mb="16px"
      >
        <Box backgroundColor={colors.primary[400]} borderRadius="16px" minHeight="124px" sx={{ border: isDark ? "1px solid rgba(255,255,255,0.06)" : "1px solid rgba(148,163,184,0.16)" }}>
          <StatBox
            title={String(stats.totalChildren)}
            subtitle="Enfants inscrits approuvés"
            increase={`${stats.approvedChildrenThisWeek} cette semaine`}
            iconBg={isDark
              ? "linear-gradient(135deg, rgba(59,130,246,0.28), rgba(96,165,250,0.12))"
              : "linear-gradient(135deg, rgba(37,99,235,0.18), rgba(147,197,253,0.3))"}
            icon={<ChildCareIcon sx={{ color: isDark ? "#93c5fd" : "#1d4ed8", fontSize: "22px" }} />}
          />
        </Box>
        <Box backgroundColor={colors.primary[400]} borderRadius="16px" minHeight="124px" sx={{ border: isDark ? "1px solid rgba(255,255,255,0.06)" : "1px solid rgba(148,163,184,0.16)" }}>
          <StatBox
            title={String(stats.totalTeachers)}
            subtitle="Enseignants"
            increase={`${stats.activeTeachers} actifs`}
            iconBg={isDark
              ? "linear-gradient(135deg, rgba(168,85,247,0.26), rgba(216,180,254,0.12))"
              : "linear-gradient(135deg, rgba(126,34,206,0.16), rgba(221,214,254,0.34))"}
            icon={<SchoolIcon sx={{ color: isDark ? "#d8b4fe" : "#7e22ce", fontSize: "22px" }} />}
          />
        </Box>
        <Box backgroundColor={colors.primary[400]} borderRadius="16px" minHeight="124px" sx={{ border: isDark ? "1px solid rgba(255,255,255,0.06)" : "1px solid rgba(148,163,184,0.16)" }}>
          <StatBox
            title={String(stats.totalParents)}
            subtitle="Parents"
            increase={`${stats.activeParents} actifs`}
            iconBg={isDark
              ? "linear-gradient(135deg, rgba(249,115,22,0.26), rgba(253,186,116,0.12))"
              : "linear-gradient(135deg, rgba(234,88,12,0.16), rgba(254,215,170,0.36))"}
            icon={<PeopleIcon sx={{ color: isDark ? "#fdba74" : "#c2410c", fontSize: "22px" }} />}
          />
        </Box>
        <Box backgroundColor={colors.primary[400]} borderRadius="16px" minHeight="124px" sx={{ border: isDark ? "1px solid rgba(255,255,255,0.06)" : "1px solid rgba(148,163,184,0.16)" }}>
          <StatBox
            title={String(stats.totalClasses)}
            subtitle="Classes"
            increase={`${stats.activeClasses} actives`}
            iconBg={isDark
              ? "linear-gradient(135deg, rgba(45,212,191,0.24), rgba(153,246,228,0.12))"
              : "linear-gradient(135deg, rgba(13,148,136,0.16), rgba(153,246,228,0.34))"}
            icon={<ClassIcon sx={{ color: isDark ? "#99f6e4" : "#0f766e", fontSize: "22px" }} />}
          />
        </Box>
      </Box>

      {/* Lower Modular Widgets */}
      <Box display="grid" gridTemplateColumns="repeat(12, 1fr)" gridAutoRows="124px" gap="16px">
        <RecentInscriptionsFeed inscriptions={stats.recentInscriptions} colors={colors} isDark={isDark} />
        <UpcomingEventsFeed events={upcomingEvents} colors={colors} isDark={isDark} />
        <FinancialBilanWidget stats={stats} revenuePct={revenuePct} colors={colors} />
      </Box>
    </Box>
  );
};

export default Dashboard;
