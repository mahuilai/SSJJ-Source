"""Build an encrypted, non-deployed Assembly-CSharp candidate.

This deliberately never writes to the installed game's Managed directory.
"""
import hashlib
import os
import sys

ROOT = r'D:\逆向\SSJJ双塔惊魂'
MANAGED = r'D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\Managed'
REC = os.path.join(ROOT, 'Game source', '01_metadata', 'recovered')
BUILD = os.path.join(ROOT, 'Game-SSJJ', 'SourceBuild', 'Assembly-CSharp-rebuild', 'bin', 'Debug', 'net48', 'Assembly-CSharp.dll')
OUT = os.path.join(ROOT, 'Game-SSJJ', 'SourceBuild', 'encrypted', 'Assembly-CSharp-offline-native-engine-candidate.dll')
ADD, XOR = 0x2A, 0x83


def build_tables():
    tables = []
    for prev in range(256):
        table = bytearray(256)
        for cipher_byte in range(256):
            value = ((prev ^ ((cipher_byte + 0x89) & 0xFFFFFFFF)) ^ 0x8D)
            value = (value + ADD) & 0xFFFFFFFF
            value ^= XOR
            table[value & 0xFF] = cipher_byte
        tables.append(bytes(table))
    return tables


def encrypt(plain, tables):
    result = bytearray(plain)
    prev = plain[0]
    for i in range(1, len(plain)):
        result[i] = tables[prev][plain[i]]
        prev = plain[i]
    return bytes(result)


def decrypt(cipher):
    result = bytearray(cipher)
    prev = result[0]
    for i in range(1, len(cipher)):
        value = ((prev ^ ((cipher[i] + 0x89) & 0xFFFFFFFF)) ^ 0x8D)
        value = (value + ADD) & 0xFFFFFFFF
        value ^= XOR
        result[i] = value & 0xFF
        prev = result[i]
    return bytes(result)


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def main():
    baseline_plain_path = os.path.join(REC, 'Assembly-CSharp.decrypted.dll')
    baseline_cipher_path = os.path.join(MANAGED, 'Assembly-CSharp.dll.orig.bak')
    for path in (BUILD, baseline_plain_path, baseline_cipher_path):
        if not os.path.isfile(path):
            raise FileNotFoundError(path)

    tables = build_tables()
    baseline_plain = open(baseline_plain_path, 'rb').read()
    baseline_cipher = open(baseline_cipher_path, 'rb').read()
    if encrypt(baseline_plain, tables) != baseline_cipher:
        raise RuntimeError('original assembly encryption sanity check failed')

    plain = open(BUILD, 'rb').read()
    cipher = encrypt(plain, tables)
    if decrypt(cipher) != plain:
        raise RuntimeError('candidate round-trip check failed')
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, 'wb') as f:
        f.write(cipher)
    print('candidate:', OUT)
    print('bytes:', len(cipher))
    print('plain_sha256:', sha256(plain))
    print('cipher_sha256:', sha256(cipher))
    print('original_baseline: exact match')
    print('candidate_roundtrip: exact match')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as exc:
        print('ERROR:', exc, file=sys.stderr)
        sys.exit(1)
