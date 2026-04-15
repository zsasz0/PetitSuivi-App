import { Box, FormControl, InputAdornment, MenuItem, Select, TextField, Typography } from "@mui/material";
import SearchIcon from "@mui/icons-material/Search";
import NotificationImportantOutlinedIcon from "@mui/icons-material/NotificationImportantOutlined";
import Groups2OutlinedIcon from "@mui/icons-material/Groups2Outlined";
import HomeWorkOutlinedIcon from "@mui/icons-material/HomeWorkOutlined";
import { getStyles } from "../utils/styles";

export const SummaryBar = ({ colors, isDark, totalSignalements, flaggedCount, classCount }) => {
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

export const PlanningToolbar = ({ colors, isDark, plannings, selectedPlanningId, setSelectedPlanningId, searchTerm, setSearchTerm }) => {
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
