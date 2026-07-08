"use client";
import Password from "@/app/component/Password";
import Cookies from "js-cookie";
import React, { useState } from "react";

const ChangePass = () => {
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const [isSuccess, setIsSuccess] = useState(false);

  /* =========================
     Change password handler
     ========================= */
  const handleChangePassword = async () => {
    setMessage("");
    setIsSuccess(false);

    const id = localStorage.getItem("id");
    if (!id) {
      setMessage("User not found. Please login again.");
      return;
    }

    // 🔒 frontend validation
    if (!currentPassword || !newPassword || !confirmPassword) {
      setMessage("All fields are required");
      return;
    }

    if (newPassword !== confirmPassword) {
      setMessage("New password and confirm password do not match");
      return;
    }

    if (newPassword.length < 6) {
      setMessage("Password must be at least 6 characters");
      return;
    }

    setLoading(true);

    try {
      const res = await fetch(
        `${API_BASE_URL}/api/admin/profile/change-password/${id}`,
        {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${Cookies.get("accessToken")}`,
          },
          credentials: "include",
          body: JSON.stringify({
            currentPassword,
            newPassword,
          }),
        }
      );

      const data = await res.json();
     localStorage.getItem("id", id);

      if (data.success) {
        setMessage("Password updated successfully");
        setIsSuccess(true);

        // clear inputs
        setCurrentPassword("");
        setNewPassword("");
        setConfirmPassword("");
      } else {
        setMessage(data.message || "Old password is incorrect");
      }
    } catch (err) {
      setMessage("Something went wrong!");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="w-[480px] flex flex-col items-center mx-auto gap-8 mt-10">
      <Password
        value={currentPassword}
        onChange={(e) => setCurrentPassword(e.target.value)}
        inputClass="border border-[#21E6A0]"
        label="Old Password"
        labelClass="text-[#000000] text-xl"
        icon="text-[#000000]"
      />

      <Password
        value={newPassword}
        onChange={(e) => setNewPassword(e.target.value)}
        inputClass="border border-[#21E6A0]"
        label="New Password"
        labelClass="text-[#000000] text-xl"
        icon="text-[#000000]"
      />

      <Password
        value={confirmPassword}
        onChange={(e) => setConfirmPassword(e.target.value)}
        inputClass="border border-[#21E6A0]"
        label="Confirm Password"
        labelClass="text-[#000000] text-xl"
        icon="text-[#000000]"
      />

      {message && (
        <p
          className={`text-center ${
            isSuccess ? "text-green-600" : "text-red-600"
          }`}
        >
          {message}
        </p>
      )}

      <button
        disabled={loading}
        onClick={handleChangePassword}
        className="bg-gradient-to-r from-[#21E6A0] to-[#6DF844]
        text-[#000000] w-[50%] font-semibold py-3 rounded-lg
        mt-5 cursor-pointer disabled:opacity-60"
      >
        {loading ? "Updating..." : "Update Password"}
      </button>
    </div>
  );
};

export default ChangePass;
