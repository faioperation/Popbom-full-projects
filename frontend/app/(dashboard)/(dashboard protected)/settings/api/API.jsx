"use client";
import Table from "@/app/component/Table";
import React, { useState } from "react";

import { FiEye, FiEyeOff, FiRefreshCcw } from "react-icons/fi";

const ApiTokenField = ({ token }) => {
  const [show, setShow] = useState(false);

  return (
    <div className="flex items-center gap-2">
      <input
        type={show ? "text" : "password"}
       
        
        className="bg-gray-100 px-3 py-1 rounded-lg outline-none w-[140px]"
      />

      <button
        onClick={() => setShow(!show)}
        className="text-gray-600 hover:text-black"
      >
        {show ? <FiEyeOff /> : <FiEye />}
      </button>
    </div>
  );
};

// TABLE COLUMNS
const TableHeads = [
  { Title: "Service", key: "service", width: "20%" },
  { Title: "Status", key: "status", width: "10%" },
  { Title: "Token Expiry", key: "token", width: "10%" },
  { Title: "Last Handshake", key: "handshake", width: "10%" },
  { Title: "Calls/min", key: "calls", width: "10%" },
  { Title: "API Token", key: "api_token", width: "15%" },
  { Title: "Actions", key: "action", width: "15%" },
];

// REAL DATA (you can fetch from API later)
const rawData = [
  {
    service: "Pinecone ",
    status: "connected",
    expiry: 45,
    handshake: "2 min ago",
    calls: 127,
    token: "Token123",
  },
  {
    service: "Pinecone Index Name",
    status: "connected",
    expiry: 12,
    handshake: "5 min ago",
    calls: 89,
    token: "Token123",
  },
  {
    service: "Pinecone Namespace",
    status: "error",
    expiry: "expired",
    handshake: "3 days ago",
    calls: 0,
    token: "Token123",
  },
  {
    service: "OpenAI API Key",
    status: "connected",
    expiry: 89,
    handshake: "1 min ago",
    calls: 234,
    token: "Token123",
  },
  {
    service: "Clodinary API Key",
    status: "connected",
    expiry: 3,
    handshake: "8 min ago",
    calls: 45,
    token: "Token123",
  },
  {
    service: "Clodinary Cloud",
    status: "error",
    expiry: "expired",
    handshake: "3 days ago",
    calls: 0,
    token: "Token123",
  },
  {
    service: "Clodinary Secret",
    status: "connected",
    expiry: 89,
    handshake: "1 min ago",
    calls: 234,
    token: "Token123",
  },
  
];

// CONVERT RAW DATA INTO TABLE ROWS WITH JSX
const TableRows = rawData.map((item) => {
  // STATUS DOT COLOR
  const statusColor =
    item.status === "connected"
      ? "bg-green-500"
      : item.status === "warning"
      ? "bg-orange-500"
      : "bg-red-500";

  // STATUS TEXT
  const statusText =
    item.status === "connected" ? (
      <span className="bg-[#2dc941] text-white  p-1 rounded-md font-medium ">Connected</span>
    ) : (
      <span className="bg-[#D4183D] text-white px-6 py-1 rounded-md  font-medium">Error</span>
    );

  // EXPIRY COLOR
  const expiryColor =
    item.expiry === "expired"
      ? "text-red-500"
      : item.expiry < 10
      ? "text-orange-500"
      : "text-gray-700";

  const expiryLabel =
    item.expiry === "expired" ? "Expired" : `${item.expiry} days`;

  return {
    service: item.service,

    // STATUS CELL (DOT + TEXT)
    status: (
      <div className="flex items-center gap-2">
        <span className={`w-2 h-2 rounded-full ${statusColor}`}></span>
        {statusText}
      </div>
    ),

    // TOKEN EXPIRY
    token: <span className={`font-medium ${expiryColor}`}>{expiryLabel}</span>,

    handshake: item.handshake,
    calls: item.calls,

    // API TOKEN MASKED INPUT
    api_token: (
        
      <div>
        <ApiTokenField token={item.token} />
      <div>
        
      </div>
      
      </div>
    ),

    // ACTION BUTTONS
    action: (
      <div className="flex gap-2 ">
        {item.expiry === "expired" && (
          <button className="px-3 py-1 bg-gray-100 rounded-lg flex items-center gap-1">
            <FiRefreshCcw size={14} /> Resync
          </button>
        )}
        <button className="px-3 py-1 bg-gray-100 rounded-lg">Revoke</button>
      </div>
    ),
  };
});

const API = () => {
  return (
    <div className="bg-white rounded-2xl mt-7 border border-black/10">
      <Table TableHeads={TableHeads} TableRows={TableRows} />
    </div>
  );
};

export default API;
