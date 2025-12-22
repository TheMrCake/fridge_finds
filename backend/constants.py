from pathlib import Path

PROJECT_ROOT_DIR: Path = Path(__file__).resolve().parent.parent

GLEAM_STATIC_DIR: Path = PROJECT_ROOT_DIR / "frontend" / "dist" / "static"



DATABASE_NAME: str = "fridge_finds.db"

DATABASE_FOLDER_DIR: Path = PROJECT_ROOT_DIR / "backend" / "database"
DATABASE_DIR: Path = DATABASE_FOLDER_DIR / DATABASE_NAME

DATABASE_SCHEMA_NAME: str = "schema.sql"
DATABASE_SCHEMA_DIR: Path = DATABASE_FOLDER_DIR / DATABASE_SCHEMA_NAME
DATABASE_SEED_SCRIPT_NAME: str = "populate.sql"
DATABASE_SEED_SCRIPT_DIR: Path = DATABASE_FOLDER_DIR / DATABASE_SEED_SCRIPT_NAME
