import { ensureDir } from "https://deno.land/std@0.224.0/fs/ensure_dir.ts";
import { DOMParser, Element } from "https://deno.land/x/deno_dom/deno-dom-wasm.ts";

interface Page {
  url: string
  type: string
  id: string
}



// https://www.alltricks.fr/C-41476-vtt/NW-6666-vendu-par-~alltricks
// 

const pages:Page[] = [{
  url: "https://www.alltricks.fr/C-1385454-tout_suspendus/NW-6666-vendu-par-~alltricks/NW-16238-seconde-vie~non",
  type: "alltricks_index",
  id: "0"
}];

interface Offre {
  vendeur: string
  taille: string
  mpn: string
  sku: string
  gtin13: string
  prix: number
  stock: number
  url: string
}


let compteur = 0;

const visited = new Set<string>()

const products = []

/**
 * La page est elle deja dans la file d'attente ou a t elle deja été visitée ?
 */
function is_page_in_queue(url:string): boolean {
  if (visited.has(url)) {
    return true;
  }

  return pages.some(elt => elt.url == url)
}

/**
 * Ajouter la page dans la file d'attente
 */
function add_page_in_queue(url:string, type:string, id:string) {
  if (is_page_in_queue(url)) {
    return
  }

  pages.push({ url, type, id})
}

/**
 * Insère une valeur dans la profondeur d'un tableau associatif
 */
function obj_add_kv2(obj, key1:string, key2:string, v:any) {
  if (!obj[key1]) {
    obj[key1] = { }
  }
  obj[key1][key2] = v
}

/**
 * Insère une valeur dans la profondeur d'un tableau associatif
 */
function Numeric(value) {
  return isNaN(value) ? value : parseFloat(value)
}

/**
 * Fonction wrapper pour toutes les fonctions d'exploration
 */
async function explore_page(page: Page, fnct) {

  compteur++;

  try {
    if (visited.has(page.url)) {
      return;
    }

    visited.add(page.url);

    console.log(`Explore : ${page.url}`);

    try {
      const response = await fetch(page.url)
      if (!response.ok) {
        console.error(`Failed to fetch ${page.url}: ${response.statusText}`)
        return
      }

      const html = await response.text()
      
      const doc = new DOMParser().parseFromString(html, "text/html")
      if (!doc) {
        console.error(`Failed to parse HTML for ${page.url}`)
        return
      }

      let ld
      try {
        const script = doc.querySelector("script[type='application/ld+json']")
        if (script) {
          ld = JSON.parse(script.textContent);
        }
      } catch (error) {
        console.error(`${error.message}`);
      }

      fnct(page, doc, ld)
    }
    catch (error) {
      console.error(`Error crawling ${page.url}: ${error.message}`);
    }
  }
  finally {
    compteur--;
  } 
}

/**
 * Analyse une page catégorie du site AllTicks.
 * Extrait depuis la liste des articles un certain nombre d'information de base,
 * puis ajoute le lien de la page de détail du produit dans la file d'attente.
 */
function alltricks_index(page: Page, doc: Element) {
    
  const title = doc.querySelector("title")?.textContent;
  console.log(`Title: ${title}`);

  // Détecte la liste des produits

  const products = doc.querySelectorAll("div.alltricks-Product.alltricks-Product--grid")

  for (const product of products) {
    alltricks_index_detail(page, doc, product);
  }

  // Détecte les liens de navigation des pages suivantes
  
  const elts = doc.querySelectorAll("div.alltricks-Pager__item[data-url]");
  for (const div of elts) {
    const href = div.getAttribute("data-url");
    if (href) {
      const newUrl = new URL(href, page.url).href;
      if (!is_page_in_queue(newUrl)) {
        add_page_in_queue(newUrl, 'alltricks_index', '0')
        }
      }
  }
}

