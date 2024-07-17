create table if not exists devises (
  devise_code character(3) not null,
  num4217 integer default null,
  symbole text default null,
  nom text default null,
  format text default null,
  division integer default 0,
  minor text default null,
  minors text default null
);

alter table devises
  add constraint devises_pkey
  primary key (devise_code);

create table if not exists pays_devises (
  pays_code character(2) not null,
  devise_code character(3) not null,
  valide daterange default null
);

alter table pays_devises add constraint pays_devises_devise_fkey 
  foreign key (devise_code) references devises(devise_code) 
  on delete cascade;

alter table pays_devises add constraint pays_devises_pays_fkey 
  foreign key (pays_code) references pays(code_2) 
  on delete cascade;

create table changes (
	devise_code character(3),
	cloture date,
	taux numeric(9, 4)
);

alter table changes
  add constraint changes_pkey
  primary key (devise_code, cloture);

alter table changes add constraint changes_devises_fkey 
  foreign key (devise_code) references devises(devise_code) 
  on delete cascade;
