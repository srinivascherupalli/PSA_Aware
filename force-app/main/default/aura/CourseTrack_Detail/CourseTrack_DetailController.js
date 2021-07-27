({
  doInit: function doInit(component, event, helper) {
    var action = component.get("c.getTrainingTrackState");
    action.setParams({
      trainingTrackId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      var status = response.getState();

      if (status === "SUCCESS") {
        var resultData = response.getReturnValue();
          //console.log(resultData);
        component.set("v.pageStateWrapper", resultData);
        var prerequsiteCards = helper.formatCardList(resultData, [
          "prerequsite1Plan",
          "prerequsite2Plan",
          "prerequsite3Plan"
        ]);
        component.set("v.prerequsiteList", prerequsiteCards);
        var relatedCards = helper.formatCardList(resultData, [
          "related1Plan",
          "related2Plan",
          "related3Plan",
          "related4Plan"
        ]);
        component.set("v.relatedList", relatedCards);
        var trainingPlanclassString = [];
        var trainingtrackString = [];
        var categoryString = [];
        var listofCategory = [];
        var deliveryMethodString = [];
        var listofdleiveryMethod = [];
        var tpTypeString = [];
        var listofTPType = []; //trainingPlanclassString=resultData['tPlan']

        trainingtrackString = resultData["track"];
        categoryString = trainingtrackString["AsCategory__c"];
          if (categoryString!= null) {
              listofCategory = categoryString.split(";").map(helper.formatTags);
              if(listofCategory.length>0){
                  component.set("v.categoryPicklistValues", listofCategory);
              }
          } 
          
          deliveryMethodString = trainingtrackString["PSA_Delivery_Method__c"]; //listofdleiveryMethod = deliveryMethodString.split(';');
          if(deliveryMethodString.length>0){
              component.set(
                  "v.deliveryPicklistValues",
                  [deliveryMethodString].map(helper.formatTags)
              );
          }
          
          tpTypeString = trainingtrackString["PSA_Education_Type__c"]; //listofTPType = tpTypeString.split(';');
          if(tpTypeString.length>0){
              component.set(
                  "v.tpTypePicklistValues",
                  [tpTypeString].map(helper.formatTags)
              );
          }
          
          // Badge image

        var mainachievment = [];
        var imageURL = [];
        var groupValue = [];
        groupValue = trainingtrackString["PSA_Group__c"];
        mainachievment = trainingtrackString["Achievement__r"];

        if (mainachievment != undefined) {
          imageURL = mainachievment["Eligible_Image__c"];

          if (imageURL != undefined) {
            component.set("v.badgeimage", imageURL);
          }
        } else if (groupValue != undefined) {
          if (groupValue == "Group 1") {
            var badgeURL1 =
              '<p><img src="' +
              $A.get("$Resource.PSAFED") +
              "/dist/images/group1-blanklogo.gif" +
              '" alt="credit badge single"></img></p>';
            component.set("v.badgeimage", badgeURL1);
          } else if (groupValue == "Group 2") {
            var badgeURL =
              '<p><img src="' +
              $A.get("$Resource.PSAFED") +
              "/dist/images/group2-blanklogo.gif" +
              '" alt="credit badge single"></img></p>';
            component.set("v.badgeimage", badgeURL);
          } else if (groupValue == "Group 3") {
            var badgeURL =
              '<p><img src="' +
              $A.get("$Resource.PSAFED") +
              "/dist/images/group3-blanklogo.gif" +
              '" alt="credit badge single"></img></p>';
            component.set("v.badgeimage", badgeURL);
          }
        }
      } else {
        console.log("Error: " + response.getError()[0].message);
      }
    });
    $A.enqueueAction(action);
  }
});