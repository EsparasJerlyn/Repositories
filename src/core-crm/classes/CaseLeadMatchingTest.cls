/**
 * @description Test Apex Class for CaseLeadMatching Flow
 * @see src\core-crm\flows\Case_Lead_Matching.flow-meta.xml
 * @author Accenture
 * @history
 * | Developer         | Date        | JIRA      | Change Summary
 * |-------------------|-------------|-----------|---------------...
 * | alexander.cadalin | Nov 02 2022 | DEPP-4326 | Created file
 * |                   | Nov 03 2022 |           | Added System.runAs()
 */

@isTest public class CaseLeadMatchingTest {
    final static String FIRSTNAME = 'Alexa';
    final static String LASTNAME = 'Nacaldi';
    final static String NAME = FIRSTNAME + ' ' + LASTNAME;
    final static String EMAIL = 
        FIRSTNAME.toLowerCase() + '.' + 
        LASTNAME.toLowerCase() + 
        '@email.test';
    final static Id ID_INTENQ = [
        SELECT Id FROM RecordType 
        WHERE DeveloperName = 'International_Enquiry' 
        AND SobjectType = 'Case'].Id;
    
    @testSetup static void setup() {
        TestDataFactory.generateTestUsers();
        Lead ld = new Lead(
            FirstName = FIRSTNAME,
            LastName = LASTNAME,
            Company = 'Case Lead Matching Research Facility',
            Email = EMAIL,
            OwnerId = TestDataFactory.getISRStudentEnquiriesCommunicationOfficer().Id
        );
        insert ld;
    }
    
    /**
     * Lead Matched With Single Case
     * Connect one Lead record to one Case record.
     */
    @isTest static void leadMatchedSingleCase() {
        System.runAs(TestDataFactory.getISRStudentEnquiriesCommunicationOfficer()){
            Case cs = new Case(
                SuppliedEmail = EMAIL, 
                RecordTypeId = ID_INTENQ);
            Test.startTest();
            insert cs;
            Test.stopTest();
            Id ldId = [SELECT Id FROM Lead WHERE Name=:NAME LIMIT 1].Id;
            Case csInserted = [SELECT Id, Lead__c FROM Case LIMIT 1];
            System.assert(
                csInserted.Lead__c == ldId, 
                'The Case record\'s Lead field was not ' +
                'updated with the correct Lead.'
            );
        }
    }
    
    /**
     * Lead Matched With Multiple Similar Cases
     * Connect one Lead record to numerous Cases that uses
     * the same Web Email.
     */
    @isTest static void leadMatchedMultipleSimilarCases() {
        System.runAs(TestDataFactory.getISRStudentEnquiriesCommunicationOfficer()){
			List<Case> cases = new List<Case>();
            for(Integer i = 0; i < 100; i++) {
                Case cs = new Case(
                    SuppliedEmail = EMAIL, 
                    RecordTypeId = ID_INTENQ, 
                    Subject = 'Case#' + i);
                cases.add(cs);
            }
            Test.startTest();
            insert cases;
            Test.stopTest();
            Id ldId = [SELECT Id FROM Lead WHERE Name=:NAME LIMIT 1].Id;
            List<Case> casesInserted = [SELECT Id, Lead__c FROM Case];
            for(Case cs : casesInserted) {
                System.assert(
                    cs.Lead__c == ldId, 
                    'A Case record\'s Lead field was not ' + 
                    'updated with the correct Lead.');
            }            
        }
    }
    
    /**
     * No Matches Found
     * The Case record's Lead field must not be changed.
     */
    @isTest static void noMatches() {
        System.runAs(TestDataFactory.getISRStudentEnquiriesCommunicationOfficer()){
            Case cs = new Case(
                SuppliedEmail = Integer.valueof(
                    Math.random() * 1000000) + '@randomized.email', 
                RecordTypeId = ID_INTENQ);
            Test.startTest();
            insert cs;
            Test.stopTest();
            Case csInserted = [SELECT Id, Lead__c FROM Case LIMIT 1];
            System.assert(
                String.isBlank(csInserted.Lead__c), 
                'The Case record\'s Lead field was not ' +
                'updated with the correct Lead.');
        }
    }
}