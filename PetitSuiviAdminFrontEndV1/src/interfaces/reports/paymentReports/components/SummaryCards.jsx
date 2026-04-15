import { Box, Typography } from "@mui/material";
import { getStyles } from "../utils/styles";
import { FINANCE_COLORS } from "../utils/constants";
import { formatAmount } from "../utils/formatters";
import AccountBalanceWalletOutlinedIcon from "@mui/icons-material/AccountBalanceWalletOutlined";
import SavingsOutlinedIcon from "@mui/icons-material/SavingsOutlined";
import PendingActionsOutlinedIcon from "@mui/icons-material/PendingActionsOutlined";

export const SummaryCards = ({ colors, isDark, summary }) => {
  const styles = getStyles(colors, isDark);
  const items = [
    {
      label: "Revenus attendus",
      value: summary?.total_expected || 0,
      color: FINANCE_COLORS.expected,
      icon: AccountBalanceWalletOutlinedIcon,
    },
    {
      label: "Revenus collectés",
      value: summary?.total_paid || 0,
      color: FINANCE_COLORS.paid,
      icon: SavingsOutlinedIcon,
    },
    {
      label: "En attente",
      value: summary?.total_pending || 0,
      color: FINANCE_COLORS.pending,
      icon: PendingActionsOutlinedIcon,
    },
  ];

  return (
    <Box sx={styles.summaryGrid}>
      {items.map(({ label, value, color, icon: Icon }) => (
        <Box key={label} sx={styles.summaryCard(color)}>
          <Box sx={styles.summaryCardTopRow}>
            <Box>
              <Typography sx={styles.summaryLabel}>{label}</Typography>
              <Typography sx={styles.summaryValue}>
                {formatAmount(value)}
                <Typography component="span" sx={styles.summaryCurrency}>
                  TND
                </Typography>
              </Typography>
            </Box>
            <Box sx={styles.summaryIconWrap(color)}>
              <Icon sx={{ fontSize: 20, color }} />
            </Box>
          </Box>
        </Box>
      ))}
    </Box>
  );
};
