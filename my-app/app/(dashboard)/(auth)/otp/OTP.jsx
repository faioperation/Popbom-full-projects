"use client";

import { API_BASE_URL } from "@/app/config/api";
import axios from "axios";
import Link from "next/link";
import { useRouter } from "next/navigation";
import React, { useEffect, useRef, useState } from "react";

const OTP = () => {
  const [loading, setLoading] = useState(false);
  const inputs = useRef([]);
  const router = useRouter();

  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState(["", "", "", "", "", ""]);
  const [success, setSuccess] = useState("");
  const [error, setError] = useState("");

  const handleChange = (e, index) => {
    const value = e.target.value.replace(/[^0-9]/g, "");

    const newOtp = [...otp];
    newOtp[index] = value;
    setOtp(newOtp);

    if (value && index < 5) {
      inputs.current[index + 1]?.focus();
    }
  };

  const handleKeyDown = (e, index) => {
    if (e.key === "Backspace" && !otp[index] && index > 0) {
      inputs.current[index - 1].focus();
    }
  };

  useEffect(() => {
    const storedEmail = sessionStorage.getItem("resetEmail");
    if (!storedEmail) {
      router.push("/forgotpassword");
    } else {
      setEmail(storedEmail);
    }
  }, [router]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccess("");

    const finalOtp = otp.join("");

    if (finalOtp.length !== 6) {
      setError("Please enter all 6 digits");
      return;
    }

    try {
      setLoading(true);

      const res = await axios.post(
        `${API_BASE_URL}/api/auth/admin/verify-otp`,
        {
          email: email,
          otp: finalOtp,
        },
        {
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
        }
      );

      if (res.status === 200 && res.data.success) {
        setSuccess("OTP Verified Successfully!");
        setTimeout(() => {
          router.push("/newpassword");
        }, 800);
      } else {
        setError(res.data.message || "Invalid OTP");
      }
    } catch (err) {
      const msg =
        err?.response?.data?.message ||
        err?.message ||
        "OTP verification failed";
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-[#EAEAEA] grid justify-center items-center h-screen">
      <main className="bg-white   overflow-y-auto hide-scrollbar py-20 px-15 rounded-3xl">
        <form
          onSubmit={handleSubmit}
          className="flex flex-col items-center text-center w-[480px]"
        >
          <h1 className="text-[32px] text-[#333333]  font-inter font-medium">
            Check your email
          </h1>
          <p className="font-inter text-[16px] text-[#333333] mt-6">
            We sent a code to your email address. Please check your email for
            the 6 digit code.
          </p>

          <div className="flex gap-4 justify-center my-[82px]">
            {[...Array(6)].map((_, i) => (
              <input
                key={i}
                type="text"
                inputMode="numeric"
                maxLength={1}
                ref={(el) => (inputs.current[i] = el)}
                onChange={(e) => handleChange(e, i)}
                onKeyDown={(e) => handleKeyDown(e, i)}
                value={otp[i]}
                className="appearance-none w-[47px] h-[49px] border border-[#21E6A0] rounded-[10px] text-center outline-none text-xl font-inter font-bold text-[#900616] "
              />
            ))}
          </div>

          {error && <p className="text-red-500 mt-2">{error}</p>}
          {success && <p className="text-green-500 mt-2">{success}</p>}

          <button
            type="submit"
            disabled={loading}
            className="w-full font-inter font-semibold text-[16px] bg-gradient-to-r from-[#21E6A0] to-[#6DF844] text-white rounded py-3 hover:opacity-90 disabled:opacity-50 cursor-pointer"
          >
            {loading ? "Verifying..." : "Verify"}
          </button>

          <p className="font-inter text-[16px] text-[#333333]  mt-[92px]">
            You have not received the email?
            <a
              href="/forgotpassword"
              className="text-[#21E6A0] cursor-pointer underline m-2"
            >
              Resend
            </a>
          </p>
        </form>
      </main>
    </div>
  );
};

export default OTP;
