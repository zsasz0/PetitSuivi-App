/**
 * @file App.js
 * @description Main application entry point and routing configuration.
 * 
 * ROLE:
 * This file serves as the foundational skeleton of the React application. 
 * It is responsible for:
 * 1. Initializing global context providers (Theme, Auth).
 * 2. Setting up the client-side router (`react-router-dom`).
 * 3. Defining the layout structure (Sidebar, Topbar, Main Content).
 * 4. Mapping URL paths to their corresponding page components (Scenes/Interfaces).
 * 5. Enforcing route protection so only authenticated users can access the dashboard.
 */

import { useEffect, useState } from "react";
import { Routes, Route, Navigate } from "react-router-dom";

// Layout Components
import Topbar from "./interfaces/global/Topbar";
import Sidebar from "./interfaces/global/Sidebar";
import Dashboard from "./interfaces/dashboard";

// Theme & Styling
import { Box, CssBaseline, ThemeProvider, useTheme } from "@mui/material";
import { ColorModeContext, useMode } from "./theme";

// Application Interfaces (Pages)
import { Parent as Parents, Teacher as Teachers } from "./interfaces/ParentAndTeacher";
import { PreschoolClasses as Preschool } from "./interfaces/classes";
import { KindergartenClasses as Kindergarten } from "./interfaces/classes";
import Inscriptions from "./interfaces/inscriptions";
import Payments from "./interfaces/payments";
import Activities from "./interfaces/activities";
import FoodItems from "./interfaces/food/ManageMeals";
import FoodExceptions from "./interfaces/food/manageFoodExceptions";
import ReportsTabsPage from "./interfaces/reports";
import PaymentReports from "./interfaces/reports/paymentReports";
import Parameters from "./interfaces/parameters";
import Events from "./interfaces/events";
import MealsPlanning from "./interfaces/food/schedule";

// Authentication
import Login from "./interfaces/login";
import { AuthProvider, useAuth } from "./context/AuthContext";
import appIcon from "./assets/appImage.png";

/**
 * Component to protect routes that require authentication.
 * If no valid token exists in the AuthContext, the user is automatically
 * redirected to the /login page.
 * 
 * @param {Object} props - Component props.
 * @param {React.ReactNode} props.children - Protected content.
 * @returns {JSX.Element} The children if authenticated, or a redirect to login.
 */
const ProtectedRoute = ({ children }) => {
  const { token } = useAuth();
  if (!token) {
    return <Navigate to="/login" replace />;
  }
  return children;
};

/**
 * Component that renders the core application layout.
 * Enforces sidebar/topbar presence and defines nested routes.
 * 
 * @param {Object} props - Component props.
 * @param {boolean} props.isSidebar - State indicating if the sidebar is expanded.
 * @param {Function} props.setIsSidebar - Function to toggle sidebar state.
 * @returns {JSX.Element} The application layout structure.
 */
