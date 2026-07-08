import multer from "multer";
import { CloudinaryStorage } from "multer-storage-cloudinary";
import cloudinary from "../config/cloudinary.config";

const storage = new CloudinaryStorage({
    cloudinary,
    params: async(req, file) =>{
        const folder = "popbom_uploads";
       
        return {
            folder,
            resource_type:"auto",
            public_id:`${Date.now()}-${file.originalname.split(".")[0]}`,
        };
    },
});

const upload = multer({
    storage,
    limits: {
        fileSize: 100 * 1024 * 1024, // 100MB limit
    },
});

export default upload;