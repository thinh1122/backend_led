import React, { useState, useEffect } from 'react';
import mqtt from 'mqtt';
import {
    ArrowLeft, Search, Check, Plus, Trash2, Edit2, Tv,
    Cloud, Droplet, Lightbulb, Music, ChevronDown, MoreHorizontal,
    Bed, Bath, UtensilsCrossed, LayoutGrid, Sofa
} from 'lucide-react';
import OnboardingWizard from './onboarding/OnboardingWizard';
import { authService } from '../services/api'; // Import API Service

import {
    HOUSE_URL,
    ROOM_IMG,
    DEVICE_IMG_BASE,
    ROOM_IMAGES,
    DEVICES,
    resolveDeviceImage
} from '../constants/dashboardConstants';
import ichomestep1 from '../assets/ichomestep1.png';

import {
    DashboardRoomCard,
    DashboardDeviceCard,
    RoomDetailView,
    DeviceDetailView,
    DevicesStep1,
    DevicesStep2,
    DevicesStep3,
    StatisticsView
} from './dashboard/DashboardComponents';

// Helper cleanId (same as Backend/App)
const cleanId = (input) => {
    if (!input) return "";
    let str = input.toLowerCase();
    str = str.normalize("NFD").replace(/[\u0300-\u036f]/g, ""); // Remove accents
    str = str.replace(/đ/g, 'd').replace(/Đ/g, 'd');
    str = str.replace(/[^a-z0-9]/g, "_");
    str = str.replace(/_+/g, "_");
    return str;
};



