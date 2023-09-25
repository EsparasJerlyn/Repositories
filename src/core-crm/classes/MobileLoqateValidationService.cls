/**
 * @description Service class for Mobile Loqate Validation of Lead
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | nicole.genon                   | September 21, 2023    | DEPP-6540              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class MobileLoqateValidationService {

    @InvocableMethod(label = 'Validate Mobile of Lead')
    public static void validateLeadMobile(List<ValidateRequestList> validateRequestList){

        List<Lead> leadListToUpdate = new List<Lead>();

        try{     
            ContactInformationValidationCtrl.validateFields(JSON.serialize(validateRequestList));
            leadListToUpdate.add(
                new Lead(
                    id = validateRequestList[0].leadId,
                    MobilePhone = buildMobile(validateRequestList[0].value,validateRequestList[0].localePicklistValue),
                    LeadMobile_Validation__c = 'Valid'
                )
            );
        }catch(Exception e){
            leadListToUpdate.add(
                new Lead(
                    id = validateRequestList[0].leadId,
                    LeadMobile_Validation__c = 'Not Valid'
                )
            );
            Logger.error('Exception caught in method validateLeadMobile in Apex class MobileLoqateValidationService').setExceptionDetails(e);
        }finally{
            if(!leadListToUpdate.isEmpty()){
                LeadsDAO.newInstance().updateRecords(leadListToUpdate, false, AccessLevel.USER_MODE);
            }

            if(Logger.getBufferSize() > 0){
                Logger.saveLog();
            }
        }
    }

    public static String buildMobile(String mobileNoLocale,String locale){
        Matcher mobile_NL = Pattern.compile('^0+').matcher((String)mobileNoLocale);
        String mobileNoLocaleTemp = mobile_NL.replaceAll('');
        String localNoLocale = (String)locale + mobileNoLocaleTemp;
        Matcher matcher1 = Pattern.compile('[^0-9]').matcher((String)localNoLocale);
        String localeStr = (String)locale;
        String tempLocale = localeStr.subString(localeStr.indexOf('(') + 1, localeStr.indexOf(')'));
        String localeTemp = tempLocale.replaceAll('\\D', '');
        String numberField = matcher1.replaceAll('');
        String mobileNoLocaleCheckerStr = mobileNoLocaleTemp.replaceAll('\\D', '').substring(0,2);
        if(mobileNoLocaleCheckerStr == localeTemp){
            numberField = numberField.removeStart(localeTemp);
        }
        return numberField;
    }

    public class ValidateRequestList{
        @InvocableVariable(label='Lead Id' required='true')
        public String leadId;
        @InvocableVariable(label='Api Name' required='true')
        public String apiName;
        @InvocableVariable(label='Loqate Request' required='true')
        public String loqateRequest;
        @InvocableVariable(label='Status Validation Field' required='true')
        public String statusValidationField;
        @InvocableVariable(label='Locale' required='true')
        public String locale;
        @InvocableVariable(label='value' required='true')
        public String value;
        @InvocableVariable(label='Locale Picklist Value' required='true')
        public String localePicklistValue;
    }
}