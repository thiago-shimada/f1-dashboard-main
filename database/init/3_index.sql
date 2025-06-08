CREATE EXTENSION IF NOT EXISTS Cube;
CREATE EXTENSION IF NOT EXISTS EarthDistance;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX IdxSurnameDriver ON Driver USING GIN (LOWER(surname) gin_trgm_ops);
CREATE INDEX IdxDriveridResults ON Results USING HASH (DriverId);
CREATE INDEX IdxConstructorDriverResults ON results (constructorid, driverid); -- Necessária, pois algumas consultas fazem um group by em constructorid e para cada um conta distinct driverid, então ambos são necessários para o índice, proporcionando melhor performance do que include driverid
CREATE INDEX IdxRaceidResults ON Results USING HASH (RaceId);
CREATE INDEX IdxResultsConstructorRaceLaps ON results (constructorid, raceid) INCLUDE (laps); -- exato padrão GROUP BY em algumas consultas
CREATE INDEX IF NOT EXISTS IdxConstructorRaceResults ON results (constructorid, raceid); -- Para consultas que fazem GROUP BY constructorid e COUNT(DISTINCT raceid)
CREATE INDEX IdxStatusidResults ON Results (StatusId, ResultId);
CREATE INDEX IdxAirportLL ON airports USING gist (ll_to_earth(latdeg, longdeg)) WHERE type IN ('medium_airport', 'large_airport') AND isocountry = 'BR'; -- Tipo gist para permitir consultas geográficas, índice parcial apenas para aeroportos médios e grandes no Brasil
CREATE INDEX IdxCitiesLL ON geocities15k USING gist (ll_to_earth(lat, long)); -- Tipo gist para permitir consultas geográficas, índice completo para todas as cidades
CREATE INDEX IdxResultsStatusConstructor ON results (statusid, constructorid); -- Report 5

-- obterusuarioinfo -> select 1: idxdriveridresults; select2: idxconstructordriverresults
-- adm_view2 -> idxraceidresults
-- adm_view3 -> idxraceidresults
-- adm_view4 -> idxraceidresults
-- VitoriasEscuderia -> idxresultsconstructorracelaps  
-- PilotosEscuderia -> idxconstructordriverresults
-- AnosEscuderia -> idxconstructorraceresults
-- AnosPiloto -> idxdriveridresults
-- EstatisticasPiloto -> select 1: idxdriveridresults; select 2: idxdriveridresults; select 3: idxdriveridresults
-- Action 1 constructor -> idxconstructordriverresults
-- Report 1 -> IdxStatusidResults
-- Report 2 -> idxcitiesll, idxairportsll
-- Report 3 -> select 1: idxconstructordriverresults; select 2: idxconstructorraceresults; select 3: none; select 4: none;
-- Report 4 -> idxconstructordriverresults
-- Report 5 -> idxresultsstatusconstructor
-- Report 6 -> idxdriveridresults
-- Report 7 -> idxdriveridresults