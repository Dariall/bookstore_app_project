INSERT INTO authors (id, name) VALUES
('11111111-111', 'Агата Кристи'),
('22222222-222', 'Стивен Кинг'),
('33333333-333', 'Эрих Мария Ремарк');

INSERT INTO genres (id, name) VALUES
('g1', 'Классика'),
('g2', 'Фэнтези'),
('g3', 'Детектив');

INSERT INTO books (id, title, author_id, genre_id, price, year, pages, cover_type, image_url) VALUES
('b1', 'Немой свидетель', '11111111-111', 'g3', 450.00, 1937, 384, 'мягкий', 'https://example.com/1.jpg'),
('b2', 'Институт', '22222222-222', 'g2', 1700.00, 2019, 640, 'твердый', 'https://example.com/2.jpg'),
('b3', 'Три товарища', '33333333-333', 'g1', 630.00, 1936, 480, 'мягкий', 'https://example.com/3.jpg');

INSERT INTO users (id, phone_number, created_at) VALUES
('u1', '+79838867361', NOW());

INSERT INTO favorites (user_id, book_id) VALUES
('u1', 'b1'),
('u1', 'b3');

INSERT INTO carts (id, user_id, created_at, is_active) VALUES
('c1', 'u1', NOW(), true);

INSERT INTO cart_items (id, cart_id, book_id, quantity) VALUES
('i1', 'c1', 'b2', 1),
('i2', 'c1', 'b3', 2);
