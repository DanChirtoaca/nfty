<%!
  from dsl_util import get_imports, get_extensions 
%>
<%
  imports = get_imports(data, "core_imports")
  extensions = get_extensions(data, "core_extensions")
%>
pragma solidity >=0.5.6;

${imports}
contract Core is ${extensions} {}
