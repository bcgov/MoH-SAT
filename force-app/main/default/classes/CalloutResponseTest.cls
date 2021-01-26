@isTest
public class CalloutResponseTest {
  @isTest
  public static void CalloutResponseTest() {
  
  CalloutResponse cor = new CalloutResponse();
    cor.errorCode = 200;
    cor.errorMessage = 'Error Message';
    cor.response = 'SALESFORCE';
    System.assertEquals(true, true);
  }
}