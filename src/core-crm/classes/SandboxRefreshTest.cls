@isTest
public class SandboxRefreshTest {
    @testSetup
    static void setupMethod() {
        TestDataFactoryUser.generateUserSystemAdministrator();
    }
    
    @isTest
    public static void testSandboxRefresh() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {    
            Profile adminUserProfile = [SELECT Id FROM Profile WHERE Name = :SandboxRefresh.ADMIN_PROFILE_NAME]; 
            Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User']; 
            
            User adminUser = new User(Alias = 'adminU', Email='adminuser@qut.com.invalid', 
                EmailEncodingKey='UTF-8', LastName='TestingAdmin', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = adminUserProfile.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='adminuser@qut.com');
            
            User standardUser = new User(Alias = 'standt', Email='standarduser@qut.com.invalid', 
                EmailEncodingKey='UTF-8', LastName='TestingStandard', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = standardUserProfile.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@qut.com');
            
            User otherUser = new User(Alias = 'otherU', Email='otheruser@qut.com.invalid', 
                EmailEncodingKey='UTF-8', LastName='TestingOther', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = standardUserProfile.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='otheruser@qut.com');
            
            List<User> users = new List<User>();
            users.add(adminUser);
            users.add(standardUser);
            users.add(otherUser);
            insert users;
            
            PermissionSet manageSandboxPermSet = [SELECT Id FROM PermissionSet WHERE Name = :SandboxRefresh.MANAGE_SANDBOX_NAME];
            insert new PermissionSetAssignment(AssigneeId = standardUser.id, PermissionSetId = manageSandboxPermSet.Id);
            
            Test.startTest();
            Test.testSandboxPostCopyScript(
                    new SandboxRefresh(), 
                    UserInfo.getOrganizationId(),
                    UserInfo.getOrganizationId(), 
                    UserInfo.getOrganizationName()
                ); 
            Test.stopTest();
            
            List<User> validateUsers = [SELECT Id, Profile.Name, Email, LastName FROM User WHERE LastName = 'TestingAdmin' OR LastName = 'TestingStandard' OR LastName = 'TestingOther'];
            
            for(User user : validateUsers) {
                if(user.LastName == 'TestingAdmin') {
                    System.assertEquals('adminuser@qut.com', user.Email, 'Invalid should be removed from email address.');
                    System.assertEquals(SandboxRefresh.ADMIN_PROFILE_NAME, user.Profile.Name, 'System Administrator should be the profile.');
                }
                
                if(user.LastName == 'TestingStandard') {
                    System.assertEquals('standarduser@qut.com', user.Email, 'Invalid should be removed from email address.');
                    System.assertEquals(SandboxRefresh.ADMIN_PROFILE_NAME, user.Profile.Name, 'System Administrator should be the profile.');
                }
                
                if(user.LastName == 'TestingOther') {
                    System.assertEquals('otheruser@qut.com.invalid', user.Email, 'Invalid should not be removed from email address.');
                    System.assertEquals('Standard User', user.Profile.Name, 'System Administrator should not be the profile.');
                }
            }
        }  
    }
    
}