import client from './client'
import type { User, Driver } from './types'

export const login = async (email: string, password: string): Promise<string> => {
  const { data } = await client.post('/api/v1/admin/login', { email, password })
  return data.body as string
}

export const getUsers = async (): Promise<User[]> => {
  const { data } = await client.get('/api/v1/admin/users')
  return (data.body as User[]) ?? []
}

export const getDrivers = async (): Promise<Driver[]> => {
  const { data } = await client.get('/api/v1/admin/drivers')
  return (data.body as Driver[]) ?? []
}

export const acceptDriver = async (id: string, accept: boolean): Promise<void> => {
  await client.post('/api/v1/admin/drivers/accept', { id, accept })
}
