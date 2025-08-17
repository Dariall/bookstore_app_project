GO
CREATE PROCEDURE SearchBooks
    @term NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        b.id,
        b.title,
        a.name AS author_name,
        b.price,
        b.image_url
    FROM books b
    INNER JOIN authors a ON b.author_id = a.id
    WHERE 
        LOWER(b.title) LIKE '%' + LOWER(@term) + '%'
        OR LOWER(a.name) LIKE '%' + LOWER(@term) + '%';
END;
GO

GO
CREATE PROCEDURE GetBooksCatalog
    @author_id UNIQUEIDENTIFIER = NULL,
    @genre_id UNIQUEIDENTIFIER = NULL,
    @price_min DECIMAL(10,2) = NULL,
    @price_max DECIMAL(10,2) = NULL,
    @only_favorites BIT = 0,
    @user_id UNIQUEIDENTIFIER = NULL,
    @sort_by NVARCHAR(20) = 'title', -- 'title', 'price'
    @sort_dir NVARCHAR(4) = 'asc'    -- 'asc' или 'desc'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        b.id,
        b.title,
        a.name AS author_name,
        b.price,
        b.image_url
    FROM books b
    INNER JOIN authors a ON b.author_id = a.id
    LEFT JOIN favorites f ON b.id = f.book_id AND f.user_id = @user_id
    WHERE
        (@author_id IS NULL OR b.author_id = @author_id)
        AND (@genre_id IS NULL OR b.genre_id = @genre_id)
        AND (@price_min IS NULL OR b.price >= @price_min)
        AND (@price_max IS NULL OR b.price <= @price_max)
        AND (@only_favorites = 0 OR f.book_id IS NOT NULL)
    ORDER BY
        CASE 
            WHEN @sort_by = 'title' AND @sort_dir = 'asc' THEN b.title 
        END ASC,
        CASE 
            WHEN @sort_by = 'title' AND @sort_dir = 'desc' THEN b.title 
        END DESC,
        CASE 
            WHEN @sort_by = 'price' AND @sort_dir = 'asc' THEN b.price 
        END ASC,
        CASE 
            WHEN @sort_by = 'price' AND @sort_dir = 'desc' THEN b.price 
        END DESC;
END;
GO

GO
CREATE PROCEDURE AddToFavorites
    @user_id UNIQUEIDENTIFIER,
    @book_id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM favorites WHERE user_id = @user_id AND book_id = @book_id
    )
    BEGIN
        INSERT INTO favorites (user_id, book_id)
        VALUES (@user_id, @book_id);
    END
END;
GO


GO
CREATE PROCEDURE AddToCart
    @user_id UNIQUEIDENTIFIER,
    @book_id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cart_id UNIQUEIDENTIFIER;

    SELECT TOP 1 @cart_id = id
    FROM carts
    WHERE user_id = @user_id AND is_active = 1;

    IF @cart_id IS NULL
    BEGIN
        SET @cart_id = NEWID();
        INSERT INTO carts (id, user_id, created_at, is_active)
        VALUES (@cart_id, @user_id, GETDATE(), 1);
    END

    IF EXISTS (
        SELECT 1 FROM cart_items
        WHERE cart_id = @cart_id AND book_id = @book_id
    )
    BEGIN
        UPDATE cart_items
        SET quantity = quantity + 1
        WHERE cart_id = @cart_id AND book_id = @book_id;
    END
    ELSE
    BEGIN
        INSERT INTO cart_items (id, cart_id, book_id, quantity)
        VALUES (NEWID(), @cart_id, @book_id, 1);
    END
END;
GO

GO
CREATE PROCEDURE RemoveFromCart
    @user_id UNIQUEIDENTIFIER,
    @book_id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cart_id UNIQUEIDENTIFIER;

    SELECT TOP 1 @cart_id = id
    FROM carts
    WHERE user_id = @user_id AND is_active = 1;

    IF @cart_id IS NOT NULL
    BEGIN
        DELETE FROM cart_items
        WHERE cart_id = @cart_id AND book_id = @book_id;
    END
END;
GO

GO
CREATE PROCEDURE GetCart
    @user_id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cart_id UNIQUEIDENTIFIER;

    SELECT TOP 1 @cart_id = id
    FROM carts
    WHERE user_id = @user_id AND is_active = 1;

    IF @cart_id IS NOT NULL
    BEGIN
        SELECT 
            ci.id AS cart_item_id,
            b.id AS book_id,
            b.title,
            a.name AS author,
            ci.quantity,
            b.price,
            b.price * ci.quantity AS total_price
        FROM cart_items ci
        JOIN books b ON ci.book_id = b.id
        JOIN authors a ON b.author_id = a.id
        WHERE ci.cart_id = @cart_id;

        SELECT SUM(b.price * ci.quantity) AS cart_total
        FROM cart_items ci
        JOIN books b ON ci.book_id = b.id
        WHERE ci.cart_id = @cart_id;
    END
    ELSE
    BEGIN
        SELECT NULL AS cart_item_id, NULL AS book_id, NULL AS title, NULL AS author, NULL AS quantity, NULL AS price, NULL AS total_price;
        SELECT 0 AS cart_total;
    END
END;
GO


