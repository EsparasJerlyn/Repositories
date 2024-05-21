/**
* @description Tests the MatchingResult
*
* @see MatchingResult
*
* @author Accenture
*
* @history
*    | Developer Email           | Date                  | JIRA       | Change Summary                  |
     |---------------------------|-----------------------|------------|---------------------------------|
     | roy.nino.s.regala         | April 18, 2024        | DEPP-7986  | Created file                    |  
*/
@isTest
private class MatchingResultTest{

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // This is just a DTO/Value class, user will never create/update records. 
    private static void matchingResultConstructorWithContactsTest(){
        MockIdGenerator contactMock = new MockIdGenerator(Contact.sObjectType);
        
        MatchingResult result = new MatchingResult(new Set<Contact>{new Contact(Id = contactMock.getMockId())},'Natural Key Matching');
        system.assertEquals(1,result.contactIds.size(),'Contact ids should be 1');
        system.assertEquals(false,result.error,'there should be no error');
        system.assertEquals('Natural Key Matching',result.matchingType,'Natural Key Matching');
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // This is just a DTO/Value class, user will never create/update records. 
    private static void matchingResultConstructorWithErrorMessageTest(){
        MatchingResult result = new MatchingResult('','Insufficient Info');
        system.assertEquals('Insufficient Info',result.errorMessage,'there should be an error message');
        system.assertEquals(true,result.error,'there should be no error');
        system.assertEquals('',result.matchingType,'there should be no matching type');
    }


}