export function getPlanningLabel(startYear, endYear) {
    return startYear === endYear ? `${startYear}` : `${startYear}/${endYear}`;
}

export function mapPlanningFromApi(planning) {
    const startYear = Number(planning.Startyear ?? planning.startYear ?? planning.start_year);
    const endYear = Number(planning.Endyear ?? planning.endYear ?? planning.end_year);
    const startDate = typeof (planning.startDate ?? planning.start_date) === "string"
        ? (planning.startDate ?? planning.start_date).slice(0, 10)
        : "";
    const endDate = typeof (planning.endDate ?? planning.end_date) === "string"
        ? (planning.endDate ?? planning.end_date).slice(0, 10)
        : "";

    return {
        id: planning.id,
        startYear,
        endYear,
        startDate,
        endDate,
        label: planning.label || getPlanningLabel(startYear, endYear),
        isActive: !!planning.is_active,
    };
}

export function getDefaultPlanning(planningRows, referenceDate) {
    if (!Array.isArray(planningRows) || planningRows.length === 0) return null;

    return planningRows.slice().sort((a, b) => {
        const aYear = Number(a.startYear) || 0;
        const bYear = Number(b.startYear) || 0;
        return bYear - aYear;
    })[0];
}
