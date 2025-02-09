/**
 * @description Batch class that sends email to users that expressed there interest to courses
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | February 03, 2022     | DEPP-213               | Created file                 | 
      |                                |                       |                        |                              | 
 */
public class B2BRegisterInterestBatch implements Database.Batchable<sObject>
{
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'SELECT Id, Contact__c,Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, Contact__r.Registered_Email__c,'; 
               query += 'Product__c, Product__r.Course__c, Product__r.Name, Product__r.Program_Plan__c, ';
               query += 'Type__c, Status__c ';
               query += 'FROM Expression_of_interest__c ' ;
               query += 'WHERE Status__c = \'Active\' ';
               query += 'AND Contact__r.Email != NULL ';
               query += 'AND Type__c = \'Register Interest\' ';
               query += 'AND ( Product__r.Course__c != NULL ';
               query += 'OR Product__r.Program_Plan__c != NULL)';
        return Database.getQueryLocator(query);
    }
 
    public void execute(Database.BatchableContext bc, List<Expression_of_Interest__c> expresionOfInterestList)
    {
        Map<Id,List<Id>> mapOfCourseToInterests = new Map<Id,List<Id>>(); // map of course to expresion of interests 
        Map<Id,List<Id>> mapOfProgramPlanToInterests = new Map<Id,List<Id>>(); // map of course to expresion of interests 
        Set<Id> interestEmailRecipientsSet = new Set<Id>(); // Set of expression of interests Ids that would receive an email
        Map<Id, Expression_of_Interest__c> expresionOfInterestMap = new Map<Id, Expression_of_Interest__c>(expresionOfInterestList);

        for(Expression_of_Interest__c interest : expresionOfInterestMap.values()){
            //construct map, this relates and groups expression of interests for each course
            if(interest.Product__r.Course__c != NULL){
                if(!mapOfCourseToInterests.containsKey(interest.Product__r.Course__c)){
                    mapOfCourseToInterests.put(interest.Product__r.Course__c,new List<Id>());
                }
                mapOfCourseToInterests.get(interest.Product__r.Course__c).add(interest.Id);
            }
            //construct map, this relates and groups expression of interests for each course

            //construct map, this relates and groups expression of interests for each program plan
            if(interest.Product__r.Program_Plan__c != NULL){
                if(!mapOfProgramPlanToInterests.containsKey(interest.Product__r.Program_Plan__c)){
                    mapOfProgramPlanToInterests.put(interest.Product__r.Program_Plan__c,new List<Id>());
                }
                mapOfProgramPlanToInterests.get(interest.Product__r.Program_Plan__c).add(interest.Id);
            }
            //construct map, this relates and groups expression of interests for each program plan
        }

        if(!mapOfCourseToInterests.keySet().isEmpty()){
            List<hed__Course_Offering__c> relatedCourseOfferings = new List<hed__Course_Offering__c>([SELECT Id, hed__Course__c, Available_Seats__c, On_Hold_Seat__c
                                                                                                        FROM hed__Course_Offering__c 
                                                                                                        WHERE hed__Course__c IN:mapOfCourseToInterests.keySet()
                                                                                                        AND Available_Seats__c > 0
                                                                                                        AND hed__Start_Date__c >  TODAY]);
            for(hed__Course_Offering__c courseOffering: relatedCourseOfferings){

                //check if offering has available seats (available seats - on hold seats)
                Decimal availableSeatTemp = courseOffering.Available_Seats__c != null?courseOffering.Available_Seats__c:0;
                Decimal onHoldSeatTemp = courseOffering.On_Hold_Seat__c != null?courseOffering.On_Hold_Seat__c:0;
                Decimal finalSeats = availableSeatTemp - onHoldSeatTemp;
                //check if offering has available seats (available seats - on hold seats)

                if( finalSeats > 0){
                    //store all Interests that have available course offerings in a set to remove duplicates
                    interestEmailRecipientsSet.addAll(mapOfCourseToInterests.get(courseOffering.hed__Course__c));
                }
            }
        }

        if(!mapOfProgramPlanToInterests.keySet().isEmpty()){
            List<Program_Offering__c> relatedProgramOfferings = new List<Program_Offering__c>([SELECT Id, hed_Program_Plan__c, Available_Seats__c
                                                                                                        FROM Program_Offering__c 
                                                                                                        WHERE hed_Program_Plan__c IN:mapOfProgramPlanToInterests.keySet()
                                                                                                        AND Available_Seats__c > 0
                                                                                                        AND Start_Date__c >  TODAY]);
            for(Program_Offering__c programOffering: relatedProgramOfferings){
                //store all Interests that have available program offerings in a set to remove duplicates
                interestEmailRecipientsSet.addAll(mapOfProgramPlanToInterests.get(programOffering.hed_Program_Plan__c));
            }
        }

        if(!interestEmailRecipientsSet.isEmpty()){
            List<Domain> domain = new List<Domain>([SELECT Id, Domain FROM Domain]);
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>([SELECT Id, HTMLValue from EmailTemplate WHERE DeveloperName = 'Offering_Available_Email_Notification']);
            OrgWideEmailAddress owea = new OrgWideEmailAddress();
            owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='QUTeX'];

            String basePortalUrl ='';
            if(!domain.isEmpty()){
                basePortalUrl= 'https://' + domain[0].Domain + '/study/s/product/';
            }
            
            List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();

            if(!emailTemplateList.isEmpty()){
                for(Id interestId : interestEmailRecipientsSet){
                    Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();

                    //Prepare SendToEmail List          
                    List<String> lstSendToEmails = new List<String>();

                    lstSendToEmails.add(expresionOfInterestMap.get(interestId).Contact__r.Registered_Email__c);
                
                    objEmail.setToAddresses(lstSendToEmails);

                    if(owea != null){
                        objEmail.setOrgWideEmailAddressId(owea.Id);
                    }

                    //Set Email Subject
                    objEmail.setSubject(expresionOfInterestMap.get(interestId).Product__r.Name);

                    //Set Email Body
                    String body = emailTemplateList[0].HTMLValue.replace('Contact_LastName',expresionOfInterestMap.get(interestId).Contact__r.LastName);

                    //To make sure that firstname is populated, it is not a required field 
                    if(expresionOfInterestMap.get(interestId).Contact__r.FirstName != null){ 
                        body = body.replace('Contact_FirstName', expresionOfInterestMap.get(interestId).Contact__r.FirstName);
                    }else{
                        body = body.replace('Contact_FirstName', '');
                    }
                    //To make sure that firstname is populated, it is not a required field 

                    body = body.replace('Product_Name', expresionOfInterestMap.get(interestId).Product__r.Name);
                    String productUrl = basePortalUrl + expresionOfInterestMap.get(interestId).Product__c;
                    body = body.replace('Product_URL', productUrl);
                    body = EmailHelper.addHeaderAndFooter(body);
                    
                    objEmail.setHtmlBody(body);
                    
                    lstEmails.add(objEmail);
                    //make sure email is not null
                }
            }
            
            String errorLocation = 'On method execute on class B2BRegisterInterestBatch: ';
            Messaging.SendEmailResult[] results;
            if(!lstEmails.isEmpty()){
                results = Messaging.sendEmail(lstEmails);
            } else {
                Logger.error(errorLocation + 'No emails to be sent.');
            }

            if(!results[0].success) {
                Logger.error(errorLocation + 'The email failed to send: ' + results[0].errors[0].message);
            }
            
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }  
    public void finish(Database.BatchableContext bc){}//NOPMD
}