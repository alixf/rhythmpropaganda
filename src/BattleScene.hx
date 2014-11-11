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

enum Action
{
	ATTACK;
	DEFEND;
}

enum ActionSuccess
{
	MISS;
	OK;
	GOOD;
	MARVELOUS;
}

class BattleScene extends Sprite
{
	var game : Game;

	var terrainAsset : BitmapData;
	var swordAsset = Assets.getBitmapData("assets/sword.png");
	var shieldAsset = Assets.getBitmapData("assets/shield.png");
	var timelineAsset = Assets.getBitmapData("assets/timeline.png");
	var cursorAsset = Assets.getBitmapData("assets/cursor.png");
	var characterAsset0 = Assets.getBitmapData("assets/character_0.png");
	var characterAsset1 = Assets.getBitmapData("assets/character_1.png");
	var characterAsset2 = Assets.getBitmapData("assets/character_2.png");
	var readyAsset = Assets.getBitmapData("assets/ready.png");
	var missAsset = Assets.getBitmapData("assets/miss.png");
	var okAsset = Assets.getBitmapData("assets/ok.png");
	var goodAsset = Assets.getBitmapData("assets/good.png");
	var marvelousAsset = Assets.getBitmapData("assets/marvelous.png");
	var defeatAsset = Assets.getBitmapData("assets/defeat.png");
	var victoryAsset = Assets.getBitmapData("assets/victory.png");

	var enemyAsset0 : BitmapData;
	var enemyAsset1 : BitmapData;
	var enemyAsset2 : BitmapData;

	#if flash
		var missSound = Assets.getSound("assets/miss.mp3");
		var hurtSound = Assets.getSound("assets/hurt.mp3");
		var hitSound = Assets.getSound("assets/hit.mp3");
	#else
		var missSound = Assets.getSound("assets/miss.ogg");
		var hurtSound = Assets.getSound("assets/hurt.ogg");
		var hitSound = Assets.getSound("assets/hit.ogg");
	#end

	var character = new Sprite();
	var enemy = new Sprite();
	var characterGauge = new Gauge();
	var enemyGauge = new Gauge();
	var battleIcons : Array<Sprite>;
	var background = new Bitmap(new BitmapData(800, 600, false, 0x000000));
	var ready : Sprite;
	var waiting = true;
	var timeline = new Sprite();
	var cursor : Bitmap;

	var battleData : Game.Battle;
	var battleId : Int;
	
	var timelineMargin = 5;
	var actionDone = false;
	var latestSuccess = MISS;

	var actionBuffer : Array<{action : Action, time : Float}>;

	var characterMaxHealth : Float;
	var characterHealth : Float;
	var characterAttack : Float;
	var enemyHealth : Float;
	var enemyMaxHealth : Float;

	var clock = new Clock();
	var over = false;
	var tutorial : Bitmap;

	public function new(game : Game, battleId : Int, battleData : Game.Battle)
	{
		super();
		this.game = game;
		this.battleData = battleData;
		this.battleId = battleId;

		enemyAsset0 = Assets.getBitmapData(battleData.enemy[0]);
		enemyAsset1 = Assets.getBitmapData(battleData.enemy[1]);
		enemyAsset2 = Assets.getBitmapData(battleData.enemy[2]);

		characterMaxHealth = game.characterHealth;
		characterHealth = game.characterHealth;
		characterAttack = game.characterAttack;

		enemyMaxHealth = battleData.enemyHealth;
		enemyHealth = battleData.enemyHealth;

		clock.stop();
		addEventListener(Event.ENTER_FRAME, update);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);

		addChild(new Bitmap(Assets.getBitmapData(battleData.terrain)));
		buildActionBuffer(battleData.minDelay, battleData.maxDelay);
		buildTimeline();

		character.x = 600;
		character.y = 375;
		addChild(character);
		var characterBitmap = new Bitmap(characterAsset0);
		characterBitmap.x = -characterBitmap.width/2;
		characterBitmap.y = -characterBitmap.height/2;
		character.addChild(characterBitmap);

