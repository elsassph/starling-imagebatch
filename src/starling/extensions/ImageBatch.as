package starling.extensions 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.errors.MissingContextError;
	import starling.textures.Texture;
	import starling.utils.VertexData;
	
	/**
	 * Animate a lot of elements as one batched call to the GPU.
	 *
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class ImageBatch extends DisplayObject 
	{
		public var blendFactorSource:String;
		public var blendFactorDest:String;

		private var _count:int;
		private var _drawCount:int;
		private var _texture:Texture;
		private var _items:Vector.<BatchItem>;

		private var vertexData:VertexData;
		private var indices:Vector.<uint>;
		private var vertexBuffer:VertexBuffer3D;
		private var indexBuffer:IndexBuffer3D;
		private var premultipliedAlpha:Boolean;
		private var baseVertexData:VertexData;
		private var alphaVector:Vector.<Number>;
		
		public function ImageBatch(texture:Texture, blendFactorSource:String = null, blendFactorDest:String = null)
		{
			this.blendFactorDest = blendFactorDest;
			this.blendFactorSource = blendFactorSource;
			this.texture = texture;
			
			_items = new Vector.<BatchItem>();
			vertexData = new VertexData(0, premultipliedAlpha);
			indices = new <uint>[];
		}
		
		public function addItem(item:BatchItem):void
		{
			var v:Vector.<BatchItem> = new <BatchItem>[item];
			addRange(v);
		}
		
		public function addRange(newItems:Vector.<BatchItem>):void
		{
            var context:Context3D = Starling.context;
            if (context == null) throw new MissingContextError();
			
			_items.fixed = false;
			indices.fixed = false;
			
			for (var i:int = 0; i < newItems.length; i++) 
			{
				var vertexID:int = (count + i) << 2;
				var numVertices:int = (count + i) << 2;
				
				var item:BatchItem = newItems[i];
				_items.push(item);
				
				vertexData.append(baseVertexData);
				for (var j:int = 0; j < 4; ++j)
                    vertexData.setColor(vertexID + j, item.color, item.alpha);
				
                indices.push(numVertices,     numVertices + 1, numVertices + 2, 
                             numVertices + 1, numVertices + 3, numVertices + 2);
			}
			
			_items.fixed = true;
			indices.fixed = true;
			_count = items.length;
			
			vertexBuffer = context.createVertexBuffer(count * 4, VertexData.ELEMENTS_PER_VERTEX);
			indexBuffer = context.createIndexBuffer(count * 6);
		}
        
        public override function dispose():void
        {
            if (vertexBuffer) vertexBuffer.dispose();
            if (indexBuffer)  indexBuffer.dispose();
			_texture = null;
			baseVertexData = null;
			_items = null;
            
            super.dispose();
        }
		
		public override function getBounds(targetSpace:DisplayObject):Rectangle
        {
            var matrix:Matrix = getTransformationMatrix(targetSpace);
            var position:Point = matrix.transformPoint(new Point(x, y));
            return new Rectangle(position.x, position.y);
        }
		
		public override function render(support:RenderSupport, alpha:Number):void
        {
            if (count == 0) return;
			
            var item:BatchItem;
			var vertexID:int, x:Number, y:Number, s:Number, xOffset:Number, yOffset:Number;
            var textureWidth:Number = texture.width;
            var textureHeight:Number = texture.height;
			
			var data:Vector.<Number> = vertexData.data;
			
			function setValues(offset:int, x:Number, y:Number):void 
			{
				data[offset] = x;
				data[offset + 1] = y;
			}
			
			var sh:int = stage.stageHeight;
			for (var i:int = 0; i < _drawCount; ++i)
            {
                item = items[i];
				
                vertexID = i << 2;
                x = item.x;
                y = item.y;
                s = item.scale;
                xOffset = textureWidth  * s >> 1;
                yOffset = textureHeight * s >> 1;
                
				if (item.dirty)
				{
					for (var j:int = 0; j < 4; ++j)
						vertexData.setColor(vertexID + j, item.color, item.alpha);
					item.dirty = false;
				}
				
				vertexID *= 9;
				data[vertexID] 		= x - xOffset;
				data[vertexID + 1] 	= y - yOffset;
				data[vertexID + 9] 	= x + xOffset;
				data[vertexID + 10] = y - yOffset;
				data[vertexID + 18] = x - xOffset;
				data[vertexID + 19] = y + yOffset;
				data[vertexID + 27] = x + xOffset;
				data[vertexID + 28] = y + yOffset;
            }
			
            alpha *= this.alpha;
            var program:String = Image.getProgramName(texture.mipMapping);
            var context:Context3D = Starling.context;
            
            if (context == null) throw new MissingContextError();
            
            vertexBuffer.uploadFromVector(vertexData.data, 0, count * 4);
            indexBuffer.uploadFromVector(indices, 0, count * 6);
            
			var blendDest:String = blendFactorDest || Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            var blendSource:String = blendFactorSource ||
                (premultipliedAlpha ? Context3DBlendFactor.ONE : Context3DBlendFactor.SOURCE_ALPHA);
            context.setBlendFactors(blendSource, blendDest);
            
            context.setProgram(Starling.current.getProgram(program));
            context.setTextureAt(1, texture.base);
            context.setVertexBufferAt(0, vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_3); 
            context.setVertexBufferAt(1, vertexBuffer, VertexData.COLOR_OFFSET,    Context3DVertexBufferFormat.FLOAT_4);
            context.setVertexBufferAt(2, vertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix, true);            
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, alphaVector, 1);
            context.drawTriangles(indexBuffer, 0, drawCount * 2);
            
            context.setTextureAt(1, null);
            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
            context.setVertexBufferAt(2, null);
        }
		
		/* PROPERTIES */
		
		public function get texture():Texture { return _texture; }
		
		public function set texture(value:Texture):void 
		{
			_texture = value;
			if (!value) return;
			
			premultipliedAlpha = value.premultipliedAlpha;
			alphaVector = premultipliedAlpha 
					? new <Number>[alpha, alpha, alpha, alpha] 
					: new <Number>[1.0, 1.0, 1.0, alpha];
			
			baseVertexData = new VertexData(4);
            baseVertexData.setTexCoords(0, 0.0, 0.0);
            baseVertexData.setTexCoords(1, 1.0, 0.0);
            baseVertexData.setTexCoords(2, 0.0, 1.0);
            baseVertexData.setTexCoords(3, 1.0, 1.0);
            baseVertexData = value.adjustVertexData(baseVertexData);
		}

		public function get items():Vector.<BatchItem> { return _items; }
		
		/** Total items in the pool */
		public function get count():int { return _count; }
		
		/** Total items to render */
		public function get drawCount():int { return _drawCount; }
		
		public function set drawCount(value:int):void 
		{
			_drawCount = value;
		}
		
	}

}