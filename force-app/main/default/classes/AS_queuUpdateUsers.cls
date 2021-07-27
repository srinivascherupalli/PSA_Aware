public class AS_queuUpdateUsers implements Queueable {

	public Set<Id> setUsers = new Set<Id>();

	public AS_queuUpdateUsers(Set<Id> setId) {
		setUsers = setId;
		system.debug('xxxAS_queuUpdateUsers : '+setId);
	}

	public void execute(QueueableContext context) {
        //Do some action here
		List<Profile> listProfile = [Select Id,Name from Profile where Name='Non Member Login User' LIMIT 1];
    	List<User> listUser = new List<User>();
    	for(User usr : [Select Id,Name,Email,ProfileId from User where Id IN :setUsers]){
    		if(listProfile[0]!=null){
	    		User usr2Update = new User();
				usr2Update.Id = usr.Id;
				usr2Update.ProfileId = listProfile[0].Id;
	    		listUser.add(usr2Update);
	    	}
    	}

    	update listUser;
	}
}