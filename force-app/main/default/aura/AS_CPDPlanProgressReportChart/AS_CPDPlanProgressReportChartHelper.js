({
    AS_psaChartPlan : function (component) {
        var ready = component.get("v.ready");
        if (ready === false) {
            return;
        }
        var url      = window.location.href; 
        console.log('url:' + url);
        var arr = url.split('/'); 
        console.log('ron:' + arr[arr.length-2])
        var chartCanvas = component.find("AS_psachart").getElement();
        var action = component.get("c.cpdPlanProgressReport");
        action.setParams({ cpdPlanId : arr[arr.length-2] });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var cpdList = response.getReturnValue();
                console.log(cpdList);
                
                var cpdLabels = [];
                var totalCpd = [];
                for (var key in cpdList ) {
                    var value = cpdList[key];
                    console.log(value);
                    if(typeof value != 'function') {
                        
                        cpdLabels.push(value.AS_CPD_Credits_Percentage__c + '%');
                        totalCpd.push(value.AS_CPD_Credits_Percentage__c);
                    }
                }
                var chart = new Chart(chartCanvas,{
                    type: 'horizontalBar',
                    data: {
                        labels: cpdLabels,
                        datasets: [
                            {
                                label: "Record Count",
                                data: totalCpd,
                                backgroundColor: [
                                    "#00A1E0",
                                    "#00A1E0",
                                    "#00A1E0",
                                    "#00A1E0",
                                    "#00A1E0"]
                            }
                        ]
                    },
                    options: {
                        responsive:true,
                        scales: {
                            yAxes: [{
                                gridLines: {
                                    display:false
                                },
                                scaleLabel: {
                                    display: true,
                                    labelString: "My Progress Status"
                                }
                            }],
                            xAxes: [{
                                ticks: {
                                    max: 100,
                                    min: 0,
                                    stepSize: 15,
                                    mirror: false
                                }
                            }]
                        },
                        pieceLabel: {
                            render: 'value',
                            fontSize: 16,
                            fontColor: '#fff',
                        },
                        legend: {
                            display: false
                        },
                        showAllTooltips: true,
                        tooltips: {
                            custom: function(tooltip) {
                                if (!tooltip) return;
                                // disable displaying the color box;
                                tooltip.displayColors = false;
                            },
                            callbacks: {
                                // use label callback to return the desired label
                                label: function(tooltipItem, data) {
                                    return "Current Progress : " + tooltipItem.yLabel;
                                },
                                // remove title
                                title: function(tooltipItem, data) {
                                    return;
                                }
                            }
                        },
                        cutoutPercentage: 50,
                        maintainAspectRatio: false,
                        centerText: ''    
                    }
                });
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message on createReport: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
    }
})