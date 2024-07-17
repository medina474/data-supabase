create table pays (
  code_2 character(2) not null,
  code_3 character(3) not null,
  code_num character(3) not null,
  pays text not null,
  nom_eng text,
  nom_spa text,
  drapeau_unicode character(2),
  drapeau_svg text
);

comment on column pays.code_2
  is 'iso 3166-1 alpha 2';

comment on column pays.code_3
  is 'iso 3166-1 alpha 3';

comment on column pays.code_num
  is 'iso 3166-1 numeric';

alter table pays
  add constraint pays_pkey
  primary key (code_2);

create index pays_nom
  on pays using btree (pays asc nulls last);

-- regions

create table regions (
  region_code character varying(6),
  region_parent character varying(6),
  region text not null,
  division text,
  capitale text
);

alter table regions
  add constraint regions_pkey
  primary key (region_code);

comment on column regions.region_code
  is 'UN Standard country or area codes for statistical use (M49)';

-- langues

create table langues (
  langue_code character(3) not null primary key,
  langue character varying(20),
  "français" character varying(20),
  ltr boolean
);

-- codes postaux

create table if not exists codepostaux (
  code_insee character(5),
  codepostal character varying(10),
  commune text,
  libelle_acheminement character varying(40),
  ligne_5 character varying(40),
  coordonnees extensions.geometry(point, 4326) default null::geometry
);

--alter table codepostaux
--  add constraint codepostaux_pkey 
--  primary key (code_insee, codepostal, ligne_5);
