import {
  Box,
  Button,
  Chip,
  CircularProgress,
  Collapse,
  FormControl,
  InputAdornment,
  MenuItem,
  Select,
  TextField,
  Typography,
} from "@mui/material";
import SearchIcon from "@mui/icons-material/Search";
import PsychologyAltOutlinedIcon from "@mui/icons-material/PsychologyAltOutlined";
import WarningAmberRoundedIcon from "@mui/icons-material/WarningAmberRounded";
import Groups2OutlinedIcon from "@mui/icons-material/Groups2Outlined";
import HomeWorkOutlinedIcon from "@mui/icons-material/HomeWorkOutlined";
import NotificationImportantOutlinedIcon from "@mui/icons-material/NotificationImportantOutlined";
import InsightsOutlinedIcon from "@mui/icons-material/InsightsOutlined";
import ExpandMoreRoundedIcon from "@mui/icons-material/ExpandMoreRounded";
import Header from "../../components/Header";
import { tokens } from "../../theme";
import { useTheme } from "@mui/material";
import { useCallback, useEffect, useMemo, useState } from "react";
import api from "../../api/axios";
import { getAdminPrimaryButtonSx, getAdminSecondaryButtonSx } from "../../utils/adminActionButtons";

const formatDate = (value, options = { day: "2-digit", month: "short", year: "numeric" }) => {
  if (!value) return "Date indisponible";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "Date indisponible";
  return date.toLocaleDateString("fr-FR", options);
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

const SummaryBar = ({ colors, isDark, totalSignalements, flaggedCount, classCount }) => {
  const styles = getStyles(colors, isDark);
  const items = [
    {
      icon: NotificationImportantOutlinedIcon,
      label: "Signalements",
      value: totalSignalements,
    },
    {
      icon: Groups2OutlinedIcon,
      label: "Élèves concernés",
      value: flaggedCount,
    },
    {
      icon: HomeWorkOutlinedIcon,
      label: "Classes touchées",
      value: classCount,
    },
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

const PlanningToolbar = ({ colors, isDark, plannings, selectedPlanningId, setSelectedPlanningId, searchTerm, setSearchTerm }) => {
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
        placeholder="Rechercher un élève ou une classe"
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

const AiDisabledBanner = ({ colors, isDark }) => {
  const styles = getStyles(colors, isDark);

  return (
    <Box sx={styles.aiDisabledBanner}>
      <WarningAmberRoundedIcon sx={{ color: colors.redAccent[400], fontSize: 18 }} />
      <Typography sx={styles.aiDisabledText}>
        L'analyse IA est désactivée. Les signalements restent consultables, mais l'analyse automatique n'est pas disponible.
      </Typography>
    </Box>
  );
};

const AiResultCards = ({ colors, isDark, aiAnalysis }) => {
  const styles = getStyles(colors, isDark);

  if (aiAnalysis?.error) {
    return (
      <Box sx={styles.aiErrorCard}>
        <Typography sx={styles.aiErrorText}>{aiAnalysis.error}</Typography>
        {aiAnalysis.raw && (
          <Typography variant="caption" sx={styles.aiRawText}>
            {aiAnalysis.raw}
          </Typography>
        )}
      </Box>
    );
  }

  return (
    <>
      <Box sx={styles.aiResultsGrid}>
        {(aiAnalysis?.eleves || []).map((student, index) => (
          <Box key={`${student.nom || "eleve"}-${index}`} sx={styles.aiResultCard}>
            <Box display="flex" justifyContent="space-between" alignItems="flex-start" gap="12px" mb="14px" flexWrap="wrap">
              <Box>
                <Typography sx={styles.aiResultName}>{student.nom || "Élève"}</Typography>
                {student.classe && <Typography sx={styles.aiResultClass}>{student.classe}</Typography>}
              </Box>
              {student.classe && <Chip label={student.classe} size="small" sx={styles.aiClassChip} />}
            </Box>

            <Box sx={styles.aiTextBlock}>
              <Typography sx={styles.aiBlockLabel}>Synthèse</Typography>
              <Typography sx={styles.aiBlockText}>{student.synthese || "Aucune synthèse disponible."}</Typography>
            </Box>

            <Box sx={styles.aiTextBlock}>
              <Typography sx={styles.aiBlockLabel}>Recommandations</Typography>
              <Typography sx={styles.aiBlockText}>{student.recommandations || "Aucune recommandation disponible."}</Typography>
            </Box>
          </Box>
        ))}
      </Box>

      {aiAnalysis?.remarques?.length > 0 && (
        <Box sx={styles.aiRemarksCard}>
          <Typography sx={styles.aiRemarksTitle}>Remarques générales</Typography>
          <Box display="flex" flexDirection="column" gap="8px">
            {aiAnalysis.remarques.map((remark, index) => (
              <Typography key={`${remark}-${index}`} sx={styles.aiRemarksText}>
                {remark}
              </Typography>
            ))}
          </Box>
        </Box>
      )}
    </>
  );
};

const SignalementDetail = ({ colors, isDark, signalement, isAlreadyAnalyzed }) => {
  const styles = getStyles(colors, isDark);

  return (
    <Box sx={styles.signalementCard}>
      <Box display="flex" justifyContent="space-between" gap="12px" alignItems="flex-start" flexWrap="wrap">
        <Box flex="1">
          <Box display="flex" alignItems="center" gap="8px" flexWrap="wrap" mb="6px">
            <Typography sx={{ ...styles.signalementType, color: styles.alertColor(signalement.alert_type) }}>
              {signalement.alert_type || "Signalement"}
            </Typography>
            {isAlreadyAnalyzed && <Chip label="Analysé" size="small" sx={styles.analyzedMiniChip} />}
          </Box>
          <Typography sx={styles.signalementMeta}>
            {formatDate(signalement.incident_time)}
            {signalement.teacher_name ? ` • ${signalement.teacher_name}` : ""}
          </Typography>
        </Box>
        <Typography sx={styles.signalementComment}>
          {signalement.comment || "Sans commentaire"}
        </Typography>
      </Box>
    </Box>
  );
};

const ChildRow = ({ colors, isDark, child, isExpanded, onToggle, analyzedSignalementIds }) => {
  const styles = getStyles(colors, isDark);
  const [fromColor, toColor] = getAvatarGradient(child.child_id || child.child_name, isDark);
  const analyzedCount = child.signalements.filter((signalement) => analyzedSignalementIds.has(signalement.id)).length;
  const allAnalyzed = analyzedCount === child.signalements.length && child.signalements.length > 0;
  const someAnalyzed = analyzedCount > 0 && !allAnalyzed;

  let statusLabel = "À analyser";
  let statusSx = styles.statusPendingChip;

  if (allAnalyzed) {
    statusLabel = "Analysé";
    statusSx = styles.statusAnalyzedChip;
  } else if (someAnalyzed) {
    statusLabel = "Partiel";
    statusSx = styles.statusPartialChip;
  }

  return (
    <Box sx={styles.rowShell}>
      <Box sx={styles.tableRow} onClick={onToggle}>
        <Box sx={styles.avatarCell}>
          <Box sx={{ ...styles.avatarBadge, background: `linear-gradient(135deg, ${fromColor}, ${toColor})` }}>
            {(child.child_name || "?").charAt(0).toUpperCase()}
          </Box>
        </Box>

        <Box sx={styles.nameCell}>
          <Typography sx={styles.studentName}>{child.child_name}</Typography>
          <Typography sx={styles.studentClass}>{child.class_name || "Classe indisponible"}</Typography>
        </Box>

        <Box sx={styles.metricCell}>
          <Box sx={styles.countPill(child.signalements.length)}>{child.signalements.length} incident(s)</Box>
        </Box>

        <Box sx={styles.metricCell}>
          <Chip label={statusLabel} size="small" sx={statusSx} />
        </Box>

        <Box sx={styles.expandCell}>
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
        <Box sx={styles.expandedRow}>
          <Typography sx={styles.expandedTitle}>Détail des signalements</Typography>
          <Box display="flex" flexDirection="column" gap="10px">
            {child.signalements
              .slice()
              .sort((a, b) => new Date(b.incident_time) - new Date(a.incident_time))
              .map((signalement) => (
                <SignalementDetail
                  key={signalement.id}
                  colors={colors}
                  isDark={isDark}
                  signalement={signalement}
                  isAlreadyAnalyzed={analyzedSignalementIds.has(signalement.id)}
                />
              ))}
          </Box>
        </Box>
      </Collapse>
    </Box>
  );
};

const ChildrenListSection = ({
  colors,
  isDark,
  filteredChildren,
  expandedChild,
  setExpandedChild,
  analyzedSignalementIds,
  aiEnabled,
  isAnalyzing,
  aiAnalysis,
  analysisHistory,
  onAnalyze,
  isAiPanelOpen,
  setIsAiPanelOpen,
}) => {
  const styles = getStyles(colors, isDark);

  return (
    <Box sx={styles.panelShell}>
      <Box sx={styles.panelHeader}>
        <Box>
          <Typography sx={styles.panelTitle}>Signalements comportementaux</Typography>
          <Typography sx={styles.panelSubtitle}>{filteredChildren.length} élève(s) avec au moins un signalement</Typography>
        </Box>

        <Box sx={styles.actionsRow}>
          {(aiAnalysis || isAnalyzing) && (
            <Button
              variant="text"
              onClick={() => setIsAiPanelOpen((previous) => !previous)}
              sx={styles.ghostActionButton}
              startIcon={<InsightsOutlinedIcon fontSize="small" />}
            >
              {isAiPanelOpen ? "Masquer l'analyse" : "Voir l'analyse"}
            </Button>
          )}

          {analysisHistory.length > 0 && (
            <Button
              variant="outlined"
              onClick={() => {
                setIsAiPanelOpen(true);
                onAnalyze(true);
              }}
              disabled={isAnalyzing || !aiEnabled}
              sx={styles.secondaryActionButton(aiEnabled)}
            >
              Ré-analyser tout
            </Button>
          )}

          <Button
            variant="contained"
            onClick={() => {
              setIsAiPanelOpen(true);
              onAnalyze(false);
            }}
            disabled={isAnalyzing || !aiEnabled}
            sx={styles.primaryActionButton(aiEnabled)}
            startIcon={isAnalyzing ? <CircularProgress size={16} sx={{ color: "inherit" }} /> : <PsychologyAltOutlinedIcon fontSize="small" />}
          >
            {isAnalyzing
              ? "Analyse en cours"
              : !aiEnabled
                ? "IA désactivée"
                : analysisHistory.length > 0
                  ? "Analyser les nouveaux"
                  : "Lancer l'analyse"}
          </Button>
        </Box>
      </Box>

      {!aiEnabled && <AiDisabledBanner colors={colors} isDark={isDark} />}

      <Collapse in={isAiPanelOpen || isAnalyzing}>
        <Box sx={styles.aiInlinePanel}>
          <Box display="flex" alignItems="center" gap="10px" mb={aiAnalysis || isAnalyzing ? 16 : 0}>
            <Box sx={styles.inlineAiIconWrap}>
              <PsychologyAltOutlinedIcon sx={{ color: colors.greenAccent[400], fontSize: 18 }} />
            </Box>
            <Box>
              <Typography sx={styles.inlineAiTitle}>Synthèse IA</Typography>
              <Typography sx={styles.inlineAiText}>
                {isAnalyzing
                  ? "Analyse en cours des signalements de la période sélectionnée."
                  : "Lancez une analyse pour générer une synthèse et des recommandations ciblées."}
              </Typography>
            </Box>
          </Box>

          {isAnalyzing ? (
            <Box sx={styles.aiLoadingState}>
              <CircularProgress size={24} sx={{ color: colors.greenAccent[500] }} />
              <Typography sx={styles.inlineAiText}>Préparation de la synthèse comportementale...</Typography>
            </Box>
          ) : aiAnalysis ? (
            <AiResultCards colors={colors} isDark={isDark} aiAnalysis={aiAnalysis} />
          ) : null}
        </Box>
      </Collapse>

        <Box sx={styles.tableScroll}>
          <Box sx={styles.tableInner}>
            <Box sx={styles.tableHeaderRow}>
              <Box sx={styles.headerSpacerCell} />
              <Box sx={styles.headerNameCell}>
                <Typography sx={styles.headerText}>Élève</Typography>
              </Box>
              <Box sx={styles.headerMetricCell}>
                <Typography sx={styles.headerText}>Signalements</Typography>
              </Box>
              <Box sx={styles.headerMetricCellLast}>
                <Typography sx={styles.headerText}>Statut</Typography>
              </Box>
              <Box sx={styles.headerSpacerCell} />
            </Box>

          {filteredChildren.length === 0 ? (
            <Box sx={styles.emptyState}>
              <Box sx={styles.emptyStateIconWrap}>
                <NotificationImportantOutlinedIcon sx={{ color: colors.greenAccent[400], fontSize: 24 }} />
              </Box>
              <Typography sx={styles.emptyStateTitle}>Aucun signalement trouvé</Typography>
              <Typography sx={styles.emptyStateText}>Ajustez les filtres ou sélectionnez une autre année scolaire.</Typography>
            </Box>
          ) : (
            filteredChildren.map((child) => (
              <ChildRow
                key={`${child.child_id}-${child.class_id}`}
                colors={colors}
                isDark={isDark}
                child={child}
                isExpanded={expandedChild === child.child_id}
                onToggle={() => setExpandedChild((previous) => (previous === child.child_id ? null : child.child_id))}
                analyzedSignalementIds={analyzedSignalementIds}
              />
            ))
          )}
        </Box>
      </Box>
    </Box>
  );
};

const Reports = ({ showHeader = true }) => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";

  const [plannings, setPlannings] = useState([]);
  const [selectedPlanningId, setSelectedPlanningId] = useState("");
  const [reportData, setReportData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [aiEnabled, setAiEnabled] = useState(true);
  const [aiAnalysis, setAiAnalysis] = useState(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [analysisHistory, setAnalysisHistory] = useState([]);
  const [, setLoadingHistory] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [expandedChild, setExpandedChild] = useState(null);
  const [isAiPanelOpen, setIsAiPanelOpen] = useState(false);

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

    const fetchAiEnabled = async () => {
      try {
        const response = await api.get("/admin/parameters");
        const data = response.data?.data || response.data || [];
        const parameterList = Array.isArray(data) ? data : [];
        const aiParameter = parameterList.find((parameter) => parameter.name === "ai_enabled");
        if (aiParameter) {
          setAiEnabled(aiParameter.value === "true" || aiParameter.value === "1");
        }
      } catch {
        // Ignore parameter fetch errors here and keep the default UI state.
      }
    };

    fetchPlannings();
    fetchAiEnabled();
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

    const fetchReport = async () => {
      setLoading(true);
      try {
        const response = await api.get(`/admin/plannings/${selectedPlanningId}/report`);
        setReportData(response.data);
      } catch (error) {
        console.error(error);
      } finally {
        setLoading(false);
      }
    };

    fetchReport();
    fetchHistory(selectedPlanningId);
    setAiAnalysis(null);
    setExpandedChild(null);
    setIsAiPanelOpen(false);
  }, [selectedPlanningId, fetchHistory]);

  const allFlaggedChildren = useMemo(() => {
    if (!reportData?.classes) return [];

    const children = [];
    reportData.classes.forEach((schoolClass) => {
      schoolClass.children.forEach((child) => {
        if (child.signalements.length > 0) {
          children.push({
            ...child,
            class_name: schoolClass.class_name,
            class_id: schoolClass.class_id,
          });
        }
      });
    });

    return children;
  }, [reportData]);

  const filteredChildren = useMemo(() => {
    if (!searchTerm) return allFlaggedChildren;

    const normalizedTerm = searchTerm.toLowerCase();
    return allFlaggedChildren.filter(
      (child) =>
        (child.child_name || "").toLowerCase().includes(normalizedTerm) ||
        (child.class_name || "").toLowerCase().includes(normalizedTerm)
    );
  }, [allFlaggedChildren, searchTerm]);

  const totalSignalements = useMemo(
    () => allFlaggedChildren.reduce((sum, child) => sum + child.signalements.length, 0),
    [allFlaggedChildren]
  );

  const analyzedSignalementIds = useMemo(() => {
    const ids = new Set();
    analysisHistory.forEach((entry) => {
      (entry.analyzed_signalement_ids || []).forEach((id) => ids.add(id));
    });
    return ids;
  }, [analysisHistory]);

  const handleAnalyze = async (forceAll = false) => {
    if (!reportData) return;

    setIsAnalyzing(true);
    setIsAiPanelOpen(true);

    try {
      const childrenToAnalyze = allFlaggedChildren;
      if (childrenToAnalyze.length === 0) {
        setAiAnalysis({ error: "Aucun élève avec des signalements." });
        return;
      }

      const childrenText = childrenToAnalyze
        .map((child) => {
          const signalements = child.signalements
            .filter((signalement) => forceAll || !analyzedSignalementIds.has(signalement.id))
            .map(
              (signalement) =>
                `- Type: ${signalement.alert_type} | "${signalement.comment || "Sans commentaire"}" (${formatDate(signalement.incident_time)})`
            )
            .join("\n  ");

          if (!signalements) return null;

          return `Élève: ${child.child_name} (Classe: ${child.class_name})\n  Signalements:\n  ${signalements}`;
        })
        .filter(Boolean)
        .join("\n\n");

      if (!childrenText) {
        setAiAnalysis({ error: "Tous les signalements ont déjà été analysés." });
        return;
      }

      const response = await api.post("/admin/ai/analyze-reports", {
        childrenText,
        max_tokens: 3500,
      });

      if (!response.data?.output) return;

      let jsonText = response.data.output.trim();
      if (jsonText.startsWith("```json")) {
        jsonText = jsonText.replace(/^```json/, "").replace(/```$/, "").trim();
      } else if (jsonText.startsWith("```")) {
        jsonText = jsonText.replace(/^```/, "").replace(/```$/, "").trim();
      }

      try {
        const parsed = JSON.parse(jsonText);
        setAiAnalysis(parsed);

        for (const child of childrenToAnalyze) {
          const childResult = (parsed.eleves || []).find(
            (student) => (student.nom || "").toLowerCase().trim() === (child.child_name || "").toLowerCase().trim()
          );

          if (!childResult) continue;

          const childSignalementIds = child.signalements.map((signalement) => signalement.id);
          await api.post("/admin/reports/analysis-history", {
            planning_id: selectedPlanningId,
            child_id: child.child_id,
            analysis_result: JSON.stringify(childResult),
            analyzed_signalement_ids: childSignalementIds,
          });
        }

        await fetchHistory(selectedPlanningId);
      } catch {
        setAiAnalysis({ error: "Format JSON invalide.", raw: response.data.output });
      }
    } catch (error) {
      setAiAnalysis({ error: `Erreur IA: ${error?.response?.data?.message || error.message}` });
    } finally {
      setIsAnalyzing(false);
    }
  };

  const styles = getStyles(colors, isDark);

  return (
    <Box {...(showHeader ? { m: "20px" } : {})}>
      {showHeader && <Header title="SIGNALEMENTS COMPORTEMENTAUX" />}

      <PlanningToolbar
        colors={colors}
        isDark={isDark}
        plannings={plannings}
        selectedPlanningId={selectedPlanningId}
        setSelectedPlanningId={setSelectedPlanningId}
        searchTerm={searchTerm}
        setSearchTerm={setSearchTerm}
      />

      {loading ? (
        <Box sx={styles.loadingState}>
          <CircularProgress sx={{ color: colors.greenAccent[500] }} />
          <Typography sx={styles.loadingText}>Chargement des signalements...</Typography>
        </Box>
      ) : !reportData ? (
        <Box sx={styles.emptyPanel}>
          <Typography sx={styles.emptyStateTitle}>Aucune donnée disponible</Typography>
          <Typography sx={styles.emptyStateText}>Les signalements de l'année sélectionnée n'ont pas pu être chargés.</Typography>
        </Box>
      ) : (
        <>
          <SummaryBar
            colors={colors}
            isDark={isDark}
            totalSignalements={totalSignalements}
            flaggedCount={allFlaggedChildren.length}
            classCount={new Set(allFlaggedChildren.map((child) => child.class_id)).size}
          />

          <ChildrenListSection
            colors={colors}
            isDark={isDark}
            filteredChildren={filteredChildren}
            expandedChild={expandedChild}
            setExpandedChild={setExpandedChild}
            analyzedSignalementIds={analyzedSignalementIds}
            aiEnabled={aiEnabled}
            isAnalyzing={isAnalyzing}
            aiAnalysis={aiAnalysis}
            analysisHistory={analysisHistory}
            onAnalyze={handleAnalyze}
            isAiPanelOpen={isAiPanelOpen}
            setIsAiPanelOpen={setIsAiPanelOpen}
          />
        </>
      )}
    </Box>
  );
};

export default Reports;

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
      gap: "16px",
      alignItems: { xs: "flex-start", lg: "center" },
      flexDirection: { xs: "column", lg: "row" },
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
    actionsRow: {
      display: "flex",
      gap: "10px",
      flexWrap: "wrap",
      justifyContent: { xs: "flex-start", lg: "flex-end" },
      width: "100%",
      maxWidth: { lg: "unset" },
    },
    primaryActionButton: (enabled) => ({
      minHeight: 40,
      px: "16px",
      ...getAdminPrimaryButtonSx(enabled ? {} : { backgroundColor: colors.grey[700], "&:hover": { backgroundColor: colors.grey[700], boxShadow: "none" } }),
    }),
    secondaryActionButton: (enabled) => ({
      minHeight: 40,
      px: "16px",
      ...getAdminSecondaryButtonSx(enabled ? {} : { backgroundColor: colors.grey[700], "&:hover": { backgroundColor: colors.grey[700], boxShadow: "none" } }),
    }),
    ghostActionButton: {
      minHeight: 40,
      px: "8px",
      borderRadius: "12px",
      textTransform: "none",
      fontWeight: 700,
      color: colors.grey[200],
      "&:hover": {
        backgroundColor: isDark ? "rgba(148, 163, 184, 0.08)" : "rgba(148, 163, 184, 0.12)",
      },
    },
    aiDisabledBanner: {
      display: "flex",
      alignItems: "flex-start",
      gap: "10px",
      mx: { xs: "16px", md: "22px" },
      mt: "16px",
      p: "12px 14px",
      borderRadius: "14px",
      backgroundColor: isDark ? "rgba(127, 29, 29, 0.24)" : "rgba(254, 226, 226, 0.86)",
      border: `1px solid ${isDark ? "rgba(248, 113, 113, 0.18)" : "rgba(248, 113, 113, 0.22)"}`,
    },
    aiDisabledText: {
      fontSize: "0.84rem",
      color: isDark ? colors.grey[200] : "#7f1d1d",
      lineHeight: 1.5,
    },
    aiInlinePanel: {
      mx: { xs: "16px", md: "22px" },
      mt: "16px",
      mb: "4px",
      p: { xs: "16px", md: "18px" },
      borderRadius: "18px",
      backgroundColor: surfaceAlt,
      border: `1px solid ${border}`,
    },
    inlineAiIconWrap: {
      width: 34,
      height: 34,
      borderRadius: "12px",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      backgroundColor: isDark ? "rgba(45, 212, 191, 0.10)" : "rgba(13, 148, 136, 0.08)",
    },
    inlineAiTitle: {
      fontSize: "0.94rem",
      fontWeight: 700,
      color: colors.grey[100],
    },
    inlineAiText: {
      mt: "2px",
      fontSize: "0.83rem",
      color: colors.grey[400],
    },
    aiLoadingState: {
      display: "flex",
      alignItems: "center",
      gap: "12px",
      py: "8px",
    },
    aiResultsGrid: {
      display: "grid",
      gridTemplateColumns: { xs: "1fr", xl: "repeat(2, minmax(0, 1fr))" },
      gap: "14px",
    },
    aiResultCard: {
      p: "16px",
      borderRadius: "16px",
      backgroundColor: isDark ? "rgba(15, 23, 32, 0.92)" : "rgba(255, 255, 255, 0.96)",
      border: `1px solid ${border}`,
    },
    aiResultName: {
      fontSize: "1rem",
      fontWeight: 800,
      color: colors.grey[100],
    },
    aiResultClass: {
      mt: "4px",
      fontSize: "0.82rem",
      color: colors.grey[400],
    },
    aiClassChip: {
      backgroundColor: isDark ? "rgba(45, 212, 191, 0.10)" : "rgba(13, 148, 136, 0.10)",
      color: colors.greenAccent[400],
      fontWeight: 700,
      border: `1px solid ${isDark ? "rgba(45, 212, 191, 0.16)" : "rgba(13, 148, 136, 0.16)"}`,
    },
    aiTextBlock: {
      mt: "12px",
      p: "12px 14px",
      borderRadius: "12px",
      backgroundColor: surfaceAlt,
      border: `1px solid ${border}`,
    },
    aiBlockLabel: {
      fontSize: "0.74rem",
      fontWeight: 800,
      textTransform: "uppercase",
      letterSpacing: "0.05em",
      color: colors.grey[400],
      mb: "6px",
    },
    aiBlockText: {
      fontSize: "0.9rem",
      lineHeight: 1.6,
      color: colors.grey[200],
    },
    aiRemarksCard: {
      mt: "14px",
      p: "14px 16px",
      borderRadius: "16px",
      backgroundColor: isDark ? "rgba(15, 23, 32, 0.92)" : "rgba(255, 255, 255, 0.96)",
      border: `1px solid ${border}`,
    },
    aiRemarksTitle: {
      fontSize: "0.9rem",
      fontWeight: 800,
      color: colors.grey[100],
      mb: "10px",
    },
    aiRemarksText: {
      fontSize: "0.88rem",
      color: colors.grey[200],
      lineHeight: 1.5,
    },
    aiErrorCard: {
      p: "14px 16px",
      borderRadius: "16px",
      backgroundColor: isDark ? "rgba(127, 29, 29, 0.28)" : "rgba(254, 226, 226, 0.88)",
      border: `1px solid ${isDark ? "rgba(248, 113, 113, 0.18)" : "rgba(248, 113, 113, 0.22)"}`,
    },
    aiErrorText: {
      color: isDark ? "#fecaca" : "#991b1b",
      fontWeight: 700,
    },
    aiRawText: {
      display: "block",
      mt: "10px",
      color: colors.grey[300],
      whiteSpace: "pre-wrap",
    },
    tableScroll: {
      px: { xs: "0", md: "0" },
      pb: "6px",
      overflowX: "auto",
    },
    tableInner: {
      minWidth: 740,
      px: { xs: "16px", md: "22px" },
      pb: { xs: "16px", md: "22px" },
      pt: "18px",
    },
    tableHeaderRow: {
      display: "grid",
      gridTemplateColumns: "64px minmax(0, 1.7fr) 160px 160px 40px",
      alignItems: "stretch",
      border: `1px solid ${border}`,
      borderRadius: "14px",
      overflow: "hidden",
      mb: "10px",
      backgroundColor: mutedHeader,
    },
    headerSpacerCell: {
      backgroundColor: "transparent",
    },
    headerNameCell: {
      pl: 0,
      pr: "16px",
      py: "12px",
      borderRight: `1px solid ${border}`,
      display: "flex",
      alignItems: "center",
    },
    headerMetricCell: {
      px: "12px",
      py: "12px",
      borderRight: `1px solid ${border}`,
      display: "flex",
      alignItems: "center",
    },
    headerMetricCellLast: {
      px: "12px",
      py: "12px",
      display: "flex",
      alignItems: "center",
    },
    headerText: {
      fontSize: "0.76rem",
      fontWeight: 800,
      letterSpacing: "0.05em",
      textTransform: "uppercase",
      color: colors.grey[300],
    },
    rowShell: {
      mb: "10px",
      borderRadius: "18px",
      border: `1px solid ${border}`,
      backgroundColor: surfaceAlt,
      overflow: "hidden",
    },
    tableRow: {
      display: "grid",
      gridTemplateColumns: "64px minmax(0, 1.7fr) 160px 160px 40px",
      alignItems: "center",
      cursor: "pointer",
      transition: "background-color 0.2s ease",
      "&:hover": {
        backgroundColor: isDark ? "rgba(30, 41, 59, 0.72)" : "rgba(241, 245, 249, 0.92)",
      },
    },
    avatarCell: {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
      py: "14px",
    },
    avatarBadge: {
      width: 40,
      height: 40,
      borderRadius: "14px",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      color: "#f8fafc",
      fontWeight: 800,
      fontSize: "0.98rem",
      letterSpacing: "0.02em",
      boxShadow: "inset 0 1px 0 rgba(255,255,255,0.22)",
    },
    nameCell: {
      py: "16px",
      pr: "16px",
      minWidth: 0,
    },
    studentName: {
      fontSize: "1rem",
      fontWeight: 800,
      color: colors.grey[100],
      whiteSpace: "nowrap",
      overflow: "hidden",
      textOverflow: "ellipsis",
    },
    studentClass: {
      mt: "4px",
      fontSize: "0.82rem",
      color: colors.grey[400],
      whiteSpace: "nowrap",
      overflow: "hidden",
      textOverflow: "ellipsis",
    },
    metricCell: {
      px: "12px",
      display: "flex",
      alignItems: "center",
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
      color: count >= 3 ? (isDark ? "#fecaca" : "#991b1b") : colors.grey[200],
      backgroundColor: count >= 3 ? (isDark ? "rgba(127, 29, 29, 0.26)" : "rgba(254, 226, 226, 0.92)") : mutedHeader,
      border: `1px solid ${count >= 3 ? (isDark ? "rgba(248, 113, 113, 0.16)" : "rgba(248, 113, 113, 0.18)") : border}`,
    }),
    statusAnalyzedChip: {
      backgroundColor: isDark ? "rgba(20, 184, 166, 0.16)" : "rgba(15, 118, 110, 0.10)",
      color: colors.greenAccent[400],
      fontWeight: 800,
      border: `1px solid ${isDark ? "rgba(45, 212, 191, 0.16)" : "rgba(13, 148, 136, 0.14)"}`,
    },
    statusPartialChip: {
      backgroundColor: isDark ? "rgba(245, 158, 11, 0.16)" : "rgba(254, 240, 138, 0.84)",
      color: isDark ? "#fcd34d" : "#92400e",
      fontWeight: 800,
      border: `1px solid ${isDark ? "rgba(245, 158, 11, 0.16)" : "rgba(245, 158, 11, 0.18)"}`,
    },
    statusPendingChip: {
      backgroundColor: mutedHeader,
      color: colors.grey[300],
      fontWeight: 700,
      border: `1px solid ${border}`,
    },
    expandCell: {
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      pr: "8px",
    },
    expandedRow: {
      px: "20px",
      pb: "18px",
      borderTop: `1px solid ${border}`,
      backgroundColor: isDark ? "rgba(15, 23, 32, 0.78)" : "rgba(248, 250, 252, 0.92)",
    },
    expandedTitle: {
      fontSize: "0.8rem",
      fontWeight: 800,
      letterSpacing: "0.05em",
      textTransform: "uppercase",
      color: colors.grey[400],
      py: "14px",
    },
    signalementCard: {
      p: "14px 16px",
      borderRadius: "14px",
      backgroundColor: isDark ? "rgba(19, 28, 39, 0.9)" : "rgba(255, 255, 255, 0.98)",
      border: `1px solid ${border}`,
    },
    signalementType: {
      fontSize: "0.82rem",
      fontWeight: 800,
      letterSpacing: "0.02em",
    },
    analyzedMiniChip: {
      backgroundColor: isDark ? "rgba(20, 184, 166, 0.16)" : "rgba(15, 118, 110, 0.10)",
      color: colors.greenAccent[400],
      fontWeight: 700,
    },
    signalementMeta: {
      fontSize: "0.78rem",
      color: colors.grey[400],
    },
    signalementComment: {
      minWidth: "min(360px, 100%)",
      maxWidth: 420,
      fontSize: "0.88rem",
      lineHeight: 1.6,
      color: colors.grey[200],
      whiteSpace: "pre-wrap",
    },
    emptyState: {
      py: "48px",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      gap: "10px",
      color: colors.grey[300],
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
      textAlign: "center",
      maxWidth: 420,
    },
    loadingState: {
      minHeight: 240,
      borderRadius: "22px",
      background: surface,
      border: `1px solid ${border}`,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      gap: "12px",
    },
    loadingText: {
      color: colors.grey[300],
    },
    emptyPanel: {
      minHeight: 240,
      borderRadius: "22px",
      background: surface,
      border: `1px solid ${border}`,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      gap: "10px",
      px: "20px",
    },
    alertColor: (alertType) => {
      const normalized = (alertType || "").toLowerCase();
      if (normalized === "positif") return colors.greenAccent[500];
      if (normalized === "warning") return "#f59e0b";
      return colors.redAccent[500];
    },
  };
}
