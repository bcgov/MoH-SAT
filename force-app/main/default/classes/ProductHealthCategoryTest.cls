@isTest
public with sharing class ProductHealthCategoryTest {

  @TestSetup
  static void test_setup(){
    Product_Health_Category__c c = TestFactory.newProductHealthCategory('Category 1', '1, 2, 3');
    insert c;
  }

  @isTest
  public static void ProductHealthCategoryTest() {
    List<Product_Health_Category__c> categories = ProductHealthCategory.getProductHealthCategories();
    system.assert(categories.size() > 0);
  }
}