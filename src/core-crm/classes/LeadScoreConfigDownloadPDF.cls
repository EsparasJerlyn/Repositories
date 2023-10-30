/**
 * @description Model Class for Download PDF Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 03, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigDownloadPDF extends LeadScoreConfigBaseModel{

    private Integer coursePagePDF = 0;
    private Integer welcomeGuide = 0;
    private Integer courseGuide = 0;

    public Integer getCoursePagePDF() {
        return coursePagePDF;
    }

    public void setCoursePagePDF(Integer coursePagePDF) {
        this.coursePagePDF = coursePagePDF;
    }

    public Integer getWelcomeGuide() {
        return welcomeGuide;
    }

    public void setWelcomeGuide(Integer welcomeGuide) {
        this.welcomeGuide = welcomeGuide;
    }

    public Integer getCourseGuide() {
        return courseGuide;
    }

    public void setCourseGuide(Integer courseGuide) {
        this.courseGuide = courseGuide;
    }

}