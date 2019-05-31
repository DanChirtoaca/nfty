from textx import metamodel_from_file
from shutil import copytree, ignore_patterns
from mako.template import Template
import os

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
      "template" : True  
  },
  "meta" : {
      "name" : "ERC721BaseMetadata",
      "file" : "ERC721BaseMetadata.sol",
      "interface" : "ERC721Metadata.sol",
      "dependencies" : [],
      "used" : False,
      "template" : True  
  },
  "enum" : {
      "name" : "ERC721BaseEnumerable",
      "file" : "ERC721BaseEnumerable.sol",
      "interface" : "ERC721Enumerable.sol",
      "dependencies" : ["supply"],
      "used" : False,
      "template" : True  
  },
  "mint" : {
      "name" : "ERC721BaseMintable",
      "file" : "ERC721BaseMintable.sol",
      "interface" : "ERC721Mintable.sol",
      "dependencies" : [],
      "used" : False,
      "template" : True  
  },
  "burn" : {
      "name" : "ERC721BaseBurnable",
      "file" : "ERC721BaseBurnable.sol",
      "interface" : "ERC721Burnable.sol",
      "dependencies" : [],
      "used" : False,
      "template" : True  
  },
  "auction" : {
      "name" : "ERC721BaseBuyable",
      "file" : "ERC721BaseBuyable.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False,
      "template" : True  
  },
  "extend" : {
      "name" : "ERC721Extended",
      "file" : "ERC721Extended.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False,
      "template" : True  
  },
  "limit" : {
      "name" : "ERC721BaseMintableLimited",
      "file" : "ERC721BaseMintableLimited.sol",
      "interface" : "",
      "dependencies" : ["mint", "supply"],
      "used" : False,
      "template" : False  
  },
  "supply" : {
      "name" : "ERC721BaseTokenSupply",
      "file" : "ERC721BaseTokenSupply.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False,
      "template" : False  
  },
  "core" : {
      "name" : "Core",
      "file" : "Core.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : True,
      "template" : True 
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
  # TODO: check validity of elements and sort (necessary for proper linearization)
  for elem in derived:
    _set_used_recursive(elem, derive_dict)
 
def _parse_included(included):
  for elem in included:
    if elem.mint: 
      elem.name = "mint"  # add check > 0 if mint has limit
      if elem.mint.limit:
        _set_used_recursive("limit", include_dict)
    if elem.meta: elem.name = "meta"
    _set_used_recursive(elem.name, include_dict)

def _parse_extended(fields):
  if fields: _set_used_recursive("extend", include_dict)
  for elem in fields:
    # ensure uint_ is used with proper size
    if elem.type.int:
      int_field = elem.type.int
      elem_type = int_field.name 
      if int_field.size:
        elem_type += str(int_field.size)
        if int_field.size < 8 or int_field.size > 256: 
          raise Exception("Size of '{0}' should be at least 8 and at most 256. The value was: {1}".format(int_field.name, int_field.size))
        if int_field.size % 8 != 0:
          raise Exception("Size of '{0}' should be a multiple of 8. The value was: {1}".format(int_field.name, int_field.size))
      
      elem.type.name = elem_type

    # ensure field names do not repeat

def _parse_modifiers(contract):
  #for elem in contract.modifiers:
  # ensure correspondence function to derives and inclusions, and no double declarations
  pass

def _set_used_recursive(feature, structure_dict):
  for elem in structure_dict[feature]["dependencies"]:
    _set_used_recursive(elem, structure_dict)
  structure_dict[feature]["used"] = True    

def create_structure():
  unused = _get_unused(structure_dict=include_dict) + _get_unused(structure_dict=derive_dict)
  copytree("../templates", "contracts", ignore=ignore_patterns(*unused))

def _get_unused(structure_dict, unused = []):
  for elem in structure_dict.values():
    if not elem["used"]:
      unused.append(elem["file"])
      if elem["interface"]: unused.append(elem["interface"]) 

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
  if included:
    for elem in included:
      if elem.mint and elem.mint.limit:
        params = "(" + str(elem.mint.limit) + ")"
        template_data_dict["core_imports"].append(include_dict["limit"]["file"])
        template_data_dict["core_extensions"].append(include_dict["limit"]["name"] + params)        
      else:  
        template_data_dict["core_imports"].append(include_dict[elem.name]["file"])
        params = ""
        if elem.meta:
          params = '("{0}", "{1}")'.format(elem.meta.token_name, elem.meta.token_symbol)

        template_data_dict["core_extensions"].append(include_dict[elem.name]["name"] + params)   
        
  else:
    template_data_dict["core_imports"].append(include_dict["base"]["file"])
    template_data_dict["core_extensions"].append(include_dict["base"]["name"])  

def _extract_extended(fields):
  for field in fields:
    template_data_dict["fields"][field.name] = field.type.name

def _extract_modifiers(modifiers):
  for modifier in modifiers:
    template_data_dict[modifier.function] = modifier.modifier


meta_model = metamodel_from_file('grammar.tx')
contract = meta_model.model_from_file('model.nft')

parse(contract) ## checks the AST and adjusts its data if needed
create_structure()  ## creates the final contracts structure with only the used templates
create_template_data(contract)  ## goes through the AST and extracts the data needed for the templates

for elem, val in include_dict.items():  ## write data to templates
  if val["template"]:
    filename = "contracts/" + val["file"]
    template = Template(filename=filename)
    rendered = template.render(data=template_data_dict)
    f = open(filename, "w")
    f.write(rendered)
    f.close()
