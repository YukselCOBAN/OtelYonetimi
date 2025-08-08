--
-- PostgreSQL database dump
--

-- Dumped from database version 15.10
-- Dumped by pg_dump version 15.10

-- Started on 2025-08-07 11:44:01

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
-- TOC entry 6 (class 2615 OID 32956)
-- Name: kisi; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA kisi;


ALTER SCHEMA kisi OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 57482)
-- Name: fatura_odeme_durumu_getir(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fatura_odeme_durumu_getir(odeme_idverilen integer) RETURNS TABLE(fatura_id integer, faturaverilmetarihi date, toplamtutar numeric, odemedurumu boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT "Fatura"."fatura_id", "faturaVerilmeTarihi", "toplamTutar","odemeDurumu"
    FROM "Fatura"
    WHERE "Fatura".odeme_id = odeme_idverilen;
END;
$$;


ALTER FUNCTION public.fatura_odeme_durumu_getir(odeme_idverilen integer) OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 65574)
-- Name: hizmet_ekle_musterihizmet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.hizmet_ekle_musterihizmet() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    kisi_id INTEGER;
BEGIN
    
    SELECT "kisi_ID" INTO kisi_id
    FROM "MusteriHizmet"
    WHERE "hizmet_ID" = NEW."hizmet_ID";

    IF kisi_id IS NULL THEN
        
        INSERT INTO "kisi"."Kisi" ("adi", "soyadi", "kisiTipi")
        VALUES ('Yeni', 'Müşteri', TRUE) 
        RETURNING "kisi_ID" INTO kisi_id;
       
    END IF;

    
    IF FOUND THEN
        UPDATE "MusteriHizmet"
        SET "tekrarSayisi" = "tekrarSayisi" + 1
        WHERE "MusteriHizmet"."kisi_ID" = kisi_id AND "hizmet_ID" = NEW."hizmet_ID";
    ELSE
       
        INSERT INTO "MusteriHizmet" ("kisi_ID", "hizmet_ID", "tekrarSayisi")
        VALUES (kisi_id, NEW."hizmet_ID", 1);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.hizmet_ekle_musterihizmet() OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 57478)
-- Name: kategori_adi_iceren_harf(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kategori_adi_iceren_harf(aranan_karakter character varying) RETURNS TABLE(kategori_id integer, kategoriadi character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT "OdaKategorisi".kategori_id, "kategoriAdi"
    FROM "OdaKategorisi"
    WHERE "kategoriAdi" LIKE '%' || aranan_karakter || '%';
END;
$$;


ALTER FUNCTION public.kategori_adi_iceren_harf(aranan_karakter character varying) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 57381)
-- Name: kdvliucret(numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kdvliucret(hizmetucreti numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
BEGIN
    hizmetUcreti := hizmetUcreti * (0.08) + hizmetUcreti;
    RETURN hizmetUcreti;
END;
$$;


ALTER FUNCTION public.kdvliucret(hizmetucreti numeric) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 57444)
-- Name: kisi_silme_trigger_function(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kisi_silme_trigger_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    
    INSERT INTO kisisilmelog ("kisi_ID", adi, soyadi, "kisiTipi")
    VALUES (OLD."kisi_ID", OLD.adi, OLD.soyadi, OLD."kisiTipi");
    
    
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.kisi_silme_trigger_function() OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 65576)
-- Name: odeme_guncelle_rezervasyon(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.odeme_guncelle_rezervasyon() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE "Rezervasyon"
    SET "odemeDurumu" = TRUE
    FROM "Odeme"  
    WHERE "Odeme"."rezervasyon_id" = NEW."rezervasyon_id"
      AND "Rezervasyon"."rezervasyon_id" = NEW."rezervasyon_id";

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.odeme_guncelle_rezervasyon() OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 57477)
-- Name: saatlikucret_buyuk_3(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.saatlikucret_buyuk_3() RETURNS TABLE(kisi_id integer, saatlikucret numeric, calistigisezon character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT "kisi_ID", "saatlikUcret", "calistigiSezon"
    FROM "kisi"."Mevsimlik"
    WHERE "saatlikUcret" > 3.0000;
END;
$$;


ALTER FUNCTION public.saatlikucret_buyuk_3() OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 57390)
-- Name: updateCikisTarihi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."updateCikisTarihi"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   
    IF NEW."cikisTarihi" <> OLD."cikisTarihi" THEN
      
        UPDATE "GirisCikisKayit"
        SET "cikisTarihi" = NEW."cikisTarihi"
        WHERE "rezervasyon_id" = NEW."rezervasyon_id";
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public."updateCikisTarihi"() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 221 (class 1259 OID 32996)
-- Name: Devamli; Type: TABLE; Schema: kisi; Owner: postgres
--

CREATE TABLE kisi."Devamli" (
    "kisi_ID" integer NOT NULL,
    "aylikMaas" numeric(10,5)
);


ALTER TABLE kisi."Devamli" OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 32958)
-- Name: Kisi; Type: TABLE; Schema: kisi; Owner: postgres
--

CREATE TABLE kisi."Kisi" (
    "kisi_ID" integer NOT NULL,
    adi character varying(80),
    soyadi character varying(80),
    "kisiTipi" boolean
);


ALTER TABLE kisi."Kisi" OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 32957)
-- Name: Kisi_kisi_ID_seq; Type: SEQUENCE; Schema: kisi; Owner: postgres
--

CREATE SEQUENCE kisi."Kisi_kisi_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE kisi."Kisi_kisi_ID_seq" OWNER TO postgres;

--
-- TOC entry 3505 (class 0 OID 0)
-- Dependencies: 215
-- Name: Kisi_kisi_ID_seq; Type: SEQUENCE OWNED BY; Schema: kisi; Owner: postgres
--

ALTER SEQUENCE kisi."Kisi_kisi_ID_seq" OWNED BY kisi."Kisi"."kisi_ID";


--
-- TOC entry 222 (class 1259 OID 33006)
-- Name: Mevsimlik; Type: TABLE; Schema: kisi; Owner: postgres
--

CREATE TABLE kisi."Mevsimlik" (
    "kisi_ID" integer NOT NULL,
    "saatlikUcret" numeric(10,5),
    "calistigiSezon" character varying(20)
);


ALTER TABLE kisi."Mevsimlik" OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 32974)
-- Name: Musteri; Type: TABLE; Schema: kisi; Owner: postgres
--

CREATE TABLE kisi."Musteri" (
    "kisi_ID" integer NOT NULL,
    "kayitTarihi" date
);


ALTER TABLE kisi."Musteri" OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 40997)
-- Name: MusteriYedek; Type: TABLE; Schema: kisi; Owner: postgres
--

CREATE TABLE kisi."MusteriYedek" (
    "kisi_ID" integer NOT NULL,
    "kayitTarihi" date
);


ALTER TABLE kisi."MusteriYedek" OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 32964)
-- Name: Personel; Type: TABLE; Schema: kisi; Owner: postgres
--

CREATE TABLE kisi."Personel" (
    "kisi_ID" integer NOT NULL,
    "calisanTipi" boolean,
    "iseAlinmaTarihi" date
);


ALTER TABLE kisi."Personel" OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 33057)
-- Name: Fatura; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Fatura" (
    fatura_id integer NOT NULL,
    "faturaVerilmeTarihi" date,
    "toplamTutar" numeric(10,5),
    "odemeDurumu" boolean,
    odeme_id integer NOT NULL
);


ALTER TABLE public."Fatura" OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 33056)
-- Name: Fatura_fatura_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Fatura_fatura_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Fatura_fatura_id_seq" OWNER TO postgres;

--
-- TOC entry 3506 (class 0 OID 0)
-- Dependencies: 229
-- Name: Fatura_fatura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Fatura_fatura_id_seq" OWNED BY public."Fatura".fatura_id;


--
-- TOC entry 228 (class 1259 OID 33045)
-- Name: GirisCikisKayit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GirisCikisKayit" (
    kayit_id integer NOT NULL,
    "girisTarihi" date,
    "cikisTarihi" date,
    rezervasyon_id integer NOT NULL
);


ALTER TABLE public."GirisCikisKayit" OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 33044)
-- Name: GirisCikisKayit_kayit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."GirisCikisKayit_kayit_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."GirisCikisKayit_kayit_id_seq" OWNER TO postgres;

--
-- TOC entry 3507 (class 0 OID 0)
-- Dependencies: 227
-- Name: GirisCikisKayit_kayit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."GirisCikisKayit_kayit_id_seq" OWNED BY public."GirisCikisKayit".kayit_id;


--
-- TOC entry 236 (class 1259 OID 33117)
-- Name: Hizmet; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Hizmet" (
    "hizmet_ID" integer NOT NULL,
    "hizmetAdi" character varying(150) NOT NULL,
    "hizmetUcreti" numeric(10,5),
    "hizmetTarihi" date
);


ALTER TABLE public."Hizmet" OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 33116)
-- Name: Hizmet_hizmet_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Hizmet_hizmet_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Hizmet_hizmet_ID_seq" OWNER TO postgres;

--
-- TOC entry 3508 (class 0 OID 0)
-- Dependencies: 235
-- Name: Hizmet_hizmet_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Hizmet_hizmet_ID_seq" OWNED BY public."Hizmet"."hizmet_ID";


