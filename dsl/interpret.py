from textx import metamodel_from_file
from shutil import copytree, ignore_patterns, rmtree
from mako.template import Template
import os
import sys
from pathlib import Path

derive_dict = {
  "owner" : {
        "name" : "Ownable",
        "file" : "Ownable.sol",
        "dependencies" : [],
        "used" : False,  
  },
  "admin" : {
      "name" : "Administered",
      "file" : "Administered.sol",
      "dependencies" : ["owner"],
      "used" : False,
  },
  "minter" : {
      "name" : "Mintable",
      "file" : "Mintable.sol",
      "dependencies" : ["admin"],
      "used" : False, 
  },
  "burner" : {
      "name" : "Burnable",
      "file" : "Burnable.sol",  
      "dependencies" : ["admin"],
      "used" : False,
  },
  "pause" : {
      "name" : "Pausable",
      "file" : "Pausable.sol",
      "dependencies" : [],
      "used" : False,
  }
}

include_dict = {
  "base" : {
      "name" : "ERC721Base",
      "file" : "ERC721Base.sol",
      "interface" : "ERC721.sol",
      "dependencies" : [],
      "used" : True,
      "template" : True,  
      "public" : False
  },
  "meta" : {
      "name" : "ERC721BaseMetadata",
      "file" : "ERC721BaseMetadata.sol",
      "interface" : "ERC721Metadata.sol",
      "dependencies" : [],
      "used" : False,
      "template" : True,
      "public" : True  
  },
  "enum" : {
      "name" : "ERC721BaseEnumerable",
      "file" : "ERC721BaseEnumerable.sol",
      "interface" : "ERC721Enumerable.sol",
      "dependencies" : ["supply"],
      "used" : False,
      "template" : True,
      "public" : True  
  },
  "mint" : {
      "name" : "ERC721BaseMintable",
      "file" : "ERC721BaseMintable.sol",
      "interface" : "ERC721Mintable.sol",
      "dependencies" : [],
      "used" : False,
      "template" : True,
      "public" : True  
  },
  "burn" : {
      "name" : "ERC721BaseBurnable",
      "file" : "ERC721BaseBurnable.sol",
      "interface" : "ERC721Burnable.sol",
      "dependencies" : [],
      "used" : False,
      "template" : True,
      "public" : True    
  },
  "auction" : {
      "name" : "ERC721BaseBuyable",
      "file" : "ERC721BaseBuyable.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False,
      "template" : True,
      "public" : True  
  },
  "extend" : {
      "name" : "ERC721Extended",
      "file" : "ERC721Extended.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False,
      "template" : True,
      "public" : False    
  },
  "limit" : {
      "name" : "ERC721BaseMintableLimited",
      "file" : "ERC721BaseMintableLimited.sol",
      "interface" : "",
      "dependencies" : ["mint", "supply"],
      "used" : False,
      "template" : False,
      "public" : False   
  },
  "supply" : {
      "name" : "ERC721BaseTokenSupply",
      "file" : "ERC721BaseTokenSupply.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False,
      "template" : False,
      "public" : False    
  },
  "core" : {
      "name" : "Core",
      "file" : "Core.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : True,
      "template" : True,
      "public" : False   
  }
}

modifiers_dict = {
    "onlyTokenOwner" : "base",
    "onlyTokenOwnerOrApproved" : "base",
    "onlyContractOwner" : "owner",
    "onlyAdmin" : "admin",
    "onlyMinter" : "minter",
    "onlyBurner" : "burner"
}

functions_dict = {
    "balanceOf" : "base",
    "ownerOf" : "base",
    "getApproved" : "base",
    "setApprovalForAll" : "base",
    "isApprovedForAll" : "base",
    "burn" : "burn",
    "mint" : "mint",
    "name" : "meta",
    "symbol" : "meta",
    "tokenURI" : "meta",
    "setTokenURI" : "meta",
    "totalSupply" : "enum",
    "tokenByIndex" : "enum",
    "tokenOfOwnerByIndex" : "enum",
    "setTokenData" : "extend",
    "getTokenData" : "extend"
}

