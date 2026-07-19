# EE-10 (M) - Ajouter un plan de test minimal solo + LAN pour le scenario complet

## Contexte

Le scenario n'a pas encore ete teste en jeu. Les tests doivent verifier que
toutes les mecaniques fonctionnent en solo d'abord, puis en LAN (multiplayer).

## Prerequis

- Pillow's Random Scenarios installe (Workshop ID: 2106657533)
- Xonic's Mega Mall installe (Workshop ID: 1713269594)
- Escapade Express installe dans `~/Zomboid/mods/EscapadeExpress/`
- Mode debug active (Sandbox > Debug Mode) pour les tests

## Plan de test SOLO

### T-SOLO-01: Le scenario apparait dans Challenges

**Etapes:**
1. Lancer Project Zomboid
2. Menu principal > Challenges
3. Chercher "Escapade Express"

**Resultat attendu:**
- "Escapade Express" apparait dans la liste des challenges
- L'image de preview (EscapadeExpress.png) s'affiche

**Si echec:**
- Verifier que `mod.info` a `require=PillowsRandomScenarios`
- Verifier que `EscapadeExpress.lua` est dans `media/lua/client/LastStand/`
- Verifier que `Events.OnChallengeQuery.Add(EscapadeExpress.Add)` est present
- Verifier la console Lua pour les erreurs de chargement

### T-SOLO-02: Spawn et role

**Etapes:**
1. Selectionner "Escapade Express" et lancer la partie
2. Attendre le spawn

**Resultat attendu:**
- Le joueur spawn dans le mall (arriere-boutique)
- Le role "Soldat" est assigne (premier role en solo)
- Les items du role sont dans l'inventaire
- Les skills du role sont set (Aiming 4, etc.)
- Le chronometre s'affiche en haut a gauche ("Temps restant: 3h00")
- "Role: Soldat" s'affiche sous le chronometre

### T-SOLO-03: Chronometre fonctionnel

**Etapes:**
1. Attendre 1 minute de jeu
2. Observer le chronometre

**Resultat attendu:**
- Le chronometre decremente (3h00 -> 2h59 -> 2h58...)
- La couleur change: vert >1h30, jaune <1h30, rouge <30min

### T-SOLO-04: Coupure electrique (~45 min)

**Etapes:**
1. Fast-forward le temps de jeu (debug: SetTime ou attendre)
2. Attendre que ~45 min de jeu s'ecoulent

**Resultat attendu:**
- Message: "COUPURE DE COURANT! Les lumieres sont eteintes."
- Les lumieres du mall s'eteignent
- Le son "LightbulbBurnedOut" joue

**Si echec:**
- Verifier que le serveur recoit `PowerOutage` (console Lua)
- Verifier que `cutPower()` s'execute (print "[EE] Coupure electrique!")
- Si pas de lumieres qui s'eteignent: les coords placeholder sont fausses

### T-SOLO-05: Incendie (~2h)

**Etapes:**
1. Fast-forward a ~2h de jeu
2. Observer

**Resultat attendu:**
- Warning pre-incendie a ~1h54: "Je sens de la fumee..."
- Incendie a ~2h: message "INCENDIE! Le feu se propage dans le mall!"
- Le feu demarre dans une boutique (coords placeholder)
- Le son "SmallExplosion" joue
- Le feu se propage aux tiles adjacents

### T-SOLO-06: Game over (3h)

**Etapes:**
1. Fast-forward a 3h de jeu

**Resultat attendu:**
- Message: "TEMPS ECOULE! Les zombies envahissent tout!"
- Horde massive de zombies aux entrees du mall
- "TEMPS ECOULE - GAME OVER" s'affiche dans le HUD

### T-SOLO-07: Revive / down

**Etapes:**
1. Attirer des zombies et se laisser taper jusqu'a sante < 0.15
2. Observer

**Resultat attendu:**
- Le joueur tombe a terre (knockedDown)
- Le joueur ne meurt pas (health bloque a 0.01)
- Apres 1 min de jeu (pas de medic en solo), respawn au point de depart
- Health remonte a 0.3
- Message: "Je me reveille au point de depart..."

