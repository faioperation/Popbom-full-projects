import React from 'react'
import Container from './Container'
import Li from './Li'

const Navbar = ({className}) => {
  return (
    <div className={`${className}`}>
        <Container className='w-[917px] '>
            <div className='flex justify-between'>
                <Li href='/' liText='Home'/>
                <Li href='#story' liText='Our story'/>
                <Li href='#popbom' liText='PopBom’s '/>
                <Li href='#explosions'  liText='In 5 Explosions'/>
                <Li href='#faq' liText='FAQ'/>
            </div>

        </Container>
      
    </div>
  )
}

export default Navbar
