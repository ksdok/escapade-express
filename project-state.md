# Project Zomboid - Mod "Escapade Express"

## Contexte
- LAN avec neveux (4 joueurs, 16+ ans, debutants)
- Build 41, map vanilla + Xonic's Mega Mall (mod Workshop)
- Base sur Pillow's Random Scenarios (mod Workshop ID: 2106657533)

## Mods requis
- Pillow's Random Scenarios (deja installe via Steam Workshop)
- Xonic's Mega Mall (Workshop ID: 1713269594) -- a installer

## Dossier de travail
/Users/kim/Documents/Zomboid/

## Fichiers de reference
- pz-mod-doc.md -- doc technique complete (API B41, pattern Pillow's, coords mall)
- Skill Hermes: project-zomboid-modding (references/api-build41.md, templates/scenario-template.lua)

---

## SCENARIO 1: "Escapade Express" -- EN COURS

### Concept (VALIDE)
- 4 joueurs coop, debutants
- Spawn dans l'arriere-boutique du mall (Xonic's Mega Mall, cell 37x28)
- 4 roles: Soldat, Voleur, Local, Medic -- skills et items differents
- Objectif: traverser le mall, trouver un vehicule dans le parking, s'enfuir
- Vehicule sans essence -- faut trouver un bidon
- Chronometre 3h (visible)
- Densite zombies: faible au debut, augmente avec le temps
- Mort: joueur ranimable (medic 5 min, autre joueur 10 min, sinon respawn depart)

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

### Phase 2: Codage -- TERMINE
- [x] Créer la structure du mod (mod.info, poster.png, dossiers)
- [x] Coder EscapadeExpress.lua (scenario principal: spawn, roles, items, skills)
- [x] Coder EscapadeExpressUI.lua (chronometre visible, messages)
- [x] Coder EscapadeExpressServer.lua (revive multi, spawn vehicule)
- [x] Implementer les 4 roles avec skills/items differents
- [x] Implementer le chronometre 3h avec affichage
- [x] Implementer l'augmentation progressive des zombies
- [x] Implementer la coupure electrique (~45 min)
- [x] Implementer l'incendie (~2h)
- [x] Implementer le systeme de revive (medic 5 min / autre 10 min)
- [x] Implementer le spawn du vehicule dans le parking
- [ ] Coordonnees exactes du mall (a determiner en jeu avec debug) -- PLACEHOLDERS

### Phase 3: Test -- A FAIRE
- [ ] Installer le mod dans ~/Zomboid/mods/
- [ ] Test solo: verifier que le scenario apparait dans Challenges
- [ ] Test solo: verifier spawn, items, skills, chronometre
- [ ] Test solo: verifier coupure elec et incendie
- [ ] Test multi (LAN): verifier revive, sync des events
- [ ] Ajuster les coordonnees de spawn selon le mall
- [ ] Ajuster la difficulte (nombre de zombies, timing des events)

### Phase 4: Distribution -- A FAIRE
- [ ] Zipper le mod pour les neveux
- [ ] (Optionnel) Publier sur Steam Workshop

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