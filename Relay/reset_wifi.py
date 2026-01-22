#!/usr/bin/env python3
"""
Script để reset WiFi credentials trong ESP32
Chỉ xóa NVS partition, không xóa firmware
"""

import sys
import subprocess

def reset_wifi(port='COM3'):
    print("=" * 50)
    print("Reset WiFi Credentials trong ESP32")
    print("=" * 50)
    print()
    
    # Xóa toàn bộ flash (bao gồm NVS)
    print(f"Đang xóa flash trên port {port}...")
    try:
        subprocess.run(['idf.py', '-p', port, 'erase-flash'], check=True)
        print()
        print("✅ Đã xóa thành công!")
        print()
        print("Bước tiếp theo:")
        print(f"  idf.py -p {port} flash monitor")
        print()
    except subprocess.CalledProcessError as e:
        print(f"❌ Lỗi: {e}")
        sys.exit(1)
    except FileNotFoundError:
        print("❌ Không tìm thấy idf.py. Hãy chạy export.bat trước:")
        print("   %userprofile%\\esp\\esp-idf\\export.bat")
        sys.exit(1)

if __name__ == '__main__':
    port = sys.argv[1] if len(sys.argv) > 1 else 'COM3'
    reset_wifi(port)
