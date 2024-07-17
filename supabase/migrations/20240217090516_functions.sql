
create or replace function etablissements_in_view(min_lat float, min_long float, max_lat float, max_long float)
returns table (etablissement_id etablissements.etablissement_id%TYPE
  , nom etablissements.nom%TYPE
	, ville etablissements.ville%TYPE
	, voie etablissements.voie%TYPE
	, codepostal etablissements.codepostal%TYPE
	, lat float, long float)
language sql
as $function$
	select etablissement_id
		, nom
		, ville
		, voie
		, codepostal
		, st_y(coordonnees::geometry) as lat, st_x(coordonnees::geometry) as long
	from etablissements
	where coordonnees && ST_SetSRID(ST_MakeBox2D(ST_Point(min_long, min_lat), ST_Point(max_long, max_lat)), 4326)
$function$;
