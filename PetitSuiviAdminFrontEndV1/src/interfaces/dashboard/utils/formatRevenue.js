export const formatRevenuePercentage = (collected, expected) => {
  if (!expected || expected <= 0) return "0%";
  return `${Math.round((collected / expected) * 100)}%`;
};