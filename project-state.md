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
- Le scenario se lance maintenant en solo, apparait dans Challenges, affiche un role et un chronometre
- Le rythme du timer solo a ete corrige; le positionnement HUD reste a peaufiner plus tard
- Le choix de role post-spawn est maintenant implemente avec UI custom, validation serveur et timer retarde apres selection initiale
- EE-12 est maintenant implemente: roster etendu a 16 roles uniques + Civil selectable/fallback, equipement automatique, picker compact en grille
- Le lancement du jeu charge bien Escapade Express sans erreur Lua du mod; les warnings restants vus en log semblent venir surtout de Xonic's Mega Mall / map data
- EE-08 est nettoye: le joueur a terre ne recoit plus son propre broadcast `PlayerDown`
- EE-09 est implemente: les placeholders de coords sont centralises dans `media/lua/shared/EscapadeExpressConfig.lua`
- Les coords reelles du spawn, de la voiture et du bidon ont maintenant ete relevees en jeu et injectees dans la config shared
- EE-14 est maintenant implemente et valide en jeu: le vehicule d'escape explose 2-3 sec apres le premier demarrage, une seule fois, avec timer tick-based cote serveur et fallback solo
- EE-11 est maintenant implemente en code pour l'ensemble du roster valide (16 roles + Civil), avec `bagContents` pour ranger directement une partie du loadout dans le sac
- Les roles restants EE-11 (Pompier, Mecanicien, Athlete, Eclaireur, Demolisseur, Invincible, Mule, Civil) sont maintenant reportes cote serveur et dans le fallback client
- EE-15 est maintenant implemente en code: van sans cle, batterie dechargee, cle et batterie cachees dans le mall, hordes declenchees sur ramassage des objets d'objectif sous validation serveur
- Les coords reelles de la cle et de la batterie ont maintenant ete relevees en jeu et injectees dans la config shared
- Le prochain focus doit revenir sur les tests solo/LAN complets de EE-15 (cle/batterie/hordes) et la validation en jeu du roster EE-11

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
- [x] Verifier la synchro multi des events (coupure elec, incendie, zombies, game over)
- [x] Remplacer les placeholders valides releves en jeu pour le spawn, la voiture et le bidon; garder le reste en attente du debug complementaire

