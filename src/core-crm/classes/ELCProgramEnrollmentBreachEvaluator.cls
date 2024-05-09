/**
 * @description Class to be used in parsing Engagement_List_Criteria__c for outreach case
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                              |
      |--------------------------------|-----------------------|------------------------|-------------------------------------------------------------|
      | arsenio.jr.dayrit              | May 07, 2024          | DEPP-8487              | Created file                                                |
*/
public with sharing class ELCProgramEnrollmentBreachEvaluator {
    
    private ELCParser elcParser;

    public ELCProgramEnrollmentBreachEvaluator(ELCParser elcParser) {
        this.elcParser = elcParser;
    }

    // Return null if query not executed
    public Map<Id, List<Program_Enrollment_Breach__c>> evaluate(Map<Id, Contact> contactMap) {

        Map<Id, List<Program_Enrollment_Breach__c>> programEnrollmentBreachMap;

        if (!elcParser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria().isEmpty()) {
            // if none of the child or grand child criteria defined, fire query and inherit parent / grand parent criteria
            elcParser.getELCContactParser().getContactCriteria().setContactIdSet(contactMap.keySet());
            //elcParser.getContactCriteria().contactIdSet.addAll(contactMap.keySet());

            //add contact id set into soql
            List<Program_Enrollment_Breach__c> programEnrollmentBreaches = ProgramEnrollmentBreachesDAO.newInstance().findByCriteria(
                elcParser.getELCProgramEnrollmentBreachParser().getProgramEnrollmentBreachCriteria(),
                elcParser.getELCProgramEnrollmentParser().getProgramEnrollmentCriteria(), 
                elcParser.getELCContactParser().getContactCriteria(),
                AccessLevel.SYSTEM_MODE);
            programEnrollmentBreachMap = groupByContact(programEnrollmentBreaches);
        }
        // if any of the child or grandchild criteria defined, only run the query in the child or grandchild
        return programEnrollmentBreachMap;
    }


    private Map<Id, List<Program_Enrollment_Breach__c>> groupByContact(List<Program_Enrollment_Breach__c> programEnrollmentBreaches) {
        Map<Id, List<Program_Enrollment_Breach__c>> programEnrollmentBreachByContactMap = new Map<Id, List<Program_Enrollment_Breach__c>>();

        for(Program_Enrollment_Breach__c programEnrollmentbreach : programEnrollmentBreaches){
            if(programEnrollmentBreachByContactMap.containsKey(programEnrollmentbreach.Program_Enrollment__r.hed__Contact__c)){
                programEnrollmentBreachByContactMap.get(programEnrollmentbreach.Program_Enrollment__r.hed__Contact__c).add(programEnrollmentbreach);
            }else{
                List<Program_Enrollment_Breach__c> programEnrollmentBreachList = new List<Program_Enrollment_Breach__c>();
                programEnrollmentBreachList.add(programEnrollmentbreach);
                programEnrollmentBreachByContactMap.put(programEnrollmentbreach.Program_Enrollment__r.hed__Contact__c, programEnrollmentBreachList);
            }
        }
        
        return programEnrollmentBreachByContactMap;
    }
}
