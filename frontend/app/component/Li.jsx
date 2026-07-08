import React from 'react'

const Li = ({className,children,liText,href}) => {
  return (
    <div>
        <li className={`list-none py-[18px] ${className}`}>
        <a href={href} className='py-[13.5px] px-[29.5px] border bg-linear-to-b from-[#6DF844] to-[#21E6A0] rounded-full font-roboto text-[24px] font-bold border-white'>
            {liText}
        </a>
        {children}
    </li>
    </div>
  )
}

export default Li
