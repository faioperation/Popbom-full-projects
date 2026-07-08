"use client";

import Dropdown from "@/app/component/Dropdown";
import UserChart from "@/app/component/UserChart";
import { API_BASE_URL } from "@/app/config/api";
import Cookies from "js-cookie";
import React, { useEffect, useState } from "react";

const Dashbaord = () => {
  const [stats, setStats] = useState({
    users: 0,
    posts: 0,
    reports: 0,
  });

  const [loading, setLoading] = useState(true);
  const [selectedYear, setSelectedYear] = useState("2026");

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        const res = await fetch(`${API_BASE_URL}/api/admin/dashboard`, {
          method: "GET",
          credentials: "include",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
            Authorization: `Bearer ${Cookies.get("accessToken")}`,
          },
        });

        const data = await res.json();

        if (res.ok) {
          setStats(data.data);
        } else {
          console.error(data.message || "Dashboard fetch failed");
        }
      } catch (error) {
        console.error("Dashboard API error:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  if (loading) {
    return <p className="text-center font-inter">Loading dashboard...</p>;
  }

  return (
    <div>
      <div className="grid grid-cols-12 gap-7">
        {/* Total Users */}
        <div className="bg-white p-10 col-span-4 rounded-2xl text-center space-y-5 flex flex-col items-center justify-center">
          <p className="font-inter text-black text-xl">Total User</p>
          <p className="font-inter text-black text-2xl font-semibold">
            {stats.users}
          </p>
        </div>

        {/* Total Videos */}
        <div className="bg-white p-10 col-span-4 rounded-2xl text-center space-y-5 flex flex-col items-center justify-center">
          <p className="font-inter text-black text-xl">Total Video</p>
          <p className="font-inter text-black text-2xl font-semibold">
            {stats.posts}
          </p>
        </div>

        {/* Total Tickets */}
        <div className="bg-white p-10 col-span-4 rounded-2xl text-center space-y-5 flex flex-col items-center justify-center">
          <p className="font-inter text-black text-xl">Total Support Ticket</p>
          <p className="font-inter text-black text-2xl font-semibold">
            {stats.reports}
          </p>
        </div>

        {/* Chart */}
        <div className="bg-white p-5 col-span-12 rounded-2xl">
          <div className="mb-12 flex items-center justify-between">
            <p className="font-inter text-black text-[20px]">User Chart</p>
            <Dropdown
               placeholder={selectedYear}
                value={selectedYear} 
              className="w-[7%] border rounded-xl p-2.5 font-inter font-medium"
              options={["2026","2025", "2024", "2023", "2022", "2021", "2020"]}
              onSelect={(value) => setSelectedYear(value)}
            />
          </div>
          <UserChart year={selectedYear} />
        </div>
      </div>
    </div>
  );
};

export default Dashbaord;
