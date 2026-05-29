import { Form, Input, Button, Card, message } from 'antd'
import { LockOutlined, MailOutlined } from '@ant-design/icons'
import { useNavigate } from 'react-router-dom'
import { login } from '../api/admin'

export default function LoginPage() {
  const navigate = useNavigate()

  const onFinish = async (values: { email: string; password: string }) => {
    try {
      const token = await login(values.email, values.password)
      localStorage.setItem('admin_token', token)
      navigate('/users')
    } catch {
      message.error('Неверный email или пароль')
    }
  }

  return (
    <div
      style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        minHeight: '100vh',
        background: '#f0f2f5',
      }}
    >
      <Card title="Вход в панель администратора" style={{ width: 380 }}>
        <Form layout="vertical" onFinish={onFinish} autoComplete="off">
          <Form.Item name="email" label="Email" rules={[{ required: true, type: 'email' }]}>
            <Input prefix={<MailOutlined />} placeholder="admin@example.com" />
          </Form.Item>
          <Form.Item name="password" label="Пароль" rules={[{ required: true }]}>
            <Input.Password prefix={<LockOutlined />} />
          </Form.Item>
          <Button type="primary" htmlType="submit" block>
            Войти
          </Button>
        </Form>
      </Card>
    </div>
  )
}
