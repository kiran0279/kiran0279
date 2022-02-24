public class apex {
    public String selectedAccId{get;set;}
     public List<SelectOption> getAccountNames() {
        List<SelectOption> accOptions= new List<SelectOption>();
        accOptions.add( new SelectOption('','--Select--'));
         for( Account acc : [select Id,name from Account MRU]){
            accOptions.add( new SelectOption(acc.Id,acc.name));
        }
        return accOptions;
    }
}