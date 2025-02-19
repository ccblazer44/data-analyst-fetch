from config import fetch_data

# Test query to count users
query = "SELECT COUNT(*) AS total_users FROM users;"

df = fetch_data(query)

if df is not None:
    print(df)
else:
    print("Query failed.")
