/**
 * @description Test Class for Update Case Priority Flow
 *
 * @see ../flows/Update_Case_Priority_Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | arsenio.jr.dayrit         | October 27, 2022      | DEPP-4250    | Created File                                |
      |                           |                       |              |                                             |
*/
@isTest
private class Update_Case_Priority_FlowTest{


    private static final Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('International_Enquiry').getRecordTypeId();
   
    @TestSetup
    static void setupMethod(){
        Test.startTest();
        TestDataFactory.generateTestUsers();
        Test.stopTest();
        

    }

    @isTest
    private static void createCaseRecordPriotyByContactTest(){
        Test.startTest(); 
        System.runAs(TestDataFactory.getISRStudentEnquiriesCommunicationOfficer()){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;

            Marketing_Segmentation__c marketingSeg = new Marketing_Segmentation__c();
            marketingSeg.My_Country_Of_Citizenship__c = 'Indonesia';
            marketingSeg.My_Country_Of_Residency__c = 'Australia';
            insert marketingSeg;

            List<Contact> cont = TestDataFactory.createTestContactRecords(1);
            for(Integer i = 0 ; i < cont.size() ; i++){
                cont[i].Marketing_Segmentation__c = marketingSeg.Id;

            }
            insert cont;

            
            List<Case> caseList = TestDataFactory.createTestCaseRecords(1, null, cont);
            for(Integer i = 0 ; i < caseList.size() ; i++){
                caseList[i].setOptions(dmo);
            }
           
            insert caseList;
    
            

            List<Case> resultList = [SELECT Id, Priority FROM Case];
            for(Case resultCase : resultList){
                System.assertEquals('High', resultCase.Priority, 'Priority not updated');
            }
            
        }
        Test.stopTest(); 
    }

    @isTest
    private static void createCaseRecordPriotyByLeadTest(){
        Test.startTest(); 
        System.runAs(TestDataFactory.getISRStudentEnquiriesCommunicationOfficer()){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;

            Account acc = TestDataFactory.createTestAccount(true);

            Marketing_Segmentation__c marketingSeg = new Marketing_Segmentation__c();
            marketingSeg.My_Country_Of_Citizenship__c = 'Indonesia';
            marketingSeg.My_Country_Of_Residency__c = 'Australia';
            insert marketingSeg;

            List<Lead> lead = TestDataFactory.createTestLeadRecords(1);
            for(Integer i = 0 ; i < lead.size() ; i++){
                lead[i].Marketing_Segmentation__c = marketingSeg.Id;

            }
            insert lead;

            
            List<Case> caseList = TestDataFactory.createTestCaseRecords(1, lead, null);
            for(Integer i = 0 ; i < caseList.size() ; i++){
                caseList[i].setOptions(dmo);
            }
           
            insert caseList;
    
            

            List<Case> resultList = [SELECT Id, Priority FROM Case];
            for(Case resultCase : resultList){
                System.assertEquals('High', resultCase.Priority, 'Priority not updated');
            }
            
        }
        Test.stopTest(); 
    }
}

