--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 14.4

-- Started on 2022-12-17 22:13:21

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 243 (class 1255 OID 40970)
-- Name: add_to_log(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_to_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    mstr varchar(30);
    astr varchar(100);
    retstr varchar(254);
BEGIN
    IF    TG_OP = 'INSERT' THEN
        astr = NEW.first_name;
        mstr := 'Add new client ';
        retstr := mstr || astr;
        INSERT INTO logger(log_text,log_date,fk_clients_id) values (retstr,NOW(),NEW.pk_clients_id);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        astr = NEW.first_name;
        mstr := 'Update client ';
        retstr := mstr || astr;
        INSERT INTO logger(log_text,log_date,fk_clients_id) values (retstr,NOW(), NEW.pk_clients_id);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        astr = OLD.first_name;
        mstr := 'Remove client ';
        retstr := mstr || astr;
        INSERT INTO logger(log_text,log_date,fk_clients_id) values (retstr,NOW(), null);
        RETURN OLD;
    END IF;
END;
$$;


ALTER FUNCTION public.add_to_log() OWNER TO postgres;

--
-- TOC entry 226 (class 1255 OID 49162)
-- Name: clients_data(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.clients_data()
    LANGUAGE sql
    AS $$
SELECT * FROM clients
$$;


ALTER PROCEDURE public.clients_data() OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 65624)
-- Name: delete_products(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_products() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM product_cart
		WHERE product_cart.cart_id = (SELECT MAX(cart_id) FROM cart);
	RETURN NULL;
END;
$$;


ALTER FUNCTION public.delete_products() OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 65549)
-- Name: insert_product(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_product() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.insert_product() OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 57356)
-- Name: insert_user(integer, character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_user(IN id integer, IN email character varying, IN password character varying, IN cart_number integer)
    LANGUAGE sql
    AS $$
INSERT INTO customer VALUES(id,email,password,cart_number);
$$;


ALTER PROCEDURE public.insert_user(IN id integer, IN email character varying, IN password character varying, IN cart_number integer) OWNER TO postgres;

--
-- TOC entry 229 (class 1255 OID 57357)
-- Name: insert_user_client(integer, character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_user_client(IN id integer, IN email character varying, IN password character varying, IN cart_number integer)
    LANGUAGE sql
    AS $$
INSERT INTO customer VALUES(id,email,password,cart_number);
$$;


ALTER PROCEDURE public.insert_user_client(IN id integer, IN email character varying, IN password character varying, IN cart_number integer) OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 57358)
-- Name: insert_user_manager(integer, character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_user_manager(IN id integer, IN email character varying, IN password character varying, IN cart_number integer)
    LANGUAGE sql
    AS $$
INSERT INTO customer VALUES(id,email,password,null,cart_number);
$$;


ALTER PROCEDURE public.insert_user_manager(IN id integer, IN email character varying, IN password character varying, IN cart_number integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 24834)
-- Name: cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart (
    cart_id integer NOT NULL,
    empty_cart boolean NOT NULL
);


ALTER TABLE public.cart OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 24618)
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    pk_category_id integer NOT NULL,
    category_name character varying(100) NOT NULL
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 24800)
-- Name: clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clients (
    pk_clients_id integer NOT NULL,
    first_name character varying(100) NOT NULL,
    second_name character varying(100) NOT NULL,
    phone_number character varying(30) NOT NULL,
    fk_discount_card_id integer,
    fk_cart_id integer
);


ALTER TABLE public.clients OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 24981)
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    pk_customer_id integer NOT NULL,
    customer_email character varying(32) NOT NULL,
    customer_password character varying(32) NOT NULL,
    fk_client_id integer,
    fk_manager_id integer
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 24817)
-- Name: discount_cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.discount_cards (
    pk_discount_card_id integer NOT NULL,
    number_card character varying(20)
);


ALTER TABLE public.discount_cards OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 40985)
-- Name: logger; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logger (
    id integer NOT NULL,
    log_text character varying(255) NOT NULL,
    log_date date NOT NULL,
    fk_clients_id integer
);


ALTER TABLE public.logger OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 40984)
-- Name: logger_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.logger_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.logger_id_seq OWNER TO postgres;

--
-- TOC entry 3450 (class 0 OID 0)
-- Dependencies: 224
-- Name: logger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.logger_id_seq OWNED BY public.logger.id;


