public class CustomSearchController {
    @AuraEnabled
    public static List<SObject> searchForIds(String searchText) {
        List<List<SObject>> results = [FIND :searchText IN ALL FIELDS  RETURNING Account(Id,Name), Campaign(Id,Name), Contact(Id,Name), Lead(Id,Name),Case(Id,CaseNumber)];
        List<SObject> ids = new List<SObject>();
        for (List<SObject> sobjs : results) {
            for (SObject sobj : sobjs) {
                ids.add(sobj);
            }
        }
        return ids;
    }
}