import {
  Box,
  CircularProgress,
  Collapse,
  FormControl,
  IconButton,
  InputAdornment,
  MenuItem,
  Pagination,
  Select,
  TextField,
  Typography,
} from "@mui/material";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import SearchIcon from "@mui/icons-material/Search";
import AssessmentOutlinedIcon from "@mui/icons-material/AssessmentOutlined";
import Groups2OutlinedIcon from "@mui/icons-material/Groups2Outlined";
import NotificationImportantOutlinedIcon from "@mui/icons-material/NotificationImportantOutlined";
import HistoryEduOutlinedIcon from "@mui/icons-material/HistoryEduOutlined";
import ExpandMoreRoundedIcon from "@mui/icons-material/ExpandMoreRounded";
import Header from "../../components/Header";
import { tokens } from "../../theme";
import { useTheme } from "@mui/material";
import { useCallback, useEffect, useMemo, useState } from "react";
import api from "../../api/axios";

const ITEMS_PER_PAGE = 8;

const formatDateTime = (value) => {
  if (!value) return "Date indisponible";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "Date indisponible";
  return date.toLocaleString("fr-FR", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
};

const getAvatarGradient = (seed, isDark) => {
  const palettes = isDark
    ? [
        ["#0f766e", "#14b8a6"],
        ["#1d4ed8", "#38bdf8"],
        ["#334155", "#64748b"],
        ["#115e59", "#2dd4bf"],
      ]
    : [
        ["#0f766e", "#2dd4bf"],
        ["#0369a1", "#38bdf8"],
        ["#475569", "#94a3b8"],
        ["#0f766e", "#5eead4"],
      ];

  const hash = String(seed || "")
    .split("")
    .reduce((sum, char) => sum + char.charCodeAt(0), 0);

  return palettes[hash % palettes.length];
};

const SummaryBar = ({ colors, isDark, totalAnalyses, uniqueChildren, totalSignals }) => {
  const styles = getStyles(colors, isDark);
  const items = [
    { icon: AssessmentOutlinedIcon, label: "Analyses", value: totalAnalyses },
    { icon: Groups2OutlinedIcon, label: "Élèves analysés", value: uniqueChildren },
    { icon: NotificationImportantOutlinedIcon, label: "Signalements traités", value: totalSignals },
  ];

  return (
    <Box sx={styles.summaryBar}>
      {items.map(({ icon: Icon, label, value }) => (
        <Box key={label} sx={styles.summaryItem}>
          <Box sx={styles.summaryIconWrap}>
            <Icon sx={styles.summaryIcon} />
          </Box>
          <Box>
            <Typography sx={styles.summaryLabel}>{label}</Typography>
            <Typography sx={styles.summaryValue}>{value}</Typography>
          </Box>
        </Box>
      ))}
    </Box>
  );
};

const Toolbar = ({ colors, isDark, plannings, selectedPlanningId, setSelectedPlanningId, searchTerm, setSearchTerm }) => {
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

      <TextField
        value={searchTerm}
        onChange={(event) => setSearchTerm(event.target.value)}
        placeholder="Rechercher un élève"
        size="small"
        sx={styles.searchField}
        InputProps={{
          startAdornment: (
            <InputAdornment position="start">
              <SearchIcon sx={{ color: colors.grey[400] }} fontSize="small" />
            </InputAdornment>
          ),
        }}
      />
    </Box>
  );
};

