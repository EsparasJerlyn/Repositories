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
       List<hed__Course_Enrollment__c > courseConnections = [SELECT Id, hed__Contact__c,
                                                            hed__Contact__r.Preferred_Given_Name__c, 
                                                            hed__Contact__r.Company_Name__c, 
                                                            hed__Contact__r.Position__c
                                                            FROM hed__Course_Enrollment__c
                                                            WHERE hed__Course_Offering__c =: offeringId 
                                                            AND RecordTypeId =: studentRTId
                                                            AND hed__Status__c = 'Active'];

        for(hed__Course_Enrollment__c student : courseConnections){
                RegisteredLearners rl = new RegisteredLearners();
                rl.prefferedName = student.hed__Contact__r.Preferred_Given_Name__c;
                rl.companyName = student.hed__Contact__r.Company_Name__c;
                rl.positionName =  student.hed__Contact__r.Position__c;
                learnerList.add(rl);
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
