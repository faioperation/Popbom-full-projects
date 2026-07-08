import React from 'react'
import Container from './Container'
import Image from 'next/image'
import logo from '@/public/LOGO.png'
import playstore from '@/public/playstore.png'
import apple from '@/public/apple.png'
import { CiFacebook, CiLinkedin } from "react-icons/ci";
import { FaInstagram } from "react-icons/fa";
import { AiOutlineLinkedin } from "react-icons/ai";


const Footer = () => {
  return (
    <div className='bg-black pt-[64px] pb-[60px] border-t border-white'>
        <Container className='flex flex-col items-center justify-center text-center '>
             <Image  src={logo} alt='logo'/>
            <div className='mt-[82px] '>
                  <h3 className='font-roboto text-white text-[32px] font-bold'>Download Now</h3>
                  <div className='flex gap-8 mt-[21px]'>
                    <a href='' className='bg-[#202019] w-[232px] py-[9px] px-[17px] rounded-[10px] flex  items-center gap-4' >
                    <Image src={playstore} alt='logo'/>
                    <div >
                      <p className='text-white font-inter text-[12px] text-start '>Download on the</p>
                      <p className='text-white font-inter font-bold text-[16px] mt-1 '>Google Play Store</p>
                      
                    </div>
                  </a>
                  <a href="" className='bg-[#202019] w-[232px] py-[9px] px-[17px] rounded-[10px] flex  items-center gap-4'>
                    <Image src={apple} alt='logo'/>
                    <div >
                      <p className='text-white font-inter text-[12px]  '>Download on the</p>
                      <p className='text-white font-inter font-bold text-[16px] mt-1 '>Apple Store</p>
                      
                    </div>
                  </a >
                  </div>
                 </div>

                 <div className='flex items-center gap-6 mt-5'>
                  <div className="line w-[354px] h-[1px] bg-white/35"></div>
                  <div className='flex items-center gap-8'>
                    <CiFacebook className='text-white w-10 h-10' />
                  <FaInstagram className='text-white w-10 h-10' />
                  
                  <CiLinkedin className='text-white w-10 h-10'  />
                  </div>
                  <div className="line w-[354px] h-[1px] bg-white/35"></div>
                  
                 </div>

                 <div className='flex items-center justify-center gap-[342px] border-t border-white w-full py-2.5 mt-8'>
                  <p className='text-white/72 font-sora text-[14px]'>Copyright © 2025 PopBom. All rights reserved.</p>

                  <ul className='font-sora text-[14px] text-white/72 flex items-center gap-2 '>
                    <li><a href="">Contact Details</a></li>
                    <li><a href="/privacy">Privacy policy</a></li>
                    <li><a href="/terms">Terms of use</a></li>
                  </ul>
                 </div>
        </Container>
      
    </div>
  )
}

export default Footer
