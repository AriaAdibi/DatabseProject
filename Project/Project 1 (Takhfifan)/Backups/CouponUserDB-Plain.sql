--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.3

-- Started on 2016-07-18 22:01:59 IRDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12623)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2441 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 557 (class 1247 OID 17218)
-- Name: PasswordDomain; Type: DOMAIN; Schema: public; Owner: CouponUser DBA staff
--

CREATE DOMAIN "PasswordDomain" AS character varying(128) NOT NULL;


ALTER DOMAIN "PasswordDomain" OWNER TO "CouponUser DBA staff";

--
-- TOC entry 558 (class 1247 OID 17219)
-- Name: cellPhoneNumDomain; Type: DOMAIN; Schema: public; Owner: CouponUser DBA staff
--

CREATE DOMAIN "cellPhoneNumDomain" AS character varying(11)
	CONSTRAINT "allDigitConstraint" CHECK (((VALUE)::text ~ '[\d+]'::text))
	CONSTRAINT "cellPhoneNumLenConstraint" CHECK ((length((VALUE)::text) = 11));


ALTER DOMAIN "cellPhoneNumDomain" OWNER TO "CouponUser DBA staff";

--
-- TOC entry 561 (class 1247 OID 17223)
-- Name: couponCategories; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "couponCategories" AS ENUM (
    'RESTAURANT_COFFEESHOP',
    'ART_THEATER',
    'ENTERTAINMENT_SPORT',
    'EDUCATIONAL',
    'HEALTH_MED',
    'COSMETIC',
    'TRAVEL',
    'GOODS'
);


ALTER TYPE "couponCategories" OWNER TO postgres;

--
-- TOC entry 564 (class 1247 OID 17239)
-- Name: emailDomain; Type: DOMAIN; Schema: public; Owner: CouponUser DBA staff
--

CREATE DOMAIN "emailDomain" AS character varying(320) NOT NULL
	CONSTRAINT "emailConstraint" CHECK (((VALUE)::text ~~ '%@%.%'::text));


ALTER DOMAIN "emailDomain" OWNER TO "CouponUser DBA staff";

--
-- TOC entry 566 (class 1247 OID 17241)
-- Name: nameDomain; Type: DOMAIN; Schema: public; Owner: CouponUser DBA staff
--

CREATE DOMAIN "nameDomain" AS character varying(50);


ALTER DOMAIN "nameDomain" OWNER TO "CouponUser DBA staff";

--
-- TOC entry 567 (class 1247 OID 17242)
-- Name: phoneNumDomain; Type: DOMAIN; Schema: public; Owner: CouponUser DBA staff
--

CREATE DOMAIN "phoneNumDomain" AS character varying(8)
	CONSTRAINT "allDigitConstraint" CHECK (((VALUE)::text ~ '[\d+]'::text))
	CONSTRAINT "phoneLenConstraint" CHECK ((length((VALUE)::text) = 8));


ALTER DOMAIN "phoneNumDomain" OWNER TO "CouponUser DBA staff";

--
-- TOC entry 188 (class 1255 OID 17245)
-- Name: numOfRemainingCoupons(integer); Type: FUNCTION; Schema: public; Owner: CouponUser DBA staff
--

CREATE FUNCTION "numOfRemainingCoupons"("couponId" integer) RETURNS integer
    LANGUAGE sql
    AS $$
SELECT ALL "numOfCoupons"- "numOfSoldCoupons"
FROM "Coupon"
WHERE "Coupon".id = "couponId"
$$;


ALTER FUNCTION public."numOfRemainingCoupons"("couponId" integer) OWNER TO "CouponUser DBA staff";

--
-- TOC entry 189 (class 1255 OID 17246)
-- Name: updateNewCoupons(); Type: FUNCTION; Schema: public; Owner: CouponUser DBA staff
--

CREATE FUNCTION "updateNewCoupons"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO "NewCoupons"
    VALUES(NEW.id, CURRENT_DATE);

    DELETE
    FROM "NewCoupons"
    WHERE "insertDate" < CURRENT_DATE;

  RETURN NEW;
END
$$;


ALTER FUNCTION public."updateNewCoupons"() OWNER TO "CouponUser DBA staff";

--
-- TOC entry 190 (class 1255 OID 17323)
-- Name: updateNumOfSoldCoupons(); Type: FUNCTION; Schema: public; Owner: CouponUser DBA staff
--

CREATE FUNCTION "updateNumOfSoldCoupons"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE "Coupon"
    SET "numOfSoldCoupons" = "numOfSoldCoupons" + NEW.cardinality
    WHERE id = NEW."couponId";

  RETURN NEW;
