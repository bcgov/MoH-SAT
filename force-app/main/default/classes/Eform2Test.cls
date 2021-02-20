@isTest
public inherited sharing class Eform2Test {
    // This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'    \"resourceType\": \"Bundle\",'+
		'    \"id\": \"cbe39adf-1a14-47bf-9172-214f0787ec2f\",'+
		'    \"meta\": {'+
		'        \"lastUpdated\": \"2021-02-19T22:26:34.6389344+00:00\",'+
		'        \"tag\": ['+
		'            {'+
		'                \"system\": \"https://ehealthbc.ca/NamingSystem/eforms/correlationId\",'+
		'                \"code\": \"d2a76bc5-6a61-4911-b069-fd72ec73b158\"'+
		'            },'+
		'            {'+
		'                \"system\": \"https://ehealthbc.ca/NamingSystem/eforms/formName\",'+
		'                \"code\": \"oneForm\"'+
		'            },'+
		'            {'+
		'                \"system\": \"https://ehealthbc.ca/NamingSystem/eforms/formTitle\",'+
		'                \"code\": \"* Request Special Authority (by Medication) *\"'+
		'            },'+
		'            {'+
		'                \"system\": \"https://ehealthbc.ca/NamingSystem/eforms/formID\",'+
		'                \"code\": \"5e84c9dc70e1762af1abc43b\"'+
		'            },'+
		'            {'+
		'                \"system\": \"https://ehealthbc.ca/NamingSystem/eforms/referenceNum\",'+
		'                \"code\": \"cbe39adf-1a14-47bf-9172-214f0787ec2f\"'+
		'            },'+
		'            {'+
		'                \"system\": \"https://ehealthbc.ca/NamingSystem/eforms/formStatus\",'+
		'                \"code\": \"Completed\"'+
		'            }'+
		'        ]'+
		'    },'+
		'    \"type\": \"message\",'+
		'    \"timestamp\": \"2021-02-19T14:26:26.9283642-08:00\",'+
		'    \"entry\": ['+
		'        {'+
		'            \"resource\": {'+
		'                \"resourceType\": \"Patient\",'+
		'                \"id\": \"Patient1\",'+
		'                \"identifier\": ['+
		'                    {'+
		'                        \"type\": {'+
		'                            \"text\": \"BC\"'+
		'                        },'+
		'                        \"system\": \"https://fhir.infoway-inforoute.ca/NamingSystem/ca-bc-patient-healthcare-id\",'+
		'                        \"value\": \"123456789\"'+
		'                    }'+
		'                ],'+
		'                \"active\": true,'+
		'                \"name\": ['+
		'                    {'+
		'                        \"use\": \"official\",'+
		'                        \"family\": \"Maximoff\",'+
		'                        \"given\": ['+
		'                            \"Wanda\",'+
		'                            \"Uni\"'+
		'                        ]'+
		'                    }'+
		'                ],'+
		'                \"telecom\": ['+
		'                    {'+
		'                        \"system\": \"phone\",'+
		'                        \"value\": \"250-111-1111\",'+
		'                        \"use\": \"home\",'+
		'                        \"period\": {'+
		'                            \"start\": \"2021-02-19T14:26:26.92938-08:00\"'+
		'                        }'+
		'                    }'+
		'                ],'+
		'                \"birthDate\": \"1990-01-01\",'+
		'                \"address\": ['+
		'                    {'+
		'                        \"use\": \"home\",'+
		'                        \"line\": ['+
		'                            \"123 1 Avenue\",'+
		'                            \"111 Unit\"'+
		'                        ],'+
		'                        \"city\": \"Vancouver\",'+
		'                        \"state\": \"BC\",'+
		'                        \"postalCode\": \"A1A1A1\",'+
		'                        \"period\": {'+
		'                            \"start\": \"2021-02-19T14:26:26.9291202-08:00\"'+
		'                        }'+
		'                    }'+
		'                ]'+
		'            }'+
		'        },'+
		'        {'+
		'            \"resource\": {'+
		'                \"resourceType\": \"Practitioner\",'+
		'                \"id\": \"Submitter1\",'+
		'                \"identifier\": ['+
		'                    {'+
		'                        \"system\": \"https://fhir.infoway-inforoute.ca/NamingSystem/ca-bc-msp-billing-id\",'+
		'                        \"value\": \"4444\"'+
		'                    }'+
		'                ],'+
		'                \"name\": ['+
		'                    {'+
		'                        \"use\": \"official\",'+
		'                        \"family\": \"Strange\",'+
		'                        \"given\": ['+
		'                            \"Stephen\"'+
		'                        ]'+
		'                    }'+
		'                ],'+
		'                \"telecom\": ['+
		'                    {'+
		'                        \"extension\": ['+
		'                            {'+
		'                                \"url\": \"http://hl7.org/fhir/StructureDefinition/contactpoint-extension\",'+
		'                                \"valueString\": \"123\"'+
		'                            }'+
		'                        ],'+
		'                        \"system\": \"phone\",'+
		'                        \"value\": \"950-553-3333\",'+
		'                        \"use\": \"home\",'+
		'                        \"period\": {'+
		'                            \"start\": \"2021-02-19T14:26:26.9298924-08:00\"'+
		'                        }'+
		'                    }'+
		'                ]'+
		'            }'+
		'        },'+
		'        {'+
		'            \"resource\": {'+
		'                \"resourceType\": \"Binary\",'+
		'                \"id\": \"subm-153a466c-048b-4141-88f5-cb4558795e6b\",'+
		'                \"contentType\": \"application/eforms\",'+
		'                \"data\": \"base64string\"'+
		'            }'+
		'        },'+
		'        {'+
		'            \"resource\": {'+
		'                \"resourceType\": \"QuestionnaireResponse\",'+
		'                \"id\": \"cbe39adf-1a14-47bf-9172-214f0787ec2f\",'+
		'                \"status\": \"completed\",'+
		'                \"authored\": \"2021-02-19T14:26:26+00:00\",'+
		'                \"source\": {'+
		'                    \"reference\": \"Patient/Patient1\"'+
		'                },'+
		'                \"item\": ['+
		'                    {'+
		'                        \"linkId\": \"patientInformation\",'+
		'                        \"text\": \"Patient Information\",'+
		'                        \"item\": ['+
		'                            {'+
		'                                \"linkId\": \"patientPrimaryPhoneNumber\",'+
		'                                \"text\": \"Primary Phone Number\",'+
		'                                \"answer\": ['+
		'                                    {'+
		'                                        \"valueString\": \"(111) 222-2222\"'+
		'                                    }'+
		'                                ]'+
		'                            }'+
		'                        ]'+
		'                    }'+
		'                ]'+
        '            }'+
		'        },'+
		'        {'+
		'            \"resource\": {'+
		'                \"resourceType\": \"Binary\",'+
		'                \"id\": \"epdf-32c1767b-e3b3-4a9b-aed6-9812ae60ac16\",'+
		'                \"contentType\": \"application/pdf\",'+
		'                \"data\": \"base64string\"'+
		'            }'+
		'        }'+
		'    ]'+
		'}';
		
		Eform2.Bundle r = Eform2.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform2.Meta objMeta = new Eform2.Meta(System.JSON.createParser(json));
		System.assert(objMeta != null);
		System.assert(objMeta.lastUpdated == null);
		System.assert(objMeta.tag == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform2.Type_Z objType_Z = new Eform2.Type_Z(System.JSON.createParser(json));
		System.assert(objType_Z != null);
		System.assert(objType_Z.text == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform2.Address objAddress = new Eform2.Address(System.JSON.createParser(json));
		System.assert(objAddress != null);
		System.assert(objAddress.use == null);
		System.assert(objAddress.line == null);
		System.assert(objAddress.city == null);
		System.assert(objAddress.state == null);
		System.assert(objAddress.postalCode == null);
		System.assert(objAddress.period == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform2.Period objPeriod = new Eform2.Period(System.JSON.createParser(json));
		System.assert(objPeriod != null);
		System.assert(objPeriod.start == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform2.Source objSource = new Eform2.Source(System.JSON.createParser(json));
		System.assert(objSource != null);
		System.assert(objSource.reference == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform2.Name objName = new Eform2.Name(System.JSON.createParser(json));
		System.assert(objName != null);
		System.assert(objName.use == null);
		System.assert(objName.family == null);
		System.assert(objName.given == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform2.Extension objExtension = new Eform2.Extension(System.JSON.createParser(json));
		System.assert(objExtension != null);
		System.assert(objExtension.url == null);
		System.assert(objExtension.valueString == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform2.Entry objEntry = new Eform2.Entry(System.JSON.createParser(json));
		System.assert(objEntry != null);
		System.assert(objEntry.resource == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform2.Identifier objIdentifier = new Eform2.Identifier(System.JSON.createParser(json));
		System.assert(objIdentifier != null);
		System.assert(objIdentifier.type_Z == null);
		System.assert(objIdentifier.system_Z == null);
		System.assert(objIdentifier.value == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform2.Resource objResource = new Eform2.Resource(System.JSON.createParser(json));
		System.assert(objResource != null);
		System.assert(objResource.resourceType == null);
		System.assert(objResource.id == null);
		System.assert(objResource.identifier == null);
		System.assert(objResource.active == null);
		System.assert(objResource.name == null);
		System.assert(objResource.telecom == null);
		System.assert(objResource.birthDate == null);
		System.assert(objResource.address == null);
		System.assert(objResource.contentType == null);
		System.assert(objResource.data == null);
		System.assert(objResource.status == null);
		System.assert(objResource.authored == null);
		System.assert(objResource.source == null);
		System.assert(objResource.item == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform2.Bundle objEform = new Eform2.Bundle(System.JSON.createParser(json));
		System.assert(objEform != null);
		System.assert(objEform.resourceType == null);
		System.assert(objEform.id == null);
		System.assert(objEform.meta == null);
		System.assert(objEform.type_Z == null);
		System.assert(objEform.timestamp == null);
		System.assert(objEform.entry == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform2.Tag objTag = new Eform2.Tag(System.JSON.createParser(json));
		System.assert(objTag != null);
		System.assert(objTag.system_Z == null);
		System.assert(objTag.code == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform2.Telecom objTelecom = new Eform2.Telecom(System.JSON.createParser(json));
		System.assert(objTelecom != null);
		System.assert(objTelecom.extension == null);
		System.assert(objTelecom.system_Z == null);
		System.assert(objTelecom.value == null);
		System.assert(objTelecom.use == null);
		System.assert(objTelecom.period == null);
	}
}
