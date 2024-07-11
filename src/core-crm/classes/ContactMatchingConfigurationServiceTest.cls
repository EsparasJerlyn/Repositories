/**
* @description Tests the ContactMatchingConfigurationService
*
* @see ContactMatchingConfigurationService
*
* @author Accenture
*
* @history
*    | Developer Email           | Date                  | JIRA       | Change Summary                  |
     |---------------------------|-----------------------|------------|---------------------------------|
     | roy.nino.s.regala         | April 18, 2024        | DEPP-7986  | Created file                    |  
*/

@isTest
private class ContactMatchingConfigurationServiceTest {

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
    // Service class is mocked, user will never create/update records. 
    //With this user access cannot be tested
    private static void processNoiseRemovalTest(){
        ImplementationSelector.DAO.setMock(new ContactMatchingConfigurationsDAOMock());
        ContactMatchingConfigurationsDAO.newInstance().insertRecords(new List<Contact_Matching_Configuration__c>{
            new Contact_Matching_Configuration__c(
                Field_Name__c = 'BirthDate',
                Noise_String__c ='1000-01-01'
            ),
            new Contact_Matching_Configuration__c(
                Field_Name__c = 'LastName',
                Noise_String__c ='+'
            ),
            new Contact_Matching_Configuration__c(
                Field_Name__c = 'All',
                Noise_String__c ='$'
            )
        },true,AccessLevel.SYSTEM_MODE);


        List<ContactMatchingService.MatchingAttributes> matchingRecords = new List<ContactMatchingService.MatchingAttributes>{ 
                new ContactMatchingService.MatchingAttributes(
                    new Map<String,String>{
                        'firstName' => 'firstname$',
                        'lastName' => 'lastname+',
                        'birthDate' => '1000-01-01',
                        'mobilePhone' => '65654+'
                }
            ) 
        };

        // generate a matching attributes map where the key is the concatenated attributes with the noise
        Map<String, ContactMatchingService.MatchingAttributes> matchingRecordsMap = ContactMatchingService.generateMatchingAttributeMap(matchingRecords);

        ContactMatchingConfigurationService.processNoiseRemoval(matchingRecordsMap);

        for(ContactMatchingService.MatchingAttributes matchingRecord : matchingRecordsMap.values()){
            System.assertEquals('',matchingRecord.get('birthDate'),'birthdate should be blank');
            System.assertEquals('',matchingRecord.get('mobilePhone'),'mobile should be blank');
            System.assertEquals('firstname',matchingRecord.get('firstName'),'firstName should be firstname');
            System.assertEquals('lastname',matchingRecord.get('lastName'),'lastName should be lastname');
        }
    }


}