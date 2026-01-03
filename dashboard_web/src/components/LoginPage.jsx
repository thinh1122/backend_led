import React, { useState } from 'react';
import { Eye, EyeOff, Loader2 } from 'lucide-react'; // Thêm Loader icon
import loginPageImg from '../assets/loginpage.jpg';
import { authService } from '../services/api';

export default function LoginPage({ onLogin }) {
    const [showPassword, setShowPassword] = useState(false);
    const [isLoginMode, setIsLoginMode] = useState(true); // Toggle Login/Signup

    // Form State
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [isLoading, setIsLoading] = useState(false);

    const handleAuth = async () => {
        setError('');
        setIsLoading(true);
        try {
            let response;
            if (isLoginMode) {
                // Login
                response = await authService.login(email, password);
            } else {
                // Signup
                response = await authService.signup(email, password);
            }

            // Thành công
            const { token, email: userEmail } = response.data;
            const userFullName = userEmail.split('@')[0];

            // Lưu token
            localStorage.setItem('token', token);
            localStorage.setItem('email', userEmail);
            localStorage.setItem('fullName', userFullName);

            // Mock data setup (giữ lại logic cũ để App hoạt động mượt)
            localStorage.setItem('onboardingStep', '0');
            // Các mục khác sẽ được fetch từ API sau này

            // Báo cho App cha biết đã Login xong
            onLogin();

        } catch (err) {
            console.error("Auth Error:", err);
            // Hiển thị lỗi từ Server
            if (err.message) {
                setError(err.message);
            } else if (err.error) {
                setError(err.error);
            } else {
                setError("Có lỗi xảy ra, vui lòng thử lại!");
            }
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="login-container">
            <div className="login-left">
                <div className="login-visual-layer">
                    <div className="login-content-stack">
                        <img
                            src={loginPageImg}
                            alt="Smart Home Illustration"
                            className="login-bg-image"
                        />
                        <div className="login-tagline">
                            <h2>Sống tiện nghi cùng <br /> ngôi nhà thông minh 💡</h2>
                            <p>Quản lý tất cả thiết bị thông minh của bạn ở một nơi chỉ với vài cú chạm.</p>
                        </div>
                    </div>

                    <div className="onboarding-pagination">
                        <div className="p-dot"></div>
                        <div className="p-dot active"></div>
                        <div className="p-dot"></div>
                        <div className="p-dot"></div>
                    </div>
                </div>
            </div>

            <div className="login-right">
                <div className="login-form-container">
                    <div className="login-form-header">
                        <h1>{isLoginMode ? 'Đăng nhập' : 'Đăng ký'}</h1>
                        <p>{isLoginMode ? 'Chào mừng trở lại! Vui lòng nhập thông tin của bạn.' : 'Tạo tài khoản mới để bắt đầu.'}</p>
                    </div>

                    <div className="login-form-body">
                        {error && (
                            <div className="error-message" style={{ color: 'red', marginBottom: '10px', fontSize: '14px' }}>
                                {error}
                            </div>
                        )}

                        <div className="login-field">
                            <input
                                type="email"
                                placeholder="Email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                            />
                        </div>
                        <div className="login-field">
                            <input
                                type={showPassword ? "text" : "password"}
                                placeholder="Mật khẩu"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                            />
                            <button className="pw-visibility-toggle" onClick={() => setShowPassword(!showPassword)}>
                                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                            </button>
                        </div>

                        {isLoginMode && (
                            <div className="login-extra">
                                <label className="checkbox-wrap">
                                    <input type="checkbox" />
                                    <span>Ghi nhớ thông tin</span>
                                </label>
                            </div>
                        )}

                        <button className="btn-login-main" onClick={handleAuth} disabled={isLoading}>
                            {isLoading ? (
                                <><Loader2 className="animate-spin" size={20} style={{ marginRight: 8 }} /> Đang xử lý...</>
                            ) : (
                                isLoginMode ? 'Đăng nhập' : 'Đăng ký'
                            )}
                        </button>

                        {isLoginMode && (
                            <div className="pw-recovery">
                                <a href="#">Quên mật khẩu?</a>
                            </div>
                        )}

                        <div className="divider-or">
                            <span className="divider-text">hoặc</span>
                        </div>

                        <div className="social-login-list">
                            <button className="btn-social">
                                <span className="s-icon"><img src="https://www.svgrepo.com/show/475656/google-color.svg" alt="G" /></span>
                                <span className="s-divider"></span>
                                <span className="s-text">Đăng nhập bằng Google</span>
                            </button>
                            <button className="btn-social">
                                <span className="s-icon"><img src="https://www.svgrepo.com/show/475647/facebook-color.svg" alt="F" /></span>
                                <span className="s-divider"></span>
                                <span className="s-text">Đăng nhập bằng Facebook</span>
                            </button>
                            <button className="btn-social">
                                <span className="s-icon"><img src="https://www.svgrepo.com/show/511330/apple-173.svg" alt="A" /></span>
                                <span className="s-divider"></span>
                                <span className="s-text">Đăng nhập bằng Apple</span>
                            </button>
                        </div>

                        <div className="login-footer-promo">
                            {isLoginMode ? "Lần đầu tiên đến đây? " : "Bạn đã có tài khoản? "}
                            <span
                                className="link-action"
                                style={{ cursor: 'pointer' }}
                                onClick={() => {
                                    setIsLoginMode(!isLoginMode);
                                    setError('');
                                }}
                            >
                                {isLoginMode ? "Đăng ký miễn phí" : "Đăng nhập ngay"}
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}