### T-SOLO-08: Vehicule et bidon

**Etapes:**
1. Aller au parking (coords 11345, 8957)
2. Observer le vehicule
3. Chercher le bidon d'essence (coords placeholder 11170, 8490)

**Resultat attendu:**
- Un Van est stationne dans le parking
- Le vehicule est repare mais sans essence (GasTank vide)
- Le bidon d'essence est au sol a sa location

### T-SOLO-09: Augmentation zombies

**Etapes:**
1. Attendre 1h, 2h, 3h de jeu
2. Observer la densite de zombies aux entrees

**Resultat attendu:**
- Heure 0-1: ~3 zombies par entree
- Heure 1-2: ~10 zombies par entree
- Heure 2-3: ~25 zombies par entree

## Plan de test LAN (4 joueurs)

### T-LAN-01: Connexion et roles

**Etapes:**
1. Heberger une partie LAN avec Escapade Express
2. 3 autres joueurs se connectent

**Resultat attendu:**
- Joueur 1: Soldat
- Joueur 2: Voleur
- Joueur 3: Local
- Joueur 4: Medic
- Chaque joueur a ses items et skills
- Le chronometre est synchronise pour tous

### T-LAN-02: Revive avec medic

**Etapes:**
1. Joueur 1 (Soldat) se laisse tomber a terre
2. Joueur 4 (Medic) s'approche a <10 tiles
3. Attendre 30 secondes de jeu

**Resultat attendu:**
- Joueur 1 est ranime apres 30 sec
- Health remonte a 0.5
- Message: "Le medic m'a ranime!"
- Les autres joueurs voient "X est de retour!"

### T-LAN-03: Revive avec autre joueur

**Etapes:**
1. Joueur 2 (Voleur) se laisse tomber a terre
2. Joueur 3 (Local) s'approche a <10 tiles (pas le medic)
3. Attendre 1 minute de jeu

**Resultat attendu:**
- Joueur 2 est ranime apres 1 min
- Health remonte a 0.5
- Message: "Je suis ranime!"

### T-LAN-04: Respawn sans aide

**Eteps:**
1. Joueur 3 (Local) se laisse tomber a terre
2. Tous les autres joueurs s'eloignent (>10 tiles)
3. Attendre 1 minute de jeu

**Resultat attendu:**
- Joueur 3 est respawn au point de depart apres 1 min
- Health remonte a 0.3
- Message: "Je me reveille au point de depart..."

### T-LAN-05: Sync des events

**Etapes:**
1. Attendre ~45 min de jeu
2. Observer la coupure elec sur tous les clients

**Resultat attendu:**
- Tous les clients voient la coupure elec au meme moment
- Les lumieres s'eteignent pour tous
- Aucun client ne declenche l'event en double

### T-LAN-06: Late joiner

**Etapes:**
1. Lancer la partie avec 3 joueurs
2. Apres 30 min, un 4e joueur se connecte

**Resultat attendu:**
- Le 4e joueur obtient le 4e role (Medic)
- Le chronometre est synchronise avec les autres (pas reset a 3h)
- Les events deja passes (coupure elec si >45min) ne se re-declenchent pas

## Fichiers a creer

- `specs/test-plan.md` -- ce document, avec checklist de passage

## Critere d'acceptation

1. Tous les tests T-SOLO passent (9 tests)
2. Tous les tests T-LAN passent (6 tests)
3. Les coords placeholder sont identifiees comme incorrectes (tests 04, 05, 08)
4. Les bugs trouves sont documentes et corriges

## Dependencies

- EE-06 (roles): T-LAN-01 depend du systeme d'assignation
- EE-07 (sync events): T-LAN-05 depend de la synchro serveur
- EE-09 (coords): les tests 04, 05, 08 reveleront les mauvaises coords

## Taille estimee

Medium (M) -- redaction du plan + execution des tests + documentation des resultats