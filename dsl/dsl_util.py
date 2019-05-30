def put(data, variable):
  if variable not in data:
    return ""
  return data[variable]

def modify(data, function):
  modif = put(data, function)
  if modif == "onlyTokenOwner" or modif == "onlyTokenOwnerOrApproved":
      modif += "(tokenID)"  
  return modif

def get_imports(data, category):
  files = put(data, category)
  imports = ""
  if files:
    imports = "".join(str("import " + '"./' + file + '"' + ";\n") for file in files)
  return imports

def get_extensions(data, category):
  contracts = put(data, category)
  extensions = ""
  if contracts:
    extensions = ", ".join(contracts)
  return extensions    