const BehavioralHistory = ({ showHeader = true }) => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";
  const styles = getStyles(colors, isDark);

  const [plannings, setPlannings] = useState([]);
  const [selectedPlanningId, setSelectedPlanningId] = useState("");
  const [analysisHistory, setAnalysisHistory] = useState([]);
  const [loadingHistory, setLoadingHistory] = useState(false);
  const [expandedHistoryId, setExpandedHistoryId] = useState(null);
  const [page, setPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState("");

  useEffect(() => {
    const fetchPlannings = async () => {
      try {
        const response = await api.get("/admin/plannings");
        const planningList = response.data?.data || [];
        setPlannings(planningList);

        if (planningList.length > 0) {
          const today = new Date().toISOString().slice(0, 10);
          const currentPlanning = planningList.find(
            (planning) => (planning.startDate || planning.start_date) <= today && (planning.endDate || planning.end_date) >= today
          );
          setSelectedPlanningId(currentPlanning ? currentPlanning.id : planningList[0].id);
        }
      } catch (error) {
        console.error(error);
      }
    };

    fetchPlannings();
  }, []);

  const fetchHistory = useCallback(async (planningId) => {
    try {
      setLoadingHistory(true);
      const response = await api.get(`/admin/reports/analysis-history?planning_id=${planningId}`);
      setAnalysisHistory(response.data?.data || []);
    } catch {
      setAnalysisHistory([]);
    } finally {
      setLoadingHistory(false);
    }
  }, []);

  useEffect(() => {
    if (!selectedPlanningId) return;
    fetchHistory(selectedPlanningId);
    setPage(1);
    setExpandedHistoryId(null);
  }, [selectedPlanningId, fetchHistory]);

  useEffect(() => {
    setPage(1);
  }, [searchTerm]);

  const handleDeleteHistory = async (id) => {
    if (!window.confirm("Supprimer cette entrée d'historique ?")) return;

    try {
      await api.delete(`/admin/reports/analysis-history/${id}`);
      setAnalysisHistory((previous) => previous.filter((entry) => entry.id !== id));
    } catch (error) {
      alert(`Erreur: ${error?.response?.data?.message || error.message}`);
    }
  };

  const filteredHistory = useMemo(() => {
    if (!searchTerm) return analysisHistory;

    const normalizedTerm = searchTerm.toLowerCase();
    return analysisHistory.filter((entry) => {
      const fullName = `${entry.child_first_name || ""} ${entry.child_last_name || ""}`.toLowerCase();
      return fullName.includes(normalizedTerm);
    });
  }, [analysisHistory, searchTerm]);

  const totalPages = Math.max(1, Math.ceil(filteredHistory.length / ITEMS_PER_PAGE));

  const paginatedHistory = useMemo(() => {
    const start = (page - 1) * ITEMS_PER_PAGE;
    return filteredHistory.slice(start, start + ITEMS_PER_PAGE);
  }, [filteredHistory, page]);

  const stats = useMemo(() => {
    const totalAnalyses = filteredHistory.length;
    const uniqueChildren = new Set(
      filteredHistory.map((entry) => entry.child_id || `${entry.child_first_name}_${entry.child_last_name}`)
    ).size;
    const totalSignals = filteredHistory.reduce(
      (sum, entry) => sum + (entry.analyzed_signalement_ids?.length || 0),
      0
    );

    return { totalAnalyses, uniqueChildren, totalSignals };
  }, [filteredHistory]);

  return (
    <Box {...(showHeader ? { m: "20px" } : {})}>
      {showHeader && <Header title="HISTORIQUE COMPORTEMENTAL" />}

      <Toolbar
        colors={colors}
        isDark={isDark}
        plannings={plannings}
        selectedPlanningId={selectedPlanningId}
        setSelectedPlanningId={setSelectedPlanningId}
        searchTerm={searchTerm}
        setSearchTerm={setSearchTerm}
      />

      <SummaryBar
        colors={colors}
        isDark={isDark}
        totalAnalyses={stats.totalAnalyses}
        uniqueChildren={stats.uniqueChildren}
        totalSignals={stats.totalSignals}
      />

      <Box sx={styles.panelShell}>
        <Box sx={styles.panelHeader}>
          <Box>
            <Typography sx={styles.panelTitle}>Historique des analyses</Typography>
            <Typography sx={styles.panelSubtitle}>{filteredHistory.length} entrée(s) pour l'année et les filtres sélectionnés</Typography>
          </Box>
          <Box sx={styles.panelTitleIconWrap}>
            <HistoryEduOutlinedIcon sx={{ color: colors.greenAccent[400], fontSize: 20 }} />
          </Box>
        </Box>

        {loadingHistory ? (
          <Box sx={styles.loadingState}>
            <CircularProgress size={28} sx={{ color: colors.greenAccent[500] }} />
            <Typography sx={styles.loadingText}>Chargement de l'historique...</Typography>
          </Box>
        ) : filteredHistory.length === 0 ? (
          <Box sx={styles.emptyState}>
            <Box sx={styles.emptyStateIconWrap}>
              <HistoryEduOutlinedIcon sx={{ color: colors.greenAccent[400], fontSize: 24 }} />
            </Box>
            <Typography sx={styles.emptyStateTitle}>Aucune analyse sauvegardée</Typography>
            <Typography sx={styles.emptyStateText}>
              {searchTerm
                ? "Aucun élève ne correspond à votre recherche."
                : "Les analyses générées apparaîtront ici pour l'année scolaire sélectionnée."}
            </Typography>
          </Box>
        ) : (
          <>
            <Box sx={styles.listBody}>
              {paginatedHistory.map((entry) => {
                const isExpanded = expandedHistoryId === entry.id;
                const [fromColor, toColor] = getAvatarGradient(entry.child_id || entry.child_first_name, isDark);

                let parsedResult = null;
                try {
                  parsedResult = JSON.parse(entry.analysis_result);
                } catch {
                  parsedResult = null;
                }

                const analyzedDate = formatDateTime(entry.analyzed_at || entry.created_at || entry.updated_at);

                return (
                  <Box key={entry.id} sx={styles.historyRowShell}>
                    <Box sx={styles.historyRowHeader} onClick={() => setExpandedHistoryId((previous) => (previous === entry.id ? null : entry.id))}>
                      <Box sx={{ ...styles.avatarBadge, background: `linear-gradient(135deg, ${fromColor}, ${toColor})` }}>
                        {(entry.child_first_name || "?").charAt(0).toUpperCase()}
                      </Box>

                      <Box flex="1" minWidth={0}>
                        <Typography sx={styles.studentName}>
                          {entry.child_first_name} {entry.child_last_name}
                        </Typography>
                        <Typography sx={styles.studentMeta}>
                          Analysé le {analyzedDate}
                          {entry.analyzed_signalement_ids?.length > 0 ? ` • ${entry.analyzed_signalement_ids.length} signalement(s)` : ""}
                        </Typography>
                      </Box>

                      <Box sx={styles.historyActions}>
                        <Box sx={styles.countPill(entry.analyzed_signalement_ids?.length || 0)}>
                          {entry.analyzed_signalement_ids?.length || 0} élément(s)
                        </Box>
                        <IconButton
                          size="small"
                          onClick={(event) => {
                            event.stopPropagation();
                            handleDeleteHistory(entry.id);
                          }}
                          sx={styles.deleteButton}
                        >
                          <DeleteOutlineIcon fontSize="small" />
                        </IconButton>
                        <ExpandMoreRoundedIcon
                          sx={{
                            color: colors.grey[300],
                            transform: isExpanded ? "rotate(180deg)" : "rotate(0deg)",
                            transition: "transform 0.2s ease",
                          }}
                        />
                      </Box>
                    </Box>

                    <Collapse in={isExpanded}>
                      <Box sx={styles.expandedPanel}>
                        {parsedResult ? (
                          <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }} gap="12px">
                            <Box sx={styles.resultBlock}>
                              <Typography sx={styles.resultBlockLabel}>Synthèse</Typography>
                              <Typography sx={styles.resultBlockText}>{parsedResult.synthese || "Aucune synthèse disponible."}</Typography>
                            </Box>
                            <Box sx={styles.resultBlock}>
                              <Typography sx={styles.resultBlockLabel}>Recommandations</Typography>
                              <Typography sx={styles.resultBlockText}>{parsedResult.recommandations || "Aucune recommandation disponible."}</Typography>
                            </Box>
                          </Box>
                        ) : (
                          <Box sx={styles.resultBlock}>
                            <Typography sx={styles.resultBlockLabel}>Résultat brut</Typography>
                            <Typography sx={styles.resultBlockText}>{entry.analysis_result}</Typography>
                          </Box>
                        )}
                      </Box>
                    </Collapse>
                  </Box>
                );
              })}
            </Box>

            <Box sx={styles.paginationRow}>
              <Pagination
                count={totalPages}
                page={page}
                onChange={(_event, value) => {
                  setPage(value);
                  setExpandedHistoryId(null);
                }}
                color="standard"
                sx={styles.pagination}
              />
              <Typography sx={styles.paginationText}>Page {page} / {totalPages}</Typography>
            </Box>
          </>
        )}
      </Box>
    </Box>
  );
};

