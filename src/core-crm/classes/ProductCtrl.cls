/** 
 * @description Controller Class for list of products to be displayed in Product Listing Page 
 * @see ../lwc/productDetails
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                             |
      |---------------------------|-----------------------|----------------------|--------------------------------------------|
      | mary.grace.li             | May 02, 2022          | DEPP-1269            | Created File                               |      
      | eugene.andrew.abuan       | May 02, 2022          | DEPP-1269            | Modified Ctrl to Map fields                |
      | eugene.andrew.abuan       | May 09, 2022          | DEPP-1979            | Added getFilteredProducts function         |          
      
 */

public without sharing class ProductCtrl {
    
    /**
     * @description fetches course offerings and pricebooks related to the products
     * @param productIds - List of Products under the Category
     * @return prodData - details of the product
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
     * @description Filters the products depending on the parameters 
     * @param productIds - List of Products under the Category
     * @param filterData - Parameters that for filter
     * @return prodData - Id of filtered products
     */
    @AuraEnabled(cacheable=true)    
    public static FilterData getFilteredProducts (List <String> productAllId, FilterWrapper filterData){
        FilterData prodData = new FilterData();
        List<Product2> filterDataList = new List<Product2>();
        List<Id> filteredProductId = new List<Id>();
        String standardPriceBook = 'Standard Price Book';
        String earlyBirdPricebook = 'Early Bird';
        String studyAreaValue = '';
        String deliveryTypeValue = '';
        String productTypeValue = '';

        // Dynamic Query that matches the selected filter
        String filterProductsQuery = 'SELECT Id, Name, Course__c, Program_Plan__c ';
            if(filterData.minUnitPrice !=null || filterData.maxUnitPrice !=null){
                filterProductsQuery += ', (SELECT UnitPrice, Pricebook2.Name, Pricebook2.Id, Product2Id FROM PricebookEntries ';
                filterProductsQuery += 'WHERE (Pricebook2.Name = \''+standardPriceBook+'\' OR Pricebook2.Name =\''+earlyBirdPricebook+'\'))';
             }
            filterProductsQuery += ' FROM Product2';
            filterProductsQuery += ' WHERE Id IN : productAllId';

            //Checks if Search Key is Empty
            if(String.isNotEmpty(filterData.searchKey)){
                String key = '%' + filterData.searchKey + '%'; 
                filterProductsQuery += ' AND (Name LIKE :key OR Description LIKE :key )';
            }
            //Checks if Study Area if Empty
            if(filterData.studyArea.size() >0 ){
                for(String val : filterData.studyArea){
                    studyAreaValue += '\''+ val+ '\' '+',';
                }
                studyAreaValue = studyAreaValue.substring(0, studyAreaValue.length() -1 );
                filterProductsQuery += ' AND Study_Area__c INCLUDES (' +studyAreaValue + ')';
            }
            //Checks if Delivery is Empty 
            if(filterData.deliveryType.size() > 0){
                for(String val : filterData.deliveryType){
                    deliveryTypeValue += '\''+val + '\' '+',';
                }
                deliveryTypeValue = deliveryTypeValue.substring(0, deliveryTypeValue.length() -1 );
                filterProductsQuery += ' AND Delivery__c INCLUDES (' +deliveryTypeValue + ')';
            }
            //Checks if ProductType is Empty
            if(filterData.productType.size() > 0){
                for(String val : filterData.productType){
                    productTypeValue += '\''+ val+ '\' '+',';
                }
                productTypeValue = productTypeValue.substring(0, productTypeValue.length() -1 );
                filterProductsQuery += ' AND Product_Type__c IN (' +productTypeValue + ')';
            }
        //Queries based on Product objects
        filterDataList = Database.query(filterProductsQuery);

        Set<Id> courseIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>();
        Set<Id> productPriceId = new Set<Id>();

        //Combination of Price and Date Filter and other filters if selected above
        if((filterData.startDate != null && filterData.endDate !=null) && 
            (filterData.minUnitPrice !=null || filterData.maxUnitPrice != null)){   
                Set<Id> filterProductPriceId = new Set<Id>();
                for(Product2 p: filterDataList){
                    for(PricebookEntry pEntry : p.PricebookEntries){
                        if(!p.PricebookEntries.isEmpty()){
                            //Checks if Product has Early Bird Price
                            if(pEntry.Pricebook2.Name == 'Early Bird'){
                                productPriceId.add(pEntry.Product2Id);
                                if((filterData.maxUnitPrice == null) && (pEntry.UnitPrice >= filterData.minUnitPrice) && (pEntry.Pricebook2.Name == 'Early Bird')){
                                    filterProductPriceId.add(pEntry.Product2Id);
                                }else if((filterData.minUnitPrice == null) && (pEntry.UnitPrice <= filterData.maxUnitPrice) && (pEntry.Pricebook2.Name == 'Early Bird')){
                                    filterProductPriceId.add(pEntry.Product2Id);
                                }else if((pEntry.UnitPrice >= filterData.minUnitPrice && pEntry.UnitPrice <= filterData.maxUnitPrice) && (pEntry.Pricebook2.Name == 'Early Bird')){
                                    filterProductPriceId.add(pEntry.Product2Id);
                                }
                            }
                            //Product Id not on the list of productPriceId 
                            if(!productPriceId.contains(pEntry.Product2Id)){
                                if((filterData.maxUnitPrice == null) && (pEntry.UnitPrice >= filterData.minUnitPrice)){
                                    filterProductPriceId.add(pEntry.Product2Id);
                                }else if((filterData.minUnitPrice == null) && (pEntry.UnitPrice <= filterData.maxUnitPrice)){
                                    filterProductPriceId.add(pEntry.Product2Id);
                                }else if(pEntry.UnitPrice >= filterData.minUnitPrice && pEntry.UnitPrice <= filterData.maxUnitPrice){
                                    filterProductPriceId.add(pEntry.Product2Id);
                                }
                            }

                            if(filterProductPriceId.contains(pEntry.Product2Id)){
                                if(String.isNotBlank(p.Program_Plan__c)){
                                    programIdSet.add(p.Program_Plan__c);
                                 }else{
                                     courseIdSet.add(p.Course__c);
                                }
                            }
                        }
                    }
                }
            }
        else{
            //Date and Other 4 filters except price
            for(Product2 p : filterDataList){
                if(String.isNotBlank(p.Program_Plan__c)){
                    programIdSet.add(p.Program_Plan__c);
                }else{
                    courseIdSet.add(p.Course__c);
                }
            }
        }    

        Set<Id> prodCourseStartDateId = new Set<Id>();
        Set<Id> prodProgramStartDateId = new Set<Id>();

        if(filterData.startDate !=null && filterData.endDate !=null){
            Date sDate = Date.parse(filterData.startDate);
            Date eDate = Date.parse(filterData.endDate);
            List<AggregateResult> startDateListCourse = [
                SELECT hed__Course__c, MIN(hed__Start_Date__c) startDate
                FROM hed__Course_Offering__c
                WHERE
                    (hed__Start_Date__c >=: sDate
                    AND hed__Start_Date__c <=: eDate)
                    AND hed__Course__c IN :courseIdSet
                GROUP BY hed__Course__c
                ];
                for (AggregateResult startDate : startDateListCourse) {
                    prodCourseStartDateId.add((Id) startDate.get('hed__Course__c')
                );
            }
            //Program Product (Program Plan)
            List<AggregateResult> startDateListProgram = [
                SELECT hed_Program_Plan__c, MIN(Start_Date__c) startDate
                FROM Program_Offering__c
                WHERE
                    (Start_Date__c >=: sDate
                    AND Start_Date__c <=: eDate)                   
                    AND hed_Program_Plan__c IN :programIdSet
                GROUP BY hed_Program_Plan__c
                ];
                for (AggregateResult startDate : startDateListProgram) {
                    prodProgramStartDateId.add((Id) startDate.get('hed_Program_Plan__c')
                );
            }
        }

        //Gets the Id of Filtered Products
        for(Product2 prodFilterDataTemp : filterDataList){
            //Price or other filter are selected, but not Date
            if((filterData.minUnitPrice !=null || filterData.maxUnitPrice !=null) &&
                (filterData.startDate == null && filterData.endDate == null)){
                for(PricebookEntry pEntry : prodFilterDataTemp.PricebookEntries ){
                    if(!prodFilterDataTemp.PricebookEntries.isEmpty()){
                        if(pEntry.Pricebook2.Name == 'Early Bird'){
                            productPriceId.add(pEntry.Product2Id);
                            if((filterData.maxUnitPrice == null) && (pEntry.UnitPrice >= filterData.minUnitPrice) && (pEntry.Pricebook2.Name == 'Early Bird')){
                                filteredProductId.add(pEntry.Product2Id);
                            }else if((filterData.minUnitPrice == null) && (pEntry.UnitPrice <= filterData.maxUnitPrice) && (pEntry.Pricebook2.Name == 'Early Bird')){
                                filteredProductId.add(pEntry.Product2Id);
                            }else if((pEntry.UnitPrice >= filterData.minUnitPrice && pEntry.UnitPrice <= filterData.maxUnitPrice) && (pEntry.Pricebook2.Name == 'Early Bird')){
                                filteredProductId.add(pEntry.Product2Id);
                            }
                        }

                        if(!productPriceId.contains(pEntry.Product2Id)){
                            if((filterData.maxUnitPrice == null) && (pEntry.UnitPrice >= filterData.minUnitPrice)){
                                filteredProductId.add(pEntry.Product2Id);
                            }else if((filterData.minUnitPrice == null) && (pEntry.UnitPrice <= filterData.maxUnitPrice)){
                                filteredProductId.add(pEntry.Product2Id);
                            }else if(pEntry.UnitPrice >= filterData.minUnitPrice && pEntry.UnitPrice <= filterData.maxUnitPrice){
                                filteredProductId.add(pEntry.Product2Id);
                            }
                        }
                    }
                }
            }
            //Date or other filters are selected but not price
            else if((filterData.startDate != null && filterData.endDate !=null)){
                if(String.isNotBlank(prodFilterDataTemp.Program_Plan__c)){
                    if(prodProgramStartDateId.contains(prodFilterDataTemp.Program_Plan__c)){
                        filteredProductId.add(prodFilterDataTemp.Id);
                    }
                }else{
                    if(prodCourseStartDateId.contains(prodFilterDataTemp.Course__c)){
                        filteredProductId.add(prodFilterDataTemp.Id);
                    }
                }
            }
            //other filters are selected but not price and date
            else{
                filteredProductId.add(prodFilterDataTemp.Id);
            }
        }

        prodData.listFilteredProductId = filteredProductId ;
        return prodData;
    }

   /**
   * @description Wrapper that contains list of products
   */
  public class ProductData {
    @AuraEnabled
    public List<ProductWrapper> productList;
  }

   /**
   * @description Wrapper that contains list of filtered product Id
   */
  public class FilterData {
    @AuraEnabled
    public List<Id> listFilteredProductId;
  }

   /**
   * @description Wrapper that contains list of product details
   */
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

  public class FilterWrapper {
    @AuraEnabled
    public String searchKey { get; set; } // KeyWord Search
    @AuraEnabled
    public List<String> studyArea { get; set; } // Study Area
    @AuraEnabled
    public List<String> deliveryType { get; set; } // Delivery
    @AuraEnabled
    public List<String> productType { get; set; } // Course Type
    @AuraEnabled
    public Integer minUnitPrice{ get; set; } // Price Range -> Minimum Value 
    @AuraEnabled
    public Integer maxUnitPrice{ get; set; } // Price Range -> Maximum Value 
    @AuraEnabled
    public String startDate { get; set; } // Start date 
    @AuraEnabled
    public String endDate{ get; set; } // end date
  }
}