
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL
);

DROP TABLE IF EXISTS recipes;
CREATE TABLE recipes (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,

    author_id INTEGER NOT NULL,
    FOREIGN KEY (author_id) REFERENCES users (id),

    title TEXT NOT NULL,
    instructions TEXT NOT NULL,
    prep_time_mins INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS ingredients;
CREATE TABLE ingredients (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name TEXT UNIQUE NOT NULL
);

DROP TABLE IF EXISTS recipe_ingredients;
CREATE TABLE recipe_ingredients (
    recipe_id INTEGER NOT NULL,
    FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE,

    ingredient_id INTEGER NOT NULL,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
);
