public with sharing class couponController {
    public couponController() {}
    @AuraEnabled(cacheable=true)
    public static List<Coupon__c> getCoupons(){
        try
        {
            return[select id,Name from Coupon__c];
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}