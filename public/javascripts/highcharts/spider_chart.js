// Spider charts
function calculAverage()
{
	// Get all table of class pm_type_tab (PM TYPE)
	var pmTypeList = jQuery(".pm_type_tab");
	for (var i=0; i < pmTypeList.length; i++)
	{
		// Get id of PM type tab
		var pm_type_tab_id = pmTypeList[i].id.split('_')[1];
	
		// Params for average calculation
		var axesList = new Array();
		var averageNotesList = new Array();
		var averageReferencesList = new Array();
		
		// Get all elements of class axe_tab in pm_type_tab (AXES)
		var axeList = jQuery("#"+pmTypeList[i].id+" .axe_tab");
		for (var j=0; j<axeList.length; j++)
		{
			// Params for axe's average calculation
			var questionNotesList = 0;
			var questionNotesCount = 0;
			var questionRefsList = 0;
			var questionRefsCount = 0;
			
			// Get axe id
			var axe_id = axeList[j].id.split('_')[2];
			
			// Average cells name
			var averageNoteCellId = pm_type_tab_id + "_axe_average_note_"+axe_id;
			var averageRefCellId = pm_type_tab_id + "_axe_average_ref_"+axe_id;
			
			// Get all notes and references of questions of the current axe_tab
			var questions = jQuery('.question_note_'+axe_id);
			var references = jQuery('.question_reference_'+axe_id);
			
			// For each questions, add values to params
			for (var y=0; y<questions.length; y++)
			{
				// Note
				if(questions[y].value != "NI")
				{
					questionNotesList += parseInt(questions[y].value);
					questionNotesCount++;
				}
				else
				{
					questionNotesList += 0;
					questionNotesCount++;
				}
				
				// Reference
				if(references[y].firstChild.nodeValue != "NI")
				{
					questionRefsList += parseInt(references[y].firstChild.nodeValue);
					questionRefsCount++;
				}
				else
				{
					questionRefsList += 0;
					questionRefsCount++;
				}
			}	
			
			// Calcul notes/references average of the current axes
			axesList.push(axeList[j].firstChild.nodeValue);
			if(questionNotesCount != 0)
			{
				var resultAvg = questionNotesList/questionNotesCount
				averageNotesList.push(Math.round(resultAvg*100)/100);
			}
			else
			{
				averageNotesList.push(0);
			}
			jQuery("#"+averageNoteCellId).text(averageNotesList[averageNotesList.length-1]);
			if(questionRefsCount != 0)
			{
				var resultAvgRef = questionRefsList/questionRefsCount
				averageReferencesList.push(Math.round(resultAvgRef*100)/100);
			}
			else
			{
				averageReferencesList.push(0);
			}
			jQuery("#"+averageRefCellId).text(averageReferencesList[averageReferencesList.length-1]);
		}
		
		// Draw chart for pm_type_tab
		var chartId = "chartContainer_"+pm_type_tab_id;
		var chartName = jQuery("#table_title_"+pm_type_tab_id).text();
		generate_spider_chart(chartId,chartName,axesList,averageNotesList,averageReferencesList)
	}
}

function generate_spider_chart(chartId,chartName,xAxisArray,serie1,serie2)
{
	// if not enough branchs, create fake branchs
	var diff = 4 - xAxisArray.length;
	for (var i = 0; i < diff; i++)
	{
		xAxisArray.push("");
		serie1.push(0);
		serie2.push(0);
	}
	// Chart generation
	window.chart = new Highcharts.Chart({
	            
	    chart: {
	        renderTo: chartId,
	        polar: true,
	        type: 'area'
	    },
	    
	    title: {
	        text: chartName,
	        x: 0,
	    },
	    
	    pane: {
	    	size: '80%'
	    },
	    
	    xAxis: {
	        categories: xAxisArray,
	        tickmarkPlacement: 'on',
	        lineWidth: 0
	    },
	        
	    yAxis: {
	        gridLineInterpolation: 'polygon',
	        lineWidth: 0,
			max: 3,
	        min: 0
	    },
	    
	    tooltip: {
	    	shared: true,
	        valuePrefix: ''
	    },
	    
	    legend: {
	        align: 'right',
	        verticalAlign: 'top',
	        y: 100,
	        layout: 'vertical'
	    },
	    credits : {
		  enabled : false
		},
		exporting : {
			url : "http://toulouse.sqli.com/eisq-portal/export_image/index.php"
		},
	    series: [{
	        name: 'Reference',
	        color: '#99B3FF',
	        data: serie2,
	        pointPlacement: 'on'
	    },
		{
	        name: 'Note',
	        color: '#0E13FF',
	        data: serie1,
	        pointPlacement: 'on'
	    }]
	});
}

function calculHistoryAverage(axeAvgByPmType)
{
	for(var i=0; i < axeAvgByPmType.length; i++)
	{
		var chartId = "chartContainer_"+i;
		var chartName = axeAvgByPmType[i]["title"];
		generate_spider_chart(chartId,chartName,axeAvgByPmType[i]["axes"],axeAvgByPmType[i]["notes"],axeAvgByPmType[i]["refs"]);
	}
}

// KPI
function generate_kpi_chart(containerId, chartName, categories, series)
{
	chart = new Highcharts.Chart({
        chart: {
            renderTo: containerId,
            type: 'line',
            marginRight: 130,
            marginBottom: 25
        },
        title: {
            text: chartName,
            x: 0, //center
        },
        xAxis: {
            categories: categories
        },
        yAxis: {
			max: 3,
			min: 0,
            title: {
                text: 'Average'
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }]
        },
        tooltip: {
            formatter: function() {
                    return '<b>'+ this.series.name +'</b><br/>'+
                    this.x +': '+ this.y;
            }
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'top',
            x: -10,
            y: 20,
            borderWidth: 0
        },
		credits : {
		  enabled : false
		},
		exporting : {
			url : "http://toulouse.sqli.com/eisq-portal/export_image/index.php"
		},
        series: series
  });
  return chart;
}