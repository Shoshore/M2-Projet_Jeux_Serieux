# Parcours d'apprentissage : l'arbre de compétences

## Aide-mémoire Godot

### Raccourcis de l'éditeur

| Raccourci | Action |
|---|---|
| **F5** | Lancer le jeu (scène principale) |
| **F6** | Lancer la scène ouverte (pratique pour tester `skill_tree.tscn` seule) |
| **F8** | Arrêter le jeu |
| **Ctrl+S** | Sauvegarder la scène |
| **Ctrl+A** | Ajouter un nœud enfant au nœud sélectionné |
| **Ctrl+Shift+A** | Instancier une scène (`.tscn`) comme enfant |
| **Ctrl+D** | Dupliquer le nœud sélectionné |
| **F2** | Renommer le nœud sélectionné |
| **Ctrl+F1 / F2 / F3** | Passer à la vue 2D / 3D / Script |
| **Q / W / E / S** (vue 2D) | Outil Sélection / Déplacement / Rotation / Échelle |
| **F** (vue 2D) | Centrer la vue sur la sélection |
| **F1** | Chercher dans la documentation intégrée (classes, méthodes, propriétés) |
| **Ctrl+clic** sur un mot (script) | Ouvrir sa définition ou sa page de documentation |
| **Ctrl+Espace** (script) | Forcer l'autocomplétion |
| **Ctrl+K** (script) | Commenter / décommenter les lignes sélectionnées |
| **F9** (script) | Poser / retirer un point d'arrêt (le jeu se met en pause sur cette ligne) |
| **Ctrl+Shift+F** | Rechercher dans tous les fichiers du projet |

### Astuces d'éditeur

