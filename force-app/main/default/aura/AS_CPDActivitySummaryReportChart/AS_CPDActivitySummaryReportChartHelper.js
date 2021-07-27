({
    AS_psaChart : function (component) {
        
        var ready = component.get("v.ready");
        if (ready === false) {
            return;
        }
        var url = window.location.href; 
        var arr = url.split('/'); 
        
        var chartCanvas = component.find("AS_psachart").getElement();
        var action = component.get("c.cpdActivityReport");
        action.setParams({ cpdPlanId : arr[arr.length-2] });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var chrtLbl = ['-', 'Complete', 'Planned', 'In Progress', 'Not Started', 'Under Review'];
            if (state === "SUCCESS") {
                var cpdList = response.getReturnValue();
                console.log(cpdList);
                console.log('length: ' + cpdList.length);
               
                if(cpdList.length > 0){
                    let cpdTotal = 0;
                    let cntPlanned = 0;
                    let cntComplete = 0;
                    let cntInProgress = 0;
                    let cntNotStarted = 0;
                    let cntUnderReview = 0;
                    let cntBlank = 0;
                    for (var key in cpdList ) {
                        var value = cpdList[key];
                        if(typeof value != 'function') {
                            
                            if(value.Status__c == 'Planned') cntPlanned ++;
                            if(value.Status__c == 'Complete') cntComplete ++;
                            if(value.Status__c == 'In Progress') cntInProgress ++;
                            if(value.Status__c == 'Not Started') cntNotStarted ++;
                            if(value.Status__c == 'Under Review') cntUnderReview ++;
                            if(value.Status__c == undefined) cntBlank ++;
                            cpdTotal ++;
                        }
                    }
                    var myChart = new Chart(chartCanvas, {
                        type: 'doughnut',
                        data: {
                            labels: chrtLbl,
                            datasets: [
                                {
                                    label: "Record Count",
                                    data: [cntBlank, cntComplete, cntPlanned, cntInProgress, cntNotStarted, cntUnderReview],
                                    backgroundColor: [
                                        "#00A1E0",
                                        "#16325C",
                                        "#76DED9",
                                        "#08A69E",
                                        "#E2CE7D",
                                        "#E67E22",
                                        "#F8C471",
                                        "#3498DB",
                                        "#00BCD4",
                                        "#D32F2F",
                                        "#82E0AA",
                                        "#AFB42B"
                                    ]
                                }
                            ]
                        },
                        options: {
                            pieceLabel: {
                                render: 'value',
                                fontSize: 17,
                                fontColor: '#fff',
                            },
                            legend: {
                                display: true,
                                position:'right',
                                fullWidth:false,
                                reverse:true,
                                labels: {
                                    fontColor: '#54698D',
                                    fontSize:10,
                                    boxWidth: 8,
                                    
                                },
                            },
                            tooltips: {
                                callbacks: {
                                    title: function(tooltipItem, data) {
                                        return ['Status', data['labels'][tooltipItem[0]['index']], ''];
                                    },
                                    label: function(tooltipItem, data) {
                                        return ['Record Count: ' + data['datasets'][0]['data'][tooltipItem['index']], ''];
                                    },
                                },
                                backgroundColor: '#003d79',
                                titleFontSize: 13,
                                titleFontColor: '#FFF',
                                bodyFontColor: '#fff',
                                bodyFontSize: 13,
                                displayColors: false
                            },
                            cutoutPercentage: 50,
                            maintainAspectRatio: false,
                            centerText: cpdTotal,
                            elements: {
                                arc: {
                                    borderWidth: 0
                                }
                            }
                        }
                        
                    });//END CHART
                    //Total Record count on Center
                    Chart.pluginService.register({
                        beforeDraw: function(chart) {
                            var width = chart.chart.width,
                                height = chart.chart.height,
                                ctx = chart.chart.ctx;
                            
                            ctx.restore();
                            var fontSize = (height / 114).toFixed(2);
                            ctx.font = fontSize + "em sans-serif";
                            ctx.textBaseline = "middle";
                            
                            var text = chart.options.centerText,
                                textX = Math.round((width - ctx.measureText(text).width) / 2.8),
                                textY = height / 2;
                            
                            ctx.fillText(text, textX, textY);
                            ctx.save();
                        } 
                    });
                }else{
                    chartCanvas.style.display='none';
                    component.set("v.displayMsg", true); 
                    console.log('here123123');
                }
            }
        });  //END action
        $A.enqueueAction(action);
    }
})