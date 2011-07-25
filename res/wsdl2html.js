
Object.prototype.getType = function() {
	return typeof this;
};

function MyBoolean(value) {
	this.value = value;
}

MyBoolean.prototype.toString = function() {
	return this.value.toString();
};

MyBoolean.prototype.getType = function() {
	return "MyBoolean";
};

function SimpleType(value) {
	this.value = value;
}

SimpleType.prototype.toString = function() {
	return this.value.toString();
};

SimpleType.prototype.getType = function() {
	return "SimpleType";
};

function ComplexType() {
	this.__keys = "";
}

ComplexType.prototype.getType = function() {
	return "ComplexType";
};

function $(id) { 
	return document.getElementById(id); 
}

function selectedMethod() {
	var select = $("methodSelect");
	return select.options[select.options.selectedIndex].value;
}

function methodPopupChanged(evt) {
	methodChanged();
	App.wasEdited();
}

function methodChanged() {
	var method = selectedMethod();
	var div = $("settingsWrap");
	var id = method + "-wrap";
	var child;
	for (var i = 0; i != div.childNodes.length; i++) {
		child = div.childNodes[i];
		if (child.nodeType == Node.ELEMENT_NODE) {
			child.style.display = (child.id == id) ? "" : "none";
		}
	}
}

function submitClicked() {
	save();
	App.doExecute();
}

function formSubmitted(evt) {
	App.execute(evt.target);
}

function createJsCommand() {
	var method = selectedMethod();
	var params = {};
	var order = [];
	var types = [];
	var paramsWrap = $(method+"-params-wrap");
	if (paramsWrap) {
		var currentUid;
		var customObj;
		
		var fields = paramsWrap.getElementsByTagName("input");
		var field, typeUri, dataType, name, value;
		for (var i = 0; i != fields.length; i++) {
			field = fields[i];
			
			//get value
			typeUri  = field.getAttribute("typeUri");
			dataType = field.getAttribute("placeholder");
			dataType = dataType.substring(dataType.lastIndexOf(":")+1);
			types.push(dataType);
			value	 = getValueFromField(field, dataType, typeUri);

			// get name
			name = field.name;
			var uid = field.getAttribute("uid");
			if (uid) {
				//App.log("found a custom Type! uid:"+uid);
				if (currentUid != uid) {
					customObj = new ComplexType()					
					order.push(uid);
					params[uid] = customObj
					currentUid = uid;
				}
				var index = name.indexOf(".");
				var __typeName = name.substring(0, index);
				var __typePrefix = field.getAttribute("typePrefix");
				var __typeUri = field.getAttribute("typeUri");
				var __localName = field.getAttribute("localName");
				var propName = name.substring(index+1);
				customObj["__typeName"] 	= __typeName;
				customObj["__prefix"] 		= __typePrefix;
				customObj["__localName"] 	= __localName;
				customObj["__namespaceUri"] = __typeUri;
				customObj["__typeName"] 	= __typeName;
				customObj[propName] 		= value;
				customObj.__keys += (customObj.__keys.length ? "," : "" ) + propName;
				var lastItem = order[order.length-1];
				//App.log(customObj);
			} else {
				order.push(name);
				params[name] = value;
			}
		}
	}
	var methodName = method.substring(0, method.indexOf("-"));
	var cmd = {
		method: methodName,
		methodId: method,
		endpointURI: $(method+"-endpointUri").value,
		bindingStyle: $(method+"-bindingStyle").value.replace(/\s*/g, ""),
		SOAPAction: $(method+"-soapAction").value,
		namespace: $(method+"-namespace").value,
		parameters: params,
		order: order,
		types: types
	};
	return cmd;
}

function getValueFromField(field, dataType, typeUri) {
	var value = field.value;
	if ("double" == dataType 
			|| "long" == dataType 
			|| "byte" == dataType 
			|| "int" == dataType 
			|| "integer" == dataType 
			|| "short" == dataType 
			|| "float" == dataType 
			|| "decimal" == dataType 
			|| "dateTime" == dataType 
			|| "date" == dataType) {
		value = new SimpleType(value);
		var __localName = field.name;
		var index = __localName.lastIndexOf(".");
		if (index > -1) {
			__localName = __localName.substring(index+1);
		}
		value["__localName"] = __localName;
		value["__typeName"] = dataType;
		value["__typeUri"] = typeUri;
	} else if ("boolean" == dataType || "bool" == dataType) {
		value = new MyBoolean(value);
	}
	return value;
}

function bodyLoaded(evt) {
	if (window.Command) {
		var methodId = Command.methodId();
		var select = $("methodSelect");
		var option;
		for (var i = 0; i != select.options.length; i++) {
			option = select.options[i];
			if (option.value == methodId) {
				select.options.selectedIndex = i;
				methodChanged();
				break;
			}
		}
		$(methodId+"-endpointUri").value	= Command.endpointURI();
		$(methodId+"-bindingStyle").value	= Command.bindingStyle();
		$(methodId+"-namespace").value		= Command.namespace();
		$(methodId+"-soapAction").value		= Command.soapAction();
		var params = Command.params();
		var paramOrder = Command.paramOrder();
		var id;
		for (var i = 0; i != paramOrder.length; i++) {
			id = paramOrder[i];
			$(methodId+"-"+id).value = Command.paramValueForKey(id);
		}
	}
}

function save() {
	App.consumeJsCommand(createJsCommand());
}

function inputElementChanged(evt) {
	var keyCode = evt.keyCode;
	var metaKey = evt.metaKey;
	//App.log("keyCode: " + keyCode);
	// do not mark cmd-a and cmd-c keypresses as causing an edit
	if (!metaKey) {
		if (keyCode == 8 || (keyCode > 32 && keyCode < 256)) {
			App.wasEdited();
		}
	}
	return true;
}