END
$$;


ALTER FUNCTION public."updateNumOfSoldCoupons"() OWNER TO "CouponUser DBA staff";

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 182 (class 1259 OID 17249)
-- Name: Coupon; Type: TABLE; Schema: public; Owner: CouponUser DBA staff
--

CREATE TABLE "Coupon" (
    id integer NOT NULL,
    category "couponCategories" NOT NULL,
    description text,
    lineaments text,
    "companyName" "nameDomain" NOT NULL,
    "companyAddress" text NOT NULL,
    conditions text,
    "nameAndAShortDescription" character varying(150),
    "numOfCoupons" integer NOT NULL,
    "numOfSoldCoupons" integer DEFAULT 0 NOT NULL,
    "expirationDate" date NOT NULL,
    "originalPrice" money DEFAULT 0 NOT NULL,
    "percentageOff" integer DEFAULT 0 NOT NULL,
    CONSTRAINT "expiredDateConstraints" CHECK ((("expirationDate" > ('now'::text)::date) AND ("expirationDate" < (('now'::text)::date + '3 mons'::interval)))),
    CONSTRAINT "numConstraints" CHECK ((("numOfCoupons" >= 0) AND ("numOfSoldCoupons" >= 0))),
    CONSTRAINT "percentageConstraint" CHECK ((("percentageOff" >= 0) AND ("percentageOff" <= 100)))
);


ALTER TABLE "Coupon" OWNER TO "CouponUser DBA staff";

--
-- TOC entry 183 (class 1259 OID 17262)
-- Name: CouponCompanyPhoneNumber; Type: TABLE; Schema: public; Owner: CouponUser DBA staff
--

CREATE TABLE "CouponCompanyPhoneNumber" (
    "couponId" integer NOT NULL,
    "companyPhoneNumber" "phoneNumDomain" NOT NULL
);


ALTER TABLE "CouponCompanyPhoneNumber" OWNER TO "CouponUser DBA staff";

--
-- TOC entry 181 (class 1259 OID 17247)
-- Name: Coupon_id_seq; Type: SEQUENCE; Schema: public; Owner: CouponUser DBA staff
--

CREATE SEQUENCE "Coupon_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Coupon_id_seq" OWNER TO "CouponUser DBA staff";

--
-- TOC entry 2442 (class 0 OID 0)
-- Dependencies: 181
-- Name: Coupon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: CouponUser DBA staff
--

ALTER SEQUENCE "Coupon_id_seq" OWNED BY "Coupon".id;


--
-- TOC entry 187 (class 1259 OID 17282)
-- Name: NewCoupons; Type: TABLE; Schema: public; Owner: CouponUser DBA staff
--

CREATE TABLE "NewCoupons" (
    "couponId" integer NOT NULL,
    "insertDate" date NOT NULL
);


ALTER TABLE "NewCoupons" OWNER TO "CouponUser DBA staff";

--
-- TOC entry 184 (class 1259 OID 17268)
-- Name: Order; Type: TABLE; Schema: public; Owner: CouponUser DBA staff
--

CREATE TABLE "Order" (
    "userId" integer NOT NULL,
    "couponId" integer NOT NULL,
    "purchaseTime" date DEFAULT ('now'::text)::date NOT NULL,
    cardinality integer NOT NULL,
    code character varying(12) NOT NULL,
    CONSTRAINT "cardinalityConstraints" CHECK (((cardinality > 0) AND (cardinality <= "numOfRemainingCoupons"("couponId")))),
    CONSTRAINT "codeConstraints" CHECK ((length((code)::text) = 12))
);


ALTER TABLE "Order" OWNER TO "CouponUser DBA staff";

--
-- TOC entry 186 (class 1259 OID 17275)
-- Name: User; Type: TABLE; Schema: public; Owner: CouponUser DBA staff
--

CREATE TABLE "User" (
    id integer NOT NULL,
    name "nameDomain" NOT NULL,
    email "emailDomain" NOT NULL,
    "cellPhoneNumber" "cellPhoneNumDomain",
    password "PasswordDomain" NOT NULL
);


ALTER TABLE "User" OWNER TO "CouponUser DBA staff";

--
-- TOC entry 185 (class 1259 OID 17273)
-- Name: User_id_seq; Type: SEQUENCE; Schema: public; Owner: CouponUser DBA staff
--

CREATE SEQUENCE "User_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "User_id_seq" OWNER TO "CouponUser DBA staff";

