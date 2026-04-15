/**
 * Calculates aggregated dashboard statistics from raw backend data.
 *
 * This function transforms raw API datasets (inscriptions, teachers, parents,
 * classes, payments, and plannings) into structured metrics used by the
 * administrative dashboard.
 *
 * It computes:
 * - Total approved students
 * - Weekly approved inscriptions
 * - Active users (teachers, parents, classes)
 * - Revenue collected and expected
 * - Latest inscriptions (sorted)
 * - Active academic year
 *
 * @param {Object} params
 * @param {Array<Object>} params.inscriptions - List of student inscriptions
 * @param {Array<Object>} params.teachers - List of teachers
 * @param {Array<Object>} params.parents - List of parents
 * @param {Array<Object>} params.classes - List of classes
 * @param {Array<Object>} params.payments - List of payment records
 * @param {Array<Object>} params.plannings - List of academic plannings
 *
 * @returns {Object} Computed dashboard statistics
 * @returns {number} returns.totalChildren - Total approved students
 * @returns {number} returns.approvedChildrenThisWeek - Approved students in last 7 days
 * @returns {number} returns.activeTeachers - Non-archived teachers count
 * @returns {number} returns.activeParents - Non-archived parents count
 * @returns {number} returns.activeClasses - Non-archived classes count
 * @returns {number} returns.revenueCollected - Sum of partial payments collected
 * @returns {number} returns.revenueExpected - Total expected revenue
 * @returns {Array<Object>} returns.recentInscriptions - Last 8 inscriptions sorted by date
 * @returns {string} returns.academicYear - Current active academic year label
 */
export const calculateDashboardStats = ({
  inscriptions,
  teachers,
  parents,
  classes,
  payments,
  plannings,
}) => {
  const totalChildren = inscriptions.filter(i =>
    (i.status?.name || i.status || "pending").toLowerCase() === "approved"
  ).length;

  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

  const approvedChildrenThisWeek = inscriptions.filter(i => {
    const status = (i.status?.name || i.status || "pending").toLowerCase();
    const date = new Date(i.inscription_date || i.date || 0);
    return status === "approved" && date >= sevenDaysAgo;
  }).length;

  const activeTeachers = teachers.filter(t => !t?.is_archived).length;
  const activeParents = parents.filter(p => !p?.is_archived).length;
  const activeClasses = classes.filter(c => !c?.is_archived).length;

  const revenueCollected = payments.reduce((sum, p) => {
    const partials = Array.isArray(p?.partial_payments) ? p.partial_payments : [];
    return sum + partials.reduce((s, tx) => s + Number(tx.value || 0), 0);
  }, 0);

  const revenueExpected = payments.reduce(
    (sum, p) => sum + Number(p?.amount || 0),
    0
  );

  const recentInscriptions = [...inscriptions]
    .sort(
      (a, b) =>
        new Date(b.inscription_date || b.date || 0) -
        new Date(a.inscription_date || a.date || 0)
    )
    .slice(0, 8);

  const activePlanning = plannings.find(p => p.is_active) || plannings[0] || {};

  return {
    totalChildren,
    approvedChildrenThisWeek,
    activeTeachers,
    activeParents,
    activeClasses,
    revenueCollected,
    revenueExpected,
    recentInscriptions,
    academicYear:
      activePlanning.label ||
      activePlanning.academic_year ||
      new Date().getFullYear().toString(),
  };
};