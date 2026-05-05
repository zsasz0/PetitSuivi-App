import { Box, Typography, useTheme } from "@mui/material";
import { PieChart, Pie, Cell, ResponsiveContainer } from "recharts";

const BilanFinancier = ({ stats, revenuePct, colors }) => {
  const theme = useTheme();
  const isDark = theme.palette.mode === "dark";

  const pendingAmount = Math.max(
    0,
    stats.revenueExpected - stats.revenueCollected
  );

  const pendingColor = isDark ? colors.redAccent[400] : "#d66a63";

  const chartData = [
    { name: "Collecté", value: stats.revenueCollected },
    { name: "En attente", value: pendingAmount },
  ].filter((item) => item.value > 0);

  return (
    <Box
      gridColumn="span 12"
      gridRow="span 2"
      backgroundColor={colors.primary[400]}
      p="18px"
      borderRadius="16px"
      sx={{
        boxShadow: "0 10px 24px rgba(0,0,0,0.07)",
        border: isDark
          ? "1px solid rgba(255,255,255,0.06)"
          : "1px solid rgba(148,163,184,0.16)",
      }}
    >
      <Typography variant="h6" fontWeight="700" mb="16px" color={colors.grey[100]}>
        Bilan Financier (Global / Toutes années)
      </Typography>

      <Box
        display="grid"
        gridTemplateColumns={{ xs: "1fr", md: "220px 1fr" }}
        gap="18px"
        alignItems="center"
      >
        {/* Pie Chart */}
        <Box height="190px" position="relative">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={chartData}
                dataKey="value"
                cx="50%"
                cy="50%"
                innerRadius={50}
                outerRadius={72}
                paddingAngle={3}
                stroke="none"
              >
                {chartData.map((entry) => (
                  <Cell
                    key={entry.name}
                    fill={
                      entry.name === "Collecté"
                        ? colors.greenAccent[500]
                        : pendingColor
                    }
                  />
                ))}
              </Pie>
            </PieChart>
          </ResponsiveContainer>

          <Box
            position="absolute"
            top="50%"
            left="50%"
            sx={{ transform: "translate(-50%, -50%)" }}
            textAlign="center"
          >
            <Typography variant="h5" fontWeight="800" color={colors.grey[100]}>
              {revenuePct}
            </Typography>
            <Typography variant="body2" color={colors.grey[300]}>
              collecté
            </Typography>
          </Box>
        </Box>

        {/* Stats */}
        <Box display="flex" flexDirection="column" gap="12px">
          <Box display="flex" justifyContent="space-between">
            <Typography color={colors.grey[300]}>
              Revenus attendus
            </Typography>
            <Typography fontWeight="800" color={colors.blueAccent[500]}>
              {stats.revenueExpected.toLocaleString("fr-FR")} TND
            </Typography>
          </Box>

          <Box display="flex" justifyContent="space-between">
            <Typography color={colors.grey[300]}>
              Revenus collectés
            </Typography>
            <Typography fontWeight="800" color={colors.greenAccent[500]}>
              {stats.revenueCollected.toLocaleString("fr-FR")} TND
            </Typography>
          </Box>

          <Box display="flex" justifyContent="space-between">
            <Typography color={colors.grey[300]}>En attente</Typography>
            <Typography fontWeight="800" color={pendingColor}>
              {pendingAmount.toLocaleString("fr-FR")} TND
            </Typography>
          </Box>

          {/* Progress */}
          <Box mt="4px">
            <Box display="flex" justifyContent="space-between" mb="6px">
              <Typography variant="body2" color={colors.grey[300]}>
                Progression du recouvrement
              </Typography>
              <Typography variant="body2" fontWeight="700">
                {revenuePct} collecté
              </Typography>
            </Box>

            <Box
              height="12px"
              borderRadius="999px"
              backgroundColor={colors.primary[500]}
              overflow="hidden"
            >
              <Box
                height="100%"
                width={revenuePct}
                borderRadius="999px"
                sx={{
                  background: `linear-gradient(90deg, ${colors.greenAccent[500]}, ${colors.blueAccent[400]})`,
                }}
              />
            </Box>
          </Box>

          {/* Legend */}
          <Box display="flex" gap="14px" flexWrap="wrap" pt="2px">
            <Box display="flex" alignItems="center" gap="8px">
              <Box
                width="10px"
                height="10px"
                borderRadius="999px"
                backgroundColor={colors.greenAccent[500]}
              />
              <Typography variant="body2" color={colors.grey[300]}>
                Collecté
              </Typography>
            </Box>

            <Box display="flex" alignItems="center" gap="8px">
              <Box
                width="10px"
                height="10px"
                borderRadius="999px"
                backgroundColor={pendingColor}
              />
              <Typography variant="body2" color={colors.grey[300]}>
                En attente
              </Typography>
            </Box>
          </Box>
        </Box>
      </Box>
    </Box>
  );
};

export default BilanFinancier;