template_data_dict = {
  "base_imports" : [],
  "base_extensions" : [],
  "core_imports" : [],
  "core_extensions" : [],
  "fields" : {}
}

def parse(contract):
  # parse derive arguments
  _parse_derived(derived=contract.derived)
  # parse include arguments
  _parse_included(included=contract.included)
  # parse extend arguments
  _parse_extended(fields=contract.fields)
  # parse modify arguments
  _parse_modifiers(contract)

def _parse_derived(derived):
  for elem in derived:
    if elem in derive_dict:
      _set_used_recursive(elem, derive_dict)
    else:
      raise Exception("Unkown '{}' identifier for 'derive'.".format(elem))
 
def _parse_included(included):
  for elem in included:
    if elem.name == "mint" and elem.params:
      if not len(elem.params) == 1:
        raise Exception("Too many arguments for 'mint'. Expected 1 argument, received: {} arguments.".format(len(elem.params)))
      limit = elem.params[0]
      if not isinstance(limit, int):
        raise Exception("Wrong argument type for 'mint'. Expected class 'int', received: {}.".format(type(limit)))
      if not limit > 0 :
        raise Exception("Limit of tokens for minting should be > 0 (greater than). The value was: {}.".format(limit))

      _set_used_recursive("limit", include_dict)
    
    if elem.name == "meta":
      if elem.params:
        if not len(elem.params) == 2:
          raise Exception("Wrong number of arguments for 'meta'. Expected 2 arguments, received: {} argument(s).".format(len(elem.params)))
        if not (isinstance(elem.params[0], str) and isinstance(elem.params[1], str)):
          raise Exception("Wrong argument(s) type(s) for 'meta'. Expected class 'str', class 'str', received: {0}, {1}.".format(type(elem.params[0]), type(elem.params[1])))
      else:
        elem.params.append("")
        elem.params.append("")
    
    if elem.name in include_dict and include_dict[elem.name]["public"]:
      _set_used_recursive(elem.name, include_dict)
    else:
      raise Exception("Unkown '{}' identifier for 'include'.".format(elem.name))

def _parse_extended(fields):
  if fields: _set_used_recursive("extend", include_dict)
  field_names = set()
  for elem in fields:
    if elem.name in field_names:
      raise Exception("Field identifiers must be unique. Double declaration for '{}'.".format(elem.name))
    else:
      field_names.add(elem.name)

    if (elem.type.name == "int" or elem.type.name == "uint") and elem.type.size > 0:
      if elem.type.size < 8 or elem.type.size > 256: 
        raise Exception("Size of '{0}' should be at least 8 and at most 256. The value was: {1}.".format(elem.type.name, elem.type.size))
      if elem.type.size % 8 != 0:
        raise Exception("Size of '{0}' should be a multiple of 8. The value was: {1}.".format(elem.type.name, elem.type.size))
      elem.type.name += str(elem.type.size) 
    if elem.type.name == "bytes":
      if elem.type.size > 32 or elem.type.size < 1: 
        raise Exception("Size of '{0}' should be at least 1 and at most 32. The value was: {1} or not provided.".format(elem.type.name, elem.type.size))
      elem.type.name += str(elem.type.size)
    if elem.type.size < 0:
      raise Exception("Size of '{}' cannot be negative.".format(elem.type.name))

def _parse_modifiers(contract):
  functions_modified = set()
  for elem in contract.modifiers:
    if elem.function not in functions_dict:
      raise Exception("Unknown '{}' function name.".format(elem.function))
    if elem.modifier not in modifiers_dict:
      raise Exception("Unknown '{}' modifier.".format(elem.modifier))
    # check if function dependecy is added (used)
    include_dep = functions_dict[elem.function]
    if not include_dict[include_dep]["used"]:
      raise Exception("Function '{0}' is not available and thus cannot be modified. Inclusion of '{1}' is missing.".format(elem.function, include_dep))
    # check if function not already modified
    if elem.function in functions_modified:
      raise Exception("Function '{}' already has a modifier. Only one modifier per function is allowed.".format(elem.function))
    # check if modifier is available - dependecy is met
    modifier_dep = modifiers_dict[elem.modifier]
    if modifier_dep != "base" and not derive_dict[modifier_dep]["used"]:
      raise Exception("Modifier '{0}' is not available. Derivation of '{1}' is missing.".format(elem.modifier, modifier_dep))

    functions_modified.add(elem.function)

