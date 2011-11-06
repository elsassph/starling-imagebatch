**An optimized Image batch class for Starling.**

*Very early alpha code and API*

The ImageBatch can efficiently (in terms of CPU and memory) render a large number of images sharing the same texture.

This class is designed as an object pool - items are recycled and vectors are never modified.

**Features:**

 - low memory footprint, items pooling
 - animate: x,y,scale,alpha,color,rotation

**TODO:**

 - spritesheet support


**Credits:**

This class is inspired by Starling's [Particle System extension][1] but with geometry building inlined.

[1]: https://github.com/PrimaryFeather/Starling-Extension-Particle-System

