from config import fetch_data
import matplotlib.pyplot as plt
import seaborn as sns

# Query: Find top power users segmented by gender and age group
query = """
WITH user_activity AS (
    SELECT user_id, COUNT(DISTINCT receipt_id) AS total_receipts
    FROM transactions
    GROUP BY user_id
),
user_details AS (
    SELECT id, gender, 
           EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) AS age
    FROM users
    WHERE birth_date IS NOT NULL
)
SELECT 
    CASE 
        WHEN ud.age < 18 THEN 'Under 18'
        WHEN ud.age BETWEEN 18 AND 24 THEN '18-24'
        WHEN ud.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN ud.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN ud.age BETWEEN 45 AND 54 THEN '45-54'
        WHEN ud.age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+' 
    END AS age_group,
    ud.gender,
    SUM(ua.total_receipts) AS total_receipts
FROM user_activity ua
JOIN user_details ud ON ua.user_id = ud.id
GROUP BY age_group, ud.gender
ORDER BY total_receipts DESC;
"""

# Fetch data
df = fetch_data(query)

# Check if query was successful
if df is not None:
    print(df)  # Print results for debugging
    
    # Visualization
    plt.figure(figsize=(12, 6))
    sns.barplot(data=df, x="total_receipts", y="age_group", hue="gender", palette="viridis")
    plt.xlabel("Total Receipts Scanned")
    plt.ylabel("Age Group")
    plt.title("Fetch Users by Gender and Age Group")
    plt.legend(title="Gender")
    plt.show()
else:
    print("Query failed.")
    