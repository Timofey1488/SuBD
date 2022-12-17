## Триггеры

### 1)Триггер, отвечающий за логирование клиента при INSERT, UPDATE

Тригер вызывает тригерную функцию, которая срабатывает при вставке или обновлении таблицы клиента.
Пример данной функции:

```SQL
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
```
Сам же триггер описывается ниже:

```SQL
CREATE TRIGGER trigger_clients
AFTER INSERT OR UPDATE ON clients 
FOR EACH ROW EXECUTE PROCEDURE add_to_log ();
```

### 2)Триггер, создающий таблицу payments для клиента непостредственно после создания клиента

```SQL
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
```

#### 3)Триггер, удаляющий товары из корзины, когда заказ сформирован
```SQL
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
```
