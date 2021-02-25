public with sharing class Eform {
    public static Bundle parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new Bundle(parser);
    }

    public class Bundle {
        public String resourceType {get;set;} 
        public String id {get;set;} 
        public Meta meta {get;set;} 
        public String type_Z {get;set;} // in json: type
        public String timestamp {get;set;} 
        public List<Entry> entry {get;set;} 

        public Bundle(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'resourceType') {
                            resourceType = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'meta') {
                            meta = new Meta(parser);
                        } else if (text == 'type') {
                            type_Z = parser.getText();
                        } else if (text == 'timestamp') {
                            timestamp = parser.getText();
                        } else if (text == 'entry') {
                            entry = arrayOfEntry(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Eform consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }

    }

    public class Meta {
        public String lastUpdated {get;set;} 
        public List<Tag> tag {get;set;} 

        public Meta(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'lastUpdated') {
                            lastUpdated = parser.getText();
                        } else if (text == 'tag') {
                            tag = arrayOfTag(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Meta consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Entry {
        public Resource resource {get;set;} 

        public Entry(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'resource') {
                            resource = new Resource(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Entry consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
        
    public class Resource {
        public String resourceType {get;set;} 
        public String id {get;set;} 
        public Boolean active {get;set;} 
        public String birthDate {get;set;} 
        public String contentType {get;set;} 
        public String data {get;set;} 
        public String status {get;set;} 
        public String authored {get;set;} 
        public Source source {get;set;}
        public List<Address> address {get;set;} 
        public List<Name> name {get;set;} 
        public List<Identifier> identifier {get;set;} 
        public List<Item> item {get;set;} 
        public List<Telecom> telecom {get;set;} 
        public List<Qualification> qualification {get;set;} 

        public Resource(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'resourceType') {
                            resourceType = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'identifier') {
                            identifier = arrayOfIdentifier(parser);
                        } else if (text == 'active') {
                            active = parser.getBooleanValue();
                        } else if (text == 'name') {
                            name = arrayOfName(parser);
                        } else if (text == 'telecom') {
                            telecom = arrayOfTelecom(parser);
                        } else if (text == 'birthDate') {
                            birthDate = parser.getText();
                        } else if (text == 'address') {
                            address = arrayOfAddress(parser);
                        } else if (text == 'contentType') {
                            contentType = parser.getText();
                        } else if (text == 'data') {
                            data = parser.getText();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'authored') {
                            authored = parser.getText();
                        } else if (text == 'source') {
                            source = new Source(parser);
                        } else if (text == 'item') {
                            item = (List<Item>) parser.readValueAs(List<Item>.class);
                        } else if (text == 'qualification') {
							qualification = arrayOfQualification(parser);
						} else {
                            System.debug(LoggingLevel.WARN, 'Resource consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
        
    public class Type_Z {
        public String text {get;set;} 

        public Type_Z(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'text') {
                            text = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Type_Z consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Qualification {
		public Code code {get;set;} 

		public Qualification(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'code') {
							code = new Code(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Qualification consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
        
    public class Address {
        public String use {get;set;} 
        public List<String> line {get;set;} 
        public String city {get;set;} 
        public String state {get;set;} 
        public String postalCode {get;set;} 
        public Period period {get;set;} 

        public Address(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'use') {
                            use = parser.getText();
                        } else if (text == 'line') {
                            line = arrayOfString(parser);
                        } else if (text == 'city') {
                            city = parser.getText();
                        } else if (text == 'state') {
                            state = parser.getText();
                        } else if (text == 'postalCode') {
                            postalCode = parser.getText();
                        } else if (text == 'period') {
                            period = new Period(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Address consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
        
    public class Period {
        public String start {get;set;} 

        public Period(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'start') {
                            start = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Period consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
        
    public class Source {
        public String reference {get;set;} 

        public Source(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'reference') {
                            reference = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Source consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
        
    public class Name {
        public String use {get;set;} 
        public String family {get;set;} 
        public List<String> given {get;set;} 

        public Name(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'use') {
                            use = parser.getText();
                        } else if (text == 'family') {
                            family = parser.getText();
                        } else if (text == 'given') {
                            given = arrayOfString(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Name consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
        
    public class Extension {
        public String url {get;set;} 
        public String valueString {get;set;} 

        public Extension(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'url') {
                            url = parser.getText();
                        } else if (text == 'valueString') {
                            valueString = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Extension consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
        
    public class Item {
        public String linkId;
        public String text;
        public List<Answer> answer;
        public List<Item> item;
    }

    public class Answer {
        public Boolean valueBoolean;
        public Decimal valueDecimal;
        public Integer valueInteger;
        public Date valueDate;
        public Datetime valueDatetime;
        public String valueString;
        public String valueUrl;
    }
        
    public class Identifier {
        public Type_Z type_Z {get;set;} // in json: type
        public String system_Z {get;set;} // in json: system
        public String value {get;set;} 

        public Identifier(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type_Z = new Type_Z(parser);
                        } else if (text == 'system') {
                            system_Z = parser.getText();
                        } else if (text == 'value') {
                            value = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Identifier consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Code {
		public List<Tag> coding {get;set;} 

		public Code(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'coding') {
							coding = arrayOfTag(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Code consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
        
    public class Tag {
        public String system_Z {get;set;} // in json: system
        public String code {get;set;} 

        public Tag(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'system') {
                            system_Z = parser.getText();
                        } else if (text == 'code') {
                            code = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Tag consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
        
    public class Telecom {
        public List<Extension> extension {get;set;} 
        public String system_Z {get;set;} // in json: system
        public String value {get;set;} 
        public String use {get;set;} 
        public Period period {get;set;} 

        public Telecom(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'extension') {
                            extension = arrayOfExtension(parser);
                        } else if (text == 'system') {
                            system_Z = parser.getText();
                        } else if (text == 'value') {
                            value = parser.getText();
                        } else if (text == 'use') {
                            use = parser.getText();
                        } else if (text == 'period') {
                            period = new Period(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Telecom consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
        
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    private static List<Identifier> arrayOfIdentifier(System.JSONParser p) {
        List<Identifier> res = new List<Identifier>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Identifier(p));
        }
        return res;
    }

    private static List<Address> arrayOfAddress(System.JSONParser p) {
        List<Address> res = new List<Address>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Address(p));
        }
        return res;
    }

    private static List<Name> arrayOfName(System.JSONParser p) {
        List<Name> res = new List<Name>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Name(p));
        }
        return res;
    }

    private static List<Entry> arrayOfEntry(System.JSONParser p) {
        List<Entry> res = new List<Entry>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Entry(p));
        }
        return res;
    }

    private static List<Telecom> arrayOfTelecom(System.JSONParser p) {
        List<Telecom> res = new List<Telecom>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Telecom(p));
        }
        return res;
    }


    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }

    private static List<Extension> arrayOfExtension(System.JSONParser p) {
        List<Extension> res = new List<Extension>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Extension(p));
        }
        return res;
    }

    private static List<Tag> arrayOfTag(System.JSONParser p) {
        List<Tag> res = new List<Tag>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Tag(p));
        }
        return res;
    }

    private static List<Qualification> arrayOfQualification(System.JSONParser p) {
        List<Qualification> res = new List<Qualification>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Qualification(p));
        }
        return res;
    }
}
