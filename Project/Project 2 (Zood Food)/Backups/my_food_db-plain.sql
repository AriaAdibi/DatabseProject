--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.3

-- Started on 2016-07-18 21:23:19

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12355)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2249 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 607 (class 1247 OID 24955)
-- Name: OrderStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "OrderStatus" AS ENUM (
    'pending',
    'approved',
    'delivered',
    'rejected'
);


ALTER TYPE "OrderStatus" OWNER TO postgres;

--
-- TOC entry 566 (class 1247 OID 24792)
-- Name: cellPhoneNumDomain; Type: DOMAIN; Schema: public; Owner: my_food_role
--

CREATE DOMAIN "cellPhoneNumDomain" AS character varying(11)
	CONSTRAINT "allDigitConstraint" CHECK (((VALUE)::text ~ '[\d+]'::text))
	CONSTRAINT "cellPhoneNumLenConstraint" CHECK ((length((VALUE)::text) = 11));


ALTER DOMAIN "cellPhoneNumDomain" OWNER TO my_food_role;

--
-- TOC entry 574 (class 1247 OID 24802)
-- Name: emailDomain; Type: DOMAIN; Schema: public; Owner: my_food_role
--

CREATE DOMAIN "emailDomain" AS character varying(320) NOT NULL
	CONSTRAINT "emailConstraint" CHECK (((VALUE)::text ~ '_%@_%.__%'::text));


ALTER DOMAIN "emailDomain" OWNER TO my_food_role;

--
-- TOC entry 569 (class 1247 OID 24797)
-- Name: nameDomain; Type: DOMAIN; Schema: public; Owner: my_food_role
--

CREATE DOMAIN "nameDomain" AS character varying(50);


ALTER DOMAIN "nameDomain" OWNER TO my_food_role;

--
-- TOC entry 573 (class 1247 OID 24801)
-- Name: passwordDomain; Type: DOMAIN; Schema: public; Owner: my_food_role
--

CREATE DOMAIN "passwordDomain" AS character varying(128) NOT NULL;


ALTER DOMAIN "passwordDomain" OWNER TO my_food_role;

--
-- TOC entry 570 (class 1247 OID 24798)
-- Name: phoneNumDomain; Type: DOMAIN; Schema: public; Owner: my_food_role
--

CREATE DOMAIN "phoneNumDomain" AS character varying(8)
	CONSTRAINT "allDigitConstraint" CHECK (((VALUE)::text ~ '[\d+]'::text))
	CONSTRAINT "phoneLenConstraint" CHECK ((length((VALUE)::text) = 8));


ALTER DOMAIN "phoneNumDomain" OWNER TO my_food_role;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 182 (class 1259 OID 24806)
-- Name: customer; Type: TABLE; Schema: public; Owner: my_food_role
--

CREATE TABLE customer (
    id integer NOT NULL,
    email "emailDomain" NOT NULL,
    password "passwordDomain",
    first_name "nameDomain",
    last_name "nameDomain",
    mobile_number "phoneNumDomain" NOT NULL
);


ALTER TABLE customer OWNER TO my_food_role;

--
-- TOC entry 181 (class 1259 OID 24804)
-- Name: Customer_id_seq; Type: SEQUENCE; Schema: public; Owner: my_food_role
--

CREATE SEQUENCE "Customer_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Customer_id_seq" OWNER TO my_food_role;

--
-- TOC entry 2250 (class 0 OID 0)
-- Dependencies: 181
-- Name: Customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: my_food_role
--

ALTER SEQUENCE "Customer_id_seq" OWNED BY customer.id;


--
-- TOC entry 184 (class 1259 OID 24830)
-- Name: manager; Type: TABLE; Schema: public; Owner: my_food_role
--

CREATE TABLE manager (
    id integer NOT NULL,
    email "emailDomain" NOT NULL,
    password "passwordDomain",
    first_name "nameDomain",
    last_name "nameDomain",
    mobile_number "phoneNumDomain" NOT NULL
);


