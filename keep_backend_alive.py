#!/usr/bin/env python3
"""
Script để giữ backend Render.com không bị sleep
Chạy script này trong background để ping backend mỗi 10 phút
"""
import requests
import time
from datetime import datetime

BACKEND_URL = "https://backend-led-xaxn.onrender.com/api/auth/login"
PING_INTERVAL = 600  # 10 phút (giây)

def ping_backend():
    try:
        response = requests.post(
            BACKEND_URL,
            json={"email": "ping@test.com", "password": "ping"},
            timeout=30
        )
        status = "✅ OK" if response.status_code in [200, 400, 403] else f"❌ {response.status_code}"
        print(f"[{datetime.now().strftime('%H:%M:%S')}] Backend ping: {status}")
        return True
    except Exception as e:
        print(f"[{datetime.now().strftime('%H:%M:%S')}] ❌ Error: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Starting backend keep-alive service...")
    print(f"📡 Pinging {BACKEND_URL} every {PING_INTERVAL//60} minutes")
    print("Press Ctrl+C to stop\n")
    
    while True:
        ping_backend()
        time.sleep(PING_INTERVAL)
