
alter table langues rename column "français" to "francais";

create unique index personnes_unique on personnes using btree (nom, prenom);
alter table personnes add constraint personnes_unique unique using index personnes_unique;

drop view if exists view_personnes_tmdb;
create or replace view "view_nb_films" as  select p.nom,
    l.identifiant,
    count(e.film_id) as count
   from ((personnes p
     join equipes e on ((p.personne_id = e.personne_id)))
     left join links l on (((p.personne_id = l.id) and (l.site_id = 1))))
  group by p.nom, l.identifiant;


drop view if exists view_films_tmdb;
create or replace view "view_films_tmdb" as  select f.titre,
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
