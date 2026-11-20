-- Question 4 
CREATE TABLE affectations_brutes (
    employe_id      INT,
    employe_nom     VARCHAR(80),
    dept_nom        VARCHAR(40),
    projets_liste   TEXT,
    chef_projet     VARCHAR(80),
    chef_projet_tel VARCHAR(20)
);

INSERT INTO affectations_brutes VALUES
 (4,  'Antoine Renaud',  'Data',  'Migration PG 17, Data Lake', 'Marc Delacroix', '04 72 10 20 30'),
 (5,  'Nadia Benali',    'Data',  'Data Lake',                  'Marc Delacroix', '04 72 10 20 30'),
 (7,  'Pauline Lefort',  'Infra', 'Supervision 24/7',           'Sophie Vasseur', '01 48 62 00 11'),
 (9,  'Émilie Maillard', 'Data',  'Migration PG 17',            'Marc Delacroix', '04 72 10 20 30'),
 (12, 'Océane Simon',    'Infra', 'Supervision 24/7',          'Sophie Vasseur', '01 48 62 00 11');

CREATE TABLE departements (
    id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE collaborateurs (
    id             INT PRIMARY KEY,
    nom            VARCHAR(80) NOT NULL,
    departement_id INT NOT NULL REFERENCES departements(id)
);

CREATE TABLE chefs_projet (
    id        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom       VARCHAR(80) NOT NULL UNIQUE,
    telephone VARCHAR(20) NOT NULL
);

CREATE TABLE projets (
    id             INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom            VARCHAR(80) NOT NULL UNIQUE,
    chef_projet_id INT NOT NULL REFERENCES chefs_projet(id)
);

CREATE TABLE affectations (
    collaborateur_id INT NOT NULL REFERENCES collaborateurs(id),
    projet_id        INT NOT NULL REFERENCES projets(id),
    PRIMARY KEY (collaborateur_id, projet_id)
);
CREATE INDEX idx_affectations_projet ON affectations (projet_id);

INSERT INTO departements (nom)
SELECT DISTINCT dept_nom FROM affectations_brutes;

INSERT INTO collaborateurs (id, nom, departement_id)
SELECT DISTINCT b.employe_id, b.employe_nom, d.id
FROM affectations_brutes b
JOIN departements d ON d.nom = b.dept_nom;

INSERT INTO chefs_projet (nom, telephone)
SELECT DISTINCT chef_projet, chef_projet_tel FROM affectations_brutes;

INSERT INTO projets (nom, chef_projet_id)
SELECT DISTINCT TRIM(p.nom), cp.id
FROM affectations_brutes b
CROSS JOIN LATERAL unnest(string_to_array(b.projets_liste, ',')) AS p(nom)
JOIN chefs_projet cp ON cp.nom = b.chef_projet;

INSERT INTO affectations (collaborateur_id, projet_id)
SELECT DISTINCT b.employe_id, pr.id
FROM affectations_brutes b
CROSS JOIN LATERAL unnest(string_to_array(b.projets_liste, ',')) AS p(nom)
JOIN projets pr ON pr.nom = TRIM(p.nom);

SELECT c.id AS employe_id, c.nom AS employe_nom, d.nom AS dept_nom,
       pr.nom AS projet, cp.nom AS chef_projet, cp.telephone AS chef_projet_tel
FROM affectations a
JOIN collaborateurs c ON c.id  = a.collaborateur_id
JOIN departements  d ON d.id  = c.departement_id
JOIN projets      pr ON pr.id = a.projet_id
JOIN chefs_projet cp ON cp.id = pr.chef_projet_id
ORDER BY c.id, pr.nom;

-- Question 5 
WITH classement AS (
    SELECT cat.nom          AS categorie,
           p.nom            AS produit,
           p.prix_unitaire,
           DENSE_RANK() OVER (
               PARTITION BY p.categorie_id
               ORDER BY p.prix_unitaire DESC
           )                AS rang_prix
    FROM produits p
    JOIN categories cat ON cat.id = p.categorie_id
)
SELECT categorie, produit, prix_unitaire, rang_prix
FROM classement
WHERE rang_prix <= 2
ORDER BY categorie ASC, rang_prix ASC;

-- Question 6 
WITH RECURSIVE organigramme AS (
    SELECT id, nom, poste, departement,
           1            AS niveau,
           nom::TEXT    AS chemin
    FROM employes
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.id, e.nom, e.poste, e.departement,
           o.niveau + 1,
           o.chemin || ' > ' || e.nom
    FROM employes e
    JOIN organigramme o ON e.manager_id = o.id
    WHERE o.niveau < 20
)
SELECT id, nom, poste, departement, niveau, chemin
FROM organigramme
ORDER BY chemin;