ALTER TABLE manager OWNER TO my_food_role;

--
-- TOC entry 183 (class 1259 OID 24828)
-- Name: restaurantManager_id_seq; Type: SEQUENCE; Schema: public; Owner: my_food_role
--

CREATE SEQUENCE "restaurantManager_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "restaurantManager_id_seq" OWNER TO my_food_role;

--
-- TOC entry 2251 (class 0 OID 0)
-- Dependencies: 183
-- Name: restaurantManager_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: my_food_role
--

ALTER SEQUENCE "restaurantManager_id_seq" OWNED BY manager.id;


--
-- TOC entry 185 (class 1259 OID 24845)
-- Name: agent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE agent (
    id integer DEFAULT nextval('"restaurantManager_id_seq"'::regclass) NOT NULL,
    email "emailDomain" NOT NULL,
    password "passwordDomain",
    first_name "nameDomain",
    last_name "nameDomain",
    mobile_number "phoneNumDomain" NOT NULL
);


ALTER TABLE agent OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 24965)
-- Name: food; Type: TABLE; Schema: public; Owner: my_food_role
--

CREATE TABLE food (
    id integer NOT NULL,
    name "nameDomain" NOT NULL,
    restaurant_id integer NOT NULL,
    type "nameDomain",
    price money NOT NULL,
    description text,
    image text
);


ALTER TABLE food OWNER TO my_food_role;

--
-- TOC entry 196 (class 1259 OID 24963)
-- Name: food_id_seq; Type: SEQUENCE; Schema: public; Owner: my_food_role
--

CREATE SEQUENCE food_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE food_id_seq OWNER TO my_food_role;

--
-- TOC entry 2252 (class 0 OID 0)
-- Dependencies: 196
-- Name: food_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: my_food_role
--

ALTER SEQUENCE food_id_seq OWNED BY food.id;


--
-- TOC entry 195 (class 1259 OID 24938)
-- Name: order; Type: TABLE; Schema: public; Owner: my_food_role
--

CREATE TABLE "order" (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    restaurant_id integer NOT NULL,
    status "OrderStatus" NOT NULL,
    order_time date
);


ALTER TABLE "order" OWNER TO my_food_role;

--
-- TOC entry 194 (class 1259 OID 24936)
-- Name: order_id_seq; Type: SEQUENCE; Schema: public; Owner: my_food_role
--

CREATE SEQUENCE order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE order_id_seq OWNER TO my_food_role;

--
-- TOC entry 2253 (class 0 OID 0)
-- Dependencies: 194
-- Name: order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: my_food_role
--

ALTER SEQUENCE order_id_seq OWNED BY "order".id;


--
-- TOC entry 199 (class 1259 OID 24983)
-- Name: ordered_food; Type: TABLE; Schema: public; Owner: my_food_role
--

CREATE TABLE ordered_food (
    id integer NOT NULL,
    food_id integer NOT NULL,
    count integer DEFAULT 1 NOT NULL,
    order_id integer NOT NULL,
    CONSTRAINT "countConstraint" CHECK ((count > 0))
);


ALTER TABLE ordered_food OWNER TO my_food_role;

--
-- TOC entry 198 (class 1259 OID 24981)
-- Name: ordered_food_id_seq; Type: SEQUENCE; Schema: public; Owner: my_food_role
--

CREATE SEQUENCE ordered_food_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ordered_food_id_seq OWNER TO my_food_role;

--
-- TOC entry 2254 (class 0 OID 0)
-- Dependencies: 198
-- Name: ordered_food_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: my_food_role
--

ALTER SEQUENCE ordered_food_id_seq OWNED BY ordered_food.id;


--
-- TOC entry 186 (class 1259 OID 24856)
-- Name: region; Type: TABLE; Schema: public; Owner: my_food_role
--

CREATE TABLE region (
    id integer NOT NULL,
    region_name text NOT NULL
);


ALTER TABLE region OWNER TO my_food_role;

