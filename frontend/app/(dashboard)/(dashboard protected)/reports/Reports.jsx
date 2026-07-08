"use client";
import Bredcumb from "@/app/component/Bredcumb";
import Dropdown from "@/app/component/Dropdown";
import Pagination from "@/app/component/Pagination";
import Table from "@/app/component/Table";
import { API_BASE_URL } from "@/app/config/api";
import Cookies from "js-cookie";
import React, { useEffect, useState } from "react";

/* ================== HELPERS ================== */
const getUsernameFromEmail = (email = "") => email.split("@")[0];

const formatNameFromUsername = (username = "") => {
  return username
    .replace(/\d+/g, "")
    .split(/[_\.]+/)
    .filter(Boolean)
    .map(
      (word) =>
        word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
    )
    .join(" ");
};

/* ================= STATUS DROPDOWN ================= */
const StatusDropDown = ({ reportId, currentStatus }) => {
  const [status, setStatus] = useState(currentStatus);

  const handleChange = async (value) => {
    setStatus(value);

    try {
      const token = Cookies.get("accessToken");

      await fetch(
        `http://172.252.13.97:5000/api/admin/reports/${reportId}/status`,
        {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({ status: value.toLowerCase() }),
        }
      );
    } catch (error) {
      console.error("Status update failed");
    }
  };

  return (
    <Dropdown
      value={status}
      className="w-[60%] rounded-xl p-2 font-inter font-medium"
      options={["Solved", "Pending", "Issued"]}
      onSelect={handleChange}   // ✅ FIX
    />
  );
};

/* ================= TABLE HEADERS ================= */
const TableHeads = [
  { Title: "Username", key: "username", width: "10%" },
  { Title: "User Mail", key: "usermail", width: "10%" },
  { Title: "Contact Number", key: "number", width: "10%" },
  { Title: "Short Title", key: "short_title", width: "10%" },
  { Title: "Description", key: "description", width: "10%" },
  { Title: "Status", key: "status", width: "10%" },
  { Title: "Date", key: "date", width: "10%" },
];

const Reports = () => {
  const [loading, setLoading] = useState(false);
  const [reports, setReports] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [range, setRange] = useState("today");

  const [stats, setStats] = useState({
    newTicket: 0,
    onProgress: 0,
    completed: 0,
  });

  /* ================= FETCH REPORTS ================= */
  const fetchReports = async (rangeValue) => {
    try {
      setLoading(true);

      const token = Cookies.get("accessToken");

      const res = await fetch(
        `${API_BASE_URL}/api/admin/reports?range=${rangeValue}`,
        {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
        }
      );

      const result = await res.json();
      if (!res.ok) throw new Error(result.message);

      const reportsArray = Array.isArray(result.data?.reports)
        ? result.data.reports
        : [];

      /* ---------- STATS ---------- */
      setStats({
        newTicket: result.data?.todaysReportsCount || 0,
        onProgress: result.data?.onProgressReportsCount || 0,
        completed: result.data?.completedReportsCount || 0,
      });

      /* ---------- TABLE DATA ---------- */
      const formattedData = reportsArray.map((item) => {
        const email = item.userId?.email || "";
        const rawUsername = getUsernameFromEmail(email);

        return {
          username: formatNameFromUsername(rawUsername) || "User",
          usermail: email || "N/A",
          number: "N/A",
          short_title: item.shortTitle || "...",
          description: item.description || "...",
          status: (
            <StatusDropDown
              reportId={item._id}
              currentStatus={
                item.status === "solved"
                  ? "Solved"
                  : item.status === "issued"
                  ? "Issued"
                  : "Pending"
              }
            />
          ),
          date: item.createdAt?.split("T")[0],
        };
      });

      setReports(formattedData);
    } catch (error) {
      console.error("Report fetch error:", error.message);
    } finally {
      setLoading(false);
    }
  };

  /* ---------- INITIAL + RANGE CHANGE ---------- */
  useEffect(() => {
    fetchReports(range);
  }, [range]);

  /* ---------- PAGINATION ---------- */
  const itemsPerPage = 10;
  const totalPages = Math.ceil(reports.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const currentItems = reports.slice(
    startIndex,
    startIndex + itemsPerPage
  );

  return (
    <>
      <Bredcumb />

      {/* ---------- STATS ---------- */}
      <div className="grid grid-cols-12 gap-7 mt-10">
        {[
          { title: "New Ticket", value: stats.newTicket },
          { title: "On Progress", value: stats.onProgress },
          { title: "Completed", value: stats.completed },
        ].map((card, i) => (
          <div
            key={i}
            className="bg-white px-10 py-10 col-span-4 rounded-2xl text-center"
          >
            {/* <div className="flex justify-end">
              <Dropdown
                placeholder="Today"
                className="w-[30%] border rounded-xl p-1 font-inter font-medium"
                options={[
                  "Today",
                  "This Week",
                  "This Month",
                  "This Year",
                  "All Time",
                ]}
                onSelect={(val) =>
                  setRange(
                    val === "Today"
                      ? "today"
                      : val === "This Week"
                      ? "week"
                      : val === "This Month"
                      ? "month"
                      : val === "This Year"
                      ? "year"
                      : "all"
                  )
                }
              />
            </div> */}
            <p className="font-inter text-black text-xl">{card.title}</p>
            <p className="font-inter text-black mt-5">{card.value}</p>
          </div>
        ))}
      </div>

      {/* ---------- TABLE ---------- */}
      <div className="bg-white rounded-2xl mt-7">
        {loading ? (
          <div className="py-10 text-center text-gray-500">
            Loading reports...
          </div>
        ) : (
          <Table TableHeads={TableHeads} TableRows={currentItems} />
        )}

        <div className="py-5">
          <Pagination
            totalPages={totalPages}
            currentPage={currentPage}
            setCurrentPage={setCurrentPage}
          />
        </div>
      </div>
    </>
  );
};

export default Reports;
