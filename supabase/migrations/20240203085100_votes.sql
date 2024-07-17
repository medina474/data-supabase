alter table films
  add column vote_votants integer,
  add column vote_moyenne decimal(4,2);

create table if not exists votes (
  userid int,
  film_id uuid,
  note decimal not null,
  timestamp timestamp not null
);

alter table votes
  add constraint vote_film_fk foreign key (film_id)
    references films (film_id) match simple
    on update no action
    on delete no action
    not valid;

create index vote_film_fki
  on votes(film_id);

alter table votes
  add constraint note_check check (note >= 0 and note < 6) not valid;

create function vote_calcul()
  returns trigger
  language 'plpgsql'
as $body$
declare
   moyenne decimal(4,2);
   votants integer;
begin
  select count(*), avg(note) into votants, moyenne from votes where film_id = new.film_id;
  update films set vote_votants=coalesce(votants,0), vote_moyenne=coalesce(moyenne,0) where film_id = new.film_id;
  return new;
end
$body$;

create trigger trigger_vote_insert
  after insert
  on votes
  for each row
  execute function vote_calcul();

create trigger trigger_vote_update
  after update
  on votes
  for each row
  execute function vote_calcul();
