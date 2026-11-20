-- Question 7 
SELECT id, nom FROM employes
WHERE id NOT IN (SELECT manager_id FROM employes);

SELECT e.id, e.nom
FROM employes e
WHERE NOT EXISTS (
    SELECT 1 FROM employes s WHERE s.manager_id = e.id
)
ORDER BY e.id;

SELECT e.id, e.nom
FROM employes e
LEFT JOIN employes s ON s.manager_id = e.id
WHERE s.id IS NULL
ORDER BY e.id;

-- Question 8 
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT solde FROM comptes_bancaires WHERE id = 1;

BEGIN;
UPDATE comptes_bancaires SET solde = solde - 1000 WHERE id = 1;
COMMIT;

SELECT solde FROM comptes_bancaires WHERE id = 1;
COMMIT;

UPDATE comptes_bancaires SET solde = 15000 WHERE id = 1;

BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT solde FROM comptes_bancaires WHERE id = 1;

BEGIN;
UPDATE comptes_bancaires SET solde = solde - 1000 WHERE id = 1;
COMMIT;

SELECT solde FROM comptes_bancaires WHERE id = 1;
COMMIT;

UPDATE comptes_bancaires SET solde = 15000 WHERE id = 1;

BEGIN;
UPDATE comptes_bancaires SET solde = solde - 1000 WHERE id = 1;
UPDATE comptes_bancaires SET solde = solde + 1000 WHERE id = 2;
COMMIT;

-- Question 9 
CREATE TABLE cov_utilisateurs (
    id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom       VARCHAR(80)  NOT NULL,
    email     VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE cov_trajets (
    id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    conducteur_id  BIGINT NOT NULL REFERENCES cov_utilisateurs(id),
    depart_at      TIMESTAMPTZ NOT NULL,
    arrivee_at     TIMESTAMPTZ,
    distance_km    NUMERIC(7,2) CHECK (distance_km >= 0)
);

CREATE TABLE cov_factures (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    trajet_id     BIGINT NOT NULL REFERENCES cov_trajets(id),
    passager_id   BIGINT NOT NULL REFERENCES cov_utilisateurs(id),
    montant       NUMERIC(10,2) NOT NULL CHECK (montant > 0),
    statut        VARCHAR(20) NOT NULL DEFAULT 'EN_ATTENTE'
                  CHECK (statut IN ('EN_ATTENTE','PAYEE','REMBOURSEE')),
    cle_idempotence UUID NOT NULL UNIQUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (trajet_id, passager_id)
);
CREATE INDEX idx_cov_factures_passager ON cov_factures (passager_id);
