# SpinToWin_JuniperJam
[The Very Serious Juniper Dev Game Jam](https://itch.io/jam/theveryseriousjuniperdevgamejam)
Theme: Spin to win

## Project Notes
Enemies spawn with the enemySpawnTimer (gets faster with time) (game.gd)
- currently we only have one enemy type (enemy_melee.gd)
- use _EnemyClass.gd for new enemies scripts (handles eg. health)

Player can use the Rotating obj to kill them.
- Player controls Rotating with fake inertia.
- The Godot DampedSpringJoint2D did not work for this, I programed a custom rope. (Rotating.gd)

There is a gameOver and pause screen.

## TODO
- sfx
- more ui?
- features?

## Ideas
sth circles the player/mouse
- and does damage
  - reward speed/circling/combos (rotation direction switches)
- click for speed
- clear enemies

Using mouse inertia? Like a rope to the player
- Sometimes rotate the camera with the player
