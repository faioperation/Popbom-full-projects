import Image from 'next/image'
import React from 'react'


import Link from 'next/link';


const Success = () => {
  return (

    <div className='grid justify-center items-center h-screen bg-[#EAEAEA]'>

     <main className="bg-white    overflow-y-auto hide-scrollbar py-30 px-11 rounded-3xl  ">
      <form className="gap-5 flex flex-col items-center w-[480px] ">

        

      <h3 className='font-inter font-medium text-[32px] text-[#333333]  text-center '>Password Updated Successfully!</h3>

      <p className='font-inter  text-[#333333]  mb-5 text-center'>Your new password has been saved. You can now continue securely.</p>

     
      


     <Link href='/signin' className='w-full'>
     
      <button className='bg-gradient-to-r from-[#21E6A0] to-[#6DF844] text-white font-semibold text-xl w-full font-inter py-3 rounded-lg cursor-pointer mt-5'>
        Sign In
      </button>
     </Link> 

     
      
      </form>

    </main>
    </div>
  )
}

export default Success