import sqlite3
from sqlite3 import Connection

# Local includes
from constants import DATABASE_NAME, DATABASE_DIR, DATABASE_SCHEMA_DIR

def init() -> None:
    if not DATABASE_SCHEMA_DIR.exists():
        print(f"Error: {DATABASE_SCHEMA_DIR} not found.")
        return

    print(f"Connecting to {DATABASE_NAME}")

    try:
        connection: Connection = sqlite3.connect(DATABASE_DIR)

        with open(DATABASE_SCHEMA_DIR, 'r') as f:
            db_schema: str = f.read()
        connection.executescript(db_schema)
    except sqlite3.Error as e:
        print(f"SQLite Error: {e}")
    finally:
        if connection:
            connection.close()
