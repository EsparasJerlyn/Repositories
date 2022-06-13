List<Product_Request__c> productRequestToUpdateList = new List<Product_Request__c>();

for(Product_Request__c prodReq: [SELECT Id, Product_Request_Status__c FROM Product_Request__c WHERE Product_Request_Status__c = 'In Delivery']){
    productRequestToUpdateList.add(new Product_Request__c(Id = prodReq.Id, Product_Request_Status__c = 'Published' ));
}

if(!productRequestToUpdateList.isEmpty()){
    update productRequestToUpdateList;
}