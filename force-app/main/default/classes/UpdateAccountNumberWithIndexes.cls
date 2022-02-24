/**
* ───────────────────────────────────────────────────────────────────────────────────────────────────┐
* @author         Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
* @modifiedBy     Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
* @maintainedBy   Saikiran Chintakayala   <saikiran.chintakayala@raaagvitech.com>
* @version        53.0
* @created        2021-12-07
* @modified      
* @systemLayer    Apex  Class
*  **/
/**
* @description getAccountIds Method to get the accounts
* ───────────────────────────────────────────────────────────────────────────────────────────────────
* @param    List<List<Account>> accountList
* @param    To store the list of updated accounts
* @param    Account Object
* ───────────────────────────────────────────────────────────────────────────────────────────────────┘ 
*  **/
public class UpdateAccountNumberWithIndexes {
    @InvocableMethod(label='GetRecordsUpdated')
    public static void getAccountIds(List<List<Account>> accountList) {
        if(!accountList.isEmpty()){
            List<Account> accs = accountList[0];
            List<Account> accList = new List<Account>();
            integer sai=0;
            for( Account acc : accs)
            {
                sai++;
                acc.AccountNumber =''+sai;
                accList.add(acc);
            }
            update accList;
        }
        
    }
}