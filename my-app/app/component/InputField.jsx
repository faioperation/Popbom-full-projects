import React from "react";

const InputField = ({
  label,
  name,              // ✅ ADD THIS
  className,
  placeholder,
  inputClass,
  labelClass,
  value,
  onChange,
  readOnly = false,
}) => {
  return (
    <div className={`flex flex-col w-full gap-2 ${className}`}>
      {label && (
        <label className={`font-inter text-[#000000] ${labelClass}`}>
          {label}
        </label>
      )}

      <input
        type="text"
        name={name}                        
        placeholder={placeholder}
        value={value ?? ""}                
        onChange={readOnly ? undefined : onChange}
        readOnly={readOnly}
        className={`bg-[#F3F3F5] outline-none p-3 text-[#0A0A0A] 
          placeholder:text-[#5D5D5D] font-inter ${inputClass}`}
      />
    </div>
  );
};

export default InputField;
