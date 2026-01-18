# 🚀 Build iOS/Android với GitHub Actions

## ✅ Đã setup GitHub Actions để build tự động

### 📱 Build được gì?

- **Android APK** (signed với debug key)
- **iOS IPA** (unsigned - cần sign sau)

### 🔄 Khi nào build?

GitHub Actions sẽ tự động build khi:
1. Push code lên branch `main`
2. Tạo Pull Request
3. Hoặc bạn trigger thủ công

### 🎯 Cách trigger build thủ công:

1. Vào repo GitHub: https://github.com/thinh1122/smarthome
2. Click tab **Actions**
3. Chọn workflow **"Build Android & iOS"**
4. Click nút **"Run workflow"** → **"Run workflow"**
5. Đợi 5-10 phút để build xong

### 📥 Tải file build:

Sau khi build xong:
1. Vào tab **Actions**
2. Click vào workflow run (màu xanh = success)
3. Scroll xuống phần **Artifacts**
4. Tải file:
   - `android-apk` - File APK Android
   - `ios-ipa-unsigned` - File IPA iOS (chưa sign)

### 📊 Giới hạn miễn phí:

GitHub Actions miễn phí cho public repo:
- ✅ **Unlimited minutes** cho public repo
- ✅ macOS runners (để build iOS)
- ✅ Linux runners (để build Android)

### 🔐 Sign iOS IPA (sau khi tải về):

File IPA từ GitHub Actions là **unsigned**. Để cài lên iPhone:

#### Cách 1: Dùng AltStore (Miễn phí)
1. Tải AltStore: https://altstore.io/
2. Cài AltStore lên iPhone
3. Dùng AltStore để sign và cài IPA
4. Cần renew mỗi 7 ngày

#### Cách 2: Dùng Sideloadly (Miễn phí)
1. Tải Sideloadly: https://sideloadly.io/
2. Kết nối iPhone với máy tính
3. Chọn file IPA và sign với Apple ID
4. Cài lên iPhone

#### Cách 3: Dùng Xcode (Cần Mac)
1. Mở Xcode
2. Window → Devices and Simulators
3. Kéo thả IPA vào device

### 🛠️ Workflows có sẵn:

#### 1. `build-all.yml` - Build cả Android và iOS
- Chạy khi push/PR lên main
- Build APK và IPA
- Upload artifacts

#### 2. `build-ios.yml` - Chỉ build iOS
- Chạy khi cần
- Nhanh hơn vì chỉ build iOS

### 📝 Lưu ý:

1. **iOS IPA không sign**: Không thể cài trực tiếp lên iPhone, cần sign trước
2. **Android APK debug**: Đã sign với debug key, cài được ngay
3. **Artifacts tồn tại 30 ngày**: Sau đó tự động xóa
4. **Build time**: 
   - Android: ~5-7 phút
   - iOS: ~8-12 phút

### 🔧 Customize build:

Để thay đổi cấu hình build, edit file:
- `.github/workflows/build-all.yml`
- `.github/workflows/build-ios.yml`

### 🐛 Troubleshooting:

#### Build failed?
1. Xem logs trong Actions tab
2. Kiểm tra Flutter version
3. Kiểm tra dependencies trong pubspec.yaml

#### iOS build lỗi?
- Thường do signing issues
- Workflow này build `--no-codesign` nên không cần certificate

#### Android build lỗi?
- Kiểm tra Gradle version
- Kiểm tra Android SDK version

### 📚 Tài liệu:

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [AltStore Guide](https://altstore.io/)

### 💡 Tips:

1. **Tạo Release**: Sau khi build xong, có thể tạo GitHub Release và attach APK/IPA
2. **Auto versioning**: Có thể setup auto increment version number
3. **TestFlight**: Nếu có Apple Developer Account ($99/năm), có thể deploy lên TestFlight

---

**Made with ❤️ using GitHub Actions**
