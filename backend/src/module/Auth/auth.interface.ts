export type TLoginUser ={
    email: string;
    password:string;
};

export type TRegisterUserPayload = {
    name: string;
    email:string;
    mobile?:string;
    password:string;
}

export type ChangePasswordPayload = {
  currentPassword: string;
  newPassword: string;
};