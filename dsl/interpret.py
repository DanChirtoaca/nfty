"""
from textx import metamodel_from_file

meta_model = metamodel_from_file('grammar.tx')

nft_model = meta_model.model_from_file('model.nft')

print (nft_model)

"""
from mako.template import Template

mytemplate = Template(filename='template.sol', strict_undefined=True)
data={}

data['imports'] = ["./File1.sol", "./File2.sol", "./File3.sol"]
data['extensions'] = ["File1", "File2", "File3"]
print(mytemplate.render(data=data))


# functions accepting modifiers:
'''
1. ERC721Base
  - balanceOf
  - ownerOf
  - getApproved
  - setApprovalForAll
  - isApprovedForAll
2. ERC721BaseBurnable
  - burn
3. ERC721Mintable
  - mint
4. ERC721BaseMetadata
  - name
  - symbol
  - tokenURI
  - setTokenURI
5. ERC721BaseEnumerable
  - totalSupply
  - tokenByIndex
  - tokenOfOwnerByIndex
5. ERC721Extended
  - setTokenData
  - getTokenData
'''

# available modifiers:
'''
1. ERC721Base
  - onlyTokenOwner(tokenID)
  - onlyTokenOwnerOrApproved(tokenID)
2. Ownable
  - onlyContractOwner
3. Administered
  - onlyAdmin
4. Mintable
  - onlyMinter
5. Burnable
  - onlyBurner
extra:
6. Pausable
  - whenPaused
  - whenNotPaused
'''

