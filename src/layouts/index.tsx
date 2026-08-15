import { Layout, Menu } from 'antd';
import React from 'react';
import { Link, Outlet, useLocation } from 'umi';

const { Header, Content, Footer } = Layout;

const AppLayout: React.FC = () => {
  const location = useLocation();

  const menuItems = [
    {
      key: '/',
      label: <Link to="/">Home</Link>,
    },
    {
      key: '/game-commands',
      label: <Link to="/game-commands">Game Commands</Link>,
    },
    {
      key: '/about',
      label: <Link to="/about">About</Link>,
    },
  ];

  return (
    <Layout className="app-shell">
      <Header className="app-header">
        <Link to="/" className="app-logo">
          Ananta Gateway Control
        </Link>
        <Menu
          theme="dark"
          mode="horizontal"
          selectedKeys={[location.pathname]}
          items={menuItems}
          className="app-menu"
        />
      </Header>
      <Content className="app-content">
        <div className="app-panel">
          <Outlet />
        </div>
      </Content>
      <Footer className="app-footer">
        Ananta Gateway Control (c) {new Date().getFullYear()} - Real-time game server control
      </Footer>
    </Layout>
  );
};

export default AppLayout;