--
-- TOC entry 220 (class 1259 OID 32985)
-- Name: IletisimBilgileri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."IletisimBilgileri" (
    "iletisim_ID" integer NOT NULL,
    "kisi_ID" integer NOT NULL,
    telefon character varying(15) NOT NULL,
    eposta character varying(80) NOT NULL,
    adres character varying(150) NOT NULL
);


ALTER TABLE public."IletisimBilgileri" OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 32984)
-- Name: IletisimBilgileri_iletisim_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."IletisimBilgileri_iletisim_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."IletisimBilgileri_iletisim_ID_seq" OWNER TO postgres;

--
-- TOC entry 3509 (class 0 OID 0)
-- Dependencies: 219
-- Name: IletisimBilgileri_iletisim_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."IletisimBilgileri_iletisim_ID_seq" OWNED BY public."IletisimBilgileri"."iletisim_ID";


--
-- TOC entry 237 (class 1259 OID 33123)
-- Name: MusteriHizmet; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."MusteriHizmet" (
    "kisi_ID" integer NOT NULL,
    "hizmet_ID" integer NOT NULL,
    "tekrarSayisi" integer NOT NULL
);


ALTER TABLE public."MusteriHizmet" OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 33077)
-- Name: Oda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Oda" (
    oda_id integer NOT NULL,
    "gecelikFiyat" numeric(10,5),
    kategori_id integer NOT NULL
);


ALTER TABLE public."Oda" OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 33070)
-- Name: OdaKategorisi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OdaKategorisi" (
    kategori_id integer NOT NULL,
    "kategoriAdi" character varying(50)
);


ALTER TABLE public."OdaKategorisi" OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 33069)
-- Name: OdaKategorisi_kategori_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."OdaKategorisi_kategori_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."OdaKategorisi_kategori_id_seq" OWNER TO postgres;

--
-- TOC entry 3510 (class 0 OID 0)
-- Dependencies: 231
-- Name: OdaKategorisi_kategori_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."OdaKategorisi_kategori_id_seq" OWNED BY public."OdaKategorisi".kategori_id;


--
-- TOC entry 233 (class 1259 OID 33076)
-- Name: Oda_oda_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Oda_oda_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Oda_oda_id_seq" OWNER TO postgres;

--
-- TOC entry 3511 (class 0 OID 0)
-- Dependencies: 233
-- Name: Oda_oda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Oda_oda_id_seq" OWNED BY public."Oda".oda_id;


--
-- TOC entry 226 (class 1259 OID 33032)
-- Name: Odeme; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Odeme" (
    odeme_id integer NOT NULL,
    "odemeTipi" character varying(20),
    "odemeTutari" numeric(10,5),
    "odemeTarihi" date,
    rezervasyon_id integer NOT NULL
);


ALTER TABLE public."Odeme" OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 33031)
-- Name: Odeme_odeme_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Odeme_odeme_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Odeme_odeme_id_seq" OWNER TO postgres;

--
-- TOC entry 3512 (class 0 OID 0)
-- Dependencies: 225
-- Name: Odeme_odeme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Odeme_odeme_id_seq" OWNED BY public."Odeme".odeme_id;


--
-- TOC entry 239 (class 1259 OID 40982)
-- Name: PersonelHizmet; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PersonelHizmet" (
    "kisi_ID" integer NOT NULL,
    "hizmet_ID" integer NOT NULL,
    "yapanPersonelSayisi" integer NOT NULL
);


ALTER TABLE public."PersonelHizmet" OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 33019)
-- Name: Rezervasyon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Rezervasyon" (
    rezervasyon_id integer NOT NULL,
    "kisi_ID" integer NOT NULL,
    "rezervasyonDurumu" boolean,
    "odemeDurumu" boolean
);


ALTER TABLE public."Rezervasyon" OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 33139)
-- Name: RezervasyonOda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."RezervasyonOda" (
    rezervasyon_id integer NOT NULL,
    oda_id integer NOT NULL,
    "odaDurumu" boolean
);


ALTER TABLE public."RezervasyonOda" OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 33018)
-- Name: Rezervasyon_rezervasyon_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Rezervasyon_rezervasyon_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Rezervasyon_rezervasyon_id_seq" OWNER TO postgres;

--
-- TOC entry 3513 (class 0 OID 0)
-- Dependencies: 223
-- Name: Rezervasyon_rezervasyon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Rezervasyon_rezervasyon_id_seq" OWNED BY public."Rezervasyon".rezervasyon_id;


--
-- TOC entry 242 (class 1259 OID 57455)
-- Name: kisisilmelog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kisisilmelog (
    log_id integer NOT NULL,
    "kisi_ID" integer NOT NULL,
    adi character varying(80),
    soyadi character varying(80),
    "kisiTipi" boolean,
    silinme_tarihi timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.kisisilmelog OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 57454)
-- Name: kisisilmelog_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kisisilmelog_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kisisilmelog_log_id_seq OWNER TO postgres;

--
-- TOC entry 3514 (class 0 OID 0)
-- Dependencies: 241
-- Name: kisisilmelog_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kisisilmelog_log_id_seq OWNED BY public.kisisilmelog.log_id;


--
-- TOC entry 3259 (class 2604 OID 32961)
-- Name: Kisi kisi_ID; Type: DEFAULT; Schema: kisi; Owner: postgres
--

ALTER TABLE ONLY kisi."Kisi" ALTER COLUMN "kisi_ID" SET DEFAULT nextval('kisi."Kisi_kisi_ID_seq"'::regclass);


--
-- TOC entry 3264 (class 2604 OID 33060)
-- Name: Fatura fatura_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Fatura" ALTER COLUMN fatura_id SET DEFAULT nextval('public."Fatura_fatura_id_seq"'::regclass);


--
-- TOC entry 3263 (class 2604 OID 33048)
-- Name: GirisCikisKayit kayit_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GirisCikisKayit" ALTER COLUMN kayit_id SET DEFAULT nextval('public."GirisCikisKayit_kayit_id_seq"'::regclass);


--
-- TOC entry 3267 (class 2604 OID 33120)
-- Name: Hizmet hizmet_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hizmet" ALTER COLUMN "hizmet_ID" SET DEFAULT nextval('public."Hizmet_hizmet_ID_seq"'::regclass);


--
-- TOC entry 3260 (class 2604 OID 32988)
-- Name: IletisimBilgileri iletisim_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."IletisimBilgileri" ALTER COLUMN "iletisim_ID" SET DEFAULT nextval('public."IletisimBilgileri_iletisim_ID_seq"'::regclass);


--
-- TOC entry 3266 (class 2604 OID 33080)
-- Name: Oda oda_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Oda" ALTER COLUMN oda_id SET DEFAULT nextval('public."Oda_oda_id_seq"'::regclass);


--
-- TOC entry 3265 (class 2604 OID 33073)
-- Name: OdaKategorisi kategori_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OdaKategorisi" ALTER COLUMN kategori_id SET DEFAULT nextval('public."OdaKategorisi_kategori_id_seq"'::regclass);


--
-- TOC entry 3262 (class 2604 OID 33035)
-- Name: Odeme odeme_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Odeme" ALTER COLUMN odeme_id SET DEFAULT nextval('public."Odeme_odeme_id_seq"'::regclass);


--
-- TOC entry 3261 (class 2604 OID 33022)
-- Name: Rezervasyon rezervasyon_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon" ALTER COLUMN rezervasyon_id SET DEFAULT nextval('public."Rezervasyon_rezervasyon_id_seq"'::regclass);


--
-- TOC entry 3268 (class 2604 OID 57458)
-- Name: kisisilmelog log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kisisilmelog ALTER COLUMN log_id SET DEFAULT nextval('public.kisisilmelog_log_id_seq'::regclass);


--
-- TOC entry 3478 (class 0 OID 32996)
-- Dependencies: 221
-- Data for Name: Devamli; Type: TABLE DATA; Schema: kisi; Owner: postgres
--

COPY kisi."Devamli" ("kisi_ID", "aylikMaas") FROM stdin;
759	75.12345
760	89.67890
761	123.54321
762	145.98765
763	178.13579
764	199.24680
765	211.35791
766	234.46802
767	256.57913
768	278.68024
769	301.79135
770	323.90246
771	345.01357
772	367.12468
773	390.23579
774	412.34680
775	435.45791
776	456.56802
778	501.79024
779	523.90135
780	545.01246
781	567.12357
782	589.23468
783	610.34579
785	654.56791
\.


--
-- TOC entry 3473 (class 0 OID 32958)
-- Dependencies: 216
-- Data for Name: Kisi; Type: TABLE DATA; Schema: kisi; Owner: postgres
--

