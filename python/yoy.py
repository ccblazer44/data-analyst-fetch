from config import fetch_data
import matplotlib.pyplot as plt

# Query: Year-over-Year User Growth
query = """
WITH yearly_users AS (
    SELECT EXTRACT(YEAR FROM created_date) AS year,
           COUNT(id) AS new_users
    FROM users
    GROUP BY year
),
cumulative_users AS (
    SELECT year, 
           new_users,
           SUM(new_users) OVER (ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS total_users_prior
    FROM yearly_users
)
SELECT year,
       new_users,
       COALESCE(total_users_prior, 0) AS total_users_prior,
       ROUND(
           (new_users * 100.0) / NULLIF(total_users_prior, 0), 2
       ) AS yoy_growth_percentage
FROM cumulative_users
ORDER BY year ASC;
"""

# Fetch data
df = fetch_data(query)

# Check if query was successful
if df is not None and not df.empty:
    print(df)  # Print results for debugging

    # Visualization
    fig, ax1 = plt.subplots(figsize=(10, 5))

    # Plot total users prior (cumulative users)
    ax1.set_xlabel("Year")
    ax1.set_ylabel("Total Users", color="blue")
    ax1.plot(df["year"], df["total_users_prior"], marker="o", linestyle="-", color="blue", label="Total Users")
    ax1.tick_params(axis="y", labelcolor="blue")
    
    # Create a second y-axis for YoY Growth
    ax2 = ax1.twinx()
    ax2.set_ylabel("YoY Growth %", color="green")
    ax2.plot(df["year"], df["yoy_growth_percentage"], marker="s", linestyle="--", color="green", label="YoY Growth %")
    ax2.tick_params(axis="y", labelcolor="green")

    # Title and legend
    plt.title("Year-over-Year User Growth & Total Users")
    fig.tight_layout()
    plt.grid(True, linestyle="--", alpha=0.5)
    
    # Show plot
    plt.show()
else:
    print("Query failed or returned no data.")
