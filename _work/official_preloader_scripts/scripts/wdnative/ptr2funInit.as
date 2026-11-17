package wdnative
{
   public function ptr2funInit() : *
   {
      if(typeof ptr2fun != "undefined" && ptr2fun == null && wdnative.ptr2fun_init is Array)
      {
         var _temp_3:* = new Vector.<Function>();
         _temp_3.push.apply(null,wdnative.ptr2fun_init);
         wdnative.ptr2fun_init.length = 0;
         wdnative.ptr2fun_init = _temp_3;
      }
      return wdnative.ptr2fun_init;
   }
}

