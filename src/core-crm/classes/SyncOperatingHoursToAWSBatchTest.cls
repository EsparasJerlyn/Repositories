/**
 * @description Batch class Sync Operating Hours to AWS
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.aldric.s.seril   	       | Jul. 29, 2024         | DEPP-9834              | Created file                 | 
 */
@isTest
public class SyncOperatingHoursToAWSBatchTest {

    @testSetup 
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Test.stopTest();
		
    }
    
    
    @isTest
    private static void runToCompleteTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<OperatingHours> operatingHoursRecordList = TestDataFactory.createOperatingHoursRecord(2);
            for(OperatingHours operatingHrsRec : operatingHoursRecordList){
                operatingHrsRec.Name = 'Testing Operating Hours';
                operatingHrsRec.Description = 'Test Description';
                operatingHrsRec.Channel_Type__c = 'Voice';
            }
            OperatingHoursDAO.newInstance().insertRecords(operatingHoursRecordList, false, AccessLevel.USER_MODE);
            
            List<TimeSlot> timeSlotRecordList = TestDataFactory.createTimeSlotRecord(1,operatingHoursRecordList[0].Id);
            insert timeSlotRecordList;
            Test.startTest();    
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            SyncOperatingHoursToAWSBatch batch = new SyncOperatingHoursToAWSBatch();
            Database.executeBatch(batch);
            Test.stopTest();  
            System.assert(![SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'SyncOperatingHoursToAWSBatch'].isEmpty() , 'SyncOperatingHoursToAWSBatch Job was not executed');
        
            
        }
    }
        
}