public with sharing class SandboxRefresh implements SandboxPostCopy{
    
    public static final String ADMIN_PROFILE_NAME = 'System Administrator';
    public static final String MANAGE_SANDBOX_NAME = 'Manage_Sandboxes';
    
    public void runApexClass(SandboxContext context) {
        if (!isSandbox() && !Test.isRunningTest()) {
            return;
        }
        
        changeUsersProfileAndEmail();
        //Batch To Invalidate the accounts, contact and lead email
        InvalidateFieldValuesBatch invalidateAccount = new InvalidateFieldValuesBatch();
        InvalidateFieldValuesBatch invalidateContact = new InvalidateFieldValuesBatch();
        InvalidateFieldValuesBatch invalidateLead = new InvalidateFieldValuesBatch();
        invalidateAccount.invalidateFieldsForObject('Account', new Set<String>{'Phone'}, true);
        invalidateContact.invalidateFieldsForObject('Contact', new Set<String>{'Email','Personal_Email__c','Registered_Email__c','QUT_Staff_Email__c','QUT_Learner_Email__c', 'MobilePhone','Personal_Mobile__c'}, true);
        invalidateLead.invalidateFieldsForObject('Lead', new Set<String>{'Email','Personal_Email__c','Work_Email__c', 'MobilePhone','Personal_Mobile__c'}, true);
    }
    
    @future
    public static void changeUsersProfileAndEmail() {
        List<Id> userIdsWithManageSandbox = new List<Id>();
        
        for (PermissionSetAssignment psa : [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = :MANAGE_SANDBOX_NAME]) {
            userIdsWithManageSandbox.add(psa.AssigneeId);
        }
        
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = :ADMIN_PROFILE_NAME LIMIT 1].Id;
        
        List<User> usersToUpdateProfileAndEmail = [SELECT Id, Email, IsActive, ProfileId FROM User WHERE (Id IN :userIdsWithManageSandbox OR ProfileId = :adminProfileId) AND IsActive = true];
        
        for (User u : usersToUpdateProfileAndEmail) {
            if (u.ProfileId != adminProfileId) {
                u.ProfileId = adminProfileId;    
            }
            u.Email = u.Email.replace('.invalid', '');
        }
        update usersToUpdateProfileAndEmail;
        

    }
    
    private Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
}