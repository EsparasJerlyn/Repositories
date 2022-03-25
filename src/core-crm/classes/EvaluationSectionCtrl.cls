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
}

