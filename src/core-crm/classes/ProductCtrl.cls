/** 
 * @description Controller Class for list of products to be displayed in Product Listing Page 
 * @see ../lwc/productDetails
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                             |
      |---------------------------|-----------------------|----------------------|--------------------------------------------|
      | mary.grace.li             | May 02, 2022          | DEPP-1269            | Created File                               |      
      | eugene.andrew.abuan       | May 02, 2022          | DEPP-1269            | Modified Ctrl to Map fields                |      
      
 */

public without sharing class ProductCtrl {

    //finds products based on the list of the searchkey
  	// @AuraEnabled(cacheable=true)
    // public static List<Product2> findProducts(String searchKey) {
    //     String key = '%' + searchKey + '%';
    //     return [
    //         SELECT Id, Name
    //         FROM Product2
    //         WHERE Name LIKE :key
    //         WITH SECURITY_ENFORCED
    //         LIMIT 100
    //     ];
    // }
    
    /**
     * @description fetches course offerings and pricebooks related to the products
     * @param productIds - List of Products under the Category
     * @return course offerings and pricebook entries related to the product
     */
    @AuraEnabled(cacheable=true)    
    public static ProductData getProducts( List<String> productIds){
        ProductData prodData = new ProductData();
        List<ProductWrapper> prodWrapperList = new List<ProductWrapper>();

        // Query List of Products under the category
        List<Product2> productList = [
            SELECT
              Id,
              Name,
              Course__c,
              Duration__c,
              Delivery__c,
              Description,
              Professional_Level__c,
              Available_on_Cart__c,
              (
                SELECT Id, Pricebook2.Name, UnitPrice
                FROM PricebookEntries
                WHERE IsActive = TRUE
                ORDER BY CreatedDate, Pricebook2.IsStandard DESC
              ),
              Program_Plan__r.Product_Request__c,
              Program_Plan__r.Program_Delivery_Structure__c
            FROM Product2
            WHERE Id IN : productIds AND Available_on_Cart__c = TRUE
        ]; // include program plan -> single/program(regardless prescribed and flex)
        
        //Get Id of the course/program plan based on the product
        Set<Id> courseIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>();

        for(Product2 p : productList){
            if(String.isNotBlank(p.Program_Plan__c)){
                programIdSet.add(p.Program_Plan__c);
            }else{
                courseIdSet.add(p.Course__c);
            }
        }

        //Single Product(Course)
        Map<Id, Date> prodCourseDateMap = new Map<Id, Date>();
        // Map Child Product Earliest Course Offering Date
        List<AggregateResult> startDateListCourse = [
            SELECT hed__Course__c, MIN(hed__Start_Date__c) startDate
            FROM hed__Course_Offering__c
            WHERE
                Registration_Start_Date__c >= TODAY
                AND IsActive__c = TRUE
                AND Available_Seats__c > 0
                AND hed__Course__c IN :courseIdSet
            GROUP BY hed__Course__c
            ];
            for (AggregateResult startDate : startDateListCourse) {
                prodCourseDateMap.put(
                (Id) startDate.get('hed__Course__c'),
                (Date) startDate.get('startDate')
            );
        }

        //Program Product (Program Plan)
        Map<Id, Date> prodProgramDateMap = new Map<Id, Date>();
        // Map Child Product Earliest Program Offering Date
        List<AggregateResult> startDateListProgram = [
            SELECT hed_Program_Plan__c, MIN(Start_Date__c) startDate
            FROM Program_Offering__c
            WHERE
                Registration_Start_Date__c >= TODAY
                AND IsActive__c = TRUE
                AND Available_Seats__c > 0
                AND hed_Program_Plan__c IN :programIdSet
            GROUP BY hed_Program_Plan__c
            ];
            for (AggregateResult startDate : startDateListProgram) {
                prodProgramDateMap.put(
                (Id) startDate.get('hed_Program_Plan__c'),
                (Date) startDate.get('startDate')
            );
        }
        
        //Process List of Products
        for(Product2 prod : productList){
            ProductWrapper productListWrapper = new ProductWrapper();
            //Flexible Program Plan -> Id, Name, Description
            productListWrapper.childProdId = prod.Id;
            productListWrapper.childProdName = prod.Name;
            productListWrapper.childProdDescription = prod.Description;
            productListWrapper.isProgramFlex = TRUE;

            // Product is Single and Prescribed Program Plan
            if(String.isBlank(prod.Program_Plan__c) || ((String.isNotBlank(prod.Program_Plan__c)) && prod.Program_Plan__r.Program_Delivery_Structure__c =='Prescribed Program')){ // single product
                productListWrapper.childProdProfLevel = prod.Professional_level__c;
                productListWrapper.childProdDuration = prod.Duration__c;
                productListWrapper.isProgramFlex = FALSE;
                if(String.isnotblank(prod.Delivery__c)){
                    productListWrapper.childProdDelivery = prod.Delivery__c.replace(';',',');
                }

                if(String.isBlank(prod.Program_Plan__c)){
                    //Course Offering -> Single Product
                    if(prodCourseDateMap.containsKey(prod.Course__c)){
                        productListWrapper.childProdOfferingDate = Datetime.newInstance(
                            prodCourseDateMap.get(prod.Course__c),
                            Time.newInstance(0, 0, 0, 0)
                        ).format('dd MMM yyyy');
                    }
                }else{
                    //Product Offering -> Presrcibed Product
                    if(prodProgramDateMap.containsKey(prod.Program_Plan__c)){
                        productListWrapper.childProdOfferingDate = Datetime.newInstance(
                            prodProgramDateMap.get(prod.Program_Plan__c),
                            Time.newInstance(0, 0, 0, 0)
                        ).format('dd MMM yyyy');                        
                    }
                }
                                
                //Product Pricebook Entries
                Map<String, String> prodPBEntryMap = new Map<String, String>();
                if (!prod.PricebookEntries.isEmpty()) {
                    for (
                    PricebookEntry productPBookEntry : prod.PricebookEntries
                    ) {
                    prodPBEntryMap.put(
                        productPBookEntry.Pricebook2.Name,
                        String.valueOf(productPBookEntry.UnitPrice)
                    );
                    }
                }
                //Get Price
                productListWrapper.childProdPrice = prodPBEntryMap.get('Standard Price Book');
                if(prodPBEntryMap.containsKey('Early Bird')){
                    productListWrapper.childProdPrice = prodPBEntryMap.get('Early Bird');
                }
            }
            prodWrapperList.add(productListWrapper);
        }
        //Set values to wrapper
        prodData.productList = prodWrapperList;
        return prodData;
    }


   /**
   * @description 
   */
  public class ProductData {
    @AuraEnabled
    public List<ProductWrapper> productList;
  }


  public class ProductWrapper {
    @AuraEnabled
    public String childProdId { get; set; }
    @AuraEnabled
    public String childProdName { get; set; }
    @AuraEnabled
    public String childProdDescription { get; set; }
    @AuraEnabled
    public String childProdProfLevel { get; set; }
    @AuraEnabled
    public String childProdOfferingDate { get; set; }
    @AuraEnabled
    public String childProdDelivery { get; set; }
    @AuraEnabled
    public String childProdPrice { get; set; }
    @AuraEnabled
    public String childProdDuration { get; set; }
    @AuraEnabled
    public Boolean isProgramFlex  { get; set;}
  }
}