**An optimized Image batch class for Starling.**

*Very early alpha code and API*

Use the ImageBatch to render a large number of similar images. 

This class is designed as an object pool - addItem will increase its capacity if needed and removeItem will only
swap items and reduce the number of triangles to draw.

**Current limitations:**

 - one texture, no animation, no rotation


**TODO:**

 - rotation
 - spritesheet animations

