"use client";
import { usePathname } from "next/navigation";
import React from "react";

const Bredcumb = () => {
  const pathname = usePathname();

  const pathParts = pathname.split("/").filter((part) => part.trim() !== "");

  const visible = pathParts.slice(-2);

  const formatText = (text) => {
    return text.replaceAll("-", " ").replace(/\b\w/g, (c) => c.toUpperCase());
  };

  return (
    <div className="flex items-center">
      {visible.map((item, index) => (
        <h3
          key={index}
          className="capitalize font-inter text-[#000000] text-2xl  "
        >
          {formatText(item)}
          {index < visible.length - 1 && " / "}
        </h3>
      ))}
    </div>
  );
};

export default Bredcumb;
