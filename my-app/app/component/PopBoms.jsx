import React from 'react'
import Container from './Container'
import Image from 'next/image'
import pop1 from '@/public/popbom1.png'
import pop2 from '@/public/popbom2.png'
import pop3 from '@/public/popbom3.png'
import playSign from '@/public/playSign.png'

const PopBoms = () => {
  return (
    <div id='popbom' className='pt-[92px] pb-[128px]'>
        <Container>
              <h3 className='py-[13.5px] px-[24.5px] bg-black text-white text-[32px] font-roboto font-bold rounded-full w-[381px] mx-auto text-center '>PopBom's</h3>

              <div className='flex justify-between mt-[125px]'>
                <div className="child w-[431px] bg-[#6DF844] rounded-[25px] ">
                    <div  className='relative'>
                        <Image src={pop1}/>
                    <Image className='absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2' src={playSign}/>
                    </div>
                    <div className="text pt-[20px] pl-[20px] pb-[71px]  ">
                        <h3 className='text-[24px] font-roboto font-bold'>Mahima Islam</h3>
                        <p className='text-[24px] font-roboto font-light mt-[19px]'>viral 5s dance video</p>
                    </div>

                </div>


                <div className="child w-[431px] bg-[#6DF844] rounded-[25px] ">
                    <div  className='relative'>
                        <Image src={pop2}/>
                    <Image className='absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2' src={playSign}/>
                    </div>
                    <div className="text pt-[20px] pl-[20px] pb-[71px]  ">
                        <h3 className='text-[24px] font-roboto font-bold'>Mahima Islam</h3>
                        <p className='text-[24px] font-roboto font-light mt-[19px]'>viral 5s dance video</p>
                    </div>

                </div>



                <div className="child w-[431px] bg-[#6DF844] rounded-[25px] ">
                    <div  className='relative'>
                        <Image src={pop3}/>
                    <Image className='absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2' src={playSign}/>
                    </div>
                    <div className="text pt-[20px] pl-[20px] pb-[71px]  ">
                        <h3 className='text-[24px] font-roboto font-bold'>Mahima Islam</h3>
                        <p className='text-[24px] font-roboto font-light mt-[19px]'>viral 5s dance video</p>
                    </div>

                </div>
              </div>
        </Container>
      
    </div>
  )
}

export default PopBoms
