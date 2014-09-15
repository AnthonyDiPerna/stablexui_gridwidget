/**
 * ...
 * @author Tony DiPerna
 */

package com.xenizogames.widgets;
import flash.display.DisplayObject;
import motion.Actuate;
import ru.stablex.ui.events.WidgetEvent;
import ru.stablex.ui.layouts.Column;
import ru.stablex.ui.widgets.HBox;
import ru.stablex.ui.widgets.Scroll;
import ru.stablex.ui.widgets.VBox;
import ru.stablex.ui.widgets.Widget;

class GridWidget extends Scroll
{
	public var gridList:ru.stablex.ui.widgets.HBox;			//container that holds all columns and will be scrolled
	public var columns:Array<ru.stablex.ui.widgets.VBox>; 	//The data grid columns
	
	private var _numCols:Int; 		//total cols in this grid
	private var _numRows:Int; 		//total rows in this grid
	private var _currIndex:Int; 	//Current column index, this is used so we know where to add to next
	private var _itemHeight:Int; 	//Height of a list item in px
	private var _scrollHeight:Float;
	private var _itemWidth:Int;
	
	/**
	 * Create a new grid.  The grid will create columns to evenly fill out the desired width.
	 * @param	inWidth      - total width of the grid in pixels
	 * @param	inHeight     - total height of the grid in pixels
	 * @param	inItemWidth  - Number of columns that will fill the parameter inWidth (evenly sized)
	 * @param	inItemHeight - the y-height of a single list item in pixels
	 */
	public function new(inWidth:Float,inHeight:Float,inItemWidth:Int,inItemHeight:Int):Void 
	{	
		super();
		
		_itemHeight = inItemHeight;
		_itemWidth = inItemHeight;
		
		/*
		vBar.slider.skinName 					= 'AIVOrange';
		vBar.slider.widthPt       				= 70;
		vBar.slider.leftPt       				= 15;
		vBar.h									= inHeight;
		vBar.right								= 5;
		vBar.top								= 0;
		vBar.vertical							= true;
		hScroll      							= false;
		hBar.visible 							= false;
		vBar.w       							= Const.UI_VERTICAL_SCROLL_WIDTH;
		vBar.skinName							= 'AIVBlueTranslucent';
		*/
		this.addEventListener(WidgetEvent.SCROLL_START, onScrollStart);
		this.addEventListener(WidgetEvent.SCROLL_STOP, 	onScrollStop);
		
		//Store desired num of columns, from there we will autosize them depending on current screen size
		_numCols = Math.floor(inWidth / inItemWidth);
		
		_currIndex = 0;
		_numRows = 0;
		
		w = inWidth;
		h = inHeight;
		_scrollHeight = inHeight; 		//Store this here since it will change as we add more widgets

		
		//This is the grid of items itself
		gridList = new HBox();
		gridList.widthPt = 100;
		gridList.heightPt = 100;
		//gridList.skinName = "translucent";
		
		//Add the grid to the scroll container
		this.addChild(gridList);
		
		//Setup columns in the grid
		gridSetup();
		
		//redraw/organize the grid, needed after any change in the grid
		refresh();
		
		//fade out
		Actuate.tween(this.vBar,2.0,{alpha:0});
	}
	
