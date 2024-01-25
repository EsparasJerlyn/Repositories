/**
 * @description Service Class for Marketing Related Logic
 * 
 * @see ApplicationService,MarketingInteractionTriggerHelper
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                     |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------|
 *    | roy.nino.s.regal               | Nov 28,2023           | DEPP-6979	            | Created File                       |\
 */
public with sharing class MarketingService { //NOPMD

    public static final Map<String,Map<String,String>> PERSONA_TYPE_TO_MARKETING_FIELDS = new Map<String,Map<String,String>>{
        'Work' => new Map<String,String>{
            'Email' => 'Work_Email__c',
            'HasOptedOutOfEmail' => 'Work_Email_Opt_Out__c',
            'Email_Opt_Out_DateTime__c' => 'Work_Email_Opt_Out_DateTime__c',
            'Email_Opt_In_DateTime__c' => 'Work_Email_Opt_In_DateTime__c'
        },
        'QUT Learner' => new Map<String,String>{
            'Email' => 'QUT_Learner_Email__c',
            'HasOptedOutOfEmail' => 'Learner_Email_Opt_Out__c',
            'Email_Opt_Out_DateTime__c' => 'Learner_Email_Opt_Out_DateTime__c',
            'Email_Opt_In_DateTime__c' => 'Learner_Email_Opt_In_DateTime__c'
        },
        'QUT Staff' => new Map<String,String>{
            'Email' => 'QUT_Staff_Email__c',
            'HasOptedOutOfEmail' => 'Staff_Email_Opt_Out__c',
            'Email_Opt_Out_DateTime__c' => 'Staff_Email_Opt_Out_DateTime__c',
            'Email_Opt_In_DateTime__c' => 'Staff_Email_Opt_In_DateTime__c'
        }
    };

    public static final Map<String,String> PERSONA_TYPES_TO_EMAIL_MAP = new Map<String,String>{
        'Work' => 'Work_Email__c',
        'QUT Learner' => 'QUT_Learner_Email__c',
        'QUT Staff' => 'QUT_Staff_Email__c'
    };

    public static final Set<String> PERSONAL_MARKETING_FIELDS = new Set<String>{
        'Email',
        'HasOptedOutOfEmail',
        'Email_Opt_Out_DateTime__c',
        'Email_Opt_In_DateTime__c'
    };

    private static final Set<String> MARKETING_BOOLEAN_FIELDS = new Set<String>{
        'HasOptedOutOfEmail',
        'Learner_Email_Opt_Out__c',
        'Staff_Email_Opt_Out__c',
        'Work_Email_Opt_Out__c',
        'Work_SMS_Opt_Out__c',
        'hed__SMS_Opt_Out__c',
        'DoNotCall'
    };

    private static final Map<Boolean, Set<String>> MARKETING_OPT_IN_OUT_EMAIL_FIELDS_MAP = new Map<Boolean, Set<String>>{
        true => new Set<String>{
            'Email_Opt_In_DateTime__c',
            'Learner_Email_Opt_In_DateTime__c',
            'Staff_Email_Opt_In_DateTime__c',
            'Work_Email_Opt_In_DateTime__c',
            'Work_SMS_Opt_In_DateTime__c',
            'SMS_Opt_In_DateTime__c'
        },
        false => new Set<String>{
            'Email_Opt_Out_DateTime__c',
            'Learner_Email_Opt_Out_DateTime__c',
            'Staff_Email_Opt_Out_DateTime__c',
            'Work_Email_Opt_Out_DateTime__c',
            'Work_SMS_Opt_Out_DateTime__c',
            'SMS_Opt_Out_DateTime__c'
        }
    };

    public static void optInOrOutMarketing(Contact applicantToUpdate, Boolean isOptIn){
        for(String booleanField: MARKETING_BOOLEAN_FIELDS){
            //By Opting In, set marketing boolean fields to false
            applicantToUpdate.put(booleanField,!isOptIn);
        }

        for(String emailField:MARKETING_OPT_IN_OUT_EMAIL_FIELDS_MAP.get(isOptIn)){
            applicantToUpdate.put(emailField,System.Now());
        }

        if(isOptIn){
            applicantToUpdate.Sync_to_MC__c = true;
            applicantToUpdate.Do_Not_Sync_To_MC_Override__c = false;
            applicantToUpdate.Dont_Market_Reason__c = null;
        }else{
            applicantToUpdate.Sync_to_MC__c = false;
            applicantToUpdate.Do_Not_Sync_To_MC_Override__c = false;
            applicantToUpdate.Dont_Market_Reason__c = 'QTAC Application QUT preferences withdrawn';
        }
    }
}