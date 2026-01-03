import React from 'react';
import { Wifi, Home, LayoutGrid, Tv, Users, PieChart, Settings, LogOut } from 'lucide-react';

function NavItem({ icon: Icon, label, active, onClick }) {
    return (
        <div className={`nav-item ${active ? 'active' : ''}`} onClick={onClick}>
            <Icon size={20} className="nav-icon" />
            <span className="nav-label">{label}</span>
            {active && <div className="active-indicator"></div>}
        </div>
    );
}

export default function Sidebar({ activeTab, setActiveTab, avatarUrl, onLogout }) {
    const fullName = localStorage.getItem('fullName') || 'Người dùng';

    return (
        <aside className="sidebar">
            <div className="logo-section">
                <div className="logo-icon-bg">
                    <Wifi size={24} color="white" />
                </div>
                <span className="logo-text">smarthouse</span>
            </div>

            <div className="sidebar-divider"></div>

            <div className="user-profile">
                <img src={avatarUrl} alt="User" className="avatar" />
                <div className="user-info">
                    <span className="welcome-text">Chào mừng trở về,</span>
                    <span className="user-name">{fullName}</span>
                </div>
            </div>

            <nav className="nav-menu">
                <NavItem icon={Home} label="Không gian" active={activeTab === 'Spaces'} onClick={() => setActiveTab('Spaces')} />
                <NavItem icon={LayoutGrid} label="Phòng" active={activeTab === 'Rooms'} onClick={() => setActiveTab('Rooms')} />
                <NavItem icon={Tv} label="Thiết bị" active={activeTab === 'Devices'} onClick={() => setActiveTab('Devices')} />
                <NavItem icon={Users} label="Thành viên" active={activeTab === 'Members'} onClick={() => setActiveTab('Members')} />
                <NavItem icon={PieChart} label="Thống kê" active={activeTab === 'Statistics'} onClick={() => setActiveTab('Statistics')} />
            </nav>

            <div className="sidebar-divider"></div>

            <div className="settings-section">
                <NavItem icon={Settings} label="Hồ sơ & Cài đặt" active={activeTab === 'Settings'} onClick={() => setActiveTab('Settings')} />
            </div>

            <div className="logout-section">
                <NavItem icon={LogOut} label="Đăng xuất" onClick={onLogout} />
            </div>
        </aside>
    );
}