COPY kisi."Kisi" ("kisi_ID", adi, soyadi, "kisiTipi") FROM stdin;
688	Elif	Koç	t
689	Hakan	Yıldız	t
690	Serap	Güneş	t
691	Kemal	Polat	t
692	Gül	Arslan	t
693	Cem	Doğan	t
694	Zeynep	Öz	t
695	Can	Eren	t
696	Pelin	Çetin	t
697	Efe	Yıldırım	t
698	Ceren	Gül	t
699	Barış	Aksoy	t
700	Sevim	Korkmaz	t
701	Ebru	Sarı	t
702	Umut	Kaya	t
703	Merve	Öztürk	t
704	Cihan	Kılıç	t
705	Berna	Akın	t
706	Halil	Karadağ	t
707	İrem	Ekinci	t
708	Volkan	Tuna	t
709	Gamze	Şen	t
710	Burak	Çiftçi	t
711	Seda	Bulut	t
712	Onur	Akçay	t
713	Yasemin	Ersoy	t
714	Tuna	Uzun	t
715	Deniz	Akşit	t
716	Gizem	Sezer	t
717	Melih	Gültekin	t
718	Nil	Akay	t
719	Gökhan	Sarıkaya	t
720	Pınar	Kum	t
721	Hasan	Taylan	t
722	Tuğba	Uslu	t
723	İlker	Demirtaş	t
724	Sibel	Korkut	t
725	Ferhat	Başar	t
726	Aslı	Eker	t
727	Taner	Yalçın	t
728	Betül	Atik	t
729	Ozan	Kaplan	t
730	Esra	Başak	t
731	Kaan	Özer	t
732	Buse	Şahin	t
733	Furkan	Çoban	t
734	Nihat	Altay	f
735	Aysun	Ergün	f
736	Turgut	Korkut	f
737	Belgin	Arıkan	f
738	Cevdet	Polat	f
739	Sibel	Tanrıverdi	f
740	Fikret	Boz	f
741	Nur	Karaca	f
742	Okan	İlhan	f
743	Ceyda	Durak	f
744	Neslihan	Gök	f
745	Hakkı	Küçük	f
746	Elvan	Uzun	f
747	Bülent	Aygün	f
748	Reyhan	Çolak	f
749	Hikmet	Bayrak	f
750	Ece	Duman	f
751	Oğuzhan	Zengin	f
752	Selçuk	Göktürk	f
753	Müjgan	Durmuş	f
754	Burçin	Sağlık	f
755	Zekeriya	Taşkın	f
756	Fadime	Baş	f
757	Bekir	Güven	f
758	Lale	Candan	f
759	Güven	Karataş	f
760	Kübra	Doğan	f
761	Rukiye	Altun	f
762	Melek	Erbay	f
763	Suat	Tekin	f
764	Hakan	Can	f
765	Nevzat	Işık	f
766	Esin	Durmuş	f
767	Alper	Kara	f
768	Songül	Şahin	f
769	Yeliz	Akıncı	f
770	Figen	Korkmaz	f
771	Aykut	Erkan	f
772	Erkan	Sarıkaya	f
773	İhsan	Erdem	f
774	Gülşah	Turan	f
775	Veli	Çakır	f
776	Leyla	Arslan	f
778	Dilek	Doğan	f
779	Huriye	Deniz	f
780	Yavuz	Gökhan	f
781	Murat	Aksoy	f
782	Selma	Ekinci	f
783	Ertuğrul	Tuna	f
785	Nazım	Çetin	f
787	Mehmet	Kara	f
685	Fatma	Kalkan	t
686	Mehmet	Kara	t
812	Hasan	Elek	t
813	Elif	Koç	t
\.


--
-- TOC entry 3479 (class 0 OID 33006)
-- Dependencies: 222
-- Data for Name: Mevsimlik; Type: TABLE DATA; Schema: kisi; Owner: postgres
--

COPY kisi."Mevsimlik" ("kisi_ID", "saatlikUcret", "calistigiSezon") FROM stdin;
734	1.23200	Yaz
735	2.34500	Kış
736	3.45600	Yaz
737	4.56700	Kış
738	5.67800	Yaz
739	6.78900	Kış
740	7.89000	Yaz
741	8.90100	Kış
742	9.01200	Yaz
743	10.12300	Kış
744	11.23400	Yaz
745	12.34500	Kış
746	13.45600	Yaz
747	14.56700	Kış
748	15.67800	Yaz
749	16.78900	Kış
750	17.89000	Yaz
751	18.90100	Kış
752	19.01200	Yaz
753	20.12300	Kış
754	21.23400	Yaz
755	22.34500	Kış
756	23.45600	Yaz
757	24.56700	Kış
\.


--
-- TOC entry 3475 (class 0 OID 32974)
-- Dependencies: 218
-- Data for Name: Musteri; Type: TABLE DATA; Schema: kisi; Owner: postgres
--

COPY kisi."Musteri" ("kisi_ID", "kayitTarihi") FROM stdin;
685	2024-01-03
686	2024-01-04
688	2024-01-06
689	2024-01-07
690	2024-01-08
691	2024-01-09
692	2024-01-10
693	2024-01-11
694	2024-01-12
695	2024-01-13
696	2024-01-14
697	2024-01-15
698	2024-01-16
699	2024-01-17
700	2024-01-18
701	2024-01-19
702	2024-01-20
703	2024-01-21
704	2024-01-22
705	2024-01-23
706	2024-01-24
707	2024-01-25
708	2024-01-26
709	2024-01-27
710	2024-01-28
711	2024-01-29
712	2024-01-30
713	2024-01-31
714	2024-02-01
715	2024-02-02
716	2024-02-03
717	2024-02-04
718	2024-02-05
719	2024-02-06
720	2024-02-07
721	2024-02-08
722	2024-02-09
723	2024-02-10
724	2024-02-11
725	2024-02-12
726	2024-02-13
727	2024-02-14
728	2024-02-15
729	2024-02-16
730	2024-02-17
731	2024-02-18
732	2024-02-19
733	2024-02-20
\.


--
-- TOC entry 3497 (class 0 OID 40997)
-- Dependencies: 240
-- Data for Name: MusteriYedek; Type: TABLE DATA; Schema: kisi; Owner: postgres
--

COPY kisi."MusteriYedek" ("kisi_ID", "kayitTarihi") FROM stdin;
683	2024-01-01
684	2024-01-02
685	2024-01-03
686	2024-01-04
687	2024-01-05
688	2024-01-06
689	2024-01-07
690	2024-01-08
691	2024-01-09
692	2024-01-10
693	2024-01-11
694	2024-01-12
695	2024-01-13
696	2024-01-14
697	2024-01-15
698	2024-01-16
699	2024-01-17
700	2024-01-18
701	2024-01-19
702	2024-01-20
703	2024-01-21
704	2024-01-22
705	2024-01-23
706	2024-01-24
707	2024-01-25
708	2024-01-26
709	2024-01-27
710	2024-01-28
711	2024-01-29
712	2024-01-30
713	2024-01-31
714	2024-02-01
715	2024-02-02
716	2024-02-03
717	2024-02-04
718	2024-02-05
719	2024-02-06
720	2024-02-07
721	2024-02-08
722	2024-02-09
723	2024-02-10
724	2024-02-11
725	2024-02-12
726	2024-02-13
727	2024-02-14
728	2024-02-15
729	2024-02-16
730	2024-02-17
731	2024-02-18
732	2024-02-19
733	2024-02-20
\.


--
-- TOC entry 3474 (class 0 OID 32964)
-- Dependencies: 217
-- Data for Name: Personel; Type: TABLE DATA; Schema: kisi; Owner: postgres
--

COPY kisi."Personel" ("kisi_ID", "calisanTipi", "iseAlinmaTarihi") FROM stdin;
734	t	2024-01-01
735	t	2024-01-02
736	t	2024-01-03
737	t	2024-01-04
738	t	2024-01-05
739	t	2024-01-06
740	t	2024-01-07
741	t	2024-01-08
742	t	2024-01-09
743	t	2024-01-10
744	t	2024-01-11
745	t	2024-01-12
746	t	2024-01-13
747	t	2024-01-14
748	t	2024-01-15
749	t	2024-01-16
750	t	2024-01-17
751	t	2024-01-18
752	t	2024-01-19
753	t	2024-01-20
754	t	2024-01-21
755	t	2024-01-22
756	t	2024-01-23
757	t	2024-01-24
758	t	2024-01-25
760	f	2024-01-27
761	f	2024-01-28
762	f	2024-01-29
763	f	2024-01-30
764	f	2024-01-31
765	f	2024-02-01
766	f	2024-02-02
767	f	2024-02-03
768	f	2024-02-04
769	f	2024-02-05
770	f	2024-02-06
771	f	2024-02-07
772	f	2024-02-08
773	f	2024-02-09
774	f	2024-02-10
775	f	2024-02-11
776	f	2024-02-12
778	f	2024-02-14
779	f	2024-02-15
780	f	2024-02-16
781	f	2024-02-17
782	f	2024-02-18
783	f	2024-02-19
785	f	2024-02-21
759	f	2024-09-30
\.


