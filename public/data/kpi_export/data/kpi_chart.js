
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
            x: -20 //center
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
        series: [{ name: "Value", data:series}]
  });
  return chart;
}

function kpi_chart_add_serie(chart,serie)
{
	chart.addSeries({
         name: name,
         data: serie
      });
}