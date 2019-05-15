<%!
  def put (data, variable):
    if variable not in data:
      return ""
    return data[variable]
%>
meow
hi
${put(data,"name")}
hello