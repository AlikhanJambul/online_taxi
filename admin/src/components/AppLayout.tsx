import { Layout, Menu } from 'antd'
import { UserOutlined, CarOutlined, LogoutOutlined } from '@ant-design/icons'
import { Outlet, useNavigate, useLocation } from 'react-router-dom'

const { Sider, Content, Header } = Layout

export default function AppLayout() {
  const navigate = useNavigate()
  const location = useLocation()

  const handleLogout = () => {
    localStorage.removeItem('admin_token')
    navigate('/login')
  }

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider breakpoint="lg" collapsedWidth="0">
        <div style={{ color: 'white', textAlign: 'center', padding: '20px 16px', fontSize: 16, fontWeight: 700 }}>
          Online Taxi
        </div>
        <Menu
          theme="dark"
          mode="inline"
          selectedKeys={[location.pathname]}
          items={[
            {
              key: '/users',
              icon: <UserOutlined />,
              label: 'Пользователи',
              onClick: () => navigate('/users'),
            },
            {
              key: '/drivers',
              icon: <CarOutlined />,
              label: 'Водители',
              onClick: () => navigate('/drivers'),
            },
            {
              key: 'logout',
              icon: <LogoutOutlined />,
              label: 'Выйти',
              onClick: handleLogout,
              danger: true,
            },
          ]}
        />
      </Sider>
      <Layout>
        <Header style={{ background: '#fff', padding: '0 24px', borderBottom: '1px solid #f0f0f0' }}>
          <span style={{ fontSize: 16, fontWeight: 600 }}>Панель администратора</span>
        </Header>
        <Content style={{ padding: 24, background: '#f5f5f5', minHeight: 'calc(100vh - 64px)' }}>
          <Outlet />
        </Content>
      </Layout>
    </Layout>
  )
}
