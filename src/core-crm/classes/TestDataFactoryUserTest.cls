/**
 * @description Test class that contains reusable method for test data creation
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                           |
 *    |---------------------------|-----------------------|---------------------|------------------------------------------|
 *    | julie.jane.alegre         | April 16, 2024        | DEPP-8016           | Created file                             |
 **/

 @isTest
 public with sharing class TestDataFactoryUserTest {
    @testSetup
    static void testSetup() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }

    @isTest
    static void generateUserSystemAdministratorTest() {
        Test.startTest();
        User user = TestDataFactoryUser.selectUserSystemAdministrator;
        List<String> permissionsetGroupNames = new List<String>{'Persona_System_Administrator'};
        List<PermissionSetGroup> permsetGroupList = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN:permissionsetGroupNames];
        Map<Id, String> permsetGroupMap = getRelatedPermsetGroups(user.Id);
    
        for(PermissionSetGroup psg: permsetGroupList){
            Assert.areEqual(psg.DeveloperName, permsetGroupMap.get(psg.Id), 'Permission Set Group is not assigned properly');
        }

        Test.stopTest();
    }

    private static Map<Id, String> getRelatedPermsets(Id userId){
        Map<Id, String> permsetMap = new Map<Id, String>();
        List<PermissionSetAssignment> permsetList = [SELECT Id, AssigneeId, PermissionSetId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: userId];
        for(PermissionSetAssignment psa: permsetList){
            permsetMap.put(psa.PermissionSetId, psa.PermissionSet.Name);
        }
        
        return permsetMap;
    }

    private static Map<Id, String> getRelatedPermsetGroups(Id userId){
        Map<Id, String> permsetGroupMap = new Map<Id, String>();
        List<PermissionSetAssignment> permsetGroupList = [SELECT Id, AssigneeId, PermissionSetGroupId, PermissionSetGroup.DeveloperName FROM PermissionSetAssignment WHERE AssigneeId =: userId];
        for(PermissionSetAssignment psa: permsetGroupList){
            permsetGroupMap.put(psa.PermissionSetGroupId, psa.PermissionSetGroup.DeveloperName);
        }
        
        return permsetGroupMap;
    }

}
