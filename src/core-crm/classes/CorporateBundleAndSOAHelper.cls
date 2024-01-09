/**
 * @description Helper class for Corporate Bundle Related records
 * 
 * @see ManageRegistrationSectionCtrl
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                      |
      |---------------------------|-----------------------|----------------------|-------------------------------------|
      | roy.nino.s.regala         | Sep 5, 2022           | DEPP-3770            | Created File                        |
      | kathy.cornejo             | Sep 15, 2022          | DEPP-4309            | Added logic for Tailored            |

 */
public without sharing class CorporateBundleAndSOAHelper {
    

     /**
     * gets corporate user record related to the webcart
     * @param priceBookId - selected pricebookid
     * @return User corporate user
     */
     public static List<User> getCorporateUser(String priceBookId){

          List<User> corporateUserRecords = new List<User>();
          List<BuyerGroupPriceBook> buyerGroupPriceBookRecord = new List<BuyerGroupPriceBook>();
          Id accountId;

          buyerGroupPriceBookRecord = BuyerGroupPriceBooksDAO.newInstance().getBuyerGroupPriceBooksByPricebookId(
               priceBookId, AccessLevel.SYSTEM_MODE
          );
     
          accountId = buyerGroupPriceBookRecord[0].BuyerGroup.Product_Request__r.Product_Specification__r.Opportunity_Name__r.AccountId;
          
          if(!buyerGroupPriceBookRecord.isEmpty()){
               Set<String> contactIds = new Set<String>();
               List<AccountContactRelation> acrList = new List<AccountContactRelation>([
                    SELECT ContactId 
                    FROM AccountContactRelation 
                    WHERE AccountId =: accountId
                    AND Account.IsPartner = true
                    AND IsActive = true
               ]);
               
               for(AccountContactRelation acr: acrList){
                    contactIds.add(acr.ContactId);
               }
               
               corporateUserRecords = new List<User>([
                    SELECT Id, AccountId, Contact.hed__Primary_Organization__c
                    FROM User
                    WHERE ContactId IN: contactIds
                    AND IsActive = true
                    LIMIT 1
               ]);
          }
          
          return corporateUserRecords;
     }


     /**
     * creates a webcart owned by the corporate user
     * @param corporateUser - user of corporate portal
     * @return WebCart
     */
    public static WebCart createCCEWebCart(User corporateUser){
          WebStore studyWebStore = WebStoresDAO.newInstance().getCCEWebStoreId();

          List<WebCart> existingCarts = WebCartsDAO.newInstance().getWebCartByUserId(
               new Set<Id>{corporateUser.Id}, 
               AccessLevel.SYSTEM_MODE
          );
          
          if(!existingCarts.isEmpty()){
               existingCarts[0].Status = 'Closed';
               WebCartsDAO.newInstance().updateRecords(
                    existingCarts, 
                    true, 
                    AccessLevel.SYSTEM_MODE
               );
          }

          WebCart webCart = new WebCart();
          webCart.Name = 'Cart';
          webCart.AccountId = corporateUser.Contact.hed__Primary_Organization__c !=null ? corporateUser.Contact.hed__Primary_Organization__c : corporateUser.AccountId;
          webCart.Status__c = 'Active';
          webCart.OwnerId = corporateUser.Id;
          webCart.WebStoreId = studyWebStore.Id;
          return webCart;
     }

/*
     * @description - checks the latest credit availablity of asset
     * @param pbEntryId - selected pricebookentry
     * @param assetId - related asset
     * @return boolean - checker if asset credit is still available for enrollment
     */
    @AuraEnabled
    public static boolean checkCreditAvailability(String pbEntryId, String assetId){

          Boolean isAvailable = false; 

          List<PricebookEntry> selectedPriceBookEntry = new List<PricebookEntry>([
               SELECT Id, UnitPrice
               FROM PricebookEntry
               WHERE Id =: pbEntryId
          ]);

          List<Asset> relatedAsset = new List<Asset>([
               SELECT Id, 
               Remaining_Value__c
               FROM Asset
               WHERE Id =: assetId
          ]);

          if(  !selectedPriceBookEntry.isEmpty() && 
               !relatedAsset.isEmpty() &&
               relatedAsset[0].Remaining_Value__c >= selectedPriceBookEntry[0].UnitPrice){
               isAvailable = true;
          }

          return isAvailable;
    }

     /*
     * @Retrieves map of pricebookentry ids against asset
     * @param pbEntryIds - list of pbEntryIds
     * @return Map<String,Asset> - id of pricebook entry against the asset
     */
     @AuraEnabled
     public static Map<String,Asset> getAsset(List<String> pbEntryIds){
          Map<Id,Id> priceBookToEntryMap = new Map<Id,Id>();
          Map<Id,Id> productRequestToPriceBookMap = new Map<Id,Id>();
          Map<String,Asset> pbEntryToAssetMap = new Map<String,Asset>();

          for(PricebookEntry pbEntry: PricebookEntriesDAO.newInstance().getPricebookEntriesByIds(
               new Set<Id>((List<Id>)pbEntryIds), AccessLevel.SYSTEM_MODE
          )){    
               priceBookToEntryMap.put(pbEntry.Pricebook2Id,pbEntry.Id);
          }

          for(BuyerGroupPriceBook buyerGroupPB: BuyerGroupPriceBooksDAO.newInstance().getBuyerGroupPriceBooksByPricebookIds(
               priceBookToEntryMap.keySet(),
               AccessLevel.SYSTEM_MODE
          )){
               productRequestToPriceBookMap.put(buyerGroupPB.BuyerGroup.Product_Request__c,buyerGroupPB.Pricebook2Id);
          }

          for(Asset asset : AssetsDAO.newInstance().getAssetsByProductRequestIds(
               productRequestToPriceBookMap.keySet(),
               AccessLevel.SYSTEM_MODE
          )){
               if(  productRequestToPriceBookMap.containsKey(asset.Product_Request__c) &&
                    priceBookToEntryMap.containsKey(productRequestToPriceBookMap.get(asset.Product_Request__c))){
                    asset.Total_Value__c = asset.Total_Value__c == null?0:asset.Total_Value__c;
                    pbEntryToAssetMap.put(priceBookToEntryMap.get(productRequestToPriceBookMap.get(asset.Product_Request__c)),asset);
               }
          }
          return pbEntryToAssetMap;    
     }


     /**
     * @description Create product ledgers against the asset and courseconnection
     * @param assetId - asset related to the corporate bundle
     * @param courseConnectionList - list of courseCourseConnections
     */
    public static void createProductLedgerRecords(Id assetId, List<hed__Course_Enrollment__c> courseConnectionList){

     List<Product_Ledger__c> productLedgerToInsert = new List<Product_Ledger__c>();
          for(hed__Course_Enrollment__c courseCon: courseConnectionList){
               //only create ledgers against Program offering and Single Course Offerings
               if(  (courseCon.Program_Offering__c != null && courseCon.hed__Course_Offering__c == null) ||
                    (courseCon.Program_Offering__c == null && courseCon.hed__Course_Offering__c != null)){
                         productLedgerToInsert.add(new Product_Ledger__c(  
                              Asset__c = assetId, 
                              Course_Connection__c = courseCon.Id,
                              Purchased_Price_v2__c = courseCon.Amount__c
                         ));
               }
          }
          
          if(!productLedgerToInsert.isEmpty()){
               ProductLedgersDAO.newInstance().insertRecords(productLedgerToInsert, false, AccessLevel.SYSTEM_MODE);
          }
     }

     /**
     * @description create affiliation records
     * @param courseConnectionList - list of courseCourseConnections
     */
     public static void createAffiliationRecords(List<hed__Course_Enrollment__c> courseConnectionList){

          try{
               List<Account> partnerAccounts = new List<Account>();
               String accountId = '';
               String affiliationKey = '';
               Set<String> partnerAccountIds = new Set<String>();
               List<hed__Course_Enrollment__c> initialCourseEnrollment = new List<hed__Course_Enrollment__c>();
               Map<String,hed__Affiliation__c> affiliationToInsert = new Map<String,hed__Affiliation__c>();
               hed__Affiliation__c affiliationRecord;
               //get new course enrollment records that has a cart and account is partner 
               //related product specification is CCE (for tailored since there are no carts for this)
               //Program offering and single course offering only
               Map<Id,hed__Course_Enrollment__c> courseEnrollmentRecords = new Map<Id,hed__Course_Enrollment__c>([
                    SELECT Id, Cart_ID__r.AccountId, 
                    hed__Contact__c,
                    Program_Offering__c, hed__Course_Offering__c,
                    hed__Course_Offering__r.hed__Course__r.ProductRequestID__r.Product_Specification__r.Opportunity_Name__r.AccountId,
                    Program_Offering__r.hed_Program_Plan__r.Product_Request__r.Product_Specification__r.Opportunity_Name__r.AccountId,
                    hed__Course_Offering__r.hed__Course__r.ProductRequestID__r.Product_Specification__r.RecordType.DeveloperName,
                    Program_Offering__r.hed_Program_Plan__r.Product_Request__r.Product_Specification__r.RecordType.DeveloperName
                    FROM hed__Course_Enrollment__c
                    WHERE Id IN: courseConnectionList
                    AND ((Program_Offering__c != null 
                    AND Program_Offering__r.hed_Program_Plan__r.Product_Request__r.Product_Specification__r.Opportunity_Name__r.AccountId != null 
                    AND hed__Course_Offering__c = null)
                    OR (Program_Offering__c = null 
                    AND hed__Course_Offering__c != null
                    AND hed__Course_Offering__r.hed__Course__r.ProductRequestID__r.Product_Specification__r.Opportunity_Name__r.AccountId != null)
                    OR (Cart_ID__c != null AND Cart_ID__r.AccountId != null)
                    OR hed__Course_Offering__r.hed__Course__r.ProductRequestID__r.Product_Specification__r.RecordType.DeveloperName = 'CCE'
                    OR Program_Offering__r.hed_Program_Plan__r.Product_Request__r.Product_Specification__r.RecordType.DeveloperName = 'CCE')
               ]);
               Set<Id> potentialPartnerAccounts = new Set<Id>();
     
               initialCourseEnrollment = courseEnrollmentRecords.values();
     
               for(hed__Course_Enrollment__c coursecon: initialCourseEnrollment){
                    if(coursecon.Cart_ID__c != null && coursecon.Cart_ID__r.AccountId != null){
                         //store course enrollemnts with cart and account id
                         //should contain the partner account
                         potentialPartnerAccounts.add(coursecon.Cart_ID__r.AccountId);
                    }else{
                         affiliationRecord = createAffiliationRecord(courseCon);
                         affiliationKey = String.valueOf(affiliationRecord.hed__Contact__c) + String.valueOf(affiliationRecord.hed__Account__c);
                         affiliationToInsert.put(affiliationKey,affiliationRecord);
                         courseEnrollmentRecords.remove(coursecon.Id);
                    }
               }
               //get partner accounts
               //for some reaspon Cart_ID__r.Account.IsPartner is not working
               partnerAccounts = AccountsDAO.newInstance().getPartnerAccountsByIds(
                    potentialPartnerAccounts, AccessLevel.SYSTEM_MODE
               );

               for(Account acc: partnerAccounts){
                    partnerAccountIds.add(acc.Id);
               }
     
               for(hed__Course_Enrollment__c courseCon : courseEnrollmentRecords.values()){
                    if(partnerAccountIds.contains(courseCon.Cart_ID__r.AccountId)){
                         
                         affiliationRecord = new hed__Affiliation__c(
                              hed__Contact__c = courseCon.hed__Contact__c,
                              hed__Account__c = courseCon.Cart_ID__r.AccountId,
                              hed__Role__c = 'Employee',
                              hed__Status__c = 'Current',
                              hed__StartDate__c = System.today(),
                              hed__Primary__c = false
                         );
                         
                         affiliationKey = String.valueOf(courseCon.hed__Contact__c) + String.valueOf(courseCon.Cart_ID__r.AccountId);
                         affiliationToInsert.put(affiliationKey,affiliationRecord);
                    }
               }
     
               if(!affiliationToInsert.keyset().isEmpty()){
                    insert affiliationToInsert.values();
               }
          }catch(Exception e){
               Logger.error('Exception caught in method createAffiliationRecords in class CorporateBundleAndSOAHelper.')
                    .setExceptionDetails(e);
          } finally {
               if(Logger.getBufferSize() > 0) {
                    Logger.saveLog();
               }
          }
     }

     private static hed__Affiliation__c createAffiliationRecord(hed__Course_Enrollment__c courseCon){

          Id accountId;

          if(  coursecon.hed__Course_Offering__c != null && 
               coursecon.hed__Course_Offering__r.hed__Course__r.ProductRequestID__r.Product_Specification__r.RecordType.DeveloperName == 'CCE' &&
               coursecon.Program_Offering__c == null){
               accountId = coursecon.hed__Course_Offering__r.hed__Course__r.ProductRequestID__r.Product_Specification__r.Opportunity_Name__r.AccountId;
          }else{
               accountId = coursecon.Program_Offering__r.hed_Program_Plan__r.Product_Request__r.Product_Specification__r.Opportunity_Name__r.AccountId;
          }

          return new hed__Affiliation__c(
               hed__Contact__c = courseCon.hed__Contact__c,
               hed__Account__c = accountId,
               hed__Role__c = 'Employee',
               hed__Status__c = 'Current',
               hed__StartDate__c = System.today(),
               hed__Primary__c = false
          );
     }
}