import { useState } from 'react';
import { NavLink, useLocation, useNavigate } from 'react-router-dom';
import { useTheme } from '@mui/material';
import DashboardOutlinedIcon from '@mui/icons-material/DashboardOutlined';
import GroupOutlinedIcon from '@mui/icons-material/GroupOutlined';
import SchoolOutlinedIcon from '@mui/icons-material/SchoolOutlined';
import DescriptionOutlinedIcon from '@mui/icons-material/DescriptionOutlined';
import PaymentsOutlinedIcon from '@mui/icons-material/PaymentsOutlined';
import EventNoteOutlinedIcon from '@mui/icons-material/EventNoteOutlined';
import RestaurantMenuOutlinedIcon from '@mui/icons-material/RestaurantMenuOutlined';
import CelebrationOutlinedIcon from '@mui/icons-material/CelebrationOutlined';
import AssessmentOutlinedIcon from '@mui/icons-material/AssessmentOutlined';
import SettingsOutlinedIcon from '@mui/icons-material/SettingsOutlined';
import appLogo from '../../assets/appImage.png';
import './Sidebar.css';

/**
 * @file global/Sidebar.jsx
 * @description Global Sidebar navigation component.
 *
 * ROLE:
 * Provides the primary navigation menu for the entire admin application.
 * Uses React Router `NavLink` for SPA routing (no full page reloads).
 * Supports collapsible sub-menus controlled via `openMenus` state.
 *
 * KEY STATE:
 * - `openMenus`  – Object of booleans keyed by section name; controls which
 *                   dropdown menus are expanded.
 *
 * KEY HELPERS:
 * - `toggleMenu(id)`                – Flips the open/closed state of a sub-menu.
 * - `isActivitiesTabActive(tabKey)` – Checks if the Activities tab matches the URL.
 * - `navigateToActivitiesTab(key)`  – Navigates to the Activities page with a query tab.
 *
 * PROPS:
 * @param {boolean} isSidebar – When false, adds a 'collapsed' CSS class to hide sidebar.
 *
 * DEPENDENCIES:
 * - React Router (`NavLink`, `useLocation`, `useNavigate`) – SPA navigation.
 * - `Sidebar.css` – Styling for the sidebar layout and animations.
 */
/**
 * Global Sidebar navigation component.
 * Provides the primary navigation menu for the entire application.
 * 
 * @param {Object} props - Component props.
 * @param {boolean} [props.isSidebar=true] - State controlling if the sidebar is expanded or collapsed.
 * @returns {JSX.Element} The rendered Sidebar.
 */
