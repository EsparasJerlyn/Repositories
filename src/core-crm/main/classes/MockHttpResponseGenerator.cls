@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint() == 'callout:LOQATE/harmony/rest/address/lookup' || req.getEndpoint() == 'callout:LOQATE/harmony/rest/address/retrieve'){
            res = loqateAddressMockResponse();
        }
        return res;
    }

    public static HttpResponse loqateAddressMockResponse(){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"payload":[{"fullAddress":"testAddress","country":"testCountry"}]}');
        res.setStatusCode(200);
        return res;
    }
}

