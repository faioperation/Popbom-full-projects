export const USER_ROLE ={
    user:'user',
    admin:'admin',
} as const;


export const USER_STATUS = ['active','inactive','blocked']  as const;


export const userSearchableFields =[
    'name',
    'email'
]