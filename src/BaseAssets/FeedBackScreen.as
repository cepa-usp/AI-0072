package BaseAssets
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class FeedBackScreen extends MovieClip
	{
		public var okCancelMode:Boolean = false;
		
		public function FeedBackScreen() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.x = stage.stageWidth / 2;
			this.y = stage.stageHeight / 2;
			
			//this.closeButton.addEventListener(MouseEvent.CLICK, closeScreen);
			//stage.addEventListener(KeyboardEvent.KEY_UP, escCloseScreen);
			
			this.gotoAndStop("END");
		}
		
		private function escCloseScreen(e:KeyboardEvent):void 
		{
			if (e.keyCode ==  Keyboard.ESCAPE) {
				if (this.currentFrame == 1) closeScreen(null);
			}
		}
		
		private function closeScreen(e:MouseEvent):void 
		{
			this.play();
			dispatchEvent(new Event(Event.CLOSE, true));
		}
		
		private function closeScreenOK(e:MouseEvent):void 
		{
			this.play();
			dispatchEvent(new Event("OK", true));
		}
		
		private var stats:Object = new Object();
		public function updateStatics(stats:Object):void
		{
			this.stats.nTotal = stats.nTotal;
			this.stats.nValendo = stats.nValendo;
			this.stats.nNaoValendo = stats.nNaoValendo;
			this.stats.scoreMin = stats.scoreMin;
			this.stats.scoreTotal = stats.scoreTotal;
			this.stats.scoreValendo = stats.scoreValendo;
			this.stats.valendo = stats.valendo;
			
			if (this.currentFrame == 1) {
				estatisticas.nTotal.text = stats.nTotal;
				estatisticas.nValendo.text = stats.nValendo;
				estatisticas.nNaoValendo.text = stats.nNaoValendo;
				estatisticas.scoreMin.text = stats.scoreMin;
				estatisticas.scoreTotal.text = stats.scoreTotal;
				estatisticas.scoreValendo.text = stats.scoreValendo;
				
				if (stats.valendo) estatisticas.valendoMC.gotoAndStop("VALENDO");
				else estatisticas.valendoMC.gotoAndStop("NAO_VALENDO");
			}
		}
		
		public function openScreen():void
		{
			this.gotoAndStop("BEGIN");
			
			if (okCancelMode) {
				estatisticas.visible = false;
				this.texto.visible = true;
				
				closeButton.x = 0;
				cancelButton.x = 195;
				cancelButton.visible = true;
				closeButton.visible = true;
				
				cancelButton.addEventListener(MouseEvent.CLICK, closeScreen, false, 0, true);
				closeButton.addEventListener(MouseEvent.CLICK, closeScreenOK, false, 0, true);
			}else {
				this.texto.visible = false;
				estatisticas.visible = true;
				
				estatisticas.nTotal.text = stats.nTotal;
				estatisticas.nValendo.text = stats.nValendo;
				estatisticas.nNaoValendo.text = stats.nNaoValendo;
				estatisticas.scoreMin.text = stats.scoreMin;
				estatisticas.scoreTotal.text = stats.scoreTotal;
				estatisticas.scoreValendo.text = stats.scoreValendo;
				
				if (stats.valendo) estatisticas.valendoMC.gotoAndStop("VALENDO");
				else estatisticas.valendoMC.gotoAndStop("NAO_VALENDO");
				
				closeButton.x = 195;
				cancelButton.visible = false;
				closeButton.visible = true;
				closeButton.addEventListener(MouseEvent.CLICK, closeScreen, false, 0, true);
			}
		}
		
		public function setText(texto:String):void
		{
			openScreen();
			this.texto.text = texto;
		}
		
	}

}