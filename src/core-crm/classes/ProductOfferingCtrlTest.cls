/**
 * @description Test class for Product Offering Controller
 *
 * @see ProductOfferingCtrl
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                |
      |---------------------------|-----------------------|--------------|-----------------------------------------------|
      | aljohn.motas              | February 8, 2022      | DEPP-1258    | Created file                                  | 
      |                           |                       |              |                                               |
*/
@isTest(SeeAllData=false)
public class ProductOfferingCtrlTest {
    private static final String STR_QUTEX = 'QUTeX';
    private static final String STR_QUTEX_TERM = STR_QUTEX + ' Term';

    @isTest
    static void getTermIdTest() {
        Account acc = new Account(Name='QUTeX');
		insert acc;

        String TermId = ProductOfferingCtrl.getTermId();
        Test.startTest();
			System.assertNotEquals(TermId,null);
	        TermId = ProductOfferingCtrl.getTermId();
        	String existingTermId = [Select Id From hed__Term__c Where Name =: STR_QUTEX_TERM AND Id =: TermId Limit 1]?.Id;
			System.assertEquals(TermId,existingTermId);
        Test.stopTest();

    }
    

    @isTest
    static void getAllFacilitatorBioTest() {
        Test.startTest();
	    ProductOfferingCtrl.getAllFacilitatorBio();
        Test.stopTest();
    }

    @isTest
    static void updateCourseConnectionsTest() {
        Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            Email = System.now().millisecond() + 'test@test.com'
        );
        insert(contact1);
		List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
        insert prodRequest;
        List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
        insert accounts;
        List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(25,accounts[0].Id,prodRequest[0].Id);
        insert courses;
        List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(25,accounts[0].Id);
        insert terms;
        List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(25,courses,terms);
        insert courseOfferings;
		List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(25);
        insert programPlans;
        List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(25, programPlans);
        insert programOfferings;
        List<hed__Course_Enrollment__c> courseConnections =  TestDataFactory.createTestCourseConnectionRecord(25,contact1?.Id,courseOfferings,programOfferings);
		insert courseConnections;
        System.debug(courseConnections);
        Test.startTest();
        courseConnections[0].hed__Account__c = accounts[0]?.Id;
	    ProductOfferingCtrl.updateCourseConnections(courseConnections);
        Test.stopTest();
        List<hed__Course_Enrollment__c> updatedCourseConnections = [Select hed__Account__c From hed__Course_Enrollment__c Where hed__Account__c =: accounts[0].Id];
        System.assertEquals(1, updatedCourseConnections.size());
    }
    
    
    @isTest
    static void getProductOfferingDataTest() {
		List<Product_Request__c> prodRequest =new List<Product_Request__c>();
        List<hed__Course_Enrollment__c> courseConnectionRecord = new List<hed__Course_Enrollment__c>();

		String PROGRAM_OFFERING_FIELDS = 'Id,Delivery_Type__c,Start_Date__c,Registration_Start_Date__c,'+
    		'Registration_End_Date__c,End_Date__c,hed_Program_Plan__c';
		String COURSE_OFFERING_FIELDS ='Id,Delivery_Type__c,hed__Start_Date__c,Registration_Start_Date__c,'+
    		'Registration_End_Date__c,hed__End_Date__c,hed__Course__c,hed__Term__c';        
        String productRequestId;
        Map<String,String> parentInfo = new Map<String,String>();
        parentInfo.put('objectType','hed__Program_Plan__c');
        parentInfo.put('field','Product_Request__c');
        Map<String,String> childInfo = new Map<String,String>();
        childInfo.put('objectType','Program_Offering__c');        
        childInfo.put('fields',PROGRAM_OFFERING_FIELDS);        
        childInfo.put('conditionField','hed_Program_Plan__c');        

        List<hed__Program_Plan__c> programPlans = new List<hed__Program_Plan__c>();
        List<Program_Offering__c> programOfferings = new List<Program_Offering__c>();
      
        prodRequest = TestDataFactory.createTestProductRequestRecords(1);
        insert prodRequest;
        System.debug('prodRequest');
        System.debug(prodRequest);

        List<hed__Program_Plan__c> programPlanList = new List<hed__Program_Plan__c>();
		programPlanList.add(new hed__Program_Plan__c(Name = 'Test Program Plan',Product_Request__c=prodRequest[0].Id));
        insert programPlanList;
        productRequestId = prodRequest[0].Id;
        programOfferings.add(
            new Program_Offering__c(
              Name = 'Test Program Offering',
              hed_Program_Plan__c = programPlanList[0].id,
              hed_Capacity__c = 10,
              Start_Date__c = system.today() + 1
            )
          );
        insert programOfferings;

//        List<hed__Course_Offering__c> courseOfferings = new List<hed__Course_Offering__c>();        
//        List<Contact> contacts = TestDataFactory.createTestContactRecords(1);
//        insert contacts;
//        List<hed__Course_Enrollment__c> courseConnections = TestDataFactory.createTestCourseConnectionRecord(1, contacts[0].Id, courseOfferings, programOfferings);
//        insert courseConnections;
        
	        Test.startTest();
	        ProductOfferingCtrl.ProductOfferingData POD = ProductOfferingCtrl.getProductOfferingData(productRequestId,parentInfo,childInfo);
    	    System.debug('POD'+POD);        
        	Test.stopTest();

    }
    
    
    
    
    @isTest
    static void cloneProductOfferingDataTest() {
        Account acc = new Account(Name='QUTeX');
		insert acc;
        Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            Email = System.now().millisecond() + 'test@test.com'
        );
        insert(contact1);
        List<Product_Request__c> prodRequest = TestDataFactory.createTestProductRequestRecords(1);
        insert prodRequest;
        List<Account> accounts = TestDataFactory.createTestAccountRecords(1);
        insert accounts;
        List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(25,accounts[0].Id,prodRequest[0].Id);
        insert courses;
        List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(25,accounts[0].Id);
        insert terms;
        List<hed__Course_Offering__c> courseOfferings = TestDataFactory.createTestCourseOfferingRecord(25,courses,terms);
        insert courseOfferings;
		List<hed__Program_Plan__c> programPlans = TestDataFactory.createTestProgramPlanRecords(25);
        insert programPlans;
        List<Program_Offering__c> programOfferings = TestDataFactory.createTestProgramOfferingRecords(25, programPlans);
        insert programOfferings;
        List<hed__Course_Enrollment__c> facilitators =  TestDataFactory.createTestCourseConnectionRecord(1,contact1?.Id,courseOfferings,programOfferings);
        List<Session__c> sessions = new List<Session__c>();
        sessions.add(new Session__c(Session_Name__c='Test'));
        String termId = ProductOfferingCtrl.getTermId();
        Map<String,Object> productOffering = new Map<String,Object>();
        productOffering.put('Delivery_Type__c','Online Classroom');
        productOffering.put('hed__Course__c',courses[0]?.Id);
        productOffering.put('hed__Term__c',termId);
        Test.startTest();
        ProductOfferingCtrl.cloneProductOfferingData('hed__Course_Offering__c',productOffering,facilitators,sessions);
        Test.stopTest();

    }
}