public with sharing class ProductHealthCategory {
  @AuraEnabled(cacheable=true)
  public static List<Product_Health_Category__c> getProductHealthCategories(){
      return [
          select
              Id, DINs__c, Name
          from Product_Health_Category__c
          order by Name
      ];
  }
}
