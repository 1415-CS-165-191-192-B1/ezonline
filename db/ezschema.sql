CREATE TABLE users (
	id bigint,
	username character varying(50) NOT NULL,
	email character varying(50) NOT NULL,
	admin smallint NOT NULL, /*1 if admin, 0 if not*/
	PRIMARY KEY(id)
);

CREATE TABLE commits (
	id SERIAL,
	snippet_id integer NOT NULL,
	user_id integer NOT NULL,
	created_at date,
	PRIMARY KEY(id)
);

CREATE TABLE snippets (
	id SERIAL,
	file_id integer NOT NULL,
	title character varying(50) NOT NULL,
	body text NOT NULL,
	video_link character varying(50),
	PRIMARY KEY(id)
);

CREATE TABLE files (
	id SERIAL,
	filename character varying(50) NOT NULL,
	PRIMARY KEY(id)
);

ALTER TABLE public.users OWNER TO ezonline;
ALTER TABLE public.commits OWNER TO ezonline;
ALTER TABLE public.snippets OWNER TO ezonline;
ALTER TABLE public.files OWNER TO ezonline;

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM ezonline;
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO ezonline;