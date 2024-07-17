create table resumes (
  film_id uuid not null,
  langue_code text not null,
  resume text not null
);

alter table resumes
  add constraint resumes_pkey 
  primary key (film_id, langue_code);

alter table resumes add column ts tsvector
  generated always as (to_tsvector('french', resume)) stored;

create index resumes_texte_idx 
  on resumes using gin (ts);

alter table resumes
add  constraint resumes_films_fk foreign key (film_id)
  references films (film_id) match simple
  on update no action
  on delete no action
  not valid;

create index resume_film_fki
  on resumes(film_id);

alter table resumes
add  constraint resume_langue_fk foreign key (langue_code)
  references langues (langue_code) match simple
  on update no action
  on delete no action
  not valid;
