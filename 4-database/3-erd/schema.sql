-- Parent table 

CREATE TABLE Roles (
    role_id SERIAL PRIMARY KEY,
	type VARCHAR(50) NOT null,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
-- Child of Roles table with Foreign Key
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    age SMALLINT CHECK (age >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    role_id INTEGER not NULL,
    password_hash TEXT NOT NULL, 
    reset_token TEXT,
    reset_token_expires TIMESTAMP,
               -- Foreign Key to Roles
    CONSTRAINT fk_bridge_Roles FOREIGN KEY (role_id) 
        REFERENCES Roles(role_id) 
        ON DELETE RESTRICT  
        ON UPDATE CASCADE
);

CREATE TABLE Category (
    category_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT null,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Parent table 
CREATE TABLE Product (
	product_id SERIAL primary key,
	status VARCHAR(50) not null,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    category_id INTEGER not null,
        CONSTRAINT fk_category FOREIGN KEY (category_id) 
        REFERENCES Category(category_id) 
        ON DELETE RESTRICT  
        ON UPDATE CASCADE
	
);
-- Bridge/Junction Table (Many-to-Many relationship)
CREATE TABLE Product_Likes(
    product_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Composite Primary Key (both FKs together form the PK)
    PRIMARY KEY (user_id, product_id),
    
    -- Foreign Key to user
    CONSTRAINT fk_bridge_users FOREIGN KEY (user_id) 
        REFERENCES Users(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Foreign Key to products
    CONSTRAINT fk_bridge_product FOREIGN KEY (product_id) 
        REFERENCES Product(product_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);




CREATE TABLE Product_Images (
    image_id SERIAL PRIMARY KEY,
	image_url TEXT NOT null,
	display_order INTEGER not null,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    product_id INTEGER not null,
        CONSTRAINT fk_Product FOREIGN KEY (product_id) 
        REFERENCES Product(product_id) 
        ON DELETE CASCADE  
        ON UPDATE CASCADE
);

CREATE TABLE Orders(
    order_id SERIAL PRIMARY KEY,
    total_amount DECIMAL(10,2) not null,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER not null,
              -- Foreign Key to user
    CONSTRAINT fk_bridge_users FOREIGN KEY (user_id) 
        REFERENCES Users(user_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
);



CREATE TABLE Order_Status_History (
    order_Status_History_id SERIAL PRIMARY KEY,
    status TEXT not NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_id INTEGER not null,
    user_id INTEGER,
          -- Foreign Key to orders
        CONSTRAINT fk_Orders FOREIGN KEY (order_id) 
        REFERENCES Orders(order_id) 
        ON DELETE CASCADE  
        ON UPDATE cascade,
        
          -- Foreign Key to user
    CONSTRAINT fk_bridge_users FOREIGN KEY (user_id) 
        REFERENCES Users(user_id) 
        ON DELETE set NULL 
        ON UPDATE CASCADE
);

CREATE TABLE Product_Variant (
    product_variant_id SERIAL PRIMARY KEY,
    size VARCHAR(10) not null CHECK (size IN ('S','M','L','XL','XXL')),
    color VARCHAR(20) not null CHECK (color IN ('red','blue','yellow')),
    stock_quantity INTEGER not null CHECK (stock_quantity >= 0),
    sku_code VARCHAR(100) not null UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    product_id INTEGER not null,
    CONSTRAINT fk_product FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


CREATE TABLE Order_Items (
    order_items_id SERIAL PRIMARY KEY,
    quantity INTEGER not null,
    price_at_purchase DECIMAL(10,2) not null,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_id INTEGER not null,
    product_variant_id INTEGER not null,
    
        CONSTRAINT fk_Product_Variant FOREIGN KEY (product_variant_id) 
        REFERENCES Product_Variant (product_variant_id) 
        ON DELETE RESTRICT  
        ON UPDATE CASCADE,
        
        CONSTRAINT fk_Orders FOREIGN KEY (order_id) 
        REFERENCES Orders(order_id) 
        ON DELETE CASCADE  
        ON UPDATE CASCADE
);

CREATE TABLE Cart(
    cart_id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER not null UNIQUE,
              -- Foreign Key to user
    CONSTRAINT fk_bridge_users FOREIGN KEY (user_id) 
        REFERENCES Users(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
    
);

CREATE TABLE Cart_Items(
    cart_items_id SERIAL PRIMARY KEY,
    quantity INTEGER not null,
    price_at_purchase DECIMAL(10,2) not null,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    product_variant_id INTEGER not null,
    cart_id INTEGER not null,
    
        CONSTRAINT fk_Product_Variant FOREIGN KEY (product_variant_id) 
        REFERENCES Product_Variant (product_variant_id) 
        ON DELETE RESTRICT  
        ON UPDATE CASCADE,
        
        CONSTRAINT fk_Cart FOREIGN KEY (cart_id) 
        REFERENCES Cart (cart_id) 
        ON DELETE RESTRICT  
        ON UPDATE CASCADE
);

CREATE TABLE Payment(
    payment_id SERIAL PRIMARY KEY,
    amount DECIMAL(10,2) not null,
	method_type VARCHAR(50), 
	stripe_reference TEXT , 
	status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_id INTEGER not null,
    
        CONSTRAINT fk_Orders FOREIGN KEY (order_id) 
        REFERENCES Orders(order_id) 
        ON DELETE RESTRICT  
        ON UPDATE CASCADE
);

CREATE TABLE Prices_History (
    prices_History_id SERIAL PRIMARY KEY,
    price DECIMAL(10, 2) NOT NULL,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    product_variant_id INTEGER not null,
    
        CONSTRAINT fk_Product_Variant FOREIGN KEY (product_variant_id) 
        REFERENCES Product_Variant (product_variant_id) 
        ON DELETE RESTRICT  
        ON UPDATE CASCADE
);




