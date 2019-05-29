from textx import metamodel_from_file
from shutil import copytree, ignore_patterns

structure_dict = {
  "base" : {
      "name" : "ERC721Base",
      "file" : "ERC721Base.sol",
      "interface" : "ERC721.sol",
      "dependencies" : [],
      "used" : True  
  },
  "owner" : {
      "name" : "Ownable",
      "file" : "Ownable.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False  
  },
  "admin" : {
      "name" : "Administered",
      "file" : "Administered.sol",
      "interface" : "",
      "dependencies" : ["owner"],
      "used" : False  
  },
  "minter" : {
      "name" : "Mintable",
      "file" : "Mintable.sol",
      "interface" : "",
      "dependencies" : ["admin"],
      "used" : False  
  },
  "burner" : {
      "name" : "Burnable",
      "file" : "Burnable.sol",
      "interface" : "",
      "dependencies" : ["admin"],
      "used" : False  
  },
  "pause" : {
      "name" : "Pausable",
      "file" : "Pausable.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False  
  },
  "meta" : {
      "name" : "ERC721BaseMetadata",
      "file" : "ERC721BaseMetadata.sol",
      "interface" : "ERC721Metadata.sol",
      "dependencies" : [],
      "used" : False  
  },
  "enum" : {
      "name" : "ERC721BaseEnumerable",
      "file" : "ERC721BaseEnumerable.sol",
      "interface" : "ERC721Enumerable.sol",
      "dependencies" : ["supply"],
      "used" : False  
  },
  "mint" : {
      "name" : "ERC721BaseMintable",
      "file" : "ERC721BaseMintable.sol",
      "interface" : "ERC721Mintable.sol",
      "dependencies" : [],
      "used" : False  
  },
  "burn" : {
      "name" : "ERC721BaseBurnable",
      "file" : "ERC721BaseBurnable.sol",
      "interface" : "ERC721Burnable.sol",
      "dependencies" : [],
      "used" : False  
  },
  "auction" : {
      "name" : "ERC721BaseBuyable",
      "file" : "ERC721BaseBuyable.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False  
  },
  "extend" : {
      "name" : "ERC721Extended",
      "file" : "ERC721Extended.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False  
  },
  "limit" : {
      "name" : "ERC721BaseMintableLimited",
      "file" : "ERC721BaseMintableLimited.sol",
      "interface" : "",
      "dependencies" : ["mint", "supply"],
      "used" : False  
  },
  "supply" : {
      "name" : "ERC721BaseTokenSupply",
      "file" : "ERC721BaseTokenSupply.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False  
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
    _set_used_recursive(elem)

def _parse_included(included):
  for elem in included:
    if elem.mint: elem.name = "mint"  # add check > 0 if mint has limit
    if elem.meta: elem.name = "meta"
    _set_used_recursive(elem.name)

def _parse_extended(fields):
  for elem in fields:
    # ensure uint_ is used with proper size
    if elem.type.int and elem.type.int.size:
      int_field = elem.type.int
      if int_field.size < 8 or int_field.size > 256: 
        raise Exception("Size of '{0}' should be at least 8 and at most 256. The value was: {1}".format(int_field.name, int_field.size))
      if int_field.size % 8 != 0:
        raise Exception("Size of '{0}' should be a multiple of 8. The value was: {1}".format(int_field.name, int_field.size))
    # ensure field names do not repeat

def _parse_modifiers(contract):
  for elem in contract.modifiers:
    print(elem) # ensure correspondence function to derives and inclusions, and no double declarations

def _set_used_recursive(feature):
  for elem in structure_dict[feature]["dependencies"]:
    _set_used_recursive(elem)
  structure_dict[feature]["used"] = True    

def create_structure():
  unused = _get_unused()
  copytree("../templates", "contracts", ignore=ignore_patterns(*unused))

def _get_unused(unused = []):
  for elem in structure_dict.values():
    if not elem["used"]:
      unused.append(elem["file"])
      if elem["interface"]: unused.append(elem["interface"]) 

  return unused



meta_model = metamodel_from_file('grammar.tx')
contract = meta_model.model_from_file('test.nft')

parse(contract) ## checks the AST and adjusts its data if needed
#print(structure_dict)
#create_structure()  ## creates the final contracts structure with only the used templates

