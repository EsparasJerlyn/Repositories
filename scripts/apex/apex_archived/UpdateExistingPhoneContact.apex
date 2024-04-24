List<Contact> conList = new List<Contact>([SELECT Id,Phone,MobilePhone,hed__WorkPhone__c,ContactPhone_Locale__c,ContactMobile_Locale__c,ContactWorkPhone_Locale__c
                                    FROM Contact 
                                    WHERE Phone_No_Locale__c = null AND 
                                    Mobile_No_Locale__c = null AND 
                                    Work_Phone_No_Locale__c = null]);

if(!conlist.isEmpty()){       
    for(Contact con: conList){
        //copy fields
        con.Phone_No_Locale__c = con.Phone;
        con.Mobile_No_Locale__c = con.MobilePhone;
        con.Work_Phone_No_Locale__c = con.hed__WorkPhone__c;
        
        //remove leading zeros from no locale fields
        Matcher phone_NL = Pattern.compile('^0+').matcher(con.Phone_No_Locale__c); 
        con.Phone_No_Locale__c = phone_NL.replaceAll('');
        Matcher mobile_NL = Pattern.compile('^0+').matcher(con.Mobile_No_Locale__c); 
        con.Mobile_No_Locale__c = mobile_NL.replaceAll('');
        Matcher workPhone_NL = Pattern.compile('^0+').matcher(con.Work_Phone_No_Locale__c); 
        con.Work_Phone_No_Locale__c = workPhone_NL.replaceAll('');
        
        //append locale to no locale fields
        con.Phone = con.ContactPhone_Locale__c + con.Phone_No_Locale__c;     
        con.MobilePhone = con.ContactMobile_Locale__c + con.Mobile_No_Locale__c;
        con.hed__WorkPhone__c = con.ContactWorkPhone_Locale__c + con.Work_Phone_No_Locale__c;    
        
        //remove strings
        Matcher matcher = Pattern.compile('[^0-9]').matcher(con.Phone); 
        con.Phone = matcher.replaceAll('');        
        Matcher matcher1 = Pattern.compile('[^0-9]').matcher(con.MobilePhone);
        con.MobilePhone = matcher1.replaceAll('');        
        Matcher matcher2 = Pattern.compile('[^0-9]').matcher(con.hed__WorkPhone__c);
        con.hed__WorkPhone__c = matcher2.replaceAll(''); 
    }     
}
update conList;