--
-- TOC entry 219 (class 1259 OID 24864)
-- Name: manager; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.manager (
    pk_manager_id integer NOT NULL,
    manager_name character varying(100) NOT NULL,
    manager_second_name character varying(100) NOT NULL,
    phone_number character varying(30)
);


ALTER TABLE public.manager OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 24933)
-- Name: order_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_details (
    pk_order_details integer NOT NULL,
    total_price numeric NOT NULL,
    fk_order_id integer,
    discount integer
);


ALTER TABLE public.order_details OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 24827)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    pk_order_id integer NOT NULL,
    order_number character varying NOT NULL,
    order_date timestamp without time zone NOT NULL,
    sum_order numeric NOT NULL,
    status_order character varying NOT NULL,
    fk_cart_id integer,
    fk_client_id integer
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 24805)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    pk_payments_id integer NOT NULL,
    number_card character varying(40),
    payments_date timestamp without time zone,
    time_transaction time without time zone,
    transaction_status character varying,
    fk_clients_id integer
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 25030)
-- Name: product_cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_cart (
    cart_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer DEFAULT 0
);


ALTER TABLE public.product_cart OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 24997)
-- Name: product_stock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_stock (
    product_id integer NOT NULL,
    stock_id integer NOT NULL
);


ALTER TABLE public.product_stock OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 24610)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    pk_product_id integer NOT NULL,
    product_name character varying(100) NOT NULL,
    price numeric NOT NULL,
    availibility boolean DEFAULT false,
    product_count integer DEFAULT 0,
    fk_category_id integer
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 24854)
-- Name: stock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock (
    pk_stock_id integer NOT NULL,
    date_arrival date NOT NULL,
    stock_name character varying(100),
    fk_manager_id integer
);


ALTER TABLE public.stock OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 24698)
-- Name: waybill; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.waybill (
    pk_waybill_id integer NOT NULL,
    provider character varying(100) NOT NULL,
    fk_manager_id integer
);


ALTER TABLE public.waybill OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 24778)
-- Name: waybill_product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.waybill_product (
    waybill_id integer NOT NULL,
    product_id integer NOT NULL
);


ALTER TABLE public.waybill_product OWNER TO postgres;

--
-- TOC entry 3234 (class 2604 OID 40988)
-- Name: logger id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logger ALTER COLUMN id SET DEFAULT nextval('public.logger_id_seq'::regclass);


--
-- TOC entry 3436 (class 0 OID 24834)
-- Dependencies: 217
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cart (cart_id, empty_cart) VALUES (2, false);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (4, true);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (5, true);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (6, true);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (3, false);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (1, false);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (11, true);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (12, true);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (13, true);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (14, true);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (15, true);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (16, true);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (17, true);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (18, true);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (19, true);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (20, true);
INSERT INTO public.cart (cart_id, empty_cart) VALUES (21, true);


--
-- TOC entry 3429 (class 0 OID 24618)
-- Dependencies: 210
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.categories (pk_category_id, category_name) VALUES (2, 'Овощи');
INSERT INTO public.categories (pk_category_id, category_name) VALUES (3, 'Молочные товары');
INSERT INTO public.categories (pk_category_id, category_name) VALUES (4, 'Фрукты');
INSERT INTO public.categories (pk_category_id, category_name) VALUES (6, 'Мясо');
INSERT INTO public.categories (pk_category_id, category_name) VALUES (1, 'Хлебобулочные изделия');
INSERT INTO public.categories (pk_category_id, category_name) VALUES (5, 'Бакалея');
INSERT INTO public.categories (pk_category_id, category_name) VALUES (7, 'Сладости');


