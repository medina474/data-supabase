create table films_genres (
  film_id uuid not null,
  genre_id integer not null
);

alter table films_genres
  add constraint film_genre_pkey primary key (film_id, genre_id);

alter table films_genres
  add constraint film_genre_film foreign key (film_id)
    references films (film_id) match simple
    on update no action
    on delete no action
    not valid;

alter table films_genres
  add constraint film_genre_genre foreign key (genre_id)
    references genres (genre_id) match simple
    on update no action
    on delete no action
    not valid;

create index on films_genres 
  using btree (film_id);

create index on films_genres 
  using btree (genre_id);


create table productions (
  film_id uuid not null,
  societe_id uuid not null
);

alter table productions
  add constraint productions_pkey 
  primary key (film_id, societe_id);

alter table productions add constraint production_films_fk foreign key (film_id)
  references films (film_id) match simple
  on update no action
  on delete no action
  not valid;

alter table productions add   constraint production_societes_fk foreign key (societe_id)
  references societes (societe_id) match simple
  on update no action
  on delete no action
  not valid;

create index on productions 
  using btree (film_id);

create index on productions 
  using btree (societe_id);
