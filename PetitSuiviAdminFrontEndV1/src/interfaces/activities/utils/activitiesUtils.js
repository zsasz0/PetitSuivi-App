/**
 * @file activitiesUtils.js
 * @description Helper functions for activities interface
 */

export const normalizeCriterionName = (name) =>
  (name || "")
    .toLowerCase()
    .trim()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");

export const toUniqueIntegerIds = (arr) => [
  ...new Set((arr || []).map(Number).filter((n) => Number.isInteger(n))),
];

export function parseSuggestedCriterionIds(rawOutput, criteriaList) {
  const allowedIds = new Set(
    criteriaList.map((c) => Number(c.id)).filter((id) => Number.isInteger(id)),
  );
  const criteriaByName = new Map(
    criteriaList.map((c) => [normalizeCriterionName(c.name), Number(c.id)]),
  );
  const sanitize = (ids) =>
    toUniqueIntegerIds(ids).filter((id) => allowedIds.has(id));
  const mapNames = (names) =>
    toUniqueIntegerIds(
      (Array.isArray(names) ? names : [names])
        .map((n) => criteriaByName.get(normalizeCriterionName(n)))
        .filter(Boolean),
    );
  const text = String(rawOutput || "").trim();
  if (!text) return [];
  const clean = text
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/\s*```$/i, "")
    .trim();
  const tryParse = (c) => {
    if (!c) return [];
    if (Array.isArray(c)) {
      const n = sanitize(c);
      return n.length > 0 ? n : sanitize(mapNames(c));
    }
    if (typeof c === "object") {
      for (const k of [
        "criteriaIds",
        "criterionIds",
        "ids",
        "criteria",
        "suggestedCriteria",
      ]) {
        if (k in c) {
          const r = tryParse(c[k]);
          if (r.length > 0) return r;
        }
      }
    }
    return [];
  };
  try {
    const p = JSON.parse(clean);
    const s = tryParse(p);
    if (s.length > 0) return s;
  } catch {}
  const fromText = sanitize((clean.match(/\b\d+\b/g) || []).map(Number));
  if (fromText.length > 0) return fromText;
  const low = normalizeCriterionName(clean);
  return sanitize(
    criteriaList
      .filter((c) => low.includes(normalizeCriterionName(c.name)))
      .map((c) => Number(c.id)),
  );
}

export const getCurrentPlanningId = (planningRows) => {
  if (!planningRows.length) return null;

  return planningRows.slice().sort((a, b) => {
    const aYear = Number(a.startYear || a.start_year) || 0;
    const bYear = Number(b.startYear || b.start_year) || 0;
    return bYear - aYear;
  })[0].id;
};

export const normalizeActivityTitle = (value) => String(value || "").trim().toLowerCase();

export const parseTimeToMinutes = (t) => {
  if (!t) return null;
  const [h, m] = t.split(":").map(Number);
  if (isNaN(h) || isNaN(m)) return null;
  return h * 60 + m;
};

export const formatMinutesToHourLabel = (m) => {
  const h = Math.floor(m / 60);
  const mm = m % 60;
  return `${String(h).padStart(2, "0")}:${String(mm).padStart(2, "0")}`;
};

export const getTimelineWindow = (activities) => {
  let minStart = 8 * 60;
  let maxEnd = 16 * 60;
  if (!activities || activities.length === 0)
    return { start: minStart, end: maxEnd };
  for (const a of activities) {
    const start = parseTimeToMinutes(a.startTime);
    const end = parseTimeToMinutes(a.endTime);
    if (start !== null) minStart = Math.min(minStart, start);
    if (end !== null) maxEnd = Math.max(maxEnd, end);
  }
  return {
    start: Math.max(0, minStart - 30),
    end: Math.min(24 * 60, maxEnd + 30),
  };
};

export const getPlanningMonths = (planning) => {
  if (!planning) return [];
  const startDateStr = planning.start_date || planning.startDate;
  const endDateStr = planning.end_date || planning.endDate;
  if (!startDateStr || !endDateStr) return [];

  const start = new Date(`${startDateStr.slice(0, 10)}T00:00:00`);
  const end = new Date(`${endDateStr.slice(0, 10)}T00:00:00`);
  if (isNaN(start) || isNaN(end) || end < start) return [];

  const months = [];
  const cur = new Date(start.getFullYear(), start.getMonth(), 1);
  const endMonth = new Date(end.getFullYear(), end.getMonth(), 1);
  while (cur <= endMonth) {
    months.push(
      `${cur.getFullYear()}-${String(cur.getMonth() + 1).padStart(2, "0")}`,
    );
    cur.setMonth(cur.getMonth() + 1);
  }
  return months;
};

export const getWeeksOfMonth = (year, month) => {
  const firstDay = new Date(year, month, 1);
  const lastDay = new Date(year, month + 1, 0);
  const weeks = [];
  let current = new Date(firstDay);
  const dayOfWeek = current.getDay();
  const mondayOffset = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
  current.setDate(current.getDate() + mondayOffset);

  while (current <= lastDay || current.getDay() !== 1) {
    const week = [];
    for (let i = 0; i < 7; i++) {
      week.push({
        date: new Date(current),
        dow: i,
        day: current.getDate(),
        inMonth: current.getMonth() === month,
        dateStr: `${current.getFullYear()}-${String(current.getMonth() + 1).padStart(2, "0")}-${String(current.getDate()).padStart(2, "0")}`,
      });
      current.setDate(current.getDate() + 1);
    }
    weeks.push(week);
    if (current > lastDay && current.getDay() === 1) break;
  }
  return weeks;
};

export const isWeekendDate = (dateStr) => {
  if (!dateStr) return false;
  const [year, month, day] = dateStr.split("-").map(Number);
  const date = new Date(year, (month || 1) - 1, day || 1);
  const dayOfWeek = date.getDay();
  return dayOfWeek === 0 || dayOfWeek === 6;
};

export const getStatusLabel = (s) => {
  const n = (s || "").toLowerCase();
  if (n === "approved") return "✓ Approuvée";
  if (n === "pending") return "◷ En attente";
  if (n === "rejected") return "✕ Rejetée";
  if (n === "executed") return "✓ Exécutée";
  if (n === "not_executed") return "✕ Non exécutée";
  return s;
};

export const getStatusColor = (s, colors) => {
  const n = (s || "").toLowerCase();
  if (n === "approved" || n === "executed") return colors.greenAccent[500];
  if (n === "pending") return "#f59e0b";
  if (n === "rejected" || n === "not_executed") return colors.redAccent[500];
  return colors.grey[300];
};
