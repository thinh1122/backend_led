import React, { useState, useEffect } from 'react';
import './App.css';

import LoginPage from './components/LoginPage';
import Sidebar from './components/Sidebar';
import MainDashboard from './components/MainDashboard';
import ProfilePage from './components/ProfilePage';

const AVATAR_URL = "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop";

function App() {
  const [activeTab, setActiveTab] = useState('Spaces');
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      setIsLoggedIn(true);
    }
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('email');
    setIsLoggedIn(false);
  };

  return (
    <div className="dashboard-container">
      {!isLoggedIn && (
        <LoginPage onLogin={() => {
          localStorage.setItem('onboardingStep', '0');
          // localStorage.setItem('connectedDevices', '[]'); // Giữ lại data cũ nếu muốn
          // localStorage.setItem('addedRooms', '[]');
          setIsLoggedIn(true);
        }} />
      )}

      {isLoggedIn && (
        <>
          <Sidebar
            activeTab={activeTab}
            setActiveTab={setActiveTab}
            avatarUrl={AVATAR_URL}
            onLogout={handleLogout}
          />

          {activeTab !== 'Settings' && (
            <MainDashboard activeTab={activeTab} setActiveTab={setActiveTab} />
          )}

          {activeTab === 'Settings' && (
            <ProfilePage avatarUrl={AVATAR_URL} />
          )}
        </>
      )}
    </div>
  );
}

export default App;
