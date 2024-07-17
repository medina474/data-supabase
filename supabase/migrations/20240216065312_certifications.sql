alter table certifications
  drop column certification_id;

alter table certifications
  alter column certification set not null;

alter table certifications
  alter column pays set not null;

create index certifications_pays_idx
  on public.certifications
  using btree (pays, ordre);

create unique index certifications_pk
  on public.certifications
  using btree (pays, certification);

alter table certifications
  add constraint certifications_pk
  primary key using index certifications_pk;
