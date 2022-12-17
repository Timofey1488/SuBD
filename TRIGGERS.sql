CREATE TRIGGER trigger_clients
AFTER INSERT OR UPDATE ON clients 
FOR EACH ROW EXECUTE PROCEDURE add_to_log ();

CREATE OR REPLACE FUNCTION add_to_log() RETURNS TRIGGER AS $$
DECLARE
    mstr varchar(30);
    astr varchar(100);
    retstr varchar(254);
BEGIN
    IF    TG_OP = 'INSERT' THEN
        astr = NEW.name;
        mstr := 'Add new client ';
        retstr := mstr || astr;
        INSERT INTO logger(log_text,log_date) values (retstr,NOW());
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        astr = NEW.name;
        mstr := 'Update client ';
        retstr := mstr || astr;
        INSERT INTO logger(log_text,log_date) values (retstr,NOW());
        RETURN NEW;

END;
$$ LANGUAGE plpgsql;

-----trigger for create payments client's
CREATE OR REPLACE FUNCTION new_payments_client() RETURNS TRIGGER AS $create_payments_client$
	BEGIN
		INSERT INTO payments(pk_payments_id,fk_clients_id) 
		VALUES ((SELECT MAX(pk_payments_id) FROM payments)+1, (SELECT MAX(pk_clients_id) FROM clients)+1);
	RETURN NULL;
END;
$create_payments_client$ LANGUAGE plpgsql;

CREATE TRIGGER create_payments_client 
AFTER INSERT ON clients
FOR EACH ROW
EXECUTE PROCEDURE new_payments_client();