--
-- TOC entry 2443 (class 0 OID 0)
-- Dependencies: 185
-- Name: User_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: CouponUser DBA staff
--

ALTER SEQUENCE "User_id_seq" OWNED BY "User".id;


--
-- TOC entry 2284 (class 2604 OID 17252)
-- Name: id; Type: DEFAULT; Schema: public; Owner: CouponUser DBA staff
--

ALTER TABLE ONLY "Coupon" ALTER COLUMN id SET DEFAULT nextval('"Coupon_id_seq"'::regclass);


--
-- TOC entry 2294 (class 2604 OID 17278)
-- Name: id; Type: DEFAULT; Schema: public; Owner: CouponUser DBA staff
--

ALTER TABLE ONLY "User" ALTER COLUMN id SET DEFAULT nextval('"User_id_seq"'::regclass);


--
-- TOC entry 2428 (class 0 OID 17249)
-- Dependencies: 182
-- Data for Name: Coupon; Type: TABLE DATA; Schema: public; Owner: CouponUser DBA staff
--

COPY "Coupon" (id, category, description, lineaments, "companyName", "companyAddress", conditions, "nameAndAShortDescription", "numOfCoupons", "numOfSoldCoupons", "expirationDate", "originalPrice", "percentageOff") FROM stdin;
3	ART_THEATER	تخفیف تئاترهای مختلف	کمدی	تئاتر جوان	خیابان مطهری	مراجعه با گروه بالای ۱۰ نفر	مجموعه تئاترهای جوان	500	0	2016-09-03	$70,000.00	90
251	COSMETIC	WYgUIfJgAY	teVEoxtsuu3qmdu	oa0WTJwm16ej	tkP6gRgQz5dn	cMv9EWng2oOFQv	syGipAcm	110	0	2016-09-14	$66,421.00	96
252	GOODS	Q4RukKcrU7I	DsB05m35nhqmf6	GIDp3OQ7g9P	PYEx9pufBIJD	aSbws	N0X9ke9ga	310	0	2016-09-14	$2,261,608.00	79
2	RESTAURANT_COFFEESHOP	تخفیف ساندویچ	ساندویچ‌های سرد	هایدا	خیابان شریعتی	بدون شرط	ساندویچ‌های خوشمزه‌ی هایدا	40	3	2016-09-03	$15,000.00	20
4	TRAVEL	سفر به تمام جهان	پر از شور و هیجان	هواپیماداران جوان	خیابان ملاصدرا	داشتن حوصله	تخفیف ویژه‌ی سفر به سراسر جهان	10	12	2016-08-03	$1,000,000.00	30
253	GOODS	72oyUukdMhc3	xmZyWw8	B2pJNBl	lM2fMkDj	4txcPATUFQx1	MAgPJJeaSFwey	339	0	2016-09-14	$3,869,028.00	7
254	HEALTH_MED	nq3qu3JTsLgjEvj	kg5hliu	Q3S8Nnp0	CetYj	mfIIdIYDf	f0ps4p4yLL	467	0	2016-09-14	$2,663,556.00	84
1	RESTAURANT_COFFEESHOP	تخفیف غذا	غذاهای گرم	رستوران شاندیز	خیابان آفریقا	سن بالای ۱۸ سال	تخفیف ویژه‌ی شاندیز	200	26	2016-08-15	$50,000.00	50
255	ENTERTAINMENT_SPORT	DnRvQ5iXbcMCsl	q3XO7sqaFH	3WBATsi4E	JmmqqMFu	9nVAINr47PILz	KNbfNh	294	0	2016-09-14	$151,623.00	78
256	TRAVEL	sBkCxKD	qyQr4qjuPMnCE41	v7kPX4o2O	Svjm	tE2D8BW	lHsgXgZfiXs	378	0	2016-09-14	$1,276,739.00	31
257	EDUCATIONAL	oHJYZIfg5	XdaaQ4Qo5t	9rWQc	prS14P5X	sJMNlyJIgwN	s54cq3FfJ6J5aet	215	0	2016-09-14	$483,596.00	7
258	TRAVEL	nMvOm	IumiF9D8cskHq	6ySDKXClx	nhCYvhYGrjIRNC	2wRiruCF3koCs	Tt9LX0rVd	457	0	2016-09-14	$2,157,629.00	54
259	RESTAURANT_COFFEESHOP	5LQpWeLA	h2ODjLmRoxw	T5hfOpL	AIxbceikH	HS5Y2zcYpqBl14J	iZ3NHaJ3	206	0	2016-09-14	$3,694,070.00	93
260	EDUCATIONAL	5Jk34vk1LjRBi	THAdrpMqoa9cI	QEdESbCyMrU	K3qn5iR	8f6xbN8YNxAg	mzKd76TkMI	240	0	2016-09-14	$2,691,632.00	53
261	COSMETIC	DJ96JKlOpKlvXL	YKGReqo	nhjURt7	7EQc7rO76U5G7	aacOw8FcehMfF	aG8ue54O1	448	0	2016-09-14	$772,850.00	78
262	TRAVEL	5bq7wPB39IXgg	YJGp	X94LL	ifvnpgvPL	L9FycMApYDv8Xt	9vrbb8bw4jfJSLJ	413	0	2016-09-14	$2,971,419.00	28
263	HEALTH_MED	tPerQ	yAWpC	7HlAn5lZRMUm9	kwrmy	mGNsXb	CdR5Om99	355	0	2016-09-14	$1,349,551.00	43
264	EDUCATIONAL	XnmsOwDhq0m1X	2NvS1	5bncN0QV40k	wUyITQU	jWnGzLPSk1q	FgNkwMH5YDZV1	458	0	2016-09-14	$1,314,297.00	14
265	EDUCATIONAL	sOeM998Nhn6Frn	RJwNNXpU	yrnc4v	Ycm3T1Ppj5rZf	8KDwxL4pGVr0	3hwx	219	0	2016-09-14	$2,631,163.00	93
266	RESTAURANT_COFFEESHOP	RdpLeJ	Dn9jX1Zd	y4YBsNlXCWH34t	gaVEE	00szZOW3vUQF3B	bx6a	159	0	2016-09-14	$1,561,756.00	16
267	EDUCATIONAL	tY2WI3V	BL125LC9c	Pi021LQR89GscP	Cj2TyF	877S	JxzCrYi8wz2I	149	0	2016-09-14	$806,186.00	86
268	TRAVEL	AJQnZ	KoRqcOH1l	3mFe8ANonFo2	irTsW	1lWuxNZR7k	XxUOP	285	0	2016-09-14	$560,429.00	50
269	COSMETIC	CAONxZft2g	v9JV1tdve	HJgcYJGI1fraz2	EoNeWMo	JVPXWSf1mB5Tu	ol5l8Gb	421	0	2016-09-14	$4,531,639.00	70
270	TRAVEL	V6ua2TH3a	S57gD	JG17ogln	XvwW73M2Q	I6VHz	UiTuE85TW	329	0	2016-09-14	$3,701,879.00	24
271	EDUCATIONAL	mkGOimPANBVnwi	outnX0iclM3Xi5	mfrRMaxBTtB4i8w	Wk0Pzb0lMt	aiZPueSrrje	lf2n5TMKpzglv	268	0	2016-09-14	$2,114,867.00	61
272	COSMETIC	lFF4HXfEuo3	PWff4SxCDNVzco	a4b8XkUZP	pN9Xd0caO2L	s1RcFoa6LEVTbch	DyYNMlJ	185	0	2016-09-14	$2,021,458.00	59
273	TRAVEL	UZ6lIp4TV	O3myqn9clSA	9AKCSOMan	3pfK3lqG	WL8qlgzo	NLc0vGfJy3RNw	255	0	2016-09-14	$3,108,066.00	43
274	ART_THEATER	PONEgyog7	AyHqoiN50	4C2mIJPm6nFP	nHEpjmrxVM	uSdBBuGbB	J2hSj6apdfF0n6Z	143	0	2016-09-14	$3,373,790.00	55
275	GOODS	hwl6xunu	w7T8KELo6	QNfrr	5gmzMeNLZxzC	weZNySD7	xAFHemx	239	0	2016-09-14	$2,933,832.00	72
276	HEALTH_MED	Mi2a5W9s7rStR	Ys278Ut9vXA2f	DzUu	BHeynl1Pb7StU4J	YBQdDLuU4qz	zoznw	138	0	2016-09-14	$4,716,464.00	97
277	HEALTH_MED	JheSczANrU5IV	CAbhr	3SdsCpl	8wkEZ232izK	uwmSklJUyTT	iNGuTuLAVp	479	0	2016-09-14	$2,623,144.00	13
278	COSMETIC	aPd16RgCyFg9n	1TfiOe6HT55YRy	nCVbDQ6yLtGB8	OIIbkQjaA	3Cp3	XJnI018q	245	0	2016-09-14	$4,209,957.00	5
279	HEALTH_MED	6FNBj	XJe0IEprn6ci4	qWQsUT00	wpi7R6okLMN	xROML8	37USVgpD	149	0	2016-09-14	$4,861,586.00	89
280	ART_THEATER	3doE	qURJAOoN	vH3rq712c	45fHLBC7c2V	7LdZFg	xRNpjICLL2q7o6s	259	0	2016-09-14	$2,786,814.00	54
281	ART_THEATER	BpbPLRBvlnU	B8uN	5ct9KDHID	D62WrwuKbFciVW	fWrj4sDB1ScV	vWXJAJH4tKP	232	0	2016-09-14	$1,074,552.00	73
282	EDUCATIONAL	HCgSEpmXDBI3	MGQ0X39	TcHuujkQp	D7zh	eSxQP	ZFSSNosi2Oosd	148	0	2016-09-14	$2,893,404.00	10
283	ENTERTAINMENT_SPORT	9mkESOyR0PYA	XjkHJhw	SYgzPWo	z6e5LZ	jgJtEsVkFiHpCJ	CO1RLyXLcOW	365	0	2016-09-14	$4,587,448.00	89
284	EDUCATIONAL	i9pwxZqB	DkC87xdI1S	K1fW8	1TuKfoqN0Zom	ou1apL	L8oPLLmHakDQ	213	0	2016-09-14	$3,131,444.00	20
285	COSMETIC	bTXEb0JGR66nX	V7DINPBj	cz4awaUu6	JUmpcMT	t2ut57uUV5fIR	db19O4NASK	354	0	2016-09-14	$1,010,776.00	61
286	ART_THEATER	3jMlmHqcPQ	1AK0i	dfOlPgrGFUcs9	jpJlJtpDz4czY	Ja2iVJFtQCXQi	8NU7	392	0	2016-09-14	$4,328,501.00	90
287	EDUCATIONAL	sDTp4j5R	LLxViNydk2K	AXzbsZVNA	2NtDRVbxzFXKMdf	h5AV1hjcfKpwlAk	UQCv9SCI8TRVXk6	409	0	2016-09-14	$2,764,338.00	17
288	HEALTH_MED	cAqOoEgIxcYpsmc	2LB6	JIxvhxvEe5AHg0x	WcEvdC	0xGoh5Dl	6anoHprIyO	387	0	2016-09-14	$2,915,296.00	76
289	TRAVEL	FcNU2XLc	L8Zzg51HS	BG3975vGe	GdCwK	iXnl	MoFX	453	0	2016-09-14	$4,221,339.00	24
290	COSMETIC	4K81VyO	RLGWNm2	W6q5eA3uP5TXun	SFWC6aVfH98	LAPAqCf	dWgVh9lf	195	0	2016-09-14	$4,124,630.00	97
291	COSMETIC	LopwWQJXK8I	NbKVcY9	cSrv	A6pXsfRW	hXJhJs49SY3	BXtm	291	0	2016-09-14	$1,887,585.00	76
292	HEALTH_MED	8i07JWZ	Pg2SVv	JHYgkJblaRnPVY	NAJY7tHW3k6r3	SLtErOihygRgwae	K2AToWyLD8veo	345	0	2016-09-14	$2,601,569.00	81
293	EDUCATIONAL	EEILxFPz	BNRhsbauaS8dehG	IWgBV	l9QoMBi8mr	gcTV9Ci6YhZYJ	9JKHzn0d	257	0	2016-09-14	$1,930,857.00	66
294	ART_THEATER	IwrVblsMI8Na	DKiWq	irTYL	CaFXGOiTxu	sPFEDGzEIzb76DK	i30e85SoTC	183	0	2016-09-14	$3,125,615.00	55
295	COSMETIC	FRoz	RK5R0nOsF5Y	wHPsQkadtqHEwq	3iHrEbc4t	taQYmub	E8QOyoaLKapX	443	0	2016-09-14	$3,000,341.00	95
296	ENTERTAINMENT_SPORT	E0vy0P5DhXD5S	dYw9VCxTqS	sIeGRUBVFo	QRitZbb	OzSSi0lfv4C9	hKh6	401	0	2016-09-14	$3,169,008.00	83
297	ART_THEATER	mEjYaiDbxAPn	4nKNh7Is	UjWbR	NKqVWyTdHM	ooMBo	ORcgwv	113	0	2016-09-14	$41,038.00	99
298	TRAVEL	FDMWUvPIerHO	tFNZNE	7qzV33	LILYu	H7rms	zBkqYLhWa	436	0	2016-09-14	$4,766,281.00	75
299	ART_THEATER	m81ITElPWv	PsVXch4Pk	cum6	DlHBwe	tjPF	lHWSl8RHHHSQ	234	0	2016-09-14	$4,027,450.00	57
300	EDUCATIONAL	zKApr	W0LtAg3	IjPC88as7jk	MsWXsglWU9	kkLQJO	5cVkYNKmh	251	0	2016-09-14	$2,834,614.00	46
301	EDUCATIONAL	F5zOw	Z6ix5TNtxOyCb	1vnHpGH	aIi8mC21OnAvHW	s03Rc1OGxDwUg	S7GAWTOfzZX50ia	223	0	2016-09-14	$447,490.00	59
302	TRAVEL	omUwRMT	NadZJhl1iq3PA5l	p4OHh2gZ43y3B	2CWBaRYktw4	ht9LId98o21apav	qfXWHgd8qpLfl	374	0	2016-09-14	$2,751,659.00	35
303	HEALTH_MED	GeonySHvwaqy9	CsLzI	RzKpBLCuT3	tH7s7MZkoBOcE	TBN78dIxZetG	hfQJ5RSiv9	154	0	2016-09-14	$34,153.00	51
304	TRAVEL	rlJnZb2AxSZ9lz	08iASRCNm	92dK0Wr	zC9K1WX	JZObzBLp4P9OWVB	8WzymFY	204	0	2016-09-14	$2,737,558.00	94
305	ART_THEATER	rPiG4Q4unHB	Vma2	vDyKV	eZzkLDM	c75V	bwG8P	406	0	2016-09-14	$2,412,700.00	40
306	RESTAURANT_COFFEESHOP	kd2aTu	hDDkvAPje	83v4pY	mrf0Yy57	gvKFl9Ati	mWDU	161	0	2016-09-14	$886,167.00	68
307	COSMETIC	YfSZeJ	6a1jmJMipjMaMa	6aUfbRYIrcgX5J	K2Yo3JVITp	4W2cNKLmho19	NGN9w2	272	0	2016-09-14	$389,241.00	32
308	COSMETIC	QgG3jBrV	hzlPGO5Fg9wG2g5	Z1C5a4Buq4V5Idk	NXS6lJ4	Y36F	ZthulIj	428	0	2016-09-14	$4,651,335.00	31
309	RESTAURANT_COFFEESHOP	ynGS	gKGG0XmMn923R	5B8DEnKxPUimj	dkatt9ZVO	IEgx	ADkzIiso	317	0	2016-09-14	$185,593.00	64
310	HEALTH_MED	DO7erEQZNy	Y750XZ	p4inDjfKuMt	2io3WCZDrOUukI7	2VauRaVE6LNqk	LF3NpltHy3cU	421	0	2016-09-14	$3,109,403.00	65
311	RESTAURANT_COFFEESHOP	K08CZ5xQDj	rsuzpNcz0	YqIbb5l4cqIxn	BtVE5FjUF	phL0mHcI	xwTYapoUEr	137	0	2016-09-14	$2,447,993.00	35
312	COSMETIC	r1QAZyIR1eYcoyu	w0kmVw	Nitk	pj937wNhXrauoW	Cqbzecf8	RlcJJEBd	125	0	2016-09-14	$2,887,388.00	38
313	GOODS	pC1zdhYPVWOFgP	eEcwXpOKo	xA1HlVcTXQvqhS	H6Ng0V	rU9btR1s4NRl	MuQQslA	313	0	2016-09-14	$4,339,576.00	26
314	EDUCATIONAL	WSix	a03xtQ6qJmh	R4qydN	Fvf3zWEH8i8wonn	SwQfLsb	uwHPhyrVg	285	0	2016-09-14	$2,268,772.00	27
315	EDUCATIONAL	zyNzOSLUeiax12	MZJzJorze5	mZTFFWeIGAr0ayK	LvtO	BCecbMCR	kJYzEhk8H6dEpBu	479	0	2016-09-14	$3,606,159.00	51
316	COSMETIC	nFsE8eEHa0DK	0emyRqIf	MUUuVyjrFc	8wzD	iNE9k	Aq4zP7	366	0	2016-09-14	$4,094,890.00	34
317	RESTAURANT_COFFEESHOP	IDqk0d	1l8BCIy1qwCdV	2J0mQi2itmDeD	hkgf7	zR7P	45sNV3sz	128	0	2016-09-14	$118,429.00	11
318	TRAVEL	GWHRhf	eLNvFd0o	K3nm	iLWh4UYrsf0xJWS	2vyqYj7zKEF	X36O10ypyN	306	0	2016-09-14	$1,610,117.00	75
319	GOODS	hv2H9Zd	FfOO	2IxN18	w3wmCN	5Wb9go4sY	cQnrspVs	183	0	2016-09-14	$1,410,433.00	60
320	COSMETIC	Lixe5OOY0etH8	gvHSHicd	OUboarLjS1FDm	pHOPMWY	QwoQMzHve	20AbuQoUvwN8rb9	480	0	2016-09-14	$628,124.00	68
\.


