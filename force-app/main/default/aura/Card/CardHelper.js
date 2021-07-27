({
  generateClassName: function(component) {
    var isCourse = component.get("v.isCourse");
    var group = component.get("v.group");

    var className = ["card"];

    if (isCourse === false) {
      className.push("card--qualification");
    } else {
      className.push("card--course");
      if (typeof group !== "undefined") {
        className.push("card--" + group.replace(" ", "").toLowerCase());
      } else {
        className.push("card--no-group");
      }
    }

    component.set("v.className", className.join(" "));
  },

  generateAttributes: function(component) {
    var duration = component.get("v.duration");
    var deliveryMethod = component.get("v.deliveryMethod");
    var deliveryDescription = component.get("v.deliveryDescription");
    var attributes = [];

    if (duration) {
      attributes.push({
        icon: "utility:clock",
        text: duration
      });
    }

    if (deliveryMethod) {
      var deliveryMethodData = {
        icon: "",
        text: deliveryDescription || deliveryMethod
      };
      switch (deliveryMethod) {
        case "Webinar":
        case "Podcast":
          deliveryMethodData.icon = "utility:podcast_webinar";
          break;
        case "Recorded session":
        case "Online module":
          deliveryMethodData.icon = "custom:custom21";
          break;
        case "Blended learning":
          deliveryMethodData.icon = "custom:custom62";
          break;
        case "Face-to-face":
        case "Conference":
          deliveryMethodData.icon = "utility:groups";
          break;
        default:
          deliveryMethodData.icon = "utility:screen";
          break;
      }
      attributes.push(deliveryMethodData);
    }

    component.set("v.attributes", attributes);
  }
});