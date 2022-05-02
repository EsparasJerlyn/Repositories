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
      |                           |                       |                      |                              | 
 */
public with sharing class SetupCertificateVFPageCtrl {
    public boolean hasPartnerLogo {get;set;}
    public string partnerLogo {get;set;}
    public boolean hasLeftSignature {get;set;}
    public string leftSignature {get;set;}
    public boolean hasRightSignature {get;set;}
    public string rightSignature {get;set;}
    public string facilitatorName {get;set;}
    public hed__Course_Enrollment__c student {get;set;}
    public String dateToday {get;set;}
    public string startDate {get;set;}
    public string endDate {get;set;}
    
    
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
            hed__Course_Offering__r.hed__Start_Date__c,
            hed__Course_Offering__r.hed__End_Date__c,
            hed__Course_Offering__r.Primary_Facilitator__r.First_Name__c, 
			hed__Course_Offering__r.Primary_Facilitator__r.Last_Name__c,
            hed__Course_Offering__r.hed__Course__r.Left_Signature__c,
            hed__Course_Offering__r.hed__Course__r.Top_Left_Signature_Text__c,
            hed__Course_Offering__r.hed__Course__r.Middle_Left_Signature_Text__c,
            hed__Course_Offering__r.hed__Course__r.Bottom_Left_Signature_Text__c,
            hed__Course_Offering__r.hed__Course__r.Top_Right_Signature_Text__c,
            hed__Course_Offering__r.hed__Course__r.Middle_Right_Signature_Text__c,
            hed__Course_Offering__r.hed__Course__r.Bottom_Right_Signature_Text__c,
            hed__Course_Offering__r.hed__Course__r.Right_Signature__c,
            hed__Course_Offering__r.hed__Course__r.Partner_Logo__c,
            hed__Course_Offering__r.hed__Course__r.Name,
            hed__Course_Offering__r.hed__Course__c
            FROM hed__Course_Enrollment__c
            WHERE Id =:courseConnectionId
            LIMIT 1
        ];
	
		Datetime dt = Date.today();
        this.dateToday = dt.day() + ' ' + dt.format('MMMM') + ' ' + dt.year();   
        if(!courseCon.isEmpty()){
            this.student = courseCon[0];
        }
       
        if(this.student != null && 
           this.student.hed__Course_Offering__c !=null && 
           this.student.hed__Course_Offering__r.hed__Course__c !=null && 
           this.student.hed__Course_Offering__r.hed__Course__r.Partner_Logo__c != null){
            this.hasPartnerLogo = true;
            this.partnerLogo = getImageUrl(this.student.hed__Course_Offering__r.hed__Course__r.Partner_Logo__c);
        }else{
            this.hasPartnerLogo = false;
        }
        
        if(this.student != null && 
           this.student.hed__Course_Offering__c !=null && 
           this.student.hed__Course_Offering__r.hed__Course__c !=null && 
           this.student.hed__Course_Offering__r.hed__Course__r.Left_Signature__c != null){
           this.hasLeftSignature = true;
           this.leftSignature = getImageUrl(this.student.hed__Course_Offering__r.hed__Course__r.Left_Signature__c);
        }else{
            this.hasLeftSignature = false;
        }
        
        if(this.student!= null && 
           this.student.hed__Course_Offering__c !=null &&
           this.student.hed__Course_Offering__r.hed__Start_Date__c != null && 
           this.student.hed__Course_Offering__r.hed__End_Date__c != null){
               Datetime dtStartDate = this.student.hed__Course_Offering__r.hed__Start_Date__c;
               Datetime dtEndDate = this.student.hed__Course_Offering__r.hed__End_Date__c;
               if(dtStartDate.year() == dtEndDate.year()){
                   this.startDate = dtStartDate.day() + ' ' + dtStartDate.format('MMMM'); 
               }else{
                   this.startDate = dtStartDate.day() + ' ' + dtStartDate.format('MMMM') + ' ' + dtStartDate.year(); 
               }
               this.endDate = dtEndDate.day() + ' ' + dtEndDate.format('MMMM') + ' ' + dtEndDate.year();
           }
        
        if(this.student != null && 
           this.student.hed__Course_Offering__c !=null && 
           this.student.hed__Course_Offering__r.hed__Course__c !=null && 
           this.student.hed__Course_Offering__r.hed__Course__r.Right_Signature__c != null){
           this.hasRightSignature = true;
           this.rightSignature = getImageUrl(this.student.hed__Course_Offering__r.hed__Course__r.Right_Signature__c);
        }else{
            this.hasRightSignature = false;
        }
        
        if(this.student.hed__Course_Offering__c != null && 
           this.student.hed__Course_Offering__r.Primary_Facilitator__c != null && 
           this.student.hed__Course_Offering__r.Primary_Facilitator__r.First_Name__c != null && 
           this.student.hed__Course_Offering__r.Primary_Facilitator__r.Last_Name__c != null){
           this.facilitatorName = this.student.hed__Course_Offering__r.Primary_Facilitator__r.First_Name__c + ' ' + this.student.hed__Course_Offering__r.Primary_Facilitator__r.Last_Name__c;
        }else{
            this.facilitatorName = '';
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
  
  }