--
-- TOC entry 2429 (class 0 OID 17262)
-- Dependencies: 183
-- Data for Name: CouponCompanyPhoneNumber; Type: TABLE DATA; Schema: public; Owner: CouponUser DBA staff
--

COPY "CouponCompanyPhoneNumber" ("couponId", "companyPhoneNumber") FROM stdin;
1	22274842
1	88685225
2	22007704
3	22221249
\.


--
-- TOC entry 2444 (class 0 OID 0)
-- Dependencies: 181
-- Name: Coupon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: CouponUser DBA staff
--

SELECT pg_catalog.setval('"Coupon_id_seq"', 320, true);


--
-- TOC entry 2433 (class 0 OID 17282)
-- Dependencies: 187
-- Data for Name: NewCoupons; Type: TABLE DATA; Schema: public; Owner: CouponUser DBA staff
--

COPY "NewCoupons" ("couponId", "insertDate") FROM stdin;
251	2016-07-18
252	2016-07-18
253	2016-07-18
254	2016-07-18
255	2016-07-18
256	2016-07-18
257	2016-07-18
258	2016-07-18
259	2016-07-18
260	2016-07-18
261	2016-07-18
262	2016-07-18
263	2016-07-18
264	2016-07-18
265	2016-07-18
266	2016-07-18
267	2016-07-18
268	2016-07-18
269	2016-07-18
270	2016-07-18
271	2016-07-18
272	2016-07-18
273	2016-07-18
274	2016-07-18
275	2016-07-18
276	2016-07-18
277	2016-07-18
278	2016-07-18
279	2016-07-18
280	2016-07-18
281	2016-07-18
282	2016-07-18
283	2016-07-18
284	2016-07-18
285	2016-07-18
286	2016-07-18
287	2016-07-18
288	2016-07-18
289	2016-07-18
290	2016-07-18
291	2016-07-18
292	2016-07-18
293	2016-07-18
294	2016-07-18
295	2016-07-18
296	2016-07-18
297	2016-07-18
298	2016-07-18
299	2016-07-18
300	2016-07-18
301	2016-07-18
302	2016-07-18
303	2016-07-18
304	2016-07-18
305	2016-07-18
306	2016-07-18
307	2016-07-18
308	2016-07-18
309	2016-07-18
310	2016-07-18
311	2016-07-18
312	2016-07-18
313	2016-07-18
314	2016-07-18
315	2016-07-18
316	2016-07-18
317	2016-07-18
318	2016-07-18
319	2016-07-18
320	2016-07-18
\.


