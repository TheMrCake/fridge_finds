from typing import List
import sqlite3
import constants
from enum import Enum
from pathlib import Path

class TableKind(Enum):
    RECIPE = "recipes"
    USER = "users"
    CATEGORY = "categories"
    INGREDIENT = "ingredients"

def get_db_connection() -> sqlite3.Connection:
    connection: sqlite3.Connection = sqlite3.connect(constants.DATABASE_DIR)
    connection.row_factory = sqlite3.Row
    return connection

def execute_script(script_path: Path) -> None:
    if not script_path.exists():
        print(f"Error: {script_path} not found.")
        return

    try:
        connection: Connection = get_db_connection()

        with open(script_path, "r") as f:
            db_script: str = f.read()
        connection.executescript(db_script)

    except sqlite3.Error as e:
        print(f"SQLite Error: {e}")
    finally:
        if connection:
            connection.close()


def count_table(table_kind: TableKind) -> int:
    connection = get_db_connection()
    cursor = connection.cursor()
    
    cursor.execute(f"SELECT COUNT(*) FROM {table_kind.value}")
    
    result: tuple = cursor.fetchone()
    connection.close()
    
    return result[0] if result else 0


def get_row(id: int, table_kind: TableKind) -> dict | None:
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute(f"SELECT * FROM {table_kind.value} WHERE id = ?", (id,))
    row: Any | None = cursor.fetchone()
    connection.close()

    return dict(row) if row else None

def get_rows(ids: List[int], table_kind: TableKind) -> List[dict]:
    if not ids:
        return None

    connection = get_db_connection()
    cursor = connection.cursor()

    # Use as many placeholders as there are ids
    placeholders = ", ".join(["?"] * len(ids))

    cursor.execute(f"SELECT * FROM {table_kind.value} WHERE id IN ({placeholders})", ids)

    rows: Any = cursor.fetchall()
    connection.close()
    return [dict(row) for row in rows]



def get_row_with_kind(id: int, table_kind: TableKind) -> dict | None:
    row: dict | None = get_row(id, table_kind)
    if row:
        row["kind"] = table_kind.value

    return row


def get_rows_with_kind(ids: List[int], table_kind: TableKind) -> List[dict]:
    rows: List[dict] = get_rows(ids, table_kind)
    for row in rows:
        row["kind"] = table_kind.value

    return rows



def search_rows(in_str: str, filters: dict[str, bool]) -> List[dict]:
    if in_str == "":
        return []
    connection = get_db_connection()
    cursor = connection.cursor()

    all_results: List[dict] = []

    (search_param, like_or_equal) = (f"{in_str}", "=") if filters.get("exact") else (f"%{in_str}%", "LIKE")

    # Search if in_str matches any name, description, or ingredients
    # Distinct makes sure there aren"t duplicates if the string matches
    # in two places like in name and ingredients
    # Left join to make sure that the ingredient match isn"t required,
    # in otherwords, just keep everything
    if filters.get("recipes"):
        recipe_query: str = """
            SELECT DISTINCT r.* FROM recipes r
        """
        if filters.get("ingredients"):
            recipe_query += f"""

                LEFT JOIN recipe_ingredients ri ON r.id = ri.recipe_id
                LEFT JOIN ingredients i ON ri.ingredient_id = i.id
                WHERE r.name {like_or_equal} ?
                    OR r.description {like_or_equal} ?
                    OR i.name {like_or_equal} ?
            """
        else:
            recipe_query += f"""

                WHERE r.name {like_or_equal} ?
                    OR r.description {like_or_equal} ?
            """
        cursor.execute(recipe_query, (search_param, search_param, search_param))

        for row in cursor.fetchall():
            d = dict(row)
            d["kind"] = TableKind.RECIPE.value
            all_results.append(d)


    if filters.get("users"):
        # Search users now
        user_query: str = f"""
            SELECT * FROM users
            WHERE name {like_or_equal} ?
                OR description {like_or_equal} ?
                OR username {like_or_equal} ?
        """

        cursor.execute(
            user_query,
            (search_param, search_param, search_param,)
        )

        for row in cursor.fetchall():
            d = dict(row)
            d["kind"] = TableKind.USER.value
            all_results.append(d)

    return all_results
