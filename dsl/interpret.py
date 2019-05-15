"""
from textx import metamodel_from_file

meta_model = metamodel_from_file('grammar.tx')

nft_model = meta_model.model_from_file('model.nft')

print (nft_model)

"""
from mako.template import Template

mytemplate = Template(filename='template.sol', strict_undefined=True)
data={}

data['name'] = "Andrew"
print(mytemplate.render(data=data))
