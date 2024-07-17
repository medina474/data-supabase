alter table equipes
  add ordre int2 null
  default 99;

create or replace function films_with_texte(mot text)
returns table (film_id films.film_id%TYPE
  , tritre films.titre%TYPE)
language sql
as $function$
	select f.film_id, f.titre from films f
    inner join resumes r on f.film_id = r.film_id
  where ts @@ to_tsquery('french', mot);
$function$;

create or replace function reco()
  returns table (id films.film_id%TYPE
  ,titre films.titre%type
  ,vote_votants films.vote_votants%type
  ,vote_moyenne films.vote_moyenne%type
  ,score float)
  language 'plpgsql'
as $body$
declare
  C float;
  m int;
begin
  select avg(f.vote_moyenne) into C
    from films f;
  select percentile_disc(0.9) into m
    within group (order by films.vote_votants)
    from films;
  return query select f.film_id, f.titre, f.vote_votants
  	,f.vote_moyenne
  	,(f.vote_votants::numeric /(f.vote_votants::numeric + m) * f.vote_moyenne) + (m /(f.vote_votants::numeric + m) * C) as score
    from films f
    where f.vote_votants >= m
    order by score desc
    limit 10;
end
$body$;
