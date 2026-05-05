import { Box, Chip, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow } from "@mui/material";
import { getStyles } from "../utils/styles";
import { formatAmount } from "../utils/formatters";

export const ParentTableSection = ({ colors, isDark, list, title, color }) => {
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
