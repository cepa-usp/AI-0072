/**
 * Esta classe permite ao usuário manter o valor médio dos últimos N itens adicionados a ela.
 * Por exemplo, a coordeanda x média do mouse nos últimos 5 quadros (frames) pode ser obtida assim:
 * 
 * var posicao:DynamicAverage = new DynamicAverage(5);
 * 
 * addEventListener(Event.ENTER_FRAME, eachFrame);
 * 
 * function eachFrame (event:Event) : void {
 *   posicao.push(mouseX);
 *   trace("Posição média: " + posicao.mean);
 * }
 */
package {
	public class DynamicAverage {

		private var theMean:Number;	// Média.
		private var numbers:Array;
		
		/**
		 * Constrói uma média dinâmica
		 */
		public function DynamicAverage () : void {
			reset();
		}
		
		/**
		 * Acrescenta um valor à média
		 * @param	item
		 * número a ser acrescentado à média
		 */
		public function push (item:Number):void {
			
			//if (numbers.length > N) numbers.shift();
			numbers.push(item);
			
			theMean = 0;
			for (var i:uint = 0; i < numbers.length; i++) theMean += numbers[i];
			theMean /= numbers.length;
		}
		
		/**
		 * Retorna a média
		 */
		public function get mean ():Number {
			return theMean;
		}
		
		/**
		 * Apaga a média (retorna-a a zero)
		 */
		public function reset ():void {
			theMean = 0;
			numbers = new Array();
			//for (var i:uint = 0; i < N; i++) numbers.push(0);
		}
		
		public function get n():int
		{
			return numbers.length;
		}
	}
}