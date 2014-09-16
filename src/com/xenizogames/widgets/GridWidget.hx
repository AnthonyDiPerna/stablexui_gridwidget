/*
The MIT License (MIT)

Copyright (c) 2014 Tony DiPerna

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/**
 * Custom stablexui vertical grid widget.  Wraps the usual scroll widget and allows us to add an infinite
 * amount of items while scrolling vertically to accomodate them.  
 * 
 * Website    : http://www.xenizogames.com
 * Repository : https://github.com/XenizoGames/blog_stablexui_gridwidget
 * Blog Post  : http://www.xenizogames.com/blog/
 * @author Tony DiPerna (Xenizo Games)
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
	
	private var _numCols:Int; 				//total cols in this grid
	private var _numRows:Int; 				//total rows in this grid
	private var _currIndex:Int; 			//Current column index, this is used so we know where to add to next
	private var _itemWidth:Int;				//The width of a single list item in px
	private var _itemHeight:Int; 			//Height of a list item in px
	private var _scrollHeight:Float;		//The total height of the scrollable area (usually much larger than viewable area)
	
	/**
	 * Create a new grid.  The grid will create columns to evenly fill out the desired width.  The goal
	 * is to allow a user to add as many items as they wish and the grid will grow vertically to accomodate the
	 * items.  The grid is scrollable in the y-direction only.
	 * 
	 * @param	inWidth      - total width of the grid in pixels (viewable size)
	 * @param	inHeight     - total height of the grid in pixels (viewable size)
	 * @param	inItemWidth  - Number of columns that will fill the parameter inWidth (evenly sized)
	 * @param	inItemHeight - the y-height of a single list item in pixels
	 */
	public function new(inWidth:Float,inHeight:Float,inItemWidth:Int,inItemHeight:Int):Void 
	{	
		super();
		
		//init internal variables
		_currIndex = 0;
		_numRows = 0;
		
		//Store item size
		_itemHeight = inItemHeight;
		_itemWidth = inItemHeight;
		
		//Set viewable size for this widget (Scroll)
		w = inWidth;
		h = inHeight;
		
		//Set scrollable size for this widget
		//This is a gridwidget that scrolls vertically, so width must match viewable width
		_scrollHeight = inHeight; 		//Store this here since it will change as we add more widgets

		//Calc num of columns, columns autosize depending on viewable size
		_numCols = Math.floor(inWidth / inItemWidth);
				
		//This is the grid of items itself which will be scrolled
		//Its a horizontal box that will have a number of columns inside
		gridList = new HBox();
		gridList.widthPt = 100;
		gridList.heightPt = 100;
		//gridList.skinName = "translucent";
		
		//Listeners that allow us to change scrollbar behavior
		this.addEventListener(WidgetEvent.SCROLL_START, onScrollStart);
		this.addEventListener(WidgetEvent.SCROLL_STOP, 	onScrollStop);
		
		//Add the grid to the scroll container, this makes it the item that will be scrolled for stablexui (first child)
		this.addChild(gridList);
		
		//Setup columns in the grid
		gridSetup();
		
		//redraw/organize the grid, needed after any change in the grid
		refresh();
		
		//fade out the scrollbar
		Actuate.tween(this.vBar,2.0,{alpha:0});
	}
	
	/**
	 * When scrolling begins this event will fire, we use it to fade in the scrollbar
	 * @param	e - The widget event (unused)
	 */
	private function onScrollStart(e:WidgetEvent):Void 
	{
		//fade in vertical scrollbar
		Actuate.stop(this.vBar);
		Actuate.tween(this.vBar,1.0,{alpha:1});
	}
	
	/**
	 * When scrolling ends this event will fire, we use it to fade out the scrollbar
	 * @param	e
	 */
	private function onScrollStop(e:WidgetEvent):Void 
	{
		//fade out the scrollbar
		Actuate.stop(this.vBar);
		Actuate.tween(this.vBar,1.0,{alpha:0});
	}
	
	/**
	 * Setup the grid with the desired number of columns.  The column width is determined by the width of a grid list item
	 */
	private function gridSetup():Void 
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
	 * Add an item to the end of the grid list, this will find the last column with an item and 
	 * add the item to the next column (i.e. next row item, or start a new row)
	 * @param	inWidget - the item to add
	 */
	public function addToEndOfGrid(inWidget:Widget):Void
	{
		addWidget(inWidget);
		resortGrid();
	}
	
	/**
	 * Add an item to the start of the grid list, this adds an item
	 * in the very first row/column position and shifts everything else over
	 * by one column position (possibly into a new row)
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
	 * Add an item to the middle of the grid list, this finds an approx. 
	 * middle position of the grid and adds the item there moving all items after
	 * the middle to shift over by one column position (possibly into a new row)
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
		//Error Checking
		if (inWidget == null)
		{
			throw("Error: null parameter, please verify widget for removal");
		}
		
		//Make sure we actually have this widget in the grid, if we don't then dont do anything
		if (inWidget.parent != gridList)
		{
			throw("Error: trying to remove a widget that doesn't belong to this grid, real parent is: " + inWidget.parent);
		}
		
		//remove the item from the list
		inWidget.parent.removeChild(inWidget);
		resortGrid();
	}
	
	/**
	 * Add an item to the end of the grid list
	 * @param	inWidget - the item to add
	 * @note    Does not cause a grid resort
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
	
	/**
	 * When the widget is refreshed we will update extra data necessary for this grid
	 */
	override public function refresh():Void 
	{
		//make sure we don't have any half complete rows...if we do refresh the total scrollable height
		//to make sure we can see all rows (even uncomplete ones)
		checkForUnfinishedRows();
		
		//Set the height of the list based on the number of rows we have, we need this calculation
		//to make the scrollable area fit the num of rows (that can change dynamically), without this 
		//the scrollable area is "off" and doesnt work very cleanly
		gridList.h = getScrollHeight(_numRows+1,_itemHeight);		//+1 since arrays are 0 based, but viewable display is 1 based (need to see first row)
		
		//Refresh each column individually to make sure layout is clean
		for (c in columns)
		{
			c.refresh();
		}
		
		//stablexui widget refresh behavior
		super.refresh();
	}
	
	/**
	 * Helper function to modify scrollable height based on if a row is only partially filled
	 */
	private inline function checkForUnfinishedRows():Void
	{
		//one more row to make sure we have enough to see everything
		//this is needed since we started a new row but didnt finish it
		//When currIndex > 0 it means the next free column is NOT the first column
		if (_currIndex > 0)
		{
			_numRows++;
		}
	}
	
	/**
	 * Resort the grid.  
	 * This is required when adding or removing objects into the middle or start of the grid to keep the layout correct
	 * @note - Try to call this only when needed for performance reasons
	 */
	private function resortGrid():Void
	{
		//Create flat array as temporary storage doing resort
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
		//We basically build a flat array from each columns list of children to maintain order, then re-sort the flat array
		//and break back into columns
		for (z in 0...totalChildren)
		{
			//loop through each column
			for (col in columns)
			{
				//Make sure the column has items in it
				if (col.numChildren > 0)
				{
					//get the item currently at the top of the column
					var item:DisplayObject = col.getChildAt(0);
					
					//Make sure we are not grabbing some kind of background object
					if (Std.is(item, Widget))
					{
						//found an item - store it an the flat array
						items.push(item);
						
						//remove item from its old column
						item.parent.removeChild(item);
					}
				}
			}
		}
		
		//Reset internal class variables since we are resorting
		_currIndex = 0;
		_numRows = 0;
		
		//Add all items back to the columns from the flat array
		for (i in items)
		{
			columns[_currIndex].addChild(i);
			
			_currIndex++;
			
			//roll back to first column
			if (_currIndex >= _numCols)
			{
				_currIndex = 0;
				_numRows++;
			}
		}
		
		//redraw the grid and all child widgets
		refresh();
	}
	
	/**
	 * Get the total scrollable height of the grid of objects
	 * @param	inNumRows - The total grid rows in our layout
	 * @param	inHeight  - The height of a single grid item
	 * @return	Total Scrollable Height
	 */
	private inline function getScrollHeight(inNumRows:Int,inHeight:Int):Int
	{
		//guard for min condition (only 1 row)
		return Math.floor(Math.max(inNumRows * inHeight,_scrollHeight));
	}
	
	/**
	 * The number of columns we support in our grid is based on total grid width and number of columns desired (which is precalculated)
	 * @param	inNumCols - The number of columns we will break the list of items into
	 * @return  An array of floats specifying the column layout in stablexui form 
	 * @example Example return value - [.33,..33,.33] 3 column layout with each column using 33% of the total grid width
	 */
	private function getColumnArrayForGrid(inNumCols:Int):Array<Float>
	{
		//Verify parameters
		if (inNumCols <= 1)
		{
			throw("Error: invalid number of columns, need at least 2 columns for a valid grid layout");
		}
		
		var cols = new Array<Float>();
		var perc = 1 / inNumCols;		//Even percent for columns
		
		//add a new array entry for each column
		for (i in 0...inNumCols)
		{
			cols.push(perc);
		}
		
		return cols;
	}
}