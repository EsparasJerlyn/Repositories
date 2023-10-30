/**
 * @description Model Class for Course Level Lead Score Configuration
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
public with sharing class LeadScoreConfigCourseLevel extends LeadScoreConfigBaseModel{
    private Integer studyLevelUnderGrad = 0;
    private Integer studyLevelPostGrad = 0;
    private Integer studyLevelHigherDeg = 0;
    private Integer studyLevelShortCoursePD = 0;
    private Integer studyLevelExchange = 0;
    private Integer studyLevelIsBlank = 0;

    public Integer getStudyLevelUnderGrad() {
        return studyLevelUnderGrad;
    }

    public void setStudyLevelUnderGrad(Integer studyLevelUnderGrad) {
        this.studyLevelUnderGrad = studyLevelUnderGrad;
    }

    public Integer getStudyLevelPostGrad() {
        return studyLevelPostGrad;
    }

    public void setStudyLevelPostGrad(Integer studyLevelPostGrad) {
        this.studyLevelPostGrad = studyLevelPostGrad;
    }

    public Integer getStudyLevelHigherDeg() {
        return studyLevelHigherDeg;
    }

    public void setStudyLevelHigherDeg(Integer studyLevelHigherDeg) {
        this.studyLevelHigherDeg = studyLevelHigherDeg;
    }

    public Integer getStudyLevelShortCoursePD() {
        return studyLevelShortCoursePD;
    }

    public void setStudyLevelShortCoursePD(Integer studyLevelShortCoursePD) {
        this.studyLevelShortCoursePD = studyLevelShortCoursePD;
    }

    public Integer getStudyLevelExchange() {
        return studyLevelExchange;
    }

    public void setStudyLevelExchange(Integer studyLevelExchange) {
        this.studyLevelExchange = studyLevelExchange;
    }
    
    public Integer getStudyLevelIsBlank() {
        return studyLevelIsBlank;
    }

    public void setStudyLevelIsBlank(Integer studyLevelIsBlank) {
        this.studyLevelIsBlank = studyLevelIsBlank;
    }
    
}