	private function onScrollStart(e:WidgetEvent):Void 
	{
		Actuate.stop(this.vBar);
		Actuate.tween(this.vBar,1.0,{alpha:1});
	}
	private function onScrollStop(e:WidgetEvent):Void 
	{
		Actuate.stop(this.vBar);
		Actuate.tween(this.vBar,1.0,{alpha:0});
	}
	/**
	 * Setup the grid with the desired number of columns.  The column width is determined by the width passed into the constructor of this GridWidget
	 */
	function gridSetup():Void 
	{
		//Dynamically create columns that fit width of screen
		var columnLayout = new Column();
		var cols = getColumnArrayForGrid(_numCols); //columns needed by stableXUI
		
		columnLayout.cols = cols;
		gridList.layout = columnLayout;
		gridList.applyLayout();
		
		columns = new Array<VBox>();
		
		//add a widget for each column and store columns
		for (n in 0..._numCols)
		{
			var b = new VBox();
			b.childPadding = 5;
			b.name = "col" + Std.string(n + 1);
			b.align = "center,top"; //must be top or else when removing/adding to the columns height gets messed up
			gridList.addChild(b);
			columns.push(b);
		}
	}
	/**
	 * Add an item to the end of the grid list
	 * @param	inWidget - the item to add
	 */
	public function addToEndOfGrid(inWidget:Widget):Void
	{
		addWidget(inWidget);
		resortGrid();
	}
	/**
	 * Add an item to the start of the grid list
	 * @param	inWidget - the item to add
	 * @note    Causes a grid re-sort
	 */
	public function addtoStartOfGrid(inWidget:Widget):Void
	{
		//add to start of grid then resort to look nice
		columns[0].addChildAt(inWidget, 1);
		resortGrid();
	}
	/**
	 * Add an item to the middle of the grid list
	 * @param	inWidget - the item to add
	 * @note    Causes a grid re-sort
	 */
	public function addtoMiddleOfGrid(inWidget:Widget):Void
	{
		//add item to middle (approx.) of grid then resort to look nice
		var firstCol = columns[0];
		var insertPos = firstCol.numChildren > 0 ? Math.floor(firstCol.numChildren/2) : 0; //half way down first col
		columns[0].addChildAt(inWidget, insertPos);
		resortGrid();
	}
	/**
	 * Remove an item from anywhere in the grid
	 * @param	inWidget - the widget to remove, if the gridlist is not the parent of this then nothing happens
	 * @note	Causes a grid re-sort
	 */
	public function removeWidget(inWidget:Widget):Void
	{
		//Make sure we actually have this widget in the grid, if we don't then dont do anything
		//if (inWidget.parent != gridList) return;
		
		//remove the item from the list
		inWidget.parent.removeChild(inWidget);
		resortGrid();
	}
	/**
	 * Add an item to the end of the grid list
	 * @param	inWidget - the item to add
	 */
	public function addWidget(inWidget:Widget):Void
	{
		//Add to the next column
		columns[_currIndex].addChild(inWidget);
		
		//increment so next add goes to next column
		_currIndex++;
		
		//make sure we roll back to first column when exceeding num cols
		if (_currIndex >= _numCols)
		{
			_currIndex = 0;
			_numRows++;
		}
	}
	function checkForUnfinishedRows():Void
	{
		//one more row to make sure we have enough to see everything
		//this is needed since we started a new row but didnt finish it
		if (_currIndex > 0)
		{
			_numRows++;
		}
	}
	/**
	 * Resort the grid.  This is required when adding or removing objects into the middle or start of the grid.  
	 */
	private function resortGrid():Void
	{
		//we know how the scroll box is created, so use that knowledge to create data on the fly
		var items = new Array<DisplayObject>();
		var totalChildren = 0;
		
		//find column with most stuff in it...we need to check this because items can be added/removed from the grid
		for (c in columns)
		{
			if (totalChildren < c.numChildren)
			{
				totalChildren = c.numChildren;
			}
		}
		
		//loop through all columns and get the lowest index child (at the top in y-dir) to preserve current order of grid items
		for (z in 0...totalChildren)
		{
			//loop through each column
			for (col in columns)
			{
				//trace("column: " + col.name + " : " + col.numChildren);
				if (col.numChildren > 0)
				{
					var item:DisplayObject = col.getChildAt(0);
					if (Std.is(item, Widget))
					{
						//found an item store it an the array
						items.push(item);
						
						//remove from its old column
						item.parent.removeChild(item);
					}
				}
			}
		}
		
		//Reset since we are resorting
		_currIndex = 0;
		_numRows = 0;
		
		//Add all items back to the columns
		for (i in items)
		{
			columns[_currIndex].addChild(i);
			//trace("col" + Std.string(currIndex));
			
			_currIndex++;
			//roll back to first column
			if (_currIndex >= _numCols)
			{
				_currIndex = 0;
				_numRows++;
			}
		}
		
		refresh();
	}
	
	/**
	 * Get the total scrollable height of the grid of objects
	 * @param	inNumRows
	 * @param	inHeight
	 * @return
	 */
	private inline function getScrollHeight(inNumRows:Int,inHeight:Int):Int
	{
		//guard for min condition (only 1 row)
		return Math.floor(Math.max(inNumRows * inHeight,_scrollHeight));
	}
	
	override public function refresh():Void 
	{
		//make sure we don't have any half complete rows...if we do refresh
		checkForUnfinishedRows();
		
		gridList.h = getScrollHeight(_numRows+1,_itemHeight);
		
		for (c in columns)
		{
			c.refresh();
		}
		
		super.refresh();
	}
	//the number of columns we support in our grid is based on current screen resolution and the desired grid width
	private function getColumnArrayForGrid(inNumCols:Int):Array<Float>
	{
		var cols = new Array<Float>();
		var perc = 1 / inNumCols;
		
		for (i in 0...inNumCols)
		{
			cols.push(perc);
		}
		
		if (cols.length < 2)
		{
			throw("error...not enough space to make columns correctly...layout is borked!");
		}
		return cols;
	}
}