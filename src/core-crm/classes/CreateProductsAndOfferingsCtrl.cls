/**
 * @description Controller Class for createProductsAndOfferings LWC
 * @see ../lwc/createProductsAndOfferings
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | adrian.c.habasa           | October 18, 2021      | DEPP-476             | Created file                 | 
      |                           |                       |                      |                              | 
 */
public with sharing class CreateProductsAndOfferingsCtrl {

    /**
     * @description get List of courses, products, and course offerings related to a ProductRequest
     * @param Product Request Record Id
     * @return list of course, Map of Course offerings and Map of Products
     */
    @AuraEnabled(cacheable=true)
    public static CourseWithOfferings getRelatedCourse(Id productRequestId)
    {   AuraHandledException auraEx = new AuraHandledException('Error Message');  
        auraEx.setMessage('Error while getting Data.');
            try{
                CourseWithOfferings allCourseData = new CourseWithOfferings();
                Map<Id,List<hed__Course_Offering__c>> coursesWithOffering = new Map<Id,List<hed__Course_Offering__c>>();
                Map<Id,List<Product2>> coursesWithProduct = new Map<Id,List<Product2>>();

                List<hed__Course__c> courses =new List<hed__Course__c>([Select Id,Name,RecordType.Name, Start_Date__c, End_Date__c 
                                                                        From hed__Course__c 
                                                                        Where ProductRequestID__c =:productRequestId]);

                List<hed__Course_Offering__c> offeringlist = new List<hed__Course_Offering__c>([Select Id,Name,hed__Start_Date__c,hed__End_Date__c,
                                                                        hed__Course__c,hed__Course__r.Name,hed__Course__r.RecordType.Name,hed__Term__c,
                                                                        hed__Section_ID__c,hed__Capacity__c,hed__Time_Block__c, hed__Faculty__c
                                                                        From hed__Course_Offering__c
                                                                        Where hed__Course__c in:courses]);

                List<Product2> productlist = new List<Product2>([Select Id,Name,Course__c,Start_Date__c, End_Date__c, Description, IsActive, ProductCode, Family  From Product2 Where Course__c in:courses]);

                if(!offeringlist.isEmpty())
                {
                    for(hed__Course_Offering__c offer :offeringlist)
                    {
                        if(!coursesWithOffering.containsKey(offer.hed__Course__c))
                        {
                            coursesWithOffering.put(offer.hed__Course__c,new List<hed__Course_Offering__c>());
                        }
                        coursesWithOffering.get(offer.hed__Course__c).add(offer);
                    }
                }

                if(!productlist.isEmpty())
                {
                    for(Product2 product : productlist)
                    {
                        if(!coursesWithProduct.containsKey(product.Course__c))
                        {
                            coursesWithProduct.put(product.Course__c,new List<Product2>());
                        }
                        coursesWithProduct.get(product.Course__c).add(product);
                    }
                }

                allCourseData.courseList = courses;
                allCourseData.offeringMap = coursesWithOffering;
                allCourseData.productMap = coursesWithProduct;
                return allCourseData;
            }catch(Exception e){ throw auraEx; }
    }

    //wrapper class, Holds List of Courses, Map of Offerings and Map of Products
    public class CourseWithOfferings{
        @AuraEnabled
        public List<hed__Course__c> courseList;
        @AuraEnabled
        public Map<Id,List<hed__Course_Offering__c>> offeringMap;
        @AuraEnabled
        public Map<Id,List<Product2>> productMap;
    }
}
