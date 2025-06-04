-- View 1 para o dashboard do administrador
CREATE OR REPLACE VIEW adm_view1 AS
SELECT
    (SELECT COUNT(*) FROM Driver) AS "Total de pilotos",
    (SELECT COUNT(*) FROM Constructors) AS "Total de escuderias",
    (SELECT COUNT(*) FROM Seasons) AS "Total de temporadas";

-- View para dashboard 2 do administrador
CREATE OR REPLACE VIEW adm_view2 AS
WITH race_stats AS (
    SELECT
        r.raceid,
        r.name,
        r.date,
        r.time AS race_start_time_text,
        MAX(r2.laps) AS max_laps,
        MIN(r2.Milliseconds) AS min_milliseconds,
        MAX(r2.Milliseconds) AS max_milliseconds
    FROM races r
    JOIN results r2 ON r2.raceid = r.raceid
    WHERE r.year = (SELECT EXTRACT(YEAR FROM CURRENT_DATE) - 1)
    GROUP BY r.raceid, r.name, r.date, r.time
)
SELECT
    name,
    date,
    race_start_time_text,
    max_laps,
    CASE
        WHEN min_milliseconds IS NOT NULL THEN
            TO_CHAR((min_milliseconds::BIGINT || ' milliseconds')::INTERVAL, 'HH24:MI:SS.MS')
        ELSE NULL
    END AS fastest_driver_duration,
    CASE
        WHEN date IS NOT NULL AND race_start_time_text IS NOT NULL 
             AND race_start_time_text <> '' AND max_milliseconds IS NOT NULL THEN
            (date + race_start_time_text::TIME) + (max_milliseconds::BIGINT || ' milliseconds')::INTERVAL
        ELSE NULL
    END AS race_calculated_end_time
FROM race_stats
ORDER BY name, date;

-- View para dashboard 3 do administrador
CREATE OR REPLACE VIEW adm_view3 AS
SELECT
    c.name AS Piloto,
    SUM(r.points) as "Total de pontos"
FROM
	constructors c
JOIN
    results r ON r.constructorid = c.constructorid
JOIN
    races r2 ON r2.raceid = r.raceid
WHERE
    r2."year" = (SELECT EXTRACT(YEAR FROM CURRENT_DATE) - 2)
GROUP BY
    c.name
ORDER BY
    SUM(r.points) DESC;

CREATE OR REPLACE VIEW adm_view4 AS
SELECT
    d.forename || ' ' || d.surname AS Piloto,
    SUM(r.points) AS "total de pontos"
FROM
	driver d
JOIN
    results r ON r.driverid = d.driverid
JOIN
    races r2 ON r2.raceid = r.raceid
WHERE
    r2."year" = (SELECT EXTRACT(YEAR FROM CURRENT_DATE) - 1)
GROUP BY
    d.forename || ' ' || d.surname
ORDER BY
    SUM(r.points) DESC;

-- Função para dashboard 1 da escuderia
CREATE OR REPLACE FUNCTION VitoriasEscuderia(s_idoriginal INTEGER)
	RETURNS TABLE (
		Escuderia TEXT,
		Vitorias INTEGER
	)
	LANGUAGE plpgsql
AS $$
BEGIN
	SELECT c.name
	INTO Escuderia
	FROM constructors c
	WHERE c.constructorid = s_idoriginal;

	SELECT COUNT(CASE WHEN r.position = 1 THEN 1 END)
	INTO Vitorias
	FROM constructors c
	JOIN results r ON c.constructorid = r.constructorid
	JOIN races r2 ON r.raceid = r2.raceid AND r2.year = (SELECT EXTRACT(YEAR FROM CURRENT_DATE) - 1)
	WHERE c.constructorid = s_idoriginal
	GROUP BY c.name;
	
	RETURN NEXT;
END;
$$;

-- Função para dashboard 2 da escuderia
CREATE OR REPLACE FUNCTION PilotosEscuderia(s_idoriginal INTEGER)
	RETURNS TABLE (
		Escuderia TEXT,
		Pilotos INTEGER
	)
	LANGUAGE plpgsql
