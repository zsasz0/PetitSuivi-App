import { Box, Collapse, Pagination, Typography } from "@mui/material";
import ExpandMoreRoundedIcon from "@mui/icons-material/ExpandMoreRounded";
import { getStyles } from "../utils/styles";
import { formatDateTime, getAvatarGradient } from "../utils/formatters";

export const HistoryList = ({
  colors,
  isDark,
  paginatedHistory,
  expandedHistoryId,
  setExpandedHistoryId,
  totalPages,
  page,
  setPage,
}) => {
  const styles = getStyles(colors, isDark);

  return (
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
  );
};