def _set_used_recursive(feature, structure_dict):
  for elem in structure_dict[feature]["dependencies"]: 
    if not structure_dict[elem]["used"]:
      _set_used_recursive(elem, structure_dict)
  structure_dict[feature]["used"] = True    

def create_structure():
  unused = _get_unused(structure_dict=include_dict) + _get_unused(structure_dict=derive_dict)
  copytree("../templates", "contracts", ignore=ignore_patterns(*unused))

def _get_unused(structure_dict, unused = []):
  for elem in structure_dict.values():
    if not elem["used"]:
      unused.append(elem["file"])
      if "interface" in elem and elem["interface"]: unused.append(elem["interface"]) 

  return unused

def create_template_data(contract):
  # extract derive arguments
  _extract_derived()
  # extract include arguments
  _extract_included(included=contract.included)
  # extract extend arguments
  _extract_extended(fields=contract.fields)
  # extract modify arguments
  _extract_modifiers(modifiers=contract.modifiers)

def _extract_derived():
  for key, elem in derive_dict.items():
    if elem["used"]:
      template_data_dict["base_imports"].append(elem["file"])
      template_data_dict["base_extensions"].append(elem["name"]) 
      if key == "pause": template_data_dict["pause"] = "whenNotPaused"

def _extract_included(included):
  for elem in included:
    if elem.name == "mint" and elem.params:
      params = "(" + str(elem.params[0]) + ")"
      template_data_dict["core_imports"].append(include_dict["limit"]["file"])
      template_data_dict["core_extensions"].append(include_dict["limit"]["name"] + params)        
    else:
      template_data_dict["core_imports"].append(include_dict[elem.name]["file"])
      params = ""
      if elem.name == "meta":
        params = '("{0}", "{1}")'.format(elem.params[0], elem.params[1])

      template_data_dict["core_extensions"].append(include_dict[elem.name]["name"] + params)         
  if not included: # if nothing is included then add the base ERC721
    template_data_dict["core_imports"].append(include_dict["base"]["file"])
    template_data_dict["core_extensions"].append(include_dict["base"]["name"])  

  if include_dict["extend"]["used"]:
    template_data_dict["core_imports"].append(include_dict["extend"]["file"])
    template_data_dict["core_extensions"].append(include_dict["extend"]["name"])

def _extract_extended(fields):
  for field in fields:
    template_data_dict["fields"][field.name] = field.type.name

def _extract_modifiers(modifiers):
  for modifier in modifiers:
    template_data_dict[modifier.function] = modifier.modifier

def write_templates():
  for elem, val in include_dict.items():  
    if val["template"] and val["used"]:
      filename = "contracts/" + val["file"]
      template = Template(filename=filename)
      rendered = template.render(data=template_data_dict)
      f = open(filename, "w")
      f.write(rendered)
      f.close()


if len(sys.argv) != 2 :
  raise Exception("Usage: interpret.py <inputfile>")

if Path('contracts').exists():
  val = input("Destination '/contracts' already exists. Delete and proceed? : [y/n]")
  if val == "y" or val == "Y":
    rmtree("contracts")
  else:
    exit()

meta_model = metamodel_from_file('grammar.tx')
contract = meta_model.model_from_file(sys.argv[1])

## checks the AST and adjusts its data if needed
parse(contract)                
## creates the final contracts structure with only the used templates
create_structure()              
## goes through the AST and extracts the data needed for the templates
create_template_data(contract)  
## write data to templates
write_templates()                
