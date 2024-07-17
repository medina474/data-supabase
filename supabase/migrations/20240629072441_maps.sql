CREATE TABLE boundaries ( 
  fid integer,
  country character varying(32),
  gid_0 character varying(32),
  gid_1 character varying(32),
  gid_2 character varying(32),
  gid_3 character varying(32),
  gid_4 character varying(32),
  gid_5 character varying(32),
  name_0 character varying(32),
  name_1 character varying(32),
  name_2 character varying(32),
  name_3 character varying(32),
  name_4 character varying(32),
  name_5 character varying(32),
  type_0 character varying(32),
  type_1 character varying(32),
  type_2 character varying(32),
  type_3 character varying(32),
  type_4 character varying(32),
  type_5 character varying(32)
);

/*
alter table boundaries
  add constraint boundaries_pkey
  primary key (fid);
*/
SELECT AddGeometryColumn('public','boundaries','geom',4326,'MULTIPOLYGON',2);
CREATE INDEX "boundaries_geom_geom_idx" ON boundaries USING GIST ("geom");

/*
ALTER TABLE boundaries ADD COLUMN "id_0" INT8;
ALTER TABLE boundaries ADD COLUMN "iso" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "name_english" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "name_iso" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "name_fao" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "name_local" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "name_obsolete" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "name_variants" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "name_nonlatin" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "name_french" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "name_spanish" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "name_russian" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "name_arabic" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "name_chinese" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "waspartof" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "contains" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "sovereign" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "iso2" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "www" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "fips" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "ison" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "validfr" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "validto" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "pop2000" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "sqkm" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "popsqkm" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "unregion1" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "unregion2" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "developing" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "cis" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "transition" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "oecd" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "wbregion" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "wbincome" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "wbdebt" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "wbother" VARCHAR;
ALTER TABLE boundaries ADD COLUMN "ceeac" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "cemac" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "ceplg" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "comesa" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "eac" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "ecowas" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "igad" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "ioc" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "mru" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "sacu" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "uemoa" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "uma" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "palop" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "parta" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "cacm" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "eurasec" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "agadir" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "saarc" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "asean" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "nafta" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "gcc" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "csn" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "caricom" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "eu" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "can" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "acp" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "landlocked" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "aosis" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "sids" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "islands" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "ldc" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "shape_length" FLOAT8;
ALTER TABLE boundaries ADD COLUMN "shape_area" FLOAT8;
*/

CREATE OR REPLACE FUNCTION mvt(z integer, x integer, y integer)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    mvt_output text;
BEGIN
    WITH
    -- Define the bounds of the tile using the provided Z, X, Y coordinates
    bounds AS (
        SELECT ST_TileEnvelope(z, x, y) AS geom
    ),
    -- Transform the geometries from EPSG:4326 to EPSG:3857 and clip them to the tile bounds
    mvtgeom AS (
        SELECT
            -- include the name and id only at zoom 13 to make low-zoom tiles smaller
            CASE
            WHEN z > 13 THEN id
            ELSE NULL
            END AS id,
            CASE
            WHEN z > 13 THEN names::json->>'primary'
            ELSE NULL
            END AS primary_name,
            categories::json->>'main' as main_category,
            ST_AsMVTGeom(
                ST_Transform(wkb_geometry, 3857), -- Transform the geometry to Web Mercator
                boundaries.geom,
                4096, -- The extent of the tile in pixels (commonly 256 or 4096)
                0,    -- Buffer around the tile in pixels
                true  -- Clip geometries to the tile extent
            ) AS geom
        FROM
            places, boundaries
        WHERE
            ST_Intersects(ST_Transform(wkb_geometry, 3857), boundaries.geom)
    )
    -- Generate the MVT from the clipped geometries
    SELECT INTO mvt_output encode(ST_AsMVT(mvtgeom, 'places', 4096, 'geom'),'base64')
    FROM mvtgeom;

    RETURN mvt_output;
END;
$$;


-- CREATE FUNCTION aeroports_insert_projection() RETURNS trigger
--  LANGUAGE plpgsql
--  AS $$
--DECLARE
--   srid integer := nextval('aviation.aeroports_srid_seq');
--BEGIN

--  INSERT INTO spatial_ref_sys (srid, auth_name, proj4text) 
--    VALUES (srid, CONCAT('azimuthal equidistant ', NEW.ville), CONCAT('+proj=aeqd +lat_0=', ST_Y(NEW.localisation), ' +lon_0=', ST_X(NEW.localisation), ' +x_0=0 +y_0=0 +a=6371000 +b=6371000 +units=m +no_defs') );
--  NEW.srid := srid;
--  RETURN NEW;

--END
--$$;


--CREATE FUNCTION aeroports_update_projection() RETURNS trigger
--  LANGUAGE plpgsql
--  AS $$
--BEGIN

--UPDATE spatial_ref_sys SET auth_name = CONCAT('azimuthal equidistant ', NEW.ville), 
--  proj4text = CONCAT('+proj=aeqd +lat_0=', ST_Y(NEW.localisation), ' +lon_0=', ST_X(NEW.localisation), ' +x_0=0 +y_0=0 +a=6371000 +b=6371000 +units=m +no_defs') 
--  WHERE srid = NEW.srid;
--RETURN NEW;

--END
--$$;


-- CREATE FUNCTION route_grand_cercle() RETURNS trigger
--   LANGUAGE plpgsql
--   AS $$
--   DECLARE
--     dateline geometry;
--     route geometry;
--     intersec geometry;
--     frac float := 0;
--     aeqd_srid integer;
--   BEGIN

--   RAISE INFO 'start % %', NEW.aeroport_origine, NEW.aeroport_destination;

----DELETE FROM spatial_ref_sys WHERE srid = '99999';
----INSERT INTO spatial_ref_sys (srid, auth_name, proj4text) VALUES ('99999', 'azimuthal equidistant', (SELECT CONCAT('+proj=aeqd +lat_0=', ST_Y(localisation), ' +lon_0=', ST_X(localisation), ' +x_0=0 +y_0=0 +a=6371000 +b=6371000 +units=m +no_defs' ) FROM aviation.aeroports WHERE code_iata = NEW.aeroport_origine));

----RAISE INFO 'set srid : done';

--   SELECT srid FROM aviation.aeroports WHERE code_iata = NEW.aeroport_origine INTO aeqd_srid;

--   dateline := ST_Transform(ST_Segmentize(ST_GeomFromText('LINESTRING(180 90, 180 -90)', 4326),5), aeqd_srid);

----RAISE INFO 'dateline : %', ST_AsText(dateline);

-- SELECT ST_MakeLine(ST_Transform(a.localisation, aeqd_srid), ST_Transform(b.localisation, aeqd_srid))
--  FROM 
--    aviation.aeroports a, aviation.aeroports b 
--  WHERE 
--  (a.code_iata = NEW.aeroport_origine) AND
--  (b.code_iata = NEW.aeroport_destination)
-- INTO route;

----RAISE INFO 'route : %', ST_AsText(route);

-- intersec := ST_GeometryN(ST_INTERSECTION(route, dateline), 1);

-- RAISE INFO 'intersec : %', ST_AsText(intersec);

-- IF intersec IS NULL THEN
-- 	NEW.route := ST_Transform(ST_Segmentize(route, 50000), 4326);
-- ELSE
--         frac := ST_LineLocatePoint(route, intersec);
--         RAISE INFO 'frac : %', frac;
--         IF frac > 0 AND  frac < 1 THEN
-- 		NEW.route := ST_Transform(ST_Segmentize(ST_UNION(ST_Line_Substring(route,0, frac-0.01), ST_Line_Substring(route,frac+0.01, 1)),50000),4326);
-- 	ELSE
-- 		NEW.route := ST_Transform(ST_Segmentize(route, 50000), 4326);
-- 	END IF;
-- END IF;

--RAISE INFO 'new.route : done';

--RETURN NEW;

--END
--$$;
