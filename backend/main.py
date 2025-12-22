from typing import Any
import flask
from flask import Flask, request, session
from typing import List
import random
import werkzeug.security

# Local includes
import constants
import db_init
import db_interface
from db_interface import TableKind

app = Flask(
    __name__,
    static_folder = constants.GLEAM_STATIC_DIR,
    static_url_path = "/static/")

# This should somehow be kept a secret, but this is not
# true production code so it is ok
app.secret_key = "open_sesame"

# API routes

@app.route("/api/recipes-for-you", methods=["GET"])
def recipes_for_you():
    # 5 Random recipes
    recipe_ids: List[int] = random.sample(range(1, db_interface.count_table(TableKind.RECIPE)+1), 5)

    items: List[dict] = db_interface.get_rows_with_kind(recipe_ids, TableKind.RECIPE)
    return flask.jsonify(items)

@app.route("/api/<string:table_str>/<int:id>", methods=["GET"])
def row_information(table_str: str, id: int):
    item: dict | None = db_interface.get_row(id, TableKind(table_str))
    return flask.jsonify(item) 


@app.route("/api/search", methods=["GET"])
def search():
    # q parameter stores query
    query = request.args.get("q", default="", type=str)
    filters: dict[str, bool] = {
        "recipes": True,
        "ingredients": True,
        "users": True,
        "exact": False
    }

    db_interface.search_rows(query, filters)

    results = db_interface.search_rows(query, filters)
    return flask.jsonify(results)

@app.route("/api/me", methods=["GET"])
def me():
    user_id = session.get('user_id')
    if not user_id:
        return flask.jsonify({"error": "Not logged in"}), 401

    filters: dict[str, bool] = {
        "recipes": False,
        "ingredients": False,
        "users": True,
        "exact": True
    }

    user: dict | None = db_interface.get_row(user_id, TableKind.USER)
    
    if not user:
        return flask.jsonify({"error": "User not found"}), 404

    return flask.jsonify(user)

@app.route("/api/login", methods=["POST"])
def login():
    data = request.json

    username: str = data.get("username")
    password: str = data.get("password")

    filters: dict[str, bool] = {
        "recipes": False,
        "ingredients": False,
        "users": True,
        "exact": True
    }

    search_result: List[dict] = db_interface.search_rows(username, filters)

    if len(search_result) == 0:
        return flask.jsonify({"error": "Invalid username or password"}), 401
    
    user: dict = search_result[0]

    if not werkzeug.security.check_password_hash(user.get("password_hash"), password):
        return flask.jsonify({"error": "Invalid username or password"}), 401

    session["user_id"] = user.get("id")

    return flask.jsonify(user)

@app.route("/api/logout", methods=["POST"])
def logout():
    session.pop("user_id")

    return jsonify({"message": "Logged out"}), 200

# Catch All route

@app.route("/<path:path>", methods=["GET"])
@app.route("/", defaults={"path": ""}, methods=["GET"])
def catch_all(path):
    return app.send_static_file("index.html")




if __name__ == "__main__":
    db_init.init()
    app.run(debug = True, port = 5000)
