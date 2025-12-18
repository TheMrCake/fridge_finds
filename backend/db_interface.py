import sqlite3
import constants

def get_db_connection() -> sqlite3.Connection:
    connection: sqlite3.Connection = sqlite3.connect(constants.DB_PATH)
    connection.row_factory = sqlite3.Row
    return connection


