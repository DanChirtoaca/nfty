<%!
  from dsl_util import put, modify, getImports, getExtensions
%>
<%
  imports = getImports(data)
  extensions = getExtensions(data)
  #pause = put(data, 'pausable')
%>
pragma solidity >=0.5.6;

${imports}
contract Core is ${extensions} {}