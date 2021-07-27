/*
* Author : WEW
* Description: method to update user using Queueable to avoid mix dml error
* Parameter : None
* Return : None
*/
public class AS_createUserFuture implements Queueable {

	public List<Id> userIdList = new List<Id>();

	public AS_createUserFuture(List<Id> listId) {
		userIdList = listId;
		system.debug('AS_createUserFuture : '+userIdList);
	}

	public void execute(QueueableContext context) {
        //Do some action here
		List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];  // this is a static query
   	
   	List<User> allUserUpdate = new List<User>(); 
   	if(pro.size() > 0) {
			for(Id theId : userIdList) {
				User indiUser = new User();
				indiUser.Id = theId;
				indiUser.profileid = pro[0].Id;
				allUserUpdate.add(indiUser);
			}
			update allUserUpdate;
   	}
	}
}