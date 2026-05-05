import React from 'react';
import { Box, Typography } from "@mui/material";

/**
 * A global shared component for rendering statistics cards.
 * 
 * @param {Array} cards Array of { label, value, desc, icon, color, bg } (or { title, value, icon, iconColor, iconBg })
 * @param {Object} colors Theme colors object. Required.
 */
const GlobalStatsCards = ({ cards = [], colors }) => {
    return (
        <Box
            display="grid"
            gridTemplateColumns={{ xs: "1fr", sm: "repeat(2, 1fr)", xl: `repeat(${cards.length}, 1fr)` }}
            gap="14px"
            mb="20px"
        >
            {cards.map((card, idx) => {
                const title = card.label || card.title;
                const iconBg = card.bg || card.iconBg;
                const iconColor = card.color || card.iconColor;

                return (
                    <Box
                        key={title || idx}
                        backgroundColor={colors.primary[400]}
                        display="flex"
                        alignItems="center"
                        gap="14px"
                        p="16px 18px"
                        borderRadius="14px"
                        border={`1px solid ${colors.primary[500]}`}
                        boxShadow="0px 10px 24px rgba(0, 0, 0, 0.08)"
                    >
                        <Box
                            width="48px"
                            height="48px"
                            borderRadius="14px"
                            display="inline-flex"
                            alignItems="center"
                            justifyContent="center"
                            flexShrink={0}
                            sx={{ backgroundColor: iconBg, color: iconColor }}
                        >
                            {card.icon}
                        </Box>
                        <Box minWidth={0}>
                            <Typography variant="body2" color={colors.grey[300]}>
                                {title}
                            </Typography>
                            <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mt="4px">
                                {card.value}
                            </Typography>
                            {card.desc && (
                                <Typography variant="caption" color={colors.grey[400]}>
                                    {card.desc}
                                </Typography>
                            )}
                        </Box>
                    </Box>
                );
            })}
        </Box>
    );
};

export default GlobalStatsCards;
