"""
Comment out Trade Type UI blocks using line-based approach.
Finds 'Trade Type *' text labels and comments out from the preceding SizedBox
through the closing Container ).
"""

files = [
    'C:/CLoudeRentalManager/302-property/lib/screens/Maintenance/Vendor/add_vendor.dart',
    'C:/CLoudeRentalManager/302-property/lib/screens/Maintenance/Vendor/edit_vendor.dart',
    'C:/CLoudeRentalManager/302-property/lib/StaffModule/screen/Maintenance/Vendor/add_vendor.dart',
    'C:/CLoudeRentalManager/302-property/lib/StaffModule/screen/Maintenance/Vendor/edit_vendor.dart',
]

def comment_trade_blocks(path):
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    result = []
    i = 0
    commented = 0
    while i < len(lines):
        line = lines[i]
        # Detect start of trade type block: line contains "Trade Type *" and not already commented
        if "Trade Type *" in line and not line.lstrip().startswith('//'):
            block_lines = []
            # Go back to include the preceding SizedBox(height: 10)
            # The previous line in result should be the SizedBox
            if result and 'const SizedBox(height: 10),' in result[-1] and not result[-1].lstrip().startswith('//'):
                block_lines.insert(0, result.pop())  # pull back the SizedBox

            # Collect lines until we close the Container (find the Container's closing `),`)
            # We need to track bracket depth starting from the Container( line
            # First add the Text('Trade Type *'...) and SizedBox(height:10) lines
            # Then find Container( and track until it closes
            block_lines.append(line)
            i += 1

            # Collect Text style lines (until we hit `const SizedBox(height: 10),`)
            while i < len(lines):
                block_lines.append(lines[i])
                if 'const SizedBox(height: 10),' in lines[i]:
                    i += 1
                    break
                i += 1

            # Now collect the Container block
            # Find the Container( line
            depth = 0
            in_container = False
            while i < len(lines):
                l = lines[i]
                block_lines.append(l)
                # Count opening and closing parens to track Container depth
                opens = l.count('(')
                closes = l.count(')')
                if not in_container:
                    if 'Container(' in l:
                        in_container = True
                        depth = opens - closes
                else:
                    depth += opens - closes
                    if depth <= 0:
                        i += 1
                        break
                i += 1

            # Comment out all collected lines
            for bl in block_lines:
                if bl.strip() == '':
                    result.append(bl)
                else:
                    indent = len(bl) - len(bl.lstrip())
                    result.append(' ' * indent + '// ' + bl.lstrip())
            commented += 1
        else:
            result.append(line)
            i += 1

    with open(path, 'w', encoding='utf-8') as f:
        f.writelines(result)

    name = '/'.join(path.split('/')[-2:])
    print(f'{name}: {commented} trade block(s) commented out')

for path in files:
    comment_trade_blocks(path)

print('\nVerifying trade: fields still present in API calls...')
import re
for path in files:
    with open(path, 'r', encoding='utf-8') as f:
        c = f.read()
    trade_ui = len([l for l in c.split('\n') if "Trade Type *" in l and not l.lstrip().startswith('//')])
    trade_api = len([l for l in c.split('\n') if "trade: selectedTradeType" in l and not l.lstrip().startswith('//')])
    name = '/'.join(path.split('/')[-2:])
    print(f'  {name}: UI visible={trade_ui} (should be 0), API calls={trade_api} (should be >0)')
