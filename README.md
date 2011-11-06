**An optimized Image batch class for Starling.**

*Warning: alpha code and API*

The ImageBatch can efficiently (in terms of CPU and memory) render a large number of images sharing the same texture. 
This class is designed as an object pool: items are recycled and vectors are never modified.

[Try the demo][1]: 8k particles with position/alpha/rotation animation and different textures from a shared spritesheet.

If you're unimpressed, that's ok - just notice that Starling rendering model adds an important overhead compared 
to heavily optimized demos or pure GPU particles (like ND2D offers). But here you can animate each element 
independently, and this is a big difference compared to animating a few high-polys models.

**Features:**

 - low memory footprint, items pooling
 - animate: x, y, scale, alpha, color, rotation, texture
 - (shared) spritesheet support
 - store custom data in items' "tag" property

**Credits:**

This class is inspired by Starling's [Particle System extension][1] but with geometry building inlined.

[1]: http://philippe.elsass.me/lab/StarlingImageBatch
[2]: https://github.com/PrimaryFeather/Starling-Extension-Particle-System