--
-- TOC entry 3432 (class 0 OID 24800)
-- Dependencies: 213
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (2, 'Тимофей', 'Хасанов', '+375338953745', 2, 2);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (5, 'Олег', 'Дебаг', '+375256785049', 5, 5);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (6, 'Никита', 'Шишко', '+375296538440', 6, 6);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (8, 'Миша', 'Шишко', '+375296538440', 6, 6);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (1, 'Mar', 'Сидоренко', '+375336835043', 1, 1);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (4, 'Mar', 'Понасенкова', '+375298989745', 4, 4);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (11, 'Red', 'Sans', '897126374612', NULL, 11);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (12, 'Tim', 'Smith', '+375336835043', NULL, 12);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (13, 'Tim', 'Sid', '123123123123', NULL, 13);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (14, 'asdf', 'asdfa', '234243234', NULL, 14);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (15, 'qwqwe', 'qweqwe', '123124124', NULL, 15);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (16, 'qweqe', 'qweqew', '12124124142', NULL, 16);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (17, 'qweq', 'qweqwe', '851235741234', NULL, 17);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (18, 'hsdfkjhasdf', 'asdfasdf', '12341234123', NULL, 18);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (19, 'aksjdfas', 'asdfasdf', '12341235', NULL, 19);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (20, 'dfasdf', 'asdfasdf', '21341234', NULL, 20);
INSERT INTO public.clients (pk_clients_id, first_name, second_name, phone_number, fk_discount_card_id, fk_cart_id) VALUES (21, 'asdas', 'asdasd', '125765123', NULL, 21);