### Phase 4: Test du scenario -- EN COURS
- [x] Installer le mod dans ~/Zomboid/mods/
- [x] Verifier que le scenario apparait dans Challenges via Pillow's Random Scenarios
- [ ] Test solo: verifier spawn, items, skills, chronometre
- [ ] Test solo: verifier coupure elec et incendie
- [ ] Test multi (LAN): verifier revive, sync des events, vehicule, spawn bidon
- [x] Ajuster les coordonnees de spawn selon le mall
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
- [x] EE-06 (M) - Fiabiliser l'assignation des 4 roles et des items/skills au lancement du scenario
- [x] EE-07 (M) - Fiabiliser la synchro multi des evenements scripts cote serveur
- [x] EE-08 (S) - Nettoyer les messages dupliques client/UI
- [x] EE-09 (S) - Definir et documenter les placeholders de coords du mall dans le code
- [x] EE-10 (M) - Ajouter un plan de test minimal solo + LAN pour le scenario complet
- [x] EE-11 (S) - Definir collaborativement les objets de chaque role (items, quantites, vetements, equipement) et implementer les loadouts valides pour l'ensemble du roster avec rangement direct dans le sac
- [x] EE-12 (M) - Ajouter de nouveaux roles: roster etendu a 16 roles uniques + Civil selectable/fallback, equipement automatique, picker grille, assignation >4 joueurs
- [x] EE-13 (M) - Ajouter un choix de role post-spawn avec UI custom, validation serveur et demarrage du timer apres selection initiale
- [x] EE-14 (M) - Faire exploser le vehicule d'escape 2-3 sec apres le premier demarrage moteur, une seule fois, sous autorite serveur
- [x] EE-15 (M) - Cle de vehicule, batterie déchargee et hordes declenchees par ramassage d'objet-cle (bidon/cle/batterie)
- [ ] EE-16 (S) - Role Builder: skills construction a 10, setUnlimitedCarry, stock massif, re-garnissage periodique EveryTenMinutes

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
- 2026-07-15: Clean-up post-review applique sur EE-05 (doc revive alignee + setDoDeathSound cote serveur)
- 2026-07-15: EE-07 implemente: timer et evenements scripts passes sous autorite serveur avec SyncTimer pour les late joiners
- 2026-07-15: EE-07 corrige post-review: warnings late joiner alignes sur le vrai temps restant et AlertMessage dedoublonne avec l'UI
- 2026-07-15: EE-06 implemente: slots deterministes par username, rejoin conserve, loadouts non dupliques, 5e joueur refuse
- 2026-07-15: Plan de test minimal EE-10 redige pour solo + LAN
- 2026-07-15: Bug de chargement corrige: `Events.EveryMinutes` remplace par `Events.EveryOneMinute` (B41)
- 2026-07-15: Fallback solo ajoute puis scenario valide en solo de base (apparition dans Challenges, role visible, chronometre visible)
- 2026-07-15: Rythme du timer solo corrige via day length temps reel; HUD role/timer encore a peaufiner
- 2026-07-15: Spec EE-13 redigee pour un choix de role post-spawn avec UI custom et validation serveur
- 2026-07-16: Spec EE-13 ajustee (payload ChooseRole sans username client, timer decouple de la preparation technique, variante solo documentee)
- 2026-07-16: EE-13 implemente: role picker UI, validation serveur, roster initial, timer demarre apres selection, rejoin conserve, fallback solo
- 2026-07-16: Polish post-review EE-13 applique: hook fallback solo deregistre, reset d'etat serveur au nouveau scenario, helper temps partage, sync timer sur refus tardif
- 2026-07-16: EE-12 implemente: 12 nouveaux roles ajoutes, Civil selectable + fallback automatique, equipement auto au spawn, picker role etendu
- 2026-07-16: Revue EE-12 integree: spec alignee sur Civil selectable, layout picker passe en grille compacte 3 colonnes
- 2026-07-16: Lancement du jeu verifie via console.txt: chargement Escapade Express OK, vehicule/bidon/scenario prepares, pas d'erreur Lua du mod au boot
- 2026-07-16: EE-08 nettoye: broadcast `PlayerDown` ignore maintenant le joueur deja a terre
- 2026-07-16: EE-09 implemente: config shared `EscapadeExpressConfig.lua` ajoutee, placeholders coords centralises client/serveur
- 2026-07-16: Spawn valide releve en jeu: rectangle monde X=11356..11360, Y=8944..8946, Z=0 (cell 37x29)
- 2026-07-16: Coordonnees validees en jeu: voiture au parking X=11189, Y=8739, Z=0; bidon X=11174, Y=8432, Z=4
- 2026-07-16: Role Invincible ajuste: `Base.Map` ajoutee au loadout
- 2026-07-16: EE-14 propose: explosion du vehicule d'escape 2-3 sec apres le premier demarrage moteur (one-shot, serveur)
- 2026-07-16: EE-14 implemente et valide en jeu: trigger au premier demarrage, one-shot, timer tick-based cote serveur, fallback solo, alertes warning/danger
- 2026-07-16: EE-11 implemente en code pour 8 roles valides; `ROLE_DEFS` serveur/client synchronises, `bagContents` ajoute, role picker et README mis a jour, verification `luac -p` OK
- 2026-07-16: Survivaliste valide puis aligne en code (ALICE pack, HuntingRifle, x4Scope, .308 x40, equipement de camping dans le sac), serveur/client synchronises et syntaxe Lua OK
- 2026-07-16: Validation spec EE-11 terminee pour les roles restants: Pompier, Mecanicien, Athlete, Eclaireur, Demolisseur, Invincible, Mule et Civil
- 2026-07-16: EE-11 etendu aux roles restants; `ROLE_DEFS` serveur/client realignes pour le roster complet, `bagContents` ajoute sur les nouveaux sacs, verification `luac -p` OK
- 2026-07-18: Spec EE-15 validee puis ajustee avec la doc PZ B41 / Context7: batterie monde en `Base.CarBattery1`, detection serveur par reference d'objet, fallback client immediat pour bidon/batterie
- 2026-07-18: Coordonnees validees en jeu pour EE-15: cle X=11601 Y=8681 Z=0; batterie X=11520 Y=8405 Z=0
- 2026-07-18: EE-15 implemente en code puis corrige post-review: van sans cle + batterie dechargee, spawns cle/batterie, hordes one-shot, scan recursif des sacs cote serveur, retrait du `PetrolCan` du role Mule, verification `luac -p` OK