const AppLayout = ({ isSidebar, setIsSidebar }) => {
  const theme = useTheme();
  const isDark = theme.palette.mode === "dark";

  return (
    <Box
      className="app"
      sx={{
        background: isDark
          ? `radial-gradient(circle at 16% 22%, rgba(255, 244, 214, 0.10), transparent 26%), radial-gradient(circle at 72% 18%, rgba(124, 211, 255, 0.06), transparent 30%), radial-gradient(circle at 52% 78%, rgba(120, 255, 186, 0.04), transparent 34%), linear-gradient(135deg, #12181d 0%, #0f151a 52%, #0b1115 100%)`
          : "radial-gradient(circle at 18% 24%, rgba(255, 248, 230, 0.88), transparent 28%), radial-gradient(circle at 76% 18%, rgba(220, 245, 233, 0.58), transparent 34%), radial-gradient(circle at 54% 80%, rgba(232, 247, 238, 0.48), transparent 38%), linear-gradient(135deg, #f6f8f6 0%, #eef2ee 48%, #e8eeea 100%)",
      }}
    >
      <Sidebar isSidebar={isSidebar} />
      <Box
        component="main"
        className="content"
        sx={{
          position: "relative",
          backgroundColor: isDark ? "rgba(11, 17, 21, 0.36)" : "rgba(255, 255, 255, 0.34)",
          backdropFilter: "blur(28px) saturate(108%)",
          WebkitBackdropFilter: "blur(28px) saturate(108%)",
          borderLeft: isDark ? "1px solid rgba(255,255,255,0.04)" : "1px solid rgba(255,255,255,0.42)",
          boxShadow: isDark ? "inset 0 1px 0 rgba(255,255,255,0.03)" : "inset 0 1px 0 rgba(255,255,255,0.72)",
        }}
      >
        <Topbar setIsSidebar={setIsSidebar} />
        <Routes>
          {/* Main Dashboard */}
          <Route path="/" element={<Dashboard />} />

          {/* User Management */}
          <Route path="/users/teachers" element={<Teachers />} />
          <Route path="/users/parents" element={<Parents />} />

          {/* Classes */}
          <Route path="/classes/preschool" element={<Preschool />} />
          <Route path="/classes/kindergarten" element={<Kindergarten />} />

          {/* Internal Management */}
          <Route path="/management/inscriptions" element={<Inscriptions />} />
          <Route path="/management/payments" element={<Payments />} />
          <Route path="/management/activities" element={<Activities />} />
          <Route path="/management/food-items" element={<FoodItems />} />
          <Route path="/management/food-exceptions" element={<FoodExceptions />} />
          <Route path="/management/reports" element={<ReportsTabsPage />} />
          <Route path="/management/behavioral-history" element={<Navigate to="/management/reports?tab=history" replace />} />
          <Route path="/management/payment-reports" element={<PaymentReports />} />
          <Route path="/management/parameters" element={<Parameters />} />
          <Route path="/management/meals" element={<MealsPlanning />} />
          <Route path="/management/events" element={<Events />} />
        </Routes>
      </Box>
    </Box>
  );
};

/**
 * Root Application Component.
 * Wraps the entire application hierarchy in the necessary global providers.
 */
function App() {
  // Initialize dynamic theme state (e.g., light vs dark mode)
  const [theme, colorMode] = useMode();

  // State to track whether the sidebar is currently collapsed or expanded
  const [isSidebar, setIsSidebar] = useState(true);

  useEffect(() => {
    document.title = "Administration Scolaire";

    let iconLink = document.querySelector("link[rel='icon']");
    if (!iconLink) {
      iconLink = document.createElement("link");
      iconLink.rel = "icon";
      document.head.appendChild(iconLink);
    }

    iconLink.type = "image/png";
    iconLink.href = appIcon;
  }, []);

  return (
    // Provides functionality to toggle between light/dark mode deep in the component tree
    <ColorModeContext.Provider value={colorMode}>
      {/* Applies the Material UI theme definitions globally */}
      <ThemeProvider theme={theme}>
        {/* Normalizes browser styles and applies baseline background/text colors */}
        <CssBaseline />

        {/* Supplies user authentication state and login/logout methods */}
        <AuthProvider>

          {/* Top-Level Router mapping */}
          <Routes>
            {/* Public Route: Login Page */}
            <Route path="/login" element={<Login />} />

            {/* 
              Private Routes Group (Catch-all '/*'): 
              Everything besides /login must be authenticated via ProtectedRoute. 
              If the user is valid, they will see the AppLayout.
            */}
            <Route
              path="/*"
              element={
                <ProtectedRoute>
                  <AppLayout isSidebar={isSidebar} setIsSidebar={setIsSidebar} />
                </ProtectedRoute>
              }
            />
          </Routes>

        </AuthProvider>
      </ThemeProvider>
    </ColorModeContext.Provider>
  );
}

export default App;
