import { Request, Response, NextFunction } from "express";
import multer from "multer";

export const handleUploadError = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (err instanceof multer.MulterError) {

    return res.status(400).json({
      success: false,
      message: err.message,
    });
  }

  if (err) {
    // Handle Cloudinary-specific errors
    if (err.message && err.message.includes("cloud_name")) {
      return res.status(400).json({
        success: false,
        message: "Cloudinary configuration error. Please check your CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET in .env file. The cloud_name may be incorrect or your Cloudinary account may be disabled.",
      });
    }
    
    return res.status(500).json({
      success: false,
      message: err.message || "Upload failed",
    });
  }

  next();
};
