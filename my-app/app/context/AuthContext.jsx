"use client";

import Cookies from "js-cookie";
import { createContext, useContext, useEffect, useState } from "react";

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [token, setToken] = useState(null);

  useEffect(() => {
    const t = Cookies.get("accessToken");
    if (t) setToken(t);
  }, []);

  const login = (tokenValue) => {
    setToken(tokenValue);
    Cookies.set("accessToken", tokenValue);
  };

  const logout = () => {
    setToken(null);
    Cookies.remove("accessToken");
  };

  return (
    <AuthContext.Provider value={{ token, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
