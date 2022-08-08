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
 */
public without sharing class RegistrationFormCtrl {
  private static final String RT_CONTACT_PERSON = System.Label.RT_Contact_Person;
  private static final Id RT_CONTACT_PERSON_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get(RT_CONTACT_PERSON)
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
        SELECT Id, Name, MobilePhone, Username
        FROM User
        WHERE Email = :email AND Profile.Name = 'OPE Catalogue'
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

      commData.comSite = communityUrl;
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
    String mobileConLocale
  ) {
    try {
      String confirmPageName = 'CheckPasswordResetEmail';

      //Format birthday
      Date birthdate = Date.newInstance(year, month, day);

      //Query OPE Account
      Account a = [SELECT Id, Name FROM Account WHERE Name = 'OPE Catalogue'];

      //Detect contact duplicates
      List<Contact> duplicateContacts = new List<Contact>(
        [
          SELECT
            Id,
            MobilePhone,
            Mobile_No_Locale__c,
            ContactMobile_Locale__c,
            Dietary_Requirement__c,
            Accessibility_Requirement__c,
            AccountId,
            Birthdate,
            Email,
            Work_Email__c,
            QUT_Learner_Email__c,
            QUT_Staff_Email__c,
            LastName
          FROM Contact
          WHERE
            RecordTypeId = :RT_CONTACT_PERSON_ID
            AND Parent_Person_Contact__c = NULL
            AND Birthdate = :birthdate
            AND (Email = :email
            OR Work_Email__c = :email
            OR QUT_Learner_Email__c = :email
            OR QUT_Staff_Email__c = :email)
            AND LastName = :lastName
        ]
      );

      //Update existing contact if there's only 1 exact match
      if (duplicateContacts.size() == 1) {
        Contact existingContact = duplicateContacts[0];
        existingContact.AccountId = a.Id;
        existingContact.ContactMobile_Locale__c = mobileConLocale;
        existingContact.Mobile_No_Locale__c = mobileNoLocale;
        existingContact.MobilePhone = mobile;
        existingContact.Registered_Email__c = email;
        existingContact.Dietary_Requirement__c = dietaryReq;
        existingContact.Accessibility_Requirement__c = accessReq;
        update existingContact;

        //Create user if none associated yet
        if (
          [SELECT ContactId FROM User WHERE ContactId = :existingContact.Id]
            .isEmpty()
        ) {
          confirmPageName = createNewUser(
            firstName,
            lastName,
            email,
            mobile,
            birthdate,
            existingContact.Id,
            a.Id,
            startURL
          );
        } else {
          confirmPageName = 'CloseModal';
        }
      } else if (duplicateContacts.size() > 1) {
        //Create potential duplicate records if there's more than 1 exact match
        List<Potential_Duplicate__c> potentialDuplicates = new List<Potential_Duplicate__c>();
        Id newContactId = createNewContact(
          firstName,
          lastName,
          email,
          mobile,
          birthdate,
          dietaryReq,
          accessReq,
          a.Id,
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
          a.Id,
          startURL
        );
        for (Contact existingCon : duplicateContacts) {
          potentialDuplicates.add(
            new Potential_Duplicate__c(
              Contact__c = existingCon.Id,
              Duplicate_Contact__c = newContactId
            )
          );
        }

        insert potentialDuplicates;
      } else {
        //Proceed in creation as usual if no exact match found
        Id newContactId = createNewContact(
          firstName,
          lastName,
          email,
          mobile,
          birthdate,
          dietaryReq,
          accessReq,
          a.Id,
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
          a.Id,
          startURL
        );
      }

      return confirmPageName;
    } catch (Exception e) {
      return null;
    }
  }

  /**
   * @description Method to insert and return the id of Contact
   * @param firstName - First Name of the User
   * @param lastName - Last Name of the User
   * @param email - Email of the User
   * @param mobile - Mobile of the User
   * @param birthdate - date of the Birthdate of the User
   * @param dietraryReq - Dietary Requirement of the User
   * @param accountId - account of the User
   * @return Returns api name of the confirmation page
   */
  public static Id createNewContact(
    String firstName,
    String lastName,
    String email,
    String mobile,
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
    c.MobilePhone = mobile;
    c.Mobile_No_Locale__c = mobileNoLocale;
    c.ContactMobile_Locale__c = mobileConLocale;
    c.Birthdate = birthdate;
    c.Dietary_Requirement__c = dietaryReq;
    c.Accessibility_Requirement__c = accessReq;
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
    system.debug(u.CommunityNickname);
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
