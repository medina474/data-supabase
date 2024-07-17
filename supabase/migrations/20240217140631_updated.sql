create function last_updated()
  returns trigger
  language plpgsql
  as $function$
begin
  new.updated_at = current_timestamp;
  return new;
end $function$;


create trigger last_updated
  before update on films
  for each row
  execute procedure last_updated();

alter table films
  add column pays text[];

alter table films
  add column created_at timestamp with time zone default now(),
  add column updated_at timestamp with time zone;
