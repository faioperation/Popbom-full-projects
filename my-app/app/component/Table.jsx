import React from "react";

export default function Table({
  TableHeads,
  TableRows,
  headClass,
  tableClass,
  onStatusChange,
}) {
  return (
    <table
      className={`w-full rounded-t-2xl  border-collapse   overflow-hidden ${tableClass}`}
    >
      {/* ==== TABLE HEADER ==== */}
      <thead>
        <tr className="  ">
          {TableHeads.map((head, idx) => (
            <th
              key={idx}
              className={`p-5 -2xl font-inter text-left text-[18px] font-medium bg-[#2DDE7F]/30  text-[#0A0A0A]
                ${idx === TableHeads.length - 1 ? "" : ""} ${headClass}`}
              style={{ width: head.width }}
            >
              {head.Title}
            </th>
          ))}
        </tr>
      </thead>

      {/* ==== TABLE BODY ==== */}
      <tbody className=" pb-20">
        {TableRows.map((row, rowIdx) => (
          <tr key={rowIdx}>
            {TableHeads.map((head, headIdx) => (
              <td
                key={headIdx}
                className="border-t  border-[#000000]/10  p-5 font-inter  text-[#0F172B] "
              >
                {/* If render function exists, use it — otherwise show plain data */}
                {head.render
                  ? head.render(
                      row[head.key], 
                      row, 
                      onStatusChange 
                    )
                  : row[head.key]}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