--
-- TOC entry 3487 (class 0 OID 33057)
-- Dependencies: 230
-- Data for Name: Fatura; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Fatura" (fatura_id, "faturaVerilmeTarihi", "toplamTutar", "odemeDurumu", odeme_id) FROM stdin;
105	2024-01-03	950.75000	t	3
106	2024-01-04	1300.00000	f	4
108	2024-01-06	1400.50000	f	6
109	2024-01-07	1150.75000	t	7
110	2024-01-08	1250.00000	f	8
111	2024-01-09	1050.25000	t	9
112	2024-01-10	1350.50000	f	10
113	2024-01-11	1200.00000	t	11
114	2024-01-12	1400.25000	f	12
115	2024-01-13	1150.50000	t	13
116	2024-01-14	1250.75000	f	14
117	2024-01-15	1100.00000	t	15
118	2024-01-16	1300.25000	f	16
119	2024-01-17	1200.50000	t	17
120	2024-01-18	1450.75000	f	18
121	2024-01-19	1250.00000	t	19
122	2024-01-20	1100.25000	f	20
123	2024-01-21	1050.50000	t	21
124	2024-01-22	1300.75000	f	22
125	2024-01-23	1200.00000	t	23
126	2024-01-24	1400.25000	f	24
127	2024-01-25	1250.50000	t	25
128	2024-01-26	1350.75000	f	26
129	2024-01-27	1150.00000	t	27
130	2024-01-28	1450.25000	f	28
131	2024-01-29	1250.50000	t	29
132	2024-01-30	1300.75000	f	30
133	2024-01-31	1200.00000	t	31
134	2024-02-01	1400.25000	f	32
135	2024-02-02	1250.50000	t	33
136	2024-02-03	1350.75000	f	34
137	2024-02-04	1150.00000	t	35
138	2024-02-05	1250.25000	f	36
139	2024-02-06	1300.50000	t	37
140	2024-02-07	1450.75000	f	38
141	2024-02-08	1250.00000	t	39
142	2024-02-09	1350.25000	f	40
143	2024-02-10	1200.50000	t	41
144	2024-02-11	1400.00000	f	42
145	2024-02-12	1250.25000	t	43
146	2024-02-13	1300.50000	f	44
147	2024-02-14	1350.00000	t	45
148	2024-02-15	1200.25000	f	46
149	2024-02-16	1400.50000	t	47
150	2024-02-17	1250.75000	f	48
151	2024-02-18	1350.25000	t	49
152	2024-02-19	1200.00000	f	50
153	2024-02-20	1300.50000	t	51
\.


--
-- TOC entry 3485 (class 0 OID 33045)
-- Dependencies: 228
-- Data for Name: GirisCikisKayit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GirisCikisKayit" (kayit_id, "girisTarihi", "cikisTarihi", rezervasyon_id) FROM stdin;
3	2024-01-03	2024-01-07	3
4	2024-01-04	2024-01-08	4
6	2024-01-06	2024-01-10	6
7	2024-01-07	2024-01-11	7
8	2024-01-08	2024-01-12	8
9	2024-01-09	2024-01-13	9
10	2024-01-10	2024-01-14	10
11	2024-01-11	2024-01-15	11
12	2024-01-12	2024-01-16	12
13	2024-01-13	2024-01-17	13
14	2024-01-14	2024-01-18	14
15	2024-01-15	2024-01-19	15
16	2024-01-16	2024-01-20	16
17	2024-01-17	2024-01-21	17
18	2024-01-18	2024-01-22	18
19	2024-01-19	2024-01-23	19
20	2024-01-20	2024-01-24	20
21	2024-01-21	2024-01-25	21
22	2024-01-22	2024-01-26	22
23	2024-01-23	2024-01-27	23
24	2024-01-24	2024-01-28	24
25	2024-01-25	2024-01-29	25
26	2024-01-26	2024-01-30	26
27	2024-01-27	2024-01-31	27
28	2024-01-28	2024-02-01	28
29	2024-01-29	2024-02-02	29
30	2024-01-30	2024-02-03	30
31	2024-01-31	2024-02-04	31
32	2024-02-01	2024-02-05	32
33	2024-02-02	2024-02-06	33
34	2024-02-03	2024-02-07	34
35	2024-02-04	2024-02-08	35
36	2024-02-05	2024-02-09	36
37	2024-02-06	2024-02-10	37
38	2024-02-07	2024-02-11	38
39	2024-02-08	2024-02-12	39
40	2024-02-09	2024-02-13	40
41	2024-02-10	2024-02-14	41
42	2024-02-11	2024-02-15	42
43	2024-02-12	2024-02-16	43
44	2024-02-13	2024-02-17	44
45	2024-02-14	2024-02-18	45
46	2024-02-15	2024-02-19	46
47	2024-02-16	2024-02-20	47
48	2024-02-17	2024-02-21	48
49	2024-02-18	2024-02-22	49
50	2024-02-19	2024-02-23	50
51	2024-02-20	2024-02-24	51
\.


--
-- TOC entry 3493 (class 0 OID 33117)
-- Dependencies: 236
-- Data for Name: Hizmet; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Hizmet" ("hizmet_ID", "hizmetAdi", "hizmetUcreti", "hizmetTarihi") FROM stdin;
1	Spa	100.35000	2024-01-01
2	Yüzme Havuzu	75.25000	2024-01-02
3	Masaj	120.00000	2024-01-03
4	Sauna	80.75000	2024-01-04
5	Kuru Temizleme	50.00000	2024-01-05
6	Odalarda Kahvaltı	25.50000	2024-01-06
7	Transfer Servisi	150.00000	2024-01-07
8	Concierge Hizmeti	200.00000	2024-01-08
9	Telefon Servisi	10.00000	2024-01-09
10	Çamaşırhane	50.00000	2024-01-10
11	Özel Yat Turu	500.00000	2024-01-11
12	VIP Taşıma	250.00000	2024-01-12
13	Fırın Ürünleri	10.50000	2024-01-13
14	Yazıcı Kullanımı	20.00000	2024-01-14
15	Günlük Oda Temizliği	15.00000	2024-01-15
16	Konferans Salonu	300.00000	2024-01-16
17	Oyun Salonu	40.75000	2024-01-17
18	Özel Eğlence	175.00000	2024-01-18
19	Bebek Bakımı	60.00000	2024-01-19
20	Park Alanı	10.00000	2024-01-20
21	Gemi Turu	450.00000	2024-01-21
22	Kuru Temizleme Servisi	35.00000	2024-01-22
23	Akşam Yemeği	125.00000	2024-01-23
24	Kendi Odanızda Sinema	200.50000	2024-01-24
25	Spor Salonu	80.00000	2024-01-25
26	Piknik Alanı	30.25000	2024-01-26
27	Müzik Dinletisi	100.50000	2024-01-27
28	Özel Partiler	300.00000	2024-01-28
29	Hızlı İnternet	15.00000	2024-01-29
30	Yaz Kampı	400.00000	2024-01-30
31	Yoga	50.00000	2024-01-31
32	Sağlık Danışmanlığı	200.25000	2024-02-01
33	Yüzme Dersi	150.00000	2024-02-02
34	Çocuk Kulübü	125.00000	2024-02-03
35	Bahçe Düzenlemesi	60.00000	2024-02-04
36	Güneşlenme Alanı	25.50000	2024-02-05
37	Müşteri Hizmetleri	10.00000	2024-02-06
38	Ziyaretçi Kabulu	50.00000	2024-02-07
39	Akşam Yemeği Servisi	100.50000	2024-02-08
40	Yatak Konforu	75.25000	2024-02-09
41	Kahvaltı Servisi	20.00000	2024-02-10
42	Mikrofon Kiralama	40.00000	2024-02-11
43	Kahve Molası	30.00000	2024-02-12
44	Deniz Turu	200.00000	2024-02-13
45	Özel Eğlenceler	300.00000	2024-02-14
46	Restoran Rezervasyonu	15.50000	2024-02-15
47	Hediye Paketi	50.00000	2024-02-16
48	Gemi Gezisi	350.00000	2024-02-17
49	Beyaz Eşya Kiralama	200.00000	2024-02-18
51	Açık Hava Sineması	10.00000	2024-02-20
52	Oda Servisi	80.00000	2024-02-21
53	Kayak Turu	350.00000	2024-02-22
54	İçecek Servisi	15.25000	2024-02-23
55	Yat Kiralama	500.00000	2024-02-24
56	Lounge Alanı	30.00000	2024-02-25
57	Açık Büfe Kahvaltı	100.00000	2024-02-26
58	Futbol Sahası	250.00000	2024-02-27
59	Balo Salonu	300.00000	2024-02-28
60	Doğal Kaynak Suyu	20.50000	2024-02-29
61	Sauna	100.00000	2024-12-19
83	Temizlik Hizmeti	5.00205	2024-07-01
\.


