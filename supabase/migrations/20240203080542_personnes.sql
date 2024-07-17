create extension if not exists fuzzystrmatch schema extensions;

create table personnes (
  personne_id uuid default gen_random_uuid() not null,
  nom text,
  prenom text,
  naissance date,
  deces date,
  nationalite text,
  artiste text,
  popularite decimal default 0
);

alter table personnes
  add constraint personne_pkey
  primary key (personne_id);

alter table personnes
  add constraint personne_naissance
  check (naissance > '1730-01-01') not valid;

alter table personnes
  add constraint personne_deces
  check (deces > naissance) not valid;

alter table personnes
  add constraint personne_nationalite
  check (char_length(nationalite) = 2) not valid;

create index index_personnes_nom
  on personnes using btree
  (nom collate pg_catalog."default" asc nulls last);