function alltricks_index_detail(page: Page, doc: Element, product_elt:Element) {
  const id = product_elt.getAttribute("data-product-id")

  if (id==null) {
    return
  }

  let product = products.find(elt => elt.id == id)
  
  if (!product) {
    product = {
      "@context": "http://schema.org",
      "@type": "Product", 
      sku: id, 
      tailles: [ ] 
    }

    const link = product_elt.querySelector("a[data-testid='product-url']")
    if (link) {
      const newUrl = new  URL(link.getAttribute("href"), page.url).href;
      add_page_in_queue(newUrl, 'alltricks_detail', id)
      //add_page_in_queue(newUrl + "?frz-smartcache-fragment=true", 'alltricks_fragment', id)
    } 

    const tailles = doc.querySelectorAll(`[data-parent-id='${id}']`)
    for (const t of tailles) {
      product['name'] = t.getAttribute('data-product-name')
      product['marque'] = t.getAttribute('data-brand')
      
      /*
      const taille = { 
        'taille': t.getAttribute('data-label'),
      }

      const offer = {
        "vendeur": t.getAttribute('data-shop-name'),
        "prix": parseFloat(t.getAttribute('data-price')),
        "stock-real": parseInt(t.getAttribute('data-product-stock-real')),
        "stock-shop": parseInt(t.getAttribute('data-product-stock-shop')),
        "deliverable-online": parseInt(t.getAttribute('data-product-deliverable-online'))
      }
      taille.offers.push(offer)
      */
      product['tailles'].push(t.getAttribute('data-label'))
    } 

    products.push(product)
  }
}

async function alltricks_detail(page: Page, doc: Element, ld: any) {
  
  const product = products.find(elt => elt.sku == page.id)

  if (!product) return

  let description = ld.description 
  if (description.indexOf("\r\n\r\n\r\n") > 0) {
    description = description.substring(0, description.indexOf("\r\n\r\n\r\n"))
  }

  product.name = ld.name
  product.description = description
  product.image = ld.image
  product.marque = ld.brand.name
  product.sku = ld.sku
  product.mpn = ld.mpn
  product.gtin13 = ld.gtin13

  const offres = []
  alltricks_detail_offres(doc, ld, offres)
  product.offres = offres

  const informations = { }
  const caracteristiques = { }
  
  alltricks_detail_caracteristiques(doc, product, caracteristiques, informations)
  alltricks_detail_informations(doc, informations)
    
  product.informations = informations
  product.caracteristiques = caracteristiques
  
  const geometries = []
  alltricks_detail_geometries(doc, geometries)
  if (geometries.length > 0) {
    product.geometries = geometries
  }

  await ensureDir(`data/boutique/items/${product.marque.toLowerCase()}`);
  await Deno.writeTextFile(`data/boutique/items/${product.marque.toLowerCase()}/${product.gtin13 || product.sku }.json`, JSON.stringify(product, null, 2));
}

function alltricks_detail_offres(doc, ld, offres) {
  const html_part = doc.querySelector("#product-header .wishlist-hidden")
  if (!html_part) return

  for (const o of ld.offers.offers) {
    const offre: Offre = { 
      "vendeur": o.seller.name,
      "taille": html_part.getAttribute(`data-${o.sku}-attribute-value`)!,
      "stock": parseInt(html_part.getAttribute(`data-${o.sku}-has-stock`)!),
      "prix": parseFloat(o.price),
      "mpn": o.mpn,
      "sku": o.sku,
      "gtin13": o.gtin13,
      "url": o.url
    }

    offres.push(offre)
  }
}

