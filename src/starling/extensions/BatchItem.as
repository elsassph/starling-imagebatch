package starling.extensions 
{
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
		public var tag:*;
		
		internal var dirty:Boolean;
		internal var _color:Number;
		private var _alpha:Number;
		
		public function BatchItem() 
		{
			x = y = 0;
			scale = _alpha = 1;
			_color = 0xffffff;
			dirty = true;
		}
		
		public function get alpha():Number { return _alpha; }
		
		public function set alpha(value:Number):void 
		{
			if (_alpha != value) 
			{
				_alpha = value;
				dirty = true;
			}
		}
		
		public function get color():Number { return _color; }
		
		public function set color(value:Number):void 
		{
			if (_color != value)
			{
				_color = value;
				dirty = true;
			}
		}
		
	}

}