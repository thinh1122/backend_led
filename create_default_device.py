#!/usr/bin/env python3
"""
Script tạo device mặc định cho ESP32 với HTTP mode
Chạy sau khi backend local đã khởi động
"""

import requests
import json

# Cấu hình backend LOCAL
BACKEND_URL = "http://192.168.1.74:8080/api"

# Thông tin mặc định
DEFAULT_USER = {
    "email": "admin@gmail.com",
    "password": "admin123",
    "fullName": "Administrator"
}

DEFAULT_HOUSE = {
    "name": "Smart Home",
    "roomNames": ["Phòng khách"]  # Tạo room cùng lúc với house
}

DEFAULT_DEVICE = {
    "name": "Thiết bị ESP32",
    "hardwareId": "thiet_bi_esp32",
    "type": "SMART_PLUG",
    "isCamera": False
}

def create_default_setup():
    """Tạo user, house, room, device mặc định qua API"""
    
    print("🚀 Creating default setup for ESP32 HTTP mode...")
    print(f"   Backend: {BACKEND_URL}")
    
    try:
        # 1. Register user
        print("\n[1/4] Registering user...")
        register_response = requests.post(
            f"{BACKEND_URL}/auth/register",
            json={
                "email": DEFAULT_USER["email"],
                "password": DEFAULT_USER["password"],
                "fullName": DEFAULT_USER["fullName"]
            },
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        if register_response.status_code == 200:
            print("✅ User registered successfully")
        else:
            print(f"⚠️ User registration: {register_response.status_code} (might already exist)")
        
        # 2. Login to get token
        print("\n[2/4] Logging in...")
        login_response = requests.post(
            f"{BACKEND_URL}/auth/login",
            json={
                "email": DEFAULT_USER["email"],
                "password": DEFAULT_USER["password"]
            },
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        if login_response.status_code != 200:
            print(f"❌ Login failed: {login_response.status_code}")
            print(f"   Response: {login_response.text}")
            return
        
        token = login_response.json().get("token")
        print(f"✅ Login successful, token: {token[:20]}...")
        
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {token}"
        }
        
        # 3. Create house
        print("\n[3/4] Creating house...")
        house_response = requests.post(
            f"{BACKEND_URL}/houses",
            json=DEFAULT_HOUSE,
            headers=headers,
            timeout=10
        )
        
        if house_response.status_code not in [200, 201]:
            print(f"❌ House creation failed: {house_response.status_code}")
            print(f"   Response: {house_response.text}")
            return
        
        house_id = house_response.json().get("id")
        rooms = house_response.json().get("rooms", [])
        if not rooms:
            print("❌ No rooms created")
            return
        room_id = rooms[0].get("id")
        print(f"✅ House created, ID: {house_id}")
        print(f"✅ Room created, ID: {room_id}")
        
        # 4. Create device
        print("\n[4/4] Creating device...")
        device_response = requests.post(
            f"{BACKEND_URL}/devices",
            json={
                **DEFAULT_DEVICE,
                "roomId": room_id
            },
            headers=headers,
            timeout=10
        )
        
        if device_response.status_code not in [200, 201]:
            print(f"❌ Device creation failed: {device_response.status_code}")
            print(f"   Response: {device_response.text}")
            return
        
        device_id = device_response.json().get("id")
        print(f"✅ Device created, ID: {device_id}")
        
        print("\n" + "="*50)
        print("✅ SETUP COMPLETED SUCCESSFULLY!")
        print("="*50)
        print(f"   House ID: {house_id}")
        print(f"   Room ID: {room_id}")
        print(f"   Device ID: {device_id}")
        print(f"   Hardware ID: {DEFAULT_DEVICE['hardwareId']}")
        print(f"   ESP32 IP: 192.168.1.75")
        print(f"   Backend: {BACKEND_URL}")
        print("\n🎯 Login credentials:")
        print(f"   Email: {DEFAULT_USER['email']}")
        print(f"   Password: {DEFAULT_USER['password']}")
        print("="*50)
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Network error: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

if __name__ == "__main__":
    create_default_setup()