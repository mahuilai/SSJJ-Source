# -*- coding: utf-8 -*-
"""把自编译的 Assembly-CSharp.dll 加密回注到原客户端。"""
import hashlib
import os
import shutil
import sys

MANAGED = r'D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\Managed'
REC = r'D:\逆向\SSJJ双塔惊魂\Game source\01_metadata\recovered'
NEW = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\SourceBuild\Assembly-CSharp-rebuild\bin\Debug\net48\Assembly-CSharp.dll'
OUT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\SourceBuild\encrypted'

ADD, XOR = 0x2A, 0x83  # Assembly-CSharp 的解密参数


def build_tables(add, xor):
    tables = []
    for prev in range(256):
        t = bytearray(256)
        for c in range(256):
            v = ((prev ^ ((c + 0x89) & 0xFFFFFFFF)) ^ 0x8D)
            v = (v + add) & 0xFFFFFFFF
            v ^= xor
            t[v & 0xFF] = c
        tables.append(bytes(t))
    return tables


def encrypt(plain, add, xor):
    tables = build_tables(add, xor)
    out = bytearray(plain)
    prev = plain[0]
    for i in range(1, len(plain)):
        c = tables[prev][plain[i]]
        out[i] = c
        prev = plain[i]
    return bytes(out)


def md5(b):
    return hashlib.md5(b).hexdigest()


def main():
    os.makedirs(OUT, exist_ok=True)

    # 0) sanity：算法自校验（用官方明文重新加密应与【原版密文备份】逐字节一致）
    orig_path = os.path.join(MANAGED, 'Assembly-CSharp.dll.orig.bak')
    if os.path.exists(orig_path):
        cipher0 = open(orig_path, 'rb').read()
    else:
        cipher0 = open(os.path.join(MANAGED, 'Assembly-CSharp.dll'), 'rb').read()
    plain0 = open(os.path.join(REC, 'Assembly-CSharp.decrypted.dll'), 'rb').read()
    ok = encrypt(plain0, ADD, XOR) == cipher0
    print('sanity encrypt(recovered)==original:', ok)
    if not ok:
        print('ABORT: algorithm mismatch')
        return 1

    # 1) 加密新 DLL
    new_plain = open(NEW, 'rb').read()
    new_cipher = encrypt(new_plain, ADD, XOR)
    out_path = os.path.join(OUT, 'Assembly-CSharp.dll')
    open(out_path, 'wb').write(new_cipher)
    print('new dll plain : %d bytes  md5=%s' % (len(new_plain), md5(new_plain)))
    print('new dll cipher: %d bytes  md5=%s' % (len(new_cipher), md5(new_cipher)))
    print('head check    :', new_cipher[:4].hex(), '(首字节应=4D)')

    # 2) 备份原文件
    bak = os.path.join(MANAGED, 'Assembly-CSharp.dll.orig.bak')
    if not os.path.exists(bak):
        shutil.copy2(os.path.join(MANAGED, 'Assembly-CSharp.dll'), bak)
        print('backup ->', bak)

    # 3) 覆盖
    shutil.copy2(out_path, os.path.join(MANAGED, 'Assembly-CSharp.dll'))
    verify = open(os.path.join(MANAGED, 'Assembly-CSharp.dll'), 'rb').read()
    print('deployed md5  :', md5(verify), 'match:', verify == new_cipher)
    return 0


if __name__ == '__main__':
    sys.exit(main())
