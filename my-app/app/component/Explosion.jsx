import React from 'react'
import Container from './Container'
import Image from 'next/image'
import explosion1 from '@/public/explosion1.png'
import explosion2 from '@/public/explosion2.png'
import explosion3 from '@/public/explosion3.png'
import explosion4 from '@/public/explosion4.png'
import explosion5 from '@/public/explosion5.png'
import line from '@/public/line.png'

const Explosion = () => {
  return (
    <div id='explosions' className='pb-[21px] pt-[85px]'>
        <Container className={ ``}>
            <h3 className='py-[13.5px] px-[24.5px] bg-black text-white text-[32px] font-roboto font-bold rounded-full w-[279px] mx-auto'>In 5 Explosions</h3>




        <div className='grid grid-cols-2 grid-rows-2 gap-x-[714px] gap-y-[139px] relative  mt-[61px]'>

        <div className='bg-gradient-to-b from-[#21E6A0] to-[#6DF844] w-[316px] rounded-[25px] px-[15px] text-center pt-[30px] pb-[73px]'>
                <div className='flex items-center justify-center gap-[15px]'>
                    <Image src={explosion1}/>
                    <p className='font-roboto font-bold text-[20px] ' >Light the Fuse </p>

                </div>
                <p className='text-[24px] font-roboto mt-[62px]'>Join PopBom in seconds simple sign-up, and you’re ready to blast off</p>

            </div>



            <div className='bg-gradient-to-b from-[#21E6A0] to-[#6DF844] w-[316px] rounded-[25px] px-[15px] text-center pt-[30px] pb-[73px]'>
                <div className='flex items-center justify-center gap-[15px]'>
                    <Image src={explosion3}/>
                    <p className='font-roboto font-bold text-[20px] ' >Capture the Spark </p>

                </div>
                <p className='text-[24px] font-roboto mt-[62px]'>Record or upload a bold 5-second video that grabs attention instantly</p>

            </div>


            



            <div className='bg-gradient-to-b from-[#21E6A0] to-[#6DF844] w-[316px] rounded-[25px] px-[15px] text-center pt-[30px] pb-[73px]'>
                <div className='flex items-center justify-center gap-[15px]'>
                    <Image src={explosion4}/>
                    <p className='font-roboto font-bold text-[20px] ' >Tag the PopBom </p>

                </div>
                <p className='text-[24px] font-roboto mt-[62px]'>Drop hashtags that amplify your boom and connect with the world</p>

            </div>


            <div className='bg-gradient-to-b from-[#21E6A0] to-[#6DF844] w-[316px] rounded-[25px] px-[15px] text-center pt-[30px] pb-[73px]'>
                <div className='flex items-center justify-center gap-[15px]'>
                    <Image src={explosion5}/>
                    <p className='font-roboto font-bold text-[20px] ' >Add Your Explosion</p>

                </div>
                <p className='text-[24px] font-roboto mt-[62px]'>Style it up with sounds, effects, or text — make your moment unforgettable</p>

            </div>

            
            <div className='bg-gradient-to-b from-[#21E6A0] to-[#6DF844] w-[316px] rounded-[25px] px-[15px] text-center pt-[30px] pb-[73px] absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2'>
                <div className='flex items-center justify-center gap-[15px]'>
                    <Image src={explosion2}/>
                    <p className='font-roboto font-bold text-[20px] ' >PopBom it </p>

                </div>
                <p className='text-[24px] font-roboto mt-[62px]'>Hit post and watch your 5-second PopBom explode across the feed

</p>

            </div>
            
            <Image className='absolute top-[84px] left-[327px]' src={line}/>
            <Image className='absolute top-[84px] right-[327px] rotate-90' src={line}/>
            <Image className='absolute bottom-[84px] left-[327px] rotate-90' src={line}/>
            <Image className='absolute bottom-[84px] right-[327px] ' src={line}/>


        </div>

            
        </Container>
      
    </div>
  )
}

export default Explosion