--
-- TOC entry 2430 (class 0 OID 17268)
-- Dependencies: 184
-- Data for Name: Order; Type: TABLE DATA; Schema: public; Owner: CouponUser DBA staff
--

COPY "Order" ("userId", "couponId", "purchaseTime", cardinality, code) FROM stdin;
3	1	2016-07-18	10	0HVMANiJNasd
4	4	2016-07-17	8	PCrHvqXVsZPb
4	2	2016-07-17	3	SZkuhAVZyarY
4	1	2016-07-18	10	Q98Dg4OA4UxR
5	4	2016-07-18	4	0HVMANiJNIV6
5	1	2016-07-18	6	FynKDDEy6ZVO
\.


--
-- TOC entry 2432 (class 0 OID 17275)
-- Dependencies: 186
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: CouponUser DBA staff
--

COPY "User" (id, name, email, "cellPhoneNumber", password) FROM stdin;
4	آریا ادیبی	aria.a1995@gmail.com	09300000000	pbkdf2_sha256$24000$qZeYS2VwH2Ev$ChCC8bDVTnyNtzBDYs4fWE+5N4a7Kko3gIR5E4wzEEg=
5	سیده کوثر کاظمی	kosar.kz@gmail.com	09121230000	pbkdf2_sha256$24000$5pYp86CrIHmg$Sy9J4aB0wh3+4j/+FyTkPZ+pbSJoGlOj1DF+0Z2TLB4=
3	خشایار میرمحمدصادق	mms.khashayar@gmail.com	09364076709	pbkdf2_sha256$24000$BDdYI9JuYQPQ$ok0hfEXJbnGLmdAAEFkBdslkEkmg+ey8qy+UaNjeXpw=
\.


