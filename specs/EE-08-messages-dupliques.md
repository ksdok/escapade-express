# EE-08 (S) - Nettoyer les messages dupliques client/UI

## Contexte

Le projet a evolue depuis la premiere version de cette spec:

- les evenements globaux du scenario (coupure elec, fumee, incendie, game over) sont maintenant emis cote serveur via `AlertMessage`
- l'assignation de role est deja affichee uniquement dans le HUD (`EscapadeExpressUI.lua`)
- le client garde surtout les `Say()` de roleplay local (intro, warnings temps, etat du joueur)

Conclusion: la plupart des doublons historiques ont deja ete elimines par EE-07 et EE-13.
Le cleanup EE-08 doit donc cibler les doublons encore reels dans le code actuel.

## Doublon encore present

### PlayerDown (joueur a terre)

Flux actuel:

1. Le joueur qui tombe a terre declenche localement:
   - `player:Say("Je suis a terre! Quelqu'un peut me ranimer!")`
2. Le serveur broadcast ensuite `PlayerDown` a tous les clients
3. Le client affiche aujourd'hui pour tout le monde:
   - `pl:Say(data.username .. " est a terre! Allez le ranimer!")`

Resultat:
- les autres joueurs voient un message utile -> OK
- le joueur a terre voit 2 messages pour le meme event:
  - son message local `Je suis a terre...`
  - puis son propre nom via le broadcast serveur

## Regle cible

- **Say() local**: conserve pour les messages roleplay du personnage local
- **Broadcast serveur `PlayerDown`**: conserve pour informer les autres joueurs
- **Pas de doublon pour le joueur concerne par l'evenement**

## Correction demandee

### `media/lua/client/LastStand/EscapadeExpress.lua`

Dans le handler `onServerCommand`, branche `PlayerDown`:

- garder le message broadcast pour les autres joueurs
- ne rien afficher si `data.username == pl:getUsername()`

Pseudo-regle:

```lua
elseif command == "PlayerDown" then
    local pl = getPlayer()
    if pl and data and data.username and data.username ~= pl:getUsername() then
        pl:Say(data.username .. " est a terre! Allez le ranimer!")
    end
end
```

## Hors scope

Ne pas modifier dans EE-08:

- les warnings temporels (`Plus que 2 heures`, etc.)
- le message d'intro scenario
- les messages `PlayerRevived` / `PlayerRespawned` tant qu'ils ne sont pas dupliques
- les `AlertMessage` serveur pour coupure, fumee, incendie, game over

## Critere d'acceptation

1. Quand un joueur tombe a terre, **il ne voit qu'un seul message**: `Je suis a terre!...`
2. Les autres joueurs voient toujours: `<username> est a terre! Allez le ranimer!`
3. Aucun changement de comportement pour les warnings de temps et les alerts HUD serveur
4. Pas de regression sur le flux revive / respawn

## Taille estimee

Small (S) -- guard supplementaire dans le handler client `PlayerDown`
