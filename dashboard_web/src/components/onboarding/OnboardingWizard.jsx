import React, { useState } from 'react';
import {
    ArrowLeft, Search, Check, Plus, Trash2, Edit2, Tv,
    MoreHorizontal
} from 'lucide-react';

import {
    HOUSE_URL,
    ROOM_IMG,
    IC_HOME,
    DEVICES,
    DEVICE_IMG_BASE,
    IMAGES
} from '../../constants/dashboardConstants';

// Reusable components for onboarding
function StatChip({ label, active, type }) {
    return (
        <div className={`stat-chip ${type} ${active ? 'active' : ''}`}>
            <div className="status-dot"></div>
            <span>{label}</span>
        </div>
    );
}

function DeviceCard({ name, image, selected, connected, onSelect, onDelete, step }) {
    return (
        <div className={`device-card ${selected ? 'selected' : ''}`} onClick={onSelect}>
            <div className="device-image-area">
                <div className="deco-circle"></div>
                <img src={image} alt={name} />
            </div>

            <div className="device-card-footer">
                <div className="device-card-info">
                    <span className="device-name">{name}</span>
                    <div className="device-status-row">
                        <div className={`status-icon-box ${(connected && step >= 5) ? 'active' : ''}`}>
                            {(connected && step >= 5) ? <Check size={8} color="white" strokeWidth={4} /> : <div className="minus-line"></div>}
                        </div>
                        <span className="device-status-text">{(connected && step >= 5) ? 'đã kết nối' : 'chưa kết nối'}</span>
                    </div>
                </div>

                {!connected && (
                    <button
                        className="device-add-action"
                        onClick={(e) => {
                            e.stopPropagation();
                            onSelect();
                        }}
                    >
                        <Plus size={22} color="#3B82F6" strokeWidth={2.5} />
                    </button>
                )}

                {connected && (
                    <div className="device-connected-indicator" onClick={(e) => { e.stopPropagation(); onDelete(e); }}>
                        <Check size={16} color="white" strokeWidth={4} />
                    </div>
                )}
            </div>
        </div>
    );
}

