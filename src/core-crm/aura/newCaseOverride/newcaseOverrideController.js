({
    doInit: function(component) {
        const workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('response',JSON.parse(JSON.stringify(response)));
            //Get the prior record id
            component.set("v.recordId",response.recordId);
            //Set isInitialized to true after initialization
            component.set("v.isInitialized", true);
        }).catch(function(error) {
            console.log(JSON.stringify(error));
        });
    }
})

