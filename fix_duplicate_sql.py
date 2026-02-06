#!/usr/bin/env python3
"""
Script xóa device trùng trực tiếp trong PostgreSQL
"""

import psycopg2

# PostgreSQL connection
DB_CONFIG = {
    "host": "dpg-d60qhuaqcgvc7383v9f0-a.singapore-postgres.render.com",
    "port": 5432,
    "database": "backend_led_v1t1",
    "user": "backend_user",
    "password": "M3xCF81IhImlsjvfhA7Ny5WMMgAO2IKj"
}

def fix_duplicates():
    print("🔧 Fixing duplicate devices in PostgreSQL...")
    
    try:
        # Connect to database
        print("\n[1/4] Connecting to database...")
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✅ Connected")
        
        # Find duplicates
        print("\n[2/4] Finding duplicates...")
        cursor.execute("""
            SELECT hardware_id, COUNT(*) as count, array_agg(id) as ids
            FROM devices
            GROUP BY hardware_id
            HAVING COUNT(*) > 1
        """)
        
        duplicates = cursor.fetchall()
        print(f"✅ Found {len(duplicates)} duplicate hardware_id(s)")
        
        if not duplicates:
            print("✅ No duplicates found!")
            return
        
        # Delete duplicates (keep first, delete rest)
        print("\n[3/4] Deleting duplicates...")
        total_deleted = 0
        
        for hw_id, count, ids in duplicates:
            print(f"\n   Hardware ID: {hw_id}")
            print(f"   Total devices: {count}")
            print(f"   Device IDs: {ids}")
            
            # Keep first ID, delete rest
            keep_id = ids[0]
            delete_ids = ids[1:]
            
            print(f"   Keeping ID: {keep_id}")
            print(f"   Deleting IDs: {delete_ids}")
            
            for delete_id in delete_ids:
                cursor.execute("DELETE FROM devices WHERE id = %s", (delete_id,))
                total_deleted += 1
                print(f"   ✅ Deleted device ID {delete_id}")
        
        # Commit changes
        print("\n[4/4] Committing changes...")
        conn.commit()
        print("✅ Changes committed")
        
        print(f"\n{'='*50}")
        print(f"✅ FIX COMPLETED!")
        print(f"{'='*50}")
        print(f"   Deleted: {total_deleted} duplicate(s)")
        print(f"{'='*50}")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    fix_duplicates()
