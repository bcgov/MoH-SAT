@isTest
public class SchemaUtilTest {
    @isTest
    static void test_schema_util() {
    	system.assert(null != SchemaUtil.getObject('Account'));
    	system.assert(null != SchemaUtil.getDescribe('Account'));
    	system.assert(null != SchemaUtil.getFieldMap('Account'));
    	system.assert(null != SchemaUtil.getFieldDescribe('Account','Name'));
    	system.assert(null != SchemaUtil.getFieldType('Account', 'Name'));
    	system.assert(null != SchemaUtil.getSOAPType('Account', 'Name'));
    	system.assert(null != SchemaUtil.isTypeBoolean('Account', 'Name'));
    	system.assert(null != SchemaUtil.isTypeDate('Account', 'Name'));
    	system.assert(null != SchemaUtil.isTypeDatetime('Account', 'Name'));
    	system.assert(null != SchemaUtil.isTypeDouble('Account', 'Name'));
    	system.assert(null != SchemaUtil.isTypeID('Account', 'Name'));
    	system.assert(null != SchemaUtil.isTypeInteger('Account', 'Name'));
    	system.assert(null != SchemaUtil.isTypeString('Account', 'Name'));
    	system.assert(null != SchemaUtil.isTypeTime('Account', 'Name'));
		system.assert(null != SchemaUtil.getRecordTypeInfosByDeveloperName('Account', 'PersonAccount'));
    }
}