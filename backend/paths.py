from pathlib import Path

PROJECT_ROOT_DIR: Path = Path(__file__).resolve().parent.parent

GLEAM_DIST_DIR: Path = PROJECT_ROOT_DIR / "frontend" / "dist"

DATABASE_DIR: Path = PROJECT_ROOT_DIR / "backend" / "database"
