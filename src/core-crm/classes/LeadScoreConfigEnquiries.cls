/**
 * @description Model Class for Enquiries Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 02, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigEnquiries extends LeadScoreConfigBaseModel{

    private Integer applyingForCourse = 0;
    private Integer entryReqAndUnivStudy = 0;
    private Integer feesCostScholarship = 0;
    private Integer courseInformation = 0;
    private Integer myApplicationAndOffer = 0;
    private Integer myEnrollment = 0;
    private Integer studentLife = 0;

    public Integer getApplyingForCourse() {
        return applyingForCourse;
    }

    public void setApplyingForCourse(Integer applyingForCourse) {
        this.applyingForCourse = applyingForCourse;
    }

    public Integer getEntryReqAndUnivStudy() {
        return entryReqAndUnivStudy;
    }

    public void setEntryReqAndUnivStudy(Integer entryReqAndUnivStudy) {
        this.entryReqAndUnivStudy = entryReqAndUnivStudy;
    }

    public Integer getFeesCostScholarship() {
        return feesCostScholarship;
    }

    public void setFeesCostScholarship(Integer feesCostScholarship) {
        this.feesCostScholarship = feesCostScholarship;
    }

    public Integer getCourseInformation() {
        return courseInformation;
    }

    public void setCourseInformation(Integer courseInformation) {
        this.courseInformation = courseInformation;
    }

    public Integer getMyApplicationAndOffer() {
        return myApplicationAndOffer;
    }

    public void setMyApplicationAndOffer(Integer myApplicationAndOffer) {
        this.myApplicationAndOffer = myApplicationAndOffer;
    }

    public Integer getMyEnrollment() {
        return myEnrollment;
    }

    public void setMyEnrollment(Integer myEnrollment) {
        this.myEnrollment = myEnrollment;
    }

    public Integer getStudentLife() {
        return studentLife;
    }

    public void setStudentLife(Integer studentLife) {
        this.studentLife = studentLife;
    }
}