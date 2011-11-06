An optimized Image batch class for Starling.

*Very very early alpha code and API coded while testing Starling. 
The API will definitely change completely.*

The correct way to add items is using .addItem()/.addItemRange() 
- do NOT add/remove items by manipulating the .items property.

The batch works as a "pool of items", and nothing will be rendered until you set the .drawCount 
property which tells how many items from the pool should be rendered.

Known issue:
- you're expected to swap items in the .items vector to remove them from rendering, however doing so will 
not swap the alpha/color transformations of the swapped items - maybe .items will be made private and 
exposed through methods.

Currently limited:
- one texture, no animation, no rotation
- alpha/color changes are not optimized yet

TODO:
- add a demo
- rotation
- spritesheet animations

