# CSC258_Project

## `finalproject.v`
Top level Verilog file. Contains code that brings together all modules.

## `multi_input.v`
Contains logic for getting keycodes from the PS2 Keyboard.

## `sprite.v`
Handles drawing sprites to a VGA framebuffer given the Sprite ID and location.

## `system.v`
Handles all Game Level Loading/Completion, and Player movement logic. 

## Sprite Table

![alt text](https://github.com/yoonsikp/CSC258_Project/raw/master/sprites2.png "Logo Title Text 1")

Numbered 0 - 12

* 0: Wall
* 1: Crate
* 2: Player
* 3: Floor
* 4: Goal
* 5: Crate on top of Goal (glowing crate)
* 6: "LEV"
* 7: "EL"
* 8: "1-"
* 9: "2-"
* 10: "3-"
* 11: "4-"
* 12: Dark Grey
