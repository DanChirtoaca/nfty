from textx import metamodel_from_file

structure_dict = {
  "base" : {
      "name" : "ERC721Base",
      "path" : "contracts/ERC721Base.sol",
      "interface" : "interfaces/ERC721.sol",
      "dependencies" : [],
      "used" : True  
  },
  "owner" : {
      "name" : "Ownable",
      "path" : "contracts/Ownable.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False  
  },
  "admin" : {
      "name" : "Administered",
      "path" : "contracts/Administered.sol",
      "interface" : "",
      "dependencies" : ["owner"],
      "used" : False  
  },
  "minter" : {
      "name" : "Mintable",
      "path" : "contracts/Mintable.sol",
      "interface" : "",
      "dependencies" : ["admin"],
      "used" : False  
  },
  "burner" : {
      "name" : "Burnable",
      "path" : "contracts/Burnable.sol",
      "interface" : "",
      "dependencies" : ["admin"],
      "used" : False  
  },
  "pause" : {
      "name" : "Pausable",
      "path" : "contracts/Pausable.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False  
  },
  "meta" : {
      "name" : "ERC721BaseMetada",
      "path" : "contracts/ERC721BaseMetada.sol",
      "interface" : "interfaces/ERC721Metadata.sol",
      "dependencies" : [],
      "used" : False  
  },
  "enum" : {
      "name" : "ERC721BaseEnumerable",
      "path" : "contracts/ERC721BaseEnumerable.sol",
      "interface" : "interfaces/ERC721Enumerable.sol",
      "dependencies" : ["supply"],
      "used" : False  
  },
  "mint" : {
      "name" : "ERC721BaseMintable",
      "path" : "contracts/ERC721BaseMintable.sol",
      "interface" : "interfaces/ERC721Mintable.sol",
      "dependencies" : [],
      "used" : False  
  },
  "burn" : {
      "name" : "ERC721BaseBurnable",
      "path" : "contracts/ERC721BaseBurnable.sol",
      "interface" : "interfaces/ERC721Burnable.sol",
      "dependencies" : [],
      "used" : False  
  },
  "auction" : {
      "name" : "ERC721BaseBuyable",
      "path" : "contracts/ERC721BaseBuyable.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False  
  },
  "extend" : {
      "name" : "ERC721Extended",
      "path" : "contracts/ERC721Extended.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False  
  },
  "limit" : {
      "name" : "ERC721BaseMintableLimited",
      "path" : "contracts/Ownable.sol",
      "interface" : "",
      "dependencies" : ["mint", "supply"],
      "used" : False  
  },
  "supply" : {
      "name" : "ERC721BaseTokenSupply",
      "path" : "contracts/ERC721BaseTokenSupply.sol",
      "interface" : "",
      "dependencies" : [],
      "used" : False  
  },
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
  for elem in derived:
    print(elem) # check validity of elements and sort (necessary for proper linearization)

def _parse_included(included):
  for elem in included:
    if elem.mint:
      elem.name = "mint"
    if elem.meta:
      elem.name = "meta"
    print(elem.name)

def _parse_extended(fields):
  for elem in fields:
    print(elem)  # ensure uint_ is used with proper size

def _parse_modifiers(contract):
  for elem in contract.modifiers:
    print(elem) # ensure correspondence function to derives and inclusions, and no double declarations

meta_model = metamodel_from_file('grammar.tx')
contract = meta_model.model_from_file('test.nft')

parse(contract) ## checks the AST and adjusts its data if needed


