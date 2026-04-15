import { Box, Typography } from "@mui/material";
import { formatCurrency } from "../utils/formatters";

/**
 * @file components/RecentTransactionsPanel.jsx
 * Displays the 10 most recent transactions in a chronological flat-list.
 */
const RecentTransactionsPanel = ({ allTransactions, colors }) => (
  <Box
    mt="20px"
    backgroundColor={colors.primary[400]}
    borderRadius="12px"
    p="20px"
  >
    <Typography
      variant="h5"
      fontWeight="bold"
      color={colors.grey[100]}
      mb="15px"
    >
      Historique récent des transactions ({Math.min(10, allTransactions.length)}
      )
    </Typography>
    {allTransactions.length === 0 ? (
      <Typography color={colors.grey[300]} textAlign="center" py="20px">
        Aucune transaction enregistrée.
      </Typography>
    ) : (
      <Box
        display="flex"
        flexDirection="column"
        gap="8px"
        maxHeight="300px"
        overflow="auto"
      >
        {allTransactions.slice(0, 10).map((tx) => (
          <Box
            key={tx.id}
            display="flex"
            justifyContent="space-between"
            alignItems="center"
            p="10px 15px"
            borderRadius="8px"
            backgroundColor={
              tx.isFrais ? colors.blueAccent[800] : colors.primary[500]
            }
          >
            <Box>
              <Typography fontWeight="bold" color={colors.greenAccent[400]}>
                {tx.childName}
              </Typography>
              <Typography
                variant="caption"
                color={tx.isFrais ? colors.blueAccent[200] : colors.grey[300]}
              >
                {tx.className} · {tx.date}{" "}
                {tx.isFrais && "· Frais d'Inscription"}
              </Typography>
            </Box>
            <Typography
              fontWeight="bold"
              color={
                tx.isFrais ? colors.blueAccent[300] : colors.greenAccent[500]
              }
            >
              +{formatCurrency(tx.amount)}
            </Typography>
          </Box>
        ))}
      </Box>
    )}
  </Box>
);

export default RecentTransactionsPanel;
