"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import React from "react";

const Layout = ({ children }) => {
  const pathname = usePathname();

  const nav = [
    { name: "Profile", link: "/settings" },
    { name: "Change Password", link: "/settings/changepass" },
    { name: "API Keys", link: "/settings/api" },
  ];

  return (
    <div>
      <ul className="flex gap-7 border-b border-black/20">
        {nav.map((item, index) => {
          const isActive = pathname === item.link;

          return (
            <Link
              key={index}
              href={item.link}
              className={`py-2 px-2 font-inter flex items-center gap-4 cursor-pointer transition-all duration-200 text-xl ${
                isActive
                  ? "border-b-2 border-black"
                  : "text-[#000000]"
              }`}
            >
              {item.name}
            </Link>
          );
        })}
      </ul>

      {children}
    </div>
  );
};

export default Layout;
