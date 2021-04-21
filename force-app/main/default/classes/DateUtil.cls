public with sharing class DateUtil {

    public static Date parseOdrDate(String odrDateStr) {
        if (odrDateStr == null) return null;

        String[] terminationDateArr = odrDateStr.split('/');
        
        return Date.newInstance(
            Integer.valueOf(terminationDateArr[0]), 
            Integer.valueOf(terminationDateArr[1]), 
            Integer.valueOf(terminationDateArr[2])
        );
    }
}
