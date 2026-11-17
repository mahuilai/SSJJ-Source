package wdnative_nternal
{
   import wdnative.CModule;
   
   function modAllocSects() : Object
   {
      return {
         ".bss":[CModule.allocDataSect(wdnative_nternal.modPkgName,".bss",169244,8),169244],
         ".ctors":[CModule.allocDataSect(wdnative_nternal.modPkgName,".ctors",12,4),12],
         ".data":[CModule.allocDataSect(wdnative_nternal.modPkgName,".data",432,16),432],
         ".data.rel.local":[CModule.allocDataSect(wdnative_nternal.modPkgName,".data.rel.local",740,16),740],
         ".data.rel.ro.local":[CModule.allocDataSect(wdnative_nternal.modPkgName,".data.rel.ro.local",2596,16),2596],
         ".dtors":[CModule.allocDataSect(wdnative_nternal.modPkgName,".dtors",48,4),48],
         ".gcc_except_table":[CModule.allocDataSect(wdnative_nternal.modPkgName,".gcc_except_table",728,4),728],
         ".note.ABI-tag":[CModule.allocDataSect(wdnative_nternal.modPkgName,".note.ABI-tag",24,4),24],
         ".rodata":[CModule.allocDataSect(wdnative_nternal.modPkgName,".rodata",32762,16),32762],
         ".rodata.cst8":[CModule.allocDataSect(wdnative_nternal.modPkgName,".rodata.cst8",8,4),8],
         ".rodata.str1.1":[CModule.allocDataSect(wdnative_nternal.modPkgName,".rodata.str1.1",121,0),121],
         ".rodata.str1.16":[CModule.allocDataSect(wdnative_nternal.modPkgName,".rodata.str1.16",383,16),383],
         ".text":[CModule.allocTextSect(wdnative_nternal.modPkgName,".text",95257),95257]
      };
   }
}

