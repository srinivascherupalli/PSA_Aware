/*Author : John Hope
*Description : wrapper class for moodle api callout
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : 
*/
public class AsMoodleWrapper {
	public String token {get; set;}
	public String url {get; set;}
	public String obj {get; set;}
	public String function {get; set;}
	public String request {get; set;}
	public String sfId {get; set;}
	public String name {get; set;}
	public String shortname {get; set;}
	public String username {get; set;}
	public String firstname  {get; set;}
	public String lastname {get; set;}
	public String email {get; set;}
	public String userid {get; set;}
	public String restriction {get; set;}
	
	
	public AsMoodleWrapper(String tok, String theUrl, String obje, String func, String req, String sf, String str1, String str2, String str3, String str4, String str5, String str6, String str7,String str8) {
	    token = tok;
	    url = theUrl;
	    obj = obje;
	    function = func;
	    request = req;
	    sfId = sf;
	    name = str1;
	    shortname = str2;
	    username = str3;
	    firstname = str4;
	    lastname = str5;
	    email = str6;
	   	userid = str7;
	    restriction = str8;
	}
    
    /*Author : Michael Vincent Largo
    *Description : wrapper class for moodle api callout in activity
    *Date Created : 8/28/2019
    *Last Modified By : 
    *Date Last Modified : 
    *Related Meta Data : 
    */
        
    /*wrapper for lms_activity*/
    public String activitysfid {get; set;}
	public String actname {get; set;}
	public String courseId {get; set;}
    public String acttype {get; set;}
 
    public AsMoodleWrapper(String act_sfid, String act_name, String course_Id, String act_type, String tok, String theUrl, String obje, String func, String req){
        
        activitysfid = act_sfid;
        actname = act_name;
        courseId = course_Id;
        acttype = act_type;
        token = tok;
	    url = theUrl;
        obj = obje;
	    function = func;
	    request = req;
    }
    
    /*wrapper for lms_activity_enrolment*/
    // public String activityenrolsfid {get; set;}
    //	public String actenrolname {get; set;}
    //public String courseenrolId {get; set;}
    //  public String activsfid {get; set;}
 
    /*public AsMoodleWrapper(String actenrol_sfid, String actenrol_name, String courseenrol_Id, String activ_sfid, String tok, String theUrl, String obje, String func, String req){
        
        activityenrolsfid = actenrol_sfid;
        actenrolname = actenrol_name;
        courseenrolId = courseenrol_Id;
        activsfid = activ_sfid;
        token = tok;
	    url = theUrl;
        obj = obje;
	    function = func;
	    request = req;
    }*/
 
}