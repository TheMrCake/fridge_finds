from pathlib import Path
from flask import Flask

PROJECT_ROOT_DIR = Path(__file__).resolve().parent.parent

GLEAM_DIST_DIR = PROJECT_ROOT_DIR / "frontend" / "dist"

print(GLEAM_DIST_DIR)

app = Flask(
    __name__,
    static_folder = '../fronten',
    static_url_path = '/')

if __name__ == '__main__':
    app.run(debug = True, port = 5000)



