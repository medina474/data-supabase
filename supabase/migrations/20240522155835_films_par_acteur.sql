drop function if exists films_par_acteur;
create function films_par_acteur (id varchar)
RETURNS TABLE(film_id uuid, titre text, titre_original text,
annee int, sortie date, duree int, vote_votants int, vote_moyenne numeric(4,2), franchise text, alias text[], genres text[], motscles text[], resume text) AS
$$
BEGIN
  return query select f.film_id, f.titre, f.titre_original,
      f.annee, f.sortie, f.duree, f.vote_votants, f.vote_moyenne,
      f2.franchise
      , array_agg(distinct e.alias) as alias
      , array_agg(distinct g.genre) as genres
      , array_agg(distinct mc.motcle) as motscles
      , r.resume
    from films f
    inner join equipes e on e.film_id = f.film_id and e.alias is not null
    left join films_genres fg on fg.film_id = f.film_id
    left join genres g on g.genre_id = fg.genre_id
    left join franchises f2 on f2.franchise_id = f.franchise_id
    left join lateral (SELECT resumes.resume FROM resumes WHERE resumes.film_id  = f.film_id 
      order by array_position(array['deu','fra','eng'], resumes.langue_code)
      fetch first 1 row only ) r on true
    left join films_motscles fmc on fmc.film_id = f.film_id
    left join motscles mc on mc.motcle_id = fmc.motcle_id
    where e.personne_id = id::uuid
    group by f.film_id, f.titre, f.titre_original, f2.franchise, f.vote_votants, e.ordre, r.resume
    order by e.ordre, vote_votants desc;
END;
$$
language plpgsql volatile;
