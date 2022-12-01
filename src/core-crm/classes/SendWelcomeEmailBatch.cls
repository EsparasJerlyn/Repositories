/**
 * @description Batch class to send welcome email to contacts
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | July 30, 2022         | DEPP-3557              | Created file                 |
      | rhea.b.torres                  | November 25, 2022     | DEPP-4628              | 7-day window logic update    | 
 */
public class SendWelcomeEmailBatch implements Database.Batchable<sObject>
{

    /**
    * @description Method to course enrollments
    * @param bc - BatchableContext
    * @return query - filtered query of course enrollment records
    */
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        /**
         * startdate of offering starts 7 days from today
         * primary delivery platform is blackboard
         * Student Username is available
         * and active enrollment
         * is student
         */ 
        String query = 
        'SELECT Id, hed__Contact__c ' + 
        'FROM hed__Course_Enrollment__c ' + 
    	'WHERE hed__Course_Offering__r.hed__Start_Date__c = NEXT_N_DAYS:7 ' +
        'AND hed__Course_Offering__r.Primary_Delivery_Platform__c = \'Blackboard\' ' + 
        'AND hed__Contact__r.QUT_Student_Username__c != null ' + 
        'AND hed__Contact__r.Registered_Email__c != null ' +
        'AND hed__Status__c  = \'Active\' ' + 
        'AND RecordType.DeveloperName = \'Student\' ';
        return Database.getQueryLocator(query);
    }

    /**
    * @description Method to execute the batch
    * @param bc - BatchableContext
    * @param enrollmentList - List of course enrollments
    */
    public void execute(Database.BatchableContext bc, List<hed__Course_Enrollment__c> enrollmentList)
    {
        Set<Id> contactIds = new Set<Id>();
        try{
            //Loop through all courseconnections to get valid contacts to receive welcome email
            for(hed__Course_Enrollment__c courseEnrollnment: enrollmentList){
                contactIds.add(courseEnrollnment.hed__Contact__c);
            }
            if(!contactIds.isEmpty()){
                ContactUserNameCreatedHelper.sendEmailUsernameCreated(contactIds);
            }
        }catch(Exception e){
            System.debug(LoggingLevel.WARN, 'SendWelcomeEmailBatch Error: ' + e.getMessage());//NOPMD
        }
    }  
    public void finish(Database.BatchableContext bc) {
    }
}