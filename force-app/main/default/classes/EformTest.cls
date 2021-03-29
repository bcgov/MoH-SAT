@isTest
public class EformTest {
    // This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'	\"resourceType\": \"Bundle\",'+
		'	\"id\": \"de3f3df4-f256-4bd9-a5ff-8da50ac323cc\",'+
		'	\"meta\": {'+
		'		\"lastUpdated\": \"2021-02-23T20:22:50.4597289+00:00\",'+
		'		\"tag\": ['+
		'			{'+
		'				\"system\": \"https://ehealthbc.ca/NamingSystem/eforms/correlationId\",'+
		'				\"code\": \"4aa84313-2198-4226-8fa2-a3d8aeb4f82e\"'+
		'			},'+
		'			{'+
		'				\"system\": \"https://ehealthbc.ca/NamingSystem/eforms/formSubmitterUserName\",'+
		'				\"code\": \"TESTER0@PHSA.CA\"'+
		'			}'+
		'		]'+
		'	},'+
		'	\"type\": \"message\",'+
		'	\"timestamp\": \"2021-02-23T12:22:50.4579911-08:00\",'+
		'	\"entry\": ['+
		'		{'+
		'			\"resource\": {'+
		'				\"resourceType\": \"Patient\",'+
		'				\"id\": \"Patient1\",'+
		'				\"identifier\": ['+
		'					{'+
		'						\"type\": {'+
		'							\"text\": \"BC\"'+
		'						},'+
		'						\"system\": \"https://fhir.infoway-inforoute.ca/NamingSystem/ca-bc-patient-healthcare-id\",'+
		'						\"value\": \"9875023209\"'+
		'					}'+
		'				],'+
		'				\"active\": true,'+
		'				\"name\": ['+
		'					{'+
		'						\"use\": \"official\",'+
		'						\"family\": \"SNOW\",'+
		'						\"given\": ['+
		'							\"JON\"'+
		'						]'+
		'					}'+
		'				],'+
		'				\"telecom\": ['+
		'					{'+
		'						\"system\": \"phone\",'+
		'						\"value\": \"604-987-2345\",'+
		'						\"use\": \"home\",'+
		'						\"period\": {'+
		'							\"start\": \"2021-02-23T12:22:50.4584491-08:00\"'+
		'						}'+
		'					}'+
		'				],'+
		'				\"birthDate\": \"1995-10-23\",'+
		'				\"address\": ['+
		'					{'+
		'						\"use\": \"home\",'+
		'						\"line\": ['+
		'							\"46-980 BEAUMONT DR\"'+
		'						],'+
		'						\"city\": \"VANCOUVER\",'+
		'						\"state\": \"BC\",'+
		'						\"postalCode\": \"V2Y 7G6\",'+
		'						\"period\": {'+
		'							\"start\": \"2021-02-23T12:22:50.4583389-08:00\"'+
		'						}'+
		'					}'+
		'				]'+
		'			}'+
		'		},'+
		'		{'+
		'			\"resource\": {'+
		'				\"resourceType\": \"Practitioner\",'+
		'				\"id\": \"Submitter1\",'+
		'				\"identifier\": ['+
		'					{'+
		'						\"system\": \"urn:PHID\",'+
		'						\"value\": \"CP501\"'+
		'					}'+
		'				],'+
		'				\"name\": ['+
		'					{'+
		'						\"use\": \"official\",'+
		'						\"family\": \"Johnson\",'+
		'						\"given\": ['+
		'							\"Dale\"'+
		'						]'+
		'					}'+
		'				],'+
		'				\"telecom\": ['+
		'					{'+
		'                        \"extension\": ['+
		'                            {'+
		'                                \"url\": \"http://hl7.org/fhir/StructureDefinition/contactpoint-extension\",'+
		'                                \"valueString\": \"123\"'+
		'                            }'+
		'                        ],'+
		'						\"system\": \"phone\",'+
		'						\"value\": \"647-222-9999\",'+
		'						\"use\": \"home\",'+
		'						\"period\": {'+
		'							\"start\": \"2021-02-23T12:22:50.4588231-08:00\"'+
		'						}'+
		'					},'+
		'					{'+
		'						\"system\": \"fax\",'+
		'						\"value\": \"647-222-9977\",'+
		'						\"use\": \"work\",'+
		'						\"period\": {'+
		'							\"start\": \"2021-02-23T12:22:50.4588231-08:00\"'+
		'						}'+
		'					}'+
		'				],'+
		'				\"address\": ['+
		'					{'+
		'						\"use\": \"home\",'+
		'						\"line\": ['+
		'							\"1952 Bay st\"'+
		'						],'+
		'						\"city\": \"\",'+
		'						\"state\": \"BC\",'+
		'						\"postalCode\": \"V6P 7B8\",'+
		'						\"period\": {'+
		'							\"start\": \"2021-02-23T12:22:50.458756-08:00\"'+
		'						}'+
		'					}'+
		'				],'+
		'				\"qualification\": ['+
		'					{'+
		'						\"code\": {'+
		'							\"coding\": ['+
		'								{'+
		'									\"system\": \"urn:role\",'+
		'									\"display\": \"PHARM\"'+
		'								}'+
		'							]'+
		'						}'+
		'					},'+
		'					{'+
		'						\"code\": {'+
		'							\"coding\": ['+
		'								{'+
		'									\"system\": \"urn:specialty\",'+
		'									\"code\": \"Oncology Pharmacy\"'+
		'								}'+
		'							]'+
		'						}'+
		'					}'+
		'				]'+
		'			}'+
		'		 },'+
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
		
