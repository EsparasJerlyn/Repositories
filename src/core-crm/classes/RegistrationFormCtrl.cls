/**
 * @description Creates User when learner tries to Register in OPE Store
 * @see ../lwc/registrationForm
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                    |
      |---------------------------|-----------------------|----------------------|-----------------------------------|
      | eugene.andrew.abuan       | January 03, 2022      | DEPP-773             | Created file                      |
      | eugene.andrew.abuan       | March 28, 2022        | DEPP-1293            | Added Dietary Req                 |
      | angelika.j.s.galang       | May 26, 2022          | DEPP-1455            | Added contact duplicates handler  |
      | john.bo.a.pineda          | June 1, 2022          | DEPP-1661            | Added send SMS OTP method         |
      | keno.domienri.dico        | June 15, 2022         | DEPP-2758            | Added Accessibility Req field     |
      | john.bo.a.pineda          | June 20, 2022         | DEPP-3191            | Added Logic for Login User        |
      | john.bo.a.pineda          | July 07, 2022         | DEPP-3444            | Modified query to Mobile Country  |
      |                           |                       |                      | Code to sort by Display Name      |
      | julie.jane.alegre         | August 15, 2022       | DEPP-3568            | Added updateContact Method        |
      | julie.jane.alegre         | August 26, 2022       | DEPP-3793            | Remove mobilePhone when           |
      |                           |                       |                      | creating/updating contact         |
      | eugene.andrew.abuan       | September 11, 2022    | DEPP-4225            | Added corporate login (cce)       |
      | eugene.andrew.abuan       | September 16, 2022    | DEPP-3506            | Update OPE Catalouge to           |
      |                           |                       |                      | Administrative account            |
      | marygrace.li              | September 24, 2022    | DEPP-4411            | Updated isEmailExist method       |
      | arsenio.jr.dayrit         | December 16, 2022     | DEPP-4907            | Update UpdateContact method       |
      | eugene.andrew.abuan       | February 22, 2023     | DEPP-5232            | Updates in isEmailExist method    |
      | julie.jane.alegre         | September 22, 2023    | DEPP-4762            | Add Position & Company Name fields|

 */
