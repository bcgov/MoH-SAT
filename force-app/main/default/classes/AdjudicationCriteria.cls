public class AdjudicationCriteria {
    public class AdjudicationCriteriaException extends Exception {}
    Schema.SoapType soapType;
    String sobjectName;
    String fieldName;
    String questionId;
    String operator;
    Value expectedValue;
    Value actualValue;

    private class Value {
        public String stringValue { get; set; }
        public Boolean booleanValue { get; set; }
        public Decimal decimalValue { get; set; }
        public Date dateValue { get; set; }
        public Datetime datetimeValue { get; set; }

        public String getStringValue() {
            return stringValue;
        }
        
        public Boolean getBooleanValue() {
            return booleanValue;
        }
    
        public Decimal getDecimalValue() {
            return decimalValue;
        }
    
        public Date getDateValue() {
            return dateValue;
        }
    
        public Datetime getDatetimeValue() {
            return datetimeValue;
        }
    }

    public AdjudicationCriteria(Adjudication_Criteria__c criteria) {
        this(
            criteria.Object_Name__c, 
            criteria.Field_Name__c, 
            criteria.Question_ID__c,
            criteria.Operator__c,
            criteria.String_Value__c,
            criteria.Boolean_Value__c,
            criteria.Decimal_Value__c,
            criteria.Date_Value__c,
            criteria.Datetime_Value__c
        );
    }

    private AdjudicationCriteria(
            String sobjectName, 
            String fieldName, 
            String questionId, 
            String operator,
            String expectedStringValue, 
            Boolean expectedBooleanValue, 
            Decimal expectedDecimalValue,
            Date expectedDateValue,
            Datetime expectedDatetimeValue) {

        try {
            this.soapType = SchemaUtil.getSOAPType(sobjectName, fieldName);
        } catch (NullPointerException e) {
            throw new AdjudicationCriteriaException(e.getMessage());
        }

        this.sobjectName = sobjectName;
        this.fieldName = fieldName;
        this.questionId = String.isBlank(questionId) ? null : questionId;
        this.operator = operator;
        this.expectedValue = new Value();
        this.expectedValue.stringValue = expectedStringValue;
        this.expectedValue.booleanValue = expectedBooleanValue;
        this.expectedValue.decimalValue = expectedDecimalValue;
        this.expectedValue.dateValue = expectedDateValue;
        this.expectedValue.datetimeValue = expectedDatetimeValue;
    }

    public AdjudicationCriteria set(SObject record) {
        if (!applicable(record)) return this;

        this.actualValue = new Value();

        if (SchemaUtil.isTypeString(sobjectName, fieldName)) {
            this.actualValue.stringValue = String.valueOf(record.get(fieldName));
        } 
        else if (SchemaUtil.isTypeBoolean(sobjectName, fieldName)) {
            this.actualValue.booleanValue = Boolean.valueOf(record.get(fieldName));
        }
        else if (SchemaUtil.isTypeDouble(sobjectName, fieldName)) {
            this.actualValue.decimalValue = (Decimal) record.get(fieldName);
        }
        else if (SchemaUtil.isTypeDate(sobjectName, fieldName)) {
            this.actualValue.dateValue = (Date) record.get(fieldName);
        }
        else if (SchemaUtil.isTypeDatetime(sobjectName, fieldName)) {
            this.actualValue.datetimeValue = (Datetime) record.get(fieldName);
        } 
        else {
            this.actualValue = null;
        }
        
        return this;
    }

    private Boolean applicable(SObject record) {
        SObjectType sobjType = record.getSObjectType();

        if (!sobjectName.equals(sobjType+'')) return false;
        
        Boolean isRequestDetailValue = Request_Detail__c.getSObjectType() == sobjType;
        
        Boolean isQuestionIdEqual = 
            isRequestDetailValue 
            && questionId.equalsIgnoreCase((String) record.get(Request_Detail__c.Question_ID__c));

        if (isRequestDetailValue && !isQuestionIdEqual) return false;
        
        return true;
    }

    public Boolean evaluate() {
        if (actualValue == null) return false;

        if (operator == 'equals') {
            return evaluateEquals(expectedValue, actualValue);
        } 
        else if (operator == 'not equal to') {
            return evaluateNotEqualTo(expectedValue, actualValue);
        }
        else if (operator == 'starts with') {
            return evaluateStartsWith(expectedValue, actualValue);
        }
        else if (operator == 'contains') {
            return evaluateContains(expectedValue, actualValue);
        }
        else if (operator == 'does not contain') {
            return evaluateDoesNotContain(expectedValue, actualValue);
        }
        else if (operator == 'less than') {
            return evaluateLessThan(expectedValue, actualValue);
        }
        else if (operator == 'greater than') {
            return evaluateGreaterThan(expectedValue, actualValue);
        }
        else if (operator == 'less or equal') {
            return evaluateLessOrEqual(expectedValue, actualValue);
        }
        else if (operator == 'greater or equal') {
            return evaluateGreaterOrEqual(expectedValue, actualValue);
        }
        
        return false;
    }

    private Boolean evaluateEquals(Value expectedValue, Value actualValue) {
        Boolean result = false;

        if (this.isString()) {
            result = expectedValue.getStringValue().equalsIgnoreCase(actualValue.getStringValue());
        } 
        else if (this.isBoolean()) {
            result = expectedValue.getBooleanValue() == actualValue.getBooleanValue();
        } 
        else if (this.isDecimal()) {
            result = expectedValue.getDecimalValue() == actualValue.getDecimalValue();
        } 
        else if (this.isDate()) {
            result = expectedValue.getDateValue() == actualValue.getDateValue();
        } 
        else if (this.isDatetime()) {
            result = expectedValue.getDatetimeValue() == actualValue.getDatetimeValue();
        }

        return result;
    }

    private Boolean evaluateNotEqualTo(Value expectedValue, Value actualValue) {
        Boolean result = false;

        if (this.isString()) {
            result = !expectedValue.getStringValue().equalsIgnoreCase(actualValue.getStringValue());
        }  
        else if (this.isBoolean()) {
            result = expectedValue.getBooleanValue() != actualValue.getBooleanValue();
        }
        else if (this.isDecimal()) {
            result = expectedValue.getDecimalValue() != actualValue.getDecimalValue();
        } 
        else if (this.isDate()) {
            result = expectedValue.getDateValue() != actualValue.getDateValue();
        } 
        else if (this.isDatetime()) {
            result = expectedValue.getDatetimeValue() != actualValue.getDatetimeValue();
        }

        return result;
    }

    private Boolean evaluateStartsWith(Value expectedValue, Value actualValue) {
        Boolean result = false;

        if (this.isString()) {
            result = actualValue.getStringValue().startsWithIgnoreCase(expectedValue.getStringValue());
        } 
        
        return result;
    }

    private Boolean evaluateContains(Value expectedValue, Value actualValue) {
        Boolean result = false;

        if (this.isString()) {
            result = actualValue.getStringValue().containsIgnoreCase(expectedValue.getStringValue());
        } 
        
        return result;
    }

    private Boolean evaluateDoesNotContain(Value expectedValue, Value actualValue) {
        Boolean result = false;

        if (this.isString()) {
            result = !actualValue.getStringValue().containsIgnoreCase(expectedValue.getStringValue());
        } 
        
        return result;
    }

    private Boolean evaluateGreaterThan(Value expectedValue, Value actualValue) {
        Boolean result = false;

        if (this.isString()) {
            result = actualValue.getStringValue().toLowerCase() > expectedValue.getStringValue().toLowerCase();
        } 
        else if (this.isDecimal()) {
            result = actualValue.getDecimalValue() > expectedValue.getDecimalValue();
        } 
        else if (this.isDate()) {
            result = actualValue.getDateValue() > expectedValue.getDateValue();
        } 
        else if (this.isDatetime()) {
            result = actualValue.getDatetimeValue() > expectedValue.getDatetimeValue();
        }

        return result;
    }

    private Boolean evaluateLessThan(Value expectedValue, Value actualValue) {
        Boolean result = false;

        if (this.isString()) {
            result = actualValue.getStringValue().toLowerCase() < expectedValue.getStringValue().toLowerCase();
        } 
        else if (this.isDecimal()) {
            result = actualValue.getDecimalValue() < expectedValue.getDecimalValue();
        } 
        else if (this.isDate()) {
            result = actualValue.getDateValue() < expectedValue.getDateValue();
        } 
        else if (this.isDatetime()) {
            result = actualValue.getDatetimeValue() < expectedValue.getDatetimeValue();
        }

        return result;
    }

    private Boolean evaluateGreaterOrEqual(Value expectedValue, Value actualValue) {
        Boolean result = false;

        if (this.isString()) {
            result = actualValue.getStringValue().toLowerCase() >= expectedValue.getStringValue().toLowerCase();
        } 
        else if (this.isDecimal()) {
            result = actualValue.getDecimalValue() >= expectedValue.getDecimalValue();
        } 
        else if (this.isDate()) {
            result = actualValue.getDateValue() >= expectedValue.getDateValue();
        } 
        else if (this.isDatetime()) {
            result = actualValue.getDatetimeValue() >= expectedValue.getDatetimeValue();
        }

        return result;
    }

    private Boolean evaluateLessOrEqual(Value expectedValue, Value actualValue) {
        Boolean result = false;

        if (this.isString()) {
            result = actualValue.getStringValue().toLowerCase() <= expectedValue.getStringValue().toLowerCase();
        } 
        else if (this.isDecimal()) {
            result = actualValue.getDecimalValue() <= expectedValue.getDecimalValue();
        } 
        else if (this.isDate()) {
            result = actualValue.getDateValue() <= expectedValue.getDateValue();
        } 
        else if (this.isDatetime()) {
            result = actualValue.getDatetimeValue() <= expectedValue.getDatetimeValue();
        }

        return result;
    }

    public Boolean isString() {
        return soapType == Schema.SoapType.String;
    }
    
    public Boolean isBoolean() {
        return soapType == Schema.SoapType.Boolean;
    }

    public Boolean isDecimal() {
        return soapType == Schema.SoapType.Double;
    }

    public Boolean isDate() {
        return soapType == Schema.SoapType.Date;
    }

    public Boolean isDatetime() {
        return soapType == Schema.SoapType.Datetime;
    }
}