		enemy.x = 200;
		enemy.y = 375;
		addChild(enemy);
		var enemyBitmap = new Bitmap(enemyAsset0);
		enemyBitmap.x = -enemyBitmap.width/2;
		enemyBitmap.y = -enemyBitmap.height/2;
		enemy.addChild(enemyBitmap);
	

		characterGauge.y = -150;
		characterGauge.x = 10;
		character.addChild(characterGauge);
		enemyGauge.y = -150;
		enemyGauge.x = 10;
		enemy.addChild(enemyGauge);
		Actuate.tween(characterGauge, 1.5, {y : characterGauge.y - 15}).repeat().reflect().ease(motion.easing.Linear.easeNone);
		Actuate.tween(enemyGauge, 1.5, {y : enemyGauge.y - 15}).repeat().reflect().ease(motion.easing.Linear.easeNone);


		ready = new Sprite();
		ready.x = 800/2;
		ready.y = 600/2;
		ready.alpha = 0;
		ready.scaleX = ready.scaleY = 0;
		addChild(ready);
		var readyBitmap = new Bitmap(readyAsset);
		readyBitmap.x = -readyBitmap.width/2;
		readyBitmap.y = -readyBitmap.height/2;
		ready.addChild(readyBitmap);
		Actuate.tween(ready, 0.25, {alpha : 1, scaleX : 1, scaleY : 1});

		addChild(background);
		Actuate.tween(background, 1, {alpha : 0});


