-- Clear out existing data to ensure a fresh start
DELETE FROM recipe_ingredients;
DELETE FROM ingredients;
DELETE FROM recipes;
DELETE FROM users;

-- 1. Populate Users
INSERT INTO users (name, description, username, password_hash) VALUES 
('Gordon Ramsay', 'Professional chef and television personality.', 'gordon_r', 'hashed_pass_123'),
('Jane Homecook', 'I love making simple meals for my family.', 'jane_cooks', 'hashed_pass_456'),
('Marco Pierre White', 'The first celebrity chef.', 'mpw_legend', 'hashed_pass_789');

-- 2. Populate Ingredients
-- We use INSERT OR IGNORE just in case of duplicates during manual edits
INSERT INTO ingredients (name) VALUES 
('Egg'), ('Flour'), ('Milk'), ('Butter'), ('Salt'), 
('Tomato'), ('Basil'), ('Garlic'), ('Onion'), ('Pasta'),
('Chicken Breast'), ('Olive Oil'), ('Black Pepper');

-- 3. Populate Recipes
-- Recipe 1: Scrambled Eggs (Author: Gordon Ramsay - ID 1)
INSERT INTO recipes (author_id, name, description, instructions, prep_time_mins) VALUES 
(1, 'Gordon Ramsay Scrambled Eggs', 'The ultimate creamy scrambled eggs.', 'Break eggs into a cold pan. Add butter. Stir constantly over heat...', 10);

-- Recipe 2: Basic Tomato Pasta (Author: Jane - ID 2)
INSERT INTO recipes (author_id, name, description, instructions, prep_time_mins) VALUES 
(2, 'Simple Tomato Pasta', 'A quick weekday dinner.', 'Boil pasta. Sauté garlic and onions. Add tomato and basil...', 20);

-- Recipe 3: Roasted Chicken (Author: Marco - ID 3)
INSERT INTO recipes (author_id, name, description, instructions, prep_time_mins) VALUES 
(3, 'Classic Roasted Chicken', 'Simple but perfect roast chicken.', 'Season with salt and oil. Roast at 200C for 60 minutes...', 70);

-- 4. Link Recipes to Ingredients (recipe_ingredients)
-- Scrambled Eggs (ID 1) uses Eggs, Butter, Salt
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES 
(1, 1), (1, 4), (1, 5);

-- Tomato Pasta (ID 2) uses Pasta, Tomato, Basil, Garlic, Onion
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES 
(2, 10), (2, 6), (2, 7), (2, 8), (2, 9);

-- Roasted Chicken (ID
