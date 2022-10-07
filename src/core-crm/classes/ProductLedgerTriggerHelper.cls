/**
 * @description helper for ProductLedgerTriggerHelper
 * @see CourseConnectionTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | Aug 22, 2022          | DEPP-3482              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class ProductLedgerTriggerHelper {


    public static void productLedgerRollUpUpdate(List<hed__Course_Enrollment__c> parentCourseEnrollment){

        List<Product_Ledger__c> productLedgerToUpdate = new List<Product_Ledger__c>([
            SELECT Id, 
            Course_Connection__r.Offering_End_Date__c, 
            Course_Connection__r.hed__Status__c,
            Offering_Ended__c, Registration_Cancelled__c
            FROM Product_Ledger__c
            WHERE Course_Connection__c IN: parentCourseEnrollment
        ]);

        for(Product_Ledger__c prodLedger: productLedgerToUpdate){
            if( prodLedger.Course_Connection__c != null && 
                prodLedger.Course_Connection__r.Offering_End_Date__c < Date.Today()){
                prodLedger.Offering_Ended__c = true;
            }else{
                prodLedger.Offering_Ended__c = false;
            }

            if( prodLedger.Course_Connection__c != null &&
                prodLedger.Course_Connection__r.hed__Status__c == 'Cancelled'){
                prodLedger.Registration_Cancelled__c = true;
            }else{
                prodLedger.Registration_Cancelled__c = false;
            }
        }

        if(!productLedgerToUpdate.isEmpty()){
            update productLedgerToUpdate;
        }
    }
}