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
	public class DynamicAverage2 {

		private var theMean:Number;	// Média.
		private var numbers:int;
		
		/**
		 * Constrói uma média dinâmica
		 */
		public function DynamicAverage2 (inicial:Number = 0, nInicial:int = 0) : void {
			theMean = inicial;
			numbers = nInicial;
		}
		
		public function setParams(mean:Number, numbers:int):void
		{
			this.theMean = mean;
			this.numbers = numbers;
		}
		
		/**
		 * Acrescenta um valor à média
		 * @param	item
		 * número a ser acrescentado à média
		 */
		public function push (item:Number):void {
			theMean = ((theMean * numbers) + item) / (numbers + 1);
			
			numbers++;
		}
		
		/**
		 * Retorna a média
		 */
		public function get mean ():Number {
			return theMean;
		}
		
		public function get n():int
		{
			return numbers;
		}
	}
}