-----trigger for create cart client's
CREATE OR REPLACE FUNCTION new_cart_client() RETURNS TRIGGER AS $create_cart_client$
	BEGIN
		INSERT INTO cart(cart_id,empty_cart) 
		VALUES ((SELECT MAX(cart_id) FROM cart)+1, true;
	RETURN NULL;
END;
$create_cart_client$ LANGUAGE plpgsql;

CREATE TRIGGER create_cart_client 
AFTER INSERT ON clients
FOR EACH ROW
EXECUTE PROCEDURE new_cart_client();
				
-----trigger for delete product from product_cart
CREATE OR REPLACE FUNCTION delete_products() RETURNS TRIGGER AS $delete_product_from_product_cart$
	BEGIN
		DELETE FROM product_cart
		WHERE product_cart.cart_id = (SELECT MAX(cart_id) FROM cart);
	RETURN NULL;
END;
$delete_product_from_product_cart$ LANGUAGE plpgsql;

CREATE TRIGGER delete_product_from_product_cart
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE PROCEDURE delete_products();
-------------------------------------------------------------
SELECT * FROM clients


select * from product_cart
-----------------------------------------

SELECT * FROM clients
SELECT * FROM logger
SHOW TRIGGERS FROM subd;

--------PROCEDURES-----------------------
CREATE PROCEDURE clients_data()
LANGUAGE SQL
AS $$
SELECT * FROM clients
$$;

CALL clients_data();

CREATE PROCEDURE insert_user_client(id integer,email VARCHAR(50) ,password VARCHAR(50), cart_number integer)
LANGUAGE SQL
AS $$
INSERT INTO customer VALUES(id,email,password,cart_number);
$$;

CREATE PROCEDURE insert_user_manager(id integer,email VARCHAR(50) ,password VARCHAR(50), cart_number integer)
LANGUAGE SQL
AS $$
INSERT INTO customer VALUES(id,email,password,null,cart_number);
$$;
-----------------------------------------------------------------------
CALL insert_user_manager(4,'timsid@gmail.com','123456789',4);
CALL insert_user_manager(5,'tisid@gmail.com','23456789',3);

SELECT * FROM customer

-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_product() RETURNS TRIGGER AS $insert_product$
DECLARE
	count_pr numeric;
	BEGIN 
	count_pr := COUNT(*) FROM products;
	IF (TG_OP = 'INSERT') THEN
		IF (NEW.pk_product_id > count_pr) THEN
			INSERT INTO products (pk_product_id, product_name, price, availibility, product_count, fk_category_id)
			VALUES 
			(NEW.pk_product_id, NEW.product_name, NEW.price, NEW.availibility, NEW.product_count, NEW.fk_category_id);
		END IF;
	END IF;
	
	RETURN NULL;
END;
$insert_product$ LANGUAGE plpgsql;

CREATE TRIGGER insert_product AFTER INSERT ON products
	FOR EACH ROW EXECUTE PROCEDURE insert_product();
----------------------------------------------------------

 
INSERT INTO products(pk_product_id, product_name, price, availibility, product_count, fk_category_id)
VALUES (8,'Батон',2,true,20,1)

SELECT fk_client_id,fk_manager_id FROM customer WHERE customer_email='timofey12@gmail.com'
SELECT customer_password FROM customer WHERE customer_email='timofey12@gmail.com'

SELECT * FROM clients

INSERT INTO customer(pk_customer_id,customer_email,customer_password) values(14,'admin@gmail.com','admin')

SELECT customer.customer_email, clients.first_name, clients.second_name, clients.phone_number 
FROM customer
LEFT JOIN clients 
ON customer.fk_client_id = clients.pk_clients_id
WHERE customer_email='mark@gmail.com'

UPDATE clients 
SET first_name='Mark'
FROM customer 
WHERE customer.fk_client_id = clients.pk_clients_id and customer.customer_email='mark@gmail.com'

SELECT * FROM orders

SELECT DISTINCT orders.fk_cart_id FROM orders
LEFT JOIN clients 
ON orders.fk_cart_id = clients.pk_clients_id
LEFT JOIN customer
ON customer.fk_client_id = clients.pk_clients_id
WHERE customer_email = 'r@gmail.com'

SELECT MAX(pk_clients_id) FROM clients

ALTER TABLE product_cart ADD FOREIGN KEY (cart_id) REFERENCES cart(cart_id) 
ON DELETE CASCADE

ALTER TABLE order_details DROP COLUMN fk_product_id

SELECT cart_id FROM clients
LEFT JOIN customer
ON customer.fk_client_id = clients.pk_clients_id
LEFT JOIN cart
ON clients.fk_cart_id = cart.cart_id 
WHERE customer_email = 'r@gmail.com'

select cart_id, product_id from product_cart
WHERE cart_id = 11 and product_id=6

SELECT SUM(price*quantity) AS sum_price
FROM products
LEFT JOIN product_cart
ON product_cart.product_id = products.pk_product_id
WHERE cart_id = 11

SELECT * FROM order_details

SELECT number_card FROM discount_cards
LEFT JOIN clients
ON clients.fk_discount_card_id = discount_cards.pk_discount_card_id
WHERE clients.fk_cart_id = 4

SELECT pk_order_id, total_price, status_order, product_name, quantity, price*quantity AS total_price_product FROM order_details
LEFT JOIN orders ON
order_details.fk_order_id = orders.pk_order_id
LEFT JOIN cart ON
orders.fk_cart_id = cart.cart_id
LEFT JOIN product_cart ON
cart.cart_id = product_cart.cart_id
LEFT JOIN products ON
products.pk_product_id = product_cart.product_id
WHERE pk_order_id = 3

SELECT pk_order_id FROM customer
LEFT JOIN clients ON
clients.pk_clients_id = customer.fk_client_id
LEFT JOIN cart ON
clients.fk_cart_id = cart.cart_id
INNER JOIN orders ON
orders.fk_client_id = clients.pk_clients_id
WHERE customer_email='r@gmail.com'

SELECT cart_id, pk_order_id FROM cart
LEFT JOIN orders ON
cart.cart_id = orders.fk_cart_id
LEFT JOIN clients ON
orders.fk_client_id = clients.pk_clients_id
LEFT JOIN customer ON
clients.pk_clients_id = customer.fk_client_id
WHERE customer_email = 'timofey12@gmail.com'

select * from customer