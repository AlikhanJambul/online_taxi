import { useEffect, useState } from 'react'
import { Table, Avatar, Tag, message } from 'antd'
import { UserOutlined } from '@ant-design/icons'
import { getUsers } from '../api/admin'
import type { User } from '../api/types'
import type { ColumnsType } from 'antd/es/table'

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    getUsers()
      .then(setUsers)
      .catch(() => message.error('Ошибка загрузки пользователей'))
      .finally(() => setLoading(false))
  }, [])

  const columns: ColumnsType<User> = [
    {
      title: 'Фото',
      dataIndex: 'avatar_url',
      width: 60,
      render: (url: string) =>
        url ? <Avatar src={url} /> : <Avatar icon={<UserOutlined />} />,
    },
    { title: 'Имя', dataIndex: 'full_name' },
    { title: 'Email', dataIndex: 'email' },
    { title: 'Телефон', dataIndex: 'phone' },
    {
      title: 'Роль',
      dataIndex: 'role',
      render: (role: string) => (
        <Tag color={role === 'DRIVER' ? 'blue' : role === 'ADMIN' ? 'purple' : 'green'}>
          {role}
        </Tag>
      ),
    },
  ]

  return (
    <div style={{ background: '#fff', borderRadius: 8, padding: 24 }}>
      <h2 style={{ marginTop: 0 }}>Пользователи</h2>
      <Table rowKey="id" dataSource={users} columns={columns} loading={loading} />
    </div>
  )
}
