package org.as3commons.logging.setup
{
   import org.as3commons.logging.api.ILogSetup;
   import org.as3commons.logging.api.Logger;
   
   public final class HierarchicalSetup implements ILogSetup
   {
      
      private var _threshold:LogSetupLevel = LogSetupLevel.ALL;
      
      private var _root:HierarchyData = new HierarchyData();
      
      private var _separator:String;
      
      public function HierarchicalSetup(param1:String = ".", param2:LogSetupLevel = null)
      {
         super();
         this._separator = param1;
         this._threshold = param2 || LogSetupLevel.ALL;
      }
      
      public function set threshold(param1:LogSetupLevel) : void
      {
         this._threshold = param1;
         this._root.dirty = true;
      }
      
      public function setHierarchy(param1:String = null, param2:ILogTarget = null, param3:LogSetupLevel = null, param4:Boolean = true) : void
      {
         var _loc7_:String = null;
         var _loc8_:HierarchyData = null;
         var _loc5_:Array = Boolean(param1) && param1 != "" ? param1.split(this._separator) : null;
         var _loc6_:HierarchyData = this._root;
         if(_loc5_)
         {
            while(_loc5_.length > 0)
            {
               _loc7_ = _loc5_.shift();
               _loc8_ = _loc6_.children[_loc7_];
               if(!_loc8_)
               {
                  _loc6_.children[_loc7_] = _loc8_ = new HierarchyData();
                  _loc6_.dirty = true;
               }
               _loc6_ = _loc8_;
            }
         }
         _loc6_.target = param2;
         _loc6_.level = param3;
         _loc6_.additive = param4;
         _loc6_.dirty = true;
      }
      
      public function applyTo(param1:Logger) : void
      {
         var _loc2_:Array = param1.name == "" ? null : param1.name.split(this._separator);
         this._root.applyConfigTo(param1,_loc2_,LogSetupLevel.ALL,null,this._threshold);
      }
   }
}

import org.as3commons.logging.api.Logger;
import org.as3commons.logging.setup.ILogTarget;
import org.as3commons.logging.setup.LogSetupLevel;
import org.as3commons.logging.setup.target.mergeTargets;

class HierarchyData
{
   
   internal var children:Object = {};
   
   internal var level:LogSetupLevel = null;
   
   internal var target:ILogTarget;
   
   internal var additive:Boolean = true;
   
   private var _dirty:Boolean = true;
   
   private var _target:ILogTarget;
   
   private var _level:LogSetupLevel;
   
   public function HierarchyData()
   {
      super();
   }
   
   internal function set dirty(param1:Boolean) : void
   {
      var _loc2_:HierarchyData = null;
      if(this._dirty != param1)
      {
         this._dirty = param1;
         for each(_loc2_ in this.children)
         {
            _loc2_.dirty = true;
         }
      }
   }
   
   internal function applyConfigTo(param1:Logger, param2:Array, param3:LogSetupLevel, param4:ILogTarget, param5:LogSetupLevel) : void
   {
      var _loc6_:HierarchyData = null;
      if(this._dirty)
      {
         if(Boolean(this.additive) && Boolean(param4))
         {
            this._target = mergeTargets(param4,this.target);
         }
         else
         {
            this._target = this.target;
         }
         this._level = LogSetupLevel.getLevelByValue((this.level || param3).valueOf() & param5.valueOf());
         this._dirty = false;
      }
      if(Boolean(param2) && (Boolean(_loc6_ = this.children[param2[0]] as HierarchyData)))
      {
         param2.shift();
         _loc6_.applyConfigTo(param1,param2,this._level,this._target,param5);
      }
      else
      {
         this._level.applyTo(param1,this._target);
      }
   }
}
