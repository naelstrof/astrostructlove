Bounties
--------
This text file is used to determine payout. Completing bounties adds to your overal percentage cut from the profits.

* Component based entity system (DONE Nael)
    + Renderer (DONE Nael)
    + Way to grab existing/surrounding/nearby/specific entities efficiently

* Demosystem (DONE Nael)
    + Recording (DONE Nael)
    + Playback (DONE Nael)

* Networking
    + Lobbying
        - Player names and avatars (DONE Nael)
        - Gamemode selection
        - Job preference selection
    + User command networking (like using a vending machine to get chips instead of chocolate would require the user to send some sort of command to the server)
    + Server time-travel
    + Client prediction
    + Server <-> Client connection (DONE Nael)
    + Server -> Client broadcast (DONE Nael)
    + Server <- Client broadcast (DONE Nael)
    + Server <-> Client timeout/disconnection
    + Client joining an already running game

* Lighting (DONE Nael)
    + Shadow stencils (DONE Nael)
    + Additive light overlay (DONE Nael)
    + Illumination masks (DONE Nael)

* Map Editor
    + Entity placement
    + Entity deletion
    + Wiring tools
    + Saving (DONE Nael)
    + Loading (DONE Nael)

* Adaptive Options
    + Dynamic creation of an options menu based on existing options
    + Saving (DONE Eric)
    + Loading (DONE Nael)

* Damage system
    + Damage types (fire, slash, blunt, pierce, chem, with additional parameters like depth, force, temp, or type of chem damage (lack of air, acid, poison, etc))
    + Damage bodies (Humans have limbs and organs made of flesh, robots have chips, wires, and servos made of steel, windows have dual paned glass)
    + Way to query for certain damage (controllable can check for broken legs, and adjust movespeed accordingly)
    + Break hook (When any part of a damage body "breaks", this hook is called. So like a vending machine can know when to break its window to release snacks for free, while simutaniously knowing if the contents of the vending machine is ok [burning a vending machine might call Break( "vendingcontents" ) which would destroy some of its contents])

* Electricity system
    + Wiring tools that "Link" devices together with visuals
    + Electric powered devices
    + Performance of machines should be determined by how much power they have. Too little power would cause flickering and poor/no performance, too much would cause flickering and instability

* Atmospherics
    + Gridbased "flow" atmospherics
    + "Blocksair" component that causes entities to solidify parts of the virtual grid on spawn
    + Air logic entity that fills the grid with normal air, then updates and keeps track of it.
    + Air logic entity can hold and move around airborne chemical entities, calling interact( e ) on damage bodies

* Chemicals
    + Chemical entities with combine( e ) and interact( e ) hooks (sodium nitrate and sugar can be combined into a smoke bomb, but only under low heat. High heat or sparks would cause the combination to combust.)
    + Chemical interactions with damage bodies. (sodium nitrate will not cause chem damage to bodies, but something like powdered nightshade could to flesh, but not to metal)

* Gamemodes
    + Downloadable package system (DONE Atlantique)
    + Gamemode hooks (Like spawnplayer( playerid, playerjob ), disconnectPlayer( playerid ), etc)
