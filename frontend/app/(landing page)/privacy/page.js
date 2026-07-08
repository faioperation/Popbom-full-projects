import Container from "@/app/component/Container";
import Navbar from "@/app/component/Navbar";
import React from "react";
// import Navbar from '../component/Navbar'
// import Container from '../component/Container'
import { BiPhoneCall } from "react-icons/bi";
import { MdOutlineMarkEmailUnread } from "react-icons/md";

const page = () => {
  return (
    <div className="pb-[77px]">
      <Container>
        <div className="flex justify-between py-4">
          <p className="font-figtree text-[18px]">Hello!! Welcome to PopBom</p>
          <div className="flex gap-[21px]">
            <p className="font-figtree text-[18px] flex items-center gap-1">
              <MdOutlineMarkEmailUnread className="w-4 h-4" />
              popbom@gmail.com
            </p>

            <p className="font-figtree text-[18px] flex items-center gap-1">
              <BiPhoneCall className="w-4 h-4" />
              +757 699-4478
            </p>
          </div>
        </div>
        <Navbar className="my-[60px]" />

        <div>
          <h3 className="font-figtree font-bold text-[56px] ">
            Privacy Policy
          </h3>

          <p className="font-figtree text-[#707071] text-[32px] mt-10 ">
            {`  Welcome to PopBom.Before using our logo design service, please carefully review the following Terms and Conditions, as they govern the contractual relationship between you (the "Client") and [Your Company Name] (the "Service Provider"). By using our logo design service, you acknowledge that you have read, understood, and agreed to these Terms and Conditions in their entirety.`}
          </p>
        </div>

        <div className="mt-7">
          <h3 className="font-figtree font-bold text-[56px] ">
            → What are your rights?
          </h3>

          <p className="font-figtree text-[#707071] text-[32px] mt-10 ">
            {` a. The Client acknowledges that all rights, title, and ownership of the final logo design will belong solely to the Client after full payment has been received by the Service Provider.`}
            <br />
            <br />
            {`
            b. Final payment ensures that only the agreed design becomes the client’s property. Any previous ideas/concepts remain the property of The Service Provider, unless any prior agreement has been made.`}
          </p>
        </div>
      </Container>
    </div>
  );
};

export default page;
