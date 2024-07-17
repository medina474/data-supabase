/*
 * supabase functions deploy film --no-verify-jwt
 */
import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2'

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

    const supabaseClient = createClient(
      // Supabase API URL - env var exported by default.
      Deno.env.get('SUPABASE_URL') ?? '',
      // Supabase API ANON KEY - env var exported by default.
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      // Create client with Auth context of the user that called the function.
      // This way your row-level-security (RLS) policies are applied.
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    const body = await req.json();
 
    let error, data;

    ({ error, data } = await supabaseClient.from('films')
      .select('titre, titre_original, vote_votants, vote_moyenne, resumes (resume), duree, sortie, annee, slogan, franchises(franchise, franchise_id)')
      .eq('film_id', body.film_id)
      .single()
      )

    const film = data;

    ({ error, data } = await supabaseClient.from('equipes')
      .select('role, alias, acteurs (personne_id, nom)')
      .eq('film_id', body.film_id)
      .in('role', ['acteur', 'voix'])
      .order('ordre', { ascending: true }))

    film.acteurs = data;

    ({ error, data } = await supabaseClient.from('equipes')
      .select('role, alias, ordre, acteurs (personne_id, nom)')
      .eq('film_id', body.film_id) 
      .not("role", "in", "('acteur', 'voix')")
      .order('ordre', { ascending: true }))

    film.equipe = data;


    ({ error, data } = await supabaseClient.from('films_genres')
    .select('genres (genre, genre_id)')
    .eq('film_id', body.film_id)
    )

    film.genres = data?.map(m => m.genres);

    ({ error, data } = await supabaseClient.from('films_motscles')
      .select('motscles (motcle_id, motcle)')
      .eq('film_id', body.film_id))

    film.motscles = data?.map(m => m.motscles);

    ({ error, data } = await supabaseClient.from('productions')
      .select('societes (societe_id, societe)')
      .eq('film_id', body.film_id))
    
    film.societes = data?.map(s => s.societes);
    
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
