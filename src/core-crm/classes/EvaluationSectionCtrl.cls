/**
 * @description Controller class for evaluationSection LWC
 *
 * @see ../lwc/evaluationSection
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                         |
      |---------------------------|-----------------------|----------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | March 22, 2022        | DEPP-1502            | Created file                                           |
      |                           |                       |                      |                                                        | 
*/
public with sharing class EvaluationSectionCtrl {

    /**
    * @description Method for getting the metadata of Evaluation fields
    * @return list of Offering Evalution Setting records
    */
    @AuraEnabled(cacheable=true)
    public static List<Offering_Evaluation_Setting__mdt> getEvaluationFields(){
        return [
            SELECT MasterLabel, Fields__c
            FROM Offering_Evaluation_Setting__mdt
        ];
    }

    /**
    * @description Method to get list of related program offerings
    * @param productRequestId - id of related product request
    * @return list of related program offerings
    */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,Object>> getRelatedProgramOfferings(Id productRequestId){
        List<Map<String,Object>> programOfferings = new List<Map<String,Object>>();
        Id programPlanId = [SELECT Id FROM hed__Program_Plan__c WHERE Product_Request__c =: productRequestId LIMIT 1]?.Id;

        for(Program_Offering__c po : [
            SELECT Id, Start_Date__c, End_Date__c, Delivery_Type__c, Evaluation_Type__c 
            FROM Program_Offering__c
            WHERE hed_Program_Plan__c =: programPlanId
            ORDER BY Start_Date__c ASC
        ]){
            programOfferings.add(new Map<String,Object>{
                'value' => po.Id,
                'startDate' => po.Start_Date__c,
                'endDate' => po.End_Date__c,
                'deliveryType' => po.Delivery_Type__c,
                'evaluationType' => po.Evaluation_Type__c
            });
        }

        return programOfferings;
    }
}
