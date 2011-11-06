package  
{
	import flash.display.Sprite;
	import net.hires.debug.Stats;
	import starling.core.Starling;
	
	/**
	 * ImageBatch demo
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class Demo extends Sprite 
	{
		private var ctx:Starling;
		
		public function Demo() 
		{
			ctx = new Starling(Stars, stage);
			ctx.start();
			
			addChild(new Stats());
		}
		
	}

}