create table categories (
  categorie_code text,
  categorie text
);

alter table categories
  add constraint categories_pkey primary key (categorie_code);

alter table categories enable row level security;

create policy "enable read access for all users"
on categories
as permissive
for select
to public
using (true);

create table participants (
  participant_id integer,
  prenom text,
  nom text,
  nationalite text,
  categorie_code text,
  naissance date,
  temps time
);

alter table participants
  add constraint participants_pkey primary key (participant_id);

create table epreuves (
  epreuve_id integer,
  epreuve text, 
  ville text,
  date date,
  distance decimal,
  denivelle integer,
  min integer,
  max integer,
  coord extensions.geometry(Point, 4326) default null::geometry
);

alter table epreuves
  add constraint epreuves_pkey primary key (epreuve_id);

create table points (
  point_code text,
  epreuve_id integer,
  point extensions.geometry(Point, 4326) default null::geometry
);

alter table points enable row level security;

create policy "enable read access for all users"
on points
as permissive
for select
to public
using (true);
