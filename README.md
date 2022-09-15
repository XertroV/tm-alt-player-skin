# Trackmania 2020 Female / Alternate Player Character Skin

This allows you to change all in-game skins (it changes it for all character models).
A restart is required when you change your skin.
(Unless you have only been in the menu -- the skin *might* load in when you load up a map.)

Currently the only choices of skins are male (dark) or female (light).
Support for other skins could be added in the future if there's any demand for that feature and someone makes some.

You don't need this plugin to change the skin, mind, it just makes it easy.

The manual process involves extracting the skin yourself and placing it in `Documents\Trackmania\Skins\Models\CharacterPilot\StadiumMale` and `Documents\Trackmania\Skins\Models\HelmetPilot\Stadium`.
That's how this plugin works: it adds a custom skin that overwrites `StadiumMale` which is the default.
To fix animations for the female model, use `Player.Anim.Gbx` from the `StadiumMale` skin.

The background clouds animation was set using [Menu BG Chooser](https://openplanet.dev/plugin/menu-bg-chooser) v1.1.0 which is being reviewed as of 12th Sept 2022.

The 3D menu scene was modified using hacky dev code that [you can find here if you really want](https://github.com/XertroV/tm-menu-bg-refls/tree/35f58a3ba5babd1ddde5d639553b9efe3fffcc09).

License: Public Domain

Authors: XertroV

Suggestions/feedback: @XertroV on Openplanet discord

Code/issues: [https://github.com/XertroV/tm-alt-driver](https://github.com/XertroV/tm-alt-driver)

GL HF

-----------

## Notes:

* `ChestVisor_{B,E,N,R}` takes precedence based on `HelmetPilot` (male versions work over female model when only replacing these files)
  * changes color of visor and color of chest TM logo
* `Body_{B,E,N,R}` also works based on `HelmetPilot`
  * changes color of suit
* `HelmetVisor_{R,B,N}` also based on `HelmetPilot`
  * changes an overlay color of the visor
* (`HelmetPilot`) Male mesh with female `Body_` files (light skin) has dark helmet
  * replacing `HelmetVisor_` in `StadiumMale` did not help
  * deleting `Helmet_` resulting in a normal-map-esq coloring
  * changing `player.mesh.gbx` back to female in `HelmetPilot` restored normality (note: no `Helmet_` files present)

for new skins, we need in `Models\HelmetPilot`:
  * name.zip (with the text file)
  * folder with:
    * HV, CV, Body from wherever and Helmet from `HelmetPilot\Stadium`
  * need zips in `Models\CharacterPilot` too, but not the folders apparently if they're already in `HelmetPilot`

female helmetvisor_b will change appearance of male helmetvisor

to replace default char:
- CharPilot\StadiumMale:
  - Body, ChestVisor
- HelmetPilot\Stadium:
  - Body, ChestVisor, Helmet, HelmetVisor, Anim, Mesh

For arbitrary char:
- CharPilot\Name.zip
- HelmetPilot\Name.zip
- HelmetPilot\Name:
  - B, CV, H, HV, A, M
- HelmetPilot\Name\Icon.tga appears to be required...