--
-- TOC entry 2445 (class 0 OID 0)
-- Dependencies: 185
-- Name: User_id_seq; Type: SEQUENCE SET; Schema: public; Owner: CouponUser DBA staff
--

SELECT pg_catalog.setval('"User_id_seq"', 5, true);


--
-- TOC entry 2298 (class 2606 OID 17286)
-- Name: CouponCompanyPhoneNumberPK; Type: CONSTRAINT; Schema: public; Owner: CouponUser DBA staff
--

ALTER TABLE ONLY "CouponCompanyPhoneNumber"
    ADD CONSTRAINT "CouponCompanyPhoneNumberPK" PRIMARY KEY ("couponId", "companyPhoneNumber");


--
-- TOC entry 2296 (class 2606 OID 17288)
-- Name: CouponPK; Type: CONSTRAINT; Schema: public; Owner: CouponUser DBA staff
--

ALTER TABLE ONLY "Coupon"
    ADD CONSTRAINT "CouponPK" PRIMARY KEY (id);


--
-- TOC entry 2300 (class 2606 OID 17290)
-- Name: OrderPK; Type: CONSTRAINT; Schema: public; Owner: CouponUser DBA staff
--

ALTER TABLE ONLY "Order"
    ADD CONSTRAINT "OrderPK" PRIMARY KEY ("userId", "couponId");


