blog_stablexui_gridwidget
=========================

OpenFL Stablexui GridWidget Implementation

To use GridWidget.hx do the following:

### Create the grid ###

<pre>
		//Create the grid
		var grid = new GridWidget(totalGridWidth, totalGridHeight, itemWidth, itemHeight);
</pre>

### Add any number of StableXUI Widget(s) ### 

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
