public class XMLSerializer{
    
    //Private Members
    private boolean serializeNulls = true;  				// Serializes XML nodes even if the content is null
    private string rootElement;              				// Root element to wrap around the serialized string.
    private Set<string> deSerializeAsArrayNodes = new Set<string>();	// Collection of node names to be deserialized as array.
    
    /*
    @Description    : Serializes the object passed to XML string
    @Parameter      : objectToSerialize = Apex object to serialize into XML
    @Returns        : XML String
    */
    public string serialize(object objectToSerialize){        
        object deSerialized = JSON.deserializeUntyped(JSON.serialize(objectToSerialize));               
        return !string.isEmpty(rootElement) ? Wrap(rootElement,serialize((Map<string,object>)deSerialized)) : serialize((Map<string,object>)deSerialized);     
    }
    
    //Helpers
    
    /*
    @Description    : Serialize method
    @Parameter      : objectMap = Map of String and objects
    @Returns        : XML String
    */
    private string serialize(Map<string,object> objectMap){
        string xmlString = '';    
        for(string key:objectMap.keySet()){  
            object o = objectMap.get(key);
            if(o == null) { if(this.SerializeNulls)     xmlString += wrap(key,null); }                       
            else if(o InstanceOf List<object> )         xmlString += serialize((List<object>) o,key);
            else if(o InstanceOf Map<string,object> )   xmlString += wrap(key,serialize((Map<string,object>) o));
            else                                        xmlString += wrap(key,string.valueOf(o));                               
        }
        return xmlString;
    }
    
    /*
    @Description    : Wraps value with key xml element
    @Parameter      : key = Xml node name
    @parameter	: value = xml node value
    @Returns        : XML String
    */
    private string wrap(string key, string value){
        return (string.isNotBlank(value) || serializeNulls) ? ('<' + key + '>' + (string.isBlank(value)?'':value) + '</' + key + '>') : value;
    }

    /*
    @Description    : Serialize method
    @Parameter      : objectList = List of objects
    @Parameter      : key = key to wrap all elements of the list with 
    @Returns        : XML String
    */
    private string serialize(List<object> objectList, string key){
        string xmlString = '';      
        for(object o:objectList){    
            if (o InstanceOf string)				xmlString += wrap(key,string.valueOf(o)); 	
            else if(o InstanceOf List<object> )  	xmlString += wrap(key,serialize((List<object>) o, key));
            else                            		xmlString += wrap(key,serialize((Map<string,object>) o));                
        }     
        return xmlString;
    }
}