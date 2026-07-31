import pandas as pd
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

load_dotenv()

USERNAME = os.getenv("MYSQL_USER")
PASSWORD = os.getenv("MYSQL_PASSWORD")
HOST = os.getenv("MYSQL_HOST")
PORT = os.getenv("MYSQL_PORT")
DATABASE = os.getenv("MYSQL_DATABASE")

engine = create_engine(
    f"mysql+pymysql://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}"
)

# -----------------------------
# Files to Import
# -----------------------------

files = {
    "reviews": "D:/Retail Supply Chain Intelligence Platform/data/processed/reviews_clean.csv"
}

# -----------------------------
# Import Data
# -----------------------------
for table, path in files.items():
    print(f"Loading {table}...")

    df = pd.read_csv(path)

    # Convert all date/timestamp columns
    for col in df.columns:
        if "date" in col.lower() or "timestamp" in col.lower():
            df[col] = pd.to_datetime(df[col], errors="coerce")

    df.to_sql(
        name=table,
        con=engine,
        if_exists="append",
        index=False,
        chunksize=5000,
        method="multi"
    )

    print(f"✓ {table} imported successfully")

print("\nAll datasets imported successfully!")