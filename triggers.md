## Триггеры

## Триггер, отвечающий за логирвание клиента при INSERT, UPDATE

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