--
-- TOC entry 191 (class 1259 OID 24907)
-- Name: region_id_seq; Type: SEQUENCE; Schema: public; Owner: my_food_role
--

CREATE SEQUENCE region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE region_id_seq OWNER TO my_food_role;

--
-- TOC entry 2255 (class 0 OID 0)
-- Dependencies: 191
-- Name: region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: my_food_role
--

ALTER SEQUENCE region_id_seq OWNED BY region.id;


--
-- TOC entry 190 (class 1259 OID 24885)
-- Name: restaurant; Type: TABLE; Schema: public; Owner: my_food_role
--

CREATE TABLE restaurant (
    id integer NOT NULL,
    name "nameDomain" NOT NULL,
    manager_id integer NOT NULL,
    address text NOT NULL,
    phone_number "phoneNumDomain" NOT NULL,
    restaurant_type "nameDomain",
    is_available boolean DEFAULT true NOT NULL,
    image text,
    logo text,
    agent_id integer NOT NULL
);


ALTER TABLE restaurant OWNER TO my_food_role;

--
-- TOC entry 189 (class 1259 OID 24883)
-- Name: restaurant_id_seq; Type: SEQUENCE; Schema: public; Owner: my_food_role
--

CREATE SEQUENCE restaurant_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE restaurant_id_seq OWNER TO my_food_role;

--
-- TOC entry 2256 (class 0 OID 0)
-- Dependencies: 189
-- Name: restaurant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: my_food_role
--

ALTER SEQUENCE restaurant_id_seq OWNED BY restaurant.id;


--
-- TOC entry 188 (class 1259 OID 24869)
-- Name: restaurant_supporting_regions; Type: TABLE; Schema: public; Owner: my_food_role
--

CREATE TABLE restaurant_supporting_regions (
    id integer NOT NULL,
    restaurant_id integer NOT NULL,
    region_id integer NOT NULL
);


ALTER TABLE restaurant_supporting_regions OWNER TO my_food_role;

--
-- TOC entry 187 (class 1259 OID 24867)
-- Name: restaurant_supporting_regions_id_seq; Type: SEQUENCE; Schema: public; Owner: my_food_role
--

CREATE SEQUENCE restaurant_supporting_regions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE restaurant_supporting_regions_id_seq OWNER TO my_food_role;

--
-- TOC entry 2257 (class 0 OID 0)
-- Dependencies: 187
-- Name: restaurant_supporting_regions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: my_food_role
--

ALTER SEQUENCE restaurant_supporting_regions_id_seq OWNED BY restaurant_supporting_regions.id;


--
-- TOC entry 193 (class 1259 OID 24926)
-- Name: session; Type: TABLE; Schema: public; Owner: my_food_role
--

CREATE TABLE session (
    id integer NOT NULL,
    data text
);


ALTER TABLE session OWNER TO my_food_role;

--
-- TOC entry 192 (class 1259 OID 24924)
-- Name: session_id_seq; Type: SEQUENCE; Schema: public; Owner: my_food_role
--

CREATE SEQUENCE session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE session_id_seq OWNER TO my_food_role;

--
-- TOC entry 2258 (class 0 OID 0)
-- Dependencies: 192
-- Name: session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: my_food_role
--

ALTER SEQUENCE session_id_seq OWNED BY session.id;


--
-- TOC entry 2053 (class 2604 OID 24809)
-- Name: id; Type: DEFAULT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY customer ALTER COLUMN id SET DEFAULT nextval('"Customer_id_seq"'::regclass);


--
-- TOC entry 2062 (class 2604 OID 24968)
-- Name: id; Type: DEFAULT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY food ALTER COLUMN id SET DEFAULT nextval('food_id_seq'::regclass);


--
-- TOC entry 2054 (class 2604 OID 24833)
-- Name: id; Type: DEFAULT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY manager ALTER COLUMN id SET DEFAULT nextval('"restaurantManager_id_seq"'::regclass);


