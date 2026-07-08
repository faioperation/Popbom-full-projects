"use client";
import React, { useState } from 'react'
import { FaPlus, FaMinus, FaAngleDown, FaAngleUp } from 'react-icons/fa';
import { MdArrowDropDown, MdArrowDropUp } from 'react-icons/md';


const FAQdropdown = ({question,answer,className}) => {
    const [dropdown,setDropdown]=useState(false);
  return (
    <div className={` ${className}`}>
      <div  onClick={()=>setDropdown(!dropdown)}  className="one  bg-white cursor-pointer px-8 border-b border-[#000000]/10 ">
                      <div  className="up flex items-center justify-between py-[25.5px] ">
                          <h4 className='text-[#000000] text-xl  font-inter'>{question}</h4>
                          {dropdown? <FaAngleUp className='h-6 w-6 text-[#717182] ' />: <FaAngleDown  className='h-6 w-6 text-[#717182] ' />}
                          
                      </div>
                      <p className={`text-[#0C0C0C]   font-inter  ${dropdown? "opacity-100 h-auto visible overflow-auto pb-4" : "opacity-0 h-0 invisible overflow-hidden"}`}>{answer}</p>
                      
                  </div>
    </div>
  )
}

export default FAQdropdown