public without sharing class RegistrationFormCtrl {
  private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;
  private static final Id RT_CONTACT_PERSON_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get(RT_CONTACT_PERSON)
    .getRecordTypeId();
  private static final Id ADMINISTRATIVE_ACC_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
  .get('Administrative')
  .getRecordTypeId();

  /**
   * @description Method to check if Email exists
   * @param email - Email of the User
   * @return userList - returns User Details of existing user
   */
  @AuraEnabled(cacheable=false)
  public static List<User> isEmailExist(String email) {
    try {
      List<User> userList = new List<User>();
      if(Schema.sObjectType.User.isAccessible()){
        userList = [
          SELECT 
            Id, Name, Contact.MobilePhone, Username, Profile.Name, AccountId, FirstName, LastName
          FROM User
          WHERE (Contact.Registered_Email__c =: email OR Contact.Work_Email__c =: email)
          AND IsActive = true
          LIMIT 1
        ];
      }

      List<BuyerGroup> opeBuyerGroup = [
        SELECT Id
        FROM BuyerGroup
        WHERE Name = 'OPE BuyerGroup'
        LIMIT 1
      ];

      if(!userList.isEmpty() && !opeBuyerGroup.IsEmpty()){
        if(userList[0].Profile.Name == 'Corporate Partner'){
          
          AdminAccountDetails adminAcc = new AdminAccountDetails();
          adminAcc.buyerGroupId = opeBuyerGroup[0].Id;
          adminAcc.accountId = userList[0].AccountId;
          adminAcc.lastName = userList[0].LastName;
          adminAcc.firstName = userList[0].FirstName;
          //Assign account to the BuyerGroup Member
          createAdministrativeAccount(adminAcc);
        }
      }
      return userList;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

   /**
   * @description Method to Update Contact
   * @param contactId - Contact Id
   * @param email - Contact Email
   * @param mobileNoLocale - Contact mobileNoLocale
   * @param mobileConLocale - Contact mobileConLocale
   * @param dietaryReq - Contact dietaryRequirements
   * @param accessibilityReq - Contact accessibilityRequirements
   * 
   */
  @AuraEnabled
  public static void updateContact(
    String registrationData,
    Boolean isUpdatePersonalEmail
  ) {

      RegistrationDataWrapper parsedRegistrationData = (RegistrationDataWrapper) JSON.deserialize(
            registrationData, 
            RegistrationDataWrapper.class
      );

      List<Contact> currentContacts = new List<Contact>(
        [
          SELECT
            Id,
            MobilePhone,
            Mobile_No_Locale__c,
            ContactMobile_Locale__c,
            Dietary_Requirement__c,
            Accessibility_Requirement__c,
            Email,
            Work_Email__c,
            QUT_Learner_Email__c,
            QUT_Staff_Email__c,
            HasOptedOutOfEmail,
            Email_Opt_In_DateTime__c,
            Consent_Source__c,
            Consent_Source_Category__c,
            Position__c,
            Company_Name__c
          FROM Contact
          WHERE
            RecordTypeId = :RT_CONTACT_PERSON_ID
            AND Parent_Person_Contact__c = NULL
            AND Id = :parsedRegistrationData.contactRecord.Id
            AND (Email = :parsedRegistrationData.contactRecord.Registered_Email__c
            OR Work_Email__c = :parsedRegistrationData.contactRecord.Registered_Email__c
            OR QUT_Learner_Email__c = :parsedRegistrationData.contactRecord.Registered_Email__c
            OR QUT_Staff_Email__c = :parsedRegistrationData.contactRecord.Registered_Email__c)
        ]
      );
      //Update existing contact if there's only 1 exact match
      if (currentContacts.size() == 1) {
        Contact existingContact = currentContacts[0];
        existingContact.ContactMobile_Locale__c = parsedRegistrationData.contactRecord.ContactMobile_Locale__c;
        existingContact.Mobile_No_Locale__c = parsedRegistrationData.contactRecord.Mobile_No_Locale__c;
        existingContact.Registered_Email__c = parsedRegistrationData.contactRecord.Email;
        if( parsedRegistrationData.contactRecord.Email != existingContact.Email 
            && parsedRegistrationData.contactRecord.Email != existingContact.QUT_Learner_Email__c 
            && parsedRegistrationData.contactRecord.Email != existingContact.QUT_Staff_Email__c 
            && parsedRegistrationData.contactRecord.Email != existingContact.Work_Email__c){
            if(isUpdatePersonalEmail == true){
              existingContact.Email = parsedRegistrationData.contactRecord.Email;
            }else{
              existingContact.Work_Email__c = parsedRegistrationData.contactRecord.Email;
            }
        }
        existingContact.Dietary_Requirement__c = parsedRegistrationData.contactRecord.Dietary_Requirement__c;
        existingContact.Accessibility_Requirement__c = parsedRegistrationData.contactRecord.Dietary_Requirement__c;
        existingContact.Position__c = parsedRegistrationData.contactRecord.Position__c;
        existingContact.Company_Name__c = parsedRegistrationData.contactRecord.Company_Name__c;

        Study_Store_URL_Settings__c storeLinkSettings = Study_Store_URL_Settings__c.getOrgDefaults();

        if(parsedRegistrationData.isOptIn == true){
          existingContact.HasOptedOutOfEmail = false;
          existingContact.Consent_Source__c = storeLinkSettings.Study_Store_Link__c;
          existingContact.Consent_Source_Category__c = 'Study Application';
        }

        update existingContact;
      }
   
  }

  /**
   * @description Method to check if Email exists
   * @param email - Email of the User
   * @return userList - returns User Details of existing user
   */
  @AuraEnabled(cacheable=false)
  public static List<User> isUserExist(Id contactId) {
    try {
      List<User> userList = new List<User>();
      userList = [
        SELECT Id, Name, MobilePhone, Username, ContactId
        FROM User
        WHERE ContactId = :contactId AND Profile.Name = 'QUT Experience'
        LIMIT 1
      ];
      return userList;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Method to call Send OTP
   * @param mobile - mobile to recieve OTP
   * @return retOTP - returns OTP sent
   */
  @AuraEnabled(cacheable=false)
  public static String sendRegistrationSMSOTP(String mobile) {
    return MCTransactionalMessagingOTP.sendSMSOTP(mobile);
  }

  /**
   * @description Method to call Send OTP
   * @param email - email to recieve OTP
   * @return retOTP - returns OTP sent
   */
  @AuraEnabled(cacheable=false)
  public static String sendRegistrationEmailOTP(String email) {
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    OrgWideEmailAddress owea = new OrgWideEmailAddress();
    EmailTemplate otpEmailTemplate = new EmailTemplate();
    String retOTP;

    // Generate OTP
    String randNum = string.valueof(Math.abs(Crypto.getRandomLong()));
    String otpValue = randNum.substring(0, 6);

    // Get Org Wide Email Address
    owea = [
      SELECT Id, Address, DisplayName
      FROM OrgWideEmailAddress
      WHERE DisplayName = 'QUTeX'
    ];

    // Get Email Template
    otpEmailTemplate = [
      SELECT Id, Name, Subject, HtmlValue, Body
      FROM EmailTemplate
      WHERE Name = 'Send OTP Email'
      LIMIT 1
    ];

    // Process Email
    Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
    objEmail.setToAddresses(new List<String>{ email });
    if (owea != null) {
      objEmail.setOrgWideEmailAddressId(owea.Id);
    }

    // Set Email Subject
    objEmail.setSubject(otpEmailTemplate.Subject);

    // Set Email Body
    String body = otpEmailTemplate.HTMLValue.replace('{otpValue}', otpValue);
    body = EmailHelper.addHeaderAndFooter(body);
    objEmail.setHtmlBody(body);
    emailList.add(objEmail);

    if (emailList.size() > 0) {
      Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
      if (results[0].success) {
        retOTP = otpValue;
      }
    }

    return retOTP;
  }

  /**
   * @description Method to get the community URL
   * @return communityUrl - returns the site link
   */
  @AuraEnabled(cacheable=false)
  public static CommunityWrapper getCommunityUrl() {
    try {
      CommunityWrapper commData = new CommunityWrapper();

      Site site = [SELECT Id FROM Site WHERE UrlPathPrefix = 'study' LIMIT 1];
      String communityUrl = [
        SELECT SecureURL
        FROM SiteDetail
        WHERE DurableId = :site.Id
      ]
      .SecureUrl;
      List<Domain> domainUrl = [SELECT Domain FROM Domain];

      Site siteCCE = [SELECT Id FROM Site WHERE UrlPathPrefix = 'cce' LIMIT 1];
      String communityUrlCCE = [
        SELECT SecureURL
        FROM SiteDetail
        WHERE DurableId = :siteCCE.Id
      ]
      .SecureUrl;

      commData.comSite = communityUrl;
      commData.comSiteCCE = communityUrlCCE;
      commData.comURL = domainUrl;
      return commData;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Method to Register User
   * @param firstName - First Name of the User
   * @param lastName - Last Name of the User
   * @param email - Email of the User
   * @param position - Position of the User
   * @param companyName - Company Name of the User
   * @param mobile - Mobile of the User
   * @param date - date of the Birthdate of the User
   * @param month - month of the Birthdate of the User
   * @param year - year of the Birthdate of the User
   * @param dietraryReq - Dietary Requirement of the User
   * @param startURL - Start URL
   * @return page - Returns api name of the confirmation page
   */
  @AuraEnabled
  public static string registerUser(
    String registrationData,
    String birthDateData
  ) {
      String confirmPageName = 'CheckPasswordResetEmail';

      

      RegistrationDataWrapper parsedRegistrationData = (RegistrationDataWrapper) JSON.deserialize(
            registrationData, 
            RegistrationDataWrapper.class
      );

      BirthDateWrapper parsedBirthDateData = (BirthDateWrapper) JSON.deserialize(
        birthDateData, 
        BirthDateWrapper.class
      );

      //Format birthday
      parsedRegistrationData.contactRecord.Birthdate = Date.newInstance(parsedBirthDateData.year, parsedBirthDateData.month, parsedBirthDateData.day);

      // Query OPE Buyer Group
      List <BuyerGroup> opeBuyerGroup = [
        SELECT Id
        FROM BuyerGroup
        WHERE Name = 'OPE BuyerGroup'
        LIMIT 1
      ];

      //Update existing contact if there's only 1 exact match
      if (parsedRegistrationData.contactRecord.Id != null) {
        Id accId;
        // Query if there is an exsisting administrative account linked to the contact
        List<Contact> contactAdministrativeAcc = [
          SELECT Id, AccountId
          FROM Contact 
          WHERE Account.RecordTypeId =: ADMINISTRATIVE_ACC_RECTYPEID
          AND Id =: parsedRegistrationData.contactRecord.Id
          LIMIT 1
        ];

        AdminAccountDetails adminAcc = new AdminAccountDetails();
        adminAcc.buyerGroupId = opeBuyerGroup[0].Id;
        adminAcc.lastName = parsedRegistrationData.contactRecord.LastName;
        adminAcc.firstName = parsedRegistrationData.contactRecord.FirstName;
        if(contactAdministrativeAcc.isEmpty()){
          adminAcc.accountId = null;
        }else{
          adminAcc.accountId = contactAdministrativeAcc[0].AccountId;
        }
        accId = createAdministrativeAccount(adminAcc);
        
        Contact existingContact = new Contact();
        existingContact.Id = parsedRegistrationData.contactRecord.Id;
        existingContact.AccountId = accId;
        existingContact.ContactMobile_Locale__c = parsedRegistrationData.contactRecord.ContactMobile_Locale__c;
        existingContact.Mobile_No_Locale__c = parsedRegistrationData.contactRecord.Mobile_No_Locale__c;
        existingContact.Registered_Email__c = parsedRegistrationData.contactRecord.Registered_Email__c;
        existingContact.Birthdate = parsedRegistrationData.contactRecord.Birthdate;
        existingContact.Dietary_Requirement__c = parsedRegistrationData.contactRecord.Dietary_Requirement__c;
        existingContact.Accessibility_Requirement__c = parsedRegistrationData.contactRecord.Accessibility_Requirement__c;
        existingContact.Position__c = parsedRegistrationData.contactRecord.Position__c;
        existingContact.Company_Name__c = parsedRegistrationData.contactRecord.Company_Name__c;
        update existingContact;

        //Create user if none associated yet
        List<User> existingUser = [
          SELECT Id, ContactId
          FROM User
          WHERE ContactId =: existingContact.Id
        ];     

        if (existingUser.isEmpty())
        {
          confirmPageName = createNewUser(
            parsedRegistrationData
          );
        } else {
          confirmPageName = 'CloseModal';
        }
      } else {
        //Proceed in creation as usual if no exact match found
        
        //parsedRegistrationData.contactRecord.AccountId = administrativAccount;
        Id newContactId = createNewContact(
          parsedRegistrationData
        );

        List<Contact> contactAdministrativeAcc = [
          SELECT Id, AccountId
          FROM Contact 
          WHERE Account.RecordTypeId =: ADMINISTRATIVE_ACC_RECTYPEID
          AND Id =: newContactId
          LIMIT 1
        ];

        AdminAccountDetails adminAcc = new AdminAccountDetails();
        adminAcc.buyerGroupId = opeBuyerGroup[0].Id;
        adminAcc.lastName = parsedRegistrationData.contactRecord.LastName;
        adminAcc.firstName = parsedRegistrationData.contactRecord.FirstName;
        if(contactAdministrativeAcc.isEmpty()){
          adminAcc.accountId = null;
        }else{
          adminAcc.accountId = contactAdministrativeAcc[0].AccountId;
        }
        createAdministrativeAccount(adminAcc);

        parsedRegistrationData.contactRecord.Id = newContactId;
        confirmPageName = createNewUser(
          parsedRegistrationData
        );
      }

      return confirmPageName;
  }
  
  /**
   * @description Method to insert an Administrative Account and link it to the OPE Buyer Group
   * @param buyerGroupId - Id of OPE Buyer Group
   * @param accountId - Id of the Account
   * @param lastName - last name of the contact
   * @param firstName - first name of the contact
   * @return accountId - Id of the Administrative Account that was created
   */
  public static Id createAdministrativeAccount(AdminAccountDetails adminAcc){
    Id accId;
    String accName;
    if(adminAcc.accountId == null ){
      //Create Administrative Account Record
      Account adminstrativeAccount = new Account();
      adminstrativeAccount.Name = adminAcc.lastName + ' (' + adminAcc.firstName + ')' + ' Administrative Account';
      adminstrativeAccount.RecordTypeId = ADMINISTRATIVE_ACC_RECTYPEID;
      insert adminstrativeAccount;

      accId = adminstrativeAccount.Id;
      accName = adminstrativeAccount.Name;
    }else{
      Account accAdministrative = [SELECT Name 
                                   FROM Account 
                                   WHERE Id =: adminAcc.accountId 
                                   AND RecordTypeId =: ADMINISTRATIVE_ACC_RECTYPEID
                                   LIMIT 1];
      accName = accAdministrative.Name;
      accId = adminAcc.accountId;
    }

    // Query if Buyer Account is Existing
    List<BuyerAccount> buyerAccount = [SELECT Id FROM BuyerAccount WHERE BuyerId =:accId];

    //Create Buyer Account Record
    if(buyerAccount.isEmpty()){
      BuyerAccount administrativeAccountBuyer = new BuyerAccount();
      administrativeAccountBuyer.BuyerId = accId;
      administrativeAccountBuyer.Name = accName;
      administrativeAccountBuyer.IsActive = TRUE;
      administrativeAccountBuyer.BuyerStatus = 'Active';
      insert administrativeAccountBuyer;
    }


    List<BuyerGroupMember> buyerGroupMember = [
      SELECT Id 
      FROM buyerGroupMember 
      WHERE BuyerId =: accId
      AND BuyerGroupId =: adminAcc.buyerGroupId
      ];

    if(buyerGroupMember.isEmpty()){
      // Create Buyer Group Member Record 
      BuyerGroupMember bgMember = new BuyerGroupMember();
      bgMember.BuyerId = accId;
      bgMember.BuyerGroupId = adminAcc.buyerGroupId;
      insert bgMember;
    }

    return accId;
  }

  /**
   * @description Method to insert and return the id of Contact
   * @param firstName - First Name of the User
   * @param lastName - Last Name of the User
   * @param email - Email of the User
   * @param position - Position of the User
   * @param companyName - Company Name of the User
   * @param birthdate - date of the Birthdate of the User
   * @param dietraryReq - Dietary Requirement of the User
   * @param accountId - account of the User
   * @return Returns api name of the confirmation page
   */
  private static Id createNewContact(
    RegistrationDataWrapper registrationData
  ) {


    //Set fields from the form to the Contact Object
    Contact c = new Contact();
    c.AccountId = registrationData.accountId;
    c.FirstName = registrationData.contactRecord.FirstName;
    c.lastName = registrationData.contactRecord.LastName;
    c.Email = registrationData.contactRecord.Registered_Email__c;
    c.Position__c = registrationData.contactRecord.Position__c;
    c.Company_Name__c = registrationData.contactRecord.Company_Name__c;
    c.Registered_Email__c = registrationData.contactRecord.Registered_Email__c;
    c.Mobile_No_Locale__c = registrationData.contactRecord.Mobile_No_Locale__c;
    c.ContactMobile_Locale__c = registrationData.contactRecord.ContactMobile_Locale__c;
    c.Birthdate = registrationData.contactRecord.Birthdate;
    c.Dietary_Requirement__c = registrationData.contactRecord.Dietary_Requirement__c;
    c.Accessibility_Requirement__c = registrationData.contactRecord.Accessibility_Requirement__c;
    c.RecordTypeId = RT_CONTACT_PERSON_ID;

    Study_Store_URL_Settings__c storeLinkSettings = Study_Store_URL_Settings__c.getOrgDefaults();

    if(registrationData.isOptIn == true){
      c.HasOptedOutOfEmail = false;
      c.Email_Opt_In_DateTime__c = System.now();
      c.Consent_Source__c = storeLinkSettings.Study_Store_Link__c;
      c.Consent_Source_Category__c = 'Study Application';
    }

    insert (c);

    return c.Id;
  }

  /**
   * @description Method to insert a User
   * @param firstName - First Name of the User
   * @param lastName - Last Name of the User
   * @param email - Email of the User
   * @param position - Position of the User
   * @param companyName - Company Name of the User
   * @param mobile - Mobile of the User
   * @param birthdate - date of the Birthdate of the User
   * @param contactId - Contact related to the User
   */
  private static String createNewUser(
    RegistrationDataWrapper registrationData
  ) {
    //Query Ecommerece Learner Profile
    String invalidChar = '[^0-9]';
    datetime myDate = datetime.now();
    String retURL;
    String userName = registrationData.contactRecord.Registered_Email__c + '.qut';
    Profile p = [SELECT Id FROM Profile WHERE Name = 'QUT Experience' WITH SYSTEM_MODE];

    //Create User
    User u = new User();
    u.FirstName = registrationData.contactRecord.FirstName;
    u.LastName = registrationData.contactRecord.LastName;
    u.Email = registrationData.contactRecord.Registered_Email__c;
    u.MobilePhone = registrationData.contactRecord.MobilePhone;
    u.Birthdate__c = registrationData.contactRecord.Birthdate;
    u.Username = username;
    String alias = u.LastName + u.FirstName;
    if (alias.length() > 8) {
      alias = alias.substring(0, 8);
    }
    u.alias = alias;
    u.CommunityNickname =
      alias +
      String.valueOf(myDate).replaceAll(invalidChar, '') +
      String.valueOf(u.Birthdate__c).replaceAll(invalidChar, '');
    u.LanguageLocaleKey = 'en_US';
    u.localesidkey = UserInfo.getLocale();
    u.emailEncodingKey = 'UTF-8';
    u.timeZoneSidKey = 'Australia/Brisbane';
    u.ContactId = registrationData.contactRecord.Id;
    u.profileId = p.Id;
    insert (u);

    String key = EncodingUtil.convertToHex(crypto.generateAesKey(128));
    String pwd = key.substring(0, 10) + 'AbC123!';

    system.setPassword(u.id, pwd);

    List<Id> userInserted = new List<Id>();
    userInserted.add(u.id);
    assignOPEPermset(userInserted);

    ApexPages.PageReference pageRef = Site.login(userName, pwd, registrationData.startURL);
    if (pageRef != null) {
      retURL = pageRef.getUrl();
    }

    return retURL;
  }

  /**
   * @description Method to login existing User
   * @param userId - Existing User Id
   * @param userName - Existing User Username
   * @param startURL - Login Start URL
   * @return retURL - Login Return URL
   */
  @AuraEnabled
  public static String loginExistingUser(
    String userId,
    String userName,
    String startURL
  ) {
    String retURL;

    String key = EncodingUtil.convertToHex(crypto.generateAesKey(128));
    String pwd = key.substring(0, 10) + 'AbC123!';

    system.setPassword(userId, pwd);

    ApexPages.PageReference pageRef = Site.login(userName, pwd, startURL);
    if (pageRef != null) {
      retURL = pageRef.getUrl();
    }

    return retURL;
  }

  /**
   * Get user mobile locale
   */
  @AuraEnabled(cacheable=false)
  public static String getUserMobileLocale(Id userId){
    Contact userMobileLoc = [
      SELECT Id, ContactMobile_Locale__c
      FROM Contact
      WHERE Id = :userId
      LIMIT 1
    ];
    String mLocale = userMobileLoc.ContactMobile_Locale__c;
    return mLocale;
  }

  /**
   * @description Method to get All Mobile Locale Options
   * @return mobileLocaleWrapperList - List of Mobile Locale Options
   */
  @AuraEnabled(cacheable=false)
  public static List<MobileLocaleWrapper> getMobileLocaleOptions() {
    // Init
    List<MobileLocaleWrapper> mobileLocaleWrapperList = new List<MobileLocaleWrapper>();
    try {
      // Get All Mobile Locale Options from Country Code Custom Metadata
      List<Mobile_Country_Code__mdt> mobileCountryCodeMDTList = [
        SELECT Id, Display_Name__c, Mobile_Coutnry_Code__c, Loqate_Locale__c
        FROM Mobile_Country_Code__mdt
        ORDER BY Display_Name__c
      ];
      if (mobileCountryCodeMDTList.size() > 0) {
        for (
          Mobile_Country_Code__mdt mobileCountryCodeMDT : mobileCountryCodeMDTList
        ) {
          MobileLocaleWrapper mobileLocaleWrapper = new MobileLocaleWrapper();
          mobileLocaleWrapper.label = mobileCountryCodeMDT.Display_Name__c;
          mobileLocaleWrapper.value = mobileCountryCodeMDT.Display_Name__c;
          mobileLocaleWrapper.countryCode = mobileCountryCodeMDT.Mobile_Coutnry_Code__c;
          mobileLocaleWrapper.conMobileLocale = mobileCountryCodeMDT.Loqate_Locale__c;
          mobileLocaleWrapperList.add(mobileLocaleWrapper);
        }
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }

    return mobileLocaleWrapperList;
  }

  /**
   * @description Method to check if Email exists and Mobile Number for Corporate Login
   * @param email - Email of the User
   * @param mobile - mobile of the User
   * @return userList - returns User Details of existing user
   */
  @AuraEnabled(cacheable=false)
  public static List<User> loginCorporateUser(String email, String mobile) {
    List<Contact> corporateContact = new List<Contact>();
    corporateContact = [
      SELECT Id, Work_Email__c, MobilePhone
      FROM Contact
      WHERE Work_Email__c =: email
      AND MobilePhone =: mobile
      LIMIT 1
    ];

    List<User> userList = new List<User>();
    if(!corporateContact.isEmpty()){
      userList = [
        SELECT Id, Name, Username
        FROM User
        WHERE ContactId =: corporateContact[0].Id
        LIMIT 1
      ];
    }else{
      userList = null;
    }
    return userList;
  }

  /**
   * @description Method to Assign the Permission set to the User in future
   * @param recordIds - Id of the User
   */
  @future
  public static void assignOPEPermset(List<ID> recordIds) {
    User userInserted = [SELECT Id FROM User WHERE Id IN :recordIds];
    PermissionSet ps = [
      SELECT Name, Id
      FROM PermissionSet
      WHERE Name = 'OPE_Catalogue'
    ];
    PermissionSetAssignment psa = new PermissionSetAssignment(
      PermissionSetId = ps.Id,
      AssigneeId = userInserted.Id
    );
    insert (psa);
  }

  public class CommunityWrapper {
    @AuraEnabled
    public List<Domain> comURL;
    @AuraEnabled
    public String comSite;
    @AuraEnabled
    public String comSiteCCE;
  }

  public class MobileLocaleWrapper {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    @AuraEnabled
    public String conMobileLocale;
    @AuraEnabled
    public String countryCode;
  }

  public class RegistrationDataWrapper{
    @AuraEnabled
    public Contact contactRecord;
    @AuraEnabled
    public Id accountId;
    @AuraEnabled
    public String startURL;
    @AuraEnabled
    public Boolean isOptIn;
  }

  public class BirthDateWrapper{
    @AuraEnabled
    public Integer day;
    @AuraEnabled
    public Integer month;
    @AuraEnabled
    public Integer year;
  }

  public class AdminAccountDetails {
    public Id buyerGroupId;
    public Id accountId;
    public String lastName;
    public String firstName;
  }
}