--
-- TOC entry 2061 (class 2604 OID 24941)
-- Name: id; Type: DEFAULT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY "order" ALTER COLUMN id SET DEFAULT nextval('order_id_seq'::regclass);


--
-- TOC entry 2063 (class 2604 OID 24986)
-- Name: id; Type: DEFAULT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY ordered_food ALTER COLUMN id SET DEFAULT nextval('ordered_food_id_seq'::regclass);


--
-- TOC entry 2056 (class 2604 OID 24909)
-- Name: id; Type: DEFAULT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY region ALTER COLUMN id SET DEFAULT nextval('region_id_seq'::regclass);


--
-- TOC entry 2058 (class 2604 OID 24888)
-- Name: id; Type: DEFAULT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY restaurant ALTER COLUMN id SET DEFAULT nextval('restaurant_id_seq'::regclass);


--
-- TOC entry 2057 (class 2604 OID 24872)
-- Name: id; Type: DEFAULT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY restaurant_supporting_regions ALTER COLUMN id SET DEFAULT nextval('restaurant_supporting_regions_id_seq'::regclass);


--
-- TOC entry 2060 (class 2604 OID 24929)
-- Name: id; Type: DEFAULT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY session ALTER COLUMN id SET DEFAULT nextval('session_id_seq'::regclass);


--
-- TOC entry 2259 (class 0 OID 0)
-- Dependencies: 181
-- Name: Customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: my_food_role
--

SELECT pg_catalog.setval('"Customer_id_seq"', 1, false);


--
-- TOC entry 2227 (class 0 OID 24845)
-- Dependencies: 185
-- Data for Name: agent; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY agent (id, email, password, first_name, last_name, mobile_number) FROM stdin;
\.


--
-- TOC entry 2224 (class 0 OID 24806)
-- Dependencies: 182
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: my_food_role
--

COPY customer (id, email, password, first_name, last_name, mobile_number) FROM stdin;
\.


--
-- TOC entry 2239 (class 0 OID 24965)
-- Dependencies: 197
-- Data for Name: food; Type: TABLE DATA; Schema: public; Owner: my_food_role
--

COPY food (id, name, restaurant_id, type, price, description, image) FROM stdin;
\.


--
-- TOC entry 2260 (class 0 OID 0)
-- Dependencies: 196
-- Name: food_id_seq; Type: SEQUENCE SET; Schema: public; Owner: my_food_role
--

SELECT pg_catalog.setval('food_id_seq', 1, false);


--
-- TOC entry 2226 (class 0 OID 24830)
-- Dependencies: 184
-- Data for Name: manager; Type: TABLE DATA; Schema: public; Owner: my_food_role
--

COPY manager (id, email, password, first_name, last_name, mobile_number) FROM stdin;
\.


--
-- TOC entry 2237 (class 0 OID 24938)
-- Dependencies: 195
-- Data for Name: order; Type: TABLE DATA; Schema: public; Owner: my_food_role
--

COPY "order" (id, customer_id, restaurant_id, status, order_time) FROM stdin;
\.


--
-- TOC entry 2261 (class 0 OID 0)
-- Dependencies: 194
-- Name: order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: my_food_role
--

SELECT pg_catalog.setval('order_id_seq', 1, false);


--
-- TOC entry 2241 (class 0 OID 24983)
-- Dependencies: 199
-- Data for Name: ordered_food; Type: TABLE DATA; Schema: public; Owner: my_food_role
--

COPY ordered_food (id, food_id, count, order_id) FROM stdin;
\.


--
-- TOC entry 2262 (class 0 OID 0)
-- Dependencies: 198
-- Name: ordered_food_id_seq; Type: SEQUENCE SET; Schema: public; Owner: my_food_role
--

SELECT pg_catalog.setval('ordered_food_id_seq', 1, false);


--
-- TOC entry 2228 (class 0 OID 24856)
-- Dependencies: 186
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: my_food_role
--

COPY region (id, region_name) FROM stdin;
\.