--
-- TOC entry 3440 (class 0 OID 24981)
-- Dependencies: 221
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (1, 'timofey@gmail.com', '123456789', 1, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (2, 'timofey12@gmail.com', '123456789', NULL, 2);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (4, 'timsid@gmail.com', '123456789', 4, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (5, 'tisid@gmail.com', '23456789', NULL, 3);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (9, 'ljkahsdfjk', 'sadfkahsd', NULL, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (10, 'jhaslkdfj', 'alsd,fkj', NULL, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (11, 'asldjflasjdf', '12341234', NULL, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (12, 'asdlfj;lasd@gmail.com', '123423452346', NULL, 5);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (13, 'timofey2003@gmail.com', '123456789', NULL, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (14, 'admin@gmail.com', 'admin', NULL, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (16, 't@gmail.com', '123', NULL, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (17, 'r@gmail.com', '123', 11, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (19, 'q@gmail.com', '123', NULL, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (20, 'e@gmail.com', '123', NULL, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (21, 'h@gmail.com', '123', NULL, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (22, 'u@gmail.com', '123', 15, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (23, 'ty@gmail.com', '123', NULL, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (24, 'tyr@gmail.com', '123', NULL, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (25, 'pok@gmail.com', '123', 16, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (26, 'io@gmail.com', '123', 17, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (27, '123@gmail.com', '123', 18, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (28, '1@gmail.com', '123', 19, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (29, '2@gmail.com', '123', 20, NULL);
INSERT INTO public.customer (pk_customer_id, customer_email, customer_password, fk_client_id, fk_manager_id) VALUES (30, '23@gmail.com', '123', 21, NULL);


--
-- TOC entry 3434 (class 0 OID 24817)
-- Dependencies: 215
-- Data for Name: discount_cards; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.discount_cards (pk_discount_card_id, number_card) VALUES (1, '12345678987');
INSERT INTO public.discount_cards (pk_discount_card_id, number_card) VALUES (2, '87432456783');
INSERT INTO public.discount_cards (pk_discount_card_id, number_card) VALUES (5, '789125659384');
INSERT INTO public.discount_cards (pk_discount_card_id, number_card) VALUES (3, NULL);
INSERT INTO public.discount_cards (pk_discount_card_id, number_card) VALUES (4, NULL);
INSERT INTO public.discount_cards (pk_discount_card_id, number_card) VALUES (6, '16982341732');


--
-- TOC entry 3444 (class 0 OID 40985)
-- Dependencies: 225
-- Data for Name: logger; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (11, 'Remove client Миша', '2022-11-26', NULL);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (14, 'Remove client Миша', '2022-11-26', NULL);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (15, 'Add new client Олег', '2022-11-26', 8);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (16, 'Update client Миша', '2022-11-26', 8);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (19, 'Update client Mar', '2022-12-16', 1);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (21, 'Update client Mar', '2022-12-16', 4);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (27, 'Add new client Red', '2022-12-16', 11);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (29, 'Remove client E', '2022-12-16', NULL);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (31, 'Remove client Mar', '2022-12-16', NULL);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (32, 'Remove client Никита', '2022-12-16', NULL);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (33, 'Remove client a;lskdjf', '2022-12-16', NULL);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (34, 'Remove client Mark', '2022-12-16', NULL);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (35, 'Add new client Tim', '2022-12-17', 12);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (36, 'Add new client Tim', '2022-12-17', 13);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (37, 'Add new client asdf', '2022-12-17', 14);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (39, 'Remove client esdf', '2022-12-17', NULL);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (40, 'Add new client qwqwe', '2022-12-17', 15);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (41, 'Add new client qweqe', '2022-12-17', 16);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (42, 'Add new client qweq', '2022-12-17', 17);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (43, 'Add new client hsdfkjhasdf', '2022-12-17', 18);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (44, 'Add new client aksjdfas', '2022-12-17', 19);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (45, 'Add new client dfasdf', '2022-12-17', 20);
INSERT INTO public.logger (id, log_text, log_date, fk_clients_id) VALUES (46, 'Add new client asdas', '2022-12-17', 21);


--
-- TOC entry 3438 (class 0 OID 24864)
-- Dependencies: 219
-- Data for Name: manager; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.manager (pk_manager_id, manager_name, manager_second_name, phone_number) VALUES (1, 'Никита', 'Качанов', '+375336985044');
INSERT INTO public.manager (pk_manager_id, manager_name, manager_second_name, phone_number) VALUES (2, 'Светлана', 'Марьянова', '+375297085044');
INSERT INTO public.manager (pk_manager_id, manager_name, manager_second_name, phone_number) VALUES (3, 'Елена', 'Печенько', '+375256984044');
INSERT INTO public.manager (pk_manager_id, manager_name, manager_second_name, phone_number) VALUES (4, 'Kal', 'Man', '1234567892');
INSERT INTO public.manager (pk_manager_id, manager_name, manager_second_name, phone_number) VALUES (5, 'asjdlfjas', 'asdlkjfhajksdf', '71629828347');


--
-- TOC entry 3439 (class 0 OID 24933)
-- Dependencies: 220
-- Data for Name: order_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.order_details (pk_order_details, total_price, fk_order_id, discount) VALUES (1, 123, 1, 20);
INSERT INTO public.order_details (pk_order_details, total_price, fk_order_id, discount) VALUES (2, 1343, 2, 20);
INSERT INTO public.order_details (pk_order_details, total_price, fk_order_id, discount) VALUES (3, 97, 3, 0);
INSERT INTO public.order_details (pk_order_details, total_price, fk_order_id, discount) VALUES (4, 49.5, 6, 0);
INSERT INTO public.order_details (pk_order_details, total_price, fk_order_id, discount) VALUES (5, 1.98, 7, 0);
INSERT INTO public.order_details (pk_order_details, total_price, fk_order_id, discount) VALUES (6, 2.97, 8, 0);


--
-- TOC entry 3435 (class 0 OID 24827)
-- Dependencies: 216
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.orders (pk_order_id, order_number, order_date, sum_order, status_order, fk_cart_id, fk_client_id) VALUES (1, '1', '2022-10-19 10:23:54', 123, 'READY', 1, 1);
INSERT INTO public.orders (pk_order_id, order_number, order_date, sum_order, status_order, fk_cart_id, fk_client_id) VALUES (2, '2', '2022-10-19 11:24:54', 1453, 'COLLECT', 2, 2);
INSERT INTO public.orders (pk_order_id, order_number, order_date, sum_order, status_order, fk_cart_id, fk_client_id) VALUES (3, '3', '2022-12-16 21:45:00', 97, 'IN PROCESS', 11, 11);
INSERT INTO public.orders (pk_order_id, order_number, order_date, sum_order, status_order, fk_cart_id, fk_client_id) VALUES (4, '4', '2022-12-17 01:04:00', 6, 'IN PROCESS', 12, 12);
INSERT INTO public.orders (pk_order_id, order_number, order_date, sum_order, status_order, fk_cart_id, fk_client_id) VALUES (5, '5', '2022-12-17 01:09:00', 20, 'IN PROCESS', 13, 13);
INSERT INTO public.orders (pk_order_id, order_number, order_date, sum_order, status_order, fk_cart_id, fk_client_id) VALUES (6, '6', '2022-12-17 01:13:00', 50, 'IN PROCESS', 14, 14);
INSERT INTO public.orders (pk_order_id, order_number, order_date, sum_order, status_order, fk_cart_id, fk_client_id) VALUES (7, '7', '2022-12-17 15:19:00', 2, 'IN PROCESS', 20, 20);
INSERT INTO public.orders (pk_order_id, order_number, order_date, sum_order, status_order, fk_cart_id, fk_client_id) VALUES (8, '8', '2022-12-17 15:30:00', 3, 'IN PROCESS', 21, 21);


--
-- TOC entry 3433 (class 0 OID 24805)
-- Dependencies: 214
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.payments (pk_payments_id, number_card, payments_date, time_transaction, transaction_status, fk_clients_id) VALUES (1, '12345677889', '2022-10-19 11:23:54', '12:41:54', 'READY', 1);
INSERT INTO public.payments (pk_payments_id, number_card, payments_date, time_transaction, transaction_status, fk_clients_id) VALUES (2, '98765432176', '2022-10-17 11:25:24', '12:40:54', 'NOT CONFIRMED', 2);


--
-- TOC entry 3442 (class 0 OID 25030)
-- Dependencies: 223
-- Data for Name: product_cart; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (1, 1, 6);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (1, 2, 8);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (1, 3, 4);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (2, 1, 2);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (2, 4, 3);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (2, 6, 5);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (3, 1, 2);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (3, 2, 2);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (3, 4, 5);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (3, 5, 1);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (11, 3, 2);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (11, 6, 2);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (11, 2, 1);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (12, 3, 2);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (13, 4, 2);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (14, 5, 5);
INSERT INTO public.product_cart (cart_id, product_id, quantity) VALUES (19, 1, 1);


--
-- TOC entry 3441 (class 0 OID 24997)
-- Dependencies: 222
-- Data for Name: product_stock; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.product_stock (product_id, stock_id) VALUES (1, 1);
INSERT INTO public.product_stock (product_id, stock_id) VALUES (1, 2);
INSERT INTO public.product_stock (product_id, stock_id) VALUES (2, 1);
INSERT INTO public.product_stock (product_id, stock_id) VALUES (2, 2);
INSERT INTO public.product_stock (product_id, stock_id) VALUES (3, 1);


--
-- TOC entry 3428 (class 0 OID 24610)
-- Dependencies: 209
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.products (pk_product_id, product_name, price, availibility, product_count, fk_category_id) VALUES (1, 'Лук репчатый', 2.4, true, 10, 2);
INSERT INTO public.products (pk_product_id, product_name, price, availibility, product_count, fk_category_id) VALUES (2, 'Морковка', 1.5, true, 5, 2);
INSERT INTO public.products (pk_product_id, product_name, price, availibility, product_count, fk_category_id) VALUES (4, 'Арбуз', 10, true, 9, 4);
INSERT INTO public.products (pk_product_id, product_name, price, availibility, product_count, fk_category_id) VALUES (7, 'Огурец свежий', 30, true, 17, 2);
INSERT INTO public.products (pk_product_id, product_name, price, availibility, product_count, fk_category_id) VALUES (5, 'Помидор', 10, true, 6, 2);
INSERT INTO public.products (pk_product_id, product_name, price, availibility, product_count, fk_category_id) VALUES (6, 'Мясо свинины(бедро)', 45, true, 14, 6);
INSERT INTO public.products (pk_product_id, product_name, price, availibility, product_count, fk_category_id) VALUES (3, 'Тварог', 3, true, 8, 3);


--
-- TOC entry 3437 (class 0 OID 24854)
-- Dependencies: 218
-- Data for Name: stock; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.stock (pk_stock_id, date_arrival, stock_name, fk_manager_id) VALUES (2, '2022-11-16', 'Валерьяново', 1);
INSERT INTO public.stock (pk_stock_id, date_arrival, stock_name, fk_manager_id) VALUES (3, '2022-11-15', 'Евроопт', 2);
INSERT INTO public.stock (pk_stock_id, date_arrival, stock_name, fk_manager_id) VALUES (1, '2022-11-17', 'Прибрежный', 1);


--
-- TOC entry 3430 (class 0 OID 24698)
-- Dependencies: 211
-- Data for Name: waybill; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.waybill (pk_waybill_id, provider, fk_manager_id) VALUES (1, 'ООО Рога и копыта', 1);
INSERT INTO public.waybill (pk_waybill_id, provider, fk_manager_id) VALUES (2, 'ООО Бабушкина крынка', 2);


--
-- TOC entry 3431 (class 0 OID 24778)
-- Dependencies: 212
-- Data for Name: waybill_product; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.waybill_product (waybill_id, product_id) VALUES (1, 1);
INSERT INTO public.waybill_product (waybill_id, product_id) VALUES (1, 2);
INSERT INTO public.waybill_product (waybill_id, product_id) VALUES (2, 3);
INSERT INTO public.waybill_product (waybill_id, product_id) VALUES (1, 4);
INSERT INTO public.waybill_product (waybill_id, product_id) VALUES (1, 5);
INSERT INTO public.waybill_product (waybill_id, product_id) VALUES (2, 6);
INSERT INTO public.waybill_product (waybill_id, product_id) VALUES (1, 7);


--
-- TOC entry 3451 (class 0 OID 0)
-- Dependencies: 224
-- Name: logger_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.logger_id_seq', 46, true);


--
-- TOC entry 3264 (class 2606 OID 25034)
-- Name: product_cart cart_product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_cart
    ADD CONSTRAINT cart_product_pkey PRIMARY KEY (cart_id, product_id);


--
-- TOC entry 3252 (class 2606 OID 24838)
-- Name: cart carts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT carts_pkey PRIMARY KEY (cart_id);


--
-- TOC entry 3238 (class 2606 OID 24622)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (pk_category_id);


--
-- TOC entry 3244 (class 2606 OID 24804)
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (pk_clients_id);


--
-- TOC entry 3260 (class 2606 OID 24985)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (pk_customer_id);


--
-- TOC entry 3248 (class 2606 OID 24821)
-- Name: discount_cards discount_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discount_cards
    ADD CONSTRAINT discount_cards_pkey PRIMARY KEY (pk_discount_card_id);


--
-- TOC entry 3266 (class 2606 OID 40990)
-- Name: logger logger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logger
    ADD CONSTRAINT logger_pkey PRIMARY KEY (id);


--
-- TOC entry 3256 (class 2606 OID 24868)
-- Name: manager manager_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manager
    ADD CONSTRAINT manager_pkey PRIMARY KEY (pk_manager_id);


--
-- TOC entry 3258 (class 2606 OID 24939)
-- Name: order_details order_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_pkey PRIMARY KEY (pk_order_details);


--
-- TOC entry 3250 (class 2606 OID 24833)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (pk_order_id);


--
-- TOC entry 3246 (class 2606 OID 24811)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (pk_payments_id);


--
-- TOC entry 3242 (class 2606 OID 24782)
-- Name: waybill_product pk_waybill_product_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.waybill_product
    ADD CONSTRAINT pk_waybill_product_id PRIMARY KEY (waybill_id, product_id);


--
-- TOC entry 3262 (class 2606 OID 25001)
-- Name: product_stock product_stock_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_stock
    ADD CONSTRAINT product_stock_pk PRIMARY KEY (product_id, stock_id);


--
-- TOC entry 3236 (class 2606 OID 24617)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (pk_product_id);


--
-- TOC entry 3254 (class 2606 OID 24858)
-- Name: stock stock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_pkey PRIMARY KEY (pk_stock_id);


--
-- TOC entry 3240 (class 2606 OID 24702)
-- Name: waybill waybill_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.waybill
    ADD CONSTRAINT waybill_pkey PRIMARY KEY (pk_waybill_id);


--
-- TOC entry 3288 (class 2620 OID 65625)
-- Name: orders delete_product_from_product_cart; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER delete_product_from_product_cart AFTER INSERT ON public.orders FOR EACH ROW EXECUTE FUNCTION public.delete_products();


--
-- TOC entry 3286 (class 2620 OID 65550)
-- Name: products insert_product; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER insert_product AFTER INSERT ON public.products FOR EACH ROW EXECUTE FUNCTION public.insert_product();


--
-- TOC entry 3287 (class 2620 OID 40971)
-- Name: clients trigger_clients; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_clients AFTER INSERT OR DELETE OR UPDATE ON public.clients FOR EACH ROW EXECUTE FUNCTION public.add_to_log();


--
-- TOC entry 3271 (class 2606 OID 65561)
-- Name: clients clients_fk_cart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_fk_cart_id_fkey FOREIGN KEY (fk_cart_id) REFERENCES public.cart(cart_id) ON DELETE CASCADE;


--
-- TOC entry 3272 (class 2606 OID 65566)
-- Name: clients clients_fk_discount_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_fk_discount_card_id_fkey FOREIGN KEY (fk_discount_card_id) REFERENCES public.discount_cards(pk_discount_card_id) ON DELETE CASCADE;


--
-- TOC entry 3279 (class 2606 OID 65551)
-- Name: customer customer_fk_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_fk_client_id_fkey FOREIGN KEY (fk_client_id) REFERENCES public.clients(pk_clients_id) ON DELETE CASCADE;


--
-- TOC entry 3280 (class 2606 OID 65556)
-- Name: customer customer_fk_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_fk_manager_id_fkey FOREIGN KEY (fk_manager_id) REFERENCES public.manager(pk_manager_id) ON DELETE CASCADE;


--
-- TOC entry 3267 (class 2606 OID 32778)
-- Name: products fk_category_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_category_id FOREIGN KEY (fk_category_id) REFERENCES public.categories(pk_category_id);


--
-- TOC entry 3268 (class 2606 OID 32783)
-- Name: waybill fk_manager_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.waybill
    ADD CONSTRAINT fk_manager_id FOREIGN KEY (fk_manager_id) REFERENCES public.manager(pk_manager_id);


--
-- TOC entry 3274 (class 2606 OID 24844)
-- Name: orders fkey_cart; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fkey_cart FOREIGN KEY (fk_cart_id) REFERENCES public.cart(cart_id);


--
-- TOC entry 3277 (class 2606 OID 32788)
-- Name: stock fkey_manager_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT fkey_manager_id FOREIGN KEY (fk_manager_id) REFERENCES public.manager(pk_manager_id);


--
-- TOC entry 3285 (class 2606 OID 40991)
-- Name: logger logger_fk_clients_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logger
    ADD CONSTRAINT logger_fk_clients_id_fkey FOREIGN KEY (fk_clients_id) REFERENCES public.clients(pk_clients_id) ON DELETE CASCADE;


--
-- TOC entry 3278 (class 2606 OID 65586)
-- Name: order_details order_details_fk_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_fk_order_id_fkey FOREIGN KEY (fk_order_id) REFERENCES public.orders(pk_order_id) ON DELETE CASCADE;


--
-- TOC entry 3276 (class 2606 OID 65581)
-- Name: orders orders_fk_cart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_fk_cart_id_fkey FOREIGN KEY (fk_cart_id) REFERENCES public.cart(cart_id) ON DELETE CASCADE;


--
-- TOC entry 3275 (class 2606 OID 65576)
-- Name: orders orders_fk_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_fk_client_id_fkey FOREIGN KEY (fk_client_id) REFERENCES public.clients(pk_clients_id) ON DELETE CASCADE;


--
-- TOC entry 3273 (class 2606 OID 65571)
-- Name: payments payments_fk_clients_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_fk_clients_id_fkey FOREIGN KEY (fk_clients_id) REFERENCES public.clients(pk_clients_id) ON DELETE CASCADE;


--
-- TOC entry 3284 (class 2606 OID 65614)
-- Name: product_cart product_cart_cart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_cart
    ADD CONSTRAINT product_cart_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES public.cart(cart_id) ON DELETE CASCADE;


--
-- TOC entry 3283 (class 2606 OID 25040)
-- Name: product_cart product_cart_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_cart
    ADD CONSTRAINT product_cart_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(pk_product_id);


--
-- TOC entry 3281 (class 2606 OID 25002)
-- Name: product_stock product_stock_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_stock
    ADD CONSTRAINT product_stock_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(pk_product_id);


--
-- TOC entry 3282 (class 2606 OID 25007)
-- Name: product_stock product_stock_stock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_stock
    ADD CONSTRAINT product_stock_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.stock(pk_stock_id);


--
-- TOC entry 3270 (class 2606 OID 24788)
-- Name: waybill_product waybill_product_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.waybill_product
    ADD CONSTRAINT waybill_product_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(pk_product_id);


--
-- TOC entry 3269 (class 2606 OID 24783)
-- Name: waybill_product waybill_product_waybill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.waybill_product
    ADD CONSTRAINT waybill_product_waybill_id_fkey FOREIGN KEY (waybill_id) REFERENCES public.waybill(pk_waybill_id);


-- Completed on 2022-12-17 22:13:21

--
-- PostgreSQL database dump complete
--

