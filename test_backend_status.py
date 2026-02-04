#!/usr/bin/env python3
"""
Script test trạng thái backend cloud
"""
import requests
import json
from datetime import datetime

def test_backend(url, name):
    print(f"\n🔍 Testing {name}: {url}")
    print("-" * 50)
    
    endpoints = [
        ("Root", ""),
        ("API Root", "/api"),
        ("Health Check", "/actuator/health"),
        ("Auth Login", "/api/auth/login"),
        ("Houses", "/api/houses"),
    ]
    
    for endpoint_name, path in endpoints:
        full_url = url + path
        try:
            response = requests.get(full_url, timeout=10)
            status_icon = "✅" if response.status_code < 400 else "❌"
            print(f"{status_icon} {endpoint_name:12} [{response.status_code}] {full_url}")
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, dict) and len(data) < 5:
                        print(f"   Response: {data}")
                except:
                    print(f"   Response: {response.text[:100]}...")
                    
        except requests.exceptions.Timeout:
            print(f"⏰ {endpoint_name:12} [TIMEOUT] {full_url}")
        except requests.exceptions.ConnectionError:
            print(f"🔌 {endpoint_name:12} [CONNECTION_ERROR] {full_url}")
        except Exception as e:
            print(f"❌ {endpoint_name:12} [ERROR] {full_url} - {e}")

def main():
    print(f"🚀 Backend Status Check - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    backends = [
        ("Backend NEW", "https://backend-led-1.onrender.com"),
        ("Backend OLD", "https://backend-led-xaxn.onrender.com"),
        ("Backend ALT1", "https://backend-led.onrender.com"),
        ("Backend ALT2", "https://backend-led-new.onrender.com"),
    ]
    
    for name, url in backends:
        test_backend(url, name)
    
    print(f"\n✅ Test completed at {datetime.now().strftime('%H:%M:%S')}")

if __name__ == "__main__":
    main()