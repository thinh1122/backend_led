#!/usr/bin/env python3
"""
Script xóa device trùng lặp trong PostgreSQL
"""

import requests

BACKEND_URL = "http://192.168.1.72:8080/api"

USER = {
    "email": "admin@gmail.com",
    "password": "admin123"
}

def clean_duplicates():
    print("🧹 Cleaning duplicate devices...")
    
    try:
        # 1. Login
        print("\n[1/3] Logging in...")
        login_response = requests.post(
            f"{BACKEND_URL}/auth/login",
            json=USER,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        if login_response.status_code != 200:
            print(f"❌ Login failed: {login_response.status_code}")
            return
        
        token = login_response.json().get("token")
        print(f"✅ Login successful")
        
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {token}"
        }
        
        # 2. Get all devices
        print("\n[2/3] Getting all devices...")
        devices_response = requests.get(
            f"{BACKEND_URL}/devices",
            headers=headers,
            timeout=10
        )
        
        if devices_response.status_code != 200:
            print(f"❌ Failed to get devices: {devices_response.status_code}")
            return
        
        devices = devices_response.json()
        print(f"✅ Found {len(devices)} devices")
        
        # 3. Delete duplicates (keep only first one)
        print("\n[3/3] Deleting duplicates...")
        hardware_ids = {}
        deleted_count = 0
        
        for device in devices:
            hw_id = device.get("hardwareId")
            device_id = device.get("id")
            
            if hw_id in hardware_ids:
                # Duplicate found, delete it
                print(f"   Deleting duplicate device ID {device_id} (hardware_id: {hw_id})")
                delete_response = requests.delete(
                    f"{BACKEND_URL}/devices/{device_id}",
                    headers=headers,
                    timeout=10
                )
                if delete_response.status_code in [200, 204]:
                    deleted_count += 1
                    print(f"   ✅ Deleted device ID {device_id}")
                else:
                    print(f"   ⚠️ Failed to delete device ID {device_id}: {delete_response.status_code}")
            else:
                hardware_ids[hw_id] = device_id
                print(f"   Keeping device ID {device_id} (hardware_id: {hw_id})")
        
        print(f"\n{'='*50}")
        print(f"✅ CLEANUP COMPLETED!")
        print(f"{'='*50}")
        print(f"   Deleted: {deleted_count} duplicate(s)")
        print(f"   Remaining: {len(hardware_ids)} unique device(s)")
        print(f"{'='*50}")
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Network error: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

if __name__ == "__main__":
    clean_duplicates()