--
-- TOC entry 3477 (class 0 OID 32985)
-- Dependencies: 220
-- Data for Name: IletisimBilgileri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."IletisimBilgileri" ("iletisim_ID", "kisi_ID", telefon, eposta, adres) FROM stdin;
3	685	05648763454	kisi685@example.com	Cumhuriyet Mah., 25 Nolu Sokak, No: 17
6	688	05648763457	kisi688@example.com	Bahçelievler Mah., 28 Nolu Sokak, No: 20
7	689	05648763458	kisi689@example.com	Huzur Mah., 29 Nolu Sokak, No: 21
8	690	05648763459	kisi690@example.com	Huzur Mah., 30 Nolu Sokak, No: 22
9	691	05648763460	kisi691@example.com	Güzeltepe Mah., 31 Nolu Sokak, No: 23
10	692	05648763461	kisi692@example.com	Güzeltepe Mah., 32 Nolu Sokak, No: 24
11	693	05648763462	kisi693@example.com	Yıldız Mah., 33 Nolu Sokak, No: 25
12	694	05648763463	kisi694@example.com	Yıldız Mah., 34 Nolu Sokak, No: 26
13	695	05648763464	kisi695@example.com	Ormanlı Mah., 35 Nolu Sokak, No: 27
14	696	05648763465	kisi696@example.com	Ormanlı Mah., 36 Nolu Sokak, No: 28
15	697	05648763466	kisi697@example.com	Aydınlı Mah., 37 Nolu Sokak, No: 29
16	698	05648763467	kisi698@example.com	Aydınlı Mah., 38 Nolu Sokak, No: 30
17	699	05648763468	kisi699@example.com	Saray Mah., 39 Nolu Sokak, No: 31
18	700	05648763469	kisi700@example.com	Saray Mah., 40 Nolu Sokak, No: 32
19	701	05648763470	kisi701@example.com	Fatih Mah., 41 Nolu Sokak, No: 33
20	702	05648763471	kisi702@example.com	Fatih Mah., 42 Nolu Sokak, No: 34
21	703	05648763472	kisi703@example.com	Mavişehir Mah., 43 Nolu Sokak, No: 35
22	704	05648763473	kisi704@example.com	Mavişehir Mah., 44 Nolu Sokak, No: 36
23	705	05648763474	kisi705@example.com	İsmetpaşa Mah., 45 Nolu Sokak, No: 37
24	706	05648763475	kisi706@example.com	İsmetpaşa Mah., 46 Nolu Sokak, No: 38
25	707	05648763476	kisi707@example.com	Vatan Mah., 47 Nolu Sokak, No: 39
26	708	05648763477	kisi708@example.com	Vatan Mah., 48 Nolu Sokak, No: 40
27	709	05648763478	kisi709@example.com	Kocatepe Mah., 49 Nolu Sokak, No: 41
28	710	05648763479	kisi710@example.com	Kocatepe Mah., 50 Nolu Sokak, No: 42
29	711	05648763480	kisi711@example.com	Dumlupınar Mah., 51 Nolu Sokak, No: 43
30	712	05648763481	kisi712@example.com	Dumlupınar Mah., 52 Nolu Sokak, No: 44
31	713	05648763482	kisi713@example.com	Aksaray Mah., 53 Nolu Sokak, No: 45
32	714	05648763483	kisi714@example.com	Aksaray Mah., 54 Nolu Sokak, No: 46
33	715	05648763484	kisi715@example.com	İstiklal Mah., 55 Nolu Sokak, No: 47
34	716	05648763485	kisi716@example.com	İstiklal Mah., 56 Nolu Sokak, No: 48
35	717	05648763486	kisi717@example.com	Ekinci Mah., 57 Nolu Sokak, No: 49
36	718	05648763487	kisi718@example.com	Ekinci Mah., 58 Nolu Sokak, No: 50
37	719	05648763488	kisi719@example.com	Süleymanpaşa Mah., 59 Nolu Sokak, No: 51
38	720	05648763489	kisi720@example.com	Süleymanpaşa Mah., 60 Nolu Sokak, No: 52
39	721	05648763490	kisi721@example.com	Kocatepe Mah., 61 Nolu Sokak, No: 53
40	722	05648763491	kisi722@example.com	Kocatepe Mah., 62 Nolu Sokak, No: 54
41	723	05648763492	kisi723@example.com	Yavuzselim Mah., 63 Nolu Sokak, No: 55
42	724	05648763493	kisi724@example.com	Yavuzselim Mah., 64 Nolu Sokak, No: 56
43	725	05648763494	kisi725@example.com	Yenişehir Mah., 65 Nolu Sokak, No: 57
44	726	05648763495	kisi726@example.com	Yenişehir Mah., 66 Nolu Sokak, No: 58
45	727	05648763496	kisi727@example.com	Emek Mah., 67 Nolu Sokak, No: 59
46	728	05648763497	kisi728@example.com	Emek Mah., 68 Nolu Sokak, No: 60
47	729	05648763498	kisi729@example.com	Süleymanpaşa Mah., 69 Nolu Sokak, No: 61
48	730	05648763499	kisi730@example.com	Süleymanpaşa Mah., 70 Nolu Sokak, No: 62
49	731	05648763500	kisi731@example.com	Vatan Mah., 71 Nolu Sokak, No: 63
50	732	05648763501	kisi732@example.com	Vatan Mah., 72 Nolu Sokak, No: 64
51	733	05648763502	kisi733@example.com	Kocatepe Mah., 73 Nolu Sokak, No: 65
52	734	05648763503	kisi734@example.com	Kocatepe Mah., 74 Nolu Sokak, No: 66
53	735	05648763504	kisi735@example.com	Fatih Mah., 75 Nolu Sokak, No: 67
54	736	05648763505	kisi736@example.com	Fatih Mah., 76 Nolu Sokak, No: 68
55	737	05648763506	kisi737@example.com	Mavişehir Mah., 77 Nolu Sokak, No: 69
56	738	05648763507	kisi738@example.com	Mavişehir Mah., 78 Nolu Sokak, No: 70
57	739	05648763508	kisi739@example.com	İsmetpaşa Mah., 79 Nolu Sokak, No: 71
58	740	05648763509	kisi740@example.com	İsmetpaşa Mah., 80 Nolu Sokak, No: 72
59	741	05648763510	kisi741@example.com	Vatan Mah., 81 Nolu Sokak, No: 73
60	742	05648763511	kisi742@example.com	Vatan Mah., 82 Nolu Sokak, No: 74
61	743	05648763512	kisi743@example.com	Kocatepe Mah., 83 Nolu Sokak, No: 75
62	744	05648763513	kisi744@example.com	Kocatepe Mah., 84 Nolu Sokak, No: 76
63	745	05648763514	kisi745@example.com	Dumlupınar Mah., 85 Nolu Sokak, No: 77
64	746	05648763515	kisi746@example.com	Dumlupınar Mah., 86 Nolu Sokak, No: 78
65	747	05648763516	kisi747@example.com	Aksaray Mah., 87 Nolu Sokak, No: 79
66	748	05648763517	kisi748@example.com	Aksaray Mah., 88 Nolu Sokak, No: 80
67	749	05648763518	kisi749@example.com	İstiklal Mah., 89 Nolu Sokak, No: 81
68	750	05648763519	kisi750@example.com	İstiklal Mah., 90 Nolu Sokak, No: 82
69	751	05648763520	kisi751@example.com	Ekinci Mah., 91 Nolu Sokak, No: 83
70	752	05648763521	kisi752@example.com	Ekinci Mah., 92 Nolu Sokak, No: 84
71	753	05648763522	kisi753@example.com	Süleymanpaşa Mah., 93 Nolu Sokak, No: 85
72	754	05648763523	kisi754@example.com	Süleymanpaşa Mah., 94 Nolu Sokak, No: 86
73	755	05648763524	kisi755@example.com	Kocatepe Mah., 95 Nolu Sokak, No: 87
74	756	05648763525	kisi756@example.com	Kocatepe Mah., 96 Nolu Sokak, No: 88
75	757	05648763526	kisi757@example.com	Fatih Mah., 97 Nolu Sokak, No: 89
76	758	05648763527	kisi758@example.com	Fatih Mah., 98 Nolu Sokak, No: 90
77	759	05648763528	kisi759@example.com	Mavişehir Mah., 99 Nolu Sokak, No: 91
78	760	05648763529	kisi760@example.com	Mavişehir Mah., 100 Nolu Sokak, No: 92
79	761	05648763530	kisi761@example.com	İsmetpaşa Mah., 101 Nolu Sokak, No: 93
80	762	05648763531	kisi762@example.com	İsmetpaşa Mah., 102 Nolu Sokak, No: 94
81	763	05648763532	kisi763@example.com	Vatan Mah., 103 Nolu Sokak, No: 95
82	764	05648763533	kisi764@example.com	Vatan Mah., 104 Nolu Sokak, No: 96
83	765	05648763534	kisi765@example.com	Kocatepe Mah., 105 Nolu Sokak, No: 97
84	766	05648763535	kisi766@example.com	Kocatepe Mah., 106 Nolu Sokak, No: 98
85	767	05648763536	kisi767@example.com	Dumlupınar Mah., 107 Nolu Sokak, No: 99
86	768	05648763537	kisi768@example.com	Dumlupınar Mah., 108 Nolu Sokak, No: 100
87	769	05648763538	kisi769@example.com	Aksaray Mah., 109 Nolu Sokak, No: 101
88	770	05648763539	kisi770@example.com	Aksaray Mah., 110 Nolu Sokak, No: 102
89	771	05648763540	kisi771@example.com	İstiklal Mah., 111 Nolu Sokak, No: 103
90	772	05648763541	kisi772@example.com	İstiklal Mah., 112 Nolu Sokak, No: 104
91	773	05648763542	kisi773@example.com	Ekinci Mah., 113 Nolu Sokak, No: 105
92	774	05648763543	kisi774@example.com	Ekinci Mah., 114 Nolu Sokak, No: 106
93	775	05648763544	kisi775@example.com	Süleymanpaşa Mah., 115 Nolu Sokak, No: 107
94	776	05648763545	kisi776@example.com	Süleymanpaşa Mah., 116 Nolu Sokak, No: 108
96	778	05648763547	kisi778@example.com	Kocatepe Mah., 118 Nolu Sokak, No: 110
97	779	05648763548	kisi779@example.com	Fatih Mah., 119 Nolu Sokak, No: 111
98	780	05648763549	kisi780@example.com	Fatih Mah., 120 Nolu Sokak, No: 112
99	781	05648763550	kisi781@example.com	Mavişehir Mah., 121 Nolu Sokak, No: 113
100	782	05648763551	kisi782@example.com	Mavişehir Mah., 122 Nolu Sokak, No: 114
101	783	05648763552	kisi783@example.com	İsmetpaşa Mah., 123 Nolu Sokak, No: 115
103	785	05648763554	kisi785@example.com	Vatan Mah., 125 Nolu Sokak, No: 117
104	686	05648763455	kisi686@example.com	Cumhuriyet Mah., 26 Nolu Sokak, No: 18
\.


