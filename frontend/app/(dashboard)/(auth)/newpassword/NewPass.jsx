"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
import Password from "@/app/component/Password";
import { useRouter } from "next/navigation";
import axios from "axios";
import { API_BASE_URL } from "@/app/config/api";


const NewPass = () => {
    const router = useRouter();

  const [email, setEmail] = useState("");
  const [formData, setFormData] = useState({
    password: "",
    confirmPassword: "",
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  // Get email from sessionStorage
  useEffect(() => {
    const storedEmail = sessionStorage.getItem("resetEmail");
    if (!storedEmail) {
      router.push("/forgotpassword");
      return;
    }
    setEmail(storedEmail);
  }, [router]);

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

 const handleSubmit = async (e) => {
  e.preventDefault();
  setError("");
  setSuccess("");

  if (!formData.password || !formData.confirmPassword) {
    setError("Please fill all fields");
    return;
  }

  if (formData.password !== formData.confirmPassword) {
    setError("Passwords do not match");
    return;
  }

  try {
    setLoading(true);

    const response = await axios.post(
      `${API_BASE_URL}/api/auth/admin/reset-password`,
      {
        email: email,
        newPassword: formData.password, // ✅ ONLY ONE FIELD
      },
      {
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
      }
    );

    if (response.status === 200 && response.data.success) {
      setTimeout(() => {
        router.push("/success");
      }, 500);
    }
  } catch (err) {
    console.error("Reset Error:", err);
    setError(
      err.response?.data?.message ||
        "Failed to reset password. Try again."
    );
  } finally {
    setLoading(false);
  }
};

  return (
    <div className=" grid justify-center items-center h-screen bg-[#EAEAEA]">
      <main className="bg-white    overflow-y-auto hide-scrollbar py-20 px-18 rounded-3xl  ">
        <form 
        onSubmit={handleSubmit}
        className=" flex flex-col items-center text-cente gap-7 w-[480px]">
          <h3 className="font-inter font-medium text-[32px] text-[#333333]  ">
            Set a new password
          </h3>

          <p className="font-inter  text-[#333333]  mb-5 text-center">
            Create a new password. Ensure it differs from previous ones for
            security
          </p>

          <Password
           inputClass="border border-[#21E6A0]"
            label="Password"
            // placeholder="Enter your password"
            name={`password`}
            value={formData.password}
            onChange={handleChange}
          />

          <Password
           inputClass="border border-[#21E6A0]"
            label="Confirm Password"
            // placeholder="Enter your password again"
            name={`confirmPassword`}
            value={formData.confirmPassword}
            onChange={handleChange}
          />

          {error && <p className="text-red-500">{error}</p>}
          {success && <p className="text-green-500">{success}</p>}

          
            <button
            disabled={loading}
              type="submit"
              className="bg-gradient-to-r from-[#21E6A0] to-[#6DF844] text-white w-full font-semibold font-inter  py-3 rounded-lg mt-5 cursor-pointer"
            >
              {loading ? "Updating..." : "Update Password"}
            </button>
          
        </form>
      </main>
    </div>
  );
};

export default NewPass;
