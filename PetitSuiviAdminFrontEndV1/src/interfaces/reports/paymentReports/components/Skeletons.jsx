import { Box, Skeleton } from "@mui/material";
import { getStyles } from "../utils/styles";

export const LoadingSkeleton = ({ colors, isDark }) => {
  const styles = getStyles(colors, isDark);

  return (
    <>
      <Box sx={styles.summaryGrid}>
        {[1, 2, 3].map((item) => (
          <Box key={item} sx={styles.summarySkeletonCard}>
            <Skeleton variant="text" width="44%" height={22} />
            <Skeleton variant="text" width="58%" height={42} />
          </Box>
        ))}
      </Box>

      <Box sx={styles.chartsGrid}>
        {[1, 2].map((item) => (
          <Box key={item} sx={styles.chartCard}>
            <Skeleton variant="text" width="48%" height={28} />
            <Skeleton variant="rectangular" height={280} sx={{ borderRadius: "18px", mt: 1.5 }} />
          </Box>
        ))}
      </Box>

      <Box sx={styles.chartCard}>
        <Skeleton variant="text" width="32%" height={28} />
        <Skeleton variant="text" width="44%" height={22} />
        <Skeleton variant="rectangular" height={320} sx={{ borderRadius: "18px", mt: 1.5 }} />
      </Box>
    </>
  );
};

export const ModalSkeleton = ({ colors, isDark }) => {
  return (
    <Box>
      <Box display="flex" gap="12px" mb="18px" flexWrap="wrap">
        <Skeleton variant="rounded" width={160} height={32} />
        <Skeleton variant="rounded" width={160} height={32} />
      </Box>
      {[1, 2].map((item) => (
        <Box key={item} sx={{ mb: 2.5 }}>
          <Skeleton variant="text" width="28%" height={24} />
          <Skeleton variant="rectangular" height={160} sx={{ borderRadius: "16px", mt: 1 }} />
        </Box>
      ))}
    </Box>
  );
};