--
-- TOC entry 3494 (class 0 OID 33123)
-- Dependencies: 237
-- Data for Name: MusteriHizmet; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."MusteriHizmet" ("kisi_ID", "hizmet_ID", "tekrarSayisi") FROM stdin;
685	3	4
686	4	1
688	6	5
689	7	3
690	8	4
691	9	2
692	10	3
693	11	1
694	12	5
695	13	4
696	14	2
697	15	3
698	16	1
699	17	5
700	18	4
701	19	2
702	20	3
703	21	1
704	22	5
705	23	4
706	24	2
707	25	3
708	26	4
709	27	2
710	28	5
711	29	1
712	30	3
713	31	4
714	32	2
715	33	3
716	34	5
717	35	4
718	36	1
719	37	2
720	38	5
721	39	4
722	40	3
723	41	2
724	42	5
725	43	3
726	44	4
727	45	1
728	46	5
729	47	3
730	48	2
731	49	4
733	51	5
685	54	3
686	55	1
688	57	4
689	58	3
690	59	2
691	60	5
685	1	1
\.


--
-- TOC entry 3491 (class 0 OID 33077)
-- Dependencies: 234
-- Data for Name: Oda; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Oda" (oda_id, "gecelikFiyat", kategori_id) FROM stdin;
1	125.50000	1
2	150.75000	2
3	180.25000	3
4	100.00000	4
5	135.75000	5
6	155.50000	6
7	200.00000	7
8	175.00000	8
9	190.25000	9
10	140.50000	10
11	160.75000	11
12	130.00000	12
13	180.50000	13
14	155.00000	14
15	110.25000	15
16	195.50000	16
17	145.75000	17
18	170.25000	18
19	185.50000	19
20	125.75000	20
21	165.00000	21
22	145.50000	22
23	155.75000	23
24	200.50000	24
25	175.75000	25
26	140.25000	26
27	135.00000	27
28	160.50000	28
29	190.00000	29
30	185.25000	30
31	150.75000	31
32	145.00000	32
33	175.50000	33
34	200.75000	34
35	110.00000	35
36	135.25000	36
37	150.50000	37
38	190.75000	38
39	165.50000	39
40	140.75000	40
41	180.00000	41
42	175.25000	42
43	155.50000	43
44	200.25000	44
45	145.00000	45
46	125.50000	46
47	180.75000	47
48	190.00000	48
49	150.25000	49
50	135.75000	50
51	165.00000	51
\.


--
-- TOC entry 3489 (class 0 OID 33070)
-- Dependencies: 232
-- Data for Name: OdaKategorisi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."OdaKategorisi" (kategori_id, "kategoriAdi") FROM stdin;
1	Standart Oda
2	Standart Oda
3	Standart Oda
4	Standart Oda
5	Standart Oda
6	Standart Oda
7	Standart Oda
8	Standart Oda
9	Deluxe Oda
10	Deluxe Oda
11	Deluxe Oda
12	Deluxe Oda
13	Deluxe Oda
14	Deluxe Oda
15	Deluxe Oda
16	Deluxe Oda
17	Süit Oda
18	Süit Oda
19	Süit Oda
20	Süit Oda
21	Süit Oda
22	Süit Oda
23	Süit Oda
24	Süit Oda
25	Kral Dairesi
26	Kral Dairesi
27	Kral Dairesi
28	Kral Dairesi
29	Kral Dairesi
30	Çift Kişilik Oda
31	Çift Kişilik Oda
32	Çift Kişilik Oda
33	Çift Kişilik Oda
34	Tek Kişilik Oda
35	Tek Kişilik Oda
36	Tek Kişilik Oda
37	Tek Kişilik Oda
38	Aile Odası
39	Aile Odası
40	Aile Odası
41	Aile Odası
42	Ekonomik Oda
43	Ekonomik Oda
44	Ekonomik Oda
45	Ekonomik Oda
46	Manzaralı Oda
47	Manzaralı Oda
48	Manzaralı Oda
49	Manzaralı Oda
50	Lüks Süit
51	Lüks Süit
\.


--
-- TOC entry 3483 (class 0 OID 33032)
-- Dependencies: 226
-- Data for Name: Odeme; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Odeme" (odeme_id, "odemeTipi", "odemeTutari", "odemeTarihi", rezervasyon_id) FROM stdin;
3	Kredi Kartı	2123.34000	2024-01-03	3
4	Nakit	1500.75000	2024-01-04	4
6	Nakit	1950.26000	2024-01-06	6
7	Kredi Kartı	1800.49000	2024-01-07	7
8	Nakit	2340.51000	2024-01-08	8
9	Kredi Kartı	1280.73000	2024-01-09	9
10	Nakit	1390.64000	2024-01-10	10
11	Kredi Kartı	1530.22000	2024-01-11	11
12	Nakit	1410.80000	2024-01-12	12
13	Kredi Kartı	1600.32000	2024-01-13	13
14	Nakit	1720.19000	2024-01-14	14
15	Kredi Kartı	1450.68000	2024-01-15	15
16	Nakit	1870.90000	2024-01-16	16
17	Kredi Kartı	1930.22000	2024-01-17	17
18	Nakit	2040.74000	2024-01-18	18
19	Kredi Kartı	1290.12000	2024-01-19	19
20	Nakit	1560.35000	2024-01-20	20
21	Kredi Kartı	1640.77000	2024-01-21	21
22	Nakit	1750.65000	2024-01-22	22
23	Kredi Kartı	1860.48000	2024-01-23	23
24	Nakit	1930.29000	2024-01-24	24
25	Kredi Kartı	2050.12000	2024-01-25	25
26	Nakit	2100.20000	2024-01-26	26
27	Kredi Kartı	2210.34000	2024-01-27	27
28	Nakit	2300.15000	2024-01-28	28
29	Kredi Kartı	2410.50000	2024-01-29	29
30	Nakit	2500.74000	2024-01-30	30
31	Kredi Kartı	2620.22000	2024-01-31	31
32	Nakit	2730.40000	2024-02-01	32
33	Kredi Kartı	2840.55000	2024-02-02	33
34	Nakit	2910.67000	2024-02-03	34
35	Kredi Kartı	3030.36000	2024-02-04	35
36	Nakit	3120.12000	2024-02-05	36
37	Kredi Kartı	3250.76000	2024-02-06	37
38	Nakit	3340.45000	2024-02-07	38
39	Kredi Kartı	3450.25000	2024-02-08	39
40	Nakit	3500.13000	2024-02-09	40
41	Kredi Kartı	3600.40000	2024-02-10	41
42	Nakit	3710.52000	2024-02-11	42
43	Kredi Kartı	3820.55000	2024-02-12	43
44	Nakit	3900.33000	2024-02-13	44
45	Kredi Kartı	4000.61000	2024-02-14	45
46	Nakit	4110.74000	2024-02-15	46
47	Kredi Kartı	4230.12000	2024-02-16	47
48	Nakit	4350.26000	2024-02-17	48
49	Kredi Kartı	4400.38000	2024-02-18	49
51	Kredi Kartı	4600.50000	2024-02-20	51
50	Nakit	133.03450	2024-02-19	50
57	Kredi Kartı	250.50000	\N	3
\.


--
-- TOC entry 3496 (class 0 OID 40982)
-- Dependencies: 239
-- Data for Name: PersonelHizmet; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PersonelHizmet" ("kisi_ID", "hizmet_ID", "yapanPersonelSayisi") FROM stdin;
734	1	3
735	2	2
736	3	4
737	4	1
738	5	5
739	6	2
740	7	3
741	8	4
742	9	1
743	10	5
744	11	2
745	12	3
746	13	4
747	14	1
748	15	5
749	16	2
750	17	3
751	18	4
752	19	1
753	20	5
754	21	2
755	22	3
756	23	4
757	24	1
758	25	5
759	26	2
734	27	3
735	28	4
736	29	1
737	30	5
738	31	2
739	32	3
740	33	4
741	34	1
742	35	5
743	36	2
744	37	3
745	38	4
746	39	1
747	40	5
748	41	2
749	42	3
750	43	4
751	44	1
752	45	5
753	46	2
754	47	3
755	48	4
756	49	1
758	51	2
759	52	3
734	53	4
735	54	1
736	55	5
737	56	2
738	57	3
739	58	4
740	59	1
741	60	5
\.


--
-- TOC entry 3481 (class 0 OID 33019)
-- Dependencies: 224
-- Data for Name: Rezervasyon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Rezervasyon" (rezervasyon_id, "kisi_ID", "rezervasyonDurumu", "odemeDurumu") FROM stdin;
4	686	t	\N
6	688	t	\N
7	689	t	\N
8	690	t	\N
9	691	t	\N
10	692	t	\N
11	693	t	\N
12	694	t	\N
13	695	t	\N
14	696	t	\N
15	697	t	\N
16	698	t	\N
17	699	t	\N
18	700	t	\N
19	701	t	\N
20	702	t	\N
21	703	t	\N
22	704	t	\N
23	705	t	\N
24	706	t	\N
25	707	t	\N
26	708	t	\N
27	709	t	\N
28	710	f	\N
29	711	f	\N
30	712	f	\N
31	713	f	\N
32	714	f	\N
33	715	f	\N
34	716	f	\N
35	717	f	\N
36	718	f	\N
37	719	f	\N
38	720	f	\N
39	721	f	\N
40	722	f	\N
41	723	f	\N
42	724	f	\N
43	725	f	\N
44	726	f	\N
45	727	f	\N
46	728	f	\N
47	729	f	\N
48	730	f	\N
49	731	f	\N
50	732	f	\N
51	733	f	\N
52	699	t	\N
3	685	t	t
\.


