# EE-08 (S) - Nettoyer les messages dupliques client/UI

## Contexte

Les messages du scenario sont affiches par deux canaux independants:
1. `pl:Say("texte")` dans `EscapadeExpress.lua` -- bulle au-dessus du personnage
2. `UI.addMessage("texte", color)` dans `EscapadeExpressUI.lua` -- message HUD temporaires
3. `sendServerCommand("EscapadeExpress", "AlertMessage", {...})` -- message serveur -> UI

## Doublons identifies

### Doublon 1: Assignation de role

- Client `onServerCommand RoleAssigned` (EscapadeExpress.lua ligne 311-312):
  `pl:Say("Mon role: " .. data.roleName)`
- UI `onServerCommand RoleAssigned` (EscapadeExpressUI.lua ligne 155-157):
  `UI.addMessage("Role: " .. data.roleName, COLOR_GREEN)`

Resultat: 2 messages pour le meme event (bulle + HUD).

### Doublon 2: Coupure electrique

- Client `EveryMinutes` (ligne 187):
  `pl:Say("Coupure de courant! Les lumieres sont eteintes.")`
- Serveur `cutPower()` (ligne 255-258):
  `sendServerCommand("EscapadeExpress", "AlertMessage", {text="COUPURE DE COURANT!..."})`

Resultat: Le joueur voit la bulle + le message HUD + les autres joueurs voient
aussi le message serveur. Trop de messages pour un seul event.

### Doublon 3: Incendie

- Client `EveryMinutes` (ligne 205):
  `pl:Say("Un incendie! Le feu se propage!")`
- Serveur `startFire()` (ligne 276-279):
  `sendServerCommand("EscapadeExpress", "AlertMessage", {text="INCENDIE!..."})`

### Doublon 4: Game over

- Client `EveryMinutes` (ligne 216):
  `pl:Say("TEMPS ECOULE! Les zombies envahissent le mall!")`
- Serveur `triggerGameOver()` (ligne 316-318):
  `sendServerCommand("EscapadeExpress", "AlertMessage", {text="TEMPS ECOULE!..."})`

### Doublon 5: PlayerDown

- Client `OnPlayerDeath` (ligne 296):
  `player:Say("Je suis a terre! Quelqu'un peut me ranimer!")`
- Serveur `markPlayerDowned()` (ligne 372-374):
  `sendServerCommand("EscapadeExpress", "PlayerDown", {username=...})`
- Client `onServerCommand PlayerDown` (ligne 315-318):
  `pl:Say(data.username .. " est a terre! Allez le ranimer!")`

Resultat: Le joueur a terre dit "Je suis a terre" + le serveur broadcast
"X est a terre" + chaque client le dit aussi. 3 messages pour le meme event.

## Spec corrective

### Regle: un canal par type de message

- **Say()**: messages roleplay du personnage (intro, warnings temporels)
- **AlertMessage (UI HUD)**: events globaux du scenario (coupure elec, incendie, game over)
- **Pas de Say() sur un event qui a deja un AlertMessage serveur**

### Corrections

1. **RoleAssigned**: Garder uniquement `UI.addMessage` (HUD). Retirer le `pl:Say`.
2. **Coupure elec**: Retirer le `pl:Say` du client. Garder uniquement l'AlertMessage serveur.
   Garder le `pl:playSound("LightbulbBurnedOut")` cote client.
3. **Incendie**: Retirer le `pl:Say` du client. Garder l'AlertMessage serveur.
   Garder le `pl:playSound("SmallExplosion")` cote client.
4. **Game over**: Retirer le `pl:Say` du client. Garder l'AlertMessage serveur.
5. **PlayerDown**: Garder le `pl:Say` du joueur a terre (roleplay). Retirer le
   `pl:Say` des autres clients (deja couvert par l'AlertMessage). Ou inversement:
   retirer le Say du joueur et garder uniquement le broadcast.

## Fichiers a modifier

- `media/lua/client/LastStand/EscapadeExpress.lua`:
  - Retirer `pl:Say` aux lignes 187, 205, 216, 312
  - Retirer (ou garder) le `pl:Say` ligne 296 et 318
- `media/lua/client/EscapadeExpressUI.lua`:
  - Garder le handler `AlertMessage` et `RoleAssigned` tels quels

## Critere d'acceptation

1. Chaque event du scenario produit au maximum 1 message visible
2. Les messages roleplay (warnings temporels "Plus que 30 min!") restent en Say()
3. Les messages d'event (coupure, incendie, game over) passent uniquement par AlertMessage

## Dependencies

- **EE-07 recommande avant**: Si EE-07 deplace les events cote serveur, certains
  doublons disparaissent naturellement (le client ne declenche plus les events).
  Faire EE-08 apres EE-07 simplifie le cleanup.

## Taille estimee

Small (S) -- suppression de ~6 lignes `pl:Say()` + ajustements