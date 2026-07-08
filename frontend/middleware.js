import { NextResponse } from "next/server";

export function middleware(req) {
  const token = req.cookies.get("accessToken")?.value;
  // PROTECTED ROUTES
  const protectedRoutes = [
    "/dashboard",
    "/userlist",
    "/reports",
    "/settings",
    "/settings/api",
    "/settings/changepass",
  ];

  const { pathname } = req.nextUrl;

  if (protectedRoutes.some((route) => pathname.startsWith(route))) {
    if (!token) {
      const loginUrl = new URL("/signin", req.url);
      return NextResponse.redirect(loginUrl);
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/:path*"],
};
