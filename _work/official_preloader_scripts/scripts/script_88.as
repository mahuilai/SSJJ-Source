include "wdnative/ptr2funInit.as";
include "wdnative/threadArbMutexLock.as";
include "wdnative/threadArbMutexUnlock.as";
include "wdnative/threadArbCondsNotify.as";
include "wdnative/threadArbCondWait.as";
include "wdnative/yield.as";
include "wdnative/newThread.as";
include "wdnative/ramInit.as";
include "wdnative/ramGetLength.as";
include "wdnative/ramAtomicCompareAndSwapLength.as";
include "wdnative/ramSetLength.as";
include "wdnative/sbrk.as";

§__force_ordering_ns_89674f80-1ed2-4d3e-b5a4-2c3091889351§;
if(!ptr2fun_init.length)
{
   ptr2fun_init[0] = function():void
   {
      throw new Error("null function pointer called");
   };
   ptr2fun_init.length = 1;
}

