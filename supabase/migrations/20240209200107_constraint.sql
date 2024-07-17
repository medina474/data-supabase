
alter table equipes drop constraint equipe_film_fk;
alter table equipes add constraint equipes_film_id_fkey 
  foreign key (film_id) references films(film_id) 
  on delete cascade not valid;
alter table equipes validate constraint equipes_film_id_fkey;

alter table equipes drop constraint equipe_personne_fk;
alter table equipes add constraint equipes_personne_id_fkey 
  foreign key (personne_id) references personnes(personne_id) 
  on delete cascade not valid;
alter table equipes validate constraint equipes_personne_id_fkey;

alter table films_genres drop constraint film_genre_film;
alter table films_genres add constraint films_genres_film_id_fkey 
  foreign key (film_id) references films(film_id) 
  on delete cascade not valid;
alter table films_genres validate constraint films_genres_film_id_fkey;

alter table films_genres drop constraint film_genre_genre;
alter table films_genres add constraint films_genres_genre_id_fkey 
  foreign key (genre_id) references genres(genre_id) 
  on delete cascade not valid;
alter table films_genres validate constraint films_genres_genre_id_fkey;

alter table productions drop constraint production_films_fk;
alter table productions add constraint productions_film_id_fkey 
  foreign key (film_id) references films(film_id) 
  on delete cascade not valid;
alter table productions validate constraint productions_film_id_fkey;

alter table productions drop constraint production_societes_fk;
alter table productions add constraint productions_societe_id_fkey 
  foreign key (societe_id) references societes(societe_id) 
  on delete cascade not valid;
alter table productions validate constraint productions_societe_id_fkey;

alter table resumes drop constraint resume_langue_fk;
alter table resumes add constraint resumes_film_id_fkey 
  foreign key (film_id) references films(film_id) 
  on delete cascade not valid;
alter table resumes validate constraint resumes_film_id_fkey;

alter table resumes drop constraint resumes_films_fk;
alter table resumes add constraint resumes_langue_code_fkey 
  foreign key (langue_code) references langues(langue_code) not valid;
alter table resumes validate constraint resumes_langue_code_fkey;

alter table salles drop constraint salle_etablissement_fk;
alter table salles add constraint salle_etablissement_fk 
  foreign key (etablissement_id) references etablissements(etablissement_id) not valid;
alter table salles validate constraint salle_etablissement_fk;


create or replace view view_debug as  select fg.film_id,
    fg.genre_id
   from (films_genres fg
     left join films f on ((fg.film_id = f.film_id)))
  where (f.film_id = null::uuid);


create or replace view view_films_tmdb as  select f.titre,
    f.film_id
   from (films f
     left join links l on (((f.film_id = l.id) and (l.site_id = 1))))
  where (l.id is null);


create or replace view view_personnes_tmdb as  select p.nom,
    p.prenom,
    p.personne_id
   from (personnes p
     left join links l on (((p.personne_id = l.id) and (l.site_id = 1))))
  where (l.id is null);
