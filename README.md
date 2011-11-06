**An optimized Image batch class for Starling.**

*Very early alpha code and API*

The batch is intended to work as a "pool of items", and nothing will be rendered until you set the .drawCount 
property which tells how many items from the pool should be rendered.

**Current limitations:**

 - one texture, no animation, no rotation

**Known issues:**

 - you're expected to swap items in the .items vector to remove them from rendering, however doing so will 
not swap the alpha/colorv transformations of the swapped items - maybe .items will be made private and 
exposed through methods.

**TODO:**

 - rotation
 - spritesheet animations

