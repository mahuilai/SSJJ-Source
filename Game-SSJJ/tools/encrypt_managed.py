"""SSJJ 托管程序集加密的逆变换（用于把自编译 DLL 塞回原客户端）

正向（mono 解密）：
    p[i] = ((((p[i-1] ^ (c[i] + 0x89)) ^ 0x8D) + ADD) ^ XOR) & 0xFF
其中 p[0] 不变（'M'）。

逆变换没有闭式解，但 c -> p 是双射，且只依赖 p[i-1]，
所以对每个可能的 p[i-1] 预生成 256 字节的反查表，加密就是 O(n)。
"""
import hashlib
import os
import sys

MANAGED = r'D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\Managed'
REC = r'D:\逆向\SSJJ双塔惊魂\Game source\01_metadata\recovered'
OUT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\SourceBuild\encrypted'

RECIPES = {
    'Assembly-CSharp.dll': (0x2A, 0x83),
    'Magic.dll': (0x3A, 0x93),
}


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


def main():
    os.makedirs(OUT, exist_ok=True)
    print('PLAINTEXT'.ljust(24), 'MATCH', 'MD5(cipher)')
    for name, (add, xor) in RECIPES.items():
        cipher_path = os.path.join(MANAGED, name)
        plain_path = os.path.join(REC, name.replace('.dll', '.decrypted.dll'))
        if not (os.path.exists(cipher_path) and os.path.exists(plain_path)):
            print('skip', name)
            continue
        cipher = open(cipher_path, 'rb').read()
        plain = open(plain_path, 'rb').read()
        enc = encrypt(plain, add, xor)
        same = enc == cipher
        print(name.ljust(24), same, hashlib.md5(enc).hexdigest(), 'vs', hashlib.md5(cipher).hexdigest())
        if not same:
            diff = sum(1 for a, b in zip(enc, cipher) if a != b)
            print('  diff bytes:', diff, '/', len(cipher))
        open(os.path.join(OUT, name), 'wb').write(enc)
    return 0


if __name__ == '__main__':
    sys.exit(main())
