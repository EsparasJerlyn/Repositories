/**
 * @description Controller class for Face to Face Final Confirmation Email Template
 *
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | marygrace.li@qut.edu.au        | April 4, 2022         | DEPP-1479              | Created file                 |
      | rhea.b.torres                  | June 22, 2022         | DEPP-3188              | Get sessions with Date__c is |
      |                                |                       |                        | tomorrow                     |
      | rhea.b.torres                  | November 4, 2022      | DEPP-4720              | Deleted unused method        |
      |                                |                       |                        | generatePDFandSendEmail()    |
 */
public with sharing class FacetoFaceFinalConfirmationEmailCtrl {
  public hed__Course_Enrollment__c courseConnect { get; set; }
  public List<Session__c> sessions { get; set; }
  Set<String> faceToFaceSet = new Set<String>{'Brisbane Classroom',
                                            'Canberra Classroom',
                                            'Melbourne Classroom',
                                            'Sydney Classroom'};

  public facetoFaceFinalConfirmationEmailCtrl() {
    String courseConnectionId = ApexPages.currentPage()
      .getParameters()
      .get('courseConnectionId');
    this.courseConnect = [
      SELECT
        Id,
        hed__Course_Offering__c,
        Amount__c,
        hed__Contact__r.FirstName,
        hed__Contact__r.LastName,
        Course_Offering_Name__c,
        Paid_in_Full__c,
        hed__Course_Offering__r.hed__Course__c,
        hed__Course_Offering__r.Delivery_Type__c
      FROM hed__Course_Enrollment__c
      WHERE Id = :courseConnectionId
      LIMIT 1
    ];

    if (this.courseConnect != null) {
      this.sessions = [
        SELECT
          Id,
          Course_Connection__c,
          Course_Offering__c,
          Course_Connection__r.Name,
          Name,
          Date__c,
          Start_Time_v2__c,
          End_Time_v2__c,
          Location__c,
          Location_Name__c,
          Location_Detail_v2__c
        FROM Session__c
        WHERE Course_Offering__c = :courseConnect.hed__Course_Offering__c
            AND Course_Offering__r.Delivery_Type__c IN :faceToFaceSet
      ];
    }
  }
}