import { Box, FormControl, MenuItem, Select, Typography } from "@mui/material";
import { getStyles } from "../utils/styles";

export const PlanningToolbar = ({ colors, isDark, plannings, selectedPlanningId, setSelectedPlanningId }) => {
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