--
-- TOC entry 2263 (class 0 OID 0)
-- Dependencies: 191
-- Name: region_id_seq; Type: SEQUENCE SET; Schema: public; Owner: my_food_role
--

SELECT pg_catalog.setval('region_id_seq', 1, false);


--
-- TOC entry 2232 (class 0 OID 24885)
-- Dependencies: 190
-- Data for Name: restaurant; Type: TABLE DATA; Schema: public; Owner: my_food_role
--

COPY restaurant (id, name, manager_id, address, phone_number, restaurant_type, is_available, image, logo, agent_id) FROM stdin;
\.


--
-- TOC entry 2264 (class 0 OID 0)
-- Dependencies: 183
-- Name: restaurantManager_id_seq; Type: SEQUENCE SET; Schema: public; Owner: my_food_role
--

SELECT pg_catalog.setval('"restaurantManager_id_seq"', 1, false);


--
-- TOC entry 2265 (class 0 OID 0)
-- Dependencies: 189
-- Name: restaurant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: my_food_role
--

SELECT pg_catalog.setval('restaurant_id_seq', 1, false);


--
-- TOC entry 2230 (class 0 OID 24869)
-- Dependencies: 188
-- Data for Name: restaurant_supporting_regions; Type: TABLE DATA; Schema: public; Owner: my_food_role
--

COPY restaurant_supporting_regions (id, restaurant_id, region_id) FROM stdin;
\.


--
-- TOC entry 2266 (class 0 OID 0)
-- Dependencies: 187
-- Name: restaurant_supporting_regions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: my_food_role
--

SELECT pg_catalog.setval('restaurant_supporting_regions_id_seq', 1, false);


--
-- TOC entry 2235 (class 0 OID 24926)
-- Dependencies: 193
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: my_food_role
--

COPY session (id, data) FROM stdin;
\.


--
-- TOC entry 2267 (class 0 OID 0)
-- Dependencies: 192
-- Name: session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: my_food_role
--

SELECT pg_catalog.setval('session_id_seq', 1, false);


--
-- TOC entry 2067 (class 2606 OID 24814)
-- Name: customerPK; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY customer
    ADD CONSTRAINT "customerPK" PRIMARY KEY (id);


--
-- TOC entry 2069 (class 2606 OID 24842)
-- Name: customerUniqueEmail; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY customer
    ADD CONSTRAINT "customerUniqueEmail" UNIQUE (email);


--
-- TOC entry 2093 (class 2606 OID 24973)
-- Name: foodPK; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY food
    ADD CONSTRAINT "foodPK" PRIMARY KEY (id);


--
-- TOC entry 2095 (class 2606 OID 24975)
-- Name: foodUniqueRestaurantFName; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY food
    ADD CONSTRAINT "foodUniqueRestaurantFName" UNIQUE (name, restaurant_id);


--
-- TOC entry 2091 (class 2606 OID 24943)
-- Name: orderPK; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY "order"
    ADD CONSTRAINT "orderPK" PRIMARY KEY (id);


--
-- TOC entry 2097 (class 2606 OID 24990)
-- Name: orderedFoodPK; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY ordered_food
    ADD CONSTRAINT "orderedFoodPK" PRIMARY KEY (id);


--
-- TOC entry 2099 (class 2606 OID 24992)
-- Name: orderedFoodUniqueOrderFood; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY ordered_food
    ADD CONSTRAINT "orderedFoodUniqueOrderFood" UNIQUE (food_id, order_id);


--
-- TOC entry 2075 (class 2606 OID 24853)
-- Name: rAgentPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agent
    ADD CONSTRAINT "rAgentPK" PRIMARY KEY (id);


--
-- TOC entry 2077 (class 2606 OID 24855)
-- Name: rAgentUniqueEmail; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agent
    ADD CONSTRAINT "rAgentUniqueEmail" UNIQUE (email);


