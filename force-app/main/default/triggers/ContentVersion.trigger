trigger ContentVersion on ContentVersion  (after insert, after update) {
    Set<Id> contentDocumentIdSet = new Set<Id>();
    
    for(ContentVersion cv:trigger.new)
    {
        if(cv.ContentDocumentId != null)
        {
            contentDocumentIdSet.add(cv.ContentDocumentId);
        }
        
    }
    System.debug('@@@@@'+contentDocumentIdSet);
}