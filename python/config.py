import psycopg2
import pandas as pd
from sqlalchemy import create_engine
import os

# Load database credentials from environment variables (optional security measure)
DB_HOST = os.getenv("DB_HOST", "localhost")  # Change to your PostgreSQL host
DB_NAME = os.getenv("DB_NAME", "bleezy")  # Your database name
DB_USER = os.getenv("DB_USER", "bleezy")  # Your PostgreSQL username
DB_PASSWORD = os.getenv("DB_PASSWORD", "")  # Your PostgreSQL password
DB_PORT = os.getenv("DB_PORT", "5432")  # Default PostgreSQL port

# Function to create a database connection
def get_db_connection():
    try:
        engine = create_engine(f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")
        print("Successfully connected to the database!")
        return engine
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return None


# Function to fetch query results as a Pandas DataFrame
def fetch_data(query):
    engine = get_db_connection()
    if engine:
        try:
            df = pd.read_sql(query, engine)
            return df
        except Exception as e:
            print(f"Error running query: {e}")
            return None