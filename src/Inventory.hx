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
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.Font;

class Inventory extends Sprite
{
	var game : Game;
	var inventoryData : Array<Game.Item>;
	var itemSlotAsset = Assets.getBitmapData("assets/itemSlot.png");
	var slots = new Array<Bitmap>();
	var items = new Array<Bitmap>();

	var weaponSlot : Bitmap;
	var armorSlot : Bitmap;
	var jewelSlot : Bitmap;
	var weaponItem : Bitmap;
	var armorItem : Bitmap;
	var jewelItem : Bitmap;
	var weaponText : TextField;
	var armorText : TextField;
	var jewelText : TextField;
	
	
	public function new(game : Game)
	{
		super();

		this.game = game;
		this.inventoryData = game.inventory;
        addEventListener(MouseEvent.CLICK, mouseDoubleClick);

		//Font.registerFont(DefaultFont);
		var format = new TextFormat("Arial", 20, 0x000000);

		for(y in 0...3)
		{
			for(x in 0...7)
			{
				var itemSlot = new Bitmap(itemSlotAsset);
				itemSlot.x = x * itemSlot.width;
				itemSlot.y = y * itemSlot.height;
				addChild(itemSlot);
				slots.push(itemSlot);
			}
		}

		weaponSlot = new Bitmap(itemSlotAsset);
		weaponSlot.x = 500;
		weaponSlot.y = 0;
		addChild(weaponSlot);
		armorSlot = new Bitmap(itemSlotAsset);
		armorSlot.x = 500;
		armorSlot.y = 30;
		addChild(armorSlot);
		jewelSlot = new Bitmap(itemSlotAsset);
		jewelSlot.x = 500;
		jewelSlot.y = 60;
		addChild(jewelSlot);
		weaponText = new TextField();
		weaponText.x = 535;
		weaponText.y = 0;
		weaponText.defaultTextFormat = format;
		weaponText.embedFonts = true;
		weaponText.selectable = false;
		weaponText.text = "ATK : 10";
		addChild(weaponText);
		armorText = new TextField();
		armorText.x = 535;
		armorText.y = 30;
		armorText.defaultTextFormat = format;
		armorText.embedFonts = true;
		armorText.selectable = false;
		armorText.text = "HPs : 100";
		addChild(armorText);
		jewelText = new TextField();
		jewelText.x = 535;
		jewelText.y = 60;
		jewelText.defaultTextFormat = format;
		jewelText.embedFonts = true;
		jewelText.selectable = false;
		jewelText.text = "TMP : +0%";
		jewelText.width = 250;
		addChild(jewelText);

		var i = 0;
		for(item in inventoryData)
		{
			var itemBitmap = new Bitmap(Assets.getBitmapData(item.image));

			itemBitmap.x = slots[i].x;
			itemBitmap.y = slots[i].y;

			switch(item.type)
			{
			case WEAPON : if(item == game.weapon) {itemBitmap.x = weaponSlot.x; itemBitmap.y = weaponSlot.y; weaponItem = itemBitmap; equip(item); }
			case ARMOR : if(item == game.armor) {itemBitmap.x = armorSlot.x; itemBitmap.y = armorSlot.y; armorItem = itemBitmap; equip(item); }
			case JEWEL : if(item == game.jewel) {itemBitmap.x = jewelSlot.x; itemBitmap.y = jewelSlot.y; jewelItem = itemBitmap; equip(item); }
			}

			addChild(itemBitmap);
			items.push(itemBitmap);
			i++;
		}
	}

	public function mouseDoubleClick(event:MouseEvent)
	{
		var i = 0;
		for(item in items)
		{
			if(item.hitTestPoint(event.stageX, event.stageY, false))
			{
				switch(inventoryData[i].type)
				{
				case WEAPON :
					Actuate.tween(item, 0.25, {x : weaponSlot.x, y : weaponSlot.y});
					if(weaponItem != null)
						Actuate.tween(weaponItem, 0.25, {x : item.x, y : item.y});
					weaponItem = item;
					equip(inventoryData[i]);
				case ARMOR :
					Actuate.tween(item, 0.25, {x : armorSlot.x, y : armorSlot.y});
					if(armorItem != null)
						Actuate.tween(armorItem, 0.25, {x : item.x, y : item.y});
					armorItem = item;
					equip(inventoryData[i]);
				case JEWEL :
					Actuate.tween(item, 0.25, {x : jewelSlot.x, y : jewelSlot.y});
					if(jewelItem != null)
						Actuate.tween(jewelItem, 0.25, {x : item.x, y : item.y});
					jewelItem = item;
					equip(inventoryData[i]);
				};
			}
			i++;
		}
	}

	public function equip(item : Game.Item)
	{
		switch(item.type)
		{
		case WEAPON :
			game.weapon = item;
			game.characterAttack = game.characterAttackBase + item.value;
			weaponText.text = "ATK : "+ Std.int(game.characterAttack);
		case ARMOR :
			game.armor = item;
			game.characterHealth = game.characterHealthBase + item.value;
			armorText.text = "HPs : "+ Std.int(game.characterHealth);
		case JEWEL :
			game.jewel = item;
			game.tempoFactor = item.value;
			jewelText.text = "TMP : +"+Std.int(game.tempoFactor)+"%";
		}
	}
}