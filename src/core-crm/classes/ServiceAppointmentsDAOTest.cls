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
 *    | nicole.genon                   | November 27, 2023     |DEPP-7259               | Added getServiceAppointmentsBySetIdsTest            |
 *    | neil.s.h.lesidan               | November 29, 2023     |DEPP-7280               | Add test method getServiceAppointmentByEmailTest    |
 *    | arsenio.jr.dayrit              | December 14, 2023     |DEPP-7357               | Added Test Method getServiceAppointmentByLeadIdTest |
 */
@isTest
public with sharing class ServiceAppointmentsDAOTest {
    @testSetup
    static void testSetup() {
        TestDataFactory.generateTestUsers(new List<String>{ 'QUTeX_Program_Administrator' });
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
    static void getServiceAppointmentsBySetIdsTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<ServiceAppointment> serviceAppointmentList = ServiceAppointmentsDAO.newInstance()
                .getServiceAppointmentsBySetIds(new Set<Id>(), new List<String>(), AccessLevel.SYSTEM_MODE);
            System.assert(serviceAppointmentList.isEmpty(), 'serviceAppointmentList is not empty');
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

    @isTest
    static void getServiceAppointmentByAppointmentEmailTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<ServiceAppointment> serviceAppointment = ServiceAppointmentsDAO.newInstance()
                .getServiceAppointmentByAppointmentEmail(
                    '',
                    AccessLevel.SYSTEM_MODE
                );
            System.assert(serviceAppointment.isEmpty(), 'serviceAppointment is not empty');
        }
        Test.stopTest();
    }

    @isTest
    static void getServiceAppointmentByLeadIdTest() {
        Test.startTest();
        System.runAs(TestDataFactory.getProgramAdminUser()) {
            List<ServiceAppointment> serviceAppointment = ServiceAppointmentsDAO.newInstance()
                .getServiceAppointmentByLeadId(
                    new Set<Id>()
                );
            System.assert(serviceAppointment.isEmpty(), 'serviceAppointment is not empty');
        }
        Test.stopTest();
    }
}
