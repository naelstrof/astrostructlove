astrostructlove
===============

A SS13 clone designed on the Love2D framework with proper networking and expanded engine features.


Projected Features
------------------

* Flexible component based entity system (DONE)
* Off-the-grid objects (DONE)
* Advanced 2D lighting (DONE)
* Demoing system (à la source demos) (DONE)
* Various gamemodes (DONE)
* Box2D physics (PROTOTYPED)
* Map editor (PROTOTYPED)
* Accurate networking (à la source multiplayer) with prediction and timetravel (PROTOTYPED)
* Simple controls that allow for creatures with infinite limbs. Monkeys can hold and use four weapons at once. (PROTOTYPE)
* Grid-based air simulation with air constitution/consumption/conversion.
* Dwarf-fortress style health system with dismemberment, organs, and blood content/constitution.
* Volume and weight (gravity matters!) styled inventory system with various wearable bags.

How To Run
----------
Due to how love.filesystem.mount() works, you'll have to copy the Downloads folder into your corresponding love.filesystem.getSaveDirectory() folder (In my case it's ~/.local/share/love/lovegame/).
This is in order to mount the gamemode package, soon I might make it auto-copy or something.
From there you'll need [Love2D](http://love2d.org/) installed, where you can run the game by dragging and dropping the game folder onto the executable to run it.
