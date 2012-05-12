import flash.events.TimerEvent;
import flash.system.System;
import flash.utils.Timer;

private var map:Array;
private var MAX_ROWS:int;
private var MAX_COLUMNS:int;

private var gameTimer:Timer = null;
private var autoIncreaseTimer:Timer = null;

private var during_step:Boolean = false;
private var autoIncreaseMode:Boolean = true;

// スタートボタンが押されたときに実行される。
private function gameStart():void {
	during_step = false;
	
	MAX_ROWS = image_table.height / 16; // 高さ
	MAX_COLUMNS = image_table.width / 16; // 幅
	
	// mapを二次元配列化。
	map = new Array();
	for(var i:int = 0; i < MAX_ROWS; i++) {
		// ActionScript の Array は何でも入れることができてしまい、
		// C++ユーザーの私にとっては非常に気持ち悪いので、
		// Vectorクラスを利用してジェネリクス（代入できる変数・インスタンスを制限する機能）を使えるようにする。
		map[i] = new Vector.<Cell>();
	}
	// mapにCellのインスタンスを詰め込む
	for(var r:int = 0; r < MAX_ROWS; r++) {
		for(var c:int = 0; c < MAX_COLUMNS; c++) {
			// Cell の新しいインスタンスを生成
			var cell:Cell = new Cell();
			map[r][c] = cell;
			// 座標を決める
			cell.x = cell.width * c;
			cell.y = cell.height * r;
			// image_table（見えないようになっているが、ちゃんと配置してある）の
			// 要素として登録する。
			image_table.addChild(cell);
		}
	}
	
	// 1.0秒（1000ms）に一度TimerEvent.Timerというイベントが飛ばされるように設定する。
	// 飛ばされたら、updateを呼ぶ。
	gameTimer = new Timer(1000);
	gameTimer.addEventListener(TimerEvent.TIMER, update);
	
	// 1000ms * 60 * 3 = 60s * 3 = 3m に一度イベントを飛ばし、
	// autoIncreaseメソッドでキャッチする
	autoIncreaseTimer = new Timer(1000 * 60 * 3);
	autoIncreaseTimer.addEventListener(TimerEvent.TIMER, autoIncrease);
	// タイマーをスタートさせる。
	timerStart();
}

private function timerStart():void {
	gameTimer.start();
	
	// 自動で増えるように設定されているとき
	if(autoIncreaseMode) {
		autoIncreaseTimer.start();
	}
}

private function timerStop():void {
	// gameTimer と autoIncreaseTimer に nullが設定されているときというのは
	// すなわちまだゲームが一度も始まっていない時である。
	// しかし面倒なので、このメソッドの中で判定するようにした。
	
	if(gameTimer != null) {
		gameTimer.stop();	
	}
	if(autoIncreaseTimer != null) {
		autoIncreaseTimer.stop();
	}
}

private function update(t_evt:TimerEvent = null):void {
	for(var r:int = 0; r < MAX_ROWS; r++) {
		for(var c:int = 0; c < MAX_COLUMNS; c++) {
			// デフォルトでは、どのマスも、次のターンは死滅する事になっている。
			map[r][c].liveNextTurn = false;
			
			// 周囲8マスに生存しているマスがいくつあるか調べる。
			// 探索オーダーは MAX_ROWS * MAX_COLUMNS * 9とあまり良くないが、
			// いまどきのコンピューターなら問題ないと思う。
			var liveCount:int = 0;
			for(var x:int = -1; x <= 1; x++) {
				for(var y:int = -1; y <= 1; y++) {
					// nx, ny : 新しい座標
					var nx:int = c + x;
					var ny:int = r + y;
					// !(nx == c && ny == r) というのはx座標、y座標共に自分自身のものとは等しくない時のことだが、
					// 高校生的にはド・モルガンの法則により(nx != c || ny != r)と書くべきである。
					if(!(nx == c && ny == r) &&
						0 <= nx && nx < MAX_COLUMNS && // x座標は範囲内か
						0 <= ny && ny < MAX_ROWS && // y座標は範囲内か
						map[ny][nx].live == true) {
							liveCount++;
					}
				}
			}
			
			if(map[r][c].live == false && liveCount == 3) {
				// そのマスが死滅していて、周囲8マスに生存しているマスがちょうど3つあるとき、
				// そのマスが次のターンに生存状態になる。
				map[r][c].liveNextTurn = true;
			} else if(map[r][c].live == true && (liveCount == 2 || liveCount == 3)) {
				// そのマスが生存していて、周囲8マスの生存マスが2 or 3のとき
				// そのマスは次のターンも生存する。
				map[r][c].liveNextTurn = true;
			}
		}
	}
	// 全てのマスの状態をアップデートする。
	for(r = 0; r < MAX_ROWS; r++) {
		for(c = 0; c < MAX_COLUMNS; c++) {
			map[r][c].update();
		}
	}
}

private function autoIncrease(event:TimerEvent = null):void {
	// autoIncreaseTimerから投げられたイベントをキャッチするメソッド。
	// すべてのマスに対し、乱数の結果に応じて次のターンに生存状態にする
	// Math.random() は [0, 1) の範囲の実数を生成するメソッドで、
	// 今回は約10%の確率で次のターンに生存状態にするようにしている。
	for(var r:int = 0; r < MAX_ROWS; r++) {
		for(var c:int = 0; c < MAX_COLUMNS; c++) {
			if(Math.random() > 0.90) {
				map[r][c].liveNextTurn = true;
				map[r][c].update();
			}
		}
	}
}
