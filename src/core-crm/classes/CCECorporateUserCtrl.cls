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
      | arsenio.jr.dayrit         | January 17, 2023      | DEPP-4925            | added handling for OPE enablement   |
      | eugene.andrew.abuan       | February 10, 2023     | DEPP-4991            | Added Administrative Acc access     |


 */
public without sharing class CCECorporateUserCtrl { 

    /**
     * Enables Corporate User
     * @param <String> - record Id of the contact.
     * @return <String> - response
     */
    @AuraEnabled
    public static CorporateUserDetails enablePortalUser(String recordId, String portalAccessType){
        CorporateUserDetails response = new CorporateUserDetails();
        Savepoint savePoint = Database.setSavepoint();
        try{
            Contact contact = new Contact();
            Boolean hasOpeUser = false;
            String ccefilter;
            String opefilter;
            String emailToUse;
            String administrativeId = '';
            String administrativeAccName = '';           

            //Retrieves Contact details
            List<Contact> contacts = [SELECT Id, AccountId, Account.Name, hed__Primary_Organization__c, Email, Work_Email__c, FirstName, LastName, Name, Registered_Email__c, MobilePhone FROM Contact WHERE Id =: recordId WITH SECURITY_ENFORCED LIMIT 1];
            for(Contact con : contacts){
                //store AccountName and Account Id in the variables above
                if(String.IsNotBlank(con.AccountId) && String.IsNotBlank(con.Account.Name)){
                    administrativeId = con.AccountId;
                    administrativeAccName = con.Account.Name;
                }

                ValidateContactInputResponse validateConInput = validateContactInput(con, portalAccessType);
                if(!validateConInput.isSuccess){
                    response.isSuccess = validateConInput.isSuccess;
                    response.errorMessage = validateConInput.errorMessage;
                    return response;
                }

                emailToUse = con.Work_Email__c;
                ccefilter = con.Work_Email__c + '.cce';
                opefilter = con.Registered_Email__c + '.ope';
                contact = con;
            }

            Id userId;
            Boolean hasCCEUser = false;
            List<User> users = [SELECT Id, Username FROM User WHERE ContactId =: contact.Id AND (Username =: ccefilter OR (Username =: opefilter AND IsActive = true)) WITH SECURITY_ENFORCED LIMIT 1];
            List<User> usersToUpdate = new List<User>();
            if(users.size() == 0){
                List<User> checkEmailToUseUser = [SELECT Id, Username, Email FROM User WHERE ContactId =: contact.Id LIMIT 1];
                for( User checkUser : checkEmailToUseUser )
                if(emailToUse.contains(checkUser.Email) ||  opefilter.contains(checkUser.Email)){
                    users = checkEmailToUseUser;
                }
                if(portalAccessType == 'Product Catalogue'){
                    response.isNoUpdateNeeded = true;
                }
            }
            for(User user : users){
                //Disables existing ope user
                if(user.Username.endsWith('.ope') && portalAccessType == 'Corporate Portal'){
                    user.IsActive = false;
                    user.IsPortalEnabled = false;
                    hasOpeUser = true;
                }else if(user.Username.endsWith('.ope') && portalAccessType == 'Product Catalogue'){
                    hasOpeUser = true;
                    response.isSuccess = true;
                    response.hasOpeUser = hasOpeUser;
                    response.isNoUpdateNeeded = true;
                    response.contactId = contact.Id;
                    return response;
                }
                else if(user.Username.endsWith('.cce') || (user.Username.endsWith('.cce') && portalAccessType == 'Product Catalogue')){
                    //Enables existing cce user
                    userId = user.Id;
                    user.IsActive = true;
                    hasCCEUser = true;
                }
                usersToUpdate.add(user);
            }
            if(usersToUpdate.size() > 0){
                update usersToUpdate;
            }
            Boolean isCreateUser = users.isEmpty();

            UserAccessWrapper userAccessWrapper = new UserAccessWrapper();
            userAccessWrapper.contact = contact;
            userAccessWrapper.portalAccessType = portalAccessType;
            userAccessWrapper.isCreateUser = isCreateUser;
            userAccessWrapper.userId = userId;
            userAccessWrapper.hasCCEUser = hasCCEUser;
            userAccessWrapper.hasOpeUser = hasOpeUser;
            userId = createUser(userAccessWrapper);

            response.isSuccess = true;
            response.contactId = contact.Id;
            response.hasOpeUser = hasOpeUser;
            response.email = portalAccessType == 'Product Catalogue' ? contact.Registered_Email__c : emailToUse;
            response.contactLastName = contact.LastName;
            response.contactFirstName = contact.FirstName;
            response.accountId = contact.AccountId;
            response.primaryBusinessAcctId = contact.hed__Primary_Organization__c;
            response.accountName = contact.Account.Name;
            response.userId = userId;

            //Add Administrative Account associated with the Contact
            if(String.isNotBlank(administrativeAccName) && String.isNotBlank(administrativeId)){
                createOPEAccess(administrativeAccName,administrativeId);
            }

        }catch(Exception e){
            Database.rollback(savePoint);
            response.isSuccess = false;
            response.errorMessage = e.getMessage();
        }
        return response;
    }

    private static Id createUser(UserAccessWrapper userAccessWrapper){
        String username = '';
        String emailToUse = '';
        Profile profile = new Profile();
        List<String> permsetLabelList = new List<String>();
        Contact contact =  userAccessWrapper.contact;

        if(userAccessWrapper.portalAccessType != 'Product Catalogue' || userAccessWrapper.hasCCEUser){
            profile = [SELECT Id FROM Profile WHERE Name = 'Corporate Partner' WITH SECURITY_ENFORCED LIMIT 1];
            permsetLabelList = new List<String>{'Corporate Partner'};
            username = contact.Work_Email__c + '.cce';
            emailToUse = contact.Work_Email__c;
        }else{
            profile = [SELECT Id FROM Profile WHERE Name = 'QUT Experience' WITH SECURITY_ENFORCED LIMIT 1];
            permsetLabelList = new List<String>{'QUT Experience'};
            username = contact.Registered_Email__c + '.ope';
            emailToUse = contact.Registered_Email__c;
        }

        List<User> usersToCreate = new List<User>();
        if(userAccessWrapper.isCreateUser){
            User commerceUser = new User();
            commerceUser.IsActive = true;
            commerceUser.Username = username;
            commerceUser.Email = emailToUse;
            commerceUser.LastName = contact.LastName;
            commerceUser.FirstName = contact.FirstName;
            commerceUser.ContactId = contact.Id;
            commerceUser.MobilePhone = contact.MobilePhone;
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
            userAccessWrapper.userId = user.Id;
        }
        // Assign Permissionset in the future to aviod MIXED_DML_OPERATION 
        assignPermissionset(permsetLabelList, userAccessWrapper.userId, userAccessWrapper.hasOpeUser);
        return  userAccessWrapper.userId;
    }
    
    /**
   * @description Method to Assign the Permission set to the User in future
   * @param permsetLabelList - List of Permission Sets
   * @param userId - id of the user
   * @param hasOpeUser - Boolean checker if the user is an OPE
   */
    @future
    public static void assignPermissionset(List<String> permsetLabelList, Id userId, Boolean hasOpeUser){
        List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();
        List<PermissionSet> permsets = new List<PermissionSet>();
        if(Schema.sObjectType.PermissionSet.isAccessible()){
            permsets = [SELECT Id FROM PermissionSet WHERE Label IN : permsetLabelList];
        }
        List<PermissionSetAssignment> userPermSetAssignments = new List<PermissionSetAssignment>();
        if(Schema.sObjectType.PermissionSet.isAccessible()){
            userPermSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN : permsets AND AssigneeId = : userId];
        }
        if(userPermSetAssignments.isEmpty()){
            for(PermissionSet perm: permsets){
                if(userId != null){
                    PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
                        PermissionSetId = perm.Id,
                        AssigneeId = userId
                    );
                    permSetAssignments.add(permSetAssignment);
                }      
            }

            if(permSetAssignments.size() > 0 && !hasOpeUser &&
            Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isCreateable() &&
            Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isCreateable()){
                insert permSetAssignments;
            }
        }
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
    public static Id enableCCECorporateUserForOPE(ContactDetails conDetails){
        Savepoint savePoint = Database.setSavepoint();
        Id userId;
        try {
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'Corporate Partner' WITH SECURITY_ENFORCED LIMIT 1];

            List<User> usersToCreate = new List<User>();
            User commerceUser = new User();
            commerceUser.IsActive = true;
            commerceUser.Username = conDetails.email + '.cce';
            commerceUser.Email = conDetails.email;
            commerceUser.LastName = conDetails.contactFirstName;
            commerceUser.FirstName = conDetails.contactFirstName;
            commerceUser.ContactId = conDetails.recordId;
            commerceUser.alias = conDetails.contactFirstName.substring(0, 1) + conDetails.contactFirstName.substring(0, 2);
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
            List<String> permsetLabelList = new List<String>{'Corporate Partner'};
            List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();
            List<PermissionSet> permsets = [SELECT Id FROM PermissionSet WHERE Label IN : permsetLabelList WITH SECURITY_ENFORCED];
            List<PermissionSetAssignment> userPermSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN : permsets AND AssigneeId = : userId WITH SECURITY_ENFORCED];
            if(userPermSetAssignments.isEmpty()){
                for(PermissionSet perm: permsets){
                    PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
                        PermissionSetId = perm.Id, 
                        AssigneeId = userId
                    );
                    permSetAssignments.add(permSetAssignment);
                }
                if(permSetAssignments.size() > 0 &&
                Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isCreateable() &&
                Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isCreateable()){
                    insert permSetAssignments;
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
            String ccefilter;
            String opefilter;
            
            Contact contact = new Contact();
            List<Contact> contacts = [SELECT Id, Email, Registered_Email__c, Work_Email__c, FirstName, LastName FROM Contact WHERE Id =: recordId WITH SECURITY_ENFORCED LIMIT 1];
            for(Contact con : contacts){
                if(String.isBlank(con.Work_Email__c)){
                    ccefilter = con.Registered_Email__c + '.cce';
                    opefilter = con.Registered_Email__c + '.ope';
                }else{
                    ccefilter = con.Work_Email__c + '.cce';
                    opefilter = con.Work_Email__c + '.ope';
                }
                contact = con;                
            }
            Id userId;

            //Disable existing user
            List<User> users = [SELECT Id, IsActive FROM User WHERE ContactId  =: contact.Id AND (Username =: ccefilter OR Username =: opefilter) WITH SECURITY_ENFORCED LIMIT 1];
            List<User> usersToUpdate = new List<User>();
            if(users.size() == 0){
                List<User> checkEmailToUseUser = [SELECT Id, Username, Email FROM User WHERE ContactId =: contact.Id LIMIT 1];
                for( User checkUser : checkEmailToUseUser )
                if(ccefilter.contains(checkUser.Email) ||  opefilter.contains(checkUser.Email)){
                    users = checkEmailToUseUser;
                }
            }
            for(User user : users){
                userId = user.Id;
                user.IsActive = false;
                usersToUpdate.add(user);
            }
            update usersToUpdate;

            //Remove Permission Set from the existing user
            Set<Id> permSetIdSet = new Set<Id>();
            List<PermissionSet> permsets = [SELECT Id FROM PermissionSet WHERE Label IN ('Corporate Partner') WITH SECURITY_ENFORCED];
            for(PermissionSet perm: permsets){
                permSetIdSet.add(perm.Id);
            }
            List<PermissionSetAssignment> permissionAssignments = [SELECT Id from PermissionSetAssignment WHERE PermissionSetId IN : permSetIdSet AND AssigneeId = : userId WITH SECURITY_ENFORCED];
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
    public static String createExtManagedAcct(ExternalAccountDetails extAccDetails){
        List<DelegatedAccount> delegatedAcctList = [
            SELECT Id 
            FROM DelegatedAccount 
            WHERE TargetId =: extAccDetails.primaryBusinessAcctId
            AND ManagedById =: extAccDetails.userId WITH SECURITY_ENFORCED];
        if(delegatedAcctList.isEmpty()){
            DelegatedAccount delegatedAcct = new DelegatedAccount();
            delegatedAcct.TargetId = extAccDetails.primaryBusinessAcctId;
            delegatedAcct.ManagedById = extAccDetails.userId;
            delegatedAcct.AccessBuyFor = true;
            delegatedAcct.Name = extAccDetails.accountName;
            //delegatedAcct.ParentId = extAccDetails.primaryBusinessAcctId;
            insert delegatedAcct;
        }
        return 'Success';
    }   

    /**
     * Validates Contact Input
     * @param <String> - workEmail
     * @param <String> - primaryOrgAccount
     * @param <String> - portalAccessType
     * @return <ValidateContactInputResponse> - response
     */
    private static ValidateContactInputResponse validateContactInput(Contact contact, String portalAccessType){
        ValidateContactInputResponse response = new ValidateContactInputResponse();
        response.isSuccess = true;
        response.errorMessage = '';
        if(portalAccessType == 'Corporate Portal' && String.isBlank(contact.Work_Email__c)){
            response.isSuccess = false;
            response.errorMessage = 'Please make sure to populate Work Email before enabling this contact as partner user.';
        }   
        if(portalAccessType == 'Corporate Portal' && String.isBlank(contact.hed__Primary_Organization__c)){
            response.isSuccess = false;
            response.errorMessage = 'Please make sure to populate Primary Business Account before enabling this contact as partner user.';
        }
        if(portalAccessType == 'Product Catalogue' && String.isBlank(contact.Registered_Email__c)){
            response.isSuccess = false;
            response.errorMessage = 'Registered Email is mandatory.';
        }
        return response;
    }

    /**
     * Creates Buyer Access to OPE Portal for CCE User
     * @param accountName - Account Name of the Administrative Account
     * @param administrativeAccId - administrative Account Id of the contact
     */
    @future
    public static void createOPEAccess (String accountName, String administrativeAccId){
        //Query the OPE Buyer Group
        List<BuyerGroup> opeBuyerGroup = [ SELECT Id FROM BuyerGroup WHERE Name = 'OPE BuyerGroup' WITH SECURITY_ENFORCED LIMIT 1];
        //Query the Administrative Account of the Contact has Buyer Account 
        List<BuyerAccount> buyerAccount = [SELECT Id FROM BuyerAccount WHERE BuyerId =:administrativeAccId WITH SECURITY_ENFORCED LIMIT 1];

        //Create Buyer Account Record if Buyer Account is blank
        if(buyerAccount.isEmpty()){
            BuyerAccount administrativeAccountBuyer = new BuyerAccount();
            administrativeAccountBuyer.BuyerId = administrativeAccId;
            administrativeAccountBuyer.Name = accountName;
            administrativeAccountBuyer.IsActive = TRUE;
            administrativeAccountBuyer.BuyerStatus = 'Active';

            if(Schema.sObjectType.BuyerAccount.fields.BuyerId.isCreateable() &&
            Schema.sObjectType.BuyerAccount.fields.Name.isCreateable() &&
            Schema.sObjectType.BuyerAccount.fields.IsActive.isCreateable() &&
            Schema.sObjectType.BuyerAccount.fields.BuyerStatus.isCreateable())
            {
                insert administrativeAccountBuyer;
            }
        }
        
        // Query the Buyer Group Member of the OPE Catalouge Buyer Group
        List<BuyerGroupMember> buyerGroupMember = [ SELECT Id FROM buyerGroupMember WHERE BuyerId =: administrativeAccId AND BuyerGroupId =: opeBuyerGroup[0].Id WITH SECURITY_ENFORCED LIMIT 1];
        // Create Buyer Group Member Record if the Account is not yet associated to the OPE Buyer Group
        if(buyerGroupMember.isEmpty()){
            BuyerGroupMember bgMember = new BuyerGroupMember();
            bgMember.BuyerId = administrativeAccId;
            bgMember.BuyerGroupId = opeBuyerGroup[0].Id;

            if(Schema.sObjectType.BuyerGroupMember.fields.BuyerId.isCreateable() &&
            Schema.sObjectType.BuyerGroupMember.fields.BuyerGroupId.isCreateable())
            {
                insert bgMember;
            }
          }
    }   

    public class ValidateContactInputResponse{
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
    }

    public class CorporateUserDetails{
        @AuraEnabled public String contactId { get; set; }        
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String contactLastName { get; set; }
        @AuraEnabled public String contactFirstName { get; set; }
        @AuraEnabled public Boolean hasOpeUser { get; set; }
        @AuraEnabled public String accountId { get; set; }
        @AuraEnabled public String primaryBusinessAcctId { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public String userId { get; set; }
        @AuraEnabled public Boolean isNoUpdateNeeded { get; set; }
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
    }
    /* contact, portalAccessType, isCreateUser, userId, hasCCEUser, hasOpeUser */
    public class UserAccessWrapper{
        @AuraEnabled public Contact contact { get; set; }
        @AuraEnabled public String portalAccessType { get; set; }
        @AuraEnabled public Boolean isCreateUser { get; set; }
        @AuraEnabled public Id userId { get; set; }
        @AuraEnabled public Boolean hasCCEUser { get; set; }
        @AuraEnabled public Boolean hasOpeUser { get; set; }
    }

    public class ContactDetails {
        @AuraEnabled public String recordId { get; set; }
        @AuraEnabled public String contactFirstName { get; set; }
        @AuraEnabled public String contactLastName { get; set; }
        @AuraEnabled public String email { get; set; }
    }

    public class ExternalAccountDetails {
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public Id primaryBusinessAcctId { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public Id userId { get; set; }
    }
}
