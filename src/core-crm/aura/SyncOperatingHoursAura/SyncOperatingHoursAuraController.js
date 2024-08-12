({
    doInit: function (cmp, event, helper) {
        var action = cmp.get("c.syncOperatingHours");
        action.setParams({ operatingHrsId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            if (state === "SUCCESS") {
                if(returnValue == "Success"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been Sync to AWS successfully.",
                        "type": "success"
                    });
                }
                if(returnValue == "Failed"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Warning!",
                        "message": "The record has not been Sync to AWS.",
                        "type": "warning"
                    });
                }
                toastEvent.fire();
            }
            $A.get("e.force:closeQuickAction").fire();
        });

        $A.enqueueAction(action);
        
    }
    
})