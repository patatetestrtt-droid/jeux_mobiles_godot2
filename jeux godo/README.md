# Mini Games - Godot

Projet de départ Godot pour votre appli de mini-jeux Android hors ligne.

## Ce qui est déjà inclus

- Menu principal
- Écran de sélection des jeux
- Block Blast jouable
- Grille 8x8
- Pièces aléatoires
- Glisser-déposer à la souris ET au tactile
- Lignes horizontales/verticales
- Carrés 5x5
- Score
- Meilleur score sauvegardé localement
- Game Over
- Rejouer
- Aucun téléchargement d'image ou de donnée pendant le jeu

## Ouvrir

1. Installer Godot 4.x depuis https://godotengine.org/
2. Ouvrir Godot
3. Importer le dossier contenant `project.godot`
4. Ouvrir le projet
5. Appuyer sur F6/F5 pour lancer

## Ajouter un jeu

Créez un dossier dans `games/`, puis ajoutez une scène/script.
Ensuite, ajoutez un bouton dans `scripts/main.gd`.

## Android

Dans Godot : Project > Export > Add Android.

Pour publier sur Google Play, configurez ensuite le nom du package, la version, la signature et exportez un AAB.

## Important

Le prototype p5.js original utilisait une image distante. Cette version n'en dépend pas : tout le rendu du prototype est généré localement, donc le jeu n'a pas besoin d'Internet.
