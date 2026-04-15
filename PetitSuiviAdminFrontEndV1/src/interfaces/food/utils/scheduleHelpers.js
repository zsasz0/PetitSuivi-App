export const WEEKDAYS = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];

export const getMonday = (d) => {
    const date = new Date(d);
    const day = date.getDay();
    const diff = date.getDate() - day + (day === 0 ? -6 : 1);
    date.setDate(diff);
    date.setHours(0, 0, 0, 0);
    return date;
};

export const formatDate = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;

export const formatDisplayDate = (d) => {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return `${d.getDate()} ${months[d.getMonth()]} ${d.getFullYear()}`;
};

export const isSnackCategory = (name) => {
    const n = String(name || '').toLowerCase().trim();
    return n === 'snack' || n === 'snacks' || n === 'goûter' || n === 'gouter';
};
