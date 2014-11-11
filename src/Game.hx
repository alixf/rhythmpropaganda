package;

import motion.Actuate;
import openfl.display.Sprite;
import openfl.Assets;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;

enum ItemType
{
	WEAPON;
	ARMOR;
	JEWEL;
}

enum SceneType
{
	TITLE;
	MAP;
	BATTLE;
}

typedef Item = {name : String, image : String, type : ItemType, value : Float};
typedef Battle = {x : Int, y : Int, sequenceTime : Float, minDelay : Float, maxDelay : Float, enemyHealth : Float,   enemyAttack : Float, item : Item, terrain : String, enemy : Array<String>};

class Game extends Sprite
{
	var scene : Sprite = null;
	public var mapProgress = 0;

	public var showMapTutorial = true;
	public var showBattleTutorial = true;

	public var battleData : Battle;
	public var battleId : Int;

	public var characterHealth = 100.0;
	public var characterAttack = 10.0;
	public var characterAttackBase = 10.0;
	public var characterHealthBase = 100.0;
	public var tempoFactor = 0.0;

	public var items : Array<Item>;
	public var battles : Array<Battle>;

	public var inventory = new Array<Item>();
	public var weapon : Item;
	public var armor : Item;
	public var jewel : Item;

	public function new()
	{
		super();

		items =
		[
			{name : "Wooden sword",       image : "assets/items/woodenSword.png",       type : WEAPON, value : 5.0},
			{name : "Iron sword",         image : "assets/items/ironSword.png",         type : WEAPON, value : 7.0},
			{name : "Steel sword",        image : "assets/items/steelSword.png",        type : WEAPON, value : 16.0},
			{name : "Mithril sword",      image : "assets/items/mithrilSword.png",      type : WEAPON, value : 27.0},
			{name : "Orichalcum sword",   image : "assets/items/orichalcumSword.png",   type : WEAPON, value : 40.0},
			{name : "Night sword",        image : "assets/items/nightSword.png",        type : WEAPON, value : 55.0},
			{name : "Sun sword",          image : "assets/items/sunSword.png",          type : WEAPON, value : 80.0},
			
			{name : "Leather armor",      image : "assets/items/leatherArmor.png",      type : ARMOR,  value : 5.0},
			{name : "Iron armor",         image : "assets/items/ironArmor.png",         type : ARMOR,  value : 10.0},
			{name : "Steel armor",        image : "assets/items/steelArmor.png",        type : ARMOR,  value : 15.0},
			{name : "Mithril armor",      image : "assets/items/mithrilArmor.png",      type : ARMOR,  value : 30.0},
			{name : "Orichalcum armor",   image : "assets/items/orichalcumArmor.png",   type : ARMOR,  value : 60.0},
			{name : "Night armor",        image : "assets/items/nightArmor.png",        type : ARMOR,  value : 90.0},
			{name : "Sun armor",          image : "assets/items/sunArmor.png",          type : ARMOR,  value : 150.0},
			
			{name : "Silver watch",       image : "assets/items/silverWatch.png",       type : JEWEL,  value : 0.0},
			{name : "Copper watch",       image : "assets/items/copperWatch.png",       type : JEWEL,  value : 3.0},
			{name : "Gold watch",         image : "assets/items/goldWatch.png",         type : JEWEL,  value : 6.0},
			{name : "Saphir watch",       image : "assets/items/saphirWatch.png",       type : JEWEL,  value : 10.0},
			{name : "Emerald watch",      image : "assets/items/emeraldWatch.png",      type : JEWEL,  value : 30.0},
			{name : "Ruby watch",         image : "assets/items/rubyWatch.png",         type : JEWEL,  value : 40.0},
			{name : "Diamond watch",      image : "assets/items/diamondWatch.png",      type : JEWEL,  value : 50.0},
		];

		var weaponsIndex = 0;
		var armorIndex = 7;
		var jewelsIndex = 14;
		
		var enemies =
		[
			["assets/enemies/slime0.png",   "assets/enemies/slime1.png",   "assets/enemies/slime2.png"],
			["assets/enemies/dragon0.png",  "assets/enemies/dragon1.png",  "assets/enemies/dragon2.png"],
			["assets/enemies/golem0.png",   "assets/enemies/golem1.png",   "assets/enemies/golem2.png"],
			["assets/enemies/banshee0.png", "assets/enemies/banshee1.png", "assets/enemies/banshee2.png"],
			["assets/enemies/boss0.png",    "assets/enemies/boss1.png",    "assets/enemies/boss2.png"],
		];

		battles = 
		[
			// Continent 1
			//{x : 543, y : 220,    sequenceTime : 5.0,   minDelay : 0.10, maxDelay  : 0.5,   enemyHealth : 200,     enemyAttack : 55},
			{x : 543, y : 220,      sequenceTime : 5.0,   minDelay : 1.00, maxDelay  : 2.0,   enemyHealth : 10,      enemyAttack : 10, item : items[weaponsIndex++],  terrain : "assets/maps/terrain1.png", enemy : enemies[0]},
			{x : 543, y : 286,      sequenceTime : 5.0,   minDelay : 0.95, maxDelay  : 1.8,   enemyHealth : 20,      enemyAttack : 10, item : null,                   terrain : "assets/maps/terrain1.png", enemy : enemies[0]},
			{x : 487, y : 297,      sequenceTime : 5.0,   minDelay : 0.90, maxDelay  : 1.6,   enemyHealth : 20,      enemyAttack : 15, item : items[armorIndex++],    terrain : "assets/maps/terrain1.png", enemy : enemies[0]},
			{x : 509, y : 349,      sequenceTime : 5.0,   minDelay : 0.85, maxDelay  : 1.4,   enemyHealth : 30,      enemyAttack : 15, item : null,                   terrain : "assets/maps/terrain1.png", enemy : enemies[0]},
			{x : 458, y : 384,      sequenceTime : 5.0,   minDelay : 0.80, maxDelay  : 1.2,   enemyHealth : 30,      enemyAttack : 20, item : items[jewelsIndex++],   terrain : "assets/maps/terrain1.png", enemy : enemies[0]},
			{x : 436, y : 335,      sequenceTime : 5.0,   minDelay : 0.75, maxDelay  : 1.0,   enemyHealth : 40,      enemyAttack : 20, item : null,                   terrain : "assets/maps/terrain1.png", enemy : enemies[0]},
			{x : 372, y : 311,      sequenceTime : 5.0,   minDelay : 0.70, maxDelay  : 1.0,   enemyHealth : 40,      enemyAttack : 25, item : items[armorIndex++],    terrain : "assets/maps/terrain1.png", enemy : enemies[0]},
			{x : 401, y : 383,      sequenceTime : 5.0,   minDelay : 0.65, maxDelay  : 1.0,   enemyHealth : 50,      enemyAttack : 25, item : null,                   terrain : "assets/maps/terrain1.png", enemy : enemies[0]},
			{x : 338, y : 419,      sequenceTime : 5.0,   minDelay : 0.60, maxDelay  : 1.0,   enemyHealth : 100,     enemyAttack : 30, item : items[jewelsIndex++],  terrain : "assets/maps/terrain1.png", enemy : enemies[0]},

			// Continent 2
			{x : 210, y : 478,      sequenceTime : 5.0,   minDelay : 0.80, maxDelay  : 1.4,   enemyHealth : 30,      enemyAttack : 2*10, item : items[weaponsIndex++],  terrain : "assets/maps/terrain2.png", enemy : enemies[1]},
			{x : 116, y : 494,      sequenceTime : 5.0,   minDelay : 0.75, maxDelay  : 1.3,   enemyHealth : 40,      enemyAttack : 2*10, item : null,                   terrain : "assets/maps/terrain2.png", enemy : enemies[1]},
			{x : 28, y : 466,       sequenceTime : 5.0,   minDelay : 0.70, maxDelay  : 1.2,   enemyHealth : 50,      enemyAttack : 2*15, item : items[armorIndex++],     terrain : "assets/maps/terrain2.png", enemy : enemies[1]},
			{x : 29, y : 415,       sequenceTime : 5.0,   minDelay : 0.65, maxDelay  : 1.1,   enemyHealth : 60,      enemyAttack : 2*15, item : null,                    terrain : "assets/maps/terrain2.png", enemy : enemies[1]},
			{x : 175, y : 434,      sequenceTime : 5.0,   minDelay : 0.60, maxDelay  : 1.0,   enemyHealth : 70,      enemyAttack : 2*20, item : items[jewelsIndex++],   terrain : "assets/maps/terrain2.png", enemy : enemies[1]},
			{x : 107, y : 418,      sequenceTime : 5.0,   minDelay : 0.55, maxDelay  : 0.9,   enemyHealth : 80,      enemyAttack : 2*20, item : null,                   terrain : "assets/maps/terrain2.png", enemy : enemies[1]},
			{x : 80, y : 342,       sequenceTime : 5.0,   minDelay : 0.50, maxDelay  : 0.9,   enemyHealth : 90,      enemyAttack : 2*25, item : items[weaponsIndex++],   terrain : "assets/maps/terrain2.png", enemy : enemies[1]},
			{x : 135, y : 354,      sequenceTime : 5.0,   minDelay : 0.45, maxDelay  : 0.8,   enemyHealth : 100,     enemyAttack : 2*25, item : null,                   terrain : "assets/maps/terrain2.png", enemy : enemies[1]},
			{x : 164, y : 295,      sequenceTime : 5.0,   minDelay : 0.40, maxDelay  : 0.8,   enemyHealth : 200,     enemyAttack : 2*30, item : items[weaponsIndex++], terrain : "assets/maps/terrain2.png", enemy : enemies[1]},
 
			// Continent 3
			{x : 183, y : 247,      sequenceTime : 5.0,   minDelay : 0.60, maxDelay  : 1.2,   enemyHealth : 75,      enemyAttack : 3*10, item : items[armorIndex++],    terrain : "assets/maps/terrain3.png", enemy : enemies[2]},
			{x : 198, y : 172,      sequenceTime : 5.0,   minDelay : 0.57, maxDelay  : 1.2,   enemyHealth : 100,     enemyAttack : 3*10, item : null,                   terrain : "assets/maps/terrain3.png", enemy : enemies[2]},
			{x : 272, y : 185,      sequenceTime : 5.0,   minDelay : 0.54, maxDelay  : 1.0,   enemyHealth : 125,     enemyAttack : 3*15, item : items[jewelsIndex++],   terrain : "assets/maps/terrain3.png", enemy : enemies[2]},
			{x : 311, y : 139,      sequenceTime : 5.0,   minDelay : 0.51, maxDelay  : 1.0,   enemyHealth : 150,     enemyAttack : 3*15, item : null,                   terrain : "assets/maps/terrain3.png", enemy : enemies[2]},
			{x : 230, y : 104,      sequenceTime : 5.0,   minDelay : 0.48, maxDelay  : 0.8,   enemyHealth : 175,     enemyAttack : 3*20, item : items[armorIndex++],    terrain : "assets/maps/terrain3.png", enemy : enemies[2]},
			{x : 218, y : 39,       sequenceTime : 5.0,   minDelay : 0.45, maxDelay  : 0.8,   enemyHealth : 200,     enemyAttack : 3*20, item : null,                    terrain : "assets/maps/terrain3.png", enemy : enemies[2]},
			{x : 294, y : 32,       sequenceTime : 5.0,   minDelay : 0.42, maxDelay  : 0.7,   enemyHealth : 225,     enemyAttack : 3*25, item : items[jewelsIndex++],    terrain : "assets/maps/terrain3.png", enemy : enemies[2]},
			{x : 361, y : 42,       sequenceTime : 5.0,   minDelay : 0.39, maxDelay  : 0.7,   enemyHealth : 250,     enemyAttack : 3*25, item : null,                    terrain : "assets/maps/terrain3.png", enemy : enemies[2]},
			{x : 398, y : 14,       sequenceTime : 5.0,   minDelay : 0.36, maxDelay  : 0.7,   enemyHealth : 500,     enemyAttack : 3*30, item : items[weaponsIndex++],  terrain : "assets/maps/terrain3.png", enemy : enemies[2]},

			// Continent 4
			{x : 657, y : 136,      sequenceTime : 5.0,   minDelay : 0.45, maxDelay  : 1.0,   enemyHealth : 200,     enemyAttack : 4*10, item : items[jewelsIndex++],   terrain : "assets/maps/terrain4.png", enemy : enemies[3]},
			{x : 681, y : 170,      sequenceTime : 5.0,   minDelay : 0.42, maxDelay  : 1.0,   enemyHealth : 230,     enemyAttack : 4*10, item : null,                   terrain : "assets/maps/terrain4.png", enemy : enemies[3]},
			{x : 701, y : 203,      sequenceTime : 5.0,   minDelay : 0.40, maxDelay  : 0.9,   enemyHealth : 260,     enemyAttack : 4*15, item : items[weaponsIndex++],  terrain : "assets/maps/terrain4.png", enemy : enemies[3]},
			{x : 748, y : 221,      sequenceTime : 5.0,   minDelay : 0.38, maxDelay  : 0.9,   enemyHealth : 300,     enemyAttack : 4*15, item : null,                   terrain : "assets/maps/terrain4.png", enemy : enemies[3]},
			{x : 783, y : 219,      sequenceTime : 5.0,   minDelay : 0.36, maxDelay  : 0.8,   enemyHealth : 330,     enemyAttack : 4*20, item : items[armorIndex++],    terrain : "assets/maps/terrain4.png", enemy : enemies[3]},
			{x : 781, y : 254,      sequenceTime : 5.0,   minDelay : 0.34, maxDelay  : 0.8,   enemyHealth : 360,     enemyAttack : 4*20, item : null,                   terrain : "assets/maps/terrain4.png", enemy : enemies[3]},
			{x : 746, y : 262,      sequenceTime : 5.0,   minDelay : 0.32, maxDelay  : 0.7,   enemyHealth : 400,     enemyAttack : 4*25, item : items[armorIndex++],    terrain : "assets/maps/terrain4.png", enemy : enemies[3]},
			{x : 737, y : 294,      sequenceTime : 5.0,   minDelay : 0.30, maxDelay  : 0.7,   enemyHealth : 430,     enemyAttack : 4*25, item : null,                   terrain : "assets/maps/terrain4.png", enemy : enemies[3]},
			{x : 774, y : 304,      sequenceTime : 5.0,   minDelay : 0.28, maxDelay  : 0.6,   enemyHealth : 1000,    enemyAttack : 4*30, item : items[jewelsIndex++],  terrain : "assets/maps/terrain4.png", enemy : enemies[3]},

			// Boss
			{x : 760, y : 527,      sequenceTime : 5.0,   minDelay : 0.33, maxDelay  : 0.66,   enemyHealth : 2500,   enemyAttack : 150, item : items[weaponsIndex++], terrain : "assets/maps/terrain5.png", enemy : enemies[4]},
		];


		changeScene(TITLE);
	}

	public function changeScene(type : SceneType)
	{
		if(scene != null)
			removeChild(scene);

		switch(type)
		{
		case TITLE : scene = new TitleScene(this);
		case MAP : scene = new MapScene(this);
		case BATTLE : scene = new BattleScene(this, battleId, battleData);
		}

		addChild(scene);
	}
}