--
-- TOC entry 3495 (class 0 OID 33139)
-- Dependencies: 238
-- Data for Name: RezervasyonOda; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."RezervasyonOda" (rezervasyon_id, oda_id, "odaDurumu") FROM stdin;
3	3	t
4	4	f
6	6	f
7	7	t
8	8	f
9	9	t
10	10	f
11	11	t
12	12	f
13	13	t
14	14	f
15	15	t
16	16	f
17	17	t
18	18	f
19	19	t
20	20	f
21	21	t
22	22	f
23	23	t
24	24	f
25	25	t
26	26	f
27	27	t
28	28	f
29	29	t
30	30	f
31	31	t
32	32	f
33	33	t
34	34	f
35	35	t
36	36	f
37	37	t
38	38	f
39	39	t
40	40	f
41	41	t
42	42	f
43	43	t
44	44	f
45	45	t
46	46	f
47	47	t
48	48	f
49	49	t
50	50	f
51	51	t
\.


--
-- TOC entry 3499 (class 0 OID 57455)
-- Dependencies: 242
-- Data for Name: kisisilmelog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kisisilmelog (log_id, "kisi_ID", adi, soyadi, "kisiTipi", silinme_tarihi) FROM stdin;
5	788	Ayşe	Demir	t	2024-12-19 16:12:13.726857
6	786	Ahmet	Yılmaz	t	2024-12-19 16:12:51.122446
7	810	rgrdtgret	Çelik	t	2024-12-20 18:03:11.916659
8	809	grtgrtg	Çelik	t	2024-12-20 18:03:16.408152
9	808	emre	Çelik	t	2024-12-20 18:03:20.236073
10	804	eren	yenıi	t	2024-12-20 18:03:24.311877
11	803	eren	yenıi	t	2024-12-20 18:03:28.350186
12	802	eren	yenıi	t	2024-12-20 18:03:32.441989
13	798	eren	yenıi	t	2024-12-20 18:03:35.332118
14	800	eren	yenıi	t	2024-12-20 18:03:38.260278
15	805	eren	yenıi	t	2024-12-20 18:03:41.252069
16	797	eren	tarım	t	2024-12-20 18:03:44.672524
17	796	eren	tarım	t	2024-12-20 18:03:47.835538
18	794	eren	Çelik	t	2024-12-20 18:03:51.005916
19	687	Ahmet	Şahin	t	2024-12-20 18:03:53.998472
20	795	eren	Çelik	t	2024-12-20 18:03:59.956111
21	799	eren	yenıi	t	2024-12-20 18:04:04.868524
22	793	eren	Çelik	t	2024-12-20 18:04:08.554079
23	801	eren	yenıi	t	2024-12-20 18:04:14.521889
24	792	Yeni	Müşteri	t	2024-12-20 18:04:18.925644
25	790	Seher	Kocaman	f	2024-12-20 18:04:28.212849
26	807	Fatma	tare	t	2024-12-20 18:04:34.852045
27	806	yılmaz	esen	t	2024-12-20 18:04:41.043143
28	789	Seher	Aslan	t	2024-12-20 18:17:00.354175
29	811	Ali	Elmas	t	2024-12-20 18:20:28.13905
30	784	Funda	Güler	t	2024-12-24 09:15:54.2312
31	777	Özkan	Sağlam	f	2024-12-24 09:27:57.042257
\.


--
-- TOC entry 3515 (class 0 OID 0)
-- Dependencies: 215
-- Name: Kisi_kisi_ID_seq; Type: SEQUENCE SET; Schema: kisi; Owner: postgres
--

SELECT pg_catalog.setval('kisi."Kisi_kisi_ID_seq"', 813, true);


--
-- TOC entry 3516 (class 0 OID 0)
-- Dependencies: 229
-- Name: Fatura_fatura_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Fatura_fatura_id_seq"', 153, true);


--
-- TOC entry 3517 (class 0 OID 0)
-- Dependencies: 227
-- Name: GirisCikisKayit_kayit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."GirisCikisKayit_kayit_id_seq"', 51, true);


--
-- TOC entry 3518 (class 0 OID 0)
-- Dependencies: 235
-- Name: Hizmet_hizmet_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Hizmet_hizmet_ID_seq"', 83, true);


--
-- TOC entry 3519 (class 0 OID 0)
-- Dependencies: 219
-- Name: IletisimBilgileri_iletisim_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."IletisimBilgileri_iletisim_ID_seq"', 103, true);


--
-- TOC entry 3520 (class 0 OID 0)
-- Dependencies: 231
-- Name: OdaKategorisi_kategori_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."OdaKategorisi_kategori_id_seq"', 51, true);


--
-- TOC entry 3521 (class 0 OID 0)
-- Dependencies: 233
-- Name: Oda_oda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Oda_oda_id_seq"', 51, true);


--
-- TOC entry 3522 (class 0 OID 0)
-- Dependencies: 225
-- Name: Odeme_odeme_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Odeme_odeme_id_seq"', 57, true);


--
-- TOC entry 3523 (class 0 OID 0)
-- Dependencies: 223
-- Name: Rezervasyon_rezervasyon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Rezervasyon_rezervasyon_id_seq"', 52, true);


--
-- TOC entry 3524 (class 0 OID 0)
-- Dependencies: 241
-- Name: kisisilmelog_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kisisilmelog_log_id_seq', 31, true);


--
-- TOC entry 3281 (class 2606 OID 33000)
-- Name: Devamli DevamliPK; Type: CONSTRAINT; Schema: kisi; Owner: postgres
--

ALTER TABLE ONLY kisi."Devamli"
    ADD CONSTRAINT "DevamliPK" PRIMARY KEY ("kisi_ID");


--
-- TOC entry 3271 (class 2606 OID 32963)
-- Name: Kisi KisiPK; Type: CONSTRAINT; Schema: kisi; Owner: postgres
--

ALTER TABLE ONLY kisi."Kisi"
    ADD CONSTRAINT "KisiPK" PRIMARY KEY ("kisi_ID");


--
-- TOC entry 3283 (class 2606 OID 33012)
-- Name: Mevsimlik MevsimlikPK; Type: CONSTRAINT; Schema: kisi; Owner: postgres
--

ALTER TABLE ONLY kisi."Mevsimlik"
    ADD CONSTRAINT "MevsimlikPK" PRIMARY KEY ("kisi_ID");


--
-- TOC entry 3275 (class 2606 OID 32978)
-- Name: Musteri MusteriPK; Type: CONSTRAINT; Schema: kisi; Owner: postgres
--

ALTER TABLE ONLY kisi."Musteri"
    ADD CONSTRAINT "MusteriPK" PRIMARY KEY ("kisi_ID");


--
-- TOC entry 3305 (class 2606 OID 41001)
-- Name: MusteriYedek PRIMARY KEY; Type: CONSTRAINT; Schema: kisi; Owner: postgres
--

ALTER TABLE ONLY kisi."MusteriYedek"
    ADD CONSTRAINT "PRIMARY KEY" PRIMARY KEY ("kisi_ID");


--
-- TOC entry 3273 (class 2606 OID 32968)
-- Name: Personel PersonelPK; Type: CONSTRAINT; Schema: kisi; Owner: postgres
--

ALTER TABLE ONLY kisi."Personel"
    ADD CONSTRAINT "PersonelPK" PRIMARY KEY ("kisi_ID");


--
-- TOC entry 3291 (class 2606 OID 33062)
-- Name: Fatura FaturaPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Fatura"
    ADD CONSTRAINT "FaturaPK" PRIMARY KEY (fatura_id);


--
-- TOC entry 3289 (class 2606 OID 33050)
-- Name: GirisCikisKayit GirisCikisPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GirisCikisKayit"
    ADD CONSTRAINT "GirisCikisPK" PRIMARY KEY (kayit_id);


--
-- TOC entry 3297 (class 2606 OID 33122)
-- Name: Hizmet HizmetPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hizmet"
    ADD CONSTRAINT "HizmetPK" PRIMARY KEY ("hizmet_ID");


--
-- TOC entry 3277 (class 2606 OID 32990)
-- Name: IletisimBilgileri IletisimBilgileriPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."IletisimBilgileri"
    ADD CONSTRAINT "IletisimBilgileriPK" PRIMARY KEY ("iletisim_ID");


--
-- TOC entry 3299 (class 2606 OID 33127)
-- Name: MusteriHizmet MusteriHizmetPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MusteriHizmet"
    ADD CONSTRAINT "MusteriHizmetPK" PRIMARY KEY ("kisi_ID", "hizmet_ID");


--
-- TOC entry 3293 (class 2606 OID 33075)
-- Name: OdaKategorisi OdaKategorisiPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OdaKategorisi"
    ADD CONSTRAINT "OdaKategorisiPK" PRIMARY KEY (kategori_id);


