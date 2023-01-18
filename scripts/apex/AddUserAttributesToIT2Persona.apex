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
List<User> userList1 = [SELECT Id,
                            UserPermissionsMarketingUser,
                            UserPermissionsSupportUser,
                            UserPermissionsLiveAgentUser,
                            UserPermissionsKnowledgeUser
                        FROM User 
                        WHERE UserRoleId=:isrSuperUserRoleId AND ProfileId=:isrProfileId];
for(User usr : userList1){
    usr.UserPermissionsMarketingUser = true;
    usr.UserPermissionsSupportUser = true;
    usr.UserPermissionsLiveAgentUser = true;
    usr.UserPermissionsKnowledgeUser = true;
}
update userList1;

/** Assign following attributes to Student Advisor:
 * Service Cloud
 * Chat User
 */
Id isrUserRoleId = [SELECT Id, Name FROM UserRole WHERE Name='International User']?.Id;
//Retrieve all users
List<User> userList2 = [SELECT Id,
                            UserPermissionsSupportUser,
                            UserPermissionsLiveAgentUser
                        FROM User 
                        WHERE UserRoleId=:isrUserRoleId AND ProfileId=:isrProfileId];
for(User usr : userList2){
    usr.UserPermissionsSupportUser = true;
    usr.UserPermissionsLiveAgentUser = true;
}
update userList2;

/**End of script */