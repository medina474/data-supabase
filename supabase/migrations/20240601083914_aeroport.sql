create table if not exists aeroports (
  aeroport_code_icao text,
  aeroport_code_iata text,
  nom text,
  ville text, 
  pays text,
  altitude int,
  tz text,
  coordonnees extensions.geometry(Point, 4326) default null::geometry
);

alter table aeroports
  add constraint aeroports_pkey 
  primary key (aeroport_code_icao);

create table appareils (
  type text,
  msn text,
  immatriculation text,
  hexa text,
  livraison date,
  nom text
) 