--
-- TOC entry 3295 (class 2606 OID 33082)
-- Name: Oda OdaPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Oda"
    ADD CONSTRAINT "OdaPK" PRIMARY KEY (oda_id);


--
-- TOC entry 3287 (class 2606 OID 33037)
-- Name: Odeme OdemePK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Odeme"
    ADD CONSTRAINT "OdemePK" PRIMARY KEY (odeme_id);


--
-- TOC entry 3303 (class 2606 OID 40986)
-- Name: PersonelHizmet PersonelHizmet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PersonelHizmet"
    ADD CONSTRAINT "PersonelHizmet_pkey" PRIMARY KEY ("kisi_ID", "hizmet_ID");


--
-- TOC entry 3301 (class 2606 OID 33143)
-- Name: RezervasyonOda RezervasyonOdaPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RezervasyonOda"
    ADD CONSTRAINT "RezervasyonOdaPK" PRIMARY KEY (rezervasyon_id, oda_id);


--
-- TOC entry 3285 (class 2606 OID 33024)
-- Name: Rezervasyon RezervasyonPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon"
    ADD CONSTRAINT "RezervasyonPK" PRIMARY KEY (rezervasyon_id);


--
-- TOC entry 3307 (class 2606 OID 57461)
-- Name: kisisilmelog kisisilmelog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kisisilmelog
    ADD CONSTRAINT kisisilmelog_pkey PRIMARY KEY (log_id);


--
-- TOC entry 3279 (class 2606 OID 40961)
-- Name: IletisimBilgileri unique_telefon; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."IletisimBilgileri"
    ADD CONSTRAINT unique_telefon UNIQUE (telefon);


--
-- TOC entry 3326 (class 2620 OID 57445)
-- Name: Kisi kisi_silme_trigger; Type: TRIGGER; Schema: kisi; Owner: postgres
--

CREATE TRIGGER kisi_silme_trigger AFTER DELETE ON kisi."Kisi" FOR EACH ROW EXECUTE FUNCTION public.kisi_silme_trigger_function();


--
-- TOC entry 3329 (class 2620 OID 65575)
-- Name: Hizmet hizmet_ekle_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER hizmet_ekle_trigger AFTER INSERT ON public."Hizmet" FOR EACH ROW EXECUTE FUNCTION public.hizmet_ekle_musterihizmet();


--
-- TOC entry 3327 (class 2620 OID 65577)
-- Name: Odeme odeme_ekle_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER odeme_ekle_trigger AFTER INSERT ON public."Odeme" FOR EACH ROW EXECUTE FUNCTION public.odeme_guncelle_rezervasyon();


--
-- TOC entry 3328 (class 2620 OID 57391)
-- Name: GirisCikisKayit updateCikisTarihiTrigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "updateCikisTarihiTrigger" AFTER UPDATE OF "cikisTarihi" ON public."GirisCikisKayit" FOR EACH ROW EXECUTE FUNCTION public."updateCikisTarihi"();


--
-- TOC entry 3311 (class 2606 OID 33001)
-- Name: Devamli DevamliFK; Type: FK CONSTRAINT; Schema: kisi; Owner: postgres
--

ALTER TABLE ONLY kisi."Devamli"
    ADD CONSTRAINT "DevamliFK" FOREIGN KEY ("kisi_ID") REFERENCES kisi."Kisi"("kisi_ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3313 (class 2606 OID 33013)
-- Name: Mevsimlik MevsimlikFK; Type: FK CONSTRAINT; Schema: kisi; Owner: postgres
--

ALTER TABLE ONLY kisi."Mevsimlik"
    ADD CONSTRAINT "MevsimlikFK" FOREIGN KEY ("kisi_ID") REFERENCES kisi."Kisi"("kisi_ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3309 (class 2606 OID 32979)
-- Name: Musteri MusteriFK; Type: FK CONSTRAINT; Schema: kisi; Owner: postgres
--

ALTER TABLE ONLY kisi."Musteri"
    ADD CONSTRAINT "MusteriFK" FOREIGN KEY ("kisi_ID") REFERENCES kisi."Kisi"("kisi_ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3308 (class 2606 OID 32969)
-- Name: Personel PersonelFK; Type: FK CONSTRAINT; Schema: kisi; Owner: postgres
--

ALTER TABLE ONLY kisi."Personel"
    ADD CONSTRAINT "PersonelFK" FOREIGN KEY ("kisi_ID") REFERENCES kisi."Kisi"("kisi_ID") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3312 (class 2606 OID 57471)
-- Name: Devamli devamlifk; Type: FK CONSTRAINT; Schema: kisi; Owner: postgres
--

ALTER TABLE ONLY kisi."Devamli"
    ADD CONSTRAINT devamlifk FOREIGN KEY ("kisi_ID") REFERENCES kisi."Kisi"("kisi_ID") ON UPDATE CASCADE;


--
-- TOC entry 3314 (class 2606 OID 57466)
-- Name: Mevsimlik mevsimlikfk; Type: FK CONSTRAINT; Schema: kisi; Owner: postgres
--

ALTER TABLE ONLY kisi."Mevsimlik"
    ADD CONSTRAINT mevsimlikfk FOREIGN KEY ("kisi_ID") REFERENCES kisi."Kisi"("kisi_ID") ON UPDATE CASCADE;


--
-- TOC entry 3318 (class 2606 OID 57435)
-- Name: Fatura FaturaFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Fatura"
    ADD CONSTRAINT "FaturaFK" FOREIGN KEY (odeme_id) REFERENCES public."Odeme"(odeme_id) ON DELETE CASCADE;


--
-- TOC entry 3317 (class 2606 OID 57430)
-- Name: GirisCikisKayit GirisCikisFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GirisCikisKayit"
    ADD CONSTRAINT "GirisCikisFK" FOREIGN KEY (rezervasyon_id) REFERENCES public."Rezervasyon"(rezervasyon_id) ON DELETE CASCADE;


--
-- TOC entry 3310 (class 2606 OID 57401)
-- Name: IletisimBilgileri KisiFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."IletisimBilgileri"
    ADD CONSTRAINT "KisiFK" FOREIGN KEY ("kisi_ID") REFERENCES kisi."Kisi"("kisi_ID") ON DELETE CASCADE;


--
-- TOC entry 3320 (class 2606 OID 33128)
-- Name: MusteriHizmet MusteriHizmetFK1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MusteriHizmet"
    ADD CONSTRAINT "MusteriHizmetFK1" FOREIGN KEY ("kisi_ID") REFERENCES kisi."Musteri"("kisi_ID") ON DELETE CASCADE;


--
-- TOC entry 3321 (class 2606 OID 33133)
-- Name: MusteriHizmet MusteriHizmetFK2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MusteriHizmet"
    ADD CONSTRAINT "MusteriHizmetFK2" FOREIGN KEY ("hizmet_ID") REFERENCES public."Hizmet"("hizmet_ID") ON DELETE CASCADE;


--
-- TOC entry 3319 (class 2606 OID 33083)
-- Name: Oda OdaFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Oda"
    ADD CONSTRAINT "OdaFK" FOREIGN KEY (kategori_id) REFERENCES public."OdaKategorisi"(kategori_id);


--
-- TOC entry 3316 (class 2606 OID 57425)
-- Name: Odeme OdemeFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Odeme"
    ADD CONSTRAINT "OdemeFK" FOREIGN KEY (rezervasyon_id) REFERENCES public."Rezervasyon"(rezervasyon_id) ON DELETE CASCADE;


--
-- TOC entry 3324 (class 2606 OID 40987)
-- Name: PersonelHizmet PersonelHizmetFK1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PersonelHizmet"
    ADD CONSTRAINT "PersonelHizmetFK1" FOREIGN KEY ("kisi_ID") REFERENCES kisi."Kisi"("kisi_ID") ON DELETE CASCADE;


--
-- TOC entry 3325 (class 2606 OID 40992)
-- Name: PersonelHizmet PersonelHizmetFK2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PersonelHizmet"
    ADD CONSTRAINT "PersonelHizmetFK2" FOREIGN KEY ("hizmet_ID") REFERENCES public."Hizmet"("hizmet_ID") ON DELETE CASCADE;


--
-- TOC entry 3315 (class 2606 OID 57415)
-- Name: Rezervasyon RezervasyonFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Rezervasyon"
    ADD CONSTRAINT "RezervasyonFK" FOREIGN KEY ("kisi_ID") REFERENCES kisi."Kisi"("kisi_ID") ON DELETE CASCADE;


--
-- TOC entry 3322 (class 2606 OID 33144)
-- Name: RezervasyonOda RezervasyonOdaFK1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RezervasyonOda"
    ADD CONSTRAINT "RezervasyonOdaFK1" FOREIGN KEY (rezervasyon_id) REFERENCES public."Rezervasyon"(rezervasyon_id) ON DELETE CASCADE;


--
-- TOC entry 3323 (class 2606 OID 33149)
-- Name: RezervasyonOda RezervasyonOdaFK2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RezervasyonOda"
    ADD CONSTRAINT "RezervasyonOdaFK2" FOREIGN KEY (oda_id) REFERENCES public."Oda"(oda_id) ON DELETE CASCADE;


-- Completed on 2025-08-07 11:44:01

--
-- PostgreSQL database dump complete
--

