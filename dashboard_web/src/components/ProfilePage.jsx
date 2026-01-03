import React from 'react';
import { Edit2 } from 'lucide-react';

export default function ProfilePage({ avatarUrl }) {
    return (
        <main className="settings-content">
            <h1>Hồ sơ</h1>

            <div className="settings-tabs">
                <div className="tab active">Thông tin tài khoản</div>
                <div className="tab">Đổi mật khẩu</div>
                <div className="tab">Thông báo</div>
                <div className="tab">Tùy chọn</div>
            </div>

            <div className="settings-form-container">
                <div className="profile-avatar-edit-section">
                    <div className="avatar-wrapper-large">
                        <img src={avatarUrl} alt="Kristin" />
                        <button className="edit-avatar-btn"><Edit2 size={16} /></button>
                    </div>
                </div>

                <div className="form-row">
                    <label>Họ và tên</label>
                    <input type="text" defaultValue="Kristin Jones" className="settings-input" />
                </div>

                <div className="form-row">
                    <label>Số điện thoại</label>
                    <div className="phone-input-wrapper">
                        <span className="flag-icon">🇩🇪</span>
                        <input type="text" defaultValue="+49 30 901820" className="settings-input" />
                    </div>
                </div>

                <div className="form-row">
                    <label>Email</label>
                    <input type="email" defaultValue="kristin@gmail.com" className="settings-input" />
                </div>
            </div>

            <div className="settings-action-bar">
                <span>Chỉnh sửa thông tin tài khoản của bạn</span>
                <button className="save-btn">Lưu cập nhật</button>
            </div>
        </main>
    );
}
