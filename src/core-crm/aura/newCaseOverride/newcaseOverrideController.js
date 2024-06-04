({
    doInit: function(component) {
        const workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('aura :', JSON.parse(JSON.stringify(response)));
            //Get the prior record id
            if(response.recordId){
                component.set("v.recordId",response.recordId);
            }else if(response.pageReference.state.force__recordId){
                component.set("v.recordId",response.pageReference.state.force__recordId);
            }
            //Set isInitialized to true after initialization
            component.set("v.isInitialized", true);
        }).catch(function(error) {
            console.log(JSON.stringify(error));
        });
    }
})

