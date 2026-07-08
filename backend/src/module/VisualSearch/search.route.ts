import { Router } from "express";
import { VisualSearchController } from "./search.controller";
import uploadSearchImage from "../../app/middleware/uploadSearchImage";
import uploadSearchAudio from "../../app/middleware/uploadSearchAudio";


const router = Router();

router.post("/by-text", VisualSearchController.searchByText);

router.post("/by-image", uploadSearchImage.single("image"), VisualSearchController.searchByImage);

router.post("/by-audio", uploadSearchAudio.single("audio"), VisualSearchController.searchByAudio);

export const VisualSearchRoutes = router;