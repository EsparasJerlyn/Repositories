/**
 * @description Controller Class for SetupCertificateVFPage pages
 * @see ../pages/CertificateOfAchievementPDFView
 * @see ../pages/CertificateOfParticipationPDFView
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | April 28, 2022        | DEPP-1478            | Created file                 |  
      | marygrace.li@qut.edu.au   | June 14, 2022         | DEPP-3066            | Added get font size          |
      | eugene.andrew.abuan       | November 16, 2023     | DEPP-7010            | Added studentName as dynamic |         
      |                           |                       |                      |                              | 
 */
public with sharing class SetupCertificateVFPageCtrl {
    private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
    public string partnerLogo {get;set;}
    public string leftSignature {get;set;}
    public string rightSignature {get;set;}
    public string facilitatorName {get;set;}
    public string studentName {get;set;}
    public hed__Course_Enrollment__c student {get;set;}
    public string product {get;set;}
    public string dateToday {get;set;}
    public string startDate {get;set;}
    public string endDate {get;set;}
    public string fontSize {get;set;}
    public string facilitatorFontSize {get;set;}
    public string studentNameFontSize {get;set;}
    private static List<String> facilitatorTitle = System.Label.LWC_List_FacilitatorTitle.split(',');
    
    public SetupCertificateVFPageCtrl() {
        String courseConnectionId = ApexPages.currentPage()
        .getParameters()
        .get('courseConnectionId');
        List<hed__Course_Enrollment__c> courseCon = [
            SELECT Id, 
            First_Name__c,
            Last_Name__c,
            Marks__c,
            Marks_Description__c,
            RecordType.DeveloperName,
            hed__Course_Offering__r.hed__Start_Date__c,
            hed__Course_Offering__r.hed__End_Date__c,
            toLabel(hed__Course_Offering__r.Primary_Facilitator__r.hed__Contact__r.Salutation), 
            hed__Course_Offering__r.Primary_Facilitator__r.First_Name__c, 
			hed__Course_Offering__r.Primary_Facilitator__r.Last_Name__c,
            hed__Course_Offering__r.hed__Course__r.Left_Signature__c,
            hed__Course_Offering__r.hed__Course__r.Name_Left_Indented__c,
            hed__Course_Offering__r.hed__Course__r.Position_Left_Indented__c,
            hed__Course_Offering__r.hed__Course__r.Department_Left_Indented__c,
            hed__Course_Offering__r.hed__Course__r.Name_Right_Indented__c,
            hed__Course_Offering__r.hed__Course__r.Position_Right_Indented__c,
            hed__Course_Offering__r.hed__Course__r.Department_Right_Indented__c,
            hed__Course_Offering__r.hed__Course__r.Right_Signature__c,
            hed__Course_Offering__r.hed__Course__r.Partner_Logo__c,
            hed__Course_Offering__r.hed__Course__r.Name,
            hed__Course_Offering__r.hed__Course__c,
            Program_Offering__r.Start_Date__c,
            Program_Offering__r.End_Date__c,
            Program_Offering__r.hed_Program_Plan__r.Left_Signature__c,
            Program_Offering__r.hed_Program_Plan__r.Name_Left_Indented__c,
            Program_Offering__r.hed_Program_Plan__r.Position_Left_Indented__c,
            Program_Offering__r.hed_Program_Plan__r.Department_Left_Indented__c,
            Program_Offering__r.hed_Program_Plan__r.Name_Right_Indented__c,
            Program_Offering__r.hed_Program_Plan__r.Position_Right_Indented__c,
            Program_Offering__r.hed_Program_Plan__r.Department_Right_Indented__c,
            Program_Offering__r.hed_Program_Plan__r.Right_Signature__c,
            Program_Offering__r.hed_Program_Plan__r.Partner_Logo__c,
            Program_Offering__r.hed_Program_Plan__r.Name,
            Program_Offering__r.hed_Program_Plan__r.Facilitated_By__c,
            Program_Offering__r.hed_Program_Plan__c
            FROM hed__Course_Enrollment__c
            WHERE Id =:courseConnectionId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
	
		Datetime dt = Date.today();
        this.dateToday = dt.day() + ' ' + dt.format('MMMM') + ' ' + dt.year();   
        if(!courseCon.isEmpty()){
            this.student = courseCon[0];
        }

        if( this.student != null && 
            this.student.RecordType != null &&
            this.student.RecordType.DeveloperName == studentProgramRT){
                this.product = 'program';
                setupProgramCertificate();
        }else{
                this.product = 'course';
                setupCourseCertificate();
        }
    }
    
    /**
     * @description get image html format of richtext field
     * @param richText - rich text field to convert
     */
    private String getImageUrl(String richText){
        String imageURL='';
          Matcher imgMatcher = Pattern.compile( '<img(.+?)>' ).matcher(richText);           
            while (imgMatcher.find()) {                
             String imageTag = imgMatcher.group();   
             imageURL= imageTag.substringBetween(' src="', '"' );
            }
        return imageURL.unescapeHtml4();
    }

    private void setupCourseCertificate(){
        
        if(this.student.hed__Course_Offering__r.hed__Course__r.Partner_Logo__c != null){
            this.partnerLogo = getImageUrl(this.student.hed__Course_Offering__r.hed__Course__r.Partner_Logo__c);
        }

        if(this.student.hed__Course_Offering__r.hed__Course__r.Left_Signature__c != null){
            this.leftSignature = getImageUrl(this.student.hed__Course_Offering__r.hed__Course__r.Left_Signature__c);
        }
        
        Datetime dtStartDate = this.student.hed__Course_Offering__r?.hed__Start_Date__c;
        Datetime dtEndDate = this.student.hed__Course_Offering__r?.hed__End_Date__c;

        this.startDate = dtStartDate.year() == dtEndDate.year()?dtStartDate.day() + ' ' + dtStartDate.format('MMMM'):dtStartDate.day() + ' ' + dtStartDate.format('MMMM') + ' ' + dtStartDate.year();
        this.endDate = dtEndDate.day() + ' ' + dtEndDate.format('MMMM') + ' ' + dtEndDate.year();

        if( this.student.hed__Course_Offering__r.hed__Course__r.Right_Signature__c != null){
            this.rightSignature = getImageUrl(this.student.hed__Course_Offering__r.hed__Course__r.Right_Signature__c);
        }
        
        this.facilitatorName = this.student.hed__Course_Offering__r.Primary_Facilitator__r.First_Name__c + ' ' + this.student.hed__Course_Offering__r.Primary_Facilitator__r.Last_Name__c;

        if( this.student.hed__Course_Offering__r.Primary_Facilitator__r.hed__Contact__r.Salutation != null && 
            facilitatorTitle.contains(this.student.hed__Course_Offering__r.Primary_Facilitator__r.hed__Contact__r.Salutation)){

            this.facilitatorName = this.student.hed__Course_Offering__r.Primary_Facilitator__r.hed__Contact__r.Salutation + ' ' + this.student.hed__Course_Offering__r.Primary_Facilitator__r.First_Name__c + ' ' + this.student.hed__Course_Offering__r.Primary_Facilitator__r.Last_Name__c;
        }
        
        this.studentName = this.student.First_Name__c + ' ' + this.student.Last_Name__c;

        //set font size
        this.fontSize = getFontSize(this.student.hed__Course_Offering__r.hed__Course__r.Name.length());
        this.facilitatorFontSize = getFontSize(this.facilitatorName.length());
        this.studentNameFontSize = getFontSize(this.studentName.length());

    }

    private void setupProgramCertificate(){
        
        if(this.student.Program_Offering__r.hed_Program_Plan__r.Partner_Logo__c != null){
            this.partnerLogo = getImageUrl(this.student.Program_Offering__r.hed_Program_Plan__r.Partner_Logo__c);
        }

        if(this.student.Program_Offering__r.hed_Program_Plan__r.Left_Signature__c != null){
            this.leftSignature = getImageUrl(this.student.Program_Offering__r.hed_Program_Plan__r.Left_Signature__c);
        }

        Datetime dtStartDate = this.student.Program_Offering__r.Start_Date__c;
        Datetime dtEndDate = this.student.Program_Offering__r.End_Date__c;

        this.startDate = dtStartDate.year() == dtEndDate.year()?dtStartDate.day() + ' ' + dtStartDate.format('MMMM'):dtStartDate.day() + ' ' + dtStartDate.format('MMMM') + ' ' + dtStartDate.year();
        this.endDate = dtEndDate.day() + ' ' + dtEndDate.format('MMMM') + ' ' + dtEndDate.year();

        if( this.student.Program_Offering__r.hed_Program_Plan__r.Right_Signature__c != null){
            this.rightSignature = getImageUrl(this.student.Program_Offering__r.hed_Program_Plan__r.Right_Signature__c);
        }

        this.facilitatorName = this.student.Program_Offering__r.hed_Program_Plan__r.Facilitated_By__c;
        this.studentName = this.student.First_Name__c + ' ' + this.student.Last_Name__c;

        //set font size
        this.fontSize = getFontSize(this.student.Program_Offering__r.hed_Program_Plan__r.Name.length());
        this.facilitatorFontSize = getFontSize(this.facilitatorName.length());
        this.studentNameFontSize = getFontSize(this.studentName.length());

    }

    public static String getFontSize(Integer textLength){
        String fontName;
        
        if(textLength >121 && textLength <= 255 ){
            fontName = 'x-small-font';
     
        }else if(textLength >61 && textLength <= 120 ){
            fontName = 'small-font';
     
        }else if(textLength >31){
            fontName = 'medium-font';
     
        }else{
            fontName = 'big-font';
        }
        return fontName;
    }
  }