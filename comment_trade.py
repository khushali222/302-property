"""Comment out Trade Type UI blocks in all 4 vendor files."""

files = [
    'C:/CLoudeRentalManager/302-property/lib/screens/Maintenance/Vendor/add_vendor.dart',
    'C:/CLoudeRentalManager/302-property/lib/screens/Maintenance/Vendor/edit_vendor.dart',
    'C:/CLoudeRentalManager/302-property/lib/StaffModule/screen/Maintenance/Vendor/add_vendor.dart',
    'C:/CLoudeRentalManager/302-property/lib/StaffModule/screen/Maintenance/Vendor/edit_vendor.dart',
]

# The trade type block appears in two indentation variants:
# Desktop (deeper indent) and mobile (shallower indent)
# Both follow the same structure:
#   SizedBox(height:10) + Text('Trade Type *'...) + SizedBox(height:10) + Container(dropdown...)
# ending with:   ),   <- closes Container
# then the next SizedBox before Password

TRADE_BLOCK_DESKTOP = (
    "                              Text('Trade Type *',\n"
    "                                  style: TextStyle(\n"
    "                                      fontSize: 13,\n"
    "                                      fontWeight: FontWeight.bold,\n"
    "                                      color: blueColor)),\n"
    "                              const SizedBox(height: 10),\n"
    "                              Container(\n"
    "                                height: 50,\n"
    "                                decoration: BoxDecoration(\n"
    "                                  color: Colors.white,\n"
    "                                  borderRadius: BorderRadius.circular(8.0),\n"
    "                                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1.0),\n"
    "                                ),\n"
    "                                padding: const EdgeInsets.symmetric(horizontal: 12.0),\n"
    "                                child: DropdownButtonHideUnderline(\n"
    "                                  child: DropdownButton<String>(\n"
    "                                    value: selectedTradeType,\n"
    "                                    hint: const Text('Select trade type',\n"
    "                                        style: TextStyle(fontSize: 13, color: Color(0xFFb0b6c3))),\n"
    "                                    isExpanded: true,\n"
    "                                    menuMaxHeight: 250,\n"
    "                                    items: _tradeTypes.map((type) {\n"
    "                                      return DropdownMenuItem<String>(\n"
    "                                        value: type.toLowerCase(),\n"
    "                                        child: Text(type, style: const TextStyle(fontSize: 14)),\n"
    "                                      );\n"
    "                                    }).toList(),\n"
    "                                    onChanged: (value) {\n"
    "                                      setState(() {\n"
    "                                        selectedTradeType = value;\n"
    "                                      });\n"
    "                                    },\n"
    "                                  ),\n"
    "                                ),\n"
    "                              ),\n"
)

TRADE_BLOCK_MOBILE = (
    "                            Text('Trade Type *',\n"
    "                                style: TextStyle(\n"
    "                                    fontSize: 13,\n"
    "                                    fontWeight: FontWeight.bold,\n"
    "                                    color: blueColor)),\n"
    "                            const SizedBox(height: 10),\n"
    "                            Container(\n"
    "                              height: 50,\n"
    "                              decoration: BoxDecoration(\n"
    "                                color: Colors.white,\n"
    "                                borderRadius: BorderRadius.circular(8.0),\n"
    "                                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.0),\n"
    "                              ),\n"
    "                              padding: const EdgeInsets.symmetric(horizontal: 12.0),\n"
    "                              child: DropdownButtonHideUnderline(\n"
    "                                child: DropdownButton<String>(\n"
    "                                  value: selectedTradeType,\n"
    "                                  hint: const Text('Select trade type', style: TextStyle(fontSize: 13, color: Color(0xFFb0b6c3))),\n"
    "                                  isExpanded: true,\n"
    "                                  menuMaxHeight: 250,\n"
    "                                  items: _tradeTypes.map((type) {\n"
    "                                    return DropdownMenuItem<String>(\n"
    "                                      value: type.toLowerCase(),\n"
    "                                      child: Text(type, style: const TextStyle(fontSize: 14)),\n"
    "                                    );\n"
    "                                  }).toList(),\n"
    "                                  onChanged: (value) {\n"
    "                                    setState(() {\n"
    "                                      selectedTradeType = value;\n"
    "                                    });\n"
    "                                  },\n"
    "                                ),\n"
    "                              ),\n"
    "                            ),\n"
)

def comment_block(block):
    """Wrap each line of block in // comment."""
    lines = block.split('\n')
    commented = []
    for line in lines:
        if line == '':
            commented.append('')
        else:
            commented.append('// ' + line)
    return '\n'.join(commented)

COMMENTED_DESKTOP = comment_block(TRADE_BLOCK_DESKTOP)
COMMENTED_MOBILE  = comment_block(TRADE_BLOCK_MOBILE)

for path in files:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    d_count = content.count(TRADE_BLOCK_DESKTOP)
    m_count = content.count(TRADE_BLOCK_MOBILE)

    content = content.replace(TRADE_BLOCK_DESKTOP, COMMENTED_DESKTOP)
    content = content.replace(TRADE_BLOCK_MOBILE,  COMMENTED_MOBILE)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

    name = path.split('/')[-2] + '/' + path.split('/')[-1]
    print(f'{name}: desktop={d_count} mobile={m_count} commented out')

print('\nDone. API trade fields untouched.')
