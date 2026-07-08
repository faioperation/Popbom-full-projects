"use client";
import React, { useState, useEffect, useRef } from "react";
import { FaCaretDown, FaCaretUp } from "react-icons/fa";
import { createPortal } from "react-dom";

const Dropdown = ({
  label = "",
  placeholder = "",
  value,
  options = [],
  onSelect,
  className = "",
  inputClass = "",
  optionClass = "",
  labelClass = "",
  icon = "",
}) => {
  const [selected, setSelected] = useState(value ?? placeholder ?? "");
  const [show, setShow] = useState(false);
  const [coords, setCoords] = useState(null);

  const dropdownRef = useRef(null);
  const triggerRef = useRef(null);
  const menuRef = useRef(null);

  // 🔁 sync selected value from parent
  useEffect(() => {
    setSelected(value ?? placeholder ?? "");
  }, [value, placeholder]);

  const handleSelect = (val) => {
    setSelected(val);
    setShow(false);
    onSelect?.(val);
  };

  // 🔹 outside click (portal safe)
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (
        !dropdownRef.current?.contains(e.target) &&
        !menuRef.current?.contains(e.target)
      ) {
        setShow(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () =>
      document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // 🔹 calculate dropdown position
  useEffect(() => {
    if (!show || !triggerRef.current) return;

    const rect = triggerRef.current.getBoundingClientRect();
    setCoords({
      top: rect.bottom + window.scrollY + 4,
      left: rect.left + window.scrollX,
      width: rect.width,
    });
  }, [show]);

  return (
    <div ref={dropdownRef} className={`flex flex-col relative ${className}`}>
      {/* Label */}
      {label && (
        <label className={`font-inter text-black ${labelClass}`}>
          {label}
        </label>
      )}

      {/* Trigger */}
      <div
        ref={triggerRef}
        onClick={() => setShow((p) => !p)}
        className="relative cursor-pointer"
      >
        <input
          readOnly
          value={selected}
          placeholder={placeholder}
          className={`w-full bg-transparent outline-none cursor-pointer text-black placeholder:text-black ${inputClass}`}
        />

        <div
          className={`w-6 h-6 absolute right-0 top-1/2 -translate-y-1/2 flex items-center justify-center ${icon}`}
        >
          {show ? <FaCaretUp /> : <FaCaretDown />}
        </div>
      </div>

      {/* Menu */}
      {show && coords &&
        createPortal(
          <div
            ref={menuRef}
            style={{
              position: "absolute",
              top: coords.top,
              left: coords.left,
              width: coords.width,
              zIndex: 9999,
            }}
            className={`bg-white border border-[#CED2E5] rounded-md shadow-md
              max-h-40 overflow-auto hide-scrollbar font-inter text-center
              ${optionClass}`}
          >
            {options.map((item, index) => (
              <div
                key={index}
                onClick={() => handleSelect(item)}
                className={`py-2 cursor-pointer
                  ${
                    selected === item
                      ? "bg-gradient-to-r from-[#21E6A0] to-[#6DF844] text-white"
                      : "hover:bg-gradient-to-r hover:from-[#21E6A0] hover:to-[#6DF844] hover:text-white"
                  }`}
              >
                {item}
              </div>
            ))}
          </div>,
          document.body
        )}
    </div>
  );
};

export default Dropdown;
