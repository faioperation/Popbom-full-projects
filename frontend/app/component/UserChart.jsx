"use client";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { useEffect, useState } from "react";
import Cookies from "js-cookie";

const months = [
  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
];

//  helper: month-wise user count (year based)
const generateMonthlyUserData = (users, year) => {
  const monthCount = months.reduce((acc, m) => {
    acc[m] = 0;
    return acc;
  }, {});

  users.forEach((user) => {
    if (!user.createdAt) return;

    const date = new Date(user.createdAt);

    //  year filter
    if (String(date.getFullYear()) !== String(year)) return;

    const monthName = months[date.getMonth()];
    monthCount[monthName]++;
  });

  return months.map((month) => ({
    month,
    value: monthCount[month],
  }));
};

export default function UserChart({ year }) {
  const [users, setUsers] = useState([]);
  const [chartData, setChartData] = useState([]);
  const [loading, setLoading] = useState(true);

  // 🔹 fetch users once
  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const token = Cookies.get("accessToken");

        const res = await fetch(
          "http://172.252.13.97:5000/api/admin/users",
          {
            method: "GET",
            credentials: "include",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${token}`,
            },
          }
        );

        const result = await res.json();
        if (!res.ok) throw new Error(result.message);

        setUsers(result.data);
      } catch (err) {
        console.error("Chart data error:", err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchUsers();
  }, []);

  
  useEffect(() => {
    if (users.length && year) {
      const monthlyData = generateMonthlyUserData(users, year);
      setChartData(monthlyData);
    }
  }, [users, year]);

  if (loading) {
    return (
      <div className="h-[420px] flex items-center justify-center text-gray-400">
        Loading chart...
      </div>
    );
  }

  return (
    <div className="w-full h-[420px] font-inter">
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={chartData}>
          <CartesianGrid stroke="#E5E7EB" strokeDasharray="3 3" />

          <XAxis
            dataKey="month"
            tick={{ fill: "#9CA3AF", fontSize: 12 }}
            axisLine={false}
            tickLine={false}
          />

          <YAxis
            width={30}
            tick={{ fill: "#9CA3AF", fontSize: 12 }}
            axisLine={false}
            tickLine={false}
            allowDecimals={false}
          />

          <Tooltip
            contentStyle={{
              borderRadius: "8px",
              border: "1px solid #E5E7EB",
            }}
          />

          <Line
            type="monotone"
            dataKey="value"
            stroke="#4F6BFF"
            strokeWidth={2.5}
            dot={{ r: 4, fill: "#4F6BFF" }}
            activeDot={{ r: 6 }}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
