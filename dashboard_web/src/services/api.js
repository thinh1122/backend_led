import axios from 'axios';

// Cấu hình URL Backend (Nếu chạy Localhost)
// Nếu deploy thì thay bằng URL thật
const BASE_URL = 'http://localhost:8080/api';

const api = axios.create({
    baseURL: BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Tự động thêm Token vào Header nếu có
api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('token');
        if (token) {
            config.headers['Authorization'] = `Bearer ${token}`;
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// Xử lý lỗi trả về từ Server
api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response) {
            // Lỗi từ Server (4xx, 5xx)
            // Nếu 401 thì có thể Auto Logout (tuỳ chọn)
            if (error.response.status === 401) {
                // localStorage.removeItem('token');
                // window.location.reload();
            }
            return Promise.reject(error.response.data);
        } else if (error.request) {
            // Lỗi không kết nối được Server
            return Promise.reject({ message: "Không thể kết nối đến Server!" });
        } else {
            return Promise.reject({ message: "Lỗi không xác định!" });
        }
    }
);

export const authService = {
    login: (email, password) => api.post('/auth/login', { email, password }),
    signup: (email, password) => api.post('/auth/signup', { email, password }),

    // Thêm các hàm khác sau này
    getMyDevices: () => api.get('/devices'),
    toggleDevice: (id, isOn) => api.post(`/devices/${id}/toggle?isOn=${isOn}`),
};

export default api;
