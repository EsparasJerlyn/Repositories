/**DEPP-4732 [Manual] Add Attributes to Persona */

/** Assign following attributes to Student Advisor:
 * Service Cloud
 * Chat User
 */
Id isrUserRoleId = [SELECT Id, Name FROM UserRole WHERE Name='International User']?.Id;
//Retrieve all users
List<User> internationalUsers = [SELECT Id,
                                        UserPermissionsSupportUser,
                                        UserPermissionsLiveAgentUser
                                FROM User 
                                WHERE UserRoleId=:isrUserRoleId AND ProfileId=:isrProfileId];
for(User usr : internationalUsers){
    usr.UserPermissionsSupportUser = true; //Service Cloud
    usr.UserPermissionsLiveAgentUser = true; //Chat
}
Database.SaveResult[] srList2 = Database.update(internationalUsers, false);
for (Database.SaveResult result : srList2){
    if(result.isSuccess()){
        System.debug('Successfully updated Student Advisor User with User Id: ' + result.getId());
    }else{
        System.debug('Database error updating users (Student Advisor): ' + result.getErrors());
    }            
}

/**DEPP-5317 DevOps - Create a user record for testing */
/** Assign following attributes to Future Student Engagement:
 * Service Cloud
 * Knowledge User
 */
Id futureStudentEngagementProfileId = [SELECT Id, Name FROM Profile WHERE Name='Future Student Engagement']?.Id;
Id futureStudentEngagementUserRoleId = [SELECT Id, Name FROM UserRole WHERE Name='Future Student Engagement']?.Id;
//Retrieve all users
List<User> futureStudentEngageentUsers = [SELECT Id,
                                        UserPermissionsSupportUser,
                                        UserPermissionsKnowledgeUser
                                FROM User 
                                WHERE UserRoleId=:futureStudentEngagementUserRoleId AND ProfileId=:futureStudentEngagementProfileId];
for(User usr : futureStudentEngageentUsers){
    usr.UserPermissionsSupportUser = true; //Service Cloud
    usr.UserPermissionsKnowledgeUser = true; //Knowledge
}
Database.SaveResult[] srList3 = Database.update(futureStudentEngageentUsers, false);
for (Database.SaveResult result : srList3){
    if(result.isSuccess()){
        System.debug('Successfully updated Future Student Engagement User with User Id: ' + result.getId());
    }else{
        System.debug('Database error updating users (Future Student Engagement): ' + result.getErrors());
    }            
}

/**End of script */