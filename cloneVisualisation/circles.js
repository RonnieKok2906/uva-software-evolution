function loadContent(projectName, type)
{

	var margin = 20,
	diameter = 960;

	var color = d3.scale.linear()
	.domain([-1, 5])
	.range(["hsl(152,80%,80%)", "hsl(228,30%,40%)"])
	.interpolate(d3.interpolateHcl);

	var pack = d3.layout.pack()
	.padding(2)
	.size([diameter - margin, diameter - margin])
	.value(function(d) { return d.size; })

	var jsonFile = "projects/" + projectName + "/type1.json";

	createMenu(type, projectName);

	if (type != "")
	{
		jsonFile = "projects/" + projectName + "/" + type + ".json";
	}

	d3.json("" + jsonFile, function(error, root) {
		
		if (error)
		{			
			d3.select("body")
			.style("background", color(-1))
			.append("p")
			.text("No valid information available for " + type + "-clones.");
		}
		
		if (error) throw error;

		createKey();
		createMetaDataDiv(root);
		
		var svg = d3.select("body").append("svg")
		.attr("width", diameter)
		.attr("height", diameter)
		.append("g")
		.attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")");

		var focus = root,
		nodes = pack.nodes(root),
		view;
		
		var tooltip = createTooltip();
		
		var selectedCloneClass = "";

		function zoomIfNeeded(d)
		{
			if (d.children)
			{
				zoom(d); 
				d3.event.stopPropagation();		
			}		
		}

		function deselectAllSelectedNodes(d)
		{
			if (!d.children)
			{
				d3.selectAll("circle")
				.filter(function(d){ return !d.children && d.cloneclass != "-1"; })
				.attr("style", "fill:white");
			}				
			
		}

		function selectNodesOfTheSameCloneClass(d)
		{
			if (d.cloneclass == "-1")
			{
				return;
			}
			
			d3.selectAll(".node--leaf" + d.cloneclass).attr("style", "fill:blue");			
			
			return tooltip.style("visibility", "visible").html(d.codeFragment);
		}

		function giveStrokeIfNeeded(it, d)
		{
			if (d3.select(it).classed("node--leaf" + d.cloneclass) && !d3.select(it).classed("node--leaf-1"))
			{
				d3.select(it).style({"stroke":"red", "stroke-width" : "3px"});
			}
		}

		var circle = svg.selectAll("circle")
		.data(nodes)
		.enter().append("circle")
		.attr("class", function(d) { return d.parent ? d.children ? "node" : "test node node--leaf" + d.cloneclass : "node node--root"; })
		.style({"fill": function(d) { return d.children ? color(d.depth) : (d3.select(this).classed("node--leaf-1") ? "#AAA" : rainbow(root.numberOfCloneClasses, d.cloneclass - 1)); }})
		.on("click", function(d) { if (focus !== d){ zoomIfNeeded(d); deselectAllSelectedNodes(d); selectNodesOfTheSameCloneClass(d); giveStrokeIfNeeded(this, d); }});

	  
		var text = svg.selectAll("text")
		.data(nodes)
		.enter().append("text")
		.attr("class", "label")
		.style("fill-opacity", function(d) { return d.parent === root ? 1 : 0; })
		.style("display", function(d) { return d.parent === root ? "inline" : "none"; })
		.text(function(d) { return d.name; });

		var node = svg.selectAll("circle,text");

		d3.select("body")
		.style("background", color(-1))
		.on("click", function() { zoom(root); });

		zoomTo([root.x, root.y, root.r * 2 + margin]);

		function zoom(d) {
			var focus0 = focus; focus = d;

			var transition = d3.transition()
			.duration(d3.event.altKey ? 7500 : 750)
			.tween("zoom", function(d) {
				var i = d3.interpolateZoom(view, [focus.x, focus.y, focus.r * 2 + margin]);
				return function(t) { zoomTo(i(t)); };
			});

			transition.selectAll("text")
			.filter(function(d) { return d.parent === focus || this.style.display === "inline"; })
			.style("fill-opacity", function(d) { return d.parent === focus ? 1 : 0; })
			.each("start", function(d) { if (d.parent === focus) this.style.display = "inline"; })
			.each("end", function(d) { if (d.parent !== focus) this.style.display = "none"; });
		}

		function zoomTo(v) {
			var k = diameter / v[2]; view = v;
			node.attr("transform", function(d) { return "translate(" + (d.x - v[0]) * k + "," + (d.y - v[1]) * k + ")"; });
			circle.attr("r", function(d) { return d.r * k; });
		}
	});

	d3.select(self.frameElement).style("height", diameter + "px");
};

function createKey()
{
	var keyContainer = d3.select("body")
	.append("div")
	.attr("class", "keyContainer");  
  
	title = keyContainer.append("h3")
	.text("Key");
  
	key1 = keyContainer
	.append("div")
	.attr("class", "key")
	.attr("id", "key1");
    
	value1 = keyContainer
	.append("p")
	.attr("class", "value")
	.text("Clone");

	key2 = keyContainer
	.append("div")
	.attr("class", "key")
	.attr("id", "key2");
 	  
	value2 = keyContainer
	.append("p")
	.attr("class", "value")
	.text("Clone in CloneClass");

	key3 = keyContainer
	.append("div")
	.attr("class", "key")
	.attr("id", "key3");
  
	value3 = keyContainer
	.append("p")
	.attr("class", "value")
	.text("Selected Clone");

	key4 = keyContainer
	.append("div")
	.attr("class", "key")
	.attr("id", "key4");
  
	value4 = keyContainer
	.append("p")
	.attr("class", "value")
	.text("non-cloned code"); 
	
	key5 = keyContainer
	.append("div")
	.attr("class", "key")
	.attr("id", "key5");
  
	value5 = keyContainer
	.append("p")
	.attr("class", "value")
	.text("Package or CompilationUnit"); 
	
}

function createTooltip()
{
	var tooltip = d3.select("body")
	.append("div")
	.attr("class", "tooltip")
	.style("visibility", "hidden");
	
	return tooltip;
}


function createMenu(typeString, projectName)
{
	var menuContainer = d3.select("body")
	.append("div")
	.attr("id", "menuContainer");
	
	var unorderedList = menuContainer.append("ul")
	
	var li1 = unorderedList.append("li").append("a")
    .attr("href", "/?" + projectName +"?type1")
    .html("Type 1");
	
	if (typeString == "" || typeString == "type1")
	{
		li1.attr("class", "selected");
	}
	
	
  	var li2 = unorderedList.append("li").append("a")
    .attr("href", "/?" + projectName +"?type2")
    .html("Type 2");
	
	if (typeString == "type2")
	{
		li2.attr("class", "selected");
	}
	
  	var li3 = unorderedList.append("li").append("a")
    .attr("href", "/?" + projectName +"?type3")
    .html("Type 3");
	
	if (typeString == "type3")
	{
		li3.attr("class", "selected");
	}
	
  	var li4 = unorderedList.append("li").append("a")
  	.html("Rainbow view")
	.on("click", function(d){ window.location.reload(true); });
  
	
	menuContainer.append("h1").html("Project: " + projectName);
}

function createMetaDataDiv(root)
{
	var metaDataDiv = d3.select("body")
	.append("div")
	.attr("id", "metaDataDiv");
	
	metaDataDiv.append("h3")
	.html("Metadata");
	
	metaDataDiv.append("p")
	.html("Number of Clone Classes: " + root.numberOfCloneClasses);
	
	metaDataDiv.append("p")
	.html("Minimum number of Lines: " + root.minumumNumberOfLines);
}