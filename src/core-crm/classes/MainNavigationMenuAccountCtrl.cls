/**
 * @description Controller Class for AccountWrapper LWC
 * @see ../lwc/accountWrapper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                 | Change Summary                          |
      |--------------------------------|-----------------------|----------------------|---------------------------------------- |
      | eccarius.karl.munoz            | February 1, 2023      | DEPP-5113            | Created Class for retrieving Account    | 
      |                                |                       |                      | Options of the logged in Corp User.     | 
 */

public without sharing class MainNavigationMenuAccountCtrl {
    private static List <Account> userAccountOptions = new List <Account>();    

    /**
     * Returns Account Options that is linked with the Business account of the current user.
     * @param <String> userId : user id of the logged in user
     * @return <UserAccountOptionWrapper> List of Accounts 
     */
    @AuraEnabled(cacheable=true)
    public static UserAccountOptionWrapper getAllRelatedBusinessAccountOfUser(String userId, String selectedAccountId){
        Id currentId = getCurrentBusinessAccountId(userId);        
        //Map<Id,List<Account>> accountByParentId = getAllAccountsWithParentId(currentId);
        //getAllChildrenByParentID(currentId, accountByParentId);

        Account parentAccount = [SELECT Id, Name FROM Account WHERE Id =: currentId WITH SECURITY_ENFORCED LIMIT 1];
        userAccountOptions.add(parentAccount);

        UserAccountOptionWrapper userAccountOption = new UserAccountOptionWrapper();
        List<UserAccountOptionWrapper> userAccountOptionList = new List<UserAccountOptionWrapper>();
        for(Account account : userAccountOptions){
            UserAccountOptionWrapper accountWrapper = new UserAccountOptionWrapper();
            accountWrapper.fullLabel = account.Name;
            accountWrapper.label = account.Name;
            if(account.Name.length() > 80){
                accountWrapper.label = account.Name.SubString(0, 80);
            }
            accountWrapper.value = account.Id; 

            //checking to set account as primary
            if(String.isBlank(selectedAccountId)){
                if(String.valueOf(account.Id) == String.valueOf(currentId)){
                    accountWrapper.isPrimaryAccount = true;
                    accountWrapper.isSelected = false;
                }
            }
            //checking to set account as selected
            if(String.valueOf(account.Id) == selectedAccountId){
                accountWrapper.isSelected = true;
            }

            userAccountOptionList.add(accountWrapper);
        }

        userAccountOption.accountOptions = userAccountOptionList;
        return userAccountOption;
    }
    
    /**
     * Retrieves Children Account from the Business Account of the current user
     */
    /* private static Map<Id,List<Account>> getAllAccountsWithParentId(String currentId){   
        Map<Id,List<Account>> accountByParentId = new Map<Id,List<Account>>();     
        List<Account> accountsWithParentId = [SELECT Id, Name, ParentId, Parent.Name FROM Account WHERE ParentId != null AND RecordType.Name = 'Business Organization' WITH SECURITY_ENFORCED];
        for (Account acc: accountsWithParentId) {
            if (!accountByParentId.containsKey(acc.ParentId)) {
                accountByParentId.put(acc.ParentId, new List < Account > ());
            }
            accountByParentId.get(acc.ParentId).add(acc);
        }   
        return accountByParentId;     
    } */

    /**
     * Retrieves Children Account from the specified Parent Account Id
     */
    /* private static void getAllChildrenByParentID(Id parentAccountID, Map <Id,List<Account>> accountByParentId) {
        if(accountByParentId.containsKey(parentAccountID)){
            for (Account acc: accountByParentId.get(parentAccountID)) {
                userAccountOptions.add(acc);
                getAllChildrenByParentID(acc.Id, accountByParentId);
            }
        }
    } */

    /**
     * Retrieves the Business Account of the current user
     */
    private static Id getCurrentBusinessAccountId(String userId){
        Id currentId;
        if(Schema.sObjectType.User.isAccessible()){
            currentId = [SELECT Contact.hed__Primary_Organization__r.Id FROM User WHERE Id =: userId LIMIT 1].Contact.hed__Primary_Organization__r.Id;
        }
        return currentId;

    }

    /**
     * Wrapper class for storing account option details
     */
    public class UserAccountOptionWrapper{
        @AuraEnabled
        public Boolean isPrimaryAccount{ get; set; }
        @AuraEnabled
        public Boolean isSelected{ get; set; }
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String fullLabel;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public List<UserAccountOptionWrapper> accountOptions;
    }
}