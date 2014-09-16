package;

import com.xenizogames.widgets.GridWidget;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import ru.stablex.ui.skins.Paint;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;

/**
 * OpenFL Boilerplate 
 * StableXUI Boilerplate
 * Grid Widget (custom widget) Boilerplate
 * @author Tony DiPerna
 */

class Main extends Sprite 
{
	var inited:Bool;

	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;

		// (your code here)
		//Create UI and attach it to root display object
		
		
		
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		
		//initialize StablexUI
        UIBuilder.init();
		
		//Start - Grid Widget Boilerplate
		//*************************************
		//Grid sizing
		var totalGridWidth = 400;
		var totalGridHeight = 200;
		var itemWidth = 100;
		var itemHeight = 100;
		
		//Create the grid
		var grid = new GridWidget(totalGridWidth, totalGridHeight, itemWidth, itemHeight);
		
		//Create some test data
		for (i in 0...120)
		{
			//Apply a random color skin to each button to show each item
			//is different
			var randomSkin = new Paint();
			randomSkin.color = Std.random(0xFFFFFF);
			
			//Create a generic button with random text
			var button = UIBuilder.create(Button, {
				text : "Hello",
				w: itemWidth,
				h: itemHeight,
				skin: randomSkin
				});
			
			//Add the widget to your grid
			grid.addWidget(button);
		
		}
		
		//redraw/organize the grid
		grid.refresh(); 
		
        Lib.current.addChild(grid);
		
		//End - Grid Widget Boilerplate
		//*************************************
		
	}
}
