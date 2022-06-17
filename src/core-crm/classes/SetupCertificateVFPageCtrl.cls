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
      |                           |                       |                      |                              | 
 */
public with sharing class SetupCertificateVFPageCtrl {
    private static string studentProgramRT = System.Label.RT_CourseConnection_Student_Program;
    public boolean hasPartnerLogo {get;set;}
    public string partnerLogo {get;set;}
    public boolean hasLeftSignature {get;set;}
    public string leftSignature {get;set;}
    public boolean hasRightSignature {get;set;}
    public string rightSignature {get;set;}
    public string facilitatorName {get;set;}
    public hed__Course_Enrollment__c student {get;set;}
    public string product {get;set;}
    public string dateToday {get;set;}
    public string startDate {get;set;}
    public string endDate {get;set;}
    public string productName {get;set;}
    public string topLeftText {get;set;}
    public string topRightText {get;set;}
    public string midLeftText {get;set;}
    public string midRightText {get;set;}
    public string bottomLeftText {get;set;}
    public string bottomRightText {get;set;}
    public string fontSize {get;set;}
    
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
    public String getImageUrl(String richText){
        String imageURL='';
          Matcher imgMatcher = Pattern.compile( '<img(.+?)>' ).matcher(richText);           
            while (imgMatcher.find()) {                
             String imageTag = imgMatcher.group();   
             imageURL= imageTag.substringBetween(' src="', '"' );
            }
        return imageURL.unescapeHtml4();
    }

    public void setupCourseCertificate(){

        if( this.student != null && 
            this.student.hed__Course_Offering__c !=null && 
            this.student.hed__Course_Offering__r.hed__Course__c !=null){

            if(this.student.hed__Course_Offering__r.hed__Course__r.Name != null){
                this.productName = this.student.hed__Course_Offering__r.hed__Course__r.Name;
            } 

            if(this.student.hed__Course_Offering__r.hed__Course__r.Partner_Logo__c != null){
                this.hasPartnerLogo = true;
                this.partnerLogo = getImageUrl(this.student.hed__Course_Offering__r.hed__Course__r.Partner_Logo__c);
            }else{
                this.hasPartnerLogo = false;
            }

            if(this.student.hed__Course_Offering__r.hed__Course__r.Left_Signature__c != null){
                this.hasLeftSignature = true;
                this.leftSignature = getImageUrl(this.student.hed__Course_Offering__r.hed__Course__r.Left_Signature__c);
            }else{
                this.hasLeftSignature = false;
            }

            if( this.student.hed__Course_Offering__r.hed__Start_Date__c != null && 
                this.student.hed__Course_Offering__r.hed__End_Date__c != null){
                    Datetime dtStartDate = this.student.hed__Course_Offering__r.hed__Start_Date__c;
                    Datetime dtEndDate = this.student.hed__Course_Offering__r.hed__End_Date__c;

                    this.startDate = dtStartDate.year() == dtEndDate.year()?dtStartDate.day() + ' ' + dtStartDate.format('MMMM'):dtStartDate.day() + ' ' + dtStartDate.format('MMMM') + ' ' + dtStartDate.year();
                    this.endDate = dtEndDate.day() + ' ' + dtEndDate.format('MMMM') + ' ' + dtEndDate.year();
            }

            if( this.student.hed__Course_Offering__r.hed__Course__r.Right_Signature__c != null){
                this.hasRightSignature = true;
                this.rightSignature = getImageUrl(this.student.hed__Course_Offering__r.hed__Course__r.Right_Signature__c);
            }else{
                this.hasRightSignature = false;
            }

            if( this.student.hed__Course_Offering__r.Primary_Facilitator__r.First_Name__c != null && 
                this.student.hed__Course_Offering__r.Primary_Facilitator__r.Last_Name__c != null){
                this.facilitatorName = this.student.hed__Course_Offering__r.Primary_Facilitator__r.First_Name__c + ' ' + this.student.hed__Course_Offering__r.Primary_Facilitator__r.Last_Name__c;
            }

            if( this.student.hed__Course_Offering__r.hed__Course__r.Name_Left_Indented__c != null){
                this.topLeftText = this.student.hed__Course_Offering__r.hed__Course__r.Name_Left_Indented__c;
            }
            if( this.student.hed__Course_Offering__r.hed__Course__r.Name_Right_Indented__c != null){
                this.topRightText = this.student.hed__Course_Offering__r.hed__Course__r.Name_Right_Indented__c;
            }
            if( this.student.hed__Course_Offering__r.hed__Course__r.Position_Left_Indented__c != null){
                this.midLeftText = this.student.hed__Course_Offering__r.hed__Course__r.Position_Left_Indented__c;
            }
            if( this.student.hed__Course_Offering__r.hed__Course__r.Position_Right_Indented__c != null){
                this.midRightText = this.student.hed__Course_Offering__r.hed__Course__r.Position_Right_Indented__c;
            }
            if( this.student.hed__Course_Offering__r.hed__Course__r.Department_Left_Indented__c != null){
                this.bottomLeftText = this.student.hed__Course_Offering__r.hed__Course__r.Department_Left_Indented__c;
            }
            if( this.student.hed__Course_Offering__r.hed__Course__r.Department_Right_Indented__c != null){
                this.bottomRightText = this.student.hed__Course_Offering__r.hed__Course__r.Department_Right_Indented__c;
            }

            //set font size
            this.fontSize = getFontSize(this.productName.length());
        }

    }

    public void setupProgramCertificate(){
        if( this.student != null && 
        this.student.Program_Offering__c !=null && 
        this.student.Program_Offering__r.hed_Program_Plan__r !=null){

        if(this.student.Program_Offering__r.hed_Program_Plan__r.Name != null){
            this.productName = this.student.Program_Offering__r.hed_Program_Plan__r.Name;
        } 

        if(this.student.Program_Offering__r.hed_Program_Plan__r.Partner_Logo__c != null){
            this.hasPartnerLogo = true;
            this.partnerLogo = getImageUrl(this.student.Program_Offering__r.hed_Program_Plan__r.Partner_Logo__c);
        }else{
            this.hasPartnerLogo = false;
        }

        if(this.student.Program_Offering__r.hed_Program_Plan__r.Left_Signature__c != null){
            this.hasLeftSignature = true;
            this.leftSignature = getImageUrl(this.student.Program_Offering__r.hed_Program_Plan__r.Left_Signature__c);
        }else{
            this.hasLeftSignature = false;
        }

        if( this.student.Program_Offering__r.Start_Date__c != null && 
            this.student.Program_Offering__r.End_Date__c != null){
                Datetime dtStartDate = this.student.Program_Offering__r.Start_Date__c;
                Datetime dtEndDate = this.student.Program_Offering__r.End_Date__c;

                this.startDate = dtStartDate.year() == dtEndDate.year()?dtStartDate.day() + ' ' + dtStartDate.format('MMMM'):dtStartDate.day() + ' ' + dtStartDate.format('MMMM') + ' ' + dtStartDate.year();
                this.endDate = dtEndDate.day() + ' ' + dtEndDate.format('MMMM') + ' ' + dtEndDate.year();
        }

        if( this.student.Program_Offering__r.hed_Program_Plan__r.Right_Signature__c != null){
            this.hasRightSignature = true;
            this.rightSignature = getImageUrl(this.student.Program_Offering__r.hed_Program_Plan__r.Right_Signature__c);
        }else{
            this.hasRightSignature = false;
        }

        if( this.student.Program_Offering__r.hed_Program_Plan__r.Facilitated_By__c != null ){
            this.facilitatorName = this.student.Program_Offering__r.hed_Program_Plan__r.Facilitated_By__c;
        }

        if( this.student.Program_Offering__r.hed_Program_Plan__r.Name_Left_Indented__c != null){
            this.topLeftText = this.student.Program_Offering__r.hed_Program_Plan__r.Name_Left_Indented__c;
        }
        if( this.student.Program_Offering__r.hed_Program_Plan__r.Name_Right_Indented__c != null){
            this.topRightText = this.student.Program_Offering__r.hed_Program_Plan__r.Name_Right_Indented__c;
        }
        if( this.student.Program_Offering__r.hed_Program_Plan__r.Position_Left_Indented__c != null){
            this.midLeftText = this.student.Program_Offering__r.hed_Program_Plan__r.Position_Left_Indented__c;
        }
        if( this.student.Program_Offering__r.hed_Program_Plan__r.Position_Right_Indented__c != null){
            this.midRightText = this.student.Program_Offering__r.hed_Program_Plan__r.Position_Right_Indented__c;
        }
        if( this.student.Program_Offering__r.hed_Program_Plan__r.Department_Left_Indented__c != null){
            this.bottomLeftText = this.student.Program_Offering__r.hed_Program_Plan__r.Department_Left_Indented__c;
        }
        if( this.student.Program_Offering__r.hed_Program_Plan__r.Department_Right_Indented__c != null){
            this.bottomRightText = this.student.Program_Offering__r.hed_Program_Plan__r.Department_Right_Indented__c;
        }
         //set font size
         this.fontSize = getFontSize(this.productName.length());
    }

    }

    public static String getFontSize(Integer prodNameLength){
        String fontName;
        
        if(prodNameLength >121 && prodNameLength <= 255 ){
            fontName = 'x-small-font';
     
        }else if(prodNameLength >61 && prodNameLength <= 120 ){
            fontName = 'small-font';
     
        }else if(prodNameLength >31){
            fontName = 'medium-font';
     
        }else{
            fontName = 'big-font';
        }
        return fontName;
    }
  }