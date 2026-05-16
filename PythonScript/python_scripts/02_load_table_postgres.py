import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine
from pathlib import Path

# 1. Load environment variables
load_dotenv()

user = os.getenv("DB_USER")
password = os.getenv("DB_PASSWORD")
host = os.getenv("DB_HOST")
port = os.getenv("DB_PORT")
db = os.getenv("DB_NAME")

# 2. Create database connection
engine = create_engine(
    f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}"
)

# 3. Load Excel file
BASE_DIR = Path(__file__).resolve().parent.parent.parent
file_path = BASE_DIR / "Data" / "raw_data" / "FintechTrainee.xlsx"

df = pd.read_excel(file_path)

print("Excel loaded successfully")
print(df.head())

# 4. Convert column names in to appropriate format 

df.columns = (
    df.columns
    .str.strip()               # remove spaces
    .str.lower()               # convert to lowercase
    .str.replace(" ", "_")     # replace spaces with _
)

print("Cleaned columns:", df.columns)

# 5. Load into PostgreSQL
table_name = "fintech"

df.to_sql(
    table_name,
    engine,
    if_exists="replace",
    index=False
)

print(f"Data successfully loaded into PostgreSQL table: {table_name}")