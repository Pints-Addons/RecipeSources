Pints Recipe Sources v3.1 - every recipe you haven't learned, where to get it, and what it costs
(WoW Classic Era / Hardcore / Forever)

REQUIRES
  Nothing. All data is built in. Optional: TomTom (click a recipe to set a waypoint).

INSTALL
  Unzip so the folder sits at:  World of Warcraft\_classic_era_\Interface\AddOns\RecipeSources
  Restart the game.

HOW TO USE
  Open any profession window and click the "Learnable" button at its bottom-right.
  - Status filters: All unlearned / Learnable now / Learned
  - Source filters: All / Trainer / Vendor / Drop / Quest-Other
  - "Other faction" box (top of the list): also shows recipes sold by the other faction's vendors
    or given by their quests, tagged [Horde] or [Alliance]. They're items, so a friend on the other
    side or the neutral auction house can get them to you. Other-faction trainers stay hidden.
  - Grouped by skill level. Red = your skill is too low yet. Once any character on your account
    knows a recipe, its real orange / yellow / green / grey skill-up colors fill in as you level.
  - Sources: every trainer that teaches it (nearest continent first), vendors with zone and
    coordinates (limited-supply flagged), mob drops with drop chance and zone, world drops with
    mob level range and suggested zones, quest rewards and containers.
  - Training cost and vendor price - white if you can afford it, red if you can't - plus a
    "Train all learnable now" total. Prices you see at trainers and vendors replace the built-in ones.
  Hover a recipe for full details; click it to set a TomTom waypoint (if installed).

COMMANDS
  /rsrc tab <x> <y>    move the Learnable button
  /rsrc panel <x> <y>  move the list
  /rsrc rescan         rebuild the recipe list

CHANGES
  3.1  "Other faction" option for completionists (thanks SawyerMBlack for the idea).

LICENSE
  GPL-3.0 (see LICENSE.txt). Recipe, source, name and price data is generated from the
  CMaNGOS Classic world database (https://github.com/cmangos/classic-db, GPL).

FEEDBACK
  Report a bug or suggest an idea: https://github.com/Pints-Addons/RecipeSources/issues
  Source code: https://github.com/Pints-Addons/RecipeSources
