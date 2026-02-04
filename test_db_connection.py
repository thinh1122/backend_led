import psycopg2
import os

# Test database connection
try:
    # Get connection details from environment or use defaults
    db_url = os.getenv('DB_URL', 'postgresql://localhost:5432/smart_home_db')
    db_user = os.getenv('DB_USERNAME', 'postgres')
    db_pass = os.getenv('DB_PASSWORD', '1')
    
    # Parse URL to get host, port, database
    if db_url.startswith('jdbc:postgresql://'):
        db_url = db_url.replace('jdbc:postgresql://', 'postgresql://')
    
    print(f"Attempting to connect to: {db_url}")
    print(f"Username: {db_user}")
    
    conn = psycopg2.connect(
        host="localhost",  # Change this to your actual host
        port="5432",
        database="smart_home_db",  # Change this to your actual database
        user=db_user,
        password=db_pass
    )
    
    print("✅ Database connection successful!")
    conn.close()
    
except Exception as e:
    print(f"❌ Database connection failed: {e}")