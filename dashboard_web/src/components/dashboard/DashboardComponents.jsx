import React, { useState, useEffect } from 'react';
import {
    ArrowLeft, Edit2, Droplet, ChevronDown,
    Play, Pause, SkipBack, SkipForward,
    Volume2, Battery, Radio, Plus,
    ChevronLeft, ChevronRight, Calendar,
    TrendingUp, TrendingDown
} from 'lucide-react';
import { ROOM_IMAGES, IMAGES } from '../../constants/dashboardConstants';
import { authService } from '../../services/api';

export function DashboardRoomCard({ name, devicesCount, image, onClick }) {
    return (
        <div className="dash-room-card" onClick={onClick}>
            <div className="room-card-deco">
                <div className="deco-layer d1"></div>
                <div className="deco-layer d2"></div>
                <div className="deco-layer d3"></div>
                <div className="deco-layer d4"></div>
            </div>
            <button className="room-edit-btn" onClick={(e) => e.stopPropagation()}>
                <Edit2 size={16} />
            </button>
            <div className="room-visual">
                <img src={image} alt={name} />
            </div>
            <div className="room-content">
                <h4>{name}</h4>
                <div className="room-badge">
                    <div className="dot"></div>
                    <span>{devicesCount} thiết bị</span>
                </div>
            </div>
        </div>
    );
}

export function DashboardDeviceCard({ id, name, image, room, initialIsOn = false }) {
    const [isOn, setIsOn] = useState(initialIsOn);

    useEffect(() => {
        setIsOn(initialIsOn);
    }, [initialIsOn]);


    const handleToggle = async (e) => {
        e.stopPropagation(); // Avoid triggering card click if exists
        const newState = !isOn;
        setIsOn(newState); // Optimistic update
        console.log(`Toggling device ${id} to ${newState}`);

        if (id) {
            try {
                await authService.toggleDevice(id, newState);
                console.log("Toggle success");
            } catch (error) {
                console.error("Toggle failed:", error);
                setIsOn(!newState); // Revert if failed
            }
        } else {
            console.warn("No ID provided for device, skipping API call");
        }
    };

    return (
        <div className="dash-device-card">
            <div className="dash-device-img-area">
                <div className="deco-circle"></div>
                <img src={image} alt={name} />
            </div>
            <div className="dash-device-card-footer">
                <div className="dash-device-info">
                    <h4>{name}</h4>
                    <p>{room}</p>
                </div>
                <div className={`toggle-switch-wrapper ${isOn ? 'on' : ''}`} onClick={handleToggle}>
                    <div className="thumb-circle"></div>
                </div>
            </div>
        </div>
    );
}

