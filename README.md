blog_stablexui_gridwidget
=========================

OpenFL Stablexui GridWidget Implementation

To use GridWidget.hx do the following:

### Create the grid ###

<pre>
		//Create the grid
		var grid = new GridWidget(totalGridWidth, totalGridHeight, itemWidth, itemHeight);
</pre>

### Add any number of StableXUI Widgets 

<pre>
		//Create some test data
		for (i in 0...120)
		{
			//Add the widget to your grid
			grid.addWidget(new ru.stablex.ui.widgets.Button());
		}
</pre>

### Refresh the grid after you've added items ###
<pre>
		//redraw/organize the grid
		grid.refresh(); 
</pre>		

### Display the grid ###
<pre>        
Lib.current.addChild(grid);
</pre>

### Add an item dynamically to the front of the grid  ###

<pre>
//This button will be in the first row and first column of the grid
grid.addToStartOfGrid(new ru.stablex.ui.widgets.Button())
</pre>

### Add an item to the end of the grid ###

<pre>
//This button will be in the last row and last column of the grid
grid.addToEndOfGrid(new ru.stablex.ui.widgets.Button())
</pre>

### Add an item to the about the middle of the grid ###

<pre>
//This button will be in the mid row and first column of the grid
grid.addToMiddleOfGrid(new ru.stablex.ui.widgets.Button())
</pre>

### Remove an item from the grid  ###
<pre>
//This button will be in the mid row and first column of the grid
grid.removeWidget(new ru.stablex.ui.widgets.Button())
</pre>

### Performance Tips ###

- Using `addWidget(x)` only adds the data to the data structure of the grid, it doesn't update the display.
     -  Use this when adding multiple widgets, calling `grid.refresh()` afterwards to update the display only once.
- Using `addToEndOfGrid(x)`, `addToStartOfGrid(x)`, `addToMidOfGrid(x)` or `removeWidget(x)` causes an immediate display update, meaning if you do this repeatedly performance will suffer...although you'll probably only notice it if your grid list has many items (> 100) or the grid items are complicated widgets.
