$(document).ready(function(){
var kpi_data = new Array();
var kpi_dates = new Array();
var axes = new Array();
var axesByLifecycle = new Array();
var types = new Array();
var categories = new Array();
var chart_objects = new Array();

// INIT
download_json = function()
{
	var jqxhr = $.getJSON('data/data.json?callback=?', function(data) {});
	jqxhr.complete(function(data){ 
		var obj = $.parseJSON(data.responseText);
		// Dates
		kpi_dates = obj["date"];
		// Axes
		axes = obj["axe"];
		// Types
		types = obj["type"];
		// Axes by lifecycle
		$.each(obj["axe_by_lifecycle"], function(key,value) {
			axesByLifecycle[value.id] = value.axes;
		});

		// Charts data
		for (var i = 0; i< obj["data"].length; i++)
		{
			$.each(obj["data"][i], function(key, value) {
				kpi_data[key] = value;
			});
		}
		init_charts();
	});
}

init_charts = function()
{
	$.each(kpi_dates, function(key, value) {
		current_date = value["month"]+"_"+value["year"];
		categories.push(current_date);
	});
	$.each(types, function(key,value) {
		$("#charts").append('<div id="type_' + value["id"] + '" style="min-width: 400px; height: 400px; margin: 0 auto"></div>');
		chart_objects["type_" + value["id"]] = generate_kpi_chart("type_" + value["id"], value["title"], categories, [0]);
	});	
	$.each(axes, function(key,value) {
		$("#charts").append('<div id="axe_' + value["id"] + '" style="min-width: 400px; height: 400px; margin: 0 auto"></div>');		
		chart_objects["axe_" + value["id"]] = generate_kpi_chart("axe_" + value["id"], value["title"], categories, [0]);	
	});	
}


// Called when change in list
generate_kpi = function()
{
	$("#kpi_loading").show("fast",function() {
		reset_charts();
	
		type_id = $("#choose_type").val();
		lifecycle_id = $("#choose_lifecycle").val();
		workstream = ""+$("#choose_workstream").val();
		milestone = $("#choose_milestone").val();
	
		// Data filter : For each month, filter data with lifecycle/workstream/milestone
		var value_results = new Array();
	
		$.each(kpi_dates, function(key, value) {
			current_date = value["month"]+"_"+value["year"];
			current_chart_data = kpi_data[current_date];
			value_results[current_date] = new Array();
			if(current_chart_data != null)
			{
				$.each(current_chart_data, function(chart_data_key, chart_data_value) {
					lifecycle_ok = false;
					if( ((lifecycle_id == 0) || (parseInt(lifecycle_id) == parseInt(chart_data_value["lifecycle"]))) && (chart_data_value["lifecycle"] != "") )
					{
						lifecycle_ok = true;
					}
			
					workstream_ok = false;
					if( ((workstream == 0) || (workstream.toLowerCase() == chart_data_value["workstream"].toLowerCase())) && (chart_data_value["workstream"] != null) )
					{
						workstream_ok = true;
					}
			
					milestone_ok = false;			
					if( ((milestone == 0) || (parseInt(milestone) == parseInt(chart_data_value["milestone"]))) && (chart_data_value["milestone"] != "") )
					{
						milestone_ok = true;
					}			
		
					if((lifecycle_ok) && (workstream_ok) && (milestone_ok))
					{
						value_results[current_date].push(chart_data_value);
					}
				});
			}	
		});	
	
		// init chart arrays
		var charts_values_not_cal = new Array();
		$.each(types, function(key,value) {
			charts_values_not_cal["type_"+value["id"]] = new Array();
		});	
		$.each(axes, function(key,value) {
			$.inArray(value["id"], axesByLifecycle[lifecycle_id])
			{
				charts_values_not_cal["axe_"+value["id"]] = new Array();
			}
		});
	
		// For each month, add sum and count of different types and axes
		var last_month = 0;
		$.each(kpi_dates, function(key, value) 
		{
			current_date = value["month"]+"_"+value["year"];
			current_chart_data = value_results[current_date];
		
			$.each(types, function(type_key,type_value) {
				charts_values_not_cal["type_"+type_value["id"]][current_date] = new Array();
				charts_values_not_cal["type_"+type_value["id"]][current_date]["sum"] = 0;
				charts_values_not_cal["type_"+type_value["id"]][current_date]["count"] = 0;
			});
			$.each(axes, function(axe_key,axe_value) {
				charts_values_not_cal["axe_"+axe_value["id"]][current_date] = new Array();
				charts_values_not_cal["axe_"+axe_value["id"]][current_date]["sum"] = 0;
				charts_values_not_cal["axe_"+axe_value["id"]][current_date]["count"] = 0;
			});
				
			// Format data in sum and count
			$.each(current_chart_data, function(chart_data_key, chart_data_value) {
				// By type
				$.each(types, function(type_key,type_value) {
					if(chart_data_value["type"] == type_value["id"])
					{
						charts_values_not_cal["type_"+type_value["id"]][current_date]["sum"] += helper_format_float(chart_data_value["sum"]);
						charts_values_not_cal["type_"+type_value["id"]][current_date]["count"] += helper_format_float(chart_data_value["count"]);
					}
				});
				// By Axes
				$.each(axes, function(axe_key,axe_value) {
					$.inArray(axe_value["id"], axesByLifecycle[lifecycle_id])
					{
						if(chart_data_value["axe"] == axe_value["id"])
						{
							charts_values_not_cal["axe_"+axe_value["id"]][current_date]["sum"] += helper_format_float(chart_data_value["sum"]);
							charts_values_not_cal["axe_"+axe_value["id"]][current_date]["count"] += helper_format_float(chart_data_value["count"]);
						}
					}
				});		
			});
		});
	
		// Hide axe in function of lifecycle
		show_lifecycle_axes(lifecycle_id);
		
		if(type_id == 1)
		{
			kpi_calcul_classic(charts_values_not_cal);
		}
		else
		{
			kpi_calcul_cumul(charts_values_not_cal);
		}
	});
} 

kpi_calcul_classic = function(charts_data)
{
	for(var chart_key in charts_data)
	{
		serie = new Array();
		for(var date_key in charts_data[chart_key])
		{
			if(charts_data[chart_key][date_key]["count"] > 0)
			{
				serie.push(charts_data[chart_key][date_key]["sum"]/charts_data[chart_key][date_key]["count"]);
			}
			else
			{
				serie.push(0);
			}
		}
		// Set chart
		if(serie.length == categories.length)	
		{
			//chart_objects[chart_key].setTitle({text: chart_objects[chart_key].title.text + " - " +  $("#choose_milestone :selected").text() });
			// Add series
			kpi_chart_add_serie(chart_objects[chart_key],serie);
		}
	}
	
	$("#kpi_loading").hide();
}

kpi_calcul_cumul = function(charts_data)
{
	for(var chart_key in charts_data)
	{
		serie = new Array();
		var sum_save = 0;
	    var count_save = 0;
	    var last_avg = -1;
	
		for(var date_key in charts_data[chart_key])
		{
			if(last_avg == -1)
			{
				var temp_avg = 0;
				if(charts_data[chart_key][date_key]["count"] > 0)
				{
					temp_avg = charts_data[chart_key][date_key]["sum"] / charts_data[chart_key][date_key]["count"];
					last_avg = temp_avg;
					serie.push(temp_avg);
				}
				else
				{
					last_avg = 0;
					serie.push(0);
				}
			}
			else if(charts_data[chart_key][date_key]["sum"] == 0)
			{
				serie.push(last_avg);
			}
			else if(last_avg == 0)
			{
				var temp_avg = 0;
				if(charts_data[chart_key][date_key]["count"] > 0)
				{
					temp_avg = charts_data[chart_key][date_key]["sum"] / charts_data[chart_key][date_key]["count"];
					last_avg = temp_avg;
					serie.push(temp_avg);
				}
				else
				{
					last_avg = 0;
					serie.push(0);
				}
			}
			else
			{
				var temp_avg = sum_save + charts_data[chart_key][date_key]["sum"];
				var temp_count = count_save + charts_data[chart_key][date_key]["count"];
				if(temp_count > 0)
				{
					serie.push(temp_avg/temp_count);
					last_avg = temp_avg/temp_count;
				}
				else
				{
					serie.push(0);
					last_avg = 0;
				}
			}
			sum_save += charts_data[chart_key][date_key]["sum"];
			count_save += charts_data[chart_key][date_key]["count"];
		}
		// Set chart
		if(serie.length == categories.length)	
		{
			// Add series
			kpi_chart_add_serie(chart_objects[chart_key],serie);
		}
	}	
	
	$("#kpi_loading").hide();
}

show_lifecycle_axes = function(lifecycle_id)
{
	$.each(axes, function(axe_key,axe_value) 
	{
		if ($.inArray(parseInt(axe_value["id"]), axesByLifecycle[lifecycle_id]) > 0)
		{
			$("#axe_"+axe_value["id"]).show();			
		}
		else
		{
			$("#axe_"+axe_value["id"]).hide();
		}
	});
}

reset_charts = function()
{
	for(var chart_key in chart_objects)
	{
		while(chart_objects[chart_key].series.length > 0)
		    chart_objects[chart_key].series[0].remove(true);		
	}
	
}

helper_format_float = function(floatValue)
{
	if((floatValue == null) || (floatValue == "0"))
	{
		return 0;
	}
	return parseFloat(floatValue);
}

// Exec
download_json();

$("#export").click(function() {
	
	var chartExportArray = new Array();
	for(var chartObj in chart_objects)
	{
		if($(chart_objects[chartObj].renderTo).is(":visible"))
	 	{
			chartExportArray.push(chart_objects[chartObj]);
		}
	}
	/*Highcharts.exportCharts(chartExportArray,{
		            type: 'image/jpeg',
		            filename: 'kpi_export'
	});*/
	Highcharts.exportCharts(chartExportArray,{
		            type: 'application/pdf',
		            filename: 'kpi_export'
	});
});

});
