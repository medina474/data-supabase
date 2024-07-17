/*
 * supabase functions deploy quizz --no-verify-jwt
 */


const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Apikey, Content-Type, Authorization',
  'Access-Control-Allow-Methods': 'POST',
}

const data = [
  {
    "drapeau": "vn",
    "reponses": ["Chine", "Vietnam", "Corée du nord", "Maroc"],
    "correct": "Vietnam"
  },
  {
    "drapeau": "tn",
    "reponses": ["Singapour", "Turquie", "Chine", "Tunisie"],
    "correct": "Tunisie"
  },
  {
    "drapeau": "lr",
    "reponses": ["Liberia", "États-Unis", "Malaisie", "Panama"],
    "correct": "Liberia"
  },
  {
    "drapeau": "pe",
    "reponses": ["Autriche", "Lettonie", "Monaco", "Pérou"],
    "correct": "Pérou"
  },
  {
    "drapeau": "om",
    "reponses": ["Madagascar", "Oman", "Bulgarie", "Bénin"],
    "correct": "Oman"
  }
]


Deno.serve(async (req) => {
  const { method } = req;
    
  // This is needed if you're planning to invoke your function from a browser.
  if (method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  return new Response(JSON.stringify(data), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    status: 200,
  })
})
