create table artistes (
  artiste_id uuid default gen_random_uuid() not null,
  nom text not null,
  logo text
);

alter table artistes
  add constraint artistes_pkey primary key (artiste_id);

alter table artistes enable row level security;

create policy "enable read access for all users"
on artistes
as permissive
for select
to public
using (true);

create table membres (
  personne_id uuid not null,
  artiste_id uuid not null,
  alias text,
  periode daterange[]
);

alter table membres
  add constraint membres_pkey primary key (personne_id, artiste_id);

create index membres_personne_id 
  on membres 
  using btree (personne_id);

create index membres_artiste_id
  on membres 
  using btree (artiste_id);

alter table membres enable row level security;

create policy "enable read access for all users"
on membres
as permissive
for select
to public
using (true);

create type sortie_type as enum (
  'album'
);

create table sorties (
  sortie_id uuid not null,
  artiste_id uuid not null,
  titre text,
  date date,
  type sortie_type, 
  code_barre text
);

alter table sorties enable row level security;

create policy "enable read access for all users"
on sorties
as permissive
for select
to public
using (true);

create table pistes (
  piste_id uuid not null,
  position int2,
  duree integer
);

alter table pistes
  add constraint pistes_pkey primary key (piste_id);

alter table pistes enable row level security;

create policy "enable read access for all users"
on pistes
as permissive
for select
to public
using (true);

create table musiques (
  musique_id uuid not null,
  titre text
);

alter table musiques
  add constraint musiques_pkey primary key (musique_id);

alter table musiques enable row level security;

create policy "enable read access for all users"
on musiques
as permissive
for select
to public
using (true);
