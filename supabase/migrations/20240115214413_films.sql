create table films (
  film_id uuid default gen_random_uuid() not null,
  titre text not null,
  titre_original text,
  annee integer,
  sortie date,
  duree integer,
  franchise_id integer,
  slogan text,
  constraint film_pkey primary key (film_id)
);

alter table films
  add constraint films_franchises_fk foreign key (franchise_id)
    references franchises (franchise_id) match simple
    on update no action
    on delete no action
    not valid;

create index on films 
  using btree (franchise_id);
