import { useEffect, useState } from 'react'
import {
  Table, Avatar, Tag, Button, Image, message, Modal,
  Descriptions, Row, Col, Divider, Space,
} from 'antd'
import { UserOutlined, CheckCircleOutlined, CloseCircleOutlined, CarOutlined } from '@ant-design/icons'
import { getDrivers, acceptDriver } from '../api/admin'
import type { Driver } from '../api/types'
import type { ColumnsType } from 'antd/es/table'

const STATUS_COLOR = { PENDING: 'orange', APPROVED: 'green', REJECTED: 'red' } as const
const STATUS_LABEL = { PENDING: 'На рассмотрении', APPROVED: 'Одобрен', REJECTED: 'Отклонён' } as const

export default function DriversPage() {
  const [drivers, setDrivers] = useState<Driver[]>([])
  const [loading, setLoading] = useState(true)
  const [selected, setSelected] = useState<Driver | null>(null)
  const [actionLoading, setActionLoading] = useState(false)

  const load = () => {
    setLoading(true)
    getDrivers()
      .then(setDrivers)
      .catch(() => message.error('Ошибка загрузки'))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const handleDecision = async (accept: boolean) => {
    if (!selected) return
    setActionLoading(true)
    try {
      await acceptDriver(selected.User.id, accept)
      message.success(accept ? 'Водитель одобрен' : 'Водитель отклонён')
      setSelected(null)
      load()
    } catch {
      message.error('Не удалось изменить статус')
    } finally {
      setActionLoading(false)
    }
  }

  const columns: ColumnsType<Driver> = [
    {
      title: '',
      width: 56,
      render: (_, r) =>
        r.User.avatar_url
          ? <Avatar size={40} src={r.User.avatar_url} />
          : <Avatar size={40} icon={<UserOutlined />} />,
    },
    {
      title: 'Водитель',
      render: (_, r) => (
        <div>
          <div style={{ fontWeight: 600 }}>{r.User.full_name}</div>
          <div style={{ fontSize: 12, color: '#8c8c8c' }}>{r.User.email}</div>
          <div style={{ fontSize: 12, color: '#8c8c8c' }}>{r.User.phone}</div>
        </div>
      ),
    },
    {
      title: 'Автомобиль',
      render: (_, r) => (
        <div>
          <div>{r.car_make} {r.car_model}</div>
          <div style={{ fontSize: 12, color: '#8c8c8c' }}>
            {r.car_color} · {r.license_plate || '—'}
          </div>
        </div>
      ),
    },
    {
      title: 'Фото авто',
      dataIndex: 'car_url',
      width: 110,
      render: (url: string) =>
        url
          ? <Image
              width={90}
              height={60}
              src={url}
              style={{ borderRadius: 6, objectFit: 'cover' }}
            />
          : <span style={{ color: '#bbb' }}>—</span>,
    },
    {
      title: 'Статус',
      dataIndex: 'status',
      width: 150,
      render: (s: Driver['status']) => (
        <Tag color={STATUS_COLOR[s]}>{STATUS_LABEL[s]}</Tag>
      ),
    },
    {
      title: '',
      width: 130,
      render: (_, r) =>
        r.status === 'PENDING' ? (
          <Button type="primary" size="small" onClick={() => setSelected(r)}>
            Рассмотреть
          </Button>
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
        pagination={{ pageSize: 10 }}
      />

      <Modal
        open={!!selected}
        onCancel={() => !actionLoading && setSelected(null)}
        footer={null}
        width={680}
        title="Рассмотрение заявки"
        centered
        destroyOnClose
      >
        {selected && (
          <>
            <Row gutter={20}>
              {/* Левая колонка — водитель */}
              <Col span={12}>
                <div style={{ textAlign: 'center', marginBottom: 12 }}>
                  {selected.User.avatar_url ? (
                    <Image
                      src={selected.User.avatar_url}
                      style={{
                        width: '100%',
                        height: 170,
                        objectFit: 'cover',
                        borderRadius: 8,
                      }}
                    />
                  ) : (
                    <div style={{
                      height: 170,
                      background: '#f5f5f5',
                      borderRadius: 8,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}>
                      <Avatar size={80} icon={<UserOutlined />} />
                    </div>
                  )}
                </div>
                <Descriptions column={1} size="small" bordered>
                  <Descriptions.Item label="ФИО">{selected.User.full_name}</Descriptions.Item>
                  <Descriptions.Item label="Email">{selected.User.email}</Descriptions.Item>
                  <Descriptions.Item label="Телефон">{selected.User.phone}</Descriptions.Item>
                </Descriptions>
              </Col>

              {/* Правая колонка — автомобиль */}
              <Col span={12}>
                <div style={{ textAlign: 'center', marginBottom: 12 }}>
                  {selected.car_url ? (
                    <Image
                      src={selected.car_url}
                      style={{
                        width: '100%',
                        height: 170,
                        objectFit: 'cover',
                        borderRadius: 8,
                      }}
                    />
                  ) : (
                    <div style={{
                      height: 170,
                      background: '#f5f5f5',
                      borderRadius: 8,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}>
                      <CarOutlined style={{ fontSize: 48, color: '#bbb' }} />
                    </div>
                  )}
                </div>
                <Descriptions column={1} size="small" bordered>
                  <Descriptions.Item label="Марка">{selected.car_make}</Descriptions.Item>
                  <Descriptions.Item label="Модель">{selected.car_model}</Descriptions.Item>
                  <Descriptions.Item label="Цвет">{selected.car_color}</Descriptions.Item>
                  <Descriptions.Item label="Гос. номер">{selected.license_plate || '—'}</Descriptions.Item>
                </Descriptions>
              </Col>
            </Row>

            <Divider style={{ margin: '20px 0' }} />

            <Space style={{ width: '100%', justifyContent: 'flex-end' }} size="middle">
              <Button
                danger
                size="large"
                icon={<CloseCircleOutlined />}
                loading={actionLoading}
                onClick={() => handleDecision(false)}
                style={{ minWidth: 140 }}
              >
                Отклонить
              </Button>
              <Button
                type="primary"
                size="large"
                icon={<CheckCircleOutlined />}
                loading={actionLoading}
                onClick={() => handleDecision(true)}
                style={{ minWidth: 140, background: '#52c41a', borderColor: '#52c41a' }}
              >
                Одобрить
              </Button>
            </Space>
          </>
        )}
      </Modal>
    </div>
  )
}
