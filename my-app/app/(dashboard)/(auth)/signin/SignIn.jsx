"use client";
import { useState } from "react";
import React from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";

import InputField from "@/app/component/InputField";
import Password from "@/app/component/Password";
import Cookies from "js-cookie";
import axios from "axios";
import { API_BASE_URL } from "@/app/config/api";

const SignIn = () => {
  const router = useRouter();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const [isSuccess, setIsSuccess] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();

    setLoading(true);
    setMessage("");
    setIsSuccess(false);

    try {
      const res = await fetch(
        `${API_BASE_URL}/api/auth/admin/login`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ email, password }),
        }
      );

      const data = await res.json();
      console.log("Login response data:", data);

      if (data.success) {
        const token = data?.data?.accessToken;
        const refreshToken = data?.data?.refreshToken;
        const id = data.data.user.adminId;
        const email = data.data.user.email;
        const name = data.data.user.name;
        Cookies.set("accessToken", token, { expires: 1 });
        Cookies.set("refreshToken", refreshToken, { expires: 7 });
        localStorage.setItem("id", id);
        localStorage.setItem("email", email);
        localStorage.setItem("name", name);

      
        setMessage("Login successful!");
        setIsSuccess(true);

        setTimeout(() => {
          router.push("/dashboard");
        }, 800);
      } else {
        setMessage(data.message || "Login failed");
        setIsSuccess(false);
      }
    } catch (error) {
      setMessage("Something went wrong!");
      setIsSuccess(false);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-[#EAEAEA] h-screen grid justify-center items-center">
      <main className="bg-white py-15 px-11 rounded-3xl">
        <form
          onSubmit={handleLogin}
          className="gap-5 flex flex-col items-center w-[480px]"
        >
          <h3 className="font-inter font-medium text-[32px] text-[#333333] mb-6">
            Sign in to Account
          </h3>

          <p className="font-inter text-[#333333]">
            Please enter your email and password to continue
          </p>

          <InputField
            label="Email Address"
            labelClass="text-[#333333] text-[16px]"
            inputClass="border border-[#21E6A0] text-[#5C5C5C] py-3 rounded bg-white"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />

          <Password
            label="Password"
            inputClass="border border-[#21E6A0]"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />

          <div className="flex justify-between items-center w-full">
            <div className="flex items-center gap-2">
              <input type="checkbox" className="w-4 h-4 accent-[#21E6A0]" />
              <p className="text-[#333333] font-inter">Remember Password</p>
            </div>

            <Link href="/forgotpassword">
              <p className="text-[#21E6A0] font-inter">Forgot Password?</p>
            </Link>
          </div>

          {message && (
            <p
              className={`text-center mt-2 ${
                isSuccess ? "text-green-600" : "text-red-600"
              }`}
            >
              {message}
            </p>
          )}

          <button
            disabled={loading}
            className="bg-gradient-to-r from-[#21E6A0] to-[#6DF844] text-white font-semibold text-xl w-full py-3 rounded-lg mt-12 disabled:opacity-60"
          >
            {loading ? "Signing In..." : "Sign In"}
          </button>
        </form>
      </main>
    </div>
  );
};

export default SignIn;
