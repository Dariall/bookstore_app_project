CREATE TABLE users (
    id UUID PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE authors (
    id UUID PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
CREATE TABLE genres (
    id UUID PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
CREATE TABLE books (
    id UUID PRIMARY KEY,
    title VARCHAR(60) NOT NULL,
    author_id UUID NOT NULL REFERENCES authors(id),
    genre_id UUID NOT NULL REFERENCES genres(id),
    price NUMERIC(10,2) NOT NULL,
    year INT,
    pages INT,
    cover_type VARCHAR(10),
    image_url TEXT
);
CREATE TABLE favorites (
    user_id UUID REFERENCES users(id),
    book_id UUID REFERENCES books(id),
    PRIMARY KEY (user_id, book_id)
);
CREATE TABLE carts (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE
);
CREATE TABLE cart_items (
    id UUID PRIMARY KEY,
    cart_id UUID REFERENCES carts(id),
    book_id UUID REFERENCES books(id),
    quantity INT NOT NULL DEFAULT 1
);
