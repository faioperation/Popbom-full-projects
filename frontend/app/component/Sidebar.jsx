"use client";
import Link from "next/link";
import React, { useState } from "react";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { FiMenu, FiX } from "react-icons/fi";
import { LuLayoutDashboard } from "react-icons/lu";
import { IoSettingsOutline } from "react-icons/io5";
import logo from "@/public/LOGO.png";
import logout from "@/public/logout.png";
import { PiUserListFill } from "react-icons/pi";
import { BiSolidError } from "react-icons/bi";
import Cookies from "js-cookie";

const navitems = [
  {
    name: "Dashboard",
    link: "/dashboard",
    icon: LuLayoutDashboard,
  },
  {
    name: "User List",
    link: "/userlist",
    icon: PiUserListFill,
  },
  {
    name: "Reports",
    link: "/reports",
    icon: BiSolidError,
  },

  {
    name: "Settings",
    link: "/settings",
    icon: IoSettingsOutline,
  },
 
 
];

const Sidebar = () => {
  const pathname = usePathname();
  const [isOpen, setIsOpen] = useState(false);

  const handleLogout = () => {
  
  Cookies.remove("accessToken");
  Cookies.remove("refreshToken");


  localStorage.clear();
  sessionStorage.clear();

  window.location.href = "/signin";
};


  return (
    <>
      {/* 🔹 Toggle Button (visible on small screens) */}
      <button
        className="2xl:hidden fixed top-5 left-5 z-50 p-2 bg-gradient-to-r from-[#21E6A0] to-[#6DF844] text-white rounded-lg cursor-pointer"
        onClick={() => setIsOpen(!isOpen)}
      >
        {isOpen ? <FiX size={24} /> : <FiMenu size={24} />}
      </button>

      {/* 🔹 Sidebar */}
      <div
        className={`fixed 2xl:static top-0 left-0 z-40 h-screen w-[241px] shrink-0 flex flex-col justify-between pl-2.5 pr-5 py-7 bg-[#FFFFFF] 
        transition-transform  duration-300 ease-in-out overflow-scroll hide-scrollbar
        ${isOpen ? "translate-x-0 " : "-translate-x-full 2xl:translate-x-0"}`}
      >
        {/* Logo */}
        <div className="flex justify-center ">
          <Image src={logo} alt="logo" height={120} width={150} />
          {/* <h3 className="font-inter text-[32px] font-bold">LOGO</h3> */}
        </div>

        {/* Nav Items */}
        <ul className="flex flex-col gap-6 overflow-scroll hide-scrollbar ">
          {navitems.map((item, index) => {
            const isActive =
              pathname === item.link || pathname.startsWith(item.link + "/");

            const Icon = item.icon;
            return (
              <Link
                href={item.link}
                key={index}
                onClick={() => setIsOpen(false)} // auto close on mobile
                className={`py-2 px-2 font-inter font-medium flex items-center gap-4 cursor-pointer rounded-lg transition-all duration-200 ${
                  isActive
                    ? "bg-gradient-to-r from-[#21E6A0] to-[#6DF844] text-black"
                    : "text-[#000000] hover:bg-gradient-to-r from-[#21E6A0] to-[#6DF844]"
                }`}
              >
                <Icon
                  size={24}
                  className="
            transition 
            group-hover:text-[#7008E7]
          "
                />

                {item.name}
              </Link>
            );
          })}
        </ul>

        {/* Logout */}
        <div className="">
          
            <button
            onClick={handleLogout}
            className="flex items-center gap-4 py-2 px-2 w-full text-[#FF1100]  hover:bg-gradient-to-r from-[#21E6A0] to-[#6DF844] font-inter font-medium cursor-pointer rounded-lg transition-all duration-200">
              <Image src={logout} alt="log out" className="w-6 h-6 " />
              Log Out
            </button>
          
        </div>
      </div>

      {/* 🔹 Overlay for mobile (click to close) */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/40  z-30 2xl:hidden"
          onClick={() => setIsOpen(false)}
        ></div>
      )}
    </>
  );
};

export default Sidebar;
