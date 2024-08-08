/**
 * @description Test class that contains reusable method for test data creation
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                                             |
 *    |---------------------------|-----------------------|---------------------|----------------------------------------------------------------------------|
 *    | julie.jane.alegre         | April 16, 2024        | DEPP-8016           | Created file                                                               |
 *    | neil.s.h.lesidan          | August 7, 2024        | DEPP-10226          | Create method generateUserAlumniEngagementUser                             |
 **/
@isTest

public class TestDataFactoryUser {
    private static User portalSysAdmin;
    
    /***********************************************
    * SERVICE USERS
    ************************************************/

    /**********************
    * Sys Admin Integration
    ***********************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserSysAdminIntegration() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOSysAdminIntegration}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserSysAdminIntegration {
        get {return [SELECT Id FROM User WHERE Email = 'TestSysAdminIntegration@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOSysAdminIntegration {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'SysAdminIntegration';
            usr.Persona = 'System Administrator';
            usr.Role = 'System_Administrator';
            usr.profileName = 'System Administrator';

            usr.userpermissionsmarketinguser = true;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;

            usr.permissionsetGroupNames = new Set<String>{'Persona_System_Administrator'};
            usr.publicGroupNames = new Set<String>{'System_Administrator'};
            usr.permissionsetNames = new Set<String>{'System_Administrator'};
            
            return usr;
        } set;
    }

    /**********************
    * System Administrator 
    ***********************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserSystemAdministrator() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOSystemAdministrator}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserSystemAdministrator {
        get {return [SELECT Id FROM User WHERE Email = 'TestSystemAdministrator@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOSystemAdministrator {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'SystemAdministrator';
            usr.Persona = 'System Administrator';
            usr.profileName = 'System Administrator';
            usr.Role = 'System_Administrator';


            usr.userpermissionsmarketinguser = true;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;

            usr.permissionsetGroupNames = new Set<String>{'Persona_System_Administrator'};
            usr.publicGroupNames = new Set<String>{'System_Administrator'};
            
            return usr;
        } set;
    }

    /****************************************
    * System Administrator - Modify All Data
    *****************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserSystemAdministratorModifyAllData() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOSystemAdministratorModifyAllData}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserSystemAdministratorModifyAllData {
        get {return [SELECT Id FROM User WHERE Email = 'TestSystemAdministratorModifyAllData@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOSystemAdministratorModifyAllData {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'SystemAdministratorModifyAllData';
            usr.Persona = 'System Administrator - Modify All Data';
            usr.profileName = 'Internal Base';

            usr.userpermissionsmarketinguser = true;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;

            usr.permissionsetGroupNames = new Set<String>{'Persona_System_Administrator_Modify_All_Data'};
            usr.publicGroupNames = new Set<String>{'System_Administrator_Modify_All_Data'};
            usr.permissionsetNames = new Set<String>{'Permission_Multi_Factor_Authentication_for_User_Interface_Logins'};

            return usr;
        } set;
    }

    /**********************************
    * System Administrator - Read Only 
    ***********************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserSystemAdministratorReadOnly() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOSystemAdministratorReadOnly}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserSystemAdministratorReadOnly {
        get {return [SELECT Id FROM User WHERE Email = 'TestSystemAdministratorReadOnly@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOSystemAdministratorReadOnly {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'SystemAdministratorReadOnly';
            usr.Persona = 'System Administrator - Read Only';
            usr.profileName = 'Internal Base';

            usr.userpermissionsmarketinguser = true;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;

            usr.permissionsetGroupNames = new Set<String>{'Persona_System_Administrator'};
            usr.publicGroupNames = new Set<String>{'Persona_System_Administrator_Read_Only'};
            usr.permissionsetNames = new Set<String>{'Permission_Multi_Factor_Authentication_for_User_Interface_Logins'};

            return usr;
        } set;
    }

    /************************
    * Developer Team User
    *************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserDevelopmentTeam() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTODevelopmentTeam}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserDevelopmentTeam {
        get {return [SELECT Id FROM User WHERE Email = 'TestDevelopmentTeam@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTODevelopmentTeam {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'DevelopmentTeam';
            usr.Persona = 'Development Team';
            usr.profileName = 'Internal Base';

            usr.userpermissionsmarketinguser = true;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;

            usr.permissionsetGroupNames = new Set<String>{'Persona_Development_Team'};
            usr.publicGroupNames = new Set<String>{'Development_Team'};
            usr.permissionsetNames = new Set<String>{'Permission_Multi_Factor_Authentication_for_User_Interface_Logins'};

            return usr;
        } set;
    }

    /***********************************************
    * BUSINESS USERS
    ************************************************/

    /*************************
    * QUTeX Executive Director
    **************************/

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

