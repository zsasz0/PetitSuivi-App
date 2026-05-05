import { Box, FormControl, InputAdornment, MenuItem, Select, TextField, Typography } from "@mui/material";
import SearchIcon from "@mui/icons-material/Search";
import AssessmentOutlinedIcon from "@mui/icons-material/AssessmentOutlined";
import Groups2OutlinedIcon from "@mui/icons-material/Groups2Outlined";
import NotificationImportantOutlinedIcon from "@mui/icons-material/NotificationImportantOutlined";
import { getStyles } from "../utils/styles";

export const SummaryBar = ({ colors, isDark, totalAnalyses, uniqueChildren, totalSignals }) => {
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

export const Toolbar = ({ colors, isDark, plannings, selectedPlanningId, setSelectedPlanningId, searchTerm, setSearchTerm }) => {
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
