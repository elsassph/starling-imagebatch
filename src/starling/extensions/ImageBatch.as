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
	import flash.utils.Dictionary;
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

		private var _drawCount:int;
		private var _texture:Texture;
		private var _clonedItems:Vector.<BatchItem>;
		
		private var items:Vector.<BatchItem>;
		private var vertexData:VertexData;
		private var indices:Vector.<uint>;
		private var vertexBuffer:VertexBuffer3D;
		private var indexBuffer:IndexBuffer3D;
		private var premultipliedAlpha:Boolean;
		private var alphaVector:Vector.<Number>;
		private var baseVertexData:VertexData;
		private var defaultVertexData:VertexData;
		private var atlasVertexData:Dictionary = new Dictionary();
		
		public function ImageBatch(texture:Texture, blendFactorSource:String = null, blendFactorDest:String = null)
		{
			this.blendFactorDest = blendFactorDest;
			this.blendFactorSource = blendFactorSource;
			this.texture = texture;
			
			items = new Vector.<BatchItem>();
			vertexData = new VertexData(0, premultipliedAlpha);
			indices = new <uint>[];
		}
		
		public function addItem():BatchItem
		{
			var item:BatchItem;
			if (_drawCount < items.length) 
			{
				item = items[_drawCount];
				item.x = item.y = 0;
				item.color = 0xffffff;
				item.alpha = item.scale = 1;
			}
			else 
			{
				item = new BatchItem();
				items.fixed = false;
				indices.fixed = false;
				var vertexID:int = _drawCount << 2;
				var verticeID:int = _drawCount << 2;
				vertexData.append(defaultVertexData);
				indices.push(verticeID,     verticeID + 1, verticeID + 2, 
							 verticeID + 1, verticeID + 3, verticeID + 2);
				items.push(item);
				items.fixed = true;
				indices.fixed = true;
			}
			_drawCount++;
            if (vertexBuffer) { vertexBuffer.dispose(); vertexBuffer = null; }
            if (indexBuffer)  { indexBuffer.dispose(); indexBuffer = null; }
			return item;
		}
		
		public function removeItem(item:BatchItem):void
		{
			var index:int = items.indexOf(item);
			if (index < 0) return;
			_drawCount--;
			items[index] = items[_drawCount];
			items[index].dirty = 3;
			items[_drawCount] = item;
		}
		
		public function removeItemAt(index:int):void
		{
			if (_drawCount <= index) return;
			_drawCount--;
			var item:BatchItem = items[index];
			items[index] = items[_drawCount];
			items[index].dirty = 3;
			items[_drawCount] = item;
		}
        
        public override function dispose():void
        {
            if (vertexBuffer) { vertexBuffer.dispose(); vertexBuffer = null; }
            if (indexBuffer)  { indexBuffer.dispose(); indexBuffer = null; }
			_texture = null;
			defaultVertexData = null;
			items = null;
            
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
            if (_drawCount == 0) return;
			
            var item:BatchItem, vOffset:int, cOffset:int, uOffset:int, 
				x:Number, y:Number, s:Number, tw2:Number, th2:Number, 
				ca:Number, sa:Number, ox1:Number, ox2:Number, oy1:Number, oy2:Number;
			var data:Vector.<Number> = vertexData.data;
			var tex:Texture = texture, itex:Texture;
            var textureWidth:Number = tex.width, textureHeight:Number = tex.height;
			
			for (var i:int = 0; i < _drawCount; ++i)
            {
                item = items[i];
				
                vOffset = (i << 2) * 9;
                x = item.x;
                y = item.y;
                s = item.scale;
				
				itex = item.texture;
				if (itex && itex != tex)
				{
					tex = itex;
					textureWidth = tex.width;
					textureHeight = tex.height;
				}
                tw2 = textureWidth  * s >> 1;
                th2 = textureHeight * s >> 1;
				
				if (item.dirty)
				{
					if ((item.dirty & 2) > 0)
					{
						if (!(itex in atlasVertexData)) 
							atlasVertexData[itex] = itex.adjustVertexData(baseVertexData);
						var tdata:Vector.<Number> = atlasVertexData[itex].data;
						uOffset = vOffset + 7;
						data[uOffset] = tdata[7];
						data[uOffset + 1] = tdata[8];
						data[uOffset + 9] = tdata[7 + 9];
						data[uOffset + 10] = tdata[8 + 9];
						data[uOffset + 18] = tdata[7 + 18];
						data[uOffset + 19] = tdata[8 + 18];
						data[uOffset + 27] = tdata[7 + 27];
						data[uOffset + 28] = tdata[8 + 27];
					}
					
					// color/alpha
					cOffset = vOffset + 3;
					var k:Number = (premultipliedAlpha ? item.alpha : 1) / 255;
					data[cOffset] = data[cOffset + 9] = data[cOffset + 18] = data[cOffset + 27] = (item.color >> 16) * k;
					++cOffset;
					data[cOffset] = data[cOffset + 9] = data[cOffset + 18] = data[cOffset + 27] = ((item.color >> 8) & 0xff) * k;
					++cOffset;
					data[cOffset] = data[cOffset + 9] = data[cOffset + 18] = data[cOffset + 27] = (item.color & 0xff) * k;
					++cOffset;
					data[cOffset] = data[cOffset + 9] = data[cOffset + 18] = data[cOffset + 27] = item.alpha;
					++cOffset;
					item.dirty = 0;
				}
				
				if (item.angle)
				{
					ca = Math.cos(item.angle);
					sa = Math.sin(item.angle);
					ox1 = tw2 * ca + th2 * sa;
					ox2 = tw2 * ca - th2 * sa;
					oy1 = -tw2 * sa + th2 * ca;
					oy2 = tw2 * sa + th2 * ca;
					data[vOffset] 		= x - ox1;
					data[vOffset + 1] 	= y - oy1;
					data[vOffset + 9] 	= x + ox2;
					data[vOffset + 10] = y - oy2;
					data[vOffset + 18] = x - ox2;
					data[vOffset + 19] = y + oy2;
					data[vOffset + 27] = x + ox1;
					data[vOffset + 28] = y + oy1;
				}
				else 
				{
					data[vOffset] 		= x - tw2;
					data[vOffset + 1] 	= y - th2;
					data[vOffset + 9] 	= x + tw2;
					data[vOffset + 10] = y - th2;
					data[vOffset + 18] = x - tw2;
					data[vOffset + 19] = y + th2;
					data[vOffset + 27] = x + tw2;
					data[vOffset + 28] = y + th2;
				}
            }
			
            alpha *= this.alpha;
            var program:String = Image.getProgramName(texture.mipMapping);
            var context:Context3D = Starling.context;
            
            if (context == null) throw new MissingContextError();
            
			if (vertexBuffer == null)
			{
				vertexBuffer = context.createVertexBuffer(items.length * 4, VertexData.ELEMENTS_PER_VERTEX);
				indexBuffer = context.createIndexBuffer(items.length * 6);
			}
            vertexBuffer.uploadFromVector(vertexData.data, 0, items.length * 4);
            indexBuffer.uploadFromVector(indices, 0, items.length * 6);
            
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
            context.drawTriangles(indexBuffer, 0, _drawCount * 2);
            
            context.setTextureAt(1, null);
            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
            context.setVertexBufferAt(2, null);
        }
		
		/* PROPERTIES */
		
		/** 
		 * Direct access to the items vector:
		 * - ONLY FOR READING! don't add/remove items yourself
		 * - only the first <code>count</code> items are rendered
		 */
		public function getItems():Vector.<BatchItem>
		{
			return items;
		}
		
		/** Only the first <code>count</count> items are rendered */
		public function get count():int { return _drawCount; }
		
		/** Default texture */
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
            defaultVertexData = value.adjustVertexData(baseVertexData);
		}
	}

}