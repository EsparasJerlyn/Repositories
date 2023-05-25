public with sharing class OpportunityTriggerHandler implements Disableable, BeforeInsert {
    public void beforeInsert(List<Sobject> newItems) {
        CodeGeneratorService.generateOpportunityCodeForOpportunityRecords((List<Opportunity>)newItems);
    }
    
    public Boolean isDisabled() {
        final TriggerBypassStrategy bypass = new TriggerBypassStrategy();
        return bypass.isDisabled();
    }
}