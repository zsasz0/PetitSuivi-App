/**
 * @file index.js
 * @description Application entry point. Renders the core App component within the browser router.
 */

import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import App from "./App";
import { BrowserRouter } from "react-router-dom";

/**
 * Root element for the React application.
 */
const root = ReactDOM.createRoot(document.getElementById("root"));

/**
 * Renders the application with React.StrictMode and BrowserRouter.
 */
root.render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>
);
