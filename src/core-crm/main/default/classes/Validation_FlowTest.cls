/**
* @description Test Class for "Course Connection Pricing Validation" & "Contact Staff Validation"
*
* @see ../flows/Course_Connection_Pricing_Validation
* @see ../flows/Contact_Staff-validation
*
* @author Accenture
*
* @history
| Developer                 | Date                  | JIRA         | Change Summary                              |
|---------------------------|-----------------------|--------------|---------------------------------------------|
| ana                       | April 20, 2022        | DEPP-2134    | Created file                                | 
|                           |                       |              |                                             | 
*/
@IsTest(SeeAllData = false)
private class Validation_FlowTest {
    private static User currentUser = TestDataFactory.createUserRecords(1, 'QUTeX').iterator().next();
    
    @IsTest
    private static void validationTest(){
        System.runAs(currentUser){
            List<Account> accList = TestDataFactory.createTestAccountRecords(1);
            accList[0].Name = 'OPE Catalogue';
            insert(accList);
            
            Webstore store = new Webstore(name='test store');
            insert store;
            
            List<WebCart> crt = new List<WebCart>{new WebCart(NAME='Test Cart',AccountID = accList[0].Id,WebStoreId=store.Id)};
                insert crt;
            
            List<Product2> prod = new List<Product2>{new Product2(name='test product')};
                insert prod;
            
            Id pricebookId = Test.getStandardPricebookId();
        
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod[0].Id,UnitPrice = 100, IsActive = true);
            insert standardPrice;
            
            List<Pricebook2> pbs = new List<Pricebook2>{new Pricebook2(name='Alumni'), new Pricebook2(name='Current Learner'), new Pricebook2(name='Current Staff')};
                insert pbs;
            
            List<PricebookEntry> pbEntry = new List<PricebookEntry>{new PricebookEntry(Pricebook2Id=pbs[0].Id,unitprice=98,Product2Id=prod[0].Id),
                new PricebookEntry(Pricebook2Id=pbs[1].Id,unitprice=98,Product2Id=prod[0].Id), new PricebookEntry(Pricebook2Id=pbs[2].Id,unitprice=98,Product2Id=prod[0].Id)};
                insert pbEntry;
            
            List<CartDeliveryGroup> cdg = new List<CartDeliveryGroup>{new CartDeliveryGroup(name='delivery test',CartId=crt[0].Id)};
                insert cdg;
            List<CartItem> item = new List<CartItem>{new CartItem(name='Alumni Test',CartId=crt[0].Id,Pricebook_Entry_ID__c=pbentry[0].Id,CartDeliveryGroupId=cdg[0].Id),
                new CartItem(name='Current Learner Test',CartId=crt[0].Id,Pricebook_Entry_ID__c=pbentry[1].Id,CartDeliveryGroupId=cdg[0].Id),
                new CartItem(name='Current Staff Test',CartId=crt[0].Id,Pricebook_Entry_ID__c=pbentry[2].Id,CartDeliveryGroupId=cdg[0].Id)};
                                                                      insert item;
            
            List<Product_Request__c> prodReqs = TestDataFactory.createTestProductRequestRecords(1);
            insert prodReqs;
            
            List<hed__Term__c> terms = TestDataFactory.createTestTermRecords(3, accList[0].Id);
            insert terms;
            
            List<hed__Course__c> courses = TestDataFactory.createTestCourseRecords(3,accList[0].Id,prodReqs[0].Id);
            insert courses;
            
            List<hed__Course_Offering__c> offerings = TestDataFactory.createTestCourseOfferingRecord(3,courses, terms);
            insert offerings;
            
            Test.startTest();
            
            List<Contact> con = new List<Contact>{new Contact(firstname='test', lastname='Ana')};
                con[0].Nominated_Student_ID__c = '123';
            con[0].Nominated_Employee_ID__c = '567';
            insert con;
            
            system.assertEquals([Select Id, Staff_Verified__c From Contact Where Id=: con[0].Id][0].Staff_Verified__c, false);
            
            List<hed__Course_Enrollment__c> cc = TestDataFactory.createTestCourseConnectionRecord(3,con[0].Id, offerings);
            cc[0].Cart_Item__c = item[0].Id;
            cc[1].Cart_Item__c = item[1].Id;
            cc[2].Cart_Item__c = item[2].Id;
            insert cc;
            
            system.assertEquals([Select Id, Pricing_Validation__c From hed__Course_Enrollment__c Where Id=: cc[0].Id][0].Pricing_Validation__c, 'Unsuccessful');
            
            con[0].QUT_Student_ID__c = '123';
            con[0].IsStaff_Active__c = true;
            con[0].QUT_Employee_ID__c = '567';
            update con;
            
            system.assertEquals([Select Id, Staff_Verified__c From Contact Where Id=: con[0].Id][0].Staff_Verified__c, true);
            
            cc[0].hed__Status__c = 'Completed';
            update cc;
            
            List<hed__Course_Enrollment__c> ccValidated = TestDataFactory.createTestCourseConnectionRecord(3,con[0].Id, offerings);
            ccValidated[0].Cart_Item__c = item[0].Id;
            ccValidated[1].Cart_Item__c = item[1].Id;
            ccValidated[2].Cart_Item__c = item[2].Id;
            
            insert ccValidated;
            
            system.assertEquals([Select Id, Pricing_Validation__c From hed__Course_Enrollment__c Where Id=: ccValidated[0].Id][0].Pricing_Validation__c, 'Successful');
            
            Test.stopTest();
        }
    }
}