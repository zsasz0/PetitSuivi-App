import { Box, Button, Chip, CircularProgress, Collapse, Typography } from "@mui/material";
import InsightsOutlinedIcon from "@mui/icons-material/InsightsOutlined";
import PsychologyAltOutlinedIcon from "@mui/icons-material/PsychologyAltOutlined";
import NotificationImportantOutlinedIcon from "@mui/icons-material/NotificationImportantOutlined";
import ExpandMoreRoundedIcon from "@mui/icons-material/ExpandMoreRounded";
import { getStyles } from "../utils/styles";
import { getAvatarGradient, formatDate } from "../utils/formatters";
import { AiDisabledBanner, AiResultCards } from "./AiComponents";

export const SignalementDetail = ({ colors, isDark, signalement, isAlreadyAnalyzed }) => {
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

export const ChildRow = ({ colors, isDark, child, isExpanded, onToggle, analyzedSignalementIds }) => {
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

export const ChildrenListSection = ({
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
          <Box display="flex" alignItems="center" gap="10px" mb={aiAnalysis || isAnalyzing ? { xs: 2, sm: 2 } : 0}>
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
