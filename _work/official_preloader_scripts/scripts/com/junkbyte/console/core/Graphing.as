package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.GraphGroup;
   import com.junkbyte.console.vos.GraphInterest;
   import flash.geom.Rectangle;
   import flash.system.System;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   public class Graphing extends ConsoleCore
   {
      
      private var _groups:Array = [];
      
      private var _map:Object = {};
      
      private var _fpsGroup:GraphGroup;
      
      private var _memGroup:GraphGroup;
      
      private var _hadGraph:Boolean;
      
      private var _previousTime:Number = -1;
      
      public function Graphing(param1:Console)
      {
         var m:Console = param1;
         super(m);
         remoter.registerCallback("fps",function(param1:ByteArray):void
         {
            fpsMonitor = param1.readBoolean();
         });
         remoter.registerCallback("mem",function(param1:ByteArray):void
         {
            memoryMonitor = param1.readBoolean();
         });
         remoter.registerCallback("removeGroup",function(param1:ByteArray):void
         {
            removeGroup(param1.readUTF());
         });
         remoter.registerCallback("graph",handleRemoteGraph,true);
      }
      
      public function add(param1:String, param2:Object, param3:String, param4:Number = -1, param5:String = null, param6:Rectangle = null, param7:Boolean = false) : void
      {
         var _loc9_:Boolean = false;
         if(param2 == null)
         {
            report("ERROR: Graph [" + param1 + "] received a null object to graph property [" + param3 + "].",10);
            return;
         }
         var _loc13_:GraphGroup = _map[param1];
         if(!_loc13_)
         {
            _loc9_ = true;
            _loc13_ = new GraphGroup(param1);
         }
         var _loc8_:Array = _loc13_.interests;
         if(isNaN(param4) || param4 < 0)
         {
            if(_loc8_.length <= 5)
            {
               param4 = Number(config.style["priority" + (10 - _loc8_.length * 2)]);
            }
            else
            {
               param4 = Math.random() * 16777215;
            }
         }
         if(param5 == null)
         {
            param5 = param3;
         }
         for each(var _loc10_:GraphInterest in _loc8_)
         {
            if(_loc10_.key == param5)
            {
               report("Graph with key [" + param5 + "] already exists in [" + param1 + "]",10);
               return;
            }
         }
         if(param6)
         {
            _loc13_.rect = param6;
         }
         if(param7)
         {
            _loc13_.inv = param7;
         }
         var _loc12_:GraphInterest = new GraphInterest(param5,param4);
         var _loc11_:Number = NaN;
         try
         {
            _loc11_ = _loc12_.setObject(param2,param3);
         }
         catch(e:Error)
         {
            report("Error with graph value for [" + param5 + "] in [" + param1 + "]. " + e,10);
            return;
         }
         if(isNaN(_loc11_))
         {
            report("Graph value for key [" + param5 + "] in [" + param1 + "] is not a number (NaN).",10);
         }
         else
         {
            _loc13_.interests.push(_loc12_);
            if(_loc9_)
            {
               _map[param1] = _loc13_;
               _groups.push(_loc13_);
            }
         }
      }
      
      public function fixRange(param1:String, param2:Number = NaN, param3:Number = NaN) : void
      {
         var _loc4_:GraphGroup = _map[param1];
         if(!_loc4_)
         {
            return;
         }
         _loc4_.low = param2;
         _loc4_.hi = param3;
         _loc4_.fixed = !(isNaN(param2) || isNaN(param3));
      }
      
      public function remove(param1:String, param2:Object = null, param3:String = null) : void
      {
         var _loc4_:Array = null;
         var _loc6_:int = 0;
         var _loc5_:GraphInterest = null;
         if(param2 == null && param3 == null)
         {
            removeGroup(param1);
         }
         else if(_map[param1])
         {
            _loc4_ = _map[param1].interests;
            _loc6_ = _loc4_.length - 1;
            while(_loc6_ >= 0)
            {
               _loc5_ = _loc4_[_loc6_];
               if((param2 == null || _loc5_.obj == param2) && (param3 == null || _loc5_.prop == param3))
               {
                  _loc4_.splice(_loc6_,1);
               }
               _loc6_--;
            }
            if(_loc4_.length == 0)
            {
               removeGroup(param1);
            }
         }
      }
      
      private function removeGroup(param1:String) : void
      {
         var _loc4_:ByteArray = null;
         var _loc2_:GraphGroup = null;
         var _loc3_:int = 0;
         if(remoter.remoting == 2)
         {
            _loc4_ = new ByteArray();
            _loc4_.writeUTF(param1);
            remoter.send("removeGroup",_loc4_);
         }
         else
         {
            _loc2_ = _map[param1];
            _loc3_ = _groups.indexOf(_loc2_);
            if(_loc3_ >= 0)
            {
               _groups.splice(_loc3_,1);
            }
            delete _map[param1];
         }
      }
      
      public function get fpsMonitor() : Boolean
      {
         if(remoter.remoting == 2)
         {
            return console.panels.fpsMonitor;
         }
         return _fpsGroup != null;
      }
      
      public function set fpsMonitor(param1:Boolean) : void
      {
         var _loc3_:ByteArray = null;
         var _loc2_:int = 0;
         if(remoter.remoting == 2)
         {
            _loc3_ = new ByteArray();
            _loc3_.writeBoolean(param1);
            remoter.send("fps",_loc3_);
         }
         else if(param1 != fpsMonitor)
         {
            if(param1)
            {
               _fpsGroup = addSpecialGroup(1);
               _fpsGroup.low = 0;
               _fpsGroup.fixed = true;
               _fpsGroup.averaging = 30;
            }
            else
            {
               _previousTime = -1;
               _loc2_ = _groups.indexOf(_fpsGroup);
               if(_loc2_ >= 0)
               {
                  _groups.splice(_loc2_,1);
               }
               _fpsGroup = null;
            }
            console.panels.mainPanel.updateMenu();
         }
      }
      
      public function get memoryMonitor() : Boolean
      {
         if(remoter.remoting == 2)
         {
            return console.panels.memoryMonitor;
         }
         return _memGroup != null;
      }
      
      public function set memoryMonitor(param1:Boolean) : void
      {
         var _loc3_:ByteArray = null;
         var _loc2_:int = 0;
         if(remoter.remoting == 2)
         {
            _loc3_ = new ByteArray();
            _loc3_.writeBoolean(param1);
            remoter.send("mem",_loc3_);
         }
         else if(param1 != memoryMonitor)
         {
            if(param1)
            {
               _memGroup = addSpecialGroup(2);
               _memGroup.freq = 20;
            }
            else
            {
               _loc2_ = _groups.indexOf(_memGroup);
               if(_loc2_ >= 0)
               {
                  _groups.splice(_loc2_,1);
               }
               _memGroup = null;
            }
            console.panels.mainPanel.updateMenu();
         }
      }
      
      private function addSpecialGroup(param1:int) : GraphGroup
      {
         var _loc3_:GraphGroup = new GraphGroup("special");
         _loc3_.type = param1;
         _groups.push(_loc3_);
         var _loc2_:GraphInterest = new GraphInterest("special");
         if(param1 == 1)
         {
            _loc2_.col = 16724787;
         }
         else
         {
            _loc2_.col = 5267711;
         }
         _loc3_.interests.push(_loc2_);
         return _loc3_;
      }
      
      public function update(param1:Number = 0) : Array
      {
         var _loc10_:GraphInterest = null;
         var _loc7_:Number = NaN;
         var _loc11_:Boolean = false;
         var _loc12_:* = 0;
         var _loc9_:* = 0;
         var _loc2_:Array = null;
         var _loc8_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:* = 0;
         var _loc6_:ByteArray = null;
         var _loc5_:* = 0;
         for each(var _loc13_:GraphGroup in _groups)
         {
            _loc11_ = true;
            if(_loc13_.freq > 1)
            {
               _loc13_.idle++;
               if(_loc13_.idle < _loc13_.freq)
               {
                  _loc11_ = false;
               }
               else
               {
                  _loc13_.idle = 0;
               }
            }
            if(_loc11_)
            {
               _loc12_ = _loc13_.type;
               _loc9_ = _loc13_.averaging;
               _loc2_ = _loc13_.interests;
               if(_loc12_ == 1)
               {
                  _loc13_.hi = param1;
                  _loc10_ = _loc2_[0];
                  _loc8_ = getTimer();
                  if(_previousTime >= 0)
                  {
                     _loc3_ = _loc8_ - _previousTime;
                     _loc7_ = 1000 / _loc3_;
                     _loc10_.setValue(_loc7_,_loc9_);
                  }
                  _previousTime = _loc8_;
               }
               else if(_loc12_ == 2)
               {
                  _loc10_ = _loc2_[0];
                  _loc7_ = Math.round(System.totalMemory / 10485.76) / 100;
                  _loc13_.updateMinMax(_loc7_);
                  _loc10_.setValue(_loc7_,_loc9_);
               }
               else
               {
                  updateExternalGraphGroup(_loc13_);
               }
            }
         }
         if(remoter.canSend && (_hadGraph || _groups.length))
         {
            _loc4_ = _groups.length;
            _loc6_ = new ByteArray();
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               GraphGroup(_groups[_loc5_]).toBytes(_loc6_);
               _loc5_++;
            }
            remoter.send("graph",_loc6_);
            _hadGraph = _groups.length > 0;
         }
         return _groups;
      }
      
      private function updateExternalGraphGroup(param1:GraphGroup) : void
      {
         var _loc2_:Number = NaN;
         for each(var _loc3_:GraphInterest in param1.interests)
         {
            try
            {
               _loc2_ = _loc3_.getCurrentValue();
               _loc3_.setValue(_loc2_,param1.averaging);
            }
            catch(e:Error)
            {
               report("Error with graph value for key [" + _loc3_.key + "] in [" + param1.name + "]. " + e,10);
               remove(param1.name,_loc3_.obj,_loc3_.prop);
            }
            param1.updateMinMax(_loc2_);
         }
      }
      
      private function handleRemoteGraph(param1:ByteArray = null) : void
      {
         var _loc2_:Array = null;
         if(param1 && param1.length)
         {
            param1.position = 0;
            _loc2_ = [];
            while(param1.bytesAvailable)
            {
               _loc2_.push(GraphGroup.FromBytes(param1));
            }
            console.panels.updateGraphs(_loc2_);
         }
         else
         {
            console.panels.updateGraphs([]);
         }
      }
   }
}