        if(game.showBattleTutorial)
        {
			tutorial = new Bitmap(Assets.getBitmapData("assets/tutorial0.png"));
			addChild(tutorial);
        }

	}

	public var state = 0;
	public function update(event:Event)
	{
		var time = clock.getTime();
		var action = actionBuffer[0];
		var characterBitmapData = characterAsset0;
		var enemyBitmapData = enemyAsset0;

		while(action != null && time > action.time)
		{
			state = 0;
			if(!actionDone)
				hit(MISS);
			actionDone = false;
			if(action != null)
				doAction(action);

			actionBuffer.shift();
			Actuate.tween(character, 0.25, {x : 600, y : 375});
			Actuate.tween(enemy, 0.25, {x : 200, y : 375});
			action = actionBuffer[0];
		}
		if(action != null)
		{
			var diffTime = action.time - time;


			if(diffTime < 0.1)
			{
				switch(action.action)
				{
				case ATTACK:
					characterBitmapData = characterAsset2;
					enemyBitmapData = enemyAsset0;
				case DEFEND:
					characterBitmapData = characterAsset0;
					enemyBitmapData = enemyAsset2;
				}
			}
			else if(diffTime < 0.5)
			{
				switch(action.action)
				{
				case ATTACK:
					characterBitmapData = characterAsset1;
					enemyBitmapData = enemyAsset0;
					if(state == 0)
					{
						Actuate.tween(character, diffTime, {x : 250, y : 375});
						state = 1;
					}
					
				case DEFEND:
					characterBitmapData = characterAsset0;
					enemyBitmapData = enemyAsset1;
					if(state == 0)
					{
						Actuate.tween(enemy, diffTime, {x : 550, y : 375});
						state = 1;
					}
				}
			}
			else
			{
				characterBitmapData = characterAsset0;
				enemyBitmapData = enemyAsset0;
			}
		}

		var characterBitmap : Bitmap = cast character.getChildAt(0);
		characterBitmap.bitmapData = characterBitmapData;
		var enemyBitmap : Bitmap = cast enemy.getChildAt(0);
		enemyBitmap.bitmapData = enemyBitmapData;

		if(time >= battleData.sequenceTime && !over)
		{
			over = true;
			if(characterHealth <= 0)
				gameOver();
			else if(enemyHealth <= 0)
				win();
			else
				replay();
		}
	}

	public function keyDown(event : KeyboardEvent)
	{
        if(game.showBattleTutorial)
        {
        	Actuate.tween(tutorial, 0.5, {alpha : 0}).onComplete(function(){removeChild(tutorial);});
        	game.showBattleTutorial = false;
        	return;
        }
		if(waiting)
		{
			Actuate.tween(ready, 0.5, {alpha : 0, scaleX : 0, scaleY : 0}).onComplete(function(){startTime();});
			waiting = false;
		}
		else
		{
			var time = clock.getTime();
			var action = actionBuffer[0];
			if(action != null && !actionDone)
			{
				if ((action.action == ATTACK && event.keyCode == 65) || (action.action == DEFEND && event.keyCode == 80))
				{
					var diffTime = action.time - time;
					if(diffTime < 0.05)
						hit(MARVELOUS);
					else if(diffTime < 0.15)
						hit(GOOD);
					else if(diffTime < 0.3)
						hit(OK);
					else
						hit(MISS);
					actionDone = true;
				}
				else
				{
					hit(MISS);
					actionDone = true;
				}
			}
		}
	}

	public function startTime()
	{
		clock.reset();
		clock.start();
		Actuate.tween(cursor, battleData.sequenceTime, {x : timelineAsset.width/2 - cursorAsset.width/2 - timelineMargin}).ease(motion.easing.Linear.easeNone);
	}

	public function buildActionBuffer(minDelay : Float, maxDelay : Float)
	{
		actionBuffer = new Array<{action : Action, time : Float}>();
		var time = 1.0;
		while(time < battleData.sequenceTime)
		{
			actionBuffer.push({action : Math.random() > 0.5 ? Action.ATTACK : Action.DEFEND, time : time});
			time += minDelay + Math.random() * (maxDelay-minDelay);
		}
	}

	public function buildTimeline()
	{
		timeline = new Sprite();
		addChild(timeline);
		timeline.y = 550;
		timeline.x = 400;
		
		var timelineBitmap = new Bitmap(timelineAsset);
		timelineBitmap.x = -timelineAsset.width/2;
		timelineBitmap.y = -timelineAsset.height/2;
		timeline.addChild(timelineBitmap);

		for(action in actionBuffer)
		{
			var actionIcon = switch(action.action)
			{
				case ATTACK : new Bitmap(swordAsset);
				case DEFEND : new Bitmap(shieldAsset);
			}
			actionIcon.x = timelineBitmap.x + (timelineAsset.width-2*timelineMargin) * (action.time / battleData.sequenceTime) - actionIcon.width/2;
			actionIcon.y = -actionIcon.height/2;
			timeline.addChild(actionIcon);	
		}

		cursor = new Bitmap(cursorAsset);
		cursor.x = -timelineAsset.width/2 - cursorAsset.width/2 + timelineMargin;
		cursor.y = -cursorAsset.height/2;
		timeline.addChild(cursor);
	}

	public function hit(success : ActionSuccess)
	{
		var successBitmap = switch(success)
		{
			case MISS: new Bitmap(missAsset);
			case OK: new Bitmap(okAsset);
			case GOOD: new Bitmap(goodAsset);
			case MARVELOUS: new Bitmap(marvelousAsset);
		}
		successBitmap.x = timeline.x + cursor.x - successBitmap.width/2;
		successBitmap.y = timeline.y + cursor.y - successBitmap.height;
		Actuate.tween(successBitmap, 0.5, {y : successBitmap.y - 50, alpha : 0}).ease(motion.easing.Linear.easeNone).onComplete(function(){removeChild(successBitmap);});
		addChild(successBitmap);
		latestSuccess = success;
	}

	public function doAction(action : {action : Action, time : Float})
	{
		if(action != null)
		{
			switch(action.action)
			{
			case ATTACK :
				var damage = characterAttack * switch(latestSuccess)
				{
					case MISS      : 0.0;
					case OK        : 0.5;
					case GOOD      : 0.75;
					case MARVELOUS : 1.0;
				};
				enemyHealth = Math.max(enemyHealth - damage, 0);
			case DEFEND :
				var damage = battleData.enemyAttack * switch(latestSuccess)
				{
					case MISS      : 1.0;
					case OK        : 0.5;
					case GOOD      : 0.25;
					case MARVELOUS : 0.0;
				}
				characterHealth = Math.max(characterHealth - damage, 0);
			}

			switch(action.action)
			{
			case ATTACK :
				switch(latestSuccess)
				{
					case MISS      : missSound.play();
					case OK        : hitSound.play();
					case GOOD      : hitSound.play();
					case MARVELOUS : hitSound.play();
				};
			case DEFEND :
				switch(latestSuccess)
				{
					case MISS      : hurtSound.play();
					case OK        : hurtSound.play();
					case GOOD      : hurtSound.play();
					case MARVELOUS : missSound.play();
				}
			}

			enemyGauge.setValue(enemyHealth / enemyMaxHealth);
			characterGauge.setValue(characterHealth / characterMaxHealth);
		}
	}


	public function gameOver()
	{
		var defeat = new Sprite();
		defeat.x = 800/2;
		defeat.y = 600/2;
		defeat.alpha = 0;
		defeat.scaleX = defeat.scaleY = 0;
		addChild(defeat);
		var defeatBitmap = new Bitmap(defeatAsset);
		defeatBitmap.x = -defeatBitmap.width/2;
		defeatBitmap.y = -defeatBitmap.height/2;
		defeat.addChild(defeatBitmap);
		Actuate.apply(defeat, {alpha : 0, scaleX : 0, scaleY : 0});
		Actuate.tween(defeat, 1, {alpha : 1, scaleX : 1, scaleY : 1})
			.onComplete(function(){Actuate.tween(defeat, 1, {alpha : 0, scaleX : 0, scaleY : 0})
				.onComplete(function(){game.changeScene(MAP);});});

		Actuate.tween(background, 1, {alpha : 1});
	}

	public function win()
	{
		var victory = new Sprite();
		victory.x = 800/2;
		victory.y = 600/2;
		victory.alpha = 0;
		victory.scaleX = victory.scaleY = 0;

		if(battleData.item != null && !Lambda.has(game.inventory, battleData.item))
		{
			var newItem = new Bitmap(Assets.getBitmapData("assets/newItem.png"));
			newItem.x = -150;
			newItem.y = 100;
			victory.addChild(newItem);
			var newItemBitmap = new Bitmap(Assets.getBitmapData(battleData.item.image));
			newItemBitmap.x = 50;
			newItemBitmap.y = 90;
			newItemBitmap.scaleX = newItemBitmap.scaleY = 2;
			victory.addChild(newItemBitmap);
			game.inventory.push(battleData.item);
		}


		addChild(victory);
		var victoryBitmap = new Bitmap(victoryAsset);
		victoryBitmap.x = -victoryBitmap.width/2;
		victoryBitmap.y = -victoryBitmap.height/2;
		victory.addChild(victoryBitmap);
		Actuate.apply(victory, {alpha : 0, scaleX : 0, scaleY : 0});
		Actuate.tween(victory, (battleData.item != null ? 5 : 2), {alpha : 1, scaleX : 1, scaleY : 1})
			.onComplete(function(){Actuate.tween(victory, 1, {alpha : 0, scaleX : 0, scaleY : 0})
				.onComplete(function()
					{
						if(game.mapProgress == battleId)
							game.mapProgress++;
						game.changeScene(MAP);
					});
				});
		
		Actuate.tween(background, 1, {alpha : 1});
	}

	public function replay()
	{
		Actuate.tween(ready, 0.25, {alpha : 1, scaleX : 1, scaleY : 1}).delay(1).onComplete(function()
			{
				waiting = true;
				clock.reset();
				clock.stop();
				over = false;
				removeChild(timeline);
				buildActionBuffer(battleData.minDelay, battleData.maxDelay);
				buildTimeline();

			});
	}
}