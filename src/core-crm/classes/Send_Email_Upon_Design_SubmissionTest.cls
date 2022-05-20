/**
 * @description Test Class for Send Email Upon Design Submission Flow
 *
 * @see ../flows/Send_Email_Upon_Design_Submission
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | adrian.c.habasa           | January 6, 2022       | DEPP-301     | Created file                                |
      | eccarius.munoz            | January 10, 2022      | DEPP-1349    | Added Test method for Single Product Record |
      |                           |                       |              |                                             |
*/
@IsTest(SeeAllData = false)
private class Send_Email_Upon_Design_SubmissionTest {
    private static string PS_PROGRAM_SPEC = System.Label.RT_ProductSpecification_OPEProgramSpecification;
    private static string PR_SHORTCOURSE = System.Label.RT_ProductRequest_ShortCourse;
    private static string PR_MODULE = System.Label.RT_ProductRequest_Program;
    private static string PR_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static string C_ACTIVITY = System.Label.RT_ProductRequest_Activity;
    private static string C_MODULE = System.Label.RT_Course_Module;
    private static string C_SHORTCOURSE = System.Label.RT_Course_ShortCourse;

    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    private static Id opeProdSpecId = Schema.SObjectType.Product_Specification__c.getRecordTypeInfosByDeveloperName().get(PS_PROGRAM_SPEC).getRecordTypeId();
    private static Id opeActProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_ACTIVITY).getRecordTypeId();
    private static Id opeActivityId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(C_ACTIVITY).getRecordTypeId();
    private static Id opeShortProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_SHORTCOURSE).getRecordTypeId();
    private static Id opeShortCourseId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(C_SHORTCOURSE).getRecordTypeId();
    private static Id opeSingleProdReqId = Schema.SObjectType.Product_Request__c.getRecordTypeInfosByDeveloperName().get(PR_MODULE).getRecordTypeId();
    private static Id opeSingleProdId = Schema.SObjectType.hed__Course__c.getRecordTypeInfosByDeveloperName().get(C_MODULE).getRecordTypeId();
    private static Integer numberOfRecords = 100;

    private static final String ACCT_UNIV_DEP = System.Label.RT_Account_University_Department;
    private static final Id ACCT_UNIV_DEP_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCT_UNIV_DEP).getRecordTypeId();

    @isTest
    private static void emailActivityUponSubmissionTest(){
        System.runAs(currentUser){
            Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
            insert customEmail;

            List<Account> acc = TestDataFactory.createTestAccountRecords(1);
            for(Account account : acc){
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '2';
            }
            insert acc;

            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            for(Integer i = 0 ; i < conList.size() ; i++){
                conList[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert conList;

            hed__Facility__c fac = new hed__Facility__c();
            fac.Name = 'Externals';
            insert fac;

            List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(1,acc[0].Id,conList.iterator().next()?.Id);
            insert oppList;

            List<Product_Specification__c> prodSpecList = TestDataFactory.createTestProductSpecsRecords(1,conList,oppList);
            for(Integer i = 0 ; i < prodSpecList.size() ; i++){
                prodSpecList[i].RecordTypeId = opeProdSpecId;
                prodSpecList[i].Stage__c = 'Idea';
                prodSpecList[i].Status__c = 'Idea Sent';
                prodSpecList[i].Requestor_Name__c = conList[i].Id;
            }
            insert prodSpecList;

            List<Product_Request__c> pr = TestDataFactory.createTestProductRequestRecords(1);
            for(Integer i = 0 ; i < pr.size() ; i++){
            pr[i].RecordTypeId = opeActProdReqId;
            }
            insert pr;

            Date startDate = date.today().addDays(1);
            Date endDate = startDate.addDays(1);

            List<hed__Course__c> course = TestDataFactory.createTestCourseRecords(numberOfRecords,acc[0].Id,pr[0].Id);
            for(Integer i = 0 ; i < course.size() ; i++){
                course[i].RecordTypeId = opeActivityId;
                course[i].hed__Course_ID__c = 'testActivity101';
                course[i].hed__Account__c = acc[0].Id;
                course[i].Name = 'NameActivity1';
                course[i].Start_Date__c = startDate;
                course[i].End_Date__c = endDate;
                course[i].Delivery_Type__c = 'Blended';
                course[i].Location__c = fac.Id;
                course[i].Location_Details__c = 'test1';
                course[i].Description__c = 'test';
                course[i].Certificate_Type__c = 'Certificate of Achievement';
                course[i].Design_Form_Status__c = 'Design Form Sent';
                course[i].External_Organisation__c = 'test';
                course[i].Collaboration_with_External_Organisation__c = 'Yes';
                course[i].Content__c = 'test';
                course[i].Resource_Details__c = 'test';
                course[i].Enrolment_Rules__c = 'test';
                course[i].Minimum_Participants__c = 10;
                course[i].Maximum_Participants__c = 100;
                course[i].Delivery_Support_v2__c = 'Catering';
                course[i].Delivery_Comments__c = 'test';
            }
            insert course;
            List<hed__Course__c> getCourse = new List<hed__Course__c>();
            List<hed__Course__c> courseRec = [SELECT id, Design_Form_Status__c FROM hed__Course__c LIMIT 100];
            Test.startTest();
            for(hed__Course__c updateCourse : courseRec){
                updateCourse.Design_Form_Status__c = 'Design Form Received';
                getCourse.add(updateCourse);
            }
            update getCourse;
            Test.stopTest();

            System.assertEquals(0, Limits.getEmailInvocations(),'Number of email invocations not as expected');
        }
    }

    @isTest
    private static void emailShortCourseOwnerUponSubmissionTest(){
        System.runAs(currentUser){
            Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
            insert customEmail;
            List<Account> acc = TestDataFactory.createTestAccountRecords(1);
            for(Account account : acc){
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '2';
            }
            insert acc;

            List<Contact> conList = TestDataFactory.createTestContactRecords(1);
            for(Integer i = 0 ; i < conList.size() ; i++){
                conList[i].Email = 'testIdeaFormUser'+i+'@mailinator.com';
            }
            insert conList;

            hed__Facility__c fac = new hed__Facility__c();
            fac.Name = 'Externals';
            insert fac;

            List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(1,acc[0].Id,conList.iterator().next()?.Id);
            insert oppList;

            List<Product_Specification__c> prodSpecList = TestDataFactory.createTestProductSpecsRecords(1,conList,oppList);
            for(Integer i = 0 ; i < prodSpecList.size() ; i++){
                prodSpecList[i].RecordTypeId = opeProdSpecId;
                prodSpecList[i].Stage__c = 'Idea';
                prodSpecList[i].Status__c = 'Idea Sent';
                prodSpecList[i].Requestor_Name__c = conList[i].Id;
            }
            insert prodSpecList;

            List<Product_Request__c> pr = TestDataFactory.createTestProductRequestRecords(1);
            for(Integer i = 0 ; i < pr.size() ; i++){
            pr[i].RecordTypeId = opeShortProdReqId;
            }
            insert pr;

            List<hed__Course__c> course = TestDataFactory.createTestCourseRecords(numberOfRecords,acc[0].Id,pr[0].Id);
            for(Integer i = 0 ; i < course.size() ; i++){
                course[i].RecordTypeId = opeShortCourseId;
                course[i].hed__Course_ID__c = 'Short101';
                course[i].hed__Account__c = acc[0].Id;
                course[i].Delivery_Type__c = 'Blended';
                course[i].Location_Details__c = 'test1';
                course[i].Name = 'test1';
                course[i].Proposal_Title__c = 'Short1';
                course[i].Previously_Developed_Content__c = 'Yes';
                course[i].Location__c = fac.Id;
                course[i].Description__c = 'test';
                course[i].Design_Form_Status__c = 'Design Form Sent';
                course[i].Certificate_Type__c = 'Certificate of Achievement';
                course[i].Collaboration_with_External_Organisation__c = 'Yes';
                course[i].Enrolment_Rules__c = 'test';
                course[i].Minimum_Participants__c = 10;
                course[i].Delivery_Support_v2__c = 'Catering';
                course[i].External_Organisation__c = 'test';
                course[i].Content__c = 'test';
                course[i].Resource_Details__c = 'test';
                //course[i].Participants__c = 'test';
                course[i].Maximum_Participants__c = 100;
                course[i].Delivery_Comments__c = 'test';
            }
            insert course;
            List<hed__Course__c> getCourse = new List<hed__Course__c>();
            List<hed__Course__c> courseRec = [SELECT id, Design_Form_Status__c FROM hed__Course__c LIMIT 100];
            Test.startTest();
            for(hed__Course__c updateCourse : courseRec){
                updateCourse.Design_Form_Status__c = 'Design Form Received';
                getCourse.add(updateCourse);
            }
            update getCourse;
            Test.stopTest();

            System.assertEquals(0, Limits.getEmailInvocations(),'Number of email invocations not as expected');
        }
    }

    @isTest
    private static void emailSingleProductOwnerUponSubmissionTest(){
        System.runAs(currentUser){
            Flow_Automation_Settings__c customEmail = new Flow_Automation_Settings__c(Name='test',New_Idea_To_Email_Address__c = 'test-qutex@yopmail.com');
            insert customEmail;

            List<Account> acc = TestDataFactory.createTestAccountRecords(1);
            for(Account account : acc){
                account.RecordTypeId = ACCT_UNIV_DEP_ID;
                account.Organization_Unit_Level__c = '2';
            }
            insert acc;

            List<Contact> conList = TestDataFactory.createTestContactRecords(numberOfRecords);
            for(Integer i = 0 ; i < conList.size() ; i++){
                conList[i].Email = 'testIdeaFormUser' + i + '@mailinator.com';
            }
            insert conList;

            hed__Facility__c fac = new hed__Facility__c();
            fac.Name = 'Externals';
            insert fac;

            List<Opportunity> oppList = TestDataFactory.createTestOpportunityRecords(numberOfRecords, acc[0].Id, conList.iterator().next()?.Id);
            insert oppList;

            List<Product_Specification__c> prodSpecList = TestDataFactory.createTestProductSpecsRecords(numberOfRecords, conList, oppList);
            for(Integer i = 0 ; i < prodSpecList.size() ; i++){
                prodSpecList[i].RecordTypeId = opeProdSpecId;
                prodSpecList[i].Stage__c = 'Idea';
                prodSpecList[i].Status__c = 'Idea Sent';
                prodSpecList[i].Requestor_Name__c = conList[i].Id;
            }
            insert prodSpecList;

            List<Product_Request__c> pr = TestDataFactory.createTestProductRequestRecords(1);
            for(Integer i = 0 ; i < pr.size() ; i++){
                pr[i].RecordTypeId = opeSingleProdReqId;
            }
            insert pr;

            List<hed__Course__c> course = TestDataFactory.createTestCourseRecords(numberOfRecords, acc[0].Id, pr[0].Id);
            for(Integer i = 0 ; i < course.size() ; i++){
                course[i].RecordTypeId = opeSingleProdId;
                course[i].hed__Course_ID__c = 'Module Product Test';
                course[i].hed__Account__c = acc[0].Id;
                course[i].Delivery_Type__c = 'Blended';
                course[i].Location_Details__c = 'test1';
                course[i].Name = 'test1';
                course[i].Proposal_Title__c = 'Module Product Proposal Title Test';
                course[i].Previously_Developed_Content__c = 'Yes';
                course[i].Location__c = fac.Id;
                course[i].Description__c = 'test';
                course[i].Design_Form_Status__c = 'Design Form Sent';
                course[i].Certificate_Type__c = 'Certificate of Achievement';
                course[i].Collaboration_with_External_Organisation__c = 'Yes';
                course[i].Minimum_Participants__c = 100;
                course[i].Delivery_Support_v2__c = 'Catering';
                course[i].External_Organisation__c = 'test';
                course[i].Content__c = 'test';
                course[i].Resource_Details__c = 'test';
                //course[i].Participants__c = 'test';
                course[i].Maximum_Participants__c = 100;
                course[i].Delivery_Comments__c = 'test';
            }
            insert course;
            List<hed__Course__c> getCourse = new List<hed__Course__c>();
            List<hed__Course__c> courseRec = [SELECT id, Design_Form_Status__c FROM hed__Course__c LIMIT 100];
            Test.startTest();
            for(hed__Course__c updateCourse : courseRec){
                updateCourse.Design_Form_Status__c = 'Design Form Received';
                getCourse.add(updateCourse);
            }
            update getCourse;
            Test.stopTest();

            System.assertEquals(0, Limits.getEmailInvocations(),'Number of email invocations not as expected');
        }
    }
}