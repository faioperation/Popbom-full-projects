import jwt from "jsonwebtoken";

const SECRET = process.env.JWT_SECRET || "SUPER_SECRET_KEY";

// export function generateToken(payload) {
//   return jwt.sign(payload, SECRET, { expiresIn: "7d" });
// }

export function verifyToken(token) {
  try {
    return jwt.verify(token, SECRET);
  } catch (e) {
    return null;
  }
}
