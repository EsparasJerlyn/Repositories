List<Lead> leadList = new List<Lead>([SELECT Id,Phone,MobilePhone,Work_Phone__c,LeadPhone_Locale__c,LeadMobile_Locale__c,WorkPhone_Locale__c
                                    FROM Lead 
                                    WHERE Phone_No_Locale__c = null AND 
                                    Mobile_No_Locale__c = null AND 
                                    Work_Phone_No_Locale__c = null]);

if(!leadList.isEmpty()){       
    for(Lead nlead: leadList){
        //copy fields
        nlead.Phone_No_Locale__c = nlead.Phone;
        nlead.Mobile_No_Locale__c = nlead.MobilePhone;
        nlead.Work_Phone_No_Locale__c = nlead.Work_Phone__c;
        
        //remove leading zeros from no locale fields
        Matcher phone_NL = Pattern.compile('^0+').matcher(nlead.Phone_No_Locale__c); 
        nlead.Phone_No_Locale__c = phone_NL.replaceAll('');
        Matcher mobile_NL = Pattern.compile('^0+').matcher(nlead.Mobile_No_Locale__c); 
        nlead.Mobile_No_Locale__c = mobile_NL.replaceAll('');
        Matcher workPhone_NL = Pattern.compile('^0+').matcher(nlead.Work_Phone_No_Locale__c); 
        nlead.Work_Phone_No_Locale__c = workPhone_NL.replaceAll('');
        
        //append locale to no locale fields
        nlead.Phone = nlead.LeadPhone_Locale__c + nlead.Phone_No_Locale__c;     
        nlead.MobilePhone = nlead.LeadMobile_Locale__c + nlead.Mobile_No_Locale__c;
        nlead.Work_Phone__c = nlead.WorkPhone_Locale__c + nlead.Work_Phone_No_Locale__c;    
        
        //remove strings
        Matcher matcher = Pattern.compile('[^0-9]').matcher(nlead.Phone); 
        nlead.Phone = matcher.replaceAll('');        
        Matcher matcher1 = Pattern.compile('[^0-9]').matcher(nlead.MobilePhone);
        nlead.MobilePhone = matcher1.replaceAll('');        
        Matcher matcher2 = Pattern.compile('[^0-9]').matcher(nlead.Work_Phone__c);
        nlead.Work_Phone__c = matcher2.replaceAll(''); 
    }     
}
update leadList;
