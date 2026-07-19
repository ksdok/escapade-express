# EE-19 — Zone safe de depart (aucun zombie dans un rayon de 20)

## Contexte

Au debut de la partie, le role picker s'ouvre apres le spawn des joueurs.

En pratique, des zombies vanilla peuvent deja etre presents tres pres de la zone de depart. Cela met une pression immediate sur les joueurs et ne laisse pas assez de temps pour choisir un role proprement.

## Probleme

Le scenario ne garantit pas actuellement une zone de depart securisee pendant la phase initiale de choix des roles.

Impact:
- ouverture de partie trop punitive
- role picker difficile a utiliser sous pression
- risque de degats / interruption avant meme le debut reel du scenario

## Objectif

Garantir qu'au lancement du scenario il n'y ait aucun zombie dans un rayon de 20 tiles autour de la zone de spawn.

Le but est de laisser une courte fenetre de securite pour:
- apparaitre correctement
- lire l'UI
- choisir un role
- commencer la partie dans de bonnes conditions

## Specification

### 1. Nettoyage initial des zombies autour du spawn

Au demarrage du scenario, cote serveur, supprimer ou neutraliser tous les zombies presents dans un rayon de 20 tiles autour du centre du spawn.

Comportement attendu:
- zone cible = point de spawn / zone de depart actuelle
- rayon = 50 tiles
- aucun zombie actif ne doit rester dans cette zone juste apres l'initialisation

### 2. Autorite serveur

Le nettoyage doit etre pilote cote serveur pour rester coherent en solo et en multi.

Le client ne doit pas etre responsable de cette logique.

### 3. One-shot au lancement

Le comportement attendu est un nettoyage initial ponctuel, pas un bubble de protection permanente.

Donc:
- le nettoyage se fait une fois au lancement du scenario
- il ne doit pas tourner en boucle en continu
- il ne doit pas empecher plus tard les zombies d'entrer naturellement dans la zone

### 4. Compatibilite avec le role picker

Le nettoyage doit se produire assez tot pour que les joueurs aient reellement le temps de choisir leur role.

Il doit donc etre execute avant, ou au plus tard au moment de l'ouverture du role picker initial.

### 5. Logging discret

Ajouter si utile un log simple du type:
- `Zone safe initiale nettoyee: <n> zombies retires`

Mais:
- pas de spam massif
- pas de log par zombie retire

## Fichiers a modifier

### `EscapadeExpress/media/lua/server/EscapadeExpressServer.lua`
- ajouter un helper serveur de nettoyage initial des zombies autour du spawn
- appeler ce nettoyage au bon moment pendant l'initialisation du scenario

### Optionnel: `EscapadeExpress/media/lua/shared/EscapadeExpressConfig.lua`
- centraliser le rayon ou le centre de la zone safe si cela simplifie le tuning

### `project-state.md`
- ajouter le ticket EE-19
- historiser le besoin de zone safe de depart

## Hors scope

- ne pas changer la densite zombie globale de la map
- ne pas modifier les hordes scriptes EE-15
- ne pas ajouter de protection permanente anti-zombies autour du spawn
- ne pas redesign le role picker

## Criteres d'acceptation

1. Au demarrage, aucun zombie n'est present dans un rayon de 20 autour du spawn
2. Les joueurs peuvent choisir leur role sans pression immediate
3. Le nettoyage fonctionne en solo et en multi
4. Les zombies peuvent ensuite revenir naturellement plus tard
5. La logique EE-15 / EE-17 / timer / role picker n'est pas casse

## Taille estimee

Small a Medium (S/M) — correctif de confort de lancement avec nettoyage serveur ponctuel autour du spawn
