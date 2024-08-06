/**
 * @description Tests the Product Details Controller Test Class
 *
 * @see ProductDetailsCtrl
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.aldric.s.seril   	       | July 30, 2024         | DEPP-9834              | Created file                 | 
 */
@isTest
public class AmazonHttpCalloutTest {
	@testSetup
    static void setupMethod() {
        Test.startTest();
        TestDataFactoryUser.generateUserSystemAdministrator();
        Holiday holidayRec = new Holiday(name = 'Holiday Testing',
                                         ActivityDate = Date.Today());        
        insert holidayRec;
        Test.stopTest();

    }
    
    @isTest
    private static void syncOperatingHoursCreateTest() {
        List<OperatingHours> operatingHoursRecordList = TestDataFactory.createOperatingHoursRecord(1);
        List<Holiday> holidayRecords = [Select Id, Name from Holiday where Name = 'Holiday Testing'];
        for(OperatingHours operatingHrsRec : operatingHoursRecordList){
            operatingHrsRec.Name = 'Testing Operating Hours';
            operatingHrsRec.Description = 'Test Description';
            operatingHrsRec.Channel_Type__c = 'Voice';
        }
        OperatingHoursDAO.newInstance().insertRecords(operatingHoursRecordList, false, AccessLevel.USER_MODE);
        
        List<TimeSlot> timeSlotRecordList = TestDataFactory.createTimeSlotRecord(5,operatingHoursRecordList[0].Id);
        timeSlotRecordList[1].dayOfWeek = 'Tuesday';
        timeSlotRecordList[2].dayOfWeek = 'Wednesday';
        timeSlotRecordList[3].dayOfWeek = 'Thursday';
        timeSlotRecordList[4].dayOfWeek = 'Friday';
        
        insert timeSlotRecordList;
       
        OperatingHoursHoliday operatingHrsHol = new OperatingHoursHoliday(OperatingHoursId = operatingHoursRecordList[0].Id,
                                                                          HolidayId = holidayRecords[0].Id);	        
        insert operatingHrsHol;
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Test.startTest();
            String responseStatus = AmazonHttpCallout.syncOperatingHours(operatingHoursRecordList[0].Id);
            Test.stopTest();
            System.assert(responseStatus == 'Success', 'Sync Failed');
        }
        
    }    
    
    @isTest
    private static void syncOperatingHoursUpdateTest() {
        System.runAs(TestDataFactoryUser.selectUserSystemAdministrator) {
            List<OperatingHours> operatingHoursRecordList = TestDataFactory.createOperatingHoursRecord(1);
            for(OperatingHours operatingHrsRec : operatingHoursRecordList){
                operatingHrsRec.Name = 'Testing Operating Hours';
                operatingHrsRec.Description = 'Test Description';
                operatingHrsRec.Channel_Type__c = 'Voice';
                operatingHrsRec.AWS_Business_Hour_External_ID__c = '123456';
            }
            OperatingHoursDAO.newInstance().insertRecords(operatingHoursRecordList, false, AccessLevel.USER_MODE);
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Test.startTest();
            String responseStatus = AmazonHttpCallout.syncOperatingHours(operatingHoursRecordList[0].Id);
            Test.stopTest();    
            System.assert(responseStatus == 'Success', 'Sync Failed');
        }
    }   
}