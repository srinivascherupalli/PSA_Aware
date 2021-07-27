public class AsCommunitiesBecomeAMember {
    
    public Id AccountId {get;set;}  
    public String memberUrl {get;set;}

    public AsCommunitiesBecomeAMember() {}

    public void theUserId(){

        system.debug('UserInfo.getUserId()  ==> '+ UserInfo.getUserId() );

        User user = [ SELECT AccountId,Email,FirstName FROM User WHERE  Id=:UserInfo.getUserId()  ];
        system.debug('user ==>'+ user);
        if( user.AccountId != null ){
            system.debug('Solod dapat diri');
            AccountId = user.AccountId;
            memberUrl = 'https://psa.secure.force.com/membershipsignup?nonmemberaccountid='+AccountId;
        } else {
            memberUrl = 'https://psa.secure.force.com/membershipsignup';
        }


    }

}