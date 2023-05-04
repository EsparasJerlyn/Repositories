/**
 * @description test class for MockIdGenerator
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
public with sharing class MockIdGeneratorTest {
    @isTest
    // prettier-ignore
    static void testGetMockId() {//NOPMD no specific user to run as for testing the mockidgenerator
        // Create a new Account record
        Account acc = new Account();
        // Instantiate a new MockIdGenerator for the Account object
        MockIdGenerator idGenerator = new MockIdGenerator(acc);
        // Get a mock ID for the Account object
        Id mockId = idGenerator.getMockId();
        // Verify that the ID is not null
        System.assertNotEquals(null, mockId,'mockid should not be null');
    }

    @isTest
    // prettier-ignore
    static void testStaticGetMockId() {//NOPMD no specific user to run as for testing the mockidgenerator
        // Create a new Account record
        Account acc = new Account();
        // Get a mock ID for the Account object
        Id mockId = MockIdGenerator.getMockId(acc);
        // Verify that the ID is not null
        System.assertNotEquals(null, mockId,'mockid should not be null');
    }
}
