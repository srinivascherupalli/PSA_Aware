({
  formatCardList: function formatCardList(data, list) {
    var _this = this;

    var cards = [];
    list.forEach(function (key) {
      if (typeof data.tPlan[key] === "undefined") {
        return;
      }

      cards.push(_this.formatCardData(data.tPlan[key]));
    });
    return cards;
  },
  formatCardData: function formatCardData(card) {
    var isTrainingTrack = card.Id.indexOf("a16") > -1;
    var cardData = {
      id: card.Id,
      href: "",
      title: card.Name,
      group: card.Group__c,
      tag: card.PSA_Marketing_Text__c,
      duration: "",
      deliveryMethod: "",
      deliveryDescription: "",
      thumbnail: "",
      badge: "",
      isCourse: card.Qualification_Card__c == false
    };

    if (typeof card.Achievement__r !== "undefined") {
      cardData.badge = card.Achievement__r.Eligible_Image__c;
    }

    if (isTrainingTrack) {
      cardData.href = "/s/training-track/" + card.Id;
      cardData.duration = card.PSA_Duration_editorial__c;
      cardData.deliveryMethod = card.PSA_Delivery_Method__c;
      cardData.deliveryDescription = card.PSA_Card_Description__c;
      cardData.thumbnail = card.PSA_TT_Tile_Image__c;
    } else {
      cardData.href = "/s/training-plan/" + card.Id;
      cardData.duration = card.Duration_editorial__c;
      cardData.deliveryMethod = card.AS_Delivery_Method__c;
      cardData.deliveryDescription = card.Card_Description__c;
      cardData.thumbnail = card.PSA_TP_Tile_Image__c;
    }

    return cardData;
  },
  formatTags: function formatTags(tag) {
    return {
      value: encodeURIComponent(tag),
      text: tag
    };
  }
});