--
-- TOC entry 2304 (class 2606 OID 17292)
-- Name: UserPK; Type: CONSTRAINT; Schema: public; Owner: CouponUser DBA staff
--

ALTER TABLE ONLY "User"
    ADD CONSTRAINT "UserPK" PRIMARY KEY (id);


--
-- TOC entry 2302 (class 2606 OID 17294)
-- Name: uniqueCode; Type: CONSTRAINT; Schema: public; Owner: CouponUser DBA staff
--

ALTER TABLE ONLY "Order"
    ADD CONSTRAINT "uniqueCode" UNIQUE (code);


--
-- TOC entry 2306 (class 2606 OID 17296)
-- Name: uniqueEmail; Type: CONSTRAINT; Schema: public; Owner: CouponUser DBA staff
--

ALTER TABLE ONLY "User"
    ADD CONSTRAINT "uniqueEmail" UNIQUE (email);


--
-- TOC entry 2311 (class 2620 OID 17297)
-- Name: insertCouponTrigger; Type: TRIGGER; Schema: public; Owner: CouponUser DBA staff
--

CREATE TRIGGER "insertCouponTrigger" AFTER INSERT ON "Coupon" FOR EACH ROW EXECUTE PROCEDURE "updateNewCoupons"();


--
-- TOC entry 2312 (class 2620 OID 17325)
-- Name: insertOrderTrigger; Type: TRIGGER; Schema: public; Owner: CouponUser DBA staff
--

