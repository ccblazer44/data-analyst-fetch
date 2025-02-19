from config import get_db_connection

# Test database connection
conn = get_db_connection()
if conn:
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM users;")  # Test query
    result = cursor.fetchone()
    print(f"Users table has {result[0]} records.")
    
    cursor.close()
    conn.close()
