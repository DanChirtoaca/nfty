def put(data, variable):
  if variable not in data:
    return ""
  return data[variable]

def modify(data, function):
  modif = put(data, function)
  if modif:
    if modif == "onlyTokenOwner" or modif == "onlyTokenOwnerOrApproved":
      modif += "(tokenID)"  
  return modif

def getImports(data):
  files = put(data, 'imports')
  imports = ""
  if files:
    imports = "".join(str("import " + '"' + file + '"' + ";\n") for file in files)
  return imports

def getExtensions(data):
  contracts = put(data, 'extensions')
  extensions = ""
  if contracts:
    extensions = ", ".join(contracts)
  return extensions    
