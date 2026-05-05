import { Box, Typography } from "@mui/material";

/**
 * A shared set of stat cards for both Parents and Teachers.
 * Dynamic rendering based on the items array passed.
 * @param {Array} items Array of { title, value, icon, iconBg, iconColor }
 * @param {Object} styles The styles object mapping
 * @param {Object} colors The colors theme
 * @param {boolean} isDark is dark theme enabled
 */
const SharedStatsCards = ({ items = [], styles, colors, isDark }) => {
    return (
        <Box 
            display="grid" 
            gridTemplateColumns={{ xs: "1fr", sm: "repeat(2, 1fr)", xl: `repeat(${items.length}, 1fr)` }} 
            gap="14px" 
            mb="20px"
        >
            {items.map((item, index) => (
                <Box key={`${item.title}-${index}`} sx={styles.statCard}>
                    <Box 
                        sx={{ 
                            ...styles.statIcon, 
                            background: item.iconBg, 
                            color: item.iconColor 
                        }}
                    >
                        {item.icon}
                    </Box>
                    <Box minWidth={0}>
                        <Typography variant="body2" color={colors.grey[300]}>
                            {item.title}
                        </Typography>
                        <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mt="4px">
                            {item.value}
                        </Typography>
                    </Box>
                </Box>
            ))}
        </Box>
    );
};

export default SharedStatsCards;
