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
      userList = [
        SELECT 
          Id, Name, MobilePhone, Username, Profile.Name, AccountId, FirstName, LastName
        FROM User
        WHERE (Contact.Email =: email OR Contact.Work_Email__c =: email)
        AND IsActive = true
        LIMIT 1
      ];

      List<BuyerGroup> opeBuyerGroup = [
        SELECT Id
        FROM BuyerGroup
        WHERE Name = 'OPE BuyerGroup'
        LIMIT 1
      ];

      if(!userList.isEmpty() && !opeBuyerGroup.IsEmpty()){
        if(userList[0].Profile.Name == 'Partner Community User'){
          
          //Assign account to the BuyerGroup Member
          Id assignBuyerGroupMember = createAdministrativeAccount( opeBuyerGroup[0].Id, 
                                                                   userList[0].AccountId, 
                                                                   userList[0].LastName, 
                                                                   userList[0].FirstName);
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
    Id contactId,
    String email,
    String mobileNoLocale,
    String mobileConLocale,
    String dietaryReq,
    String accessibilityReq
  ) {

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
            QUT_Staff_Email__c
          FROM Contact
          WHERE
            RecordTypeId = :RT_CONTACT_PERSON_ID
            AND Parent_Person_Contact__c = NULL
            AND Id = :contactId
            AND (Email = :email
            OR Work_Email__c = :email
            OR QUT_Learner_Email__c = :email
            OR QUT_Staff_Email__c = :email)
        ]
      );

      //Update existing contact if there's only 1 exact match
      if (currentContacts.size() == 1) {
        Contact existingContact = currentContacts[0];
        existingContact.ContactMobile_Locale__c = mobileConLocale;
        existingContact.Mobile_No_Locale__c = mobileNoLocale;
        existingContact.Registered_Email__c = email;
        existingContact.Dietary_Requirement__c = dietaryReq;
        existingContact.Accessibility_Requirement__c = accessibilityReq;
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
        WHERE ContactId = :contactId AND Profile.Name = 'OPE Catalogue'
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
    String firstName,
    String lastName,
    String email,
    String mobile,
    Integer day,
    Integer month,
    Integer year,
    String dietaryReq,
    String accessReq,
    String startURL,
    String mobileNoLocale,
    String mobileConLocale,
    Id contactId
  ) {
    try {
      String confirmPageName = 'CheckPasswordResetEmail';

      //Format birthday
      Date birthdate = Date.newInstance(year, month, day);

      // Query OPE Buyer Group
      List <BuyerGroup> opeBuyerGroup = [
        SELECT Id
        FROM BuyerGroup
        WHERE Name = 'OPE BuyerGroup'
        LIMIT 1
      ];

      //Update existing contact if there's only 1 exact match
      if (contactId != null) {
        Id accId;
        // Query if there is an exsisting administrative account linked to the contact
        List<Contact> contactAdministrativeAcc = [
          SELECT Id, AccountId
          FROM Contact 
          WHERE Account.RecordTypeId =: ADMINISTRATIVE_ACC_RECTYPEID
          AND Id =: contactId
          LIMIT 1
        ];

        if(contactAdministrativeAcc.isEmpty()){
          accId = createAdministrativeAccount(opeBuyerGroup[0].Id, null, lastName, firstName);
        }else{
          accId = createAdministrativeAccount(opeBuyerGroup[0].Id, contactAdministrativeAcc[0].AccountId, lastName, firstName);
        }

        Contact existingContact = new Contact();
        existingContact.Id = contactId;
        existingContact.AccountId = accId;
        existingContact.ContactMobile_Locale__c = mobileConLocale;
        existingContact.Mobile_No_Locale__c = mobileNoLocale;
        existingContact.Registered_Email__c = email;
        existingContact.Birthdate = birthdate;
        existingContact.Dietary_Requirement__c = dietaryReq;
        existingContact.Accessibility_Requirement__c = accessReq;
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
            firstName,
            lastName,
            email,
            mobile,
            birthdate,
            existingContact.Id,
            accId,
            startURL
          );
        } else {
          confirmPageName = 'CloseModal';
        }
      } else {
        //Proceed in creation as usual if no exact match found
        Id administrativAccount = createAdministrativeAccount(opeBuyerGroup[0].Id, null,lastName,firstName);
        Id newContactId = createNewContact(
          firstName,
          lastName,
          email,
          birthdate,
          dietaryReq,
          accessReq,
          administrativAccount,
          mobileNoLocale,
          mobileConLocale
        );
        confirmPageName = createNewUser(
          firstName,
          lastName,
          email,
          mobile,
          birthdate,
          newContactId,
          administrativAccount,
          startURL
        );
      }

      return confirmPageName;
    } catch (Exception e) {
      return null;
    }
  }
  
  /**
   * @description Method to insert an Administrative Account and link it to the OPE Buyer Group
   * @param buyerGroupId - Id of OPE Buyer Group
   * @param accountId - Id of the Account
   * @param lastName - last name of the contact
   * @param firstName - first name of the contact
   * @return accountId - Id of the Administrative Account that was created
   */
  public static Id createAdministrativeAccount (Id buyerGroupId , Id accountId, String lastName, String firstName){
    Id accId;
    String accName;
    if(accountId == null ){
      //Create Administrative Account Record
      Account adminstrativeAccount = new Account();
      adminstrativeAccount.Name = lastName + ' (' + firstName + ')' + ' Administrative Account';
      adminstrativeAccount.RecordTypeId = ADMINISTRATIVE_ACC_RECTYPEID;
      insert adminstrativeAccount;

      accId = adminstrativeAccount.Id;
      accName = adminstrativeAccount.Name;
    }else{
      Account accAdministrative = [SELECT Name 
                                   FROM Account 
                                   WHERE Id =: accountId 
                                   AND RecordTypeId =: ADMINISTRATIVE_ACC_RECTYPEID
                                   LIMIT 1];
      accName = accAdministrative.Name;
      accId = accountId;
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
      AND BuyerGroupId =: buyerGroupId
      ];

    if(buyerGroupMember.isEmpty()){
      // Create Buyer Group Member Record 
      BuyerGroupMember bgMember = new BuyerGroupMember();
      bgMember.BuyerId = accId;
      bgMember.BuyerGroupId = buyerGroupId;
      insert bgMember;
    }

    return accId;
  }

  /**
   * @description Method to insert and return the id of Contact
   * @param firstName - First Name of the User
   * @param lastName - Last Name of the User
   * @param email - Email of the User
   * @param birthdate - date of the Birthdate of the User
   * @param dietraryReq - Dietary Requirement of the User
   * @param accountId - account of the User
   * @return Returns api name of the confirmation page
   */
  public static Id createNewContact(
    String firstName,
    String lastName,
    String email,
    Date birthdate,
    String dietaryReq,
    String accessReq,
    Id accountId,
    String mobileNoLocale,
    String mobileConLocale
  ) {
    //Set fields from the form to the Contact Object
    Contact c = new Contact();
    c.AccountId = accountId;
    c.FirstName = firstName;
    c.lastName = lastName;
    c.Email = email;
    c.Registered_Email__c = email;
    c.Mobile_No_Locale__c = mobileNoLocale;
    c.ContactMobile_Locale__c = mobileConLocale;
    c.Birthdate = birthdate;
    c.Dietary_Requirement__c = dietaryReq;
    c.Accessibility_Requirement__c = accessReq;
    c.RecordTypeId = RT_CONTACT_PERSON_ID;
    insert (c);

    return c.Id;
  }

  /**
   * @description Method to insert a User
   * @param firstName - First Name of the User
   * @param lastName - Last Name of the User
   * @param email - Email of the User
   * @param mobile - Mobile of the User
   * @param birthdate - date of the Birthdate of the User
   * @param contactId - Contact related to the User
   */
  public static String createNewUser(
    String firstName,
    String lastName,
    String email,
    String mobile,
    Date birthdate,
    Id contactId,
    Id accId,
    String startURL
  ) {
    //Query Ecommerece Learner Profile
    String userId;
    String invalidChar = '[^0-9]';
    datetime myDate = datetime.now();
    String retURL;
    String userName = email + '.ope';
    Profile p = [SELECT Id FROM Profile WHERE Name = 'OPE Catalogue'];

    //Create User
    User u = new User();
    u.FirstName = firstName;
    u.LastName = lastName;
    u.Email = email;
    u.MobilePhone = mobile;
    u.Birthdate__c = birthdate;
    u.Username = username;
    String alias = lastName + firstName;
    if (alias.length() > 8) {
      alias = alias.substring(0, 8);
    }
    u.alias = alias;
    u.CommunityNickname =
      alias +
      String.valueOf(myDate).replaceAll(invalidChar, '') +
      String.valueOf(birthdate).replaceAll(invalidChar, '');
    u.LanguageLocaleKey = 'en_US';
    u.localesidkey = UserInfo.getLocale();
    u.emailEncodingKey = 'UTF-8';
    u.timeZoneSidKey = 'Australia/Brisbane';
    u.ContactId = contactId;
    u.profileId = p.Id;
    insert (u);

    String key = EncodingUtil.convertToHex(crypto.generateAesKey(128));
    String pwd = key.substring(0, 10) + 'AbC123';

    system.setPassword(u.id, pwd);

    List<Id> userInserted = new List<Id>();
    userInserted.add(u.id);
    assignOPEPermset(userInserted);

    ApexPages.PageReference pageRef = Site.login(userName, pwd, startURL);
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
    String pwd = key.substring(0, 10);

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
}