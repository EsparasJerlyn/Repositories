String recordTypeDeveloperName = 'Course Financial Split';
Id recordTypeId = Schema.SObjectType.Financial_Split__c.getRecordTypeInfosByName().get(recordTypeDeveloperName).getRecordTypeId();
                                                       
List<Financial_Split__c> financialSplitList = [SELECT Id, RecordTypeId FROM Financial_Split__c WHERE RecordTypeId = null];

if(!financialSplitList.isEmpty()){
    for(Financial_Split__c record : financialSplitList){
        record.RecordTypeId = recordTypeId;
    }

    Database.SaveResult[] saveResultList = Database.update(financialSplitList, false);
    for (Database.SaveResult result : saveResultList){
        if(result.isSuccess()){
            System.debug('Successfully updated Financial Split record: ' + result.getId());
        }else{
            System.debug('Database error Financial Split record update ' + result.getErrors());
        }            
    }
}  