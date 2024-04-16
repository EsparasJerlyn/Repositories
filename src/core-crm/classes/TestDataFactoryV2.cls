/**
 * @description Test class that contains reusable method for test data creation
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                           |
 *    |---------------------------|-----------------------|---------------------|------------------------------------------|
 *    | Julie                     | April 16, 2024        | DEP1-8016           | Created file                             |
 **/

@isTest
public class TestDataFactoryV2 {

    /***********************************************
    * SERVICE USERS
    ************************************************/

    /************************
    * Sys Admin Integration User
    *************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserSysAdminIntegrationUser() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOSysAdminIntegrationUser}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserSysAdminIntegrationUser {
        get {return [SELECT Id FROM User WHERE Email = 'TestSysAdminIntegrationUser@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOSysAdminIntegrationUser {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'SysAdminIntegrationUser';
            usr.Persona = 'System Administrator';
            usr.Role = 'System_Administrator';
            usr.profileName = 'System Administrator';

            usr.userpermissionsmarketinguser = true;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;

            usr.permissionsetGroupNames = new Set<String>{'Persona_System_Administrator'};
            usr.publicGroupNames = new Set<String>{'System_Administrator'};
            //usr.permissionsetNames = new Set<String>{'xxxx','xxxx'};
            //usr.permissionsetLicenceNames = new Set<String>{'xxxx','xxxx'};

            return usr;
        } set;
    }

    /***********************************************
    * BUSEINSS UESRS
    ************************************************/

    /************************
    * QUTeX Executive Director
    *************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTeXExecutiveDirector() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTeXExecutiveDirector}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTeXExecutiveDirector {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTeXExecutiveDirector@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTeXExecutiveDirector {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'QUTeXExecutiveDirector';
            usr.Persona = 'QUTeX Executive Director';
            usr.profileName = 'QUTeX';
            usr.role = 'QUTeX_Leadership';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            //usr.permissionsetGroupNames = new Set<String>{'xxxx'};
            //usr.publicGroupNames = new Set<String>{'xxxx'};
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader','Marketing','DocuSign_Generator','DocuSign_Negotiator','DocuSign_Sender','DocuSign_User','Permission_API_Enabled'};
            //usr.permissionsetLicenceNames = new Set<String>{'xxxx','xxxx'};

            return usr;
        } set;
    }


    /***********************************************
    * PORTAL/EXPERIECE UESRS
    ************************************************/

    
   
}