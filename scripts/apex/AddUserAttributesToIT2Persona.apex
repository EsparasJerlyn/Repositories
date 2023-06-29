/**DEPP-4732 [Manual] Add Attributes to Persona */

/** Assign following attributes to "Communications Manager" and "Student Enquiries Communications Officer":
 * Marketing
 * Service Cloud
 * Chat User
 * Knowledge User
 */
Id isrProfileId = [SELECT Id, Name FROM Profile WHERE Name='International Student Recruitment']?.Id;
Id isrSuperUserRoleId = [SELECT Id, Name FROM UserRole WHERE Name='International Super User']?.Id;
System.debug(LoggingLevel.DEBUG, 'ISR Profile Id:' + isrProfileId);//NOPMD
System.debug(LoggingLevel.DEBUG, 'ISR User Role Id:' + isrSuperUserRoleId);//NOPMD

// Retrieve all users
List<User> internationalStudentRecruitmentUsers = [SELECT Id,
                            UserPermissionsMarketingUser,
                            UserPermissionsSupportUser,
                            UserPermissionsLiveAgentUser,
                            UserPermissionsKnowledgeUser
                        FROM User 
                        WHERE UserRoleId=:isrSuperUserRoleId AND ProfileId=:isrProfileId];
for(User usr : internationalStudentRecruitmentUsers){
    usr.UserPermissionsMarketingUser = true; //Marketing
    usr.UserPermissionsSupportUser = true; //Service Cloud
    usr.UserPermissionsLiveAgentUser = true; //Chat
    usr.UserPermissionsKnowledgeUser = true; //Knowledge
}
Database.SaveResult[] srList1 = Database.update(internationalStudentRecruitmentUsers, false);
for (Database.SaveResult result : srList1){
    if(result.isSuccess()){
        System.debug('Successfully updated International Student Recruitment User with User Id: ' + result.getId());
    }else{
        System.debug('Database error updating users (Communications Manager, Student Enquiries Communications Officer): ' + result.getErrors());
    }            
}

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