package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	public class Cell extends Sprite
	{
		private static const EdgeLength:int = 16;
		// 最初の実装では12 * 12 のpngを作成し、それを読み込ませていたが、
		// さすがに量が大きくなるとメモリの使用量がばかにならないので、
		// 16進数で記述したBitmapDataを作成して適時利用する方法に変更した。
		// 結果、メモリ使用料が10MBほど減った。
		private static const ImageLive:BitmapData = new BitmapData(EdgeLength, EdgeLength, false, 0x000000);
		private static const ImageEmpty:BitmapData = new BitmapData(EdgeLength, EdgeLength, false, 0xFFFFFF);
		private static const ImageBorn:BitmapData = new BitmapData(EdgeLength, EdgeLength, false, 0xFF0000);
		private static const ImageDead:BitmapData = new BitmapData(EdgeLength, EdgeLength, false, 0x0000FF);
		
		private var bmp:Bitmap = null;
		public var live:Boolean = false;
		public var liveNextTurn:Boolean = false;
		
		// コンストラクタではMath.random()によりランダムで生存させるようにしている。
		// 生存確率は約10%
		public function Cell()
		{
			bmp = new Bitmap(ImageEmpty);
			addChild(bmp);
			if(Math.random() > 0.90) {
				live = true;
				updateImage(ImageBorn);
			} else {
				live = false;
				updateImage(ImageEmpty);
			}
		}
		
		// ビットマップをアップデートするメソッド
		private function updateImage(new_bmp:BitmapData):void {
			// 現在のビットマップと新しいビットマップの差が 0x000000
			// つまり差が無い → 現在のビットマップと新しいビットマップが等しい時には
			// 更新しない。（高速化の工夫）
			if(bmp.bitmapData.compare(new_bmp) != 0x000000) {
				removeChild(bmp);
				bmp = new Bitmap(new_bmp);
				addChild(bmp);
			}
		}
		
		// 状態によってアップデート
		public function update():void {
			if(live == true) {
				if(liveNextTurn == true) {
					updateImage(ImageLive);
				} else {
					updateImage(ImageDead);
				}
			} else {
				if(liveNextTurn == true) {
					updateImage(ImageBorn);
				} else {
					updateImage(ImageEmpty);
				}
			}
			live = liveNextTurn;
		}
	}
}