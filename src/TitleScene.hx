package;

import motion.Actuate;
import openfl.display.Sprite;
import openfl.Assets;
import openfl.Lib;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;

class TitleScene extends Sprite
{
	var game : Game;

	var background = new Bitmap(new BitmapData(800, 600, false, 0x000000));
	var title = new Bitmap(Assets.getBitmapData("assets/title.png"));
	var pushStart = false;

	public function new(game : Game)
	{
		super();

		this.game = game;
        addEventListener(Event.ENTER_FRAME, update);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);

      	addChild(title);
      	addChild(background);
        Actuate.tween(background, 1, {alpha : 0}).onComplete(function(){pushStart = true;});
	}

	public function update(event:Event)
	{
	}

	public function keyDown(event:KeyboardEvent)
	{
		if(pushStart)
		{
			pushStart = false;
        	Actuate.tween(background, 1, {alpha : 1}).onComplete(function(){game.changeScene(MAP);});
		}
	}
}