            return usr;
        } set;
    }

    /*************************
    * QUTeX Business Manager
    **************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTeXBusinessManager() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTeXBusinessManager}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTeXBusinessManager {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTeXBusinessManager@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTeXBusinessManager {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'QUTeXBusinessManager';
            usr.Persona = 'QUTeX Business Manager';
            usr.profileName = 'QUTeX';
            usr.role = 'QUTeX_Leadership';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader','DocuSign_Generator','DocuSign_Negotiator','DocuSign_Sender','DocuSign_User','Permission_API_Enabled'};

            return usr;
        } set;
    }

    /*************************
    * QUTeX Director of OPE
    **************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTeXDirectorOPE() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTeXDirectorOPE}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTeXDirectorOPE {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTeXDirectorOPE@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTeXDirectorOPE {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'QUTeXDirectorOPE';
            usr.Persona = 'QUTeX Director of OPE';
            usr.profileName = 'QUTeX';
            usr.role = 'QUTeX_Leadership';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader','DocuSign_Generator','DocuSign_Negotiator','DocuSign_Sender','DocuSign_User','Permission_API_Enabled'};

            return usr;
        } set;
    }

    /*****************************
    * QUTeX Portfolio Co-Ordinator
    ******************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTeXPortfolioCoordinator() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTeXPortfolioCoordinator}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTeXPortfolioCoordinator {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTeXPortfolioCoordinator@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTeXPortfolioCoordinator {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'QUTeXPortfolioCoordinator';
            usr.Persona = 'QUTeX Portfolio Co-Ordinator';
            usr.profileName = 'QUTeX';
            usr.role = 'QUTeX_Super_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader'};

            return usr;
        } set;
    }

    /*****************************
    * QUTeX Product Administrator
    ******************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTeXProductAdministrator() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTeXProductAdministrator}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTeXProductAdministrator {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTeXProductAdministrator@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTeXProductAdministrator {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'QUTeXProductAdministrator';
            usr.Persona = 'QUTeX Product Administrator';
            usr.profileName = 'QUTeX';
            usr.role = 'QUTeX_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader','Email_Template_Management'};

            return usr;
        } set;
    }

    /**********************************
    * QUTeX Learning Innovation Manager
    ***********************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTeXLearningInnovationManager() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTeXLearningInnovationManager}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTeXLearningInnovationManager {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTeXLearningInnovationManager@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTeXLearningInnovationManager {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'QUTeXLearningInnovationManager';
            usr.Persona = 'QUTeX Learning Innovation Manager';
            usr.profileName = 'QUTeX';
            usr.role = 'QUTeX_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader'};

            return usr;
        } set;
    }

    /**********************************
    * QUTeX Learning Designer
    ***********************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTeXLearningDesigner() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTeXLearningDesigner}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTeXLearningDesigner {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTeXLearningDesigner@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTeXLearningDesigner {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'QUTeXLearningDesigner';
            usr.Persona = 'QUTeX Learning Designer';
            usr.profileName = 'QUTeX';
            usr.role = 'QUTeX_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE','Product_Administration'};

            return usr;
        } set;
    }

    /**********************************
    * QUTeX Partnership Manager
    ***********************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTeXPartnershipManager() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTeXPartnershipManager}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTeXPartnershipManager {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTeXPartnershipManager@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTeXPartnershipManager {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'QUTeXPartnershipManager';
            usr.Persona = 'QUTeX Partnership Manager';
            usr.profileName = 'QUTeX';
            usr.role = 'QUTeX_Super_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader','DocuSign_Generator','DocuSign_Negotiator','DocuSign_Sender','DocuSign_User','Permission_API_Enabled','Corporate_Bundle'};

            return usr;
        } set;
    }

    /**********************************
    * QUTeX Program Coordinator
    ***********************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTeXProgramCoordinator() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTeXProgramCoordinator}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTeXProgramCoordinator {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTeXProgramCoordinator@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTeXProgramCoordinator {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'QUTeXProgramCoordinator';
            usr.Persona = 'QUTeX Program Co-Ordinator';
            usr.profileName = 'QUTeX';
            usr.role = 'QUTeX_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE'};

            return usr;
        } set;
    }

    /**********************************
    * QUTeX Program Administrator
    ***********************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTeXProgramAdministrator() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTeXProgramAdministrator}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTeXProgramAdministrator {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTeXProgramAdministrator@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTeXProgramAdministrator {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'QUTeXProgramAdministrator';
            usr.Persona = 'QUTeX Program Administrator';
            usr.profileName = 'QUTeX';
            usr.role = 'QUTeX_Super_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.publicGroupNames = new Set<String>{'OPE_Product_Design','CCE_Product_Design','Program_Administrator'};
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader','Product_Administration','DocuSign_Generator','DocuSign_Negotiator','DocuSign_Sender','DocuSign_User','Permission_API_Enabled'};

            return usr;
        } set;
    }

    /**********************************
    * QUTeX Program Administrator 2
    ***********************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTeXProgramAdministrator2() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTeXProgramAdministrator2}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTeXProgramAdministrator2 {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTeXProgramAdministrator2@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTeXProgramAdministrator2 {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'QUTeXProgramAdministrator2';
            usr.Persona = 'QUTeX Program Administrator';
            usr.profileName = 'QUTeX';
            usr.role = 'QUTeX_Super_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.publicGroupNames = new Set<String>{'OPE_Product_Design','CCE_Product_Design','Program_Administrator'};
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader','Product_Administration','DocuSign_Generator','DocuSign_Negotiator','DocuSign_Sender','DocuSign_User','Permission_API_Enabled'};

            return usr;
        } set;
    }

    /**********************************
    * Marketin Manager
    ***********************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserMarketingManager() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOMarketingManager}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserMarketingManager {
        get {return [SELECT Id FROM User WHERE Email = 'TestMarketingManager@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOMarketingManager {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'MarketingManager';
            usr.Persona = 'Marketing Manager';
            usr.profileName = 'Digital Marketing';
            usr.role = 'Marketing_Super_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.permissionsetNames = new Set<String>{'Marketing'};

            return usr;
        } set;
    }

    /**********************************
    * Marketing Partnership Manager
    ***********************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserMarketingPartnershipManager() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOMarketingPartnershipManager}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserMarketingPartnershipManager {
        get {return [SELECT Id FROM User WHERE Email = 'TestMarketingPartnershipManager@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOMarketingPartnershipManager {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'MarketingPartnershipManager';
            usr.Persona = 'Marketing Partnership Manager';
            usr.profileName = 'QUTeX';
            usr.role = 'Marketing_Super_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE','Marketing'};

            return usr;
        } set;
    }

    /**********************************
    * Marketing Quality Assurance
    ***********************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserMarketingQualityAssurance() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOMarketingQualityAssurance}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserMarketingQualityAssurance {
        get {return [SELECT Id FROM User WHERE Email = 'TestMarketingQualityAssurance@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOMarketingQualityAssurance {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'MarketingQualityAssurance';
            usr.Persona = 'Marketing Quality Assurance';
            usr.profileName = 'QUTeX';
            usr.role = 'Marketing_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE','Marketing'};

            return usr;
        } set;
    }

    /**********************************
    * Digital Marketing Officer
    ***********************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserDigitalMarketingOfficer() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTODigitalMarketingOfficer}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserDigitalMarketingOfficer {
        get {return [SELECT Id FROM User WHERE Email = 'TestDigitalMarketingOfficer@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTODigitalMarketingOfficer {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'DigitalMarketingOfficer';
            usr.Persona = 'Digital Marketing Officer';
            usr.profileName = 'Digital Marketing';
            usr.role = 'Marketing_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.permissionsetNames = new Set<String>{'Marketing'};

            return usr;
        } set;
    }

    /****************************************
    * Marketing Digital Communication fficer
    *****************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserMarketingDigitalCommunicationOfficer() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOMarketingDigitalCommunicationOfficer}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserMarketingDigitalCommunicationOfficer {
        get {return [SELECT Id FROM User WHERE Email = 'TestMarketingDigitalCommunicationOfficer@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOMarketingDigitalCommunicationOfficer {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'MarketingDigitalCommunicationOfficer';
            usr.Persona = 'Marketing Digital Communication Officer';
            usr.profileName = 'QUTeX';
            usr.role = 'Marketing_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            
            usr.permissionsetNames = new Set<String>{'QUTeX_Base','QUTeX_CCE','Marketing'};

            return usr;
        } set;
    }

    /****************************************
    * Future Student Concierge Domestic
    *****************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserFutureStudentConciergeDomestic() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOFutureStudentConciergeDomestic}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserFutureStudentConciergeDomestic {
        get {return [SELECT Id FROM User WHERE Email = 'TestFutureStudentConciergeDomestic@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOFutureStudentConciergeDomestic {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'FutureStudentConciergeDomestic';
            usr.Persona = 'Future Student Concierge - Domestic';
            usr.profileName = 'Future Student Engagement';
            usr.role = 'Future_Student_Concierge_Domestic';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetGroupNames = new Set<String>{'Future_Student_Concierge_Domestic'};
            usr.publicGroupNames = new Set<String>{'Future_Students_Domestic'};

            return usr;
        } set;
    }

    /****************************************
    * Future Student Concierge International 
    *****************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserFutureStudentConciergeInternational() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOFutureStudentConciergeInternational}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserFutureStudentConciergeInternational {
        get {return [SELECT Id FROM User WHERE Email = 'TestFutureStudentConciergeInternational@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOFutureStudentConciergeInternational {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'FutureStudentConciergeInternational';
            usr.Persona = 'Future Student Concierge - International';
            usr.profileName = 'Future Student Engagement';
            usr.role = 'Future_Student_Concierge_International';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetGroupNames = new Set<String>{'Future_Student_Concierge_International'};
            usr.publicGroupNames = new Set<String>{'Future_Students_International'};

            return usr;
        } set;
    }

    /****************************************
    * Future Student Agent Domestic 
    *****************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserFutureStudentAgentDomestic() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOFutureStudentAgentDomestic}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserFutureStudentAgentDomestic {
        get {return [SELECT Id FROM User WHERE Email = 'TestFutureStudentAgentDomestic@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOFutureStudentAgentDomestic {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'FutureStudentAgentDomestic';
            usr.Persona = 'Future Student Agent - Domestic';
            usr.profileName = 'Future Student Engagement';
            usr.role = 'Future_Student_Agent_Domestic';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetGroupNames = new Set<String>{'Future_Student_Agent_Domestic'};
            usr.publicGroupNames = new Set<String>{'Future_Students_Domestic'};

            return usr;
        } set;
    }

    /*****************************************
    * Future Student Agent Super User Domestic
    ******************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserFutureStudentAgentSuperUserDomestic() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOFutureStudentAgentSuperUserDomestic}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserFutureStudentAgentSuperUserDomestic {
        get {return [SELECT Id FROM User WHERE Email = 'TestFutureStudentAgentSuperUserDomestic@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOFutureStudentAgentSuperUserDomestic {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'FutureStudentAgentSuperUserDomestic';
            usr.Persona = 'Future Student Agent Super User - Domestic';
            usr.profileName = 'Future Student Engagement';
            usr.role = 'Future_Student_Agent_Domestic';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetGroupNames = new Set<String>{'Future_Student_Super_Agent_Domestic'};
            usr.publicGroupNames = new Set<String>{'Future_Students_Domestic'};

            return usr;
        } set;
    }

    /******************************************
    * Future Student Super Team Leader Domestic 
    *******************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserFutureStudentSuperTeamLeaderDomestic() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOFutureStudentSuperTeamLeaderDomestic}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserFutureStudentSuperTeamLeaderDomestic {
        get {return [SELECT Id FROM User WHERE Email = 'TestFutureStudentSuperTeamLeaderDomestic@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOFutureStudentSuperTeamLeaderDomestic {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'FutureStudentSuperTeamLeaderDomestic';
            usr.Persona = 'Future Student Super Team Leader - Domestic';
            usr.profileName = 'Future Student Engagement';
            usr.role = 'Future_Student_Super_User_Domestic';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetGroupNames = new Set<String>{'Future_Student_Team_Leader_Domestic','Future_Student_Super_User_Domestic'};
            usr.publicGroupNames = new Set<String>{'Future_Students_Domestic'};

            return usr;
        } set;
    }

    /******************************************
    * Future Student Agent International
    *******************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserFutureStudentAgentInternational() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOFutureStudentAgentInternational}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserFutureStudentAgentInternational {
        get {return [SELECT Id FROM User WHERE Email = 'TestFutureStudentAgentInternational@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOFutureStudentAgentInternational {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'FutureStudentAgentInternational';
            usr.Persona = 'Future Student Agent - International';
            usr.profileName = 'Future Student Engagement';
            usr.role = 'Future_Student_Agent_International';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetGroupNames = new Set<String>{'Future_Student_Agent_International'};
            usr.publicGroupNames = new Set<String>{'Future_Students_International'};

            return usr;
        } set;
    }

    /******************************************
    * Future Student Team Leader Domestic
    *******************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserFutureStudentTeamLeaderDomestic() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOFutureStudentTeamLeaderDomestic}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserFutureStudentTeamLeaderDomestic {
        get {return [SELECT Id FROM User WHERE Email = 'TestFutureStudentTeamLeaderDomestic@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOFutureStudentTeamLeaderDomestic {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'FutureStudentTeamLeaderDomestic';
            usr.Persona = 'Future Student Team Leader - Domestic';
            usr.profileName = 'Future Student Engagement';
            usr.role = 'Future_Student_Team_Leader_Domestic';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetGroupNames = new Set<String>{'Future_Student_Team_Leader_Domestic'};
            usr.publicGroupNames = new Set<String>{'Future_Students_Domestic'};

            return usr;
        } set;
    }

    /******************************************
    * Future Student Reporting Domestic'
    *******************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserFutureStudentReportingDomestic() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOFutureStudentReportingDomestic}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserFutureStudentReportingDomestic {
        get {return [SELECT Id FROM User WHERE Email = 'TestFutureStudentReportingDomestic@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOFutureStudentReportingDomestic {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'FutureStudentReportingDomestic';
            usr.Persona = 'Future Student Reporting - Domestic';
            usr.profileName = 'Future Student Engagement';
            usr.role = 'Future_Student_Team_Leader_Domestic';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetGroupNames = new Set<String>{'Future_Student_Reporting_Domestic'};
            usr.publicGroupNames = new Set<String>{'Future_Students_Domestic'};

            return usr;
        } set;
    }

    /******************************************
    * Future Student Team Leader International
    *******************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserFutureStudentTeamLeaderInternational() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOFutureStudentTeamLeaderInternational}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserFutureStudentTeamLeaderInternational {
        get {return [SELECT Id FROM User WHERE Email = 'TestFutureStudentTeamLeaderInternational@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOFutureStudentTeamLeaderInternational {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'FutureStudentTeamLeaderInternational';
            usr.Persona = 'Future Student Team Leader - International';
            usr.profileName = 'Future Student Engagement';
            usr.role = 'Future_Student_Team_Leader_International';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetGroupNames = new Set<String>{'Future_Student_Team_Leader_International'};
            usr.publicGroupNames = new Set<String>{'Future_Students_International'};

            return usr;
        } set;
    }

    /******************************************
    * Future Student Super User Domestic
    *******************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserFutureStudentSuperUserDomestic() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOFutureStudentSuperUserDomestic}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserFutureStudentSuperUserDomestic {
        get {return [SELECT Id FROM User WHERE Email = 'TestFutureStudentSuperUserDomestic@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOFutureStudentSuperUserDomestic {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'FutureStudentSuperUserDomestic';
            usr.Persona = 'Future Student Super User - Domestic';
            usr.profileName = 'Future Student Engagement';
            usr.role = 'Future_Student_Super_User_Domestic';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetGroupNames = new Set<String>{'Future_Student_Super_User_Domestic'};
            usr.publicGroupNames = new Set<String>{'Future_Students_Domestic'};

            return usr;
        } set;
    }

    /***********************************************
    * Future Student Super Team Leader International
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserFutureStudentSuperTeamLeaderInternational() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOFutureStudentSuperTeamLeaderInternational}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserFutureStudentSuperTeamLeaderInternational {
        get {return [SELECT Id FROM User WHERE Email = 'TestFutureStudentSuperTeamLeaderInternational@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOFutureStudentSuperTeamLeaderInternational {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'FutureStudentSuperTeamLeaderInternational';
            usr.Persona = 'Future Student Super Team Leader - International';
            usr.profileName = 'Future Student Engagement';
            usr.role = 'Future_Student_Super_User_International';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetGroupNames = new Set<String>{'Future_Student_Team_Leader_International','Future_Student_Super_User_International'};
            usr.publicGroupNames = new Set<String>{'Future_Students_International'};

            return usr;
        } set;
    }

    /***********************************************
    * Future Student Super User International
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserFutureStudentSuperUserInternational() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOFutureStudentSuperUserInternational}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserFutureStudentSuperUserInternational {
        get {return [SELECT Id FROM User WHERE Email = 'TestFutureStudentSuperUserInternational@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOFutureStudentSuperUserInternational {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'FutureStudentSuperUserInternational';
            usr.Persona = 'Future Student Super User - International';
            usr.profileName = 'Future Student Engagement';
            usr.role = 'Future_Student_Super_User_International';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetGroupNames = new Set<String>{'Future_Student_Super_User_International'};
            usr.publicGroupNames = new Set<String>{'Future_Students_International'};

            return usr;
        } set;
    }

    /***********************************************
    * Industry Partnership Manager
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserIndustryPartnershipManager() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOIndustryPartnershipManager}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserIndustryPartnershipManager {
        get {return [SELECT Id FROM User WHERE Email = 'TestIndustryPartnershipManager@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOIndustryPartnershipManager {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'IndustryPartnershipManager';
            usr.Persona = 'Industry Partnership Manager';
            usr.profileName = 'Industry Engagement';
            usr.role = 'Partnership_Manager';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;


            usr.permissionsetGroupNames = new Set<String>{'Partnership_Manager'};
            usr.publicGroupNames = new Set<String>{'Research_Partnership_Manager','IPU_Partnership_Manager','Commercialisation_Partnership_Manager'};

            return usr;
        } set;
    }

    /***********************************************
    * Industry Operations Manager
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserIndustryOperationsManager() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOIndustryOperationsManager}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserIndustryOperationsManager {
        get {return [SELECT Id FROM User WHERE Email = 'TestIndustryOperationsManager@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOIndustryOperationsManager {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'IndustryOperationsManager';
            usr.Persona = 'Industry Operations Manager';
            usr.profileName = 'Industry Engagement';
            usr.role = 'Operations_Manager';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;


            usr.permissionsetGroupNames = new Set<String>{'Operations_Manager'};
            usr.publicGroupNames = new Set<String>{'Research_Partnership_Manager','IPU_Partnership_Manager','Commercialisation_Partnership_Manager'};

            return usr;
        } set;
    }

    /***********************************************
    * Industry VP Business Development
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserIndustryVPBusinessDevelopment() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOIndustryVPBusinessDevelopment}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserIndustryVPBusinessDevelopment {
        get {return [SELECT Id FROM User WHERE Email = 'TestIndustryVPBusinessDevelopment@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOIndustryVPBusinessDevelopment {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'IndustryVPBusinessDevelopment';
            usr.Persona = 'Industry VP Business Development';
            usr.profileName = 'Industry Engagement';
            usr.role = 'VP_Business_Development';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;


            usr.permissionsetGroupNames = new Set<String>{'VPBD_Director'};
            usr.publicGroupNames = new Set<String>{'Research_Partnership_Manager','IPU_Partnership_Manager','Commercialisation_Partnership_Manager','Research_Operations_Manager','IPU_Operations_Manager','Commercialisation_Operations_Manager'};

            return usr;
        } set;
    }

    /***********************************************
    * Industry Director Business Development 
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserIndustryDirectorBusinessDevelopment() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOIndustryDirectorBusinessDevelopment}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserIndustryDirectorBusinessDevelopment {
        get {return [SELECT Id FROM User WHERE Email = 'TestIndustryDirectorBusinessDevelopment@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOIndustryDirectorBusinessDevelopment {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'IndustryDirectorBusinessDevelopment';
            usr.Persona = 'Industry Director Business Development';
            usr.profileName = 'Industry Engagement';
            usr.role = 'Executive_Director_Business_Development';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;


            usr.permissionsetGroupNames = new Set<String>{'VPBD_Director'};
            usr.publicGroupNames = new Set<String>{'Research_Partnership_Manager','IPU_Partnership_Manager','Commercialisation_Partnership_Manager','Research_Operations_Manager','IPU_Operations_Manager','Commercialisation_Operations_Manager'};

            return usr;
        } set;
    }

    /***********************************************
    * Industry Engagement Super User 
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserIndustryEngagementSuperUser() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOIndustryEngagementSuperUser}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserIndustryEngagementSuperUser {
        get {return [SELECT Id FROM User WHERE Email = 'TestIndustryEngagementSuperUser@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOIndustryEngagementSuperUser {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'IndustryEngagementSuperUser';
            usr.Persona = 'Industry Engagement Super User';
            usr.profileName = 'Industry Engagement';
            usr.role = 'Industry_Engagement_Super_User';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;


            usr.permissionsetGroupNames = new Set<String>{'Partnership_Manager','Operations_Manager'};
            usr.publicGroupNames = new Set<String>{'Research_Partnership_Manager','IPU_Partnership_Manager','Commercialisation_Partnership_Manager','Research_Operations_Manager','IPU_Operations_Manager','Commercialisation_Operations_Manager'};

            return usr;
        } set;
    }

    /***********************************************
    *  QUT ESB
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTESB() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTESB}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTESB {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTESB@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTESB {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'QUTESB';
            usr.profileName = 'Integration';
            usr.role = 'None';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetNames = new Set<String>{'Permission_API_Only_User','Integration_Person','Integration_Webcart'};

            return usr;
        } set;
    }

    /***********************************************
    *  QUT Marketing Cloud
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTMarketingCloud() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTMarketingCloud}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTMarketingCloud {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTMarketingCloud@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTMarketingCloud {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'QUTMarketingCloud';
            usr.profileName = 'Integration Marketing';
            usr.role = 'None';
            

            usr.userpermissionsmarketinguser = true;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetNames = new Set<String>{'Permission_API_Only_User','Integration_Marketing','Marketing_Cloud_Connected_App'};

            return usr;
        } set;
    }

    /***********************************************
    * PORTAL/EXPERIECE USERS
    ************************************************/
    /***********************************************
    *  QUT Corporate Partner Admin
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTCorporatePartnerAdmin() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTCorporatePartnerAdmin}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTCorporatePartnerAdmin {
        get {return [SELECT Id FROM User WHERE Email = 'TestQUTCorporatePartnerAdmin@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTCorporatePartnerAdmin{
        get {

            getPortalSysAdminUser();
            System.runAs(portalSysAdmin){
                //Create account
                Account account = new Account();
                account.Name = 'CorporatePortalAdminAccount';
                insert account;
                //create contact
                Contact contact = new Contact();
                contact.FirstName = 'Test';
                contact.LastName = 'CorporatePortalAdmin';
                contact.Email = System.now().millisecond() + '@mailinator.com';
                contact.AccountId = account.Id;
                insert contact;
            }
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            
                usr.FirstName = 'Test';
                usr.LastName = 'QUTCorporatePartnerAdmin';
                usr.profileName = 'Corporate Partner';
                usr.contactId = con.Id;
                

                usr.userpermissionsmarketinguser = true;
                usr.userpermissionsknowledgeuser = false;
                usr.userpermissionsflowuser = true;
                usr.userpermissionsserviceuser = true;


                usr.permissionsetNames = new Set<String>{'Corporate_Partner'};

            return usr;
        } set;
    }

    /***********************************************
    *  QUT Corporate Partner User
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTCorporatePartnerUser() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTCorporatePartnerUser}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTCorporatePartnerUser {
        get {return [SELECT Id, AccountId FROM User WHERE Email = 'TestQUTCorporatePartnerUser@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTCorporatePartnerUser{
        get {
            getPortalSysAdminUser();
            System.runAs(portalSysAdmin){
                //Create account
                Account account = new Account();
                account.Name = 'CorporatePortalUserAccount';
                insert account;
                //create contact
                Contact contact = new Contact();
                contact.FirstName = 'Test';
                contact.LastName = 'CorporatePortalUser';
                contact.Email = System.now().millisecond() + '@mailinator.com';
                contact.AccountId = account.Id;
                insert contact;
            }
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
        
            usr.FirstName = 'Test';
            usr.LastName = 'QUTCorporatePartnerUser';
            usr.profileName = 'Corporate Partner';
            usr.contactId = con.Id;
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;


            usr.permissionsetNames = new Set<String>{'Corporate_Partner'};

            return usr;
            
        } set;
    }

    /***********************************************
    *  Student Success Outreach Manager
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserStudentSuccessOutreachManager() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOStudentSuccessOutreachManager}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserStudentSuccessOutreachManager {
        get {return [SELECT Id, AccountId FROM User WHERE Email = 'TestStudentSuccessOutreachManager@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOStudentSuccessOutreachManager{
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'StudentSuccessOutreachManager';
            usr.profileName = 'Student Success';
            usr.role = 'Student_Success_Outreach_Manager';
            
            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;

            usr.permissionsetGroupNames = new Set<String>{'Student_Success_Outreach_Manager'};
            usr.publicGroupNames = new Set<String>{'Student_Success_Outreach_Manager'};
            
            return usr;
        } set;
    }

    /***********************************************
    *  Student Success Outreach Staff
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserStudentSuccessOutreachStaff() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOStudentSuccessOutreachStaff}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserStudentSuccessOutreachStaff {
        get {return [SELECT Id, AccountId FROM User WHERE Email = 'TestStudentSuccessOutreachStaff@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOStudentSuccessOutreachStaff {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'StudentSuccessOutreachStaff';
            usr.profileName = 'Student Success';
            usr.role = 'Student_Success_Outreach_Staff';
            
            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;

            usr.permissionsetGroupNames = new Set<String>{'Student_Success_Outreach_Staff'};
            usr.publicGroupNames = new Set<String>{'Student_Success_Outreach_Staff'};
            
            return usr;
        } set;
    }

    /***********************************************
    *  Student Success Manager
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserStudentSuccessManager() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOStudentSuccessManager}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserStudentSuccessManager {
        get {return [SELECT Id, AccountId FROM User WHERE Email = 'TestStudentSuccessManager@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOStudentSuccessManager {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'StudentSuccessManager';
            usr.profileName = 'Student Success';
            usr.role = 'Student_Success_Manager';
            
            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;

            usr.permissionsetGroupNames = new Set<String>{'Student_Success_Manager'};
            usr.publicGroupNames = new Set<String>{'Student_Success_Manager'};
            
            return usr;
        } set;
    }

    /***********************************************
    *  Student Success Staff
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserStudentSuccessStaff() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOStudentSuccessStaff}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserStudentSuccessStaff {
        get {return [SELECT Id, AccountId FROM User WHERE Email = 'TestStudentSuccessStaff@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOStudentSuccessStaff {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'StudentSuccessStaff';
            usr.profileName = 'Student Success';
            usr.role = 'Student_Success_Staff';
            
            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;

            usr.permissionsetGroupNames = new Set<String>{'Student_Success_Staff'};
            usr.publicGroupNames = new Set<String>{'Student_Success_Staff'};
            
            return usr;
        } set;
    }

    /***********************************************
    *  Student Success Student Partner
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserStudentSuccessStudentPartner() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOStudentSuccessStudentPartner}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserStudentSuccessStudentPartner {
        get {return [SELECT Id, AccountId FROM User WHERE Email = 'TestStudentSuccessStudentPartner@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOStudentSuccessStudentPartner {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'StudentSuccessStudentPartner';
            usr.profileName = 'Student Success';
            usr.role = 'Student_Success_Student_Partner';
            
            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;

            usr.permissionsetGroupNames = new Set<String>{'Student_Success_Student_Partner'};
            usr.publicGroupNames = new Set<String>{'Student_Success_Student_Partner'};
            
            return usr;
        } set;
    }

    /***********************************************
    *  Student Success Student Volunteer
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserStudentSuccessStudentVolunteer() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOStudentSuccessStudentVolunteer}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserStudentSuccessStudentVolunteer {
        get {return [SELECT Id, AccountId FROM User WHERE Email = 'TestStudentSuccessStudentVolunteer@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOStudentSuccessStudentVolunteer {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'StudentSuccessStudentVolunteer';
            usr.profileName = 'Student Success';
            usr.role = 'Student_Success_Student_Volunteer';
            
            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;

            usr.permissionsetGroupNames = new Set<String>{'Student_Success_Student_Volunteer'};
            usr.publicGroupNames = new Set<String>{'Student_Success_Student_Volunteer'};
            
            return usr;
        } set;
    }

    /***********************************************
    *  Student Success Reporting
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserStudentSuccessReporting() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOStudentSuccessReporting}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserStudentSuccessReporting {
        get {return [SELECT Id, AccountId FROM User WHERE Email = 'TestStudentSuccessReporting@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOStudentSuccessReporting {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'StudentSuccessReporting';
            usr.profileName = 'Student Success';
            usr.role = 'Student_Success_Reporting';
            
            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;

            usr.permissionsetGroupNames = new Set<String>{'Student_Success_Reporting'};
            usr.publicGroupNames = new Set<String>{'Student_Success_Reporting'};
            
            return usr;
        } set;
    }

    /***********************************************
    *  QUT OPE Catalogue User
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserQUTOPECatalogueUser() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOQUTOPECatalogueUser}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserQUTOPECatalogueUser {
        get {return [SELECT Id, AccountId FROM User WHERE Email = 'TestQUTOPECatalogueUser@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOQUTOPECatalogueUser{
        get {
            getPortalSysAdminUser();
            System.runAs(portalSysAdmin){
                //Create account
                Account account = new Account();
                account.Name = 'QUTOPECatalogueAccount';
                insert account;
                //create contact
                Contact contact = new Contact();
                contact.FirstName = 'Test';
                contact.LastName = 'QUTOPECatalogueUser';
                contact.Email = System.now().millisecond() + '@mailinator.com';
                contact.AccountId = account.Id;
                insert contact;
            }
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
        
            usr.FirstName = 'Test';
            usr.LastName = 'QUTOPECatalogueUser';
            usr.profileName = 'OPE Catalogue';
            usr.contactId = con.Id;
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;


            usr.permissionsetNames = new Set<String>{'OPE_Catalogue'};

            return usr;
            
        } set;
    }

    /***********************************************
    * IT3.1 USERS
    ************************************************/

    /***********************************************
    * Alumni Engagement Manager
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserAlumniEngagementManager() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOAlumniEngagementManager}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserAlumniEngagementManager {
        get {return [SELECT Id FROM User WHERE Email = 'TestAlumniEngagementManager@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOAlumniEngagementManager {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'AlumniEngagementManager';
            usr.Persona = 'Alumni Engagement Manager';
            usr.profileName = 'Alumni & Corporate Partnerships';
            usr.role = 'Alumni_Engagement';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = false;
            usr.userpermissionsserviceuser = false;

            usr.permissionsetGroupNames = new Set<String>{'Alumni_Engagement'};
            usr.publicGroupNames = new Set<String>{'Alumni_Corporate_Partnerships'};

            return usr;
        } set;
    }

    /***********************************************
    * Corporate Partnerships Manager
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserCorporatePartnershipsManager() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOCorporatePartnershipsManager}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserCorporatePartnershipsManager {
        get {return [SELECT Id FROM User WHERE Email = 'TestCorporatePartnershipsManager@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOCorporatePartnershipsManager {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'CorporatePartnershipsManager';
            usr.Persona = 'Corporate Partnerships Manager';
            usr.profileName = 'Alumni & Corporate Partnerships';
            usr.role = 'Corporate_Partnerships';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = false;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetNames = new Set<String>{'Alumni_Corporate_Partnership_Base'};

            return usr;
        } set;
    }

    /***********************************************
    * Corporate Engagement Manager
    ************************************************/

    // Used in @testSetup to generate user in a test class
    public static void generateUserCorporateEngagementManager() {
        System.enqueueJob(new InsertUsersQueueable(new List<InsertUsersQueueable.UserDTO>{userDTOCorporateEngagementManager}));
    }
    
    // Used to get user already generated in test method
    public static User selectUserCorporateEngagementManager {
        get {return [SELECT Id FROM User WHERE Email = 'TestCorporateEngagementManager@mailinator.com' LIMIT 1];}set;
    }

    // object to create user
    private static InsertUsersQueueable.UserDTO userDTOCorporateEngagementManager {
        get {
            InsertUsersQueueable.UserDTO usr = new InsertUsersQueueable.UserDTO();
            usr.FirstName = 'Test';
            usr.LastName = 'CorporateEngagementManager';
            usr.Persona = 'Corporate Engagement Manager';
            usr.profileName = 'Alumni & Corporate Partnerships';
            usr.role = 'Corporate_Engagement';
            

            usr.userpermissionsmarketinguser = false;
            usr.userpermissionsknowledgeuser = true;
            usr.userpermissionsflowuser = true;
            usr.userpermissionsserviceuser = true;


            usr.permissionsetNames = new Set<String>{'Alumni_Corporate_Partnership_Base'};

            return usr;
        } set;
    }

    private static void getPortalSysAdminUser() {
        portalSysAdmin = [
            SELECT Id, UserRoleId
            FROM User
            WHERE
                IsActive = TRUE
                AND FirstName = 'Sys Admin'
                AND LastName = 'Integration User'
                AND (Profile.Name = 'QUT System Administrator'
                OR Profile.Name = 'System Administrator')
            LIMIT 1
        ];

        if(String.isBlank(portalSysAdmin.UserRoleId)){
            //add UserRole
            portalSysAdmin.UserRoleId = [
                SELECT Id
                FROM UserRole
                WHERE Name = 'System Administrator'
                LIMIT 1
            ]
            ?.Id;
            update portalSysAdmin;
        }
        
    }

}