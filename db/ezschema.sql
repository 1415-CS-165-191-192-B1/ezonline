CREATE TABLE users (
  user_id numeric(30),
  username character varying(50),
  email character varying(50),
  admin boolean,
  PRIMARY KEY(id)
);

CREATE TABLE commits (
  id SERIAL,
  snippet_id integer NOT NULL,
  user_id character varying(30) NOT NULL,
  created_at date,
  commit_text text,
  PRIMARY KEY(id)
);

CREATE TABLE snippets (
  id SERIAL,
  doc_id character varying(30) NOT NULL,
  title character varying(50),
  video_link character varying(50),
  PRIMARY KEY(id)
);

CREATE TABLE docs (
  doc_id character varying(30),
  docname character varying(50) NOT NULL,
  link character varying(50),
  PRIMARY KEY(id)
);

INSERT INTO users VALUES(104044938106898565002,
            'Christiane Yee',
            'christiane.yee@gmail.com',
            1);

ALTER TABLE public.users OWNER TO ezonline;
ALTER TABLE public.commits OWNER TO ezonline;
ALTER TABLE public.snippets OWNER TO ezonline;
ALTER TABLE public.docs OWNER TO ezonline;

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM ezonline;
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO ezonline;


