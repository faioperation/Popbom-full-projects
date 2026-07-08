"use client";
import Bredcumb from "@/app/component/Bredcumb";
import Pagination from "@/app/component/Pagination";
import Table from "@/app/component/Table";
import { API_BASE_URL } from "@/app/config/api";
import Cookies from "js-cookie";
import React, { useEffect, useState } from "react";

const TableHeads = [
  { Title: "Name", key: "name", width: "20%" },
  { Title: "Username", key: "username", width: "20%" },
  { Title: "User Mail", key: "usermail", width: "20%" },
  { Title: "Contact Number", key: "number", width: "20%" },
  { Title: "Created Date", key: "created_date", width: "20%" },
];

const Users = () => {
  const [users, setUsers] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [loading, setLoading] = useState(false);

  // 🔹 Fetch users
  useEffect(() => {
    const fetchUsers = async () => {
      try {
        setLoading(true);

        const accesstoken = Cookies.get("accessToken");

        const res = await fetch(`${API_BASE_URL}/api/admin/users`, {
          credentials: "include",
          method: "GET",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${accesstoken}`,
          },
        });

        const result = await res.json();

        if (!res.ok) {
          throw new Error(result.message || "Failed to fetch users");
        }

        const formatNameFromUsername = (username) => {
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

        const sortedUsers = [...result.data].sort(
          (a, b) => new Date(b.createdAt) - new Date(a.createdAt)
        );

        const formattedData = sortedUsers.map((user) => ({
          name: formatNameFromUsername(user.username),
          username: `@${user.username}`,
          usermail: user.email,
          number: user.phone || "N/A",
          created_date: user.createdAt?.split("T")[0],
        }));

        setUsers(formattedData);
      } catch (error) {
        console.error("User fetch error:", error.message);
      } finally {
        setLoading(false);
      }
    };

    fetchUsers();
  }, []);

  // Pagination
  const itemsPerPage = 10;
  const totalPages = Math.ceil(users.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const currentItems = users.slice(startIndex, startIndex + itemsPerPage);

  return (
    <>
      <Bredcumb />

      <div className="bg-white rounded-2xl mt-10">
        {loading ? (
          <div className="py-10 text-center text-gray-500">
            Loading users...
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

export default Users;
