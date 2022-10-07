/**
 * @description Class for creating CCE Corporate User
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                      |
      |---------------------------|-----------------------|----------------------|-------------------------------------|
      | eccarius.munoz            | August 08, 2022       | DEPP-3488            | Created File                        |
      | julie.jane.alegre         | September 12, 2022    | DEPP-4270            | Pass the value of Contact Name      |
      |                           |                       |                      | to communityNickname of the user    | 
      | eccarius.munoz            | September 13, 2022    | DEPP-4096            | Updated logic to handle enabling    |     
      |                           |                       |                      | user with existing ope user         | 
      | roy.nino.s.regala         | September 13, 2022    | DEPP-4096            | added work email requirement        | 
      | eccarius.munoz            | September 19, 2022    | DEPP-4366            | Added handling for business org     |     
      |                           |                       |                      | account validation.                 |              
 */
public without sharing class CCECorporateUserCtrl { 

    /**
     * Enables Corporate User
     * @param <String> - record Id of the contact.
     * @return <String> - response
     */
    @AuraEnabled
    public static CorporateUserDetails enableCCECorporateUser(String recordId){
        CorporateUserDetails response = new CorporateUserDetails();
        Savepoint savePoint = Database.setSavepoint();
        try{
            Contact contact = new Contact();
            Boolean hasOpeUser = false;
            String ccefilter;
            String opefilter;
            String emailToUse;            

            //Retrieves Contact details
            List<Contact> contacts = [SELECT Id, AccountId, Account.Name, hed__Primary_Organization__c, Email, Work_Email__c, FirstName, LastName, Name FROM Contact WHERE Id =: recordId LIMIT 1];
            for(Contact con : contacts){
                if(String.IsBlank(con.Work_Email__c)){
                    response.isSuccess = false;
                    response.errorMessage = 'Please make sure to populate Work Email before enabling this contact as partner user.';
                    return response;
                }
                if(String.IsBlank(con.hed__Primary_Organization__c)){
                    response.isSuccess = false;
                    response.errorMessage = 'Please make sure to populate Primary Business Account before enabling this contact as partner user.';
                    return response;
                }
                emailToUse = con.Work_Email__c;
                ccefilter = con.Work_Email__c + '.cce';
                opefilter = con.Email + '.ope';
                contact = con;
            }

            Profile profile = [SELECT Id FROM Profile WHERE Name = 'Partner Community User' LIMIT 1];
            Id userId;
            
            List<User> users = [SELECT Id, Username FROM User WHERE ContactId =: contact.Id AND (Username =: ccefilter OR (Username =: opefilter AND IsActive = true)) LIMIT 1];
            List<User> usersToUpdate = new List<User>();    
            for(User user : users){
                //Disables existing ope user
                if(user.Username.endsWith('.ope')){
                    user.IsActive = false;
                    user.IsPortalEnabled = false;
                    hasOpeUser = true;
                }else{
                    //Enables existing cce user
                    userId = user.Id;
                    user.IsActive = true;
                    user.profileId = profile.Id;
                }
                usersToUpdate.add(user);
            }
            if(usersToUpdate.size() > 0){
                update usersToUpdate;
            }
            
            if(!hasOpeUser){
                //Creates new cce user if not yet existing
                List<User> usersToCreate = new List<User>();
                if(users.isEmpty()){                
                    User commerceUser = new User();
                    commerceUser.IsActive = true;
                    commerceUser.Username = emailToUse + '.cce';
                    commerceUser.Email = emailToUse;
                    commerceUser.LastName = contact.LastName;
                    commerceUser.FirstName = contact.FirstName;
                    commerceUser.ContactId = contact.Id;
                    commerceUser.alias = contact.FirstName.substring(0, 1) + contact.LastName.substring(0, 2);
                    commerceUser.LanguageLocaleKey = 'en_US';
                    commerceUser.localesidkey = 'en_AU';
                    commerceUser.emailEncodingKey = 'UTF-8';
                    commerceUser.timeZoneSidKey = 'Australia/Brisbane';
                    commerceUser.profileId = profile.Id;
                    usersToCreate.add(commerceUser);
                }
                if(usersToCreate.size() > 0){
                    insert usersToCreate;
                }

                for(User user : usersToCreate){
                    userId = user.Id;
                }

                //Assign Permission Sets to the existing/new user
                List<String> permsetLabelList = new List<String>{'Corporate Portal Base', 'Account Switcher User​'};
                List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();
                List<PermissionSet> permsets = [SELECT Id FROM PermissionSet WHERE Label IN : permsetLabelList];
                List<PermissionSetAssignment> userPermSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN : permsets AND AssigneeId = : userId];
                if(userPermSetAssignments.isEmpty()){
                    for(PermissionSet perm: permsets){
                        PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
                            PermissionSetId = perm.Id, 
                            AssigneeId = userId
                        );
                        permSetAssignments.add(permSetAssignment);
                    }

                    if(permSetAssignments.size() > 0){
                        upsert permSetAssignments;
                    }
                }
            }

            response.isSuccess = true;
            response.contactId = contact.Id;
            response.hasOpeUser = hasOpeUser;
            response.email = emailToUse;
            response.contactLastName = contact.LastName;
            response.contactFirstName = contact.FirstName;
            response.accountId = contact.AccountId;
            response.primaryBusinessAcctId = contact.hed__Primary_Organization__c;
            response.accountName = contact.Account.Name;
            response.userId = userId;    

        }catch(Exception e){
            Database.rollback(savePoint);
            response.isSuccess = false;
            response.errorMessage = e.getMessage();
        }
        return response;
    }
    
    /**
     * Enables Corporate User for Contact with existing OPE User
     * @param <String> - contactId
     * @param <String> - contactFirstName
     * @param <String> - contactLastName
     * @param <String> - email
     * @return <Id> - userId
     */
    @AuraEnabled
    public static Id enableCCECorporateUserForOPE(String recordId, String contactFirstName, String contactLastName, String email){
        Savepoint savePoint = Database.setSavepoint();
        Id userId;
        try {
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'Partner Community User' LIMIT 1];

            List<User> usersToCreate = new List<User>();
            User commerceUser = new User();
            commerceUser.IsActive = true;
            commerceUser.Username = email + '.cce';
            commerceUser.Email = email;
            commerceUser.LastName = contactLastName;
            commerceUser.FirstName = contactFirstName;
            commerceUser.ContactId = recordId;
            commerceUser.alias = contactFirstName.substring(0, 1) + contactLastName.substring(0, 2);
            commerceUser.LanguageLocaleKey = 'en_US';
            commerceUser.localesidkey = 'en_AU';
            commerceUser.emailEncodingKey = 'UTF-8';
            commerceUser.timeZoneSidKey = 'Australia/Brisbane';
            commerceUser.profileId = profile.Id;
            usersToCreate.add(commerceUser);
            if(usersToCreate.size() > 0){
                insert usersToCreate;
            }
            for(User user : usersToCreate){
                userId = user.Id;
            }
            //Assign Permission Sets to the existing/new user
            List<String> permsetLabelList = new List<String>{'Corporate Portal Base', 'Account Switcher User​'};
            List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();
            List<PermissionSet> permsets = [SELECT Id FROM PermissionSet WHERE Label IN : permsetLabelList];
            List<PermissionSetAssignment> userPermSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN : permsets AND AssigneeId = : userId];
            if(userPermSetAssignments.isEmpty()){
                for(PermissionSet perm: permsets){
                    PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
                        PermissionSetId = perm.Id, 
                        AssigneeId = userId
                    );
                    permSetAssignments.add(permSetAssignment);
                }
                if(permSetAssignments.size() > 0){
                    upsert permSetAssignments;
                }
            }
        } catch (Exception e) {  
            Database.rollback(savePoint);
            throw new AuraHandledException(e.getMessage());
        }
        return userId;
    }

    /**
     * Disables Corporate User
     * @param <String> - record Id of the contact.
     * @return <String> - response
     */
    @AuraEnabled
    public static String disableCCECorporateUser(String recordId){
        String response;
        try {
            Boolean isCreateCCEUser = true;
            String ccefilter;
            String opefilter;
            
            Contact contact = new Contact();
            List<Contact> contacts = [SELECT Id, Email, Work_Email__c, FirstName, LastName FROM Contact WHERE Id =: recordId LIMIT 1];
            for(Contact con : contacts){
                if(String.isBlank(con.Work_Email__c)){
                    ccefilter = con.Email + '.cce';
                    opefilter = con.Email + '.ope';
                }else{
                    ccefilter = con.Work_Email__c + '.cce';
                    opefilter = con.Work_Email__c + '.ope';
                }
                contact = con;                
            }
            Id userId;

            //Disable existing user
            List<User> users = [SELECT Id, IsActive FROM User WHERE ContactId  =: contact.Id AND (Username =: ccefilter OR Username =: opefilter) LIMIT 1];
            List<User> usersToUpdate = new List<User>();
            for(User user : users){
                userId = user.Id;
                user.IsActive = false;
                usersToUpdate.add(user);
            }
            update usersToUpdate;

            //Remove Permission Set from the existing user
            List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();
            Set<Id> permSetIdSet = new Set<Id>();
            List<PermissionSet> permsets = [SELECT Id FROM PermissionSet WHERE Label IN ('Corporate Portal Base', 'Account Switcher User​')];
            for(PermissionSet perm: permsets){
                permSetIdSet.add(perm.Id);
            }
            List<PermissionSetAssignment> permissionAssignments = [SELECT Id from PermissionSetAssignment WHERE PermissionSetId IN : permSetIdSet AND AssigneeId = : userId];
            delete permissionAssignments;
            
            response = 'Success';
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        

        return response;
    }

    /**
     * Creates External Managed Account
     * @param <String> - accountId
     * @param <String> - primaryBusinessAcctId
     * @param <String> - accountName
     * @param <String> - userId
     * @return <String>
     */
    @AuraEnabled    
    public static String createExtManagedAcct(Id accountId, Id primaryBusinessAcctId, String accountName, Id userId){
        List<DelegatedAccount> delegatedAcctList = [
            SELECT Id 
            FROM DelegatedAccount 
            WHERE TargetId =: primaryBusinessAcctId
            AND ManagedById =: userId];
        if(delegatedAcctList.isEmpty()){
            DelegatedAccount delegatedAcct = new DelegatedAccount();
            delegatedAcct.TargetId = primaryBusinessAcctId;
            delegatedAcct.ManagedById = userId;
            delegatedAcct.AccessBuyFor = true;
            delegatedAcct.Name = accountName;
            //delegatedAcct.ParentId = primaryBusinessAcctId;
            insert delegatedAcct;
        }
        return 'Success';
    }   

    public class CorporateUserDetails{
        @AuraEnabled
        public String contactId;        
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String contactLastName;
        @AuraEnabled
        public String contactFirstName;
        @AuraEnabled
        public Boolean hasOpeUser;
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String primaryBusinessAcctId;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String userId;
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String errorMessage;
    }
}
