public with sharing class DisplayImageClass 
{
    @AuraEnabled(cacheable= true)
    public static wrapclass recordSearch(String value)
    {
        String str = '%' +  value + '%';
        map<Id, Listing__c> listIdByListingRec = new map<Id, Listing__c>([SELECT Id, Name, State2__c, Category__c, Duration__c, Guest_Max_Capacity__c
                                                                           FROM Listing__c
                                                                           WHERE State2__c LIKE : str]);

        map<Id, Id> conDocIdByLinkId = new map<Id, Id>(); 
         for(ContentDocumentLink docLink: [SELECT ContentDocumentId, LinkedEntityId
                                            FROM ContentDocumentLink
                                            WHERE LinkedEntityId = : listIdByListingRec.keySet()]) 
        {
            if(!conDocIdByLinkId.containskey(docLink.ContentDocumentId))
            {
                conDocIdByLinkId.put(docLink.ContentDocumentId, docLink.LinkedEntityId);
            }
        }                                                          

        map<Id, List<String>> linkObjIdByDocId = new map<Id, List<String>>();
        for(Contentversion conObj : [SELECT Id,ContentDocumentId
                                    FROM Contentversion                                        
                                    WHERE  ContentDocumentId IN :conDocIdByLinkId.keySet()])
        { 
          if(!linkObjIdByDocId.containsKey(conDocIdByLinkId.get(conObj.ContentDocumentId)))
          {
            linkObjIdByDocId.put(conDocIdByLinkId.get(conObj.ContentDocumentId),new List<String>());
          }
          linkObjIdByDocId.get(conDocIdByLinkId.get(conObj.ContentDocumentId)).add('/sfc/servlet.shepherd/version/download/'+conObj.Id);
        }
                                                                        
        system.debug('ContentDocumentId : '+linkObjIdByDocId);
        wrapclass listingObj = new wrapclass();
        listingObj.rIdsWithConIds = linkObjIdByDocId;
        listingObj.listingList = listIdByListingRec.values();
        System.debug('listingObject : '+listingObj);
        return listingObj;
    }
    public class wrapclass
     {
        @AuraEnabled
       public map<Id, List<String>> rIdsWithConIds;
       @AuraEnabled
       public List<Listing__c> listingList;
    }
}
