create table genres (
  genre_id integer not null,
  genre text not null
);

alter table genres
  add constraint genres_pkey 
  primary key (genre_id);
