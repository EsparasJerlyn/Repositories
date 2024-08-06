({
    doInit: function (cmp, event, helper) {
        var action = cmp.get("c.syncOperatingHours");
        action.setParams({ operatingHrsId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + returnValue);
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
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            $A.get("e.force:closeQuickAction").fire();
        });

        $A.enqueueAction(action);
        
    }
    
})