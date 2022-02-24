public class TrailLoop {
    //here is a bad loop
    public static void BadLoop() {
        List<Account> tasklessAccounts = [Select id from Account limit 5];
        for (Account a : tasklessAccounts) {
            Task t = new Task();
            t.Subject = 'make something up';
            t.whatId = a.id;
            insert t;
        }
    }
    //and here is how the developer could fix it
    public static void GoodLoop() {
        List<Account> tasklessAccounts = [Select id from Account limit 5];
        List<Task> insertTasks = new List<Task>();
        for (Account a : tasklessAccounts) {
            Task t = new Task();
            t.Subject = 'make something up';
            t.whatId = a.id;
            insertTasks.add(t);
        } 
        insert insertTasks;
    }
    public static void AllGoodThings(Account a) {
        List<Task> allMyTasks = [Select Id, status, whatId From Task where whatId=:a.id];
        for (Task t : allMyTasks) {
                t.status = 'Completed';
        }
       update allMyTasks;
    }
}