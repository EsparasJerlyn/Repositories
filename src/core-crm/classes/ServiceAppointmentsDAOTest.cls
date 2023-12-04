/**
 * @description Test Class for ServiceAppointmentsDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary                                      |
 *    |--------------------------------|-----------------------|------------------------|-----------------------------------------------------|
 *    | arsenio.jr.dayrit              | November 22, 2023     |DEPP-7264               | Created File                                        |
 *    | neil.s.h.lesidan               | November 29, 2023     |DEPP-7280               | Add test method getServiceAppointmentByEmailTest    |
 */
@isTest
public with sharing class ServiceAppointmentsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUT_Program_Administrator' });
    }

    @isTest
    static void newInstanceTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(ServiceAppointmentsDAO.newInstance() != null, 'ServiceAppointmentsDAO instance is null');
        }
        Test.stopTest();
    }

    @isTest
    static void getSObjectTypeTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            System.assert(
                new ServiceAppointmentsDAO().getSObjectType() == ServiceAppointment.SObjectType,
                'SObject is not ServiceAppointment'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getServiceAppointmentByEmailTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<ServiceAppointment> serviceAppointment = ServiceAppointmentsDAO.newInstance()
                .getServiceAppointmentByEmail(
                    '',
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(serviceAppointment.isEmpty(), 'serviceAppointment is not empty');
        }
        Test.stopTest();
    }
} 