package org.as3commons.logging.setup.target
{
   import org.as3commons.logging.setup.ILogTarget;
   import org.as3commons.logging.util.flatten;
   import org.as3commons.logging.util.removeDuplicates;
   
   public function mergeTargets(... rest) : ILogTarget
   {
      var _loc2_:ILogTarget = null;
      var _loc3_:* = 0;
      var _loc4_:MergedTarget = null;
      var _loc5_:ILogTarget = null;
      flatten(rest);
      _loc3_ = int(rest.length - 1);
      while(_loc3_ >= 0)
      {
         _loc4_ = rest[_loc3_] as MergedTarget;
         if(_loc4_)
         {
            rest.splice(_loc3_,1);
            _loc4_.insertTargets(rest,_loc3_);
         }
         _loc3_--;
      }
      removeDuplicates(rest);
      _loc3_ = int(rest.length - 1);
      while(_loc3_ >= 0)
      {
         _loc5_ = rest[_loc3_] as ILogTarget;
         if(_loc5_)
         {
            if(_loc2_)
            {
               _loc2_ = new MergedTarget(_loc5_,_loc2_);
            }
            else
            {
               _loc2_ = _loc5_;
            }
         }
         _loc3_--;
      }
      return _loc2_;
   }
}

