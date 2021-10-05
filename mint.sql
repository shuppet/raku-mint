--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE mint;
ALTER ROLE mint WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md535e01a07c8765ea649f0a4a84529aec7';






--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.2
-- Dumped by pg_dump version 13.2

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
-- PostgreSQL database dump complete
--

--
-- Database "mint" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.2
-- Dumped by pg_dump version 13.2

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
-- Name: mint; Type: DATABASE; Schema: -; Owner: mint
--

CREATE DATABASE mint WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.utf8';


ALTER DATABASE mint OWNER TO mint;

\connect mint

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: mint_accounts; Type: TABLE; Schema: public; Owner: mint
--

CREATE TABLE public.mint_accounts (
    account character varying(255) NOT NULL,
    overdraft integer NOT NULL,
    is_frozen boolean NOT NULL,
    registration_date timestamp with time zone NOT NULL
);


ALTER TABLE public.mint_accounts OWNER TO mint;

--
-- Name: mint_transactions; Type: TABLE; Schema: public; Owner: mint
--

CREATE TABLE public.mint_transactions (
    batch uuid NOT NULL,
    account character varying(255) NOT NULL,
    value integer,
    from_account character varying(255),
    to_account character varying(255),
    termination_point character varying(255),
    is_void boolean,
    datetime timestamp with time zone
);


ALTER TABLE public.mint_transactions OWNER TO mint;

--
-- Data for Name: mint_accounts; Type: TABLE DATA; Schema: public; Owner: mint
--

COPY public.mint_accounts (account, overdraft, is_frozen, registration_date) FROM stdin;
kawaii	0	f	2021-07-10 18:54:35.990274+00
\.


--
-- Data for Name: mint_transactions; Type: TABLE DATA; Schema: public; Owner: mint
--

COPY public.mint_transactions (batch, account, value, from_account, to_account, termination_point, is_void, datetime) FROM stdin;
ca1a2ff2-72c0-428f-9945-f16bf2e109c7	kawaii	35	\N	kawaii	system	f	2021-07-13 12:36:42.065349+00
\.


--
-- Name: mint_accounts mint_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: mint
--

ALTER TABLE ONLY public.mint_accounts
    ADD CONSTRAINT mint_accounts_pkey PRIMARY KEY (account);


--
-- Name: mint_transactions mint_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: mint
--

ALTER TABLE ONLY public.mint_transactions
    ADD CONSTRAINT mint_transactions_pkey PRIMARY KEY (batch, account);


--
-- Name: mint_transactions mint_transactions_from_account_mint_accounts_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mint
--

ALTER TABLE ONLY public.mint_transactions
    ADD CONSTRAINT mint_transactions_from_account_mint_accounts_account_fkey FOREIGN KEY (from_account) REFERENCES public.mint_accounts(account);


--
-- Name: mint_transactions mint_transactions_to_account_mint_accounts_account_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mint
--

ALTER TABLE ONLY public.mint_transactions
    ADD CONSTRAINT mint_transactions_to_account_mint_accounts_account_fkey FOREIGN KEY (to_account) REFERENCES public.mint_accounts(account);


--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.2
-- Dumped by pg_dump version 13.2

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
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