export default function OnboardingWizard({
    step,
    setStep,
    rooms,
    setRooms,
    connectedDevices,
    setConnectedDevices
}) {
    const [selectedDevice, setSelectedDevice] = useState(null);
    const [searchQuery, setSearchQuery] = useState('');
    const [showAddRoomModal, setShowAddRoomModal] = useState(false);
    const [roomName, setRoomName] = useState('Phòng khách');
    const [roomSize, setRoomSize] = useState(20);
    const [roomUnit, setRoomUnit] = useState('m²');

    const aromaDiffuserImg = IMAGES.aromaDiffuser;
    const airConditionerImg = IMAGES.airConditioner;
    const humidifierImg = IMAGES.humidifier;
    const speakerImg = IMAGES.speaker;
    const smartLampImg = IMAGES.smartLamp;
    const smartLamp2Img = IMAGES.smartLamp2;

    const handleStep4Continue = () => {
        if (selectedDevice && !connectedDevices.includes(selectedDevice)) {
            setConnectedDevices([...connectedDevices, selectedDevice]);
        }
        setSelectedDevice(null);
        setStep(5);
    };

    const toggleDeviceConnection = (deviceName) => {
        if (connectedDevices.includes(deviceName)) {
            setConnectedDevices(connectedDevices.filter(d => d !== deviceName));
        } else {
            setConnectedDevices([...connectedDevices, deviceName]);
            setSelectedDevice(deviceName);
        }
    };

    const handleAddRoom = () => {
        setRooms([...rooms, { name: roomName, size: roomSize, unit: roomUnit }]);
        setShowAddRoomModal(false);
        setRoomName('Phòng khách');
        setRoomSize(20);
    };

    const filteredDevices = DEVICES.filter(device =>
        device.name.toLowerCase().includes(searchQuery.toLowerCase())
    );

    return (
        <>
            <header className="top-header">
                <button className="back-button" onClick={() => setStep(step - 1)}>
                    <ArrowLeft size={20} color="#fff" />
                </button>
                <div className="header-text">
                    {step === 4 ? (
                        <>
                            <h1>Liên kết thiết bị mới</h1>
                            <p>Kết nối với không gian của bạn</p>
                        </>
                    ) : step === 6 ? (
                        <>
                            <h1>Tạo không gian mới</h1>
                            <p>Xác nhận lựa chọn của bạn</p>
                        </>
                    ) : (
                        <>
                            <h1>Tạo không gian mới</h1>
                            <p>
                                {step === 1 ? "Thêm chi tiết đầu tiên" :
                                    step === 2 ? "Tổ chức không gian của bạn" :
                                        "Kết nối thiết bị của bạn"}
                            </p>
                        </>
                    )}
                </div>
                <div className="step-indicator">
                    Bước <span className="step-highlight">{step}</span>|6
                </div>
            </header>

            <div className="content-area">
                {/* STEP 1 CONTENT: Name & Image */}
                {step === 1 && (
                    <div className="step-content-centered">
                        <div className="large-house-image-container">
                            <img src={HOUSE_URL} alt="House Preview" className="large-house-image" />
                            <button className="image-edit-badge">
                                <Tv size={16} />
                            </button>
                        </div>
                        <div className="input-group">
                            <label>Tên ngôi nhà của bạn là gì?</label>
                            <input type="text" defaultValue="Nhà của tôi" className="text-input-lg" />
                        </div>
                        <div className="suggestions-group">
                            <p>Chưa có ý tưởng? Thử một trong những tên này.</p>
                            <div className="chips-row">
                                <button className="suggestion-chip">Nhà</button>
                                <button className="suggestion-chip">Văn phòng</button>
                                <button className="suggestion-chip">Nơi hạnh phúc</button>
                            </div>
                        </div>
                    </div>
                )}

                {/* STEP 2 CONTENT: Add Rooms */}
                {step === 2 && (
                    <>
                        <div className="house-card">
                            <div className="house-image-wrapper">
                                <img src={HOUSE_URL} alt="My Home" className="house-image" />
                            </div>
                            <div className="house-details">
                                <div className="house-title-row">
                                    <h2>Nhà của tôi</h2>
                                    <button className="edit-btn">
                                        <Edit2 size={14} color="#3B82F6" />
                                    </button>
                                </div>
                                <p className="house-address">11-5 Raddington Rd, London, UK</p>
                            </div>
                            <div className="house-stats">
                                <StatChip label={`${rooms.length} Phòng`} type="rooms" active={rooms.length > 0} />
                                <StatChip label="0 Thiết bị" type="devices" />
                                <StatChip label="0 Thành viên" type="members" />
                            </div>
                        </div>

                        <div className="add-rooms-section">
                            <div className="section-header-row">
                                <div className="section-intro">
                                    <h3>Thêm phòng</h3>
                                    <p>Tổ chức không gian của bạn bằng cách thêm và tùy chỉnh các phòng</p>
                                </div>
                                <button className="add-room-trigger-top" onClick={() => setShowAddRoomModal(true)}>
                                    <Plus size={18} />
                                    <span>Thêm phòng mới</span>
                                </button>
                            </div>

                            {rooms.length === 0 ? (
                                <div className="empty-rooms-visual">
                                    <div className="house-sketch-bg">
                                        <img src={IC_HOME} alt="Empty Room" />
                                    </div>
                                    <p className="empty-rooms-text">Bạn chưa thêm phòng nào</p>
                                </div>
                            ) : (
                                <div className="rooms-grid">
                                    {rooms.map((room, index) => (
                                        <div key={index} className="room-card">
                                            <div className="room-card-image-area">
                                                <div className="deco-circle"></div>
                                                <img src={ROOM_IMG} alt={room.name} />
                                            </div>
                                            <div className="room-card-footer">
                                                <div className="room-card-info">
                                                    <span className="room-name">{room.name}</span>
                                                    <span className="room-size">{room.size} {room.unit || 'm²'}</span>
                                                </div>
                                                <button className="room-more-btn">
                                                    <MoreHorizontal size={18} color="#94A3B8" />
                                                </button>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}

                            {showAddRoomModal && (
                                <div className="room-modal-overlay">
                                    <div className="room-modal">
                                        <header className="modal-header">
                                            <h3>Add a room</h3>
                                            <button className="close-modal" onClick={() => setShowAddRoomModal(false)}>
                                                <Plus size={24} style={{ transform: 'rotate(45deg)' }} />
                                            </button>
                                        </header>
                                        <div className="modal-content">
                                            <div className="room-image-preview">
                                                <img src={ROOM_IMG} alt="Room" />
                                                <button className="image-edit-icon"><Tv size={16} /></button>
                                            </div>
                                            <div className="modal-input-group">
                                                <label>Tên phòng của bạn là gì?</label>
                                                <input
                                                    type="text"
                                                    value={roomName}
                                                    onChange={(e) => setRoomName(e.target.value)}
                                                    className="modal-text-input"
                                                />
                                            </div>
                                            <div className="modal-input-group">
                                                <label>Diện tích phòng?</label>
                                                <div className="size-unit-selector">
                                                    <div
                                                        className={`unit-radio-chip ${roomUnit === 'm²' ? 'active' : ''}`}
                                                        onClick={() => setRoomUnit('m²')}
                                                    >
                                                        <div className="radio-circle"><div className="radio-inner"></div></div>
                                                        <span>size in m²</span>
                                                    </div>
                                                    <div
                                                        className={`unit-radio-chip ${roomUnit === 'ft²' ? 'active' : ''}`}
                                                        onClick={() => setRoomUnit('ft²')}
                                                    >
                                                        <div className="radio-circle"><div className="radio-inner"></div></div>
                                                        <span>size in ft²</span>
                                                    </div>
                                                </div>
                                                <div className="size-display">
                                                    <span className="size-number">{roomSize}</span>
                                                    <span className="size-unit">{roomUnit}</span>
                                                </div>
                                                <div className="ruler-wrapper">
                                                    <div className="ruler-ticks-bg">
                                                        {[...Array(31)].map((_, i) => (
                                                            <div key={i} className={`tick-line ${i % 10 === 0 ? 'large' : i % 5 === 0 ? 'medium' : ''}`}></div>
                                                        ))}
                                                    </div>
                                                    <input
                                                        type="range"
                                                        min="1"
                                                        max="100"
                                                        value={roomSize}
                                                        onChange={(e) => setRoomSize(parseInt(e.target.value))}
                                                        className="ruler-range-input"
                                                    />
                                                </div>
                                            </div>
                                            <button className="modal-continue-btn" onClick={handleAddRoom}>
                                                Tiếp tục
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            )}
                        </div>
                    </>
                )}

                {/* STEP 3 & 5 CONTENT: Link Devices (Grid) */}
                {(step === 3 || step === 5) && (
                    <>
                        <div className="house-card">
                            <div className="house-image-wrapper">
                                <img src={HOUSE_URL} alt="My Home" className="house-image" />
                            </div>
                            <div className="house-details">
                                <div className="house-title-row">
                                    <h2>Nhà của tôi</h2>
                                    <button className="edit-btn">
                                        <Edit2 size={14} color="#3B82F6" />
                                    </button>
                                </div>
                                <p className="house-address">11-5 Raddington Rd, London, UK</p>
                            </div>
                            <div className="house-stats">
                                <StatChip label={`${rooms.length} Phòng`} type="rooms" active />
                                <StatChip label={`${connectedDevices.length} Thiết bị`} type="devices" active={connectedDevices.length > 0} />
                                <StatChip label="0 Thành viên" type="members" />
                            </div>
                        </div>

                        <div className="devices-section">
                            <div className="devices-header">
                                <div className="devices-title">
                                    <h3>Liên kết thiết bị thông minh</h3>
                                    <p>Thiết bị hiện có ở gần</p>
                                </div>
                                <div className="search-bar-container">
                                    <div className="search-bar">
                                        <input
                                            type="text"
                                            placeholder="Tìm kiếm"
                                            value={searchQuery}
                                            onChange={(e) => setSearchQuery(e.target.value)}
                                        />
                                        <Search size={18} className="search-icon" />
                                    </div>
                                </div>
                            </div>

                            <div className="devices-grid">
                                {DEVICES.map(device => (
                                    <DeviceCard
                                        key={device.name}
                                        name={device.name}
                                        image={device.image}
                                        selected={selectedDevice === device.name}
                                        connected={connectedDevices.includes(device.name)}
                                        onSelect={() => toggleDeviceConnection(device.name)}
                                        onDelete={(e) => toggleDeviceConnection(device.name)}
                                        step={step}
                                    />
                                ))}
                            </div>
                        </div>
                    </>
                )}

                {/* STEP 4 CONTENT: Configure Device */}
                {step === 4 && (
                    <div className="step-content-centered">
                        <div className="glow-circle-container">
                            <img
                                src={
                                    DEVICES.find(d => d.name === selectedDevice)?.image || DEVICE_IMG_BASE
                                }
                                alt="Device"
                                className="circle-device-img"
                            />
                        </div>
                        <div className="input-group">
                            <label>Tên thiết bị của bạn là gì?</label>
                            <input type="text" defaultValue={selectedDevice || "Smart Lamp"} className="text-input-lg" />
                        </div>
                        <div className="suggestions-group">
                            <p>Thiết bị được đặt ở đâu?</p>
                            <div className="chips-row">
                                <button className="suggestion-chip active-yellow">Phòng khách</button>
                                <button className="suggestion-chip">Phòng bếp</button>
                                <button className="suggestion-chip">Phòng ngủ</button>
                                <button className="suggestion-chip">Phòng tắm</button>
                            </div>
                        </div>
                    </div>
                )}

                {/* STEP 6 CONTENT: Confirmation Summary */}
                {step === 6 && (
                    <>
                        <div className="house-card">
                            <div className="house-image-wrapper">
                                <img src={HOUSE_URL} alt="My Home" className="house-image" />
                            </div>
                            <div className="house-details">
                                <div className="house-title-row">
                                    <h2>Nhà của tôi</h2>
                                    <button className="edit-btn">
                                        <Edit2 size={14} color="#3B82F6" />
                                    </button>
                                </div>
                                <p className="house-address">11-5 Raddington Rd, London, UK</p>
                            </div>
                            <div className="house-stats">
                                <StatChip label={`${rooms.length} Phòng`} type="rooms" active />
                                <StatChip label={`${connectedDevices.length} Thiết bị`} type="devices" active />
                                <StatChip label="2 Thành viên" type="members" active />
                            </div>
                        </div>

                        <div className="summary-grid">
                            <div className="summary-card">
                                <div className="summary-header">
                                    <h3>Phòng của bạn</h3>
                                    <span className="summary-count">4</span>
                                </div>
                                <div className="summary-list">
                                    <div className="summary-item">
                                        <div className="summary-item-left">
                                            <div className="summary-img-wrapper">
                                                <img src="https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=100&auto=format&fit=crop" alt="Living Room" className="summary-img" />
                                            </div>
                                            <div className="summary-info">
                                                <h4>Phòng khách</h4>
                                                <p>20 m²</p>
                                            </div>
                                        </div>
                                        <button className="summary-action-btn"><Trash2 size={16} /></button>
                                    </div>
                                    {/* ... other summary items ... */}
                                </div>
                            </div>

                            <div className="summary-card">
                                <div className="summary-header">
                                    <h3>Thiết bị của bạn</h3>
                                    <span className="summary-count">{connectedDevices.length}</span>
                                </div>
                                <div className="summary-list">
                                    {connectedDevices.map(idxName => {
                                        const dev = DEVICES.find(d => d.name === idxName);
                                        return (
                                            <div className="summary-item" key={idxName}>
                                                <div className="summary-item-left">
                                                    <div className="summary-img-wrapper">
                                                        <img src={dev ? dev.image : DEVICE_IMG_BASE} alt={idxName} className="summary-img" />
                                                    </div>
                                                    <div className="summary-info">
                                                        <h4>{idxName}</h4>
                                                        <p>Phòng khách</p>
                                                    </div>
                                                </div>
                                                <button
                                                    className="summary-action-btn"
                                                    onClick={() => toggleDeviceConnection(idxName)}
                                                >
                                                    <Trash2 size={16} />
                                                </button>
                                            </div>
                                        );
                                    })}
                                    {connectedDevices.length === 0 && (
                                        <p style={{ color: '#94A3B8', fontSize: '0.9rem', padding: '10px 0' }}>Chưa có thiết bị nào</p>
                                    )}
                                </div>
                            </div>

                            {/* MEMBERS CARD */}
                            <div className="summary-card full-width">
                                <div className="summary-header">
                                    <h3>Thành viên</h3>
                                    <span className="summary-count">2</span>
                                </div>
                                <div className="summary-list" style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
                                    <div className="summary-item" style={{ flex: '1 1 300px', borderBottom: 'none', border: '1px solid #F1F5F9', borderRadius: '12px', padding: '12px' }}>
                                        <div className="summary-item-left">
                                            <div className="member-avatar-wrapper">
                                                <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop" alt="Albert" className="member-avatar" />
                                                <div className="active-dot"></div>
                                            </div>
                                            <div className="summary-info">
                                                <h4>Albert Flores</h4>
                                                <p>albert.flores@gmail.com</p>
                                            </div>
                                        </div>
                                        <button className="summary-action-btn"><Trash2 size={16} /></button>
                                    </div>
                                    <div className="summary-item" style={{ flex: '1 1 300px', borderBottom: 'none', border: '1px solid #F1F5F9', borderRadius: '12px', padding: '12px' }}>
                                        <div className="summary-item-left">
                                            <div className="member-avatar-wrapper">
                                                <img src="https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&auto=format&fit=crop" alt="Annette" className="member-avatar" />
                                                <div className="active-dot"></div>
                                            </div>
                                            <div className="summary-info">
                                                <h4>Annette Black</h4>
                                                <p>annette.black@gmail.com</p>
                                            </div>
                                        </div>
                                        <button className="summary-action-btn"><Trash2 size={16} /></button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </>
                )}

                <div className="action-footer">
                    <p className="footer-hint">
                        {step === 1 && "Đặt tên cho không gian mới"}
                        {step === 2 && "Sắp xếp không gian của bạn bằng cách thêm phòng"}
                        {(step === 3 || step === 5) && "Thêm tất cả thiết bị và chuyển sang bước tiếp theo."}
                        {step === 4 && "Tùy chỉnh và liên kết thiết bị mới của bạn"}
                        {step === 6 && "Kiểm tra lại thông tin và bắt đầu với không gian mới."}
                    </p>
                    <div className="footer-buttons">
                        {step !== 6 && <button className="btn-skip">Bỏ qua</button>}
                        <button
                            className={`btn-continue ${((step === 3 || step === 5) && !selectedDevice && connectedDevices.length === 0) || (step === 2 && rooms.length === 0) ? 'disabled' : 'active'}`}
                            disabled={((step === 3 || step === 5) && !selectedDevice && connectedDevices.length === 0) || (step === 2 && rooms.length === 0)}
                            onClick={() => {
                                if (step === 4) {
                                    handleStep4Continue();
                                } else if ((step === 3 || step === 5) && selectedDevice) {
                                    setStep(4);
                                } else if (step === 1) {
                                    setStep(2);
                                } else if (step === 2) {
                                    setStep(3);
                                } else if (step === 5 && !selectedDevice) {
                                    setStep(6);
                                } else if (step === 6) {
                                    setStep(7);
                                } else {
                                    setStep(step + 1);
                                }
                            }}
                        >
                            {(step === 5 && !selectedDevice) ? "Tiếp tục" : step === 6 ? "Hoàn tất" : "Tiếp tục"}
                        </button>
                    </div>
                </div>
            </div>
        </>
    );
}
