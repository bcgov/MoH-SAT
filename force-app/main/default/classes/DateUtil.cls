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

    public static String formatToOdrDate(Date dateItem) {
        Datetime dt = Datetime.newInstance(dateItem, Time.newInstance(0, 0, 0, 0));
        return dt.format('yyyy/MM/dd');
    }

    public static Date calculateTerminationDate(Date startDate, Integer duration, String durationUnit) {
        Date terminationDate = startDate;

        if (String.isBlank(durationUnit) || durationUnit.equalsIgnoreCase('Indefinite')) {
            terminationDate = Date.newInstance(3000, 1, 1);
        } else if (durationUnit.equalsIgnoreCase('End of year')) {
            terminationDate = Date.newInstance(terminationDate.year(), 12, 31);
        } else if (durationUnit.equalsIgnoreCase('Days')) {
            terminationDate = terminationDate.addDays(duration).addDays(1);
        } else if (durationUnit.equalsIgnoreCase('Months')) {
            terminationDate = terminationDate.addMonths(duration).addDays(1);
        } else if (durationUnit.equalsIgnoreCase('Years')) {
            terminationDate = terminationDate.addYears(duration).addDays(1);
        }

        return terminationDate;
    }
}