export default function MainDashboard({ activeTab, setActiveTab }) {
    // Initialize step from localStorage or default to 0
    const [step, setStep] = useState(() => {
        const savedStep = localStorage.getItem('onboardingStep');
        return savedStep ? parseInt(savedStep, 10) : 0;
    });

    const [connectedDevices, setConnectedDevices] = useState(() => {
        return JSON.parse(localStorage.getItem('connectedDevices')) || [];
    });
    const [rooms, setRooms] = useState(() => {
        return JSON.parse(localStorage.getItem('addedRooms')) || [];
    });
    const [dashboardView, setDashboardView] = useState('home'); // 'home' or 'map'
    const [selectedRoom, setSelectedRoom] = useState(null); // Detail view for a specific room
    const [selectedDevice, setSelectedDevice] = useState(null); // Detail view for a specific device
    const [selectedDeviceRoom, setSelectedDeviceRoom] = useState(null); // The room name of the selected device
    const [deviceTabStep, setDeviceTabStep] = useState(1); // 3 steps logic for Devices tab

    // Fetch Devices from Backend
    useEffect(() => {
        const fetchDevices = async () => {
            try {
                const response = await authService.getMyDevices();
                const devices = response.data;
                console.log("Fetched Devices:", devices);

                if (devices && Array.isArray(devices)) {
                    setConnectedDevices(devices);

                    // Nếu đã có thiết bị trên Server thì bỏ qua Onboarding
                    if (devices.length > 0 && step < 7) {
                        setStep(7);
                    }
                }
            } catch (error) {
                console.error("Lỗi khi tải danh sách thiết bị:", error);
            }
        };

        // Chỉ fetch nếu đã Login (có token - được xử lý ở App.jsx)
        fetchDevices();
    }, []);

    // Save state to localStorage whenever it changes
    useEffect(() => {
        localStorage.setItem('onboardingStep', step);
        localStorage.setItem('connectedDevices', JSON.stringify(connectedDevices));
        localStorage.setItem('addedRooms', JSON.stringify(rooms));
    }, [step, connectedDevices, rooms]);

    // MQTT Real-time Listener
    useEffect(() => {
        // Chỉ kết nối nếu đã vào Dashboard (step 7) và có thiết bị
        if (step !== 7) return;

        const options = {
            username: 'nguyenducphat',
            password: 'Phat123456',
            protocol: 'wss',
            port: 8884,
            clientId: `web_client_${Math.random().toString(16).substr(2, 8)}`,
        };

        const client = mqtt.connect('wss://397cff1b3ee848298abac387ff2829e2.s1.eu.hivemq.cloud:8884/mqtt', options);

        client.on('connect', () => {
            console.log('✅ Web Dashboard connected to HiveMQ Cloud (WSS)');
            client.subscribe('smarthome/devices/+/state', (err) => {
                if (!err) {
                    console.log('📡 Subscribed to device updates');
                }
            });
        });

        client.on('message', (topic, message) => {
            const payload = message.toString();
            console.log(`📩 MQTT Message: ${topic} -> ${payload}`);

            // Parse slug from topic: smarthome/devices/{slug}/state
            const parts = topic.split('/');
            if (parts.length >= 3) {
                const mqttId = parts[2]; // get slug or hardwareId
                const newState = payload === 'ON';

                setConnectedDevices(prevDevices => {
                    return prevDevices.map(device => {
                        // Check match: Priority hardwareId, then slug
                        const hwId = device.hardwareId;
                        const deviceSlug = cleanId(device.name);

                        // Match if hardwareId matches OR slug matches
                        const isMatch = (hwId && hwId === mqttId) || (deviceSlug === mqttId);

                        if (isMatch) {
                            console.log(`🔄 Updating device ${device.name} to ${payload}`);
                            return { ...device, isOn: newState };
                        }
                        return device;
                    });
                });
            }
        });

        client.on('error', (err) => {
            console.error('MQTT Connection Error:', err);
        });

        return () => {
            console.log('Disconnecting MQTT...');
            client.end();
        };

    }, [step]); // Re-connect if step changes (e.g. finishes onboarding)

    const handleDeviceClick = (deviceName, roomName) => {
        setSelectedDevice(deviceName);
        setSelectedDeviceRoom(roomName);
        setDeviceTabStep(4);
        setSelectedRoom(null);
        setActiveTab('Devices');
    };

    return (
        <main className={`main-content ${activeTab === 'Spaces' && step === 0 ? 'empty-state-layout' : ''}`}>

            {/* VIEW: EMPTY STATE (Step 0) */}
            {step === 0 && (
                <div className="empty-state-container">
                    <div className="empty-state-text">
                        <h2>Có vẻ như bạn chưa thiết lập không gian nào.</h2>
                        <p>Thêm ngôi nhà của bạn và bắt đầu cuộc sống thông minh!</p>
                    </div>

                    <div className="empty-state-illustration">
                        <img src={ichomestep1} alt="No spaces illustration" />
                    </div>

                    <button className="setup-btn" onClick={() => setStep(1)}>
                        Thiết lập không gian
                    </button>
                </div>
            )}

            {/* VIEW: ONBOARDING STEPS (1-6) */}
            {step > 0 && step < 7 && (
                <OnboardingWizard
                    step={step}
                    setStep={setStep}
                    rooms={rooms}
                    setRooms={setRooms}
                    connectedDevices={connectedDevices}
                    setConnectedDevices={setConnectedDevices}
                />
            )}

            {/* VIEW: FINAL DASHBOARD (Step 7) */}
            {step === 7 && (
                <div className="dashboard-final-layout">
                    {activeTab !== 'Devices' && activeTab !== 'Statistics' && (
                        <header className="dashboard-header-bg">
                            <div className="dashboard-top-row">
                                <div className="header-left-group">
                                    {activeTab === 'Rooms' ? (
                                        <div className="dash-title-group">
                                            <h2>Phòng</h2>
                                        </div>
                                    ) : (
                                        <>
                                            {dashboardView === 'map' && (
                                                <button className="dash-back-btn" onClick={() => setDashboardView('home')}>
                                                    <ArrowLeft size={20} />
                                                </button>
                                            )}
                                            <div className="dash-title-group">
                                                <span className="dash-subtitle">{dashboardView === 'map' ? 'Nhà của tôi' : ''}</span>
                                                <h2>{dashboardView === 'map' ? 'Sơ đồ không gian' : 'Không gian'}</h2>
                                            </div>
                                        </>
                                    )}
                                </div>
                                <div className="home-selector">
                                    <img src={HOUSE_URL} alt="Home" className="tiny-home-img" />
                                    <span>Nhà của tôi</span>
                                    <ChevronDown size={16} />
                                </div>
                            </div>

                            <div className="dashboard-widgets-row">
                                <div className="dash-widget combined-widget">
                                    <div className="widget-part">
                                        <div className="widget-icon-bg cloud"><Cloud size={24} color="#F59E0B" fill="#F59E0B" /></div>
                                        <div className="widget-text">
                                            <span className="widget-label">Trời u ám</span>
                                            <span className="widget-value">23°</span>
                                        </div>
                                    </div>
                                    <div className="widget-divider"></div>
                                    <div className="widget-part">
                                        <div className="widget-icon-bg humidity"><Droplet size={24} color="#3B82F6" fill="#3B82F6" /></div>
                                        <div className="widget-text">
                                            <span className="widget-label">Độ ẩm</span>
                                            <span className="widget-value">67%</span>
                                        </div>
                                    </div>
                                </div>
                                <div className="dash-widget lights">
                                    <div className="widget-icon-bg light"><Lightbulb size={24} color="#FBBF24" fill="#FBBF24" /></div>
                                    <div className="widget-text">
                                        <span className="widget-label">Hệ thống đèn</span>
                                        <span className="widget-value">Đang bật</span>
                                    </div>
                                </div>
                                <div className="dash-widget music">
                                    <div className="widget-icon-bg music"><Music size={24} color="#EC4899" fill="#EC4899" /></div>
                                    <div className="widget-text">
                                        <span className="widget-label">Phát nhạc</span>
                                        <span className="widget-value">Phòng khách</span>
                                    </div>
                                </div>
                            </div>
                        </header>
                    )}

                    {activeTab === 'Statistics' ? (
                        <div className="dashboard-scroll-content">
                            <StatisticsView />
                        </div>
                    ) : selectedRoom ? (
                        <RoomDetailView
                            roomName={selectedRoom}
                            onBack={() => setSelectedRoom(null)}
                            onDeviceClick={handleDeviceClick}
                        />
                    ) : activeTab === 'Devices' ? (
                        <>
                            {deviceTabStep === 1 && <DevicesStep1 onContinue={() => setDeviceTabStep(2)} />}
                            {deviceTabStep === 2 && <DevicesStep2 onContinue={() => setDeviceTabStep(3)} onBack={() => setDeviceTabStep(1)} />}
                            {deviceTabStep === 3 && <DevicesStep3 onContinue={() => setDeviceTabStep(4)} onBack={() => setDeviceTabStep(2)} />}
                            {deviceTabStep === 4 && <DeviceDetailView deviceName={selectedDevice} roomName={selectedDeviceRoom} onBack={() => setDeviceTabStep(1)} />}
                        </>
                    ) : (
                        <>
                            {activeTab === 'Rooms' && dashboardView !== 'map' ? (
                                <div className="dashboard-scroll-content">
                                    <div className="map-view-header" style={{ marginTop: '20px' }}>
                                        <div className="map-view-title">
                                            <h3>Phòng của bạn <span className="count-badge">{rooms.length}</span></h3>
                                        </div>
                                        <div className="view-toggle-pill">
                                            <button className={`pill-btn ${dashboardView === 'map' ? 'active' : ''}`} onClick={() => setDashboardView('map')}>Sơ đồ</button>
                                            <button className={`pill-btn ${dashboardView !== 'map' ? 'active' : ''}`} onClick={() => setDashboardView('home')}>Danh sách</button>
                                        </div>
                                    </div>

                                    <div className="rooms-grid-layout">
                                        <DashboardRoomCard name="Phòng khách" devicesCount={4} image={ROOM_IMAGES["Phòng khách"]} onClick={() => setSelectedRoom("Phòng khách")} />
                                        <DashboardRoomCard name="Phòng ngủ" devicesCount={3} image={ROOM_IMAGES["Phòng ngủ"]} onClick={() => setSelectedRoom("Phòng ngủ")} />
                                        <DashboardRoomCard name="Nhà bếp" devicesCount={1} image={ROOM_IMAGES["Nhà bếp"]} onClick={() => setSelectedRoom("Nhà bếp")} />
                                        <DashboardRoomCard name="Phòng tắm" devicesCount={2} image={ROOM_IMAGES["Phòng tắm"]} onClick={() => setSelectedRoom("Phòng tắm")} />
                                    </div>
                                </div>
                            ) : (
                                <>
                                    {dashboardView === 'home' ? (
                                        <div className="dashboard-scroll-content">
                                            <div className="dashboard-section-header">
                                                <h3>Thiết bị của bạn <span className="count-badge">{connectedDevices.length}</span></h3>
                                            </div>

                                            <div className="dashboard-devices-grid">
                                                {connectedDevices.map((device, index) => {
                                                    // Hỗ trợ cả trường hợp device là String (Local cũ) và Object (API)
                                                    const isObject = typeof device === 'object' && device !== null;
                                                    const deviceName = isObject ? device.name : device;
                                                    const rawImage = isObject ? device.image : (DEVICES.find(d => d.name === deviceName)?.image || DEVICE_IMG_BASE);
                                                    const deviceImage = resolveDeviceImage(rawImage);
                                                    const roomName = isObject ? (device.roomName || "Chưa phân loại") : "Phòng khách";

                                                    const key = isObject ? device.id : `${deviceName}-${index}`;
                                                    const isOn = isObject ? device.isOn : false;

                                                    return (
                                                        <DashboardDeviceCard
                                                            key={key}
                                                            id={isObject ? device.id : null}
                                                            name={deviceName}
                                                            image={deviceImage}
                                                            room={roomName}
                                                            initialIsOn={isOn}
                                                        />
                                                    )
                                                })}
                                                {connectedDevices.length === 0 && <p className="no-devices-msg">Chưa có thiết bị nào được kết nối.</p>}
                                            </div>

                                            <div className="dashboard-bottom-grid">
                                                <div className="dash-card members-card">
                                                    <h3>Thành viên</h3>
                                                    <div className="members-list-row">
                                                        <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop" className="member-avatar" alt="m1" />
                                                        <img src="https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&auto=format&fit=crop" className="member-avatar" alt="m2" />
                                                        <img src="https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&auto=format&fit=crop" className="member-avatar" alt="m3" />
                                                        <img src="https://images.unsplash.com/photo-1552058544-f2b08422138a?w=100&auto=format&fit=crop" className="member-avatar" alt="m4" />
                                                        <button className="add-member-btn"><Plus size={20} /></button>
                                                    </div>
                                                </div>

                                                <div className="dash-card map-card" onClick={() => setDashboardView('map')}>
                                                    <div className="map-info">
                                                        <h3>Sơ đồ không gian</h3>
                                                        <p>Xem các phòng và tất cả thiết bị liên quan đến chúng.</p>
                                                    </div>
                                                    <div className="map-illustration">
                                                        <div className="map-rect r1"></div>
                                                        <div className="map-rect r2"></div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    ) : (
                                        <div className="dashboard-map-view">
                                            <div className="map-view-header">
                                                <div className="map-view-title">
                                                    <h3>Phòng của bạn <span className="count-badge">4</span></h3>
                                                </div>
                                                <div className="view-toggle-pill">
                                                    <button className={`pill-btn ${dashboardView === 'map' ? 'active' : ''}`} onClick={() => setDashboardView('map')}>Sơ đồ</button>
                                                    <button className={`pill-btn ${dashboardView !== 'map' ? 'active' : ''}`} onClick={() => setDashboardView('home')}>Danh sách</button>
                                                </div>
                                            </div>

                                            <div className="interactive-map-container">
                                                <div className="map-grid">
                                                    <div className="map-block bedroom" onClick={() => setSelectedRoom("Phòng ngủ")}>
                                                        <div className="block-content">
                                                            <Bed size={32} className="block-icon" />
                                                            <span className="block-name">Phòng ngủ</span>
                                                            <div className="block-badge"><div className="dot"></div> 3 thiết bị</div>
                                                        </div>
                                                    </div>
                                                    <div className="map-block livingroom" onClick={() => setSelectedRoom("Phòng khách")}>
                                                        <div className="block-content">
                                                            <Sofa size={36} className="block-icon" />
                                                            <span className="block-name">Phòng khách</span>
                                                            <div className="block-badge"><div className="dot"></div> 4 thiết bị</div>
                                                        </div>
                                                    </div>
                                                    <div className="map-block bathroom" onClick={() => setSelectedRoom("Phòng tắm")}>
                                                        <div className="block-content">
                                                            <Bath size={28} className="block-icon" />
                                                            <span className="block-name">Phòng tắm</span>
                                                            <div className="block-badge"><div className="dot"></div> 2 thiết bị</div>
                                                        </div>
                                                    </div>
                                                    <div className="map-block kitchen" onClick={() => setSelectedRoom("Nhà bếp")}>
                                                        <div className="block-content">
                                                            <UtensilsCrossed size={28} className="block-icon" />
                                                            <span className="block-name">Nhà bếp</span>
                                                            <div className="block-badge"><div className="dot"></div> 1 thiết bị</div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div className="map-devices-section">
                                                <div className="dashboard-section-header">
                                                    <h3>Thiết bị <span className="count-badge">12</span></h3>
                                                </div>
                                                <div className="map-devices-horizontal">
                                                    {DEVICES.slice(0, 4).map(dev => (
                                                        <div key={dev.name} className="mini-device-card">
                                                            <div className="mini-img-wrapper">
                                                                <img src={dev.image} alt={dev.name} />
                                                            </div>
                                                            <div className="mini-info">
                                                                <h4>{dev.name}</h4>
                                                                <p>Phòng khách</p>
                                                            </div>
                                                        </div>
                                                    ))}
                                                </div>
                                            </div>
                                        </div>
                                    )}
                                </>
                            )}
                        </>
                    )}
                </div>
            )}
        </main>
    );
}
