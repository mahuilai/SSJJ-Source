import subprocess, sys

out = subprocess.check_output(['tasklist', '/v', '/fo', 'table'])
try:
    text = out.decode('gbk')
except:
    text = out.decode('utf-8', errors='ignore')

for line in text.splitlines():
    if any(k in line.lower() for k in ['ssjj', '4399', 'battle', 'unity', 'flash', 'adl', 'cmd', 'python', 'server']):
        print(line)
