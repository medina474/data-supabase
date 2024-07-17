create table sites (
  site_id bigint not null,
  site text not null,
  url text not null
);

alter table sites
  add constraint sites_pkey primary key (site_id);



create table links (
  id uuid not null,
  site_id bigint not null,
  identifiant text not null
);

alter table links
  add constraint links_no_insert_in_parent
  check (false) no inherit;

alter table links
  add constraint links_pkey 
  primary key (id, site_id);

create index links_identifiant_idx 
  on links (identifiant);

-- Links Sociétés

create table links_societes (
) inherits (links);

alter table links_societes
  add constraint links_societes_pkey 
  primary key (id, site_id);

alter table links_societes
  add constraint links_societes_fk 
  foreign key (id) references societes(societe_id) 
  on delete cascade;

create index links_societes_id 
  on links_societes 
  using btree (id);

-- Links Films

create table links_films (
) inherits (links);

alter table links_films
  add constraint links_films_pkey 
  primary key (id, site_id);

alter table links_films
  add constraint links_films_fk 
  foreign key (id) references films(film_id) 
  on delete cascade;

create index links_films_id 
  on links_films 
  using btree (id);

-- Links Personnes

create table links_personnes (
) inherits (links);

alter table links_personnes
  add constraint links_personnes_pkey 
  primary key (id, site_id);

alter table links_personnes
  add constraint links_personnes_fk 
  foreign key (id) references personnes(personne_id) 
  on delete cascade;

create index links_personnes_id 
  on links_personnes 
  using btree (id);
