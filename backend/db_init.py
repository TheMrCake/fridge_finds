import sqlite3
import requests
from sqlite3 import Connection
import werkzeug.security

# Local includes
from constants import DATABASE_NAME, DATABASE_DIR, DATABASE_SCHEMA_DIR, DATABASE_SEED_SCRIPT_DIR
import db_interface

def init() -> None:
    db_interface.execute_script(DATABASE_SCHEMA_DIR)

def populate() -> None:
    print("Fetching data from dummyjson.com...")
    num_users: int = 10
    num_recipes: int = 50
    users_data = requests.get(f"https://dummyjson.com/users?limit={num_users}").json()['users']
    recipes_data = requests.get(f"https://dummyjson.com/recipes?limit={num_recipes}").json()['recipes']
    connection = db_interface.get_db_connection()
    cursor = connection.cursor()

    # Users
    for user in users_data:
        cursor.execute("""
           INSERT INTO users (id, name, description, username, password_hash)
           VALUES (?, ?, ?, ?, ?) 
        """, (
            user['id'],
            f"{user['firstName']} {user['lastName']}",
            f"Chef from {user['address']['city']}",
            user['username'],
            werkzeug.security.generate_password_hash(user['username'] + "123") # Set all passwords to <username>123
        ))

    # Recipes and Ingredients
    for r in recipes_data:
        cursor.execute("""
            INSERT INTO recipes (id, author_id, name, description, instructions, prep_time_mins)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (
            r['id'],
            (r['id'] % num_users) + 1, # Distribute the recipes amongst the users
            r['name'],
            f"{r['cuisine']} style dish with {r['difficulty']} difficulty.",
            "[" + ", ".join([f"\"{instruction}\"" for instruction in r['instructions']]) + "]", # Store instructions in a json format            
            r['prepTimeMinutes'],
        ))
        for ingredient in r['ingredients']:
            # Insert the ingredient if it doesn't already exist
            cursor.execute("INSERT OR IGNORE INTO ingredients (name) VALUES (?)", (ingredient,))

            # Get the autoincremented id of that ingredient
            cursor.execute("SELECT id FROM ingredients WHERE name = ?", (ingredient,))
            ingredient_id: int = cursor.fetchone()[0]

            # Link the ingredient to the recipe 
            cursor.execute("""
                INSERT INTO recipe_ingredients (recipe_id, ingredient_id)
                VALUES (?, ?)
            """, (r['id'], ingredient_id))

    connection.commit()
    print("Successfully populated database")
        

if __name__ == "__main__":
    init()
    populate()
