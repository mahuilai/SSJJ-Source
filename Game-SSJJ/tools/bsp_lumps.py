import struct,sys
p=r"D:\逆向\SSJJ双塔惊魂\Game-SSJJ\Assets\Bundles\Map1\Data\model.bsp.raw.bytes"
d=open(p,'rb').read()
ident,ver=struct.unpack_from("<ii",d,0)
L=[struct.unpack_from("<ii",d,8+i*8) for i in range(19)]
print("ident=%08x ver=%d size=%d"%(ident,ver,len(d)))
for i,(o,l) in enumerate(L):
    print("lump[%2d] ofs=%9d len=%9d"%(i,o,l))
