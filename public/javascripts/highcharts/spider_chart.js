

function calculAverage()
{
	// Get all table of class pm_type_tab (PM TYPE)
	var pmTypeList = $(".pm_type_tab");
	for (var i=0; i < pmTypeList.length; i++)
	{
		// Get id of PM type tab
		var pm_type_tab_id = pmTypeList[i].id.split('_')[1];
	
		// Params for average calculation
		var axesList = new Array();
		var averageNotesList = new Array();
		var averageReferencesList = new Array();
		
		// Get all elements of class axe_tab in pm_type_tab (AXES)
		var axeList = $("#"+pmTypeList[i].id+" .axe_tab");
		for (var j=0; j<axeList.length; j++)
		{
			// Params for axe's average calculation
			var questionNotesList = 0;
			var questionNotesCount = 0;
			var questionRefsList = 0;
			var questionRefsCount = 0;
			
			// Get axe id
			var axe_id = axeList[j].id.split('_')[2];
			
			// Get all notes and references of questions of the current axe_tab
			var questions = $('.question_note_'+axe_id);
			var references = $('.question_reference_'+axe_id);
			
			// For each questions, add values to params
			for (var y=0; y<questions.length; y++)
			{
				if(questions[y].value != "NI")
				{
					questionNotesList += parseInt(questions[y].value);
					questionNotesCount++;
				}
				else
				{
					questionNotesList += 0;
				}
				
				questionRefsList += parseInt(references[y].firstChild.nodeValue);
				questionRefsCount++;
			}	
			
			// Calcul notes/references average of the current axes
			axesList.push(axeList[j].firstChild.nodeValue);
			if(questionNotesCount != 0)
			{
				averageNotesList.push(questionNotesList/questionNotesCount);
			}
			else
			{
				averageNotesList.push(0);
			}
			if(questionRefsCount != 0)
			{
				averageReferencesList.push(questionRefsList/questionRefsCount);
			}
			else
			{
				averageReferencesList.push(0);
			}
		}
		
		// Draw chart for pm_type_tab
		var chartId = "chartContainer_"+pm_type_tab_id;
		var chartName = $("#table_title_"+pm_type_tab_id).text();
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
	        type: 'line'
	    },
	    
	    title: {
	        text: chartName,
	        x: -80
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
	    
	    series: [{
	        name: 'Note',
	        data: serie1,
	        pointPlacement: 'on'
	    }, {
	        name: 'Reference',
	        data: serie2,
	        pointPlacement: 'on'
	    }]
	});
}