import { AnyZodObject } from "zod";
import { catchAsync } from "../utils/catchAsync";
import { Request, Response } from "express";
import { NextFunction } from "express-serve-static-core";


const validateRequest = (schema: AnyZodObject) =>{
    return catchAsync( async (req:Request, res: Response, next:NextFunction) =>{
        await schema.parseAsync({
            body: req.body
        });
       
        next();
    });
};

export default validateRequest;