function alltricks_detail_caracteristiques(doc, product, caracteristiques, informations) {
  const html_part = doc.querySelector(".prodsheet_specs1")
  if (!html_part) return

  const lignes = html_part.querySelectorAll("tr")

  for (const tr of lignes) {
    const k = tr.querySelector("td").textContent.toLowerCase()
    const v = tr.querySelector("td:nth-child(2)").textContent

    if (["cassette", "pédalier", "chaîne", "dérailleur arrière", 
      "manette de dérailleur", "boîtier de pédalier"].includes(k)) {
      obj_add_kv2(caracteristiques, "transmission", k, v)
    }
    else if (["guidon"].includes(k)) {
      obj_add_kv2(caracteristiques, "direction", "cintre", v)
    }
    else if (["poignées", "potence", "jeu de direction"].includes(k)) {
      obj_add_kv2(caracteristiques, "direction", k, v)
    }
    else if (["roues"].includes(k)) {
      obj_add_kv2(caracteristiques, "roues", "jantes", v)
    }
    else if (["rayons"].includes(k)) {
      obj_add_kv2(caracteristiques, "roues", k, v)
    }
    else if (["pneus"].includes(k)) {
      const m = v.split('/')
      if (m.length == 2) {
        obj_add_kv2(caracteristiques, "roues", "pneu avant", m[0].substring(7))
        obj_add_kv2(caracteristiques, "roues", "pneu arrière", m[1].substring(10))
      } else {
        obj_add_kv2(caracteristiques, "roues", k, v)
      }
    }
    else if (["moyeux"].includes(k)) {
      const m = v.split('/')
      if (m.length == 2) {
        obj_add_kv2(caracteristiques, "roues", "moyeu avant", m[0].substring(8))
        obj_add_kv2(caracteristiques, "roues", "moyeu arrière", m[1].substring(11))
      }
      else {
        obj_add_kv2(caracteristiques, "roues", k, v)
      }
    }
    else if (["cadre", "fourche", "amortisseur"].includes(k)) {
      obj_add_kv2(caracteristiques, "châssis", k, v)
    }
    else if (["pédales", "selle", "tige de selle", "freins"].includes(k)) {
      obj_add_kv2(caracteristiques, "équipements", k, v)
    }
    else if (["moteur", "écran", "batterie", "commande", "chargeur"].includes(k)) {
      obj_add_kv2(caracteristiques, "assistance électrique", k, v)
    }
    else if (["poids", "poids maximum", "poids total"].includes(k)) {
      if (v !== '---') {
        informations[k] = Numeric(v)
      }
    } 
    else if (["coloris"].includes(k)) {
      if (!product.coloris) {
        product.coloris = []
      }
      product.coloris.push({ coloris: v })
    } else {
      caracteristiques[k] = Numeric(v)
    } 
  }
}

function alltricks_detail_informations(doc, informations) {
  const html_part = doc.querySelector("#product-specifications-table")
  if (!html_part) return

  const lignes = html_part.querySelectorAll("tr")
  for (const tr of lignes) {
    const k = tr.querySelector("td").textContent.toLowerCase()
    const v = tr.querySelector("td:nth-child(2)").textContent.trim()
    informations[k] = Numeric(v)
  }
    
}

function alltricks_detail_geometries(doc, geometries) {
  const html_part = doc.querySelector(".prodsheet_specs2")
  if (!html_part) return

  const lignes = html_part.querySelectorAll("tr")

  for (const tr of lignes) {
    const k = tr.querySelector("td").textContent.toLowerCase()
    const cols = tr.querySelectorAll("td")
    for (let i = 1 ; i < cols.length ; i++) {
      if (typeof geometries[i - 1] === "undefined") {
        geometries[i - 1] = {}
      }
      geometries[i - 1][k] = Numeric(cols[i].textContent)
    } 
  }
}



function  veloStation(item, html) {
 
  const o =ld.offers
  const offre: Offre = { }
  offre["vendeur"] = "Vélo Station";
  offre["prix"] = o.price
  offre["url"] = o.url

  item.offres.push(offre)
  
}


/*
file = `./tests/velo/velostation.html`
html = await Deno.readTextFile(file)

await veloStation(item, html)

items.push(item)

*/

const intervalID = setInterval(async function() {
  const page = pages.shift()
  
  if (page) {
    if (page.type == 'alltricks_index') {
      explore_page(page, alltricks_index)
    } else if (page.type == 'alltricks_detail') {
      explore_page(page, alltricks_detail)
    } 
  }
  
  if (compteur == 0) {
    console.log('file d\'attente vide')
    clearInterval(intervalID)
  } 
},1000)