CREATE TRIGGER "insertOrderTrigger" AFTER INSERT ON "Order" FOR EACH ROW EXECUTE PROCEDURE "updateNumOfSoldCoupons"();


--
-- TOC entry 2307 (class 2606 OID 17298)
-- Name: couponIdFK; Type: FK CONSTRAINT; Schema: public; Owner: CouponUser DBA staff
--

ALTER TABLE ONLY "CouponCompanyPhoneNumber"
    ADD CONSTRAINT "couponIdFK" FOREIGN KEY ("couponId") REFERENCES "Coupon"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2308 (class 2606 OID 17303)
-- Name: couponIdFK; Type: FK CONSTRAINT; Schema: public; Owner: CouponUser DBA staff
--

ALTER TABLE ONLY "Order"
    ADD CONSTRAINT "couponIdFK" FOREIGN KEY ("couponId") REFERENCES "Coupon"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2310 (class 2606 OID 17313)
-- Name: couponIdFK; Type: FK CONSTRAINT; Schema: public; Owner: CouponUser DBA staff
--

ALTER TABLE ONLY "NewCoupons"
    ADD CONSTRAINT "couponIdFK" FOREIGN KEY ("couponId") REFERENCES "Coupon"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2309 (class 2606 OID 17308)
-- Name: userIdFK; Type: FK CONSTRAINT; Schema: public; Owner: CouponUser DBA staff
--

ALTER TABLE ONLY "Order"
    ADD CONSTRAINT "userIdFK" FOREIGN KEY ("userId") REFERENCES "User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2440 (class 0 OID 0)
-- Dependencies: 7
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-07-18 22:01:59 IRDT

--
-- PostgreSQL database dump complete
--

