({
    //retrieve accountid/recordid
    doInit : function(cmp, event, helper) {
        var pageRef = cmp.get("v.pageReference");
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;

        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        cmp.set("v.recordId", addressableContext.attributes.recordId);
    },

    //call standard new opportunity form
    createRecord : function(component, event, helper) {
       
	    var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Opportunity",
            "defaultFieldValues": {
                'AccountId' : component.get('v.recordId'),
                'Contact__c' : component.get('v.contactId')
            }
        });
        createRecordEvent.fire();
            
	},
  
    //retrieve contactid value from lwc
    getContactValue : function(component, event, helper) {
		component.set("v.contactId",event.getParam('contact'));
	},

    //close the tab when click button is clicked
    closeFocusedTab : function(component, event, helper) {
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });

    }
    
})