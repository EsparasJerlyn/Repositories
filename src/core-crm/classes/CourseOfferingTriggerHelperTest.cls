/**
 * @description Test class for CourseOfferingTriggerHelper
 * @see CourseOfferingTriggerHelper
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kenneth.f.alsay                | September 25, 2023    | DEPP-6629              | Created file                 |
      |                                |                       |                        |                              |
      
 */
@isTest
public class CourseOfferingTriggerHelperTest {

    @TestSetup
    public static void testSetup(){
        //create test user
        Test.startTest();
        TestDataFactoryUser.generateUserQUTeXProgramAdministrator();
        Test.stopTest();
        //create Test Account record
        List<Account> accountList = TestDataFactory.createTestAccountRecords(1);
        accountList[0].Organization_Unit_Level__c = '2';
        accountList[0].RecordTypeId = AccountsDAO.ACCT_UNIV_DEP_ID;
        AccountsDAO.newInstance().insertRecords(accountList, false, AccessLevel.USER_MODE);
        
        List<AccountShare> accShare = TestDataFactory.createAccountShareRecords(accountList, TestDataFactoryUser.selectUserQUTeXProgramAdministrator.Id, 'Edit');
        insert accShare;
        
        //create Test Term record
        List<hed__Term__c> termList = TestDataFactory.createTestTermRecords(200, accountList[0].Id);
        TermsDAO.newInstance().insertRecords(termList, false, AccessLevel.USER_MODE);
        
        //create Test Course record
        List<hed__Course__c> courseList = TestDataFactory.createTestCourseRecords(200, accountList[0].Id, null);
        CoursesDAO.newInstance().insertRecords(courseList, false, AccessLevel.USER_MODE);
        //create Course Offering Records
        System.RunAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
        	List<hed__Course_Offering__c> courseOfferingList = TestDataFactory.createTestCourseOfferingRecord(200, courseList, termList);
        	for(hed__Course_Offering__c courseOffering : courseOfferingList){
           	 	courseOffering.LMS_Integration_Status__c = 'Success';
            	courseOffering.hed__End_Date__c = System.today() + 30;
        	}
        	CourseOfferingsDAO.newInstance().insertRecords(courseOfferingList, false, AccessLevel.USER_MODE);
        }
    }
    
    @isTest
    public static void CourseOfferingTriggerHelperTestMethod(){
        System.RunAs(TestDataFactoryUser.selectUserQUTeXProgramAdministrator){
 			Test.StartTest();
            List<hed__Course_Offering__c> courseOfferingList = CourseOfferingsDAO.newInstance().getRecordsLikeName('CourseOffering');
			//test changing start date
            for(Integer i = 0 ; i<100 ; i++){
                courseOfferingList[i].hed__Start_Date__c = System.today() + 1;
            }
            //test changing end date
            for(Integer i = 100 ; i<200 ; i++){
                courseOfferingList[i].hed__End_Date__c = System.today() + 40;
            }
            CourseOfferingsDAO.newInstance().updateRecords(courseOfferingList, false, AccessLevel.USER_MODE);
            
            //get Updated Records
            List<hed__Course_Offering__c> updatedCourseOfferingRecords = [SELECT Id, LMS_Integration_Status__c FROM hed__Course_Offering__c WHERE LMS_Integration_Status__c = 'isChanged'];
            
            System.assertEquals(200, updatedCourseOfferingRecords.size(), 'Expected 200 Course Offerings records with isChanged LMS Integration Status');
            Test.StopTest();
        }
    }
}