AS $$
BEGIN	
	SELECT c.name, COUNT(DISTINCT r.driverid)
	INTO Escuderia, Pilotos
	FROM constructors c
	LEFT JOIN results r on r.constructorid = c.constructorid -- Left join caso escuderia não tenha disputado corridas
	WHERE c.constructorid = s_idoriginal
	GROUP BY c.name;
	
	RETURN NEXT;
END;
$$;

-- Função para dashboard 3 da escuderia
CREATE OR REPLACE FUNCTION AnosEscuderia(s_idoriginal INTEGER)
	RETURNS TABLE (
		Escuderia TEXT,
		"Ano inicial" INTEGER,
		"Ano final" INTEGER
	)
	LANGUAGE plpgsql
AS $$
BEGIN
	SELECT c.name, MIN(r2.year), MAX(r2.year)
	INTO Escuderia, "Ano inicial", "Ano final"
	FROM constructors c
	LEFT JOIN results r ON r.constructorid = c.constructorid
	JOIN races r2 ON r.raceid = r2.raceid
	WHERE c.constructorid = s_idoriginal
	GROUP BY c.name;

	RETURN NEXT;
END;
$$;

-- Função para dashboard 1 do piloto
CREATE OR REPLACE FUNCTION AnosPiloto(s_idoriginal INTEGER)
	RETURNS TABLE (
		Piloto TEXT,
		"Ano inicial" INTEGER,
		"Ano final" INTEGER
	)
	LANGUAGE plpgsql
AS $$
BEGIN
	SELECT d.forename||' '||d.surname, MIN(r2.year), MAX(r2.year)
	INTO Piloto, "Ano inicial", "Ano final"
	FROM driver d
	LEFT JOIN results r ON r.driverid = d.driverid
	LEFT JOIN races r2 ON r.raceid = r2.raceid
	WHERE d.driverid = s_idoriginal
	GROUP BY d.forename||' '||d.surname;

	RETURN NEXT;
END;
$$;

-- Função para dashboard 2 do piloto
CREATE OR REPLACE FUNCTION EstatisticasPiloto(s_idoriginal INTEGER)
	RETURNS TABLE (
	    tipo TEXT,
	    identificador TEXT,
	    pontos FLOAT,
	    vitorias BIGINT,
	    "numero de corridas" BIGINT
	)
	LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        'Geral'::TEXT AS tipo,
        NULL::TEXT AS identificador,
        COALESCE(SUM(r.points), 0.0) AS pontos,
        COALESCE(COUNT(*) FILTER (WHERE r.PositionOrder = 1), 0) AS vitorias,
        COUNT(*) AS "numero de corridas"
    FROM Results r
    WHERE r.DriverId = s_idoriginal;

    RETURN QUERY
    SELECT
        'Anual'::TEXT AS tipo,
        r2.Year::TEXT AS identificador,
        COALESCE(SUM(r.Points), 0.0) AS pontos,
        COUNT(*) FILTER (WHERE r.PositionOrder = 1) AS vitorias,
        COUNT(*) AS "numero de corridas"
    FROM Results r
    JOIN Races r2 ON r.RaceId = r2.RaceId
    WHERE r.DriverId = s_idoriginal
    GROUP BY 2
    ORDER BY 2 DESC;

    RETURN QUERY
    SELECT
        'Circuito'::TEXT AS tipo,
        C.Name AS identificador,
        COALESCE(SUM(r.Points), 0.0) AS pontos,
        COUNT(*) FILTER (WHERE r.PositionOrder = 1) AS vitorias,
        COUNT(*) AS "numero de corridas"
    FROM Results r
    JOIN Races r2 ON r.RaceId = r2.RaceId
    JOIN Circuits c ON r2.CircuitId = c.CircuitId
    WHERE r.DriverId = s_idoriginal
    GROUP BY 2
    ORDER BY 5 DESC;

END;
$$;