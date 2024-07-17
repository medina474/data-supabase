/*
 * supabase functions deploy detail --no-verify-jwt
 */
import postgres from 'https://deno.land/x/postgresjs/mod.js'

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
    const sql = postgres(`postgres://${Deno.env.get('DB_USER')}:${Deno.env.get('DB_PASSWORD')}@${Deno.env.get('DB_HOSTNAME')}:5432/postgres`)

    const films = await sql`
    select f.film_id, titre, titre_original,
      annee, sortie, duree, vote_votants, vote_moyenne,
      f2.franchise
      , array_agg(distinct e.alias) as alias
      , array_agg(distinct g.genre) as genres
      , array_agg(distinct mc.motcle) as motscles
      , r.resume
    from films f
    inner join equipes e on e.film_id = f.film_id and alias is not null
    left join films_genres fg on fg.film_id = f.film_id
    left join genres g on g.genre_id = fg.genre_id
    left join franchises f2 on f2.franchise_id = f.franchise_id
    left join lateral (SELECT resumes.resume FROM resumes WHERE resumes.film_id  = f.film_id FETCH FIRST 1 ROW ONLY ) r on true
    left join films_motscles fmc on fmc.film_id = f.film_id
    left join motscles mc on mc.motcle_id = fmc.motcle_id
    where e.personne_id = ${body.personne_id}
    group by f.film_id, f.titre, f.titre_original, f2.franchise, f.vote_votants, e.ordre, r.resume
    order by e.ordre, vote_votants desc`

    return new Response(JSON.stringify(films), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  }
  catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
