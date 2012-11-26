$(document).ready(function(){
var kpi_data = new Array();
var kpi_dates = new Array();
var axes = new Array();
var types = new Array();

download_json = function()
{
	var jqxhr = $.getJSON('http://0.0.0.0:3000/data/kpi_export/data/data.json', function(data) {});
	jqxhr.complete(function(data){ 
		var obj = $.parseJSON(data.responseText);
		// Dates
		kpi_dates = obj["date"];
		// Axes
		axes = obj["axe"];
		// Types
		types = obj["type"]
		
		// Charts data
		for (var i = 0; i< obj["data"].length; i++)
		{
			$.each(obj["data"][i], function(key, value) {
				kpi_data[key] = value;
			});
		}
		
	});
}

generate_kpi = function()
{
	type_id = $("#choose_type").val();
	lifecycle_id = $("#choose_lifecycle").val();
	workstream = ""+$("#choose_workstream").val();
	milestone = $("#choose_milestone").val();
	
	// Data filter
	var charts_values = new Array();
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
	
	// init
	
	$.each(types, function(key,value) {
		charts_values["type_"+key] = new Array();
	});	
	$.each(axes, function(key,value) {
		charts_values["axe"+key] = new Array();
	});
	
	var last_month = 0;
	$.each(kpi_dates, function(key, value) {
		current_date = value["month"]+"_"+value["year"];
		current_chart_data = value_results[current_date];
		
		var sum = new Array();
		$.each(types, function(type_key,type_value) {
			sum["types_"+type_value["id"]] = 0;
		});
		var count = new Array();
		$.each(axes, function(axe_key,axe_value) {
			sum["axe_"+axe_value["id"]] = 0;
		});
		
		$.each(current_chart_data, function(chart_data_key, chart_data_value) {
	
			// By type
			$.each(types, function(type_key,type_value) {
				if(chart_data_value["type"] == type_value["id"])
				{
					sum["types_"+type_value["id"]] += helper_format_float(chart_data_value["sum"]);
					count["types_"+type_value["id"]] += helper_format_float(chart_data_value["count"]);
				}
			});
	
			// By Axes
			$.each(axes, function(axe_key,axe_value) {
				if(chart_data_value["axe"] == axe_value["id"])
				{
					sum["axes_"+axe_value["id"]] += helper_format_float(chart_data_value["sum"]);
					count["axes_"+axe_value["id"]] += helper_format_float(chart_data_value["count"]);
				}
			});		
		});
		//cacul_data(sum,count);
		console.log(sum);
	});
	
//	console.log(value_results);
} 

cacul_data = function(calculType,value,count,lastValue)
{
	
}

helper_format_float = function(floatValue)
{
	console.log(floatValue);
	if((floatValue == null) || (floatValue == "0"))
	{
		return 0;
	}
	return parseFloat(floatValue);
}
// Exec
download_json();

});
