alter table films enable row level security;

create policy "Lecture publique"
on films
as permissive
for select
to public
using (true);

alter table personnes enable row level security;

create policy "Lecture publique"
on personnes
as permissive
for select
to public
using (true);

alter table equipes enable row level security;

create policy "Lecture publique"
on equipes
as permissive
for select
to public
using (true);

alter table franchises enable row level security;

create policy "Lecture publique"
on franchises
as permissive
for select
to public
using (true);

alter table films_genres enable row level security;

create policy "Lecture publique"
on films_genres
as permissive
for select
to public
using (true);

alter table etablissements enable row level security;

create policy "Lecture publique"
on etablissements
as permissive
for select
to public
using (true);


alter table societes enable row level security;

create policy "Lecture publique"
on societes
as permissive
for select
to public
using (true);

alter table productions enable row level security;

create policy "Lecture publique"
on productions
as permissive
for select
to public
using (true);




alter table sites enable row level security;

create policy "Lecture publique"
on sites
as permissive
for select
to public
using (true);

alter table links enable row level security;
alter table links_personnes enable row level security;
alter table links_films enable row level security;
alter table links_societes enable row level security;

create policy "Lecture publique"
on links
as permissive
for select
to public
using (true);

create policy "Lecture publique"
on links_personnes
as permissive
for select
to public
using (true);

create policy "Lecture publique"
on links_films
as permissive
for select
to public
using (true);

create policy "Lecture publique"
on links_societes
as permissive
for select
to public
using (true);

alter table resumes enable row level security;

create policy "Lecture publique"
on resumes
as permissive
for select
to public
using (true);

alter table certifications enable row level security;

create policy "Lecture publique"
on certifications
as permissive
for select
to public
using (true);

alter table codepostaux enable row level security;

create policy "Lecture publique"
on codepostaux
as permissive
for select
to public
using (true);

alter table langues enable row level security;

create policy "Lecture publique"
on langues
as permissive
for select
to public
using (true);

alter table genres enable row level security;

create policy "Lecture publique"
on genres
as permissive
for select
to public
using (true);

alter table pays enable row level security;

create policy "Lecture publique"
on pays
as permissive
for select
to public
using (true);

alter table salles enable row level security;

create policy "Lecture publique"
on salles
as permissive
for select
to public
using (true);

alter table seances enable row level security;

create policy "Lecture publique"
on seances
as permissive
for select
to public
using (true);
