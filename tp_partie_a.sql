-- Question 1
EXPLAIN ANALYZE
SELECT *
FROM commandes
WHERE YEAR(date_commande) = 2026
  AND statut = 'LIVREE'
ORDER BY montant_total DESC
LIMIT 10;

-- Question 2
CREATE INDEX idx_cmd_statut_date
    ON commandes (statut, date_commande)
    INCLUDE (client_id, montant_total);

ANALYZE commandes;

CREATE TABLE commandes_part (
    id            INT           NOT NULL,
    client_id     INT           NOT NULL REFERENCES clients(id),
    date_commande DATE          NOT NULL,
    statut        VARCHAR(20)   NOT NULL,
    canal         VARCHAR(20),
    montant_total NUMERIC(10,2),
    PRIMARY KEY (id, date_commande)
) PARTITION BY RANGE (date_commande);

CREATE TABLE commandes_2024 PARTITION OF commandes_part
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE commandes_2025 PARTITION OF commandes_part
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE commandes_2026 PARTITION OF commandes_part
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

CREATE INDEX idx_cmdpart_statut_date
    ON commandes_part (statut, date_commande)
    INCLUDE (client_id, montant_total);

INSERT INTO commandes_part (id, client_id, date_commande, statut, canal, montant_total)
SELECT id, client_id, date_commande, statut, canal, montant_total
FROM commandes;

ANALYZE commandes_part;

EXPLAIN ANALYZE
SELECT id, client_id, date_commande, montant_total
FROM commandes_part
WHERE statut = 'LIVREE'
  AND date_commande >= DATE '2026-01-01'
  AND date_commande <  DATE '2027-01-01'
ORDER BY montant_total DESC
LIMIT 10;

EXPLAIN ANALYZE
SELECT id, client_id, date_commande, montant_total
FROM commandes_part
WHERE YEAR(date_commande) = 2026
  AND statut = 'LIVREE'
ORDER BY montant_total DESC
LIMIT 10;

-- Question 3
CREATE MATERIALIZED VIEW mv_synthese_segments AS
SELECT cl.segment,
       COUNT(co.id)                    AS nb_commandes,
       ROUND(SUM(co.montant_total), 2) AS ca_total
FROM commandes co
JOIN clients cl ON cl.id = co.client_id
GROUP BY cl.segment;

CREATE UNIQUE INDEX ux_mv_synthese_segment ON mv_synthese_segments (segment);

SELECT * FROM mv_synthese_segments ORDER BY ca_total DESC;

INSERT INTO commandes (id, client_id, date_commande, statut, canal, montant_total)
VALUES (241, 24, DATE '2026-11-20', 'LIVREE', 'WEB', 2450.00);

SELECT * FROM mv_synthese_segments WHERE segment = 'PME';

SELECT 'live' AS source,
       COUNT(co.id)                    AS nb_commandes,
       ROUND(SUM(co.montant_total), 2) AS ca_total
FROM commandes co
JOIN clients cl ON cl.id = co.client_id
WHERE cl.segment = 'PME'
UNION ALL
SELECT 'mv', nb_commandes, ca_total
FROM mv_synthese_segments
WHERE segment = 'PME';

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_synthese_segments;

SELECT * FROM mv_synthese_segments WHERE segment = 'PME';

