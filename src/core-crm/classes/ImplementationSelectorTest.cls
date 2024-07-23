/**
 * @description Test class for ImplementationSelector
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 25, 2023        | DEPP-5567              | Created file
 */
@isTest
private class ImplementationSelectorTest {
    @isTest
    // prettier-ignore
    static void daoFactoryTest(){//NOPMD - no specific user needed to run as for the selector class
        System.assert(ImplementationSelector.DAO.newInstance(Account.SObjectType) != null,'implementation should not be null');
    }

    @isTest
    // prettier-ignore
    static void daoFactoryEmptyTest(){//NOPMD - no specific user needed to run as for the selector class
        System.assert(new ImplementationSelector.DAOFactory() != null,'implementation should not be null');
    }

    @IsTest
    // prettier-ignore
    static void testDAOFactory() {//NOPMD - no specific user needed to run as for the selector class
        ImplementationSelector.DAOFactory daoFactory = new ImplementationSelector.DAOFactory(
			new Map<SObjectType, Type> {
                Account.SObjectType => AccountsDAO.class});

		System.assert(daoFactory != null, 'dao factory should not be null');
		System.assert(daoFactory.newInstance(Account.SObjectType) != null, 'new instance should not be null');

    }

    @IsTest
    // prettier-ignore
    static void testDAOMockFactory() {//NOPMD - no specific user needed to run as for the selector class
        ImplementationSelector.DAOFactory daoFactory = new ImplementationSelector.DAOFactory(
			new Map<SObjectType, Type> {
                Account.SObjectType => AccountsDAO.class});

		System.assert(daoFactory != null, 'dao factory should not be null');

		daoFactory.setMock(new AccountsDAOMock());

		System.assert(daoFactory.newInstance(Account.SObjectType) != null, 'new instance should not be null');

    }

    @IsTest
    // prettier-ignore
    static void testDAOFactoryError() {//NOPMD - no specific user needed to run as for the selector class
        ImplementationSelector.DAOFactory daoFactory = new ImplementationSelector.DAOFactory(
			new Map<SObjectType, Type> {});
	
		try{
			daoFactory.newInstance(Account.SObjectType);
		}catch(Exception e){
			System.assert(e  != null, 'should have error');
		}
    }
    
}
