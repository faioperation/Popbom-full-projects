"use client";
import React, { useState } from "react";


import Link from "next/link";
import InputField from "@/app/component/InputField";
import axios from "axios";
import { useRouter } from "next/navigation";
import { API_BASE_URL } from "@/app/config/api";


const ForgotPass = () => {
   const router = useRouter();

  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccess("");

    if (!email) {
      setError("Please enter your email address");
      return;
    }

    try {
      setLoading(true);

      // ✅ OTP send request to backend
      const res = await axios.post(`${API_BASE_URL}/api/auth/admin/forgot-password`, {
        email: email,
      });
      console.log("OTP API RESPONSE:", res.data);

      if (res.status === 200 && res.data.success) {
        setSuccess("OTP sent successfully!");
        sessionStorage.setItem("resetEmail", email);
        router.push("/otp");
      } else {
        setError(res.data.message || "Failed to send OTP");
      }
    } catch (err) {
      console.error("OTP Send Error:", err);
      setError(err.response?.data?.message || "Failed to send OTP");
    } finally {
      setLoading(false);
    }
  };
 



  return (
    <div className="grid justify-center items-center h-screen bg-[#EAEAEA]">
    <main className="bg-white   grid justify-center items-center overflow-y-auto hide-scrollbar py-20 px-11 rounded-3xl  ">
      <form
       onSubmit={handleSubmit}
        className="gap-5 flex flex-col items-center w-[480px] "
      >
        <h3 className="font-inter font-medium text-[32px] text-[#333333] ">
          Forget Password?
        </h3>

        <p className="font-inter  text-[#333333]  mb-5">
          Please enter your email to get verification code
        </p>

        <InputField
          label="Email Address"
          labelClass={`text-[#333333]  text-[16px]`}
          inputClass={`border-[#21E6A0] border bg-transparent rounded  text-[#5C5C5C] py-3 placeholder:text-[#5C5C5C]`}
          name="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          
          
        />

          {error && <p className="text-red-500 text-sm mt-2">{error}</p>}
        {success && <p className="text-green-600 text-sm mt-2">{success}</p>}
  

          <button 
          type="submit"
          disabled={loading}
          className="bg-gradient-to-r from-[#21E6A0] to-[#6DF844] text-white font-semibold text-xl w-full font-inter py-3 rounded-lg cursor-pointer mt-5">
          {loading ? "Sending OTP..." : "Continue"}
          </button>

        
       
      </form>
    </main>
      </div>
  );
};

export default ForgotPass;