		Eform.Bundle r = Eform.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Bundle objEform = new Eform.Bundle(System.JSON.createParser(json));
		System.assert(objEform != null);
		System.assert(objEform.resourceType == null);
		System.assert(objEform.id == null);
		System.assert(objEform.meta == null);
		System.assert(objEform.type_Z == null);
		System.assert(objEform.timestamp == null);
		System.assert(objEform.entry == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Meta objMeta = new Eform.Meta(System.JSON.createParser(json));
		System.assert(objMeta != null);
		System.assert(objMeta.lastUpdated == null);
		System.assert(objMeta.tag == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Type_Z objType_Z = new Eform.Type_Z(System.JSON.createParser(json));
		System.assert(objType_Z != null);
		System.assert(objType_Z.text == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Address objAddress = new Eform.Address(System.JSON.createParser(json));
		System.assert(objAddress != null);
		System.assert(objAddress.use == null);
		System.assert(objAddress.line == null);
		System.assert(objAddress.city == null);
		System.assert(objAddress.state == null);
		System.assert(objAddress.postalCode == null);
		System.assert(objAddress.period == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Period objPeriod = new Eform.Period(System.JSON.createParser(json));
		System.assert(objPeriod != null);
		System.assert(objPeriod.start == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Source objSource = new Eform.Source(System.JSON.createParser(json));
		System.assert(objSource != null);
		System.assert(objSource.reference == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Code objCode = new Eform.Code(System.JSON.createParser(json));
		System.assert(objCode != null);
		System.assert(objCode.coding == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Name objName = new Eform.Name(System.JSON.createParser(json));
		System.assert(objName != null);
		System.assert(objName.use == null);
		System.assert(objName.family == null);
		System.assert(objName.given == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Extension objExtension = new Eform.Extension(System.JSON.createParser(json));
		System.assert(objExtension != null);
		System.assert(objExtension.url == null);
		System.assert(objExtension.valueString == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Entry objEntry = new Eform.Entry(System.JSON.createParser(json));
		System.assert(objEntry != null);
		System.assert(objEntry.resource == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Qualification objQualification = new Eform.Qualification(System.JSON.createParser(json));
		System.assert(objQualification != null);
		System.assert(objQualification.code == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Identifier objIdentifier = new Eform.Identifier(System.JSON.createParser(json));
		System.assert(objIdentifier != null);
		System.assert(objIdentifier.type_Z == null);
		System.assert(objIdentifier.system_Z == null);
		System.assert(objIdentifier.value == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Resource objResource = new Eform.Resource(System.JSON.createParser(json));
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
		Eform.Tag objTag = new Eform.Tag(System.JSON.createParser(json));
		System.assert(objTag != null);
		System.assert(objTag.system_Z == null);
		System.assert(objTag.code == null);
		System.assert(objTag.display == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		Eform.Telecom objTelecom = new Eform.Telecom(System.JSON.createParser(json));
		System.assert(objTelecom != null);
		System.assert(objTelecom.extension == null);
		System.assert(objTelecom.system_Z == null);
		System.assert(objTelecom.value == null);
		System.assert(objTelecom.use == null);
		System.assert(objTelecom.period == null);
	}
}
