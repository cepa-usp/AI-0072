package  
{
	import BaseAssets.BaseMain;
	import cepa.utils.Cronometer;
	import com.adobe.serialization.json.JSON;
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	import pipwerks.SCORM;
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
		
		private const DELTA_100:Number = 5;
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
		
		private var scoreTotal:DynamicAverage2;
		private var scoreValendo:DynamicAverage2;
		private var bombaExplodiu:Boolean;
		private var tempoTween:Number;
		private var tweenBomba:Tween;
		
		private var timeFactory:Number = 1;
		private var timeElasped:Number;
		private var tBombaElasped:Number;
		
		private var scoreMin:Number = 50;
		private var valendoNota:Boolean = false;
		
		private var sound:SoundChannel = new SoundChannel();
		private var soundAviao:SoundChannel = new SoundChannel();
		private var soundExplosao:SoundChannel = new SoundChannel();
		private var bombaCaindo:BombaCaindo = new BombaCaindo();
		private var explosao:Explosao = new Explosao();
		private var aviaoVoando:AviaoVoando = new AviaoVoando();
		
		private var soundTransformMute:SoundTransform = new SoundTransform(0);
		private var soundTransformNormal:SoundTransform = new SoundTransform(1);
		private var soundTransform2:SoundTransform = new SoundTransform(0.05);
		
		private var currentSoundTransform:SoundTransform;
		private var currentSoundTransform2:SoundTransform;
		
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
			
			if (ExternalInterface.available) {
				initLMSConnection();
				recoverStatus();
				if (!completed) iniciaTutorial();
			}else{
				iniciaTutorial();
			}
		}
		
		private function initVariables():void
		{
			bomba = new Bomba();
			bomba.x = -50;
			addChild(bomba);
			
			aviao = new Aviao();
			addChild(aviao);
			soundAviao = aviaoVoando.play();
			
			//aviaoR0 = new Point(pixel2meter(new Point(0 - 55, 0)).x , Math.random() * 270 + 300);
			aviaoR0 = new Point(pixel2meter(new Point(0 - 55, 0)).x , pixel2meter(new Point(0, Math.random() * 265 + 35)).y);
			//aviaoR0 = new Point(pixel2meter(new Point(0 - 55, 0)).x , pixel2meter(new Point(0, 300)).y);
			//aviaoV0 = new Point(150, 0);
			aviaoV0 = new Point(Math.random() * 50 + 100, 0);
			
			var posInicialAviao:Point = meter2pixel(aviaoR0);
			aviao.x = posInicialAviao.x;
			aviao.y = posInicialAviao.y;
			//indETO.y = posInicialAviao.y;
			//ETO.y = indETO.y + 25;
			
			tAviao = new Cronometer();
			tAviao.start();
			timeElasped = 0;
			tBombaElasped = 0;
			
			tBomba = new Cronometer();
			
			bombaLancada = false;
			bombaExplodiu = false;
			
			var hAviao:Number = pixel2meter(new Point(aviao.x, aviao.y)).y;
			//altura.text = hAviao.toFixed(1).replace(".",",") + " m";
			altura.text = hAviao.toFixed(0) + " m";
			
			flechaAltura.height = (VIEWPORT.height - aviao.y) - (VIEWPORT.height - flechaAltura.y);
			altura.y = flechaAltura.y - flechaAltura.height / 2 - altura.height / 2;
			downArrow.x = flechaAltura.x;
			downArrow.y = flechaAltura.y;
			upArrow.x = flechaAltura.x;
			upArrow.y = flechaAltura.y - flechaAltura.height;
			
			distanciaAlvo = pixel2meter(new Point(alvo.x, alvo.y)).x + Math.abs(aviaoR0.x);
			timeToTarget = distanciaAlvo / aviaoV0.x;
			
			tempoTween = Math.sqrt(2 * Number(altura.text.replace(" m", "").replace(",", ".")) / 9.8);
			
			scoreTotal = new DynamicAverage2();
			//mediaPontos.text = "Média: 0%";
			
			scoreValendo = new DynamicAverage2();
			
			soundControl.gotoAndStop("ON");
			currentSoundTransform = soundTransformNormal;
			currentSoundTransform2 = soundTransform2;
			
			setChildIndex(fundoMute, numChildren - 1);
			setChildIndex(soundControl, numChildren - 1);
			setChildIndex(botoes, numChildren - 1);
			setChildIndex(bordaAtividade, numChildren - 1);
		}
		
		private function changePlaneParameters():void
		{
			if (bombaLancada)
			{
				sound.stop();
				//stage.removeEventListener(Event.ENTER_FRAME, soundSeek);
				
				//aviaoR0 = new Point(pixel2meter(new Point(0 - 55, 0)).x , Math.random() * 270 + 300);
				aviaoR0 = new Point(pixel2meter(new Point(0 - 55, 0)).x , pixel2meter(new Point(0, Math.random() * 265 + 35)).y);
				//aviaoV0 = new Point(150, 0);
				aviaoV0 = new Point(Math.random() * 50 + 100, 0);
				
				var posInicialAviao:Point = meter2pixel(aviaoR0);
				aviao.y = posInicialAviao.y;
				//indETO.y = posInicialAviao.y;
				//ETO.y = indETO.y + 25;
				
				indETO.visible = true;
				ETO.visible = true;
				targetLine.visible = true;
				
				var hAviao:Number = pixel2meter(new Point(posInicialAviao.x, posInicialAviao.y)).y;
				//altura.text = hAviao.toFixed(1).replace(".",",") + " m";
				altura.text = hAviao.toFixed(0) + " m";
				
				flechaAltura.height = (VIEWPORT.height - posInicialAviao.y) - (VIEWPORT.height - flechaAltura.y);
				altura.y = flechaAltura.y - flechaAltura.height / 2 - altura.height / 2;
				downArrow.x = flechaAltura.x;
				downArrow.y = flechaAltura.y;
				upArrow.x = flechaAltura.x;
				upArrow.y = flechaAltura.y - flechaAltura.height;
				
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
				
				updateStatisticas();
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
				indETO.visible = true;
				ETO.visible = true;
				targetLine.visible = true;
			}
			
			soundAviao.stop();
			soundAviao = aviaoVoando.play();
			soundAviao.soundTransform = currentSoundTransform;
			
		}
		
		private function addListeners():void
		{
			stage.addEventListener(Event.ENTER_FRAME, update);
			launchButton.addEventListener(MouseEvent.CLICK, launchBomb);
			launchButton.addEventListener(MouseEvent.MOUSE_OVER, eagleTimeOn);
			launchButton.addEventListener(MouseEvent.MOUSE_OUT, eagleTimeOff);
			
			botoes.btEstatisticas.addEventListener(MouseEvent.CLICK, showEstatisticas);
			btValendoNota.addEventListener(MouseEvent.CLICK, askFazValer);
			
			feedbackScreen.addEventListener("OK", fazValer);
			soundControl.addEventListener(MouseEvent.CLICK, changeSound);
			soundControl.buttonMode = true;
			soundControl.mouseChildren = false;
			soundControl.addEventListener(MouseEvent.MOUSE_OVER, overBtn);
			soundControl.addEventListener(MouseEvent.MOUSE_OUT, outBtn);
		}
		
		private function overBtn(e:MouseEvent):void
		{
			e.target.scaleX = e.target.scaleY = 1.2;
		}
		
		private function outBtn(e:MouseEvent):void
		{
			e.target.scaleX = e.target.scaleY = 1;
		}
		
		private function changeSound(e:MouseEvent):void 
		{
			if (soundControl.currentLabel == "ON") {
				soundControl.gotoAndStop("OFF");
				muteOn();
			}else {
				soundControl.gotoAndStop("ON");
				muteOff();
			}
			saveStatus();
		}
		
		private function muteOn():void
		{
			sound.soundTransform = soundTransformMute;
			soundAviao.soundTransform = soundTransformMute;
			soundExplosao.soundTransform = soundTransformMute;
			currentSoundTransform = soundTransformMute;
			currentSoundTransform2 = soundTransformMute;
		}
		
		private function muteOff():void
		{
			sound.soundTransform = soundTransform2;
			soundAviao.soundTransform = soundTransformNormal;
			soundExplosao.soundTransform = soundTransformNormal;
			currentSoundTransform = soundTransformNormal;
			currentSoundTransform2 = soundTransform2;
		}
		
		private function askFazValer(e:MouseEvent):void 
		{
			feedbackScreen.okCancelMode = true;
			feedbackScreen.openScreen();
			//feedbackScreen.setText("Ao entrar no modo de avaliação e a partir do próximo lançamento, sua pontuação será contabilizada na sua nota. Além disso, não será possível retornar para o modo de investigação. Confirma a alteração para o modo de avaliação?");
			setChildIndex(feedbackScreen, numChildren - 1);
		}
		
		private function fazValer(e:Event):void 
		{
			valendoNota = true;
			//btValendoNota.visible = false;
			btValendoNota.filters = [GRAYSCALE_FILTER];
			btValendoNota.alpha = 0.5;
			btValendoNota.mouseEnabled = false;
			saveStatus();
		}
		
		private function showEstatisticas(e:MouseEvent):void 
		{
			updateStatisticas();
			
			feedbackScreen.okCancelMode = false;
			feedbackScreen.openScreen();
			
			setChildIndex(feedbackScreen, numChildren - 1);
		}
		
		private function updateStatisticas():void
		{
			var estatisticas:Object = new Object();
		
			estatisticas.nTotal = String(scoreTotal.n);
			estatisticas.nValendo = String(scoreValendo.n);
			estatisticas.nNaoValendo = String(scoreTotal.n - scoreValendo.n);
			estatisticas.scoreMin = String(scoreMin);
			estatisticas.scoreTotal = String(scoreTotal.mean.toFixed(0)).replace(".", "");
			estatisticas.scoreValendo = String(scoreValendo.mean.toFixed(0)).replace(".", "");
			estatisticas.valendo = valendoNota;
			
			feedbackScreen.updateStatics(estatisticas);
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
				aviao.abertura.play();
				
				bombaR0 = pixel2meter(new Point(aviao.x, aviao.y));
				bombaV0 = aviaoV0;
				bomba.rotation = -90;
				tBombaElasped = 0;
				bomba.gotoAndStop("INICIO");
				
				tBomba.start();
				bombaLancada = true;
				
				sound = bombaCaindo.play();
				sound.soundTransform = currentSoundTransform2;
				//stage.addEventListener(Event.ENTER_FRAME, soundSeek);
				
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
			if (tempoETO <= 0) {
				ETO.text = "0 s";
				if (ETO.visible) {
					indETO.visible = false;
					ETO.visible = false;
					targetLine.visible = false;
				}
			}
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
					
					//sound.stop();
					sound.stop();
					soundExplosao = explosao.play();
					soundExplosao.soundTransform = currentSoundTransform;
					
					//bomba.play();
					bomba.rotation = 0;
					bomba.gotoAndPlay(2);
					bomba.pontuacao.text = String(Math.round(pontos)) + "%";
					
					updateStatisticas();
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
			
			scoreTotal.push(pontuacaoAux);
			if (valendoNota) {
				scoreValendo.push(pontuacaoAux);
				if(ExternalInterface.available){
					if (!completed) {
						if (scoreValendo.mean >= scoreMin) {
							completed = true;
						}
					}
					score = scoreValendo.mean;
				}
			}
			
			pontuacao = Math.round(scoreTotal.mean);
			saveStatus();
			
			return pontuacaoAux;
			
		}
		
		private function saveStatusForRecovery():void
		{
			var status:Object = new Object();
			
			status.mediaGeral = scoreTotal.mean;
			status.nTotal = scoreTotal.n;
			status.mediaValendo = scoreValendo.mean;
			status.nValendo = scoreValendo.n;
			status.valendo = valendoNota;
			status.sound = soundControl.currentLabel;
			
			mementoSerialized = JSON.encode(status);
		}
		
		private function recoverStatus():void
		{
			if (mementoSerialized == null) return;
			if (mementoSerialized == "null") return;
			if (mementoSerialized == "") return;
			
			var status:Object = JSON.decode(mementoSerialized);
			
			scoreTotal.setParams(status.mediaGeral, status.nTotal);
			scoreValendo.setParams(status.mediaValendo, status.nValendo);
			
			if (status.valendo) {
				fazValer(null);
			}
			
			soundControl.gotoAndStop(status.sound);
			if (status.sound == "ON") {
				muteOff();
			}else {
				muteOn();
			}
			
			updateStatisticas();
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
		
		
		
		//---------------- Tutorial -----------------------
		
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var alturaForTuto:Point = new Point();
		private var etoForTuto:Point = new Point();
		private var tutoSequence:Array = ["O avião precisa lançar uma bomba...", 
										  "... e atingir o alvo.",
										  "Para isso, você deve usar a altura do voo para calcular o tempo de queda da bomba...",
										  "... e compará-lo com o tempo que falta para o avião sobrevoar o alvo (ETO).",
										  "Sua pontuação é a média de todos os seus lançamentos (após um lançamento, o avião sobrevoa o alvo novamente numa altura diferente).",
										  "Inicialmente seus lançamentos não valem nota. Quando você achar que já está pronto(a) para ser avaliado(a), pressione este botão."];
		
		override public function iniciaTutorial(e:MouseEvent = null):void 
		{
			tutoPos = 0;
			
			alturaForTuto.x = altura.x + altura.textWidth + 5;
			alturaForTuto.y = altura.y + altura.height / 2;
			
			etoForTuto.x = indETO.x - 25;
			etoForTuto.y = indETO.y + 20;
			
			if(balao == null){
				balao = new CaixaTexto(true);
				addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(launchButton.x, launchButton.y - launchButton.height / 2),
								new Point(alvo.x , alvo.y),
								alturaForTuto,
								etoForTuto,
								new Point(300 , 200),
								new Point(btValendoNota.x, btValendoNota.y - btValendoNota.height / 2)];
								
				tutoBaloonPos = [[CaixaTexto.BOTTON, CaixaTexto.CENTER],
								[CaixaTexto.BOTTON, CaixaTexto.LAST],
								[CaixaTexto.LEFT, CaixaTexto.CENTER],
								[CaixaTexto.RIGHT, CaixaTexto.FIRST],
								["", ""],
								[CaixaTexto.BOTTON, CaixaTexto.CENTER]];
			}
			balao.removeEventListener(Event.CLOSE, closeBalao);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(Event.CLOSE, closeBalao);
			balao.visible = true;
		}
		
		private function closeBalao(e:Event):void 
		{
			tutoPos++;
			if (tutoPos >= tutoSequence.length) {
				balao.removeEventListener(Event.CLOSE, closeBalao);
				balao.visible = false;
			}else {
				alturaForTuto.x = altura.x + altura.textWidth + 5;
				alturaForTuto.y = altura.y + altura.height / 2;
				etoForTuto.x = indETO.x - 45;
				etoForTuto.y = indETO.y + 14;
				
				balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
				balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			}
		}
		
		
		
		/*------------------------------------------------------------------------------------------------*/
		//SCORM:
		
		private const PING_INTERVAL:Number = 5 * 60 * 1000; // 5 minutos
		private var completed:Boolean;
		private var scorm:SCORM;
		private var scormExercise:int;
		private var connected:Boolean;
		private var score:int = 0;
		private var pingTimer:Timer;
		private var mementoSerialized:String = "";
		
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			completed = false;
			connected = false;
			scorm = new SCORM();
			
			pingTimer = new Timer(PING_INTERVAL);
			pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
			
			connected = scorm.connect();
			
			if (connected) {
				
				if (scorm.get("cmi.mode") != "normal") return;
				
				scorm.set("cmi.exit", "suspend");
				// Verifica se a AI já foi concluída.
				var status:String = scorm.get("cmi.completion_status");	
				mementoSerialized = scorm.get("cmi.suspend_data");
				var stringScore:String = scorm.get("cmi.score.raw");
				
				switch(status)
				{
					// Primeiro acesso à AI
					case "not attempted":
					case "unknown":
					default:
						completed = false;
						break;
					
					// Continuando a AI...
					case "incomplete":
						completed = false;
						break;
					
					// A AI já foi completada.
					case "completed":
						completed = true;
						//setMessage("ATENÇÃO: esta Atividade Interativa já foi completada. Você pode refazê-la quantas vezes quiser, mas não valerá nota.");
						break;
				}
				
				//unmarshalObjects(mementoSerialized);
				scormExercise = 1;
				score = Number(stringScore.replace(",", "."));
				
				var success:Boolean = scorm.set("cmi.score.min", "0");
				if (success) success = scorm.set("cmi.score.max", "100");
				
				if (success)
				{
					scorm.save();
					pingTimer.start();
				}
				else
				{
					//trace("Falha ao enviar dados para o LMS.");
					connected = false;
				}
			}
			else
			{
				trace("Esta Atividade Interativa não está conectada a um LMS: seu aproveitamento nela NÃO será salvo.");
				mementoSerialized = ExternalInterface.call("getLocalStorageString");
			}
			
			//reset();
		}
		
		/**
		 * @private
		 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
		 */ 
		private function commit()
		{
			if (connected)
			{
				if (scorm.get("cmi.mode") != "normal") return;
				
				// Salva no LMS a nota do aluno.
				var success:Boolean = scorm.set("cmi.score.raw", score.toString());

				// Notifica o LMS que esta atividade foi concluída.
				success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));

				// Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
				success = scorm.set("cmi.location", scormExercise.toString());
				
				// Salva no LMS a string que representa a situação atual da AI para ser recuperada posteriormente.
				success = scorm.set("cmi.suspend_data", mementoSerialized.toString());

				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}else { //LocalStorage
				//ExternalInterface.call("save2LS", mementoSerialized);
			}
		}
		
		/**
		 * @private
		 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
		 */
		private function pingLMS (event:TimerEvent)
		{
			commit();
		}
		
		private function saveStatus(e:Event = null):void
		{
			if (ExternalInterface.available) {
				
				if (connected) {
					if (scorm.get("cmi.mode") != "normal") return;
					
					saveStatusForRecovery();
					commit();
				}else {//LocalStorage
					saveStatusForRecovery();
					ExternalInterface.call("save2LS", mementoSerialized);
				}
			}
		}
		
	}

}