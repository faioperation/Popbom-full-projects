import React from 'react'
import Container from './Container'
import Image from 'next/image'
import story1 from '@/public/story1.png'
import story2 from '@/public/story2.png'
import story3 from '@/public/story3.png'

const Story = () => {
  return (
    <div id='story' className='pt-[64px] pb-[115px]'>
        <Container className=''>
            <h3 className='py-[13.5px] px-[24.5px] bg-black text-white text-[32px] font-roboto font-bold rounded-full w-[182px] mx-auto'>Our story</h3>

            <div className='flex justify-between mt-20'>
                <div className="child w-[431px]  bg-linear-to-t from-[#6DF844] to-[#21E6A0] px-6 pt-[38px] pb-[29px] rounded-[15px] shadow-2xl">
                    <Image src={story1}/>

                    <p className='font-roboto text-[24px] font-light'>PopBom was born from a simple idea — big stories can be told in just 5 seconds. In a fast-moving world, we wanted to create a space where creativity, fun, and connection meet in short, powerful moments.
                    </p>
                </div>

                <div className="child w-[431px]  bg-linear-to-t from-[#6DF844] to-[#21E6A0] px-6 pt-[38px] pb-[29px] rounded-[15px] shadow-2xl">
                    <Image src={story2}/>

                    <p className='font-roboto text-[24px] font-light'>Our journey started with a vision to make sharing quick, effortless, and inspiring. We designed PopBom to be more than just another video app — it’s a place where every voice matters, where anyone can showcase their talent, and where communities can grow through engaging, bite-sized content.
                    </p>
                </div>


                <div className="child w-[431px]  bg-linear-to-t from-[#6DF844] to-[#21E6A0] px-6 pt-[38px] pb-[29px] rounded-[15px] shadow-2xl">
                    <Image src={story3}/>

                    <p className='font-roboto text-[24px] font-light'>With PopBom, we aim to inspire creativity one pop at a time, helping people around the world capture their energy, share their passion, and connect through the magic of short videos.
                    </p>
                </div>
            </div>
        </Container>
      
    </div>
  )
}

export default Story
