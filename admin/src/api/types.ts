export interface User {
  id: string
  email: string
  phone: string
  full_name: string
  role: string
  avatar_url: string
}

export interface Driver {
  User: User
  car_make: string
  car_model: string
  car_color: string
  car_url: string
  license_plate: string
  status: 'PENDING' | 'APPROVED' | 'REJECTED'
}

