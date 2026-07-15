# Project Zomboid - Mod "Escapade Express"

## Contexte
- LAN avec neveux (4 joueurs, 16+ ans, debutants)
- Build 41, map vanilla + Xonic's Mega Mall (mod Workshop)
- Le but du projet est d'ajouter un nouveau scenario a Pillow's Random Scenarios (mod Workshop ID: 2106657533)
- Le but N'EST PAS de creer un nouveau mode de jeu separe

## Mods requis
- Pillow's Random Scenarios (deja installe via Steam Workshop) -- mod cible auquel on ajoute le scenario
- Xonic's Mega Mall (Workshop ID: 1713269594) -- a installer

## Dossier de travail
/Users/kim/Documents/Zomboid/

## Fichiers de reference
- pz-mod-doc.md -- doc technique complete (API B41, pattern Pillow's, coords mall)
- Repo GitHub: https://github.com/ksdok/escapade-express
- Skill Hermes: project-zomboid-modding (references/api-build41.md, templates/scenario-template.lua)

---

## SCENARIO 1: "Escapade Express" -- EN COURS

### Decision d'architecture (VALIDE)
- Le projet doit rester un scenario dans le modele de Pillow's Random Scenarios
- Le projet ne doit pas deriver vers un nouveau mode de jeu distinct
- La structure `LastStand/Challenges` est coherente avec l'objectif du projet
- Le multijoueur LAN reste une contrainte fonctionnelle a traiter dans ce cadre
- Le serveur doit rester autorite pour les elements multi sensibles (revive, sync d'events, vehicule, etc.) si necessaire

### Etat actuel
- Un prototype de scenario base sur Pillow's Random Scenarios a ete cree
- La revue a releve plusieurs problemes techniques dans ce prototype
- Le backlog ci-dessous est redecoupe en tickets small a medium pour corriger et fiabiliser le scenario
- Le point d'entree scenario est conserve; on corrige l'implementation plutot que changer de produit

### Concept (VALIDE)
- 4 joueurs coop, debutants
- Spawn dans l'arriere-boutique du mall (Xonic's Mega Mall, cell 37x28)
- 4 roles: Soldat, Voleur, Local, Medic -- skills et items differents
- Objectif: traverser le mall, trouver un vehicule dans le parking, s'enfuir
- Vehicule sans essence -- faut trouver un bidon
- Chronometre 3h (visible)
- Densite zombies: faible au debut, augmente avec le temps
- Mort: joueur ranimable (medic 30 sec, autre joueur 1 min, sinon respawn depart)

### Evenements scriptes (VALIDES)
1. Coupure electrique (~45 min) -- lumieres coupees, torches obligatoires
2. Incendie (~2h) -- feu dans une boutique aleatoire, se propage, attire zombies
3. Alarme -- NON (rejete par l'utilisateur)

### Twists
- Boutique d'armes fermee (Voleur peut crocheter)
- Magasin de nourriture (faire le plein avant fuite)
- Pharmacie (medicaments supplementaires)
- Vehicule dans parking sans essence (faut trouver bidon)

---

## TACHES

### Phase 1: Recherche technique -- TERMINE
- [x] Lire le code source de Pillow's Random Scenarios (GitHub)
- [x] Identifier le pattern d'un scenario (Add, OnGameStart, OnNewGame, spawns, metadata)
- [x] API B41: vehicules (addVehicleDebug, GasTank, createVehicleKey)
- [x] API B41: incendie (IsoFireManager.StartFire, explode)
- [x] API B41: electricite (sq:setHaveElectricity)
- [x] API B41: sante/revive (setHealth, setKnockedDown, OnPlayerDeath)
- [x] API B41: skills (getXp():setXPToLevel), items, stats
- [x] API B41: chronometre (getWorldAgeHours, OnPostUIDraw)
- [x] API B41: spawn zombies (addZombiesInOutfit, addSound)
- [x] Coordonnees mall: cell 37x28, 3-cell size, entre Muldraugh et West Point
- [x] Compiler la doc technique (pz-mod-doc.md)
- [x] Mettre a jour le skill Hermes project-zomboid-modding

### Phase 2: Prototype scenario Pillow's -- TERMINE MAIS A CORRIGER
- [x] Creer la structure initiale du mod (mod.info, poster.png, dossiers)
- [x] Coder un prototype `LastStand/Challenges` base sur Pillow's Random Scenarios
- [x] Coder une UI de chronometre/messages
- [x] Coder une logique serveur initiale (roles, revive, vehicule)
- [x] Faire une revue technique du prototype
- [x] Identifier les ecarts critiques et les bugs probables

### Phase 3: Correctifs du scenario -- EN COURS
- [x] Corriger l'ordre d'initialisation du scenario (`OnGameStart`, `OnNewGame`, hooks)
- [x] Corriger les commandes reseau client/serveur
- [x] Corriger le spawn du bidon avec l'API monde correcte
- [x] Verifier si `getTimestampMs()` est valide, sinon remplacer
- [x] Revoir la logique de revive pour coller a la spec (medic 30 sec / autre 1 min / sinon respawn)
- [ ] Verifier la synchro multi des events (coupure elec, incendie, zombies, game over)
- [ ] Garder les coordonnees en placeholders tant que le debug en jeu n'est pas fait

### Phase 4: Test du scenario -- A FAIRE
- [ ] Installer le mod dans ~/Zomboid/mods/
- [ ] Verifier que le scenario apparait dans Challenges via Pillow's Random Scenarios
- [ ] Test solo: verifier spawn, items, skills, chronometre
- [ ] Test solo: verifier coupure elec et incendie
- [ ] Test multi (LAN): verifier revive, sync des events, vehicule, spawn bidon
- [ ] Ajuster les coordonnees de spawn selon le mall
- [ ] Ajuster la difficulte (nombre de zombies, timing des events)

### Phase 5: Distribution -- A FAIRE
- [ ] Zipper le mod pour les neveux
- [ ] (Optionnel) Publier sur Steam Workshop

### Tickets proposes (taille small a medium)
- [x] EE-01 (S) - Corriger l'initialisation du scenario Pillow's (`OnGameStart`, `OnNewGame`, registration)
- [x] EE-02 (S) - Corriger tous les appels `sendClientCommand` / `sendServerCommand`
- [x] EE-03 (S) - Corriger le spawn du bidon avec `SpawnWorldInventoryItem` ou equivalent valide
- [x] EE-04 (S) - Verifier/remplacer `getTimestampMs()` dans l'UI
- [x] EE-05 (M) - Revoir la logique de revive pour respecter la spec (medic 30 sec / autre 1 min / sinon respawn) et le multijoueur
- [ ] EE-06 (M) - Fiabiliser l'assignation des 4 roles et des items/skills au lancement du scenario
- [ ] EE-07 (M) - Fiabiliser la synchro multi des evenements scripts cote serveur
- [ ] EE-08 (S) - Nettoyer les messages dupliques client/UI
- [ ] EE-09 (S) - Definir et documenter les placeholders de coords du mall dans le code
- [ ] EE-10 (M) - Ajouter un plan de test minimal solo + LAN pour le scenario complet
- [ ] EE-11 (S) - Definir collaborativement les objets de chaque role (items, quantites, vetements, equipement) -- validation utilisateur requise avant implementation
- [ ] EE-12 (M) - Ajouter de nouveaux roles: Rambo, Sniper, Samourai (skills, items, mecaniques specifiques) -- adapter le systeme d'assignation pour >4 roles

---

## POINTS BLOQUANTS / RISQUES

1. COORDONNEES EXACTES DU MALL
   - Cell 37x28 connu, mais position precise dans le mall inconnue
   - Doit etre releve en jeu avec le mode debug
   - Placeholders utilises en attendant (xcell=37, ycell=28, x=100-200)

2. REVIVE EN MULTIPLAYER
   - OnPlayerDeath est cote CLIENT
   - setHealth() sur un autre joueur peut ne pas marcher cote client
   - Peut necessiter du code serveur (sendClientCommand/addServerCommand)
   - Le jeu peut forcer la mort malgre setHealth dans la meme frame
   - Reference: mod "Death Prevention" (Workshop ID 3244802339)

3. COUPURE ELECTRIQUE EN MULTI
   - setHaveElectricity est par square, cote serveur
   - Peut necessiter du code serveur pour autorite

4. LIMITES DU MODELE SCENARIO EN LAN
   - Le point d'entree scenario est voulu, mais il faut verifier son comportement reel en LAN
   - Certaines mecaniques peuvent etre plus fragiles en multi qu'en solo
   - Les tests LAN sont donc obligatoires avant d'ajouter plus de complexite

---

## HISTORIQUE

- 2026-07-15: Recherche de mods fun pour LAN Project Zomboid
- 2026-07-15: Decouverte du mod Pillow's Random Scenarios
- 2026-07-15: Brainstorm scenario 1 "Escapade Express" -- concept valide
- 2026-07-15: Recherche technique complete (API B41, coords mall, JavaDocs)
- 2026-07-15: Doc technique creee (pz-mod-doc.md)
- 2026-07-15: Skill Hermes project-zomboid-modding mis a jour (api-build41.md, scenario-template.lua)
- 2026-07-15: Dossier de travail cree: /Users/kim/Documents/Zomboid/
- 2026-07-15: backlog project-state.md cree
- 2026-07-15: Repo GitHub cree: https://github.com/ksdok/escapade-express
- 2026-07-15: Revue du prototype initial terminee
- 2026-07-15: Clarification: le but est d'ajouter un scenario a Pillow's Random Scenarios, pas de creer un nouveau mode
- 2026-07-15: Backlog redecoupe en tickets small a medium pour corriger et fiabiliser ce scenario
- 2026-07-15: EE-05 implemente cote client/serveur et spec revive reduite a 30 sec (medic) / 1 min (autres)
