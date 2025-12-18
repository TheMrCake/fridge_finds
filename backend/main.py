from flask import Flask

# Local includes
import constants
import db_init
import db_interface

app = Flask(
    __name__,
    static_folder = constants.GLEAM_DIST_DIR,
    static_url_path = '/')

@app.route("/")
def index():
    return app.send_static_file("index.html")


if __name__ == '__main__':
    db_init.init()
    app.run(debug = True, port = 5000)
