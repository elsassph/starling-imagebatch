package  
{
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.extensions.BatchItem;
	import starling.extensions.ImageBatch;
	import starling.textures.Texture;
	
	/**
	 * Animate plenty of stars
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class Stars extends ImageBatch 
	{
		[Embed(source = "star.png")]
		private const starTexture:Class;
		
		private var steps:int = 60;
		private var anim:Vector.<Number>;
		
		public function Stars() 
		{
			super(Texture.fromBitmap(new starTexture()));
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			anim = new Vector.<Number>();
			for (var j:int = 0; j < steps; j++) 
				anim.push(0.5 + 0.5 * Math.cos((j / steps) * Math.PI * 2));
			
			var count:int = 10000;
			for (var i:int = 0; i < count; i++) 
			{
				var item:BatchItem = addItem();
				item.x = Math.random() * stage.stageWidth;
				item.y = -10 + Math.random() * (stage.stageHeight + 20);
				item.scale = 0.2 + Math.random() * 0.2;
				item.angle = Math.random() * Math.PI * 2;
				item.color = Math.random() * 0xffffff >> 0;
				item.tag = Math.random() * steps >> 0;
			}
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:EnterFrameEvent):void 
		{
			var sh:int = stage.stageHeight + 10;
			for each(var item:BatchItem in getItems())
			{
				item.y += item.scale * 2;
				item.tag = (item.tag + 1) % steps;
				item.alpha = anim[item.tag];
				item.angle += item.scale / 5;
				if (item.y > sh) item.y = -10;
			}
		}
		
	}

}