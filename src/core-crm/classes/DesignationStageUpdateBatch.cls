/**
 * @description Batch Class to update Designation Stages
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala   	       | March 14, 2024        | DEPP-8210              | Created file                 |
      | eugene.andrew.abuan            | March 18, 2024        | DEPP-8211              | Added Active Stage           |
      | nicole.genon                   | March 20, 2024        | DEPP-8212              | Added Archived Stage         |
 */
public class DesignationStageUpdateBatch implements Database.Batchable<sObject> {
    /**
     * @description to get Designation for stage update
     * @param bc - BatchableContext
     * @return query - filtered query of Designation records
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return DesignationsDAO.newInstance().queryLocatorGetDesignationsForStageUpdate();
    }

    /**
     * @description Method to execute the batch
     * @param bc - BatchableContext
     * @param designationList - List of Designation Records
     */
    public void execute(Database.BatchableContext bc, List<Designation__c> designationList) {
        try {
            List<Designation__c> designationsToUpdate = new List<Designation__c>();
            List<Designation__c> designationToUpdateWithActive = new List<Designation__c>();

            for (Designation__c dc : designationList) {
                if (isForPublish(dc)) {
                    buildDesignationWithNewStage(
                        designationsToUpdate,
                        dc,
                        DesignationsDAO.DC_PUBLISHED
                    );
                }

                if (isForArchived(dc)) {
                    buildDesignationWithNewStage(
                        designationsToUpdate,
                        dc,
                        DesignationsDAO.DC_ARCHIVED
                    );
                }

                if(isForActive(dc)){
                    designationToUpdateWithActive.add(dc);
                }
            }

            if(!designationToUpdateWithActive.isEmpty()){
                // Call the Distribution Management Service to check if per Designation has an active Distribution Management
                List<Designation__c> designationWithDistributionManagement = DistributionManagementService.getRelatedDistributionManagementOfDesignation(
                    designationToUpdateWithActive);
                for (Designation__c designation : designationWithDistributionManagement){
                    buildDesignationWithNewStage(
                        designationsToUpdate,
                        designation,
                        DesignationsDAO.DC_ACTIVE
                    );
                }
            }

            if (!designationsToUpdate.isEmpty()) {
                DesignationsDAO.newInstance()
                    .updateRecords(designationsToUpdate, false, AccessLevel.SYSTEM_MODE);
            }
        } catch (Exception e) {
            Logger.error(
                    'Exception caught in method execute in Apex class DesignationStageUpdateBatch.'
                )
                .setExceptionDetails(e);
        } finally {
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
    }

    private boolean isForPublish(Designation__c dc) {
        return dc.Ready_For_Publishing__c == true &&
            dc.Public_Giving_Publish_Start_Date__c <= System.today() &&
            dc.Public_Giving_Publish_End_Date__c > System.today() &&
            dc.Stage__c != DesignationsDAO.DC_PUBLISHED &&
            dc.Stage__c != DesignationsDAO.DC_ARCHIVED;
    }

    private boolean isForActive(Designation__c dc){
        return dc.Activation_Start_Date__c <= System.today() &&
            dc.Activation_End_Date__c > System.today() &&
            ( dc.Public_Giving_Publish_End_Date__c < System.today()||
            dc.Ready_For_Publishing__c == false ||
            dc.Public_Giving_Publish_Start_Date__c == null ||
            dc.Public_Giving_Publish_Start_Date__c > System.today()
            ) &&
            dc.Stage__c != DesignationsDAO.DC_ACTIVE &&
            dc.Stage__c != DesignationsDAO.DC_ARCHIVED &&
            (dc.RecordtypeId == DesignationsDAO.ENDOWNMENT_RECTYPE_ID ||
             dc.RecordtypeId == DesignationsDAO.GIVING_TO_CAUSE_RECTYPE_ID
            );
    }

    private boolean isForArchived(Designation__c dc) {
        return (dc.Archived_Date__c <= System.today() ||
            dc.Activation_End_Date__c <= System.today()) &&
            dc.Stage__c != DesignationsDAO.DC_ARCHIVED;
    }

    private void buildDesignationWithNewStage(
        List<Designation__c> designationsToUpdate,
        Designation__c dc,
        String stage
    ) {
        designationsToUpdate.add(new Designation__c(Id = dc.Id, Stage__c = stage));
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {
    }
}