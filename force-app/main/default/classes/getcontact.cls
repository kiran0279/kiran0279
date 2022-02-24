@RestResource(urlMapping='/v1/getcontact/*')
global  class getcontact {
    @HttpPost
    global static String savecontact(){
        String requestBody;
        RestRequest req = RestContext.request;
        requestBody = RestContext.request.requestBody.toString();
        System.debug(requestBody);
        System.debug('requestBody----->'+requestBody);
         List<Contact> conList =(List<Contact>)System.JSON.deserialize(requestBody,List<Contact>.class);
        System.debug('conList----->'+conList);
        for(Contact contact : conList){
            contact.Id = null;
        }
        try{
            insert conList;
            return 'Record Inserted';
        }
        catch (Exception e){
            return e.getMessage();
                    }
    }
}