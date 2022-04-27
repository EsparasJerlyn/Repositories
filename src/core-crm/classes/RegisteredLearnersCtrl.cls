/**
 * @description Controller Class for registeredLearnerRelatedList LWC
 * @see ../lwc/registeredLearnerRelatedList
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | adrian.c.habasa           | March 24, 2022        | DEPP-1481            | Created file                 |          | 
      |                           |                       |                      |                              | 
 */
public with sharing class RegisteredLearnersCtrl {
    private static Map <String,Schema.RecordTypeInfo> courseConnectionRecordTypes = hed__Course_Enrollment__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id studentRTId = courseConnectionRecordTypes.get('Student').getRecordTypeId();

    @AuraEnabled(cacheable=true)
    public static List<RegisteredLearners> getRegisteredLearners(Id offeringId)
    {
       List<RegisteredLearners> learnerList = new List<RegisteredLearners>();
       List<hed__Course_Enrollment__c > courseConnections = [SELECT Id, hed__Contact__c
                                                            FROM hed__Course_Enrollment__c
                                                            WHERE hed__Course_Offering__c =: offeringId AND RecordTypeId =: studentRTId];

       List<Questionnaire_Response_Summary__c> questionnaireResponseList =[ SELECT Contact__c,Contact__r.Preferred_Given_Name__c, Contact__r.Company_Name__c, Contact__r.Position__c 
                                                                            FROM Questionnaire_Response_Summary__c 
                                                                            WHERE Course_Offering__c =: offeringId AND Registration_Status__c = 'Confirmed'];

        for(hed__Course_Enrollment__c student : courseConnections){
            for(Questionnaire_Response_Summary__c question : questionnaireResponseList)
            {
                if(question.Contact__c == student.hed__Contact__c){
                    RegisteredLearners rl = new RegisteredLearners();
                    rl.prefferedName = question.Contact__r.Preferred_Given_Name__c;
                    rl.companyName = question.Contact__r.Company_Name__c;
                    rl.positionName =  question.Contact__r.Position__c;
                    learnerList.add(rl);
                }
            }
        }

        return learnerList;
   }
   public class RegisteredLearners{
		@AuraEnabled
		public String prefferedName;
		@AuraEnabled
		public String companyName;
        @AuraEnabled
		public String positionName;
	}

}
