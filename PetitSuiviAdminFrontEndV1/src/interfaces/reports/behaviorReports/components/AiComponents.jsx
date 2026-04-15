import { Box, Chip, Typography } from "@mui/material";
import WarningAmberRoundedIcon from "@mui/icons-material/WarningAmberRounded";
import { getStyles } from "../utils/styles";

export const AiDisabledBanner = ({ colors, isDark }) => {
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

export const AiResultCards = ({ colors, isDark, aiAnalysis }) => {
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
