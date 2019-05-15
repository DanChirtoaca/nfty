<%!
  def put(data, variable):
    if variable not in data:
      return ""
    return data[variable]
%>

<%
  files = put(data, 'imports')
  imports = ""
  if files:
    imports = "".join(str("import " + '"' + file + '"' + ";\n") for file in files)

  contracts = put(data, 'extensions')
  extensions = ""
  if contracts:
    extensions = ", ".join(contracts)
%>

pragma solidity >=0.5.6;

${imports}

contract Core is ${extensions} {}