import os

target_file = r'_work\lobby_air\smallbomb_asmfix\Lobby-0\lobby_\view\ApplicationMediator.class.asasm'
with open(target_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Backup
with open(target_file + '.bak', 'w', encoding='utf-8') as f:
    f.writelines(lines)

# Find disposeContext3D
# line 2402: trait method QName(PrivateNamespace( lobby.view:ApplicationMediator), disposeContext3D)
# line 2412: code
# line 2433: end ; code

start_idx = None
end_idx = None
for idx, line in enumerate(lines):
    if 'trait method QName(PrivateNamespace(lobby.view:ApplicationMediator), disposeContext3D)' in line:
        start_idx = idx
        break

assert start_idx is not None, 'disposeContext3D not found'

code_start = None
code_end = None
for idx in range(start_idx, start_idx + 40):
    if lines[idx].strip() == 'code':
        code_start = idx
    if lines[idx].strip() == 'end ; code':
        code_end = idx
        break

assert code_start is not None and code_end is not None, 'code block not found'
print(f'code block: {code_start} to {code_end}')

# Replace body with returnvoid
new_lines = lines[:code_start+1] + ['      returnvoid\n'] + lines[code_end:]

# Now find call site:
call_idx = None
for idx, line in enumerate(new_lines):
    if 'findpropstrict' in line and 'disposeContext3D' in line:
        call_idx = idx
        break

assert call_idx is not None, 'call site not found'
print(f'call site at {call_idx}: {new_lines[call_idx].strip()} and {new_lines[call_idx+1].strip()}')
assert 'callpropvoid' in new_lines[call_idx+1] and 'disposeContext3D' in new_lines[call_idx+1]

new_lines[call_idx] = '      nop\n'
new_lines[call_idx+1] = '      nop\n'

with open(target_file, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print('Successfully patched asasm!')
