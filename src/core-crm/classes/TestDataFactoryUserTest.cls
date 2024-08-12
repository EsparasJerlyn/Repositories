/**
 * @description Test class that contains reusable method for test data creation
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                                             |
 *    |---------------------------|-----------------------|---------------------|----------------------------------------------------------------------------|
 *    | julie.jane.alegre         | April 16, 2024        | DEPP-8016           | Created file                                                               |
 *    | neil.s.h.lesidan          | August 7, 2024        | DEPP-10226          | Create method generateUserAlumniEngagementTest                             |
 **/

 @isTest
 public with sharing class TestDataFactoryUserTest {

    @testSetup
    static void testSetup() {

        //Generate Test Users
        TestDataFactoryUser.generateUserSysAdminIntegration();
        TestDataFactoryUser.generateUserSystemAdministrator();
        TestDataFactoryUser.generateUserSystemAdministratorModifyAllData();
        TestDataFactoryUser.generateUserSystemAdministratorReadOnly();
        TestDataFactoryUser.generateUserDevelopmentTeam();
        TestDataFactoryUser.generateUserQUTeXExecutiveDirector();
        TestDataFactoryUser.generateUserQUTeXBusinessManager();
        TestDataFactoryUser.generateUserQUTeXDirectorOPE();
        TestDataFactoryUser.generateUserQUTeXPortfolioCoordinator();
        TestDataFactoryUser.generateUserQUTeXProductAdministrator();
        TestDataFactoryUser.generateUserQUTeXLearningInnovationManager();
        TestDataFactoryUser.generateUserAlumniEngagementManager();

    }

    @isTest
    static void generateUserSysAdminIntegrationTest() {

          //Select user generated
          User user = TestDataFactoryUser.selectUserSysAdminIntegration;
  
          //List of permission set group assigned
          List<String> permissionsetGroupNames = new List<String>{'Persona_System_Administrator'};
  
          //List of permission sets assigned
          List<String> permissionSetNames = new List<String>{'System_Administrator'};
  
          Test.startTest();
  
          Map<Id, String> permsetGroupMap = getRelatedPermsetGroups(user.Id);
          Map<Id, String> permSetMap = getRelatedPermsets(user.Id);
  
          List<PermissionSetGroup> permsetGroupList = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN:permissionsetGroupNames];
          List<PermissionSet> permsetList = [SELECT Id, Name FROM PermissionSet WHERE Name IN:permissionSetNames];
      
          for(PermissionSetGroup psg: permsetGroupList){
              Assert.areEqual(psg.DeveloperName, permsetGroupMap.get(psg.Id), 'Permission Set Group is not assigned properly');
          }
  
          for(PermissionSet ps: permsetList){
              Assert.areEqual(ps.Name, permSetMap.get(ps.Id), 'Permission Set is not assigned properly');
          }
  
          Test.stopTest();
    }

    @isTest
    static void generateUserSystemAdministratorTest() {

          //Select user generated
          User user = TestDataFactoryUser.selectUserSystemAdministrator;
  
          //List of permission set group assigned
          List<String> permissionsetGroupNames = new List<String>{'Persona_System_Administrator'};
  
          Test.startTest();
  
          Map<Id, String> permsetGroupMap = getRelatedPermsetGroups(user.Id);
  
          List<PermissionSetGroup> permsetGroupList = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN:permissionsetGroupNames];
      
          for(PermissionSetGroup psg: permsetGroupList){
              Assert.areEqual(psg.DeveloperName, permsetGroupMap.get(psg.Id), 'Permission Set Group is not assigned properly');
          }
  
          Test.stopTest();
    }

    @isTest
    static void generateUserSystemAdministratorModifyAllDataTest() {

          //Select user generated
          User user = TestDataFactoryUser.selectUserSystemAdministratorModifyAllData;
  
          //List of permission set group assigned
          List<String> permissionsetGroupNames = new List<String>{'Persona_System_Administrator_Modify_All_Data'};
  
          //List of permission sets assigned
          List<String> permissionSetNames = new List<String>{'Permission_Multi_Factor_Authentication_for_User_Interface_Logins'};
  
          Test.startTest();
  
          Map<Id, String> permsetGroupMap = getRelatedPermsetGroups(user.Id);
          Map<Id, String> permSetMap = getRelatedPermsets(user.Id);
  
          List<PermissionSetGroup> permsetGroupList = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN:permissionsetGroupNames];
          List<PermissionSet> permsetList = [SELECT Id, Name FROM PermissionSet WHERE Name IN:permissionSetNames];
      
          for(PermissionSetGroup psg: permsetGroupList){
              Assert.areEqual(psg.DeveloperName, permsetGroupMap.get(psg.Id), 'Permission Set Group is not assigned properly');
          }
  
          for(PermissionSet ps: permsetList){
              Assert.areEqual(ps.Name, permSetMap.get(ps.Id), 'Permission Set is not assigned properly');
          }
  
          Test.stopTest();
    }

    @isTest
    static void generateUserSystemAdministratorReadOnlyTest() {

          //Select user generated
          User user = TestDataFactoryUser.selectUserSystemAdministratorReadOnly;
  
          //List of permission set group assigned
          List<String> permissionsetGroupNames = new List<String>{'Persona_System_Administrator'};
  
          //List of permission sets assigned
          List<String> permissionSetNames = new List<String>{'Permission_Multi_Factor_Authentication_for_User_Interface_Logins'};
  
          Test.startTest();
  
          Map<Id, String> permsetGroupMap = getRelatedPermsetGroups(user.Id);
          Map<Id, String> permSetMap = getRelatedPermsets(user.Id);
  
          List<PermissionSetGroup> permsetGroupList = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN:permissionsetGroupNames];
          List<PermissionSet> permsetList = [SELECT Id, Name FROM PermissionSet WHERE Name IN:permissionSetNames];
      
          for(PermissionSetGroup psg: permsetGroupList){
              Assert.areEqual(psg.DeveloperName, permsetGroupMap.get(psg.Id), 'Permission Set Group is not assigned properly');
          }
  
          for(PermissionSet ps: permsetList){
              Assert.areEqual(ps.Name, permSetMap.get(ps.Id), 'Permission Set is not assigned properly');
          }
  
          Test.stopTest();
    }

    @isTest
    static void generateUserDevelopmentTeamTest() {

          //Select user generated
          User user = TestDataFactoryUser.selectUserDevelopmentTeam;
  
          //List of permission set group assigned
          List<String> permissionsetGroupNames = new List<String>{'Persona_Development_Team'};
  
          //List of permission sets assigned
          List<String> permissionSetNames = new List<String>{'Permission_Multi_Factor_Authentication_for_User_Interface_Logins'};
  
          Test.startTest();
  
          Map<Id, String> permsetGroupMap = getRelatedPermsetGroups(user.Id);
          Map<Id, String> permSetMap = getRelatedPermsets(user.Id);
  
          List<PermissionSetGroup> permsetGroupList = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN:permissionsetGroupNames];
          List<PermissionSet> permsetList = [SELECT Id, Name FROM PermissionSet WHERE Name IN:permissionSetNames];
      
          for(PermissionSetGroup psg: permsetGroupList){
              Assert.areEqual(psg.DeveloperName, permsetGroupMap.get(psg.Id), 'Permission Set Group is not assigned properly');
          }
  
          for(PermissionSet ps: permsetList){
              Assert.areEqual(ps.Name, permSetMap.get(ps.Id), 'Permission Set is not assigned properly');
          }
  
          Test.stopTest();
    }

    @isTest
    static void generateUserQUTeXExecutiveDirectorTest() {

          //Select user generated
          User user = TestDataFactoryUser.selectUserQUTeXExecutiveDirector;
  
          //List of permission sets assigned
          List<String> permissionSetNames = new List<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader','Marketing','DocuSign_Generator','DocuSign_Negotiator','DocuSign_Sender','DocuSign_User','Permission_API_Enabled'};
  
          Test.startTest();
  
          Map<Id, String> permSetMap = getRelatedPermsets(user.Id);
  
          List<PermissionSet> permsetList = [SELECT Id, Name FROM PermissionSet WHERE Name IN:permissionSetNames];
      
          for(PermissionSet ps: permsetList){
              Assert.areEqual(ps.Name, permSetMap.get(ps.Id), 'Permission Set is not assigned properly');
          }
  
          Test.stopTest();
    }

    @isTest
    static void generateUserQUTeXBusinessManagerTest() {

          //Select user generated
          User user = TestDataFactoryUser.selectUserQUTeXBusinessManager;
  
          //List of permission sets assigned
          List<String> permissionSetNames = new List<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader','DocuSign_Generator','DocuSign_Negotiator','DocuSign_Sender','DocuSign_User','Permission_API_Enabled'};
  
          Test.startTest();
  
          Map<Id, String> permSetMap = getRelatedPermsets(user.Id);
  
          List<PermissionSet> permsetList = [SELECT Id, Name FROM PermissionSet WHERE Name IN:permissionSetNames];
      
          for(PermissionSet ps: permsetList){
              Assert.areEqual(ps.Name, permSetMap.get(ps.Id), 'Permission Set is not assigned properly');
          }
  
          Test.stopTest();
    }

    @isTest
    static void generateUserQUTeXDirectorOPETest() {

          //Select user generated
          User user = TestDataFactoryUser.selectUserQUTeXDirectorOPE;
  
          //List of permission sets assigned
          List<String> permissionSetNames = new List<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader','DocuSign_Generator','DocuSign_Negotiator','DocuSign_Sender','DocuSign_User','Permission_API_Enabled'};
  
          Test.startTest();
  
          Map<Id, String> permSetMap = getRelatedPermsets(user.Id);
  
          List<PermissionSet> permsetList = [SELECT Id, Name FROM PermissionSet WHERE Name IN:permissionSetNames];
      
          for(PermissionSet ps: permsetList){
              Assert.areEqual(ps.Name, permSetMap.get(ps.Id), 'Permission Set is not assigned properly');
          }
  
          Test.stopTest();
    }

    @isTest
    static void generateUserQUTeXPortfolioCoordinatorTest() {

          //Select user generated
          User user = TestDataFactoryUser.selectUserQUTeXPortfolioCoordinator;
  
          //List of permission sets assigned
          List<String> permissionSetNames = new List<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader'};
  
          Test.startTest();
  
          Map<Id, String> permSetMap = getRelatedPermsets(user.Id);
  
          List<PermissionSet> permsetList = [SELECT Id, Name FROM PermissionSet WHERE Name IN:permissionSetNames];
      
          for(PermissionSet ps: permsetList){
              Assert.areEqual(ps.Name, permSetMap.get(ps.Id), 'Permission Set is not assigned properly');
          }
  
          Test.stopTest();
    }

    @isTest
    static void generateUserQUTeXProductAdministratorTest() {

          //Select user generated
          User user = TestDataFactoryUser.selectUserQUTeXProductAdministrator;
  
          //List of permission sets assigned
          List<String> permissionSetNames = new List<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader','Email_Template_Management'};
  
          Test.startTest();
  
          Map<Id, String> permSetMap = getRelatedPermsets(user.Id);
  
          List<PermissionSet> permsetList = [SELECT Id, Name FROM PermissionSet WHERE Name IN:permissionSetNames];
      
          for(PermissionSet ps: permsetList){
              Assert.areEqual(ps.Name, permSetMap.get(ps.Id), 'Permission Set is not assigned properly');
          }
  
          Test.stopTest();
    }

    @isTest
    static void generateUserQUTeXLearningInnovationManagerTest() {

          //Select user generated
          User user = TestDataFactoryUser.selectUserQUTeXLearningInnovationManager;
  
          //List of permission sets assigned
          List<String> permissionSetNames = new List<String>{'QUTeX_Base','QUTeX_CCE','QUTeX_Leader'};
  
          Test.startTest();
  
          Map<Id, String> permSetMap = getRelatedPermsets(user.Id);
  
          List<PermissionSet> permsetList = [SELECT Id, Name FROM PermissionSet WHERE Name IN:permissionSetNames];
      
          for(PermissionSet ps: permsetList){
              Assert.areEqual(ps.Name, permSetMap.get(ps.Id), 'Permission Set is not assigned properly');
          }
  
          Test.stopTest();
    }

    @isTest
    static void generateUserAlumniEngagementTest() {

          //Select user generated
          User user = TestDataFactoryUser.selectUserAlumniEngagementManager;

          //List of permission set group assigned
          List<String> permissionsetGroupNames = new List<String>{'Alumni_Engagement'};

          Test.startTest();

          Map<Id, String> permsetGroupMap = getRelatedPermsetGroups(user.Id);
          List<PermissionSetGroup> permsetGroupList = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN:permissionsetGroupNames];

          for(PermissionSetGroup psg: permsetGroupList){
              Assert.areEqual(psg.DeveloperName, permsetGroupMap.get(psg.Id), 'Permission Set Group is not assigned properly');
          }

          Test.stopTest();
    }


    //Returns a map of Related Permsets
    private static Map<Id, String> getRelatedPermsets(Id userId){
        Map<Id, String> permsetMap = new Map<Id, String>();
        List<PermissionSetAssignment> permsetList = [SELECT Id, AssigneeId, PermissionSetId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: userId];
        for(PermissionSetAssignment psa: permsetList){
            permsetMap.put(psa.PermissionSetId, psa.PermissionSet.Name);
        }
        
        return permsetMap;
    }

    //Returns a map of Related Permset Groups
    private static Map<Id, String> getRelatedPermsetGroups(Id userId){
        Map<Id, String> permsetGroupMap = new Map<Id, String>();
        List<PermissionSetAssignment> permsetGroupList = [SELECT Id, AssigneeId, PermissionSetGroupId, PermissionSetGroup.DeveloperName FROM PermissionSetAssignment WHERE AssigneeId =: userId];
        for(PermissionSetAssignment psa: permsetGroupList){
            permsetGroupMap.put(psa.PermissionSetGroupId, psa.PermissionSetGroup.DeveloperName);
        }
        
        return permsetGroupMap;
    }



}