--
-- TOC entry 2071 (class 2606 OID 24844)
-- Name: rManagerPK; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY manager
    ADD CONSTRAINT "rManagerPK" PRIMARY KEY (id);


--
-- TOC entry 2073 (class 2606 OID 24840)
-- Name: rManagerUniqueEmail; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY manager
    ADD CONSTRAINT "rManagerUniqueEmail" UNIQUE (email);


--
-- TOC entry 2081 (class 2606 OID 24874)
-- Name: rSupportingRegions; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY restaurant_supporting_regions
    ADD CONSTRAINT "rSupportingRegions" PRIMARY KEY (id);


--
-- TOC entry 2083 (class 2606 OID 24876)
-- Name: rSupportingRegionsUniqueRestaurantRegion; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY restaurant_supporting_regions
    ADD CONSTRAINT "rSupportingRegionsUniqueRestaurantRegion" UNIQUE (restaurant_id, region_id);


--
-- TOC entry 2079 (class 2606 OID 24918)
-- Name: regionPK; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY region
    ADD CONSTRAINT "regionPK" PRIMARY KEY (id);


--
-- TOC entry 2085 (class 2606 OID 24893)
-- Name: restaurantPK; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY restaurant
    ADD CONSTRAINT "restaurantPK" PRIMARY KEY (id);


--
-- TOC entry 2087 (class 2606 OID 24895)
-- Name: restaurantUniqueManagerRName; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY restaurant
    ADD CONSTRAINT "restaurantUniqueManagerRName" UNIQUE (manager_id, name);


--
-- TOC entry 2089 (class 2606 OID 24934)
-- Name: sessionPK; Type: CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY session
    ADD CONSTRAINT "sessionPK" PRIMARY KEY (id);


--
-- TOC entry 2102 (class 2606 OID 25003)
-- Name: agentIdFK; Type: FK CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY restaurant
    ADD CONSTRAINT "agentIdFK" FOREIGN KEY (agent_id) REFERENCES agent(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2104 (class 2606 OID 24944)
-- Name: customerIdFK; Type: FK CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY "order"
    ADD CONSTRAINT "customerIdFK" FOREIGN KEY (customer_id) REFERENCES customer(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2107 (class 2606 OID 24993)
-- Name: foodIdFK; Type: FK CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY ordered_food
    ADD CONSTRAINT "foodIdFK" FOREIGN KEY (food_id) REFERENCES food(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2103 (class 2606 OID 25008)
-- Name: managerIdFK; Type: FK CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY restaurant
    ADD CONSTRAINT "managerIdFK" FOREIGN KEY (manager_id) REFERENCES manager(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2108 (class 2606 OID 24998)
-- Name: orderIdFK; Type: FK CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY ordered_food
    ADD CONSTRAINT "orderIdFK" FOREIGN KEY (order_id) REFERENCES "order"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2101 (class 2606 OID 24919)
-- Name: regionIdFK; Type: FK CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY restaurant_supporting_regions
    ADD CONSTRAINT "regionIdFK" FOREIGN KEY (region_id) REFERENCES region(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2100 (class 2606 OID 24902)
-- Name: restaurantIdFK; Type: FK CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY restaurant_supporting_regions
    ADD CONSTRAINT "restaurantIdFK" FOREIGN KEY (restaurant_id) REFERENCES restaurant(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2105 (class 2606 OID 24949)
-- Name: restaurantIdFK; Type: FK CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY "order"
    ADD CONSTRAINT "restaurantIdFK" FOREIGN KEY (restaurant_id) REFERENCES restaurant(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2106 (class 2606 OID 24976)
-- Name: restaurantIdFK; Type: FK CONSTRAINT; Schema: public; Owner: my_food_role
--

ALTER TABLE ONLY food
    ADD CONSTRAINT "restaurantIdFK" FOREIGN KEY (restaurant_id) REFERENCES restaurant(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2248 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-07-18 21:23:19

--
-- PostgreSQL database dump complete
--

