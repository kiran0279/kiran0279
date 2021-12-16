/* *@author        Saikiran Chintakayala        <saikiran.chintakayala@raagvitech.com>
* @modifiedBy     Saikiran Chintakayala        <saikiran.chintakayala@raagvitech.com>
* @maintainedBy   Saikiran Chintakayala        <saikiran.chintakayala@raagvitech.com>
* @version        52.0
* @created        2021-12-14
* @modified      
* @systemLayer     Apex Class
*/ 
public with sharing class ListingFormClass {
    @AuraEnabled
    public static List<String> getCategoryPickList()
    {
        List<String> mapLabelToValue = new List<String>();
        Schema.DescribeFieldResult fieldResult = Listing__c.Category__c.getDescribe();
        List<Schema.PicklistEntry> categoryPickList = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry eachOne : categoryPickList)
        {
            mapLabelToValue.add(eachOne.getValue());
        }
        return mapLabelToValue;
    }
    @AuraEnabled
    public static List<String> getDurationPickList()
    {
        List<String> mapLabelToValue = new List<String>();
        Schema.DescribeFieldResult fieldResult = Listing__c.Duration__c.getDescribe();
        List<Schema.PicklistEntry> durationPickList = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry eachOne : durationPickList)
        {
            mapLabelToValue.add(eachOne.getValue());
        }
        return mapLabelToValue;
    }
    @AuraEnabled
    public static List<String> getStatusPickList()
    {
        List<String> mapLabelToValue = new List<String>();
        Schema.DescribeFieldResult fieldResult = Listing__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> statusPickList = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry eachOne : statusPickList)
        {
            mapLabelToValue.add(eachOne.getValue());
        }
        return mapLabelToValue;
    }
    @AuraEnabled
    public static List<String> getStatePickList()
    {
        List<String> mapLabelToValue = new List<String>();
        Schema.DescribeFieldResult fieldResult = Listing__c.State2__c.getDescribe();
        List<Schema.PicklistEntry> statePickList = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry eachOne : statePickList)
        {
            mapLabelToValue.add(eachOne.getValue());
        }
        return mapLabelToValue;
    }
    @AuraEnabled
    public static String recordInsert(Listing__c recievedRec ,string file , string fileName)
  {
    string contactId;
    try{
     insert recievedRec;
     contactId = recievedRec.Id;  
       String base64File = EncodingUtil.urlDecode(file, 'UTF-8');    
       ContentVersion contentVersionRec = new ContentVersion();  
       contentVersionRec.Title = fileName;  
       contentVersionRec.PathOnClient = '/' + fileName;  
       contentVersionRec.FirstPublishLocationId = recievedRec.Id;  
       contentVersionRec.VersionData = EncodingUtil.base64Decode(base64File);  
       contentVersionRec.IsMajorVersion = true;  
       Insert contentVersionRec;  
     } catch(Exception ex){  
       system.debug('Exception===>'+ex.getMessage());  
     }  
     return contactId;
  }
}
