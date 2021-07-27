({
  sortCards: function sortCards(sortType, a, b) {
    switch (sortType) {
      case "az":
        return a.Training_Plan__r.Name.toLowerCase().localeCompare(
          b.Training_Plan__r.Name.toLowerCase()
        );

      case "za":
        return b.Training_Plan__r.Name.toLowerCase().localeCompare(
          a.Training_Plan__r.Name.toLowerCase()
        );

      case "edo":
        return new Date(a.CreatedDate) - new Date(b.CreatedDate);

      case "edn":
        return new Date(b.CreatedDate) - new Date(a.CreatedDate);

      default:
        console.error("sortType not available", sortType);
        return true;
    }
  }
});