package starling.extensions 
{
	import starling.textures.Texture;
	/**
	 * Animated elements in the batch must be provided using a BatchItem (or subclass).
	 *
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class BatchItem 
	{
		public var x:Number;
		public var y:Number;
		public var scale:Number;
		public var angle:Number;
		public var tag:*;
		
		internal var dirty:int;
		internal var _color:Number;
		private var _alpha:Number;
		private var _texture:Texture;
		
		public function BatchItem() 
		{
			x = y = angle = 0;
			scale = _alpha = 1;
			_color = 0xffffff;
			dirty |= 1;
		}
		
		public function get alpha():Number { return _alpha; }
		
		public function set alpha(value:Number):void 
		{
			if (_alpha != value) 
			{
				_alpha = value;
				dirty |= 1;
			}
		}
		
		public function get color():Number { return _color; }
		
		public function set color(value:Number):void 
		{
			if (_color != value)
			{
				_color = value;
				dirty |= 1;
			}
		}
		
		public function get texture():Texture { return _texture; }
		
		public function set texture(value:Texture):void 
		{
			_texture = value;
			dirty |= 2;
		}
		
	}

}