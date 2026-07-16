# Escapade Express - Mod Project Zomboid (Build 41)

Scenario coop 4 joueurs: echappez du Xonic's Mega Mall en 3h!

## Installation

1. Copier le dossier `EscapadeExpress/` dans `~/Zomboid/mods/`:
   ```
   cp -r EscapadeExpress ~/Zomboid/mods/
   ```
2. Activer les mods dans le jeu:
   - Pillow's Random Scenarios (Workshop ID: 2106657533)
   - Xonic's Mega Mall (Workshop ID: 1713269594)
   - Escapade Express (mod local)
3. Menu principal > Challenges > Escapade Express

## Roles (4 joueurs)

| Role | Competences | Items cles |
|------|-------------|------------|
| Soldat | Aiming 4, Reloading 3, Strength 4 | Pistol + munitions, bandeaux |
| Voleur | Sneak 5, Lightfoot 5, Nimble 5 | Crowbar, screwdriver (crochetage) |
| Local | Cooking 4, Carpentry 4 | Hammer, clous, nourriture, sac |
| Medic | Doctor 6 | Bandages, desinfectant, antibiotiques |

## Mecaniques

- **Chronometre 3h** visible en haut a gauche
- **Coupure electrique** a ~45 min (lumieres coupees)
- **Incendie** a ~2h dans une boutique aleatoire (se propage)
- **Vehicule** dans le parking (essence vide, bidon a trouver)
- **Zombies**: densite faible au debut, augmente chaque heure
- **Revive**: medic 30 sec, autre joueur 1 min, sinon respawn

## Coordonnees (PLACEHOLDERS)

Toutes les coordonnees sont des placeholders basees sur cell 37x28.
Elles DOIVENT etre ajustees en jeu avec le mode debug:

1. Lancer le jeu avec Xonic's Mega Mall + Escapade Express
2. Mode debug (Sandbox > Debug Mode)
3. Teleporter a la position souhaitee
4. Lire les coordonnees (F3 ou console: `getPlayer():getX()`)
5. Convertir: xcell = floor(x/300), x = x - (xcell*300)
6. Modifier uniquement `media/lua/shared/EscapadeExpressConfig.lua`
   - spawn (`EE_Config.spawn`)
   - parking (`EE_Config.parking`)
   - respawn (`EE_Config.respawn`)
   - entrees (`EE_Config.entrances`)
   - boutiques (`EE_Config.shops`)
   - bidon (`EE_Config.gasCan`)
   - zone coupure elec (`EE_Config.powerOutageCenter`, `EE_Config.powerOutageRadius`)

## Structure

```
EscapadeExpress/
  mod.info
  poster.png
  media/
    lua/
      shared/
        EscapadeExpressConfig.lua   -- placeholders coords + helpers world<->cell
      client/
        LastStand/
          EscapadeExpress.lua        -- scenario principal (spawn, roles, events)
          EscapadeExpress.png        -- image du challenge
        EscapadeExpressUI.lua        -- chronometre UI + messages
      server/
        EscapadeExpressServer.lua   -- logique serveur (revive, vehicule, power, fire)
```

## Test

1. Installer dans `~/Zomboid/mods/`
2. Solo: verifier que le scenario apparait dans Challenges
3. Solo: verifier spawn, items, skills, chronometre
4. Solo: attendre 45 min (jeu) pour coupure elec
5. Solo: attendre 2h (jeu) pour incendie
6. Multi (LAN): verifier revive, sync events
7. Ajuster les coordonnees selon le mall reel

## Mods requis

- Pillow's Random Scenarios (Workshop ID: 2106657533)
- Xonic's Mega Mall (Workshop ID: 1713269594)

## Auteur

Kim