package;

import motion.Actuate;
import openfl.display.Sprite;
import openfl.Assets;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;

class Gauge extends Sprite
{
    var gaugeFill = new Sprite();
	
	public function new()
	{
		super();

        var gaugeAsset = Assets.getBitmapData("assets/gauge.png");
        var gaugeFillAsset = Assets.getBitmapData("assets/gaugeFill.png");

		var gaugeBitmap = new Bitmap(gaugeAsset);
    	gaugeBitmap.x = -gaugeBitmap.width/2;
    	gaugeBitmap.y = -gaugeBitmap.height/2;
    	addChild(gaugeBitmap);

    	gaugeFill.y = 20;
    	addChild(gaugeFill);

		var gaugeFillBitmap = new Bitmap(gaugeFillAsset);
    	gaugeFillBitmap.x = -gaugeFillBitmap.width/2;
    	gaugeFillBitmap.y = -gaugeFillBitmap.height;
        
		gaugeFill.addChild(gaugeFillBitmap);
	}

	public function setValue(value : Float)
	{
		gaugeFill.scaleY = value;
	}
}