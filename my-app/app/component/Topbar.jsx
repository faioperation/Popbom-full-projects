"use client";
import Image from "next/image";
import React from "react";
import Avatar from "@/public/Avatar.png";
// import logo from "@/public/logo.png";
import { IoMdNotificationsOutline } from "react-icons/io";
import Link from "next/link";

const Topbar = () => {
  return (
    <div className=" flex items-center justify-end gap-10 bg-white p-2  ">
      

      <Link href={`/settings`}>
        <Image src={Avatar} alt="profile" />
        {/* <Image src={logo} alt="logo" /> */}
      </Link>
    </div>
  );
};

export default Topbar;