export function RoomDetailView({ roomName, onBack, onDeviceClick }) {
    return (
        <div className="room-detail-view">
            <div className="room-detail-hero" style={{ backgroundImage: `url(${ROOM_IMAGES[roomName]})` }}>
                <div className="room-detail-overlay"></div>

                <header className="room-detail-header">
                    <button className="room-back-btn" onClick={onBack}>
                        <ArrowLeft size={20} />
                    </button>
                    <div className="room-breadcrumb">
                        <span className="bc-parent">Nhà của tôi</span>
                        <h2 className="bc-current">{roomName}</h2>
                    </div>
                </header>

                {/* Hotspots */}
                <div className="hotspot hs-tv" style={{ top: '40%', left: '30%' }}></div>
                <div className="hotspot hs-lamp active" style={{ top: '35%', left: '46%' }}></div>
                <div className="hotspot hs-guitar" style={{ top: '55%', left: '65%' }}></div>
                <div className="hotspot hs-table" style={{ top: '75%', left: '78%' }}></div>

                <div className="room-bottom-content">
                    <div className="room-devices-row">
                        <div className="room-device-card active">
                            <div className="rd-image-container">
                                <img src={IMAGES.smartLamp} alt="Smart Lamp" />
                            </div>
                            <div className="rd-info">
                                <h4>Smart Lamp</h4>
                                <p>{roomName}</p>
                            </div>
                            <div className="rd-toggle active">
                                <div className="rd-toggle-thumb"></div>
                            </div>
                        </div>

                        <div
                            className="room-device-card"
                            onClick={() => onDeviceClick && onDeviceClick('Speaker', roomName)}
                            style={{ cursor: 'pointer' }}
                        >
                            <div className="rd-image-container">
                                <img src={IMAGES.speaker} alt="Speaker" />
                            </div>
                            <div className="rd-info">
                                <h4>Speaker</h4>
                                <p>{roomName}</p>
                            </div>
                            <div className="rd-toggle">
                                <div className="rd-toggle-thumb"></div>
                            </div>
                        </div>

                        <div className="room-device-card">
                            <div className="rd-image-container">
                                <img src={IMAGES.aromaDiffuser} alt="Aroma Diffuser" />
                            </div>
                            <div className="rd-info">
                                <h4>Aroma Diffuser</h4>
                                <p>{roomName}</p>
                            </div>
                            <div className="rd-toggle">
                                <div className="rd-toggle-thumb"></div>
                            </div>
                        </div>

                        <div className="room-device-card">
                            <div className="rd-image-container">
                                <img src={IMAGES.humidifier} alt="Humidifier" />
                            </div>
                            <div className="rd-info">
                                <h4>Humidifier</h4>
                                <p>{roomName}</p>
                            </div>
                            <div className="rd-toggle">
                                <div className="rd-toggle-thumb"></div>
                            </div>
                        </div>
                    </div>

                    <div className="room-stats-footer">
                        <div className="room-stat-item">
                            <div className="stat-icon-row">
                                <Droplet size={20} color="#F59E0B" />
                                <span>Nhiệt độ hiện tại trong {roomName}</span>
                            </div>
                            <span className="stat-value">25°</span>
                        </div>
                        <div className="stat-v-divider"></div>
                        <div className="room-stat-item">
                            <div className="stat-icon-row">
                                <Droplet size={20} color="#3B82F6" />
                                <span>Độ ẩm hiện tại trong {roomName}</span>
                            </div>
                            <span className="stat-value">67%</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}


export function DevicesStep1({ onContinue, showFooter = true }) {
    const [selectedFilters, setSelectedFilters] = useState(['Tất cả']);
    const filters = ['Tất cả', 'Phòng khách', 'Phòng bếp', 'Phòng ngủ', 'Phòng tắm'];

    const initialScenes = [
        { name: 'Cà phê sáng', time: 'Hằng ngày | 08:15 AM - 09:00 AM', status: false },
        { name: 'Xem phim đêm', time: 'Thứ 2, Thứ 6 | 08:00 PM - 10:00 PM', status: true },
        { name: 'Ngủ', time: 'Hằng ngày | 12:00 PM - 08:00 AM', status: true },
        { name: 'Sinh nhật Kristin', time: '30 tháng 7 | 07:00 PM - 10:00 PM', status: false },
    ];

    const [scenes, setScenes] = useState(initialScenes);

    const toggleScene = (index) => {
        const newScenes = [...scenes];
        newScenes[index].status = !newScenes[index].status;
        setScenes(newScenes);
    };

    return (
        <div className="device-wizard-layout step-1">
            <header className="wizard-top-header">
                <div className="wizard-header-left">
                    <button className="wizard-back-btn">
                        <ArrowLeft size={20} />
                    </button>
                    <div className="wizard-title-group">
                        <span className="wizard-subtitle">Thiết bị</span>
                        <h2>Tất cả ngữ cảnh</h2>
                    </div>
                </div>
                <div className="wizard-filters-row">
                    {filters.map(filter => (
                        <button
                            key={filter}
                            className={`filter-pill ${selectedFilters.includes(filter) ? 'active' : ''}`}
                            onClick={() => setSelectedFilters([filter])}
                        >
                            {filter}
                        </button>
                    ))}
                </div>
            </header>

            <div className="wizard-content-area">
                <div className="wizard-section-header">
                    <div className="ws-text">
                        <h3>Thêm phòng</h3>
                        <p>Tổ chức không gian của bạn bằng cách thêm và tùy chỉnh các phòng</p>
                    </div>
                    <button className="add-new-scene-btn" onClick={onContinue}>
                        <Plus size={18} />
                        <span>Thêm ngữ cảnh mới</span>
                    </button>
                </div>

                <div className="scenes-selection-grid">
                    {scenes.map((scene, idx) => (
                        <div key={scene.name} className={`scene-select-card ${scene.status ? 'active' : ''}`}>
                            <div className="scene-card-info">
                                <h4>{scene.name}</h4>
                                <p>{scene.time}</p>
                            </div>
                            <div
                                className={`toggle-switch-wrapper mini ${scene.status ? 'on' : ''}`}
                                onClick={() => toggleScene(idx)}
                            >
                                <div className="thumb-circle"></div>
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            {showFooter && (
                <footer className="action-footer flush-wizard">
                    <p className="footer-hint">Thêm tất cả các phòng và chuyển sang bước tiếp theo.</p>
                    <div className="footer-buttons">
                        <button className="btn-skip">Bỏ qua</button>
                        <button className="btn-continue" onClick={onContinue}>Tiếp tục</button>
                    </div>
                </footer>
            )}
        </div>
    );
}

export function DevicesStep2({ onContinue, onBack }) {
    const [scheduleType, setScheduleType] = useState('Custom date');
    const [selectedDates, setSelectedDates] = useState([3, 4, 10, 11, 17, 18, 24, 25, 31]);

    const weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    const daysInMonth = Array.from({ length: 31 }, (_, i) => i + 1);

    return (
        <div className="device-wizard-layout step-2">
            <header className="wizard-top-header">
                <div className="wizard-header-left">
                    <button className="wizard-back-btn" onClick={onBack}>
                        <ArrowLeft size={20} />
                    </button>
                    <div className="wizard-title-group">
                        <span className="wizard-subtitle">Tạo ngữ cảnh mới</span>
                        <h2>Lịch trình</h2>
                    </div>
                </div>
                <div className="wizard-step-indicator">
                    <span>Bước</span>
                    <strong>2 | 3</strong>
                </div>

                {/* Floating Preview Card - Moved inside header for better overlap positioning */}
                <div className="scenario-preview-card">
                    <div className="sp-image">
                        <img src={IMAGES.livingDetail} alt="Xem phim" />
                    </div>
                    <div className="sp-info">
                        <div className="sp-title-row">
                            <h4>Xem phim đêm</h4>
                            <Edit2 size={16} color="#3B82F6" cursor="pointer" />
                        </div>
                        <p className="sp-schedule">Thứ 4, Thứ 5 | 11:15 AM - 01:15 PM</p>
                    </div>
                    <div className="sp-badges">
                        <div className="sp-badge room">
                            <div className="dot"></div>
                            <span>4 Phòng</span>
                        </div>
                        <div className="sp-badge device">
                            <div className="dot"></div>
                            <span>3 Thiết bị</span>
                        </div>
                    </div>
                </div>
            </header>

            <div className="wizard-content-area">
                <div className="schedule-config-section">
                    <div className="schedule-header-row">
                        <div className="section-intro">
                            <h3>Lịch trình</h3>
                            <p>Bạn muốn ngữ cảnh này lặp lại bao lâu một lần?</p>
                        </div>

                        <div className="schedule-pills">
                            {['Hằng ngày', 'Ngày trong tuần', 'Tùy chọn ngày'].map(type => (
                                <button
                                    key={type}
                                    className={`sch-pill ${scheduleType === (type === 'Tùy chọn ngày' ? 'Custom date' : type) ? 'active' : ''}`}
                                    onClick={() => setScheduleType(type === 'Tùy chọn ngày' ? 'Custom date' : type)}
                                >
                                    {type}
                                </button>
                            ))}
                        </div>
                    </div>

                    <div className="schedule-main-grid">
                        {/* Calendar Card */}
                        <div className="calendar-card">
                            <div className="calendar-header">
                                <div className="cal-title">
                                    <h4>Tháng 5 2023</h4>
                                    <p>Chọn các ngày mong muốn</p>
                                </div>
                                <div className="cal-nav">
                                    <button><ChevronLeft size={20} /></button>
                                    <button><ChevronRight size={20} /></button>
                                </div>
                            </div>
                            <div className="calendar-grid">
                                {weekDays.map(day => (
                                    <div key={day} className="grid-label">{day}</div>
                                ))}
                                {daysInMonth.map(day => (
                                    <div
                                        key={day}
                                        className={`grid-day ${selectedDates.includes(day) ? 'selected' : ''}`}
                                        onClick={() => {
                                            if (selectedDates.includes(day)) {
                                                setSelectedDates(selectedDates.filter(d => d !== day));
                                            } else {
                                                setSelectedDates([...selectedDates, day]);
                                            }
                                        }}
                                    >
                                        <span className="day-num">{day}</span>
                                        <span className="day-name">{weekDays[(day + 5) % 7]}</span>
                                    </div>
                                ))}
                            </div>
                        </div>

                        {/* Time Config Card */}
                        <div className="time-config-card">
                            <div className="tc-header">
                                <h4>Thời gian hoạt động</h4>
                                <p>Chọn khoảng thời gian mong muốn</p>
                            </div>

                            <div className="time-pick-rows">
                                <div className="time-row">
                                    <span className="row-label">Bật lúc</span>
                                    <div className="time-display-box">
                                        <span className="time-val">11 : 15</span>
                                    </div>
                                    <div className="am-pm-toggle">
                                        <button className="active">AM</button>
                                        <button>PM</button>
                                    </div>
                                </div>

                                <div className="time-row">
                                    <span className="row-label">Tắt lúc</span>
                                    <div className="time-display-box">
                                        <span className="time-val">01 : 15</span>
                                    </div>
                                    <div className="am-pm-toggle">
                                        <button>AM</button>
                                        <button className="active">PM</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <footer className="action-footer flush-wizard">
                <p className="footer-hint">Tùy chỉnh ngữ cảnh mới của bạn</p>
                <div className="footer-buttons">
                    <button className="btn-skip" onClick={onBack}>Hủy bỏ</button>
                    <button className="btn-continue" onClick={onContinue}>Tiếp tục</button>
                </div>
            </footer>
        </div>
    );
}

export function DevicesStep3({ onContinue, onBack }) {
    const [selectedDevice, setSelectedDevice] = useState('Loa');
    const [isOn, setIsOn] = useState(true);
    const [volume, setVolume] = useState(70);
    const [scheduleActive, setScheduleActive] = useState(true);

    const devices = [
        { id: 'lamp', name: 'Đèn thông minh', room: 'Phòng khách', image: IMAGES.smartLamp },
        { id: 'speaker', name: 'Loa', room: 'Phòng khách', image: IMAGES.speaker },
        { id: 'humidifier', id_vn: 'humidifier', name: 'Máy tạo ẩm', room: 'Phòng khách', image: IMAGES.humidifier },
    ];

    return (
        <div className="device-wizard-layout step-3">
            <header className="wizard-top-header">
                <div className="wizard-header-left">
                    <button className="wizard-back-btn" onClick={onBack}>
                        <ArrowLeft size={20} />
                    </button>
                    <div className="wizard-title-group">
                        <span className="wizard-subtitle">Chỉnh sửa ngữ cảnh</span>
                        <h2>Thiết bị</h2>
                    </div>
                </div>
                <div className="wizard-step-indicator">
                    <span>Bước</span>
                    <strong>3 | 3</strong>
                </div>

                {/* Floating Preview Card */}
                <div className="scenario-preview-card">
                    <div className="sp-image">
                        <img src={IMAGES.livingDetail} alt="Kỷ niệm" />
                    </div>
                    <div className="sp-info">
                        <div className="sp-title-row">
                            <h4>Kỷ niệm 30 năm</h4>
                            <Edit2 size={16} color="#3B82F6" cursor="pointer" />
                        </div>
                        <p className="sp-schedule">Thứ 4, Thứ 5 | 11:15 AM - 01:15 PM</p>
                    </div>
                    <div className="sp-badges">
                        <div className="sp-badge room">
                            <div className="dot"></div>
                            <span>1 Phòng</span>
                        </div>
                        <div className="sp-badge device">
                            <div className="dot"></div>
                            <span>3 Thiết bị</span>
                        </div>
                    </div>
                </div>
            </header>

            <div className="wizard-content-area">
                <div className="step3-main-section">
                    <div className="step3-header-row">
                        <div className="section-intro">
                            <h3>Thiết bị</h3>
                            <p>Tùy chỉnh cách mỗi thiết bị tham gia ngữ cảnh này</p>
                        </div>
                        <button className="add-device-inline-btn">
                            <Plus size={18} />
                            <span>Thêm thiết bị mới</span>
                        </button>
                    </div>

                    <div className="step3-grid-layout">
                        {/* Left Column: Device selection cards */}
                        <div className="step3-device-list">
                            {devices.map(dev => (
                                <div
                                    key={dev.id}
                                    className={`step3-dev-card ${selectedDevice === dev.name ? 'active' : ''}`}
                                    onClick={() => setSelectedDevice(dev.name)}
                                >
                                    <div className="sdc-img">
                                        <img src={dev.image} alt={dev.name} />
                                    </div>
                                    <div className="sdc-info">
                                        <h4>{dev.name}</h4>
                                        <p>{dev.room}</p>
                                    </div>
                                    {selectedDevice === dev.name && (
                                        <div className="sdc-pointer-arrow"></div>
                                    )}
                                </div>
                            ))}
                        </div>

                        {/* Right Column: Device control panel */}
                        <div className="step3-config-panel">
                            <div className="config-item">
                                <span className="conf-label">Trạng thái</span>
                                <div className={`toggle-switch-wrapper large ${isOn ? 'on' : ''}`} onClick={() => setIsOn(!isOn)}>
                                    <div className="thumb-circle"></div>
                                    <span className="toggle-label">{isOn ? 'BẬT' : 'TẮT'}</span>
                                </div>
                            </div>

                            <div className="config-item volume">
                                <span className="conf-label">Âm lượng</span>
                                <div className="step3-volume-control">
                                    <div className="vol-slider-track">
                                        <div className="vol-icon-start">
                                            <Volume2 size={18} color="white" />
                                        </div>
                                        <div className="vol-bars-container">
                                            {[...Array(20)].map((_, i) => (
                                                <div
                                                    key={i}
                                                    className={`vol-step-bar ${i / 20 * 100 < volume ? 'active' : ''}`}
                                                ></div>
                                            ))}
                                        </div>
                                        <span className="vol-pct">{volume}%</span>
                                    </div>
                                </div>
                            </div>

                            <div className="config-divider"></div>

                            <div className="config-item schedule-toggle">
                                <div className="conf-text">
                                    <span className="conf-label">Đặt lịch trình</span>
                                    <p>Chọn khoảng thời gian mong muốn</p>
                                </div>
                                <div className={`toggle-switch-wrapper large ${scheduleActive ? 'on' : ''}`} onClick={() => setScheduleActive(!scheduleActive)}>
                                    <div className="thumb-circle"></div>
                                    <span className="toggle-label">{scheduleActive ? 'BẬT' : 'TẮT'}</span>
                                </div>
                            </div>

                            <div className="time-pick-rows">
                                <div className="time-row">
                                    <span className="row-label">Bật lúc</span>
                                    <div className="time-display-box">
                                        <span className="time-val">11 : 15</span>
                                    </div>
                                    <div className="am-pm-toggle">
                                        <button className="active">AM</button>
                                        <button>PM</button>
                                    </div>
                                </div>

                                <div className="time-row">
                                    <span className="row-label">Tắt lúc</span>
                                    <div className="time-display-box">
                                        <span className="time-val">01 : 15</span>
                                    </div>
                                    <div className="am-pm-toggle">
                                        <button>AM</button>
                                        <button className="active">PM</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <footer className="action-footer flush-wizard">
                <p className="footer-hint">Tùy chỉnh ngữ cảnh mới của bạn</p>
                <div className="footer-buttons">
                    <button className="btn-skip" onClick={onBack}>Hủy bỏ</button>
                    <button className="btn-continue" onClick={onContinue}>Tiếp tục</button>
                </div>
            </footer>
        </div>
    );
}

export function DeviceDetailView({ deviceName = "Speaker", roomName = "Living room", onBack }) {
    const [isOn, setIsOn] = useState(true);
    const [volume, setVolume] = useState(70);

    return (
        <div className="device-detail-container">
            <div className="device-detail-left">
                <header className="device-header">
                    <button className="device-back-btn" onClick={onBack}>
                        <ArrowLeft size={20} />
                    </button>
                    <div className="device-title-box">
                        <span className="device-cat">{roomName}</span>
                        <h3>{deviceName}</h3>
                    </div>
                </header>

                <div className="device-main-visual">
                    <div className="concentric-circles">
                        <div className="circle c1"></div>
                        <div className="circle c2"></div>
                        <div className="circle c3"></div>
                    </div>
                    <div className="large-device-img-wrapper">
                        <img src={IMAGES.speaker} alt={deviceName} />
                    </div>
                </div>

                <div className="device-controls-list">
                    <div className="control-row">
                        <span className="row-label">Status</span>
                        <div className={`toggle-switch-wrapper large-detail ${isOn ? 'on' : ''}`} onClick={() => setIsOn(!isOn)}>
                            <span className="toggle-label">{isOn ? 'ON' : 'OFF'}</span>
                            <div className="thumb-circle"></div>
                        </div>
                    </div>

                    <div className="control-row">
                        <span className="row-label">Battery</span>
                        <div className="battery-status">
                            <span className="battery-value">90%</span>
                            <div className="battery-icon-wrapper">
                                <Battery size={20} color="#84CC16" />
                            </div>
                        </div>
                    </div>

                    <div className="control-row volume">
                        <span className="row-label">Volume</span>
                        <div className="step3-volume-control">
                            <div className="vol-slider-track">
                                <div className="vol-icon-start">
                                    <Volume2 size={18} color="white" />
                                </div>
                                <div className="vol-bars-container">
                                    {[...Array(20)].map((_, i) => (
                                        <div
                                            key={i}
                                            className={`vol-step-bar ${i / 20 * 100 < volume ? 'active' : ''}`}
                                        ></div>
                                    ))}
                                </div>
                                <span className="vol-pct">{volume}%</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div className="device-detail-right">
                <div className="home-selector-standalone">
                    <div className="hs-inner">
                        <div className="hs-avatar">
                            <img src={IMAGES.home} alt="My Home" />
                        </div>
                        <span>My Home</span>
                        <ChevronDown size={16} color="#475569" />
                    </div>
                </div>

                <div className="spotify-widget">
                    <div className="widget-header">
                        <div className="w-info">
                            <h4>Spotify</h4>
                            <p>{roomName}</p>
                        </div>
                        <ChevronDown size={18} color="#94A3B8" />
                    </div>

                    <div className="album-art-wrapper">
                        <img src={IMAGES.livingDetail} alt="Album Art" className="flipped-art" />
                    </div>

                    <div className="player-controls">
                        <div className="progress-container">
                            <div className="progress-bar">
                                <div className="progress-fill" style={{ width: '60%' }}></div>
                                <div className="progress-knob" style={{ left: '60%' }}></div>
                            </div>
                            <span className="time-display">2:45 min</span>
                        </div>

                        <div className="player-info-row">
                            <div className="song-meta">
                                <h5>As it was</h5>
                                <p>Harry Styles</p>
                            </div>
                            <div className="transport-btns">
                                <button className="transport-btn"><SkipBack size={20} color="#3B82F6" /></button>
                                <button className="transport-btn play-pause"><Pause size={20} fill="white" color="white" /></button>
                                <button className="transport-btn"><SkipForward size={20} color="#3B82F6" /></button>
                            </div>
                        </div>
                    </div>
                </div>

                <div className="scenes-widget">
                    <div className="widget-header">
                        <h4>Scenes <span className="cat-count">3</span></h4>
                    </div>
                    <div className="scenes-list">
                        <div className="scene-item">
                            <div className="scene-info">
                                <h5>Morning coffee</h5>
                                <p>Everyday | 08:15 AM - 09:00 AM</p>
                            </div>
                            <div className="toggle-switch-wrapper mini">
                                <div className="thumb-circle"></div>
                            </div>
                        </div>
                        <div className="scene-item active">
                            <div className="scene-info">
                                <h5>Movie Night</h5>
                                <p>Mon, Fri | 08:00 PM - 10:00 PM</p>
                            </div>
                            <div className="toggle-switch-wrapper mini on">
                                <div className="thumb-circle"></div>
                            </div>
                        </div>
                        <div className="scene-item">
                            <div className="scene-info">
                                <h5>32th Birthday Kristin</h5>
                                <p>July 30th | 07:00 PM - 10:00 PM</p>
                            </div>
                            <div className="toggle-switch-wrapper mini">
                                <div className="thumb-circle"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

export function StatRoomCard({ name, devicesCount, image, consumption }) {
    return (
        <div className="stat-room-card">
            <div className="stat-room-visual">
                <div className="room-card-deco mini">
                    <div className="deco-layer d1"></div>
                    <div className="deco-layer d2"></div>
                </div>
                <img src={image} alt={name} />
            </div>

            <div className="stat-room-bottom">
                <div className="stat-room-left">
                    <h4>{name}</h4>
                    <div className="stat-room-badge">
                        <div className="sr-icon"></div>
                        <span>{devicesCount} thiết bị</span>
                    </div>
                </div>

                <div className="stat-room-middle">
                    <div className="stat-room-divider"></div>
                </div>

                <div className="stat-room-right">
                    <span className="num">{consumption}</span>
                    <span className="unit">kw</span>
                </div>
            </div>
        </div>
    );
}

export function StatisticsView() {
    const [activeFilter, setActiveFilter] = useState("Tuần");

    return (
        <div className="statistics-view-container">
            <div className="stats-main-card">
                <div className="stats-card-header">
                    <div className="stats-title-group">
                        <button className="stats-back-btn">
                            <ArrowLeft size={20} />
                        </button>
                        <div className="stats-titles">
                            <span className="stats-sub">Thống kê</span>
                            <h3>Tiêu thụ điện năng</h3>
                        </div>
                    </div>
                    <div className="stats-time-filters">
                        {["Hôm nay", "Tuần", "Tháng", "Năm", "Quý"].map(f => (
                            <button
                                key={f}
                                className={`time-pill ${activeFilter === f ? 'active' : ''}`}
                                onClick={() => setActiveFilter(f)}
                            >
                                {f}
                            </button>
                        ))}
                    </div>
                </div>

                <div className="stats-chart-area">
                    {/* Background Waves */}
                    <div className="chart-bg-waves">
                        <svg viewBox="0 0 800 300" preserveAspectRatio="none">
                            <path d="M0,150 Q200,50 400,150 T800,150" fill="none" stroke="rgba(255,255,255,0.03)" strokeWidth="1" />
                            <path d="M0,180 Q200,80 400,180 T800,180" fill="none" stroke="rgba(255,255,255,0.02)" strokeWidth="1" />
                        </svg>
                    </div>

                    <div className="chart-y-axis">
                        <span>20 kW</span>
                        <span>15 kW</span>
                        <span>10 kW</span>
                        <span>5 kW</span>
                        <span>0 kW</span>
                    </div>

                    <div className="chart-visual-container">
                        {/* Grid Lines */}
                        <div className="chart-grid-lines">
                            {[...Array(5)].map((_, i) => <div key={i} className="grid-line"></div>)}
                        </div>

                        {/* Interactive Highlight */}
                        <div className="chart-highlight-bar" style={{ left: '57%' }}>
                            <div className="highlight-tooltip">
                                <span>17 kW</span>
                                <div className="tooltip-arrow"></div>
                            </div>
                        </div>

                        {/* Main Line */}
                        <svg className="main-chart-svg" viewBox="0 0 700 250" preserveAspectRatio="none">
                            <path
                                d="M0,200 C50,180 100,160 150,140 C200,130 250,160 300,170 C350,180 400,80 450,50 C500,40 550,150 600,140 C650,130 700,200 750,190"
                                fill="none"
                                stroke="#3B82F6"
                                strokeWidth="4"
                                strokeLinecap="round"
                            />
                            <circle cx="450" cy="50" r="6" fill="#3B82F6" stroke="white" strokeWidth="3" />
                        </svg>
                    </div>

                    <div className="chart-x-axis">
                        <span>M</span>
                        <span>T</span>
                        <span>W</span>
                        <span className="active">T</span>
                        <span>F</span>
                        <span>S</span>
                        <span>S</span>
                    </div>

                    {/* Summary Cards */}
                    <div className="stats-side-summaries">
                        <div className="summ-card">
                            <span className="summ-label">Tuần này</span>
                            <div className="summ-main">
                                <span className="summ-val">50</span>
                                <span className="summ-unit">kW</span>
                            </div>
                            <div className="summ-trend up">
                                <TrendingUp size={14} />
                                <span>+7.45%</span>
                            </div>
                        </div>
                        <div className="summ-card">
                            <span className="summ-label">Tổng tiêu hao</span>
                            <div className="summ-main">
                                <span className="summ-val">30.2</span>
                                <span className="summ-unit">kW</span>
                            </div>
                            <div className="summ-trend down">
                                <TrendingDown size={14} />
                                <span>-3.35%</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div className="your-rooms-section">
                <div className="section-header">
                    <h3>Phòng của bạn <span className="count-badge">4</span></h3>
                </div>
                <div className="stat-rooms-grid">
                    <StatRoomCard name="Phòng khách" devicesCount={4} image={IMAGES.livingroom} consumption="20" />
                    <StatRoomCard name="Phòng ngủ" devicesCount={4} image={IMAGES.bedroom} consumption="20" />
                    <StatRoomCard name="Phòng tắm" devicesCount={4} image={IMAGES.bathroom} consumption="20" />
                    <StatRoomCard name="Phòng bếp" devicesCount={4} image={IMAGES.kitchenroom} consumption="20" />
                </div>
            </div>
        </div>
    );
}
