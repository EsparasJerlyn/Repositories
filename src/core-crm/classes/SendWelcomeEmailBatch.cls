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
      | kenneth.f.alsay                | December 6, 2023      | DEPP-7339              | Updated query as per AC3     |
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
         * primary delivery platform is QUT Canvas
         * Student Username is available
         * and active enrollment
         * is student
         */
        Date sevenDaysBefore = Date.today() + 7; //NOPMD Used in string below for dynamic query
        String query = 
        'SELECT Id, hed__Contact__c ' + 
        'FROM hed__Course_Enrollment__c ' + 
    	'WHERE hed__Course_Offering__r.hed__Start_Date__c =:sevenDaysBefore ' +
        'AND hed__Course_Offering__r.Primary_Delivery_Platform__c = \'QUT Canvas\' ' + 
        'AND hed__Contact__r.QUT_Student_Username__c != null ' + 
        'AND hed__Contact__r.Registered_Email__c != null ' +
        'AND hed__Status__c  = \'Active\' ' + 
        'AND RecordType.DeveloperName = \'Student\' ' +
        'AND LMS_Integration_Status__c = \'Success\' ';
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
            Logger.error('Exception caught in method execute in class SendWelcomeEmailBatch.')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  
    public void finish(Database.BatchableContext bc) {}//NOPMD
}