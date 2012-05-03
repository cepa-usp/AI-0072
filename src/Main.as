package  
{
	import BaseAssets.BaseMain;
	import cepa.utils.Cronometer;
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain
	{
		//private const VIEWPORT:Rectangle = new Rectangle(0, 0, 550, 400);
		private const VIEWPORT:Rectangle = new Rectangle(0, 0, 700, 500);
		private const SCENE:Rectangle = new Rectangle(0, 600, 2000, 600);
		private const gravidade:Point = new Point(0, -9.8);
		
		private const DELTA_100:Number = 13;
		private const DELTA_MENOR_100:Number = 30;
		
		private var aviaoR0:Point;
		private var aviaoV0:Point;
		
		private var aviao:MovieClip;
		private var tAviao:Cronometer;
		
		private var bomba:MovieClip;
		private var tBomba:Cronometer;
		private var bombaLancada:Boolean;
		private var bombaR0:Point;
		private var bombaV0:Point;
		
		private var distanciaAlvo:Number;
		
		private var timeToTarget:Number;
		private var pontuacao:Number;
		
		private var score:DynamicAverage;
		private var bombaExplodiu:Boolean;
		private var tempoTween:Number;
		private var tweenBomba:Tween;
		
		private var timeFactory:Number = 1;
		private var timeElasped:Number;
		private var tBombaElasped:Number;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			scrollRect = VIEWPORT;
			
			initVariables();
			addListeners();
		}
		
		private function initVariables():void
		{
			aviao = new Aviao();
			addChild(aviao);
			
			//aviaoR0 = new Point(pixel2meter(new Point(0 - 55, 0)).x , Math.random() * 270 + 300);
			aviaoR0 = new Point(pixel2meter(new Point(0 - 55, 0)).x , pixel2meter(new Point(0, Math.random() * 265 + 35)).y);
			//aviaoR0 = new Point(pixel2meter(new Point(0 - 55, 0)).x , pixel2meter(new Point(0, 300)).y);
			//aviaoV0 = new Point(150, 0);
			aviaoV0 = new Point(Math.random() * 50 + 100, 0);
			
			var posInicialAviao:Point = meter2pixel(aviaoR0);
			aviao.x = posInicialAviao.x;
			aviao.y = posInicialAviao.y;
			indETO.y = posInicialAviao.y;
			ETO.y = indETO.y + 25;
			
			tAviao = new Cronometer();
			tAviao.start();
			timeElasped = 0;
			tBombaElasped = 0;
			
			bomba = new Bomba();
			bomba.x = -50;
			addChild(bomba);
			tBomba = new Cronometer();
			
			bombaLancada = false;
			bombaExplodiu = false;
			
			var hAviao:Number = pixel2meter(new Point(aviao.x, aviao.y)).y;
			//altura.text = hAviao.toFixed(1).replace(".",",") + " m";
			altura.text = hAviao.toFixed(0) + " m";
			
			flechaAltura.height = (VIEWPORT.height - aviao.y) - (VIEWPORT.height - flechaAltura.y);
			altura.y = flechaAltura.y - flechaAltura.height / 2 - altura.height / 2;
			
			distanciaAlvo = pixel2meter(new Point(alvo.x, alvo.y)).x + Math.abs(aviaoR0.x);
			timeToTarget = distanciaAlvo / aviaoV0.x;
			
			tempoTween = Math.sqrt(2 * Number(altura.text.replace(" m", "").replace(",", ".")) / 9.8);
			
			score = new DynamicAverage();
			mediaPontos.text = "Média: 0%";
			
			setChildIndex(botoes, numChildren - 1);
			setChildIndex(bordaAtividade, numChildren - 1);
		}
		
		private function changePlaneParameters():void
		{
			if (bombaLancada)
			{
				//aviaoR0 = new Point(pixel2meter(new Point(0 - 55, 0)).x , Math.random() * 270 + 300);
				aviaoR0 = new Point(pixel2meter(new Point(0 - 55, 0)).x , pixel2meter(new Point(0, Math.random() * 265 + 35)).y);
				//aviaoV0 = new Point(150, 0);
				aviaoV0 = new Point(Math.random() * 50 + 100, 0);
				
				var posInicialAviao:Point = meter2pixel(aviaoR0);
				aviao.y = posInicialAviao.y;
				indETO.y = posInicialAviao.y;
				ETO.y = indETO.y + 25;
				
				var hAviao:Number = pixel2meter(new Point(posInicialAviao.x, posInicialAviao.y)).y;
				//altura.text = hAviao.toFixed(1).replace(".",",") + " m";
				altura.text = hAviao.toFixed(0) + " m";
				
				flechaAltura.height = (VIEWPORT.height - posInicialAviao.y) - (VIEWPORT.height - flechaAltura.y);
				altura.y = flechaAltura.y - flechaAltura.height / 2 - altura.height / 2;
				
				distanciaAlvo = pixel2meter(new Point(alvo.x, alvo.y)).x + Math.abs(aviaoR0.x);
				timeToTarget = distanciaAlvo / aviaoV0.x;
				
				tempoTween = Math.sqrt(2 * Number(altura.text.replace(" m","").replace(",",".")) / 9.8);
				
				tAviao.reset();
				timeElasped = 0;
				
				if (tBomba.isRunning())
				{
					tBomba.stop();
					tBomba.reset();
					calculaPontuacao(0);
					bomba.y = -100;
				}
				bombaLancada = false;
				bombaExplodiu = false;
				
				launchButton.alpha = 1;
				launchButton.mouseEnabled = true;
				
			}
			else
			{
				//if (bombaLancada)
				//{
					//tBomba.stop();
					//tBomba.reset();
					//bombaLancada = false;
					//calculaPontuacao(0);
				//}
				tAviao.reset();
				timeElasped = 0;
			}
			
			
		}
		
		private function addListeners():void
		{
			stage.addEventListener(Event.ENTER_FRAME, update);
			launchButton.addEventListener(MouseEvent.CLICK, launchBomb);
			launchButton.addEventListener(MouseEvent.MOUSE_OVER, eagleTimeOn);
			launchButton.addEventListener(MouseEvent.MOUSE_OUT, eagleTimeOff);
		}
		
		private function eagleTimeOn(e:MouseEvent):void 
		{
			timeFactory = 0.2;
		}
		
		private function eagleTimeOff(e:MouseEvent):void 
		{
			timeFactory = 1;
		}
		
		private function launchBomb(e:MouseEvent):void 
		{
			if (!bombaLancada && Number(ETO.text.replace(",",".").replace("s","")) > 0 && !bombaExplodiu)
			{
				bombaR0 = pixel2meter(new Point(aviao.x, aviao.y));
				bombaV0 = aviaoV0;
				bomba.rotation = -90;
				tBombaElasped = 0;
				bomba.gotoAndStop("INICIO");
				
				tBomba.start();
				bombaLancada = true;
				//tweenBomba = new Tween(bomba, "rotation", None.easeNone, -90, 0, tempoTween, true);
				
				launchButton.alpha = 0.5;
				launchButton.mouseEnabled = false;
			}
		}
		
		private function getBombRotation(time:Number):Number
		{
			var rot:Number = (time / tempoTween * (90)) - 90;
			
			return rot;
		}
		
		/*
		 * Atualiza a posição do aviao.
		 */
		private function update (event:Event) : void
		{
			var position:Point;
			//var t:Number;
			
			timeElasped += (tAviao.read() / 1000) * timeFactory;
			tAviao.reset();
			
			// Atualiza a posição do avião
			//t = tAviao.read() / 1000;
			
			//position = meter2pixel(r(aviaoR0, aviaoV0, gravidade, t));
			position = meter2pixel(r(aviaoR0, aviaoV0, gravidade, timeElasped));
			aviao.x = position.x;
			
			if (aviao.x > VIEWPORT.width + aviao.width / 2) 
			{
				//bombaExplodiu = true;
				changePlaneParameters();
			}
			
			//Atauliza ETO
			//var tempoETO:Number = timeToTarget - t + 0.22;
			var tempoETO:Number = timeToTarget - timeElasped + 0.22;
			if (tempoETO <= 0) ETO.text = "0 s";
			else ETO.text = tempoETO.toFixed(1).replace(".",",") + " s";
			
			//if (Math.abs(tempoETO - Number(tempoCerto.text.replace(",","."))) < 0.02 ) launchBomb(null);
			
			// Atualiza a posição da bomba
			if (bombaLancada && !bombaExplodiu)
			{
				tBombaElasped += (tBomba.read() / 1000) * timeFactory;
				tBomba.reset();
				//t = tBomba.read() / 1000;
				
				//position = meter2pixel(r(bombaR0, bombaV0, gravidade, t));
				position = meter2pixel(r(bombaR0, bombaV0, gravidade, tBombaElasped));
				
				if (position.y >= alvo.y)
				{
					var xFinalBomba:Number = ((position.x - bomba.x) / (position.y - bomba.y)) * (alvo.y - bomba.y) + bomba.x;
					
					bomba.x = xFinalBomba;
					bomba.y = alvo.y;
					
					var pontos:Number = calculaPontuacao(xFinalBomba);
					
					//bombaLancada = false;
					bombaExplodiu = true;
					tBomba.stop();
					tBomba.reset();
					
					//bomba.play();
					bomba.gotoAndPlay(2);
					bomba.pontuacao.text = String(Math.round(pontos)) + "%";
				}
				else
				{
					bomba.x = position.x;
					bomba.y = position.y;
					//bomba.rotation = getBombRotation(tBomba.read() / 1000);
					bomba.rotation = getBombRotation(tBombaElasped);
				}
			}
		}
		
		private function calculaPontuacao(posicaoX:Number):Number
		{
			var pontuacaoAux = 100 - (100 / DELTA_MENOR_100) * (Math.abs(posicaoX - alvo.x) - DELTA_100);
			
			if (pontuacaoAux > 100) pontuacaoAux = 100;
			else if (pontuacaoAux < 0) pontuacaoAux = 0;
			
			score.push(pontuacaoAux);
			
			pontuacao = Math.round(score.mean);
			
			mediaPontos.text = "Média: " + String(pontuacao) + "%";
			
			return pontuacaoAux;
			
		}
		
		/*
		 * Retorna a posição r no instante t, para r0 (posição inicial), v0 (velocidade inicial) e a (aceleração constante).
		 */
		private function r (r0:Point, v0:Point, a:Point, t:Number) : Point
		{
			return new Point(
				r0.x + v0.x * t + a.x * t * t / 2,
				r0.y + v0.y * t + a.y * t * t / 2
			);
		}
		
		/*
		 * Mapeia posições na cena (em metros) para o viewport (em pixels).
		 */
		private function meter2pixel (r:Point) : Point
		{
			return Main.map(r, SCENE, VIEWPORT);
		}
		
		/*
		 * Mapeia posições no viewport (em pixels) para a cena (em metros).
		 */
		private function pixel2meter (r:Point) : Point
		{
			return Main.map(r, VIEWPORT, SCENE);
		}
		
		/**
		 * Mapeia um <code>Point r</code> no <code>Rectangle from</code> para um ponto no <code>Rectangle to</code>.
		 * @param	r O ponto a ser mapeado (em coordenadas de <code>from</code>)
		 * @param	from O retângulo de origem
		 * @param	to O retângulo de destino
		 * @return  O ponto mapeado (em coordenadas de <code>to</code>)
		 */
		public static function map (r:Point, from:Rectangle, to:Rectangle) : Point
		{
			return new Point(
				to.left + to.width / from.width * (r.x - from.left),
				to.top - to.height / from.height * (r.y - from.top)
			);
		}
		
	}

}