-- Report 1
CREATE OR REPLACE VIEW report1 AS
SELECT
    s.status,
    COALESCE(r.quantidade, 0) AS quantidade
FROM
    status s
LEFT JOIN (
    SELECT statusid, COUNT(DISTINCT resultid) AS quantidade
    FROM results
    GROUP BY statusid
) r ON s.statusid = r.statusid
ORDER BY 2 DESC;

CREATE MATERIALIZED VIEW report2 AS
SELECT 
    c.name AS cidade,
    a.name AS aeroporto,
    a.city AS cidade_aeroporto,
    earth_distance(
        ll_to_earth(a.latdeg, a.longdeg),
        ll_to_earth(c.lat, c.long)
    ) / 1000 AS distancia,
    a.type AS tipo
FROM airports a
JOIN geocities15k c
  ON earth_box(ll_to_earth(a.latdeg, a.longdeg), 100000) @> ll_to_earth(c.lat, c.long)
     AND earth_distance(
         ll_to_earth(a.latdeg, a.longdeg),
         ll_to_earth(c.lat, c.long)
     ) <= 100000
WHERE
	a.type IN ('medium_airport', 'large_airport')
	AND a.isocountry = 'BR'
ORDER BY 2, 4;

-- Report 3
-- Quantidade de pilotos por escuderia
CREATE OR REPLACE VIEW report3a AS
WITH counter AS (
    SELECT 
        constructorid,
        COUNT(DISTINCT driverid) as driver_count
    FROM results
    GROUP BY constructorid
)
SELECT 
    c.name AS Escuderia,
    COALESCE(co.driver_count, 0) as Pilotos
FROM constructors c
LEFT JOIN counter co ON c.constructorid = co.constructorid
ORDER BY 2 DESC;

-- Quantidade de corridas por escuderias. Left join, pois há escuderias que não correram
CREATE OR REPLACE VIEW report3b AS
SELECT 
    c.name AS escuderia,
    COALESCE(corridas.corrida, 0) as corridas,
    COALESCE(corridas.piloto, 0) AS pilotos
FROM constructors c
LEFT JOIN (
    SELECT 
        constructorid,
        COUNT(DISTINCT raceid) as corrida,
        COUNT(DISTINCT driverid) AS piloto
    FROM results
    GROUP BY constructorid
) corridas ON c.constructorid = corridas.constructorid
ORDER BY corridas DESC;

-- Quantidade de corridas por circuito por escuderia. Todos inner joins porque é necessário encontrar um circuito através de um resultado de uma corrida
CREATE OR REPLACE VIEW report3c AS
SELECT 
	c.name AS escuderia, 
	c2.name AS circuito, 
	COUNT(DISTINCT r.driverid) AS quantidade_pilotos,
	COUNT(DISTINCT r.raceid) AS quantidade_corridas, 
	MIN(r.laps) AS minimo_voltas, 
	MAX(r.laps) AS maximo_voltas, 
	ROUND(AVG(r.laps), 2) AS media_voltas
FROM constructors c 
JOIN results r ON r.constructorid = c.constructorid
JOIN races r2 ON r2.raceid = r.raceid 
JOIN circuits c2 ON c2.circuitid = r2.circuitid
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

-- Total de tempo e voltas por corrida por escuderia. Todos inner joins porque é necessário encontrar um circuito através de um resultado de uma corrida
CREATE OR REPLACE VIEW report3d AS
SELECT
	c.name AS escuderia,
	c2.name AS circuito,
	r2.year AS ano,
	COUNT(DISTINCT r.driverid) AS total_pilotos,
	SUM(r.laps) AS total_voltas,
	(SUM(r.milliseconds)||' milliseconds')::INTERVAL AS total_tempo
FROM constructors c
JOIN results r ON r.constructorid = c.constructorid
JOIN races r2 ON r2.raceid = r.raceid
JOIN circuits c2 ON c2.circuitid = r2.circuitid
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;

-- Report 4
CREATE OR REPLACE FUNCTION PilotosVitoriasEscuderia(s_idoriginal INTEGER)
	RETURNS TABLE (
		Escuderia TEXT,
		Piloto TEXT,
		Vitorias BIGINT
	)
	LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT
		c.name AS Escuderia,
		d.forename||' '||d.surname AS Piloto,
		COUNT(CASE WHEN r.position = 1 THEN 1 ELSE NULL END) AS Vitorias
	FROM constructors c 
	JOIN results r ON r.constructorid = c.constructorid
	JOIN driver d ON d.driverid = r.driverid
	WHERE c.constructorid = s_idoriginal
	GROUP BY 1, 2
	ORDER BY 1, 3 DESC;
END;
$$;

-- Report 5
CREATE OR REPLACE FUNCTION StatusEscuderia(s_idoriginal INTEGER)
	RETURNS TABLE (
		Status TEXT,
		Resultados BIGINT
	)
	LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT 
    s.status AS Status,
    COALESCE(cr.count, 0) AS Resultados
	FROM status s
	LEFT JOIN (
	    SELECT 
	        statusid,
	        COUNT(*) as count
	    FROM results 
	    WHERE constructorid = s_idoriginal
	    GROUP BY statusid
	) cr ON s.statusid = cr.statusid
	ORDER BY 2 DESC;
END;
$$;

-- Report 6
CREATE OR REPLACE FUNCTION PontosPiloto(s_idoriginal INTEGER)
	RETURNS TABLE (
		Nome TEXT,
		Ano INTEGER,
		Corrida TEXT,
		"Pontos na Corrida" DOUBLE PRECISION,
		"Pontos no Ano" DOUBLE PRECISION 
	)
	LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT 
	    d.forename||' '||d.surname AS nome,
	    r2.year AS ano,
	    r2.name AS corrida,
	    SUM(r.points) AS pontos_corrida,
	    SUM(SUM(r.points)) OVER (PARTITION BY r2.year) AS pontos_totais
	FROM driver d
	JOIN results r ON d.driverid = r.driverid
	JOIN races r2 ON r2.raceid = r.raceid
	WHERE d.driverid = s_idoriginal
	GROUP BY 1, 2, 3
	ORDER BY 2, 3 DESC;
END;
$$;

-- Report 7
CREATE OR REPLACE FUNCTION StatusPiloto(s_idoriginal INTEGER)
	RETURNS TABLE (
		Status TEXT,
		Resultados BIGINT
	)
	LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT 
        s.status AS Status,
        COALESCE(dr.count, 0) AS Resultados
    FROM status s
    LEFT JOIN (
        SELECT 
            statusid,
            COUNT(*) as count
        FROM results 
        WHERE driverid = s_idoriginal
        GROUP BY statusid
    ) dr ON s.statusid = dr.statusid
    ORDER BY 2 DESC, 1;
END;
$$;