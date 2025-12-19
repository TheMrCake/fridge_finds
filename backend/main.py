import flask
from flask import Flask
from typing import List
import random

# Local includes
import constants
import db_init
import db_interface
from db_interface import TableKind

app = Flask(
    __name__,
    static_folder = constants.GLEAM_DIST_DIR,
    static_url_path = '/')

@app.route("/api/recipes-for-you")
def recipes_for_you():
    # 5 Random recipes
    recipe_ids: List[int] = random.sample(range(1, db_interface.count_table(TableKind.RECIPE)+1), 5)

    items: List[dict] = db_interface.get_rows_with_kind(recipe_ids, TableKind.RECIPE)
    return flask.jsonify(items) if items else flask.jsonify([{}])

@app.route("/api/<string:table_str>/<int:id>")
def row_information(table_str: str, id: int):
    item: dict | None = db_interface.get_row(id, TableKind(table_str))
    return flask.jsonify(item) if item else None 


@app.route("/")
@app.route("/<path:url>")
def index():
    return app.send_static_file("index.html")


if __name__ == '__main__':
    db_init.init()
    app.run(debug = True, port = 5000)
