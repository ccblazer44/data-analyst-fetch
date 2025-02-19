import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from config import fetch_data

# Streamlit Page Configuration
st.set_page_config(page_title="Dips & Salsa Brand Analysis", layout="wide")

# Query: Find top brands in Dips & Salsa
query = """
SELECT p.brand, 
       SUM(t.quantity * t.sale) AS total_sales,
       COUNT(DISTINCT t.receipt_id) AS receipts_scanned
FROM transactions t
JOIN products p ON t.barcode = p.barcode
WHERE p.category_2 = 'Dips & Salsa'
GROUP BY p.brand
ORDER BY total_sales DESC;
"""

# Fetch data
df = fetch_data(query)

# Streamlit UI
st.title("Dips & Salsa Brand Analysis")
st.write("Analyze the top-performing brands in the Dips & Salsa category.")

# Dropdown to filter by metric
metric = st.selectbox("Select Metric:", ["Total Sales", "Receipts Scanned"])

# Choose the right metric
if metric == "Total Sales":
    df = df.sort_values(by="total_sales", ascending=False)
    x_col = "total_sales"
    x_label = "Total Sales ($)"
else:
    df = df.sort_values(by="receipts_scanned", ascending=False)
    x_col = "receipts_scanned"
    x_label = "Receipts Scanned"

# Plot the data
fig, ax = plt.subplots(figsize=(10, 5))
sns.barplot(data=df, y="brand", x=x_col, palette="viridis", ax=ax)
ax.set_xlabel(x_label, fontsize=12)
ax.set_ylabel("Brand", fontsize=12)
ax.set_title(f"Top Dips & Salsa Brands by {metric}", fontsize=14)

# Set smaller font size for brand names
ax.tick_params(axis="y", labelsize=5)  # Adjusts font size of y-axis labels

st.pyplot(fig)

# Display data
st.dataframe(df)
