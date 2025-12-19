import sqlite3
from sqlite3 import Connection

# Local includes
from constants import DATABASE_NAME, DATABASE_DIR, DATABASE_SCHEMA_DIR, DATABASE_SEED_SCRIPT_DIR
import db_interface

def init() -> None:
    db_interface.execute_script(DATABASE_SCHEMA_DIR)

def populate() -> None:
    db_interface.execute_script(DATABASE_SEED_SCRIPT_DIR)

if __name__ == '__main__':
    init()
    populate()