function Sidebar({ isSidebar = true }) {
  const [openMenus, setOpenMenus] = useState({ users: true, classes: true, activities: true, meals: true, reports: true });
  const location = useLocation();
  const navigate = useNavigate();
  const theme = useTheme();

  const isActivitiesRoute = location.pathname === '/management/activities';
  const currentActivitiesTab = (new URLSearchParams(location.search).get('tab')) || 'planned';
  const isReportsRoute = location.pathname === '/management/reports';
  const currentReportsTab = (new URLSearchParams(location.search).get('tab')) || 'behavioral';

  /**
   * Expands or collapses the sub-menu identified by menuId.
   * 
   * @param {string} menuId - The key identifying the section in openMenus state.
   */
  const toggleMenu = (menuId) => {
    setOpenMenus((prev) => ({
      ...prev,
      [menuId]: !prev[menuId],
    }));
  };

  /**
   * Returns true if the Activities route is active AND the current query tab matches.
   * 
   * @param {string} tabKey - The tab identifier to check against.
   * @returns {boolean} True if the tab is active.
   */
  const isActivitiesTabActive = (tabKey) => {
    return isActivitiesRoute && currentActivitiesTab === tabKey;
  };

  /**
   * Navigates to the Activities page with a specific tab query parameter.
   * 
   * @param {string} tabKey - The target tab key.
   * @param {React.MouseEvent} e - The mouse event from the anchor tag.
   */
  const navigateToActivitiesTab = (tabKey, e) => {
    e.preventDefault();
    navigate(`/management/activities?tab=${tabKey}`);
  };

  const isReportsTabActive = (tabKey) => {
    return isReportsRoute && currentReportsTab === tabKey;
  };

  const navigateToReportsTab = (tabKey, e) => {
    e.preventDefault();
    navigate(`/management/reports?tab=${tabKey}`);
  };

  const compactLinks = [
    { to: '/', label: 'Tableau de Bord', icon: <DashboardOutlinedIcon fontSize="small" />, active: location.pathname === '/' },
    { to: '/users/teachers', label: 'Enseignants', icon: <GroupOutlinedIcon fontSize="small" />, active: location.pathname.startsWith('/users') },
    { to: '/classes/preschool', label: 'Classes', icon: <SchoolOutlinedIcon fontSize="small" />, active: location.pathname.startsWith('/classes') },
    { to: '/management/inscriptions', label: 'Inscriptions', icon: <DescriptionOutlinedIcon fontSize="small" />, active: location.pathname === '/management/inscriptions' },
    { to: '/management/payments', label: 'Paiements', icon: <PaymentsOutlinedIcon fontSize="small" />, active: location.pathname === '/management/payments' },
    { to: '/management/activities?tab=planned', label: 'Activités', icon: <EventNoteOutlinedIcon fontSize="small" />, active: location.pathname === '/management/activities' },
    { to: '/management/meals', label: 'Repas', icon: <RestaurantMenuOutlinedIcon fontSize="small" />, active: location.pathname.startsWith('/management/meals') || location.pathname.startsWith('/management/food-') },
    { to: '/management/events', label: 'Événements', icon: <CelebrationOutlinedIcon fontSize="small" />, active: location.pathname === '/management/events' },
    { to: '/management/reports?tab=behavioral', label: 'Rapports', icon: <AssessmentOutlinedIcon fontSize="small" />, active: location.pathname.startsWith('/management/reports') || location.pathname.startsWith('/management/behavioral-history') || location.pathname.startsWith('/management/payment-reports') },
    { to: '/management/parameters', label: 'Paramètres', icon: <SettingsOutlinedIcon fontSize="small" />, active: location.pathname === '/management/parameters' },
  ];

  if (!isSidebar) {
    return (
      <div className={`sidebar compact ${theme.palette.mode}`}>
        <div className="sidebar-brand compact-brand">
          <img src={appLogo} alt="App Logo" style={{ width: '42px', height: '42px', objectFit: 'contain' }} />
        </div>

        <div className="compact-nav">
          {compactLinks.map((item) => (
            <NavLink
              key={item.label}
              to={item.to}
              end={item.to === '/'}
              className={`compact-icon-link ${item.active ? 'active' : ''}`}
              title={item.label}
            >
              {item.icon}
            </NavLink>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className={`sidebar ${theme.palette.mode}`}>
      <div className="sidebar-brand" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginBottom: '10px' }}>
        <img src={appLogo} alt="App Logo" style={{ width: '60px', height: '60px', objectFit: 'contain', marginBottom: '5px' }} />
        <h2 style={{ marginTop: '0', textAlign: 'center' }}>PETIT SUIVI</h2>
      </div>

      <NavLink to="/" className="menu-item dashboard-link" end>
        <span className="menu-icon"><DashboardOutlinedIcon fontSize="small" /></span>
        Tableau de Bord
      </NavLink>

      {/* Users Section */}
      <div className="menu-section">
        <span className="section-label">Utilisateurs</span>

        <div
          className="menu-item dropdown-btn"
          onClick={() => toggleMenu('users')}
        >
          <span className="menu-item-content"><span className="menu-icon"><GroupOutlinedIcon fontSize="small" /></span>Gérer les utilisateurs</span>
          <span className={`arrow ${openMenus.users ? 'open' : ''}`}>▾</span>
        </div>

        <div className={`submenu ${openMenus.users ? 'open' : ''}`}>
          <NavLink to="/users/teachers" className="submenu-item">
            Enseignants
          </NavLink>
          <NavLink to="/users/parents" className="submenu-item">
            Parents
          </NavLink>
        </div>
      </div>

      {/* Classes Section */}
      <div className="menu-section">
        <span className="section-label">Classes</span>

        <div
          className="menu-item dropdown-btn"
          onClick={() => toggleMenu('classes')}
        >
          <span className="menu-item-content"><span className="menu-icon"><SchoolOutlinedIcon fontSize="small" /></span>Gérer les classes</span>
          <span className={`arrow ${openMenus.classes ? 'open' : ''}`}>▾</span>
        </div>

        <div className={`submenu ${openMenus.classes ? 'open' : ''}`}>
          <NavLink to="/classes/preschool" className="submenu-item">
            Préscolaire (التحضيري)
          </NavLink>
          <NavLink to="/classes/kindergarten" className="submenu-item">
            Maternelle (التمهيدي)
          </NavLink>
        </div>
      </div>

      {/* Management Section */}
      <div className="menu-section">
        <span className="section-label">Gestion</span>
        <NavLink to="/management/inscriptions" className="menu-item">
          <span className="menu-icon"><DescriptionOutlinedIcon fontSize="small" /></span>
          Inscriptions
        </NavLink>
        <NavLink to="/management/payments" className="menu-item">
          <span className="menu-icon"><PaymentsOutlinedIcon fontSize="small" /></span>
          Paiements
        </NavLink>
        <NavLink to="/management/events" className="menu-item">
          <span className="menu-icon"><CelebrationOutlinedIcon fontSize="small" /></span>
          Événements
        </NavLink>
        <div
          className={`menu-item dropdown-btn ${isActivitiesRoute ? 'section-active' : ''}`}
          onClick={() => toggleMenu('activities')}
        >
          <span className="menu-item-content"><span className="menu-icon"><EventNoteOutlinedIcon fontSize="small" /></span>Activités</span>
          <span className={`arrow ${openMenus.activities ? 'open' : ''}`}>▾</span>
        </div>
        <div className={`submenu ${openMenus.activities ? 'open' : ''}`}>
          <a href="/management/activities?tab=planned"
            className={`submenu-item ${isActivitiesTabActive('planned') ? 'active' : ''}`}
            onClick={(e) => navigateToActivitiesTab('planned', e)}>
            Activités Planifiées
          </a>

          <a href="/management/activities?tab=criteria"
            className={`submenu-item ${isActivitiesTabActive('criteria') ? 'active' : ''}`}
            onClick={(e) => navigateToActivitiesTab('criteria', e)}>
            Critères d'évaluation
          </a>
          <a href="/management/activities?tab=all"
            className={`submenu-item ${isActivitiesTabActive('all') ? 'active' : ''}`}
            onClick={(e) => navigateToActivitiesTab('all', e)}>
            Toutes les activités
          </a>
        </div>
        <div
          className="menu-item dropdown-btn"
          onClick={() => toggleMenu('meals')}
        >
          <span className="menu-item-content"><span className="menu-icon"><RestaurantMenuOutlinedIcon fontSize="small" /></span>Repas</span>
          <span className={`arrow ${openMenus.meals ? 'open' : ''}`}>▾</span>
        </div>
        <div className={`submenu ${openMenus.meals ? 'open' : ''}`}>
          <NavLink to="/management/meals" className="submenu-item">
            Planning
          </NavLink>
          <NavLink to="/management/food-items" className="submenu-item">
            Gérer les Aliments
          </NavLink>
          <NavLink to="/management/food-exceptions" className="submenu-item">
            Exceptions Alimentaires
          </NavLink>
        </div>
        <div
          className={`menu-item dropdown-btn ${(isReportsRoute || location.pathname.startsWith('/management/payment-reports') || location.pathname.startsWith('/management/behavioral-history')) ? 'section-active' : ''}`}
          onClick={() => toggleMenu('reports')}
        >
          <span className="menu-item-content"><span className="menu-icon"><AssessmentOutlinedIcon fontSize="small" /></span>Rapports</span>
          <span className={`arrow ${openMenus.reports ? 'open' : ''}`}>▾</span>
        </div>
        <div className={`submenu ${openMenus.reports ? 'open' : ''}`}>
          <a
            href="/management/reports?tab=behavioral"
            className={`submenu-item ${isReportsTabActive('behavioral') ? 'active' : ''}`}
            onClick={(e) => navigateToReportsTab('behavioral', e)}
          >
            Signalements Comportementaux
          </a>
          <NavLink to="/management/payment-reports" className="submenu-item">
            Rapports de paiement
          </NavLink>
        </div>
      </div>

      {/* Parameters Section */}
      <div className="menu-section">
        <span className="section-label">Parametres</span>
        <NavLink to="/management/parameters" className="menu-item">
          <span className="menu-icon"><SettingsOutlinedIcon fontSize="small" /></span>
          Parametres
        </NavLink>
      </div>

    </div>
  );
}

export default Sidebar;
