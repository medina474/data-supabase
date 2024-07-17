create type role as enum (
  'acteur',
  'voix',
  'réalisateur',
  'scénariste',
  'musique',
  'roman'
);

create table if not exists equipes (
  film_id uuid not null,
  personne_id uuid not null,
  role public.role,
  alias text,
  constraint equipe_film_fk foreign key (film_id) references films(film_id)
    on update no action on delete no action not valid,
  constraint equipe_personne_fk foreign key (personne_id) references personnes(personne_id)
    on update no action on delete no action not valid
);

create index equipe_films_fki
  on equipes(film_id);

create index equipe_personnes_fki
  on equipes(personne_id);

comment on table equipes is
  e'@foreignkey (personne) references cinema.acteur(id)|@fieldname rolebyacteur';
