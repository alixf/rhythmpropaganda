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

class MapScene extends Sprite
{
	var game : Game;
    
    var battleAsset = Assets.getBitmapData("assets/battle.png");
    var drapalAsset = Assets.getBitmapData("assets/drapal.png");
	
	var battleIcons : Array<Sprite>;
	var background : Bitmap;
	var tutorial : Bitmap;


	public function new(game : Game)
	{
		super();
		this.game = game;

        addChild(new Bitmap(Assets.getBitmapData("assets/map.png")));

        addEventListener(Event.ENTER_FRAME, update);
        addEventListener(MouseEvent.CLICK, mouseClick);
        addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);

        battleIcons = [];
        var i = 0;
        for(battle in game.battles)
        {
        	var battleIcon = new Sprite();
        	battleIcon.x = battle.x;
        	battleIcon.y = battle.y;
        	battleIcons.push(battleIcon);
        	addChild(battleIcon);
        	
        	if(i > game.mapProgress)
        		battleIcon.alpha = 0.33;

        	var battleBitmap = new Bitmap(battleAsset);
        	battleBitmap.x = -battleBitmap.width/2;
        	battleBitmap.y = -battleBitmap.height/2;
        	battleIcon.addChild(battleBitmap);

        	if(i < game.mapProgress)
        	{
        		var drapal = new Bitmap(drapalAsset);
        		drapal.x = -drapal.width/2;
        		drapal.y = -drapal.height+1;
        		battleIcon.addChild(drapal);
        	}

        	i++;
        }

        var inventory = new Inventory(game);
        addChild(inventory);
        inventory.y = 600 - 3*30;

        background = new Bitmap(new BitmapData(800, 600, false, 0x000000));
        addChild(background);
        Actuate.tween(background, 1, {alpha : 0});

        if(game.showMapTutorial)
        {
			tutorial = new Bitmap(Assets.getBitmapData("assets/tutorial1.png"));
			addChild(tutorial);
        }
	}

	public function update(event:Event)
	{
	}

	public function keyDown(event:KeyboardEvent)
	{
        if(game.showMapTutorial)
        {
        	Actuate.tween(tutorial, 0.5, {alpha : 0}).onComplete(function(){removeChild(tutorial);});
        	game.showMapTutorial = false;
        }
	}

	public function mouseMove(event:MouseEvent)
	{
        if(game.showMapTutorial)
        	return;
	
		var i = 0;
		for(battleIcon in battleIcons)
		{
        	if(i <= game.mapProgress)
        	{
				//js.Browser.window.console.log(battleIcon.hitTestPoint(event.stageX, event.stageY, false));
				if(battleIcon.hitTestPoint(event.stageX, event.stageY, false))
				{
					if(battleIcon.scaleX == 1 && battleIcon.scaleY == 1)
						Actuate.tween(battleIcon, 0.25, {scaleX : 2, scaleY : 2});
				}
				else
				{
					if(battleIcon.scaleX == 2 && battleIcon.scaleY == 2)
						Actuate.tween(battleIcon, 0.125, {scaleX : 1, scaleY : 1});
				}
        	}
			i++;
		}
	}

	public function mouseClick(event:MouseEvent)
	{
        if(game.showMapTutorial)
        	return;
	
		var i = 0;
		for(battleIcon in battleIcons)
		{
        	if(i <= game.mapProgress)
        	{
				if(battleIcon.hitTestPoint(event.stageX, event.stageY, false))
				{
					game.battleData = game.battles[i];
					game.battleId = i;
					Actuate.tween(background, 0.5, {alpha : 1}).onComplete (function(){game.changeScene(BATTLE);});
				}
			}
			i++;
		}
	}
}