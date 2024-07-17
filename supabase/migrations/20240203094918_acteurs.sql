create materialized view acteurs as
  select p.personne_id,
  case
    when (p.artiste is not null) then (p.artiste)::text
    else (((p.prenom)::text || ' '::text) || (p.nom)::text)
  end as nom,
  case
    when (p.artiste is not null) then metaphone(p.artiste::text,15)
    else metaphone(((p.prenom)::text || ' '::text) || (p.nom)::text,15)
  end as metaphone,
  p.naissance,
  case
    when (p.deces is null) then date_part('year'::text, age((p.naissance)::timestamp with time zone))
    else null::double precision
  end as age,
  p.deces,
  p.nationalite,
  y.drapeau_unicode,
  count(distinct c.film_id) as nb_film,
  p.popularite
  from (equipes c
    join personnes p on (c.personne_id = p.personne_id)
    left join pays y on p.nationalite = y.code_2)
  where c.role in ('acteur', 'voix')
  group by p.personne_id, y.drapeau_unicode
  order by popularite desc
with no data;