- **Glisser un nœud** depuis le dock Scène vers le script écrit son chemin (`$CanvasLayer/Bouton`). Si vous maintenez **Ctrl** en le déposant, Godot écrit directement la ligne `@onready var …` complète.
- **Onglet « Distant » (Remote)** du dock Scène, pendant que le jeu tourne : il montre l'arbre *réel* du jeu et permet de modifier les valeurs en direct. C'est idéal pour voir les nœuds créés par code, comme les `Tile`.
- **Dock « Nœud » → Signaux** (à côté de l'Inspecteur) : double-cliquez sur un signal (par exemple `pressed`) pour le connecter à une fonction d'un script, sans écrire de code.
- **Clic droit sur un nœud → « Accès en tant que nom unique »** : vous pourrez ensuite l'appeler `%NomDuNoeud` depuis le script, même si vous le déplacez dans l'arbre.
- **Survol d'une propriété dans l'Inspecteur** : affiche son nom exact en GDScript, celui à utiliser dans le code (par exemple *Text* → `text`).

### Code GDScript courant

**Récupérer un nœud de la scène et modifier une propriété** (exemple : le texte d'un bouton).

On suppose ici un bouton nommé `BoutonArbre` sous `CanvasLayer`, et le code est écrit dans `map.gd`, qui est attaché à la racine `game` :

```gdscript
# En haut du script : on garde une référence vers le bouton.
# @onready = la variable est remplie juste avant _ready(), quand les nœuds existent.
@onready var bouton_arbre: Button = $CanvasLayer/BoutonArbre
# équivalent : get_node("CanvasLayer/BoutonArbre")
# avec un nom unique : %BoutonArbre

func _ready() -> void:
	bouton_arbre.text = "Compétences"   # modifier le texte
	bouton_arbre.disabled = false        # toute propriété de l'Inspecteur marche pareil
```

Le chemin après `$` part **du nœud qui porte le script**. Si le script est sur un autre nœud, le chemin change. Utilisez `..` pour remonter au parent.

**Afficher / cacher un nœud**

```gdscript
noeud.visible = false   # ou noeud.hide() / noeud.show()
noeud.visible = not noeud.visible   # inverser (basculer)
```

**Réagir à un clic sur un bouton (connexion de signal par code)**

```gdscript
func _ready() -> void:
	bouton_arbre.pressed.connect(_on_bouton_arbre_pressed)

func _on_bouton_arbre_pressed() -> void:
	print("clic !")
```

Si le bouton est en mode interrupteur (`toggle_mode = true`), utilisez le signal `toggled`, qui indique si le bouton est enfoncé ou non :

```gdscript
	bouton_arbre.toggled.connect(_on_bouton_arbre_toggled)

func _on_bouton_arbre_toggled(enfonce: bool) -> void:
	print("enfoncé : ", enfonce)
```

**Créer un nœud à partir d'une scène, par code**

```gdscript
const SCENE_COMPETENCE := preload("res://skill_node.tscn")   # chemin d'exemple

var competence := SCENE_COMPETENCE.instantiate()
add_child(competence)        # l'ajoute dans l'arbre, il devient visible et actif
competence.queue_free()      # le supprime proprement
```

**Autres lignes utiles**

```gdscript
@export var cout: int = 100          # variable modifiable dans l'Inspecteur
print("valeur : ", cout)             # afficher dans le panneau Sortie (en bas)
get_tree().paused = true             # mettre le jeu en pause
set_process_input(false)             # ce nœud arrête de recevoir _input()
```

### Relier deux boutons ronds par une ligne

Le `Control` **racine** de la scène dessine lui-même les lignes dans son `_draw()`. Un parent est toujours dessiné **sous** ses enfants, donc les lignes passent automatiquement derrière les boutons.

Dans le script du `Control` racine :

```gdscript
extends Control

# Adaptez les chemins à votre arbre de nœuds (glisser le nœud dans le script)
@onready var bouton_a: Button = $HBoxContainer/VBoxContainer/Button
@onready var bouton_b: Button = $HBoxContainer/VBoxContainer2/Button

func _ready() -> void:
	resized.connect(queue_redraw)        # redessiner quand la fenêtre change de taille
	await get_tree().process_frame       # attendre que les conteneurs aient placé les boutons
	queue_redraw()

func _draw() -> void:
	draw_line(centre_de(bouton_a), centre_de(bouton_b), Color.WHITE, 4.0)

# Centre d'un bouton, exprimé dans les coordonnées de ce Control
func centre_de(bouton: Control) -> Vector2:
	return bouton.get_global_rect().get_center() - global_position
```

- **`get_global_rect().get_center()`** donne le centre du bouton à l'écran. On passe par les coordonnées globales parce que les boutons sont dans des conteneurs différents, donc leurs `position` ne sont pas exprimées dans le même repère.
- **`- global_position`** convertit ce point dans le repère du `Control` racine, qui est celui où `draw_line` dessine.
- **`queue_redraw()`** redemande un appel à `_draw()`. Godot ne le fait pas tout seul quand les boutons bougent.
- **`await get_tree().process_frame`** attend une image, parce que les conteneurs placent leurs enfants *après* `_ready()`. Sans cette attente, les lignes partiraient d'une mauvaise position au lancement.

Plus tard, avec beaucoup de compétences, chaque compétence connaîtra ses prérequis. `_draw()` fera alors une boucle : pour chaque compétence, un `draw_line` vers chacun de ses prérequis.

*Alternative sans code :* ajoutez un nœud `Line2D` et posez ses points en cliquant dans la vue 2D. Placez-le au-dessus des boutons dans le dock Scène pour qu'il soit dessiné derrière eux. La ligne est en revanche figée : elle ne suit pas les boutons s'ils bougent.

---

Objectif : un bouton en bas à gauche de l'écran ouvre l'arbre de compétences de l'entreprise. Un nouveau clic sur ce même bouton ramène au plateau.

Tous les liens mènent à la documentation officielle (branche `stable`, en anglais). La plupart des pages ont une traduction française : remplacez `/en/` par `/fr/` dans l'URL. Suivez les étapes dans l'ordre. Chacune se termine par un **✅ Checkpoint** : un petit résultat concret à obtenir avant de passer à l'étape suivante.

---

## Étape 0 : les bases du moteur (à ne pas sauter)

1. [Key concepts overview](https://docs.godotengine.org/en/stable/getting_started/introduction/key_concepts_overview.html) : scènes, nœuds, signaux, en une page.
2. [Nodes and Scenes](https://docs.godotengine.org/en/stable/getting_started/step_by_step/nodes_and_scenes.html)
3. [Creating instances](https://docs.godotengine.org/en/stable/getting_started/step_by_step/instancing.html) : une scène peut être réutilisée *dans* une autre scène. C'est ainsi que l'arbre de compétences sera inséré dans le plateau.
4. [Creating your first script](https://docs.godotengine.org/en/stable/getting_started/step_by_step/scripting_first_script.html)
5. [GDScript reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html) : à garder ouverte comme référence, pas besoin de la lire en entier.

✅ **Checkpoint** : vous savez expliquer l'arbre de nœuds de `tile_map.tscn` et à quoi sert `_ready()` dans `scripts/map.gd`.

---

## Étape 1 : les signaux (le cœur du bouton)

Quand on clique sur un bouton, il **émet un signal** (`pressed`). Votre script **se connecte** à ce signal pour réagir.

1. [Using signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) : **tutoriel le plus important de ce parcours.**
2. Référence : [Button](https://docs.godotengine.org/en/stable/classes/class_button.html) et sa classe parente [BaseButton](https://docs.godotengine.org/en/stable/classes/class_basebutton.html). Regardez le signal `pressed` et la propriété `toggle_mode` : un bouton « interrupteur » (enfoncé / relâché) correspond exactement à votre besoin d'ouvrir et de fermer avec le même bouton, via le signal `toggled`.

✅ **Checkpoint** : dans une scène de test, un bouton qui affiche `print("clic")` dans la console à chaque clic.

---

## Étape 2 : l'interface utilisateur (placer le bouton en bas à gauche)

Les éléments d'interface sont des nœuds `Control` : Button, Label, Panel… Ils se placent avec des **ancres** (anchors), pas avec des coordonnées fixes.

1. [User interface (UI)](https://docs.godotengine.org/en/stable/tutorials/ui/index.html) : sommaire de la section.
2. [Size and anchors](https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html) : le preset d'ancrage *Bottom Left* colle le bouton au coin inférieur gauche, quelle que soit la taille de la fenêtre. Votre scène utilise déjà un preset d'ancrage (bas-droite) pour le panneau `info`.
3. [Using Containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html) : pour aligner automatiquement les éléments (HBox, VBox, Grid, Margin…).
4. [Control node gallery](https://docs.godotengine.org/en/stable/tutorials/ui/control_node_gallery.html) : catalogue visuel des nœuds d'interface disponibles.
5. [Canvas layers](https://docs.godotengine.org/en/stable/tutorials/2d/canvas_layers.html) : explique pourquoi votre UI est sous un `CanvasLayer`. L'interface reste fixe à l'écran même quand la caméra du plateau bouge.
6. Exemple complet à lire : [Heads up display (tutoriel « Dodge the Creeps »)](https://docs.godotengine.org/en/stable/getting_started/first_2d_game/06.heads_up_display.html). On y trouve un bouton, des ancres, un CanvasLayer et des signaux dans un vrai jeu.

✅ **Checkpoint** : dans `tile_map.tscn`, un bouton qui reste collé en bas à gauche quand on redimensionne la fenêtre.

---

## Étape 3 : afficher / cacher l'arbre (choix d'architecture)

### Approche recommandée : superposition (overlay)

L'arbre de compétences est **sa propre scène** (`skill_tree.tscn`), instanciée sous le `CanvasLayer` du plateau. Le bouton bascule simplement sa propriété `visible`.

- Le plateau n'est jamais détruit : ni son état ni les cases générées ne sont perdus.
- Le bouton reste au même endroit dans les deux « écrans », ce qui correspond exactement à ce que vous décrivez.
- Pensez à placer le bouton **au-dessus** de l'arbre dans l'arbre de nœuds, sinon l'arbre le recouvrira. Parmi des nœuds frères, le dernier de la liste est dessiné par-dessus les autres.

Lecture : [Control](https://docs.godotengine.org/en/stable/classes/class_control.html) (propriétés `visible`, `mouse_filter`) et [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html) (méthodes `show()`, `hide()`).

### Alternative : changer de scène

C'est possible, mais plus lourd pour votre cas. Le plateau serait détruit à chaque ouverture de l'arbre, et il faudrait sauvegarder son état ailleurs (voir l'étape 5).

- [Using SceneTree](https://docs.godotengine.org/en/stable/tutorials/scripting/scene_tree.html) : `change_scene_to_file()`.
- [Change scenes manually](https://docs.godotengine.org/en/stable/tutorials/scripting/change_scenes_manually.html) : compare les différentes méthodes, dont cacher / montrer des scènes.

### ⚠️ Piège spécifique à votre projet : les clics qui « traversent »

`scripts/map.gd` capte les clics avec `_input()`. Cette fonction reçoit l'événement **avant** l'interface. Si vous ne faites rien, cliquer sur une compétence cliquera aussi sur la case du plateau située en dessous.

- [Using InputEvent](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html) : lisez le schéma sur l'**ordre de propagation** des événements (`_input` → interface → `_unhandled_input`). La solution se trouve dans ce schéma.

Sur le même sujet (facultatif) : [Pausing games](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html), si le plateau doit se figer pendant que l'arbre est ouvert.

✅ **Checkpoint** : le bouton ouvre et ferme un panneau vide qui couvre l'écran, et cliquer sur ce panneau ne sélectionne plus de case.

---

## Étape 4 : construire l'arbre lui-même

### Représenter une compétence (les données)

Une compétence possède un nom, une description, un coût et des prérequis. Dans Godot, on décrit ce genre de données avec une **Resource** personnalisée. On crée ensuite un fichier `.tres` par compétence, directement dans l'éditeur.

1. [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) : voir la partie *Creating your own resources*.
2. [GDScript exported properties](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html) : `@export` rend une variable modifiable dans l'Inspecteur de l'éditeur.

### Afficher les compétences (le visuel)

Chaque compétence devient un bouton (ou une petite scène « nœud de compétence » réutilisable), et les prérequis sont reliés par des lignes.

1. [Custom drawing in 2D](https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html) : pour tracer les liens entre compétences avec `draw_line()`. C'est la même technique que `map.gd` utilise pour les hexagones.
2. Référence : [ScrollContainer](https://docs.godotengine.org/en/stable/classes/class_scrollcontainer.html), si l'arbre dépasse la taille de l'écran.
3. Référence : la propriété `tooltip_text` de [Control](https://docs.godotengine.org/en/stable/classes/class_control.html), pour afficher la description au survol.
4. Facultatif : [GraphEdit](https://docs.godotengine.org/en/stable/classes/class_graphedit.html) et [GraphNode](https://docs.godotengine.org/en/stable/classes/class_graphnode.html). Ce sont des nœuds tout faits pour les graphes reliés, mais pensés pour des éditeurs (nœuds déplaçables par l'utilisateur). Ils sont souvent plus compliqués qu'utiles pour un arbre de jeu.

### Instancier par code

- [Nodes and scene instances](https://docs.godotengine.org/en/stable/tutorials/scripting/nodes_and_scene_instances.html) : `preload()` et `instantiate()` servent à créer un bouton par compétence à partir d'une liste.

✅ **Checkpoint** : trois compétences affichées, reliées par des lignes, avec leur description au survol.

---

## Étape 5 : l'état du jeu partagé (argent, compétences débloquées)

L'arbre doit connaître l'argent de l'entreprise, et le plateau doit savoir quelles compétences sont débloquées. Le plus simple est un **Autoload** : un script global, accessible depuis n'importe quelle scène.

1. [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)
2. Revoir [Using signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html), partie *Custom signals* : par exemple, un signal `competence_debloquee` émis par l'Autoload, que le plateau écoute.
3. Plus tard : [Saving games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html).

✅ **Checkpoint** : cliquer sur une compétence la débloque (changement de couleur), débloquer une compétence exige que ses prérequis soient déjà débloqués, et le plateau en est informé.

---

## Étape 6 : finitions (facultatif)

- [GUI skinning](https://docs.godotengine.org/en/stable/tutorials/ui/gui_skinning.html) et [Using the theme editor](https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html) : donner un style commun à toute l'interface.
- Référence : [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html), pour animer l'ouverture de l'arbre (fondu, glissement).
- [Scene organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html) : bonnes pratiques pour découper un projet en scènes indépendantes. Utile pour travailler à plusieurs sans conflits Git sur les `.tscn`.

---

## Conseil pour le travail en équipe

Faites de l'arbre une **scène séparée** (`skill_tree.tscn` + son script). Dans `tile_map.tscn`, qui est partagée avec le reste de l'équipe, vous n'ajouterez alors que deux choses : le bouton et une instance de l'arbre. Cela limite fortement les conflits de fusion avec la personne qui travaille sur le plateau.
