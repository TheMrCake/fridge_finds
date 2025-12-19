-- 1. Create 5 Users
INSERT INTO users (name, password_hash) VALUES 
('Mario Batali', 'hash_mario'),
('Beth the Baker', 'hash_beth'),
('Sam Spicy', 'hash_sam'),
('Helen Healthy', 'hash_helen'),
('Quentin Quick', 'hash_quentin');

-- 2. Create Common Ingredients
INSERT INTO ingredients (name) VALUES 
('Pasta'), ('Eggs'), ('Guanciale'), ('Pecorino'), ('Black Pepper'),
('Flour'), ('Sugar'), ('Butter'), ('Apples'), ('Cinnamon'),
('Chicken'), ('Soy Sauce'), ('Ginger'), ('Garlic'), ('Broccoli'),
('Avocado'), ('Sourdough'), ('Lemon'), ('Olive Oil'), ('Sea Salt');

-- 3. Create 10 Recipes (matching your Gleam fields: name, description, instructions)
INSERT INTO recipes (author_id, name, description, instructions, prep_time_mins) VALUES 
(1, 'Carbonara', 'Creamy Roman pasta', 'Whisk eggs/cheese. Fry pork. Toss with pasta.', 20),
(1, 'Cacio e Pepe', 'Cheese and pepper pasta', 'Emulsify cheese and pasta water with lots of pepper.', 15),
(2, 'Apple Tart', 'Crispy fruit dessert', 'Layer sliced apples over buttered pastry and bake.', 60),
(2, 'Shortbread', '3-ingredient cookies', 'Mix butter, sugar, and flour. Bake at 150°C.', 40),
(3, 'Kung Pao Chicken', 'Spicy stir-fry', 'Sear chicken with ginger, garlic, and dried chilies.', 25),
(3, 'Garlic Broccoli', 'Simple side dish', 'Steam broccoli and toss with sautéed garlic oil.', 12),
(4, 'Avocado Toast', 'Healthy breakfast', 'Mash avocado on toasted sourdough with lemon.', 10),
(4, 'Lemon Chicken', 'Zesty grilled breast', 'Marinate chicken in lemon and herbs then grill.', 30),
(5, 'Quick Ramen', 'Instant upgrade', 'Add a soft boiled egg and soy sauce to ramen.', 10),
(5, 'Butter Noodles', 'The student classic', 'Boil pasta and add a massive knob of butter.', 8);

-- 4. Link Ingredients to Recipes
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES 
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), -- Carbonara
(3, 6), (3, 7), (3, 8), (3, 9), (3, 10), -- Apple Tart
(5, 11), (5, 12), (5, 13), (5, 14), -- Kung Pao
(7, 16), (7, 17), (7, 18), (7, 20), -- Avocado Toast
(10, 1), (10, 8), (10, 20); -- Butter Noodles
