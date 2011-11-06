package  
{
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.extensions.BatchItem;
	import starling.extensions.ImageBatch;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	/**
	 * Animate plenty of stars
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class Stars extends ImageBatch 
	{
		[Embed(source = "stars.png")]
		private const starTexture:Class;
		[Embed(source = "stars.xml", mimeType = "application/octet-stream")]
		private const starAtlas:Class;
		
		private var steps:int = 60;
		private var anim:Vector.<Number>;
		private var atlas:TextureAtlas;
		
		public function Stars() 
		{
			super(Texture.fromBitmap(new starTexture()));
			
			var xml:XML = XML(new starAtlas());
			atlas = new TextureAtlas(texture, xml);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			anim = new Vector.<Number>();
			for (var j:int = 0; j < steps; j++) 
				anim.push(0.5 + 0.5 * Math.cos((j / steps) * Math.PI * 2));
			
			var n:int = 8000;
			var t1:Texture = atlas.getTexture("star1");
			var t2:Texture = atlas.getTexture("star2");
			
			for (var i:int = 0; i < n; i++) 
			{
				var item:BatchItem = addItem();
				item.x = Math.random() * stage.stageWidth;
				item.y = -10 + Math.random() * (stage.stageHeight + 20);
				item.scale = 0.2 + Math.random() * 0.2;
				item.angle = Math.random() * Math.PI * 2;
				item.color = Math.random() * 0xffffff >> 0;
				item.texture = i & 1 ? t1 : t2; // use custom texture from atlas
				item.tag = Math.random() * steps >> 0; // store any data in item.tag
			}
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:EnterFrameEvent):void 
		{
			var sh:int = stage.stageHeight + 10;
			var item:BatchItem;
			
			var items:Vector.<BatchItem> = getItems(); // items pool
			var n:int = count; // active items count
			
			for (var i:int = 0; i < n; i++) 
			{
				item = items[i];
				item.y += item.scale * 2;
				item.tag = (item.tag + 1) % steps;
				item.alpha = anim[item.tag];
				item.angle += item.scale / 5;
				if (item.y > sh) item.y = -10;
			}
		}
		
	}

}