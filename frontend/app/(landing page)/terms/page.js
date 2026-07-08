import Container from '@/app/component/Container';
import Navbar from '@/app/component/Navbar';
import React from 'react'
// import Navbar from '../component/Navbar'
// import Container from '../component/Container'
import { BiPhoneCall } from "react-icons/bi";
import { MdOutlineMarkEmailUnread } from "react-icons/md";


const page = () => {
  return (
    <div className='pb-[77px]'>
       <Container>

         <div className='flex justify-between py-4'>
        <p className='font-figtree text-[18px]'>
            Hello!! Welcome to PopBom
        </p>
            <div className='flex gap-[21px]'>
                <p className='font-figtree text-[18px] flex items-center gap-1'>
                    <MdOutlineMarkEmailUnread className='w-4 h-4' />
                    popbom@gmail.com
                </p>


                <p className='font-figtree text-[18px] flex items-center gap-1'>
                <BiPhoneCall className='w-4 h-4' />
                +757 699-4478

                </p>

            </div>
        </div>
        <Navbar className='my-[60px]'/>

       <div>
         <h3 className='font-figtree font-bold text-[56px] '>
            Term of Use
        </h3>

        <p className='font-figtree text-[#707071] text-[32px] mt-10 '>
          { `Welcome to [Your Company Name]. Before using our logo design service, please carefully review the following Terms and Conditions, as they govern the contractual relationship between you (the "Client") and [Your Company Name] (the "Service Provider"). By using our logo design service, you acknowledge that you have read, understood, and agreed to these Terms and Conditions in their entirety.`}
        </p>
       </div>

       <div className='mt-7'>
         <h3 className='font-figtree font-bold text-[56px] '>
            → What data do we process?
        </h3>

        <p className='font-figtree text-[#707071] text-[32px] mt-10 '>
          {` a. [Your Company Name] will provide custom logo design services to the Client based on the specifications provided by the Client.`}

           <br/>
           <br/>
           
           {` b. The Service Provider will deliver the final logo design in the agreed-upon format upon completion and full payment of the service fee.
`}
        </p>
       </div>





       </Container>
      
    </div>
  )
}

export default page