export default BehavioralHistory;

function getStyles(colors, isDark) {
  const surface = isDark ? "rgba(15, 23, 32, 0.88)" : "rgba(255, 255, 255, 0.82)";
  const surfaceAlt = isDark ? "rgba(19, 28, 39, 0.92)" : "#f8fafc";
  const border = isDark ? "rgba(148, 163, 184, 0.16)" : "rgba(148, 163, 184, 0.28)";
  const mutedHeader = isDark ? "rgba(148, 163, 184, 0.12)" : "#e2e8f0";

  return {
    summaryBar: {
      display: "grid",
      gridTemplateColumns: { xs: "1fr", md: "repeat(3, minmax(0, 1fr))" },
      gap: "12px",
      mb: "18px",
    },
    summaryItem: {
      display: "flex",
      alignItems: "center",
      gap: "14px",
      px: "18px",
      py: "16px",
      borderRadius: "18px",
      background: surface,
      border: `1px solid ${border}`,
      boxShadow: isDark ? "0 18px 34px rgba(2, 6, 23, 0.28)" : "0 16px 32px rgba(148, 163, 184, 0.18)",
      backdropFilter: "blur(14px)",
    },
    summaryIconWrap: {
      width: 42,
      height: 42,
      borderRadius: "14px",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      backgroundColor: isDark ? "rgba(45, 212, 191, 0.10)" : "rgba(15, 118, 110, 0.08)",
      border: `1px solid ${isDark ? "rgba(45, 212, 191, 0.18)" : "rgba(15, 118, 110, 0.14)"}`,
    },
    summaryIcon: {
      color: colors.greenAccent[400],
      fontSize: 20,
    },
    summaryLabel: {
      fontSize: "0.78rem",
      letterSpacing: "0.04em",
      textTransform: "uppercase",
      color: colors.grey[400],
      mb: "4px",
    },
    summaryValue: {
      fontSize: "1.5rem",
      lineHeight: 1,
      fontWeight: 800,
      color: colors.grey[100],
    },
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
    searchField: {
      width: { xs: "100%", md: 320 },
      ml: { md: "auto" },
      "& .MuiOutlinedInput-root": {
        borderRadius: "12px",
        backgroundColor: surfaceAlt,
      },
    },
    panelShell: {
      borderRadius: "22px",
      background: surface,
      border: `1px solid ${border}`,
      boxShadow: isDark ? "0 18px 34px rgba(2, 6, 23, 0.32)" : "0 16px 34px rgba(148, 163, 184, 0.18)",
      overflow: "hidden",
    },
    panelHeader: {
      px: { xs: "16px", md: "22px" },
      py: { xs: "16px", md: "20px" },
      borderBottom: `1px solid ${border}`,
      display: "flex",
      justifyContent: "space-between",
      alignItems: "center",
      gap: "12px",
    },
    panelTitle: {
      fontSize: "1.08rem",
      fontWeight: 800,
      color: colors.grey[100],
    },
    panelSubtitle: {
      mt: "4px",
      fontSize: "0.86rem",
      color: colors.grey[400],
    },
    panelTitleIconWrap: {
      width: 38,
      height: 38,
      borderRadius: "14px",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      backgroundColor: isDark ? "rgba(45, 212, 191, 0.10)" : "rgba(13, 148, 136, 0.08)",
      border: `1px solid ${isDark ? "rgba(45, 212, 191, 0.16)" : "rgba(13, 148, 136, 0.14)"}`,
    },
    listBody: {
      px: { xs: "16px", md: "22px" },
      py: "18px",
      display: "flex",
      flexDirection: "column",
      gap: "10px",
    },
    historyRowShell: {
      borderRadius: "18px",
      border: `1px solid ${border}`,
      backgroundColor: surfaceAlt,
      overflow: "hidden",
    },
    historyRowHeader: {
      display: "flex",
      alignItems: "center",
      gap: "14px",
      p: "16px",
      cursor: "pointer",
      transition: "background-color 0.2s ease",
      "&:hover": {
        backgroundColor: isDark ? "rgba(30, 41, 59, 0.72)" : "rgba(241, 245, 249, 0.92)",
      },
    },
    avatarBadge: {
      width: 42,
      height: 42,
      borderRadius: "14px",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      color: "#f8fafc",
      fontWeight: 800,
      fontSize: "1rem",
      flexShrink: 0,
      boxShadow: "inset 0 1px 0 rgba(255,255,255,0.22)",
    },
    studentName: {
      fontSize: "1rem",
      fontWeight: 800,
      color: colors.grey[100],
      whiteSpace: "nowrap",
      overflow: "hidden",
      textOverflow: "ellipsis",
    },
    studentMeta: {
      mt: "4px",
      fontSize: "0.82rem",
      color: colors.grey[400],
    },
    historyActions: {
      display: "flex",
      alignItems: "center",
      gap: "8px",
      marginLeft: "auto",
      flexShrink: 0,
    },
    countPill: (count) => ({
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      minWidth: 116,
      px: "12px",
      py: "7px",
      borderRadius: "999px",
      fontSize: "0.78rem",
      fontWeight: 700,
      color: count > 0 ? colors.grey[200] : colors.grey[400],
      backgroundColor: mutedHeader,
      border: `1px solid ${border}`,
    }),
    deleteButton: {
      color: colors.redAccent[400],
      border: `1px solid ${isDark ? "rgba(248, 113, 113, 0.16)" : "rgba(248, 113, 113, 0.18)"}`,
      backgroundColor: isDark ? "rgba(127, 29, 29, 0.14)" : "rgba(254, 226, 226, 0.72)",
      "&:hover": {
        backgroundColor: isDark ? "rgba(127, 29, 29, 0.22)" : "rgba(254, 226, 226, 0.92)",
      },
    },
    expandedPanel: {
      p: "16px",
      borderTop: `1px solid ${border}`,
      backgroundColor: isDark ? "rgba(15, 23, 32, 0.78)" : "rgba(248, 250, 252, 0.92)",
    },
    resultBlock: {
      p: "14px 16px",
      borderRadius: "14px",
      backgroundColor: isDark ? "rgba(19, 28, 39, 0.9)" : "rgba(255, 255, 255, 0.98)",
      border: `1px solid ${border}`,
      minWidth: 0,
    },
    resultBlockLabel: {
      fontSize: "0.74rem",
      fontWeight: 800,
      textTransform: "uppercase",
      letterSpacing: "0.05em",
      color: colors.grey[400],
      mb: "8px",
    },
    resultBlockText: {
      fontSize: "0.9rem",
      lineHeight: 1.6,
      color: colors.grey[200],
      whiteSpace: "pre-wrap",
    },
    paginationRow: {
      px: { xs: "16px", md: "22px" },
      pt: 0,
      pb: { xs: "18px", md: "22px" },
      display: "flex",
      justifyContent: "space-between",
      alignItems: { xs: "flex-start", md: "center" },
      gap: "12px",
      flexDirection: { xs: "column", md: "row" },
    },
    pagination: {
      "& .MuiPaginationItem-root": {
        color: colors.grey[100],
        borderColor: border,
        "&.Mui-selected": {
          backgroundColor: isDark ? "rgba(13, 148, 136, 0.28)" : "rgba(13, 148, 136, 0.18)",
          color: colors.grey[100],
          fontWeight: 800,
        },
        "&:hover": {
          backgroundColor: mutedHeader,
        },
      },
    },
    paginationText: {
      fontSize: "0.82rem",
      color: colors.grey[400],
    },
    loadingState: {
      minHeight: 240,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      gap: "12px",
      px: "20px",
    },
    loadingText: {
      color: colors.grey[300],
    },
    emptyState: {
      minHeight: 260,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      gap: "10px",
      px: "20px",
      textAlign: "center",
    },
    emptyStateIconWrap: {
      width: 52,
      height: 52,
      borderRadius: "18px",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      backgroundColor: isDark ? "rgba(45, 212, 191, 0.10)" : "rgba(13, 148, 136, 0.08)",
    },
    emptyStateTitle: {
      fontSize: "1rem",
      fontWeight: 800,
      color: colors.grey[100],
    },
    emptyStateText: {
      fontSize: "0.88rem",
      color: colors.grey[400],
      maxWidth: 420,
    },
  };
}
