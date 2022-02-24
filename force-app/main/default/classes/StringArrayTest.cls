public class StringArrayTest {
    public static List<string> generateStringArray(integer n){
        List<string> toArray=new List<string>();
        for (integer i=0;i<n;i++){
            toArray.add('Test' + i);
            system.debug(toArray[i]);
        }
        return toArray;
    }

}