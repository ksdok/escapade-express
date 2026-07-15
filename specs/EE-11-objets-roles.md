# EE-11 (S) - Definir collaborativement les objets de chaque role

## Contexte

Les roles actuels (Soldat, Voleur, Local, Medic) ont des items et skills
definis dans `ROLE_DEFS` (EscapadeExpressServer.lua). Ces definitions sont
des placeholders -- l'utilisateur doit valider et affiner les objets de
chaque role pour le LAN avec les neveux.

## Definition actuelle (placeholders)

### Soldat
- Skills: Aiming 4, Reloading 3, Fitness 4, Strength 4, Sneak 2
- Items: Pistol x1, PistolMagazine x2, Bullets9mm x30, Bandage x3, Torch x1, Battery x2, HoodieDOWNBlackTINT x1, Trousers x1

### Voleur
- Skills: Sneak 5, Lightfoot 5, Nimble 5, Electrical 2, Fitness 3
- Items: Crowbar x1, Screwdriver x1, Bandage x2, Torch x1, Battery x1, HoodieDOWNWhiteTINT x1, Trousers x1, Shoes_Black x1

### Local
- Skills: Cooking 4, Carpentry 4, PlantScavenging 3, Fitness 3, Strength 3
- Items: Hammer x1, Nails x20, Saw x1, WaterBottleFull x2, CannedBeans x2, TinOpener x1, Bandage x2, Bag_NormalHikingBag x1, Map x1

### Medic
- Skills: Doctor 6, Fitness 3, Strength 3, Aiming 2
- Items: Bandage x5, DisinfectantAlcohol x2, Painkillers x2, Antibiotics x1, Torch x1, Battery x2, Bag_DuffelBag x1, Trousers x1, Shoes_Black x1

## Questions a valider avec l'utilisateur

### Q1: Equilibre des roles
- Les roles sont-ils equilibres pour des debutants?
- Le Soldat est-il trop fort (pistol + 30 balles + strength 4)?
- Le Local est-il trop faible en combat?
- Le Medic a-t-il assez de moyens de defense?

### Q2: Vetements et equipement
- Faut-il equiper automatiquement les vetements (hoodie, trousers, shoes)?
- Actuellement l'equipement auto est commente dans `applyRole` (ligne 144-150)
- Faut-il leactiver?

### Q3: Armes de melee
- Le Voleur a un Crowbar. Le Local a un Hammer. Le Soldat a... rien en melee?
- Faut-il donner un couteau ou batte au Soldat?
- Le Medic a-t-il besoin d'une arme de melee?

### Q4: Sac a dos
- Le Local a un HikingBag, le Medic un DuffelBag. Le Soldat et le Voleur n'ont pas de sac.
- Faut-il donner un sac a tous les roles?

### Q5: Nourriture et eau
- Seul le Local a de la nourriture et de l'eau (WaterBottle x2, CannedBeans x2)
- Faut-il donner un minimum (1 bouteille, 1 conserve) a chaque role?

### Q6: Torches et batteries
- Tous les roles ont une torche sauf le Local
- La coupure elec a ~45 min -- tout le monde doit avoir une torche?
- Combien de batteries par role?

### Q7: Items specifiques au scenario
- Faut-il donner un avantage au Voleur pour crocheter la boutique d'armes?
  (Lockpick ou autre item)
- Faut-il donner un avantage au Local pour trouver le bidon d'essence?
  (Map marquee ou indicateur)

### Q8: Skills supplementaires
- Faut-il ajouter Mechanics a un role pour reparer le vehicule?
- Faut-il ajouter Electrical au Voleur pour le crochetage?
- Faut-il ajouter Cooking au Medic pour les remedes?

## Format de validation attendu

Pour chaque role, l'utilisateur valide ou modifie:

```
### [Nom du role]
Skills:
- Perk: niveau (valider ou ajuster)
Items:
- "Item.ID" x quantite (ajouter, retirer, ajuster)
Vetements:
- Equiper automatiquement? (oui/non)
Sac a dos:
- Item.ID du sac (ou aucun)
```

## Fichiers a modifier (apres validation)

- `media/lua/server/EscapadeExpressServer.lua`: `ROLE_DEFS` (lignes 40-122)
- `media/lua/client/EscapadeExpressUI.lua`: `roleNames` (lignes 80-85) si renommage

## Critere d'acceptation

1. L'utilisateur a valide chaque role (items + skills + vetements)
2. Les `ROLE_DEFS` sont mis a jour selon les decisions
3. L'equilibre est valide pour 4 joueurs debutants en LAN
4. Tous les roles ont au minimum: 1 arme, 1 bandage, 1 torche, 1 source d'eau

## Dependencies

- Aucune (independant)
- EE-12 (nouveaux roles) utilisera le meme format de `ROLE_DEFS`

## Taille estimee

Small (S) -- discussion + validation + mise a jour des definitions