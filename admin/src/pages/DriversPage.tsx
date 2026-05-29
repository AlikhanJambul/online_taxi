import { useEffect, useState } from 'react'
import { Table, Avatar, Tag, Button, Image, Space, message, Popconfirm } from 'antd'
import { UserOutlined } from '@ant-design/icons'
import { getDrivers, acceptDriver } from '../api/admin'
import type { Driver } from '../api/types'
import type { ColumnsType } from 'antd/es/table'

const STATUS_COLOR = { PENDING: 'orange', APPROVED: 'green', REJECTED: 'red' } as const

export default function DriversPage() {
  const [drivers, setDrivers] = useState<Driver[]>([])
  const [loading, setLoading] = useState(true)

  const load = () => {
    setLoading(true)
    getDrivers()
      .then(setDrivers)
      .catch(() => message.error('Ошибка загрузки'))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const handleDecision = async (id: string, accept: boolean) => {
    try {
      await acceptDriver(id, accept)
      message.success(accept ? 'Водитель одобрен' : 'Водитель отклонён')
      load()
    } catch {
      message.error('Не удалось изменить статус')
    }
  }

  const columns: ColumnsType<Driver> = [
    {
      title: 'Фото',
      width: 60,
      render: (_, r) =>
        r.User.avatar_url
          ? <Avatar src={r.User.avatar_url} />
          : <Avatar icon={<UserOutlined />} />,
    },
    { title: 'Имя', render: (_, r) => r.User.full_name },
    { title: 'Email', render: (_, r) => r.User.email },
    { title: 'Телефон', render: (_, r) => r.User.phone },
    {
      title: 'Автомобиль',
      render: (_, r) => `${r.car_make} ${r.car_model} · ${r.car_color}`,
    },
    {
      title: 'Фото авто',
      dataIndex: 'car_url',
      render: (url: string) =>
        url ? <Image width={80} src={url} style={{ borderRadius: 4 }} /> : '—',
    },
    {
      title: 'Статус',
      dataIndex: 'status',
      render: (s: Driver['status']) => (
        <Tag color={STATUS_COLOR[s]}>{s}</Tag>
      ),
    },
    {
      title: 'Действие',
      render: (_, r) =>
        r.status === 'PENDING' ? (
          <Space>
            <Popconfirm title="Одобрить водителя?" onConfirm={() => handleDecision(r.User.id, true)}>
              <Button type="primary" size="small">Одобрить</Button>
            </Popconfirm>
            <Popconfirm title="Отклонить водителя?" onConfirm={() => handleDecision(r.User.id, false)}>
              <Button danger size="small">Отклонить</Button>
            </Popconfirm>
          </Space>
        ) : null,
    },
  ]

  return (
    <div style={{ background: '#fff', borderRadius: 8, padding: 24 }}>
      <h2 style={{ marginTop: 0 }}>Заявки водителей</h2>
      <Table
        rowKey={(r) => r.User.id}
        dataSource={drivers}
        columns={columns}
        loading={loading}
      />
    </div>
  )
}
