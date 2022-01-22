--
-- PostgreSQL database dump
--

-- Dumped from database version 11.11
-- Dumped by pg_dump version 14.1

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

--
-- Name: member_types; Type: TABLE; Schema: public; Owner: robot
--

CREATE TABLE public.member_types (
    id uuid NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.member_types OWNER TO robot;

--
-- Name: members; Type: TABLE; Schema: public; Owner: robot
--

CREATE TABLE public.members (
    id uuid NOT NULL,
    "firstName" text,
    "lastName" text,
    profile jsonb,
    type uuid NOT NULL,
    "fieldValues" jsonb,
    guardians jsonb,
    nationality text,
    "joinedDate" date,
    "dateOfBirth" date,
    address jsonb,
    country text,
    groups jsonb,
    gender text
);


ALTER TABLE public.members OWNER TO robot;

--
-- Name: all_members; Type: VIEW; Schema: public; Owner: robot
--

CREATE VIEW public.all_members AS
 SELECT m.id,
    m."firstName" AS first_name,
    m."lastName" AS last_name,
    (m.profile ->> 'email'::text) AS email,
    (m.profile ->> 'phoneNumber'::text) AS phone,
    (m."fieldValues" ->> '96153440400C4530BC1F642D9394C996'::text) AS badge_status,
    m."joinedDate" AS joined_date,
    ((m."fieldValues" ->> '07518E03975643C484163D015B9E35D1'::text))::date AS expired_date,
    m."dateOfBirth" AS birth_date,
    mt.name AS member_type,
    m.type AS member_type_id,
    m.gender,
    (((m.guardians -> 0) ->> 'guardianId'::text))::uuid AS guardian0_id,
    (((m.guardians -> 1) ->> 'guardianId'::text))::uuid AS guardian1_id,
    array_remove(ARRAY( SELECT jsonb_array_elements_text.value
           FROM jsonb_array_elements_text(m.address) jsonb_array_elements_text(value)), NULL::text) AS address
   FROM (public.members m
     LEFT JOIN public.member_types mt ON ((m.type = mt.id)));


ALTER TABLE public.all_members OWNER TO robot;

--
-- Name: member_fields; Type: TABLE; Schema: public; Owner: robot
--

CREATE TABLE public.member_fields (
    id uuid NOT NULL,
    name text NOT NULL,
    type text NOT NULL
);


ALTER TABLE public.member_fields OWNER TO robot;

--
-- Name: member_fields member_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: robot
--

ALTER TABLE ONLY public.member_fields
    ADD CONSTRAINT member_fields_pkey PRIMARY KEY (id);


--
-- Name: member_types member_types_pkey; Type: CONSTRAINT; Schema: public; Owner: robot
--

ALTER TABLE ONLY public.member_types
    ADD CONSTRAINT member_types_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: robot
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

