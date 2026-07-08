import React from 'react'
import Navbar from './component/Navbar'
import Image from 'next/image'
import logo from '../public/LOGO.png'
import Container from './component/Container'
import playstore from '../public/playstore.png'
import apple from '../public/apple.png'
import Story from './(landing page)/Story'
import PopBoms from './(landing page)/PopBoms'
import FAQ from './(landing page)/FAQ'
import Explosion from './(landing page)/Explosion'
import Footer from './component/Footer'

const page = () => {
  return (
    <div>
       <div className='bg-black'>
       <div className='bg-[url(/banner.png)] bg-cover bg-center bg-no-repeat  relative after:absolute after:h-full after:top-0 after:left-0 after:w-full after:bg-black/60 pt-[149px] pb-[85px] z-30 after:-z-30 '>
      <Navbar/>
     
     <Container className='flex flex-col items-center justify-center text-center'>
      <div className=''>
      <Image  src={logo} alt='logo'/>
      <h3 className='font-roboto text-[32px] text-white'>PopBom. Explode in 5</h3>
     </div>

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

     <div className='mt-[42px]'>
      <h3 className='text-white text-[32px] font-roboto font-semibold'>
        What is PopBom?
      </h3>
      <p className='text-white text-[24px] font-roboto text-start font-light mt-[26px] '>
        PopBom is a modern social platform designed for quick 5-second video sharing. It empowers users to create, pop, and share their moments instantly with a sleek, app-focused experience. With a minimalistic design and engaging tools, PopBom makes creativity simple and fun. The platform blends TikTok-style interaction with unique storytelling features in short bursts. Users can explore trending Pops, showcase their talent, and connect with others through strong visuals and smooth flow. PopBom’s mission is to inspire creativity and build a community where every second counts.
      </p>
     </div>
     </Container>
      </div>
     </div>

     <Story/>
     <PopBoms/>
     <Explosion/>
     <FAQ/>
     <Footer/>
     


     
    </div>
      
    
  )
}

export default page
