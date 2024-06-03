({
    doInit: function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(function(response) {
            console.log(JSON.parse(JSON.stringify(response)));
            component.set("v.parentRecordId",response[0].recordId);
            // Set isInitialized to true after initialization
            component.set("v.isInitialized", true);
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})