import os

scripts_dir = r'd:\逆向\SSJJ双塔惊魂\_work\lobby_air\ffdec_out\scripts'
for root, dirs, files in os.walk(scripts_dir):
    for f in files:
        if f.endswith('.as'):
            p = os.path.join(root, f)
            with open(p, 'r', encoding='utf-8', errors='ignore') as fp:
                c = fp.read()
                if '"shop_avatar"' in c:
                    print('Match shop_avatar:', p)
