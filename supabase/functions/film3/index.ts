/*
 * supabase functions deploy film2 --no-verify-jwt
 */
import { ERROR_CLUSTER_GUM_NOT_LOCKER } from "https://deno.land/std@0.132.0/node/internal_binding/_winerror.ts";
import { Client } from "https://deno.land/x/postgres/mod.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Apikey, Content-Type',
  'Access-Control-Allow-Methods': 'POST',
}

Deno.serve(async (req) => {
  const { method } = req;

  // This is needed if you're planning to invoke your function from a browser.
  if (method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const body = await req.json();
   
    const client = new Client({
      user: Deno.env.get('DB_USER'),
      password: Deno.env.get('DB_PASSWORD'),
      database: "postgres",
      hostname: Deno.env.get('DB_HOSTNAME'),
      port: 5432,
    });
    await client.connect();

    const films = await client.queryObject(`
    select f.titre, f.titre_original
      , vote_votants, vote_moyenne
      , r.resume
      , f.duree, f.sortie, f.annee, f.slogan
      , f2.franchise, f2.franchise_id
      , array_agg(distinct p.nom) as acteurs
      , array_agg(distinct g.genre) as genres
    from films f
      left join equipes e on e.film_id = f.film_id and alias is not null
      inner join personnes p on p.personne_id = e.personne_id
      left join films_genres fg on fg.film_id = f.film_id
      inner join genres g on g.genre_id = fg.genre_id
      left join franchises f2 on f2.franchise_id = f.franchise_id
      left join resumes r on r.film_id = f.film_id
    where f.film_id = '${body.film_id}'
    group by f.titre, f.titre_original, f.vote_votants, f.vote_moyenne, r.resume, f.duree, f.sortie, f.annee, f.slogan
      , f2.franchise_id, f2.franchise`)

    
    const film = films.rows[0];

    const acteurs = await client.queryObject(`select a.personne_id, nom, array_agg(alias) as alias, role, ordre
      from acteurs a
      inner join equipes e on e.personne_id = a.personne_id
      where film_id = '${body.film_id}' and role in ('acteur', 'voix')
      group by a.personne_id, nom, role, ordre
      order by ordre asc`)

    film.acteurs = acteurs.rows;

    const equipe = await client.queryObject(`select a.personne_id, nom, array_agg(role) as roles
      from acteurs a
      inner join equipes e on e.personne_id = a.personne_id
      where film_id = '${body.film_id}' and role not in ('acteur', 'voix')
      group by a.personne_id, nom`)

    film.equipe = equipe.rows

    const motscles = await client.queryObject(`select m.motcle_id, m.motcle
      from motscles m
      inner join films_motscles fm on fm.motcle_id = m.motcle_id
      where fm.film_id = '${body.film_id}'`)

    film.societes = motscles.rows

    const societes = await client.queryObject(`select s.societe_id, s.societe
      from societes s
      inner join productions p on p.societe_id = s.societe_id
      where p.film_id = '${body.film_id}'`)

    film.societes = societes.rows

    await client.end();

    return new Response(JSON.stringify(film), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  }
  catch (error) {
    console.log(error)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 505
    })
  }
})
