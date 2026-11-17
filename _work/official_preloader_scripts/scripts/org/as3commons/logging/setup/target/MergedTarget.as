package org.as3commons.logging.setup.target
{
   import org.as3commons.logging.setup.ILogTarget;
   
   public final class MergedTarget implements ILogTarget
   {
      
      private var _logTargetA:ILogTarget;
      
      private var _logTargetB:ILogTarget;
      
      private var _mergedTarget:MergedTarget;
      
      public function MergedTarget(param1:ILogTarget, param2:ILogTarget)
      {
         super();
         this._logTargetA = param1;
         this._logTargetB = param2;
         this._mergedTarget = param2 as MergedTarget;
      }
      
      public function log(param1:String, param2:String, param3:int, param4:Number, param5:*, param6:Array, param7:String) : void
      {
         this._logTargetA.log(param1,param2,param3,param4,param5,param6,param7);
         var _loc8_:MergedTarget = this;
         while(_loc8_._mergedTarget)
         {
            _loc8_ = _loc8_._mergedTarget;
            _loc8_._logTargetA.log(param1,param2,param3,param4,param5,param6,param7);
         }
         _loc8_._logTargetB.log(param1,param2,param3,param4,param5,param6,param7);
      }
      
      internal function insertTargets(param1:Array, param2:int) : void
      {
         param1.splice(param2,0,this._logTargetA,this._logTargetB);
         var _loc3_:MergedTarget = this;
         while(_loc3_._mergedTarget)
         {
            param2++;
            _loc3_ = _loc3_._mergedTarget;
            param1.splice(param2,0,this._logTargetA);
         }
      }
   }
}

