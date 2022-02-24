public class AccountUtils {
      public static List<Account> accountsByState(String st) {
    List<Account> accountList = [SELECT Id, Name FROM Account WHERE BillingState =: st];
          Return accountList;
}

}