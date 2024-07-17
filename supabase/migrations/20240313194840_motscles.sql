create table if not exists motscles (
  motcle_id integer not null,
  motcle text not null
);

alter table motscles
  add constraint motscles_pkey primary key (motcle_id);

create table if not exists films_motscles (
  film_id uuid not null,
  motcle_id integer not null
);

create unique index film_motscles_pkey 
  on public.films_motscles
  using btree (film_id, motcle_id);

create index film_motscles_films 
  on films_motscles 
  using btree (film_id);

create index film_motscles_motscles 
  on films_motscles 
  using btree (motcle_id);

alter table films_motscles
  add constraint film_motscles_pkey
  primary key using index film_motscles_pkey;

alter table films_motscles
  add constraint "film_motscles_film_id_fkey"
  foreign key (film_id) references films(film_id) on delete cascade not valid;

alter table films_motscles
  validate constraint "film_motscles_film_id_fkey";

alter table films_motscles
  add constraint "film_motscles_motcle_id_fkey"
  foreign key (motcle_id) references motscles(motcle_id) on delete cascade not valid;

alter table films_motscles
  validate constraint "film_motscles_motcle_id_fkey";

alter table films_motscles 
  enable row level security;

alter table motscles 
  enable row level security;

create policy "enable read access for all users"
on "films_motscles"
as permissive
for select
to public
using (true);


create policy "enable read access for all users"
on "motscles"
as permissive
for select
to public
using (true);
