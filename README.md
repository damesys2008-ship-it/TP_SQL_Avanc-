# TP SQL Avancé & NoSQL

**Nom :** MAMA
**Prénom :** Samir
**Formation :** CODA, 2e année — module SQL Avancé (novembre 2026)

## Contenu du dépôt

| Fichier | Contenu |
| --- | --- |
| `tp_partie_a.sql` | Partie A : Q1 (EXPLAIN ANALYZE), Q2 (index, partitionnement RANGE, requête SARGable), Q3 (vue matérialisée) |
| `tp_partie_b.sql` | Partie B : Q4 (passage en 3FN), Q5 (CTE + DENSE_RANK), Q6 (WITH RECURSIVE) |
| `tp_partie_c.sql` | Partie C : Q7 (piège du NOT IN), Q8 (niveaux d'isolation et WAL), Q9 (schéma de facturation de l'architecture polyglotte) |
| `responses_tp.txt` | Réponses rédigées aux 9 questions |
| `resultats_explain.txt` | Plans EXPLAIN ANALYZE obtenus pour les questions 1, 2 et 7 |

Les scripts s'exécutent dans l'ordre A, B, C sur la base `datalab_b2`.

## Remarques

- `tp_partie_a.sql` insère une commande test (id 241) : pour rejouer le script, il faut d'abord la supprimer.
- La question 8 se joue dans deux sessions du simulateur ACID, en suivant les étapes indiquées dans `tp_partie_c.sql`.
