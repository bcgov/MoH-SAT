public with sharing class SchemaUtil {
    private static Map<String, Schema.SobjectType> schemaMap;
	private static Map<String, Schema.DescribeSObjectResult> objectCache = new Map<String, Schema.DescribeSObjectResult>();
	private static Map<String, Map<String, SObjectField>> objectFieldCache = new Map<String, Map<String, SObjectField>>();

	private static Map<String, Schema.SObjectType> getSchema() {
		if (schemaMap == null) {
			schemaMap = Schema.getGlobalDescribe();
		}
		
		return schemaMap;
	}
	
	public static Schema.SObjectType getObject(String objName) {
		return getSchema().get(objName);
	}
	
	public static DescribeSObjectResult getDescribe(String name) {
		return getDescribe(getObject(name));
	}
    
    public static DescribeSObjectResult getDescribe(SObjectType objType) {
		DescribeSObjectResult descInfo = objectCache.get(objType + '');
		if (descInfo == null) {
			descInfo = objType.getDescribe();
			objectCache.put(objType + '', descInfo);
		}
		
		return descInfo;
	}
    
    public static Schema.DescribeFieldResult getFieldDescribe(String objType, String fieldName) {
    	return getFieldDescribe(getObject(objType), fieldName);
	}

    public static Schema.DescribeFieldResult getFieldDescribe(SObjectType objType, String fieldName) {
    	if (objType == null || fieldName == null) return null;
    	
    	Map<String, SObjectField> fieldMap = getFieldMap(objType);
    	
        SObjectField field =  (fieldMap != null) ? fieldMap.get(fieldName) : null;
        
        return (field != null) ? field.getDescribe() : null;
    }
    
    public static Map<String, SObjectField> getFieldMap(String objName) {
    	return getFieldMap(getObject(objName));
    }
    
    public static Map<String, SObjectField> getFieldMap(SObjectType objType) {
    	Map<String, SObjectField> fieldMap = objectFieldCache.get(objType + '');
    	
    	if (fieldMap == null) {
    		DescribeSObjectResult descInfo = getDescribe(objType);
    		if (descInfo != null) {
    			fieldMap = descInfo.fields.getMap();
    			objectFieldCache.put(objType + '', fieldMap);
			}
		}
        
        return fieldMap;
    }
    
    public static Schema.DisplayType getFieldType(String objType, String fieldName) {
    	return getFieldDescribe(objType,fieldName).getType();
    }
    
    public static Schema.SOAPType getSOAPType(String objType, String fieldName) {
    	return getFieldDescribe(objType,fieldName).getSOAPType();
    }
    
    public static Boolean isTypeBoolean(String objName, String fieldName) {
    	return Schema.SoapType.Boolean == getSOAPType(objName,fieldName);
    }
    
    public static Boolean isTypeDate(String objName, String fieldName) {
    	return Schema.SoapType.Date== getSOAPType(objName,fieldName);
    }
    
    public static Boolean isTypeDateTime(String objName, String fieldName) {
    	return Schema.SoapType.DateTime == getSOAPType(objName,fieldName);
    }
    
    public static Boolean isTypeDouble(String objName, String fieldName) {
    	return Schema.SoapType.Double == getSOAPType(objName,fieldName);
    }
    
    public static Boolean isTypeID(String objName, String fieldName) {
    	return Schema.SoapType.ID == getSOAPType(objName,fieldName);
    }
    
    public static Boolean isTypeInteger(String objName, String fieldName) {
    	return Schema.SoapType.Integer == getSOAPType(objName,fieldName);
    }
    
    public static Boolean isTypeString(String objName, String fieldName) {
    	return Schema.SoapType.String == getSOAPType(objName,fieldName);
    }
    
    public static Boolean isTypeTime(String objName, String fieldName) {
    	return Schema.SoapType.Time == getSOAPType(objName,fieldName);
	}
	
	public static RecordTypeInfo getRecordTypeInfosByDeveloperName(String sObjectName, String recordTypeName) {
        return getDescribe(sObjectName).getRecordTypeInfosByDeveloperName().get(recordTypeName);
    }

    public static RecordTypeInfo getRecordTypeInfoById(String sObjectName, Id recordTypeId) {
        return getDescribe(sObjectName).getRecordTypeInfosById().get(recordTypeId);
    }
}
