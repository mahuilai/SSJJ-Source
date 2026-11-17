package org.as3commons.logging.setup.log4j
{
   import Log4JStyleSetup.as$66.log4j;
   import org.as3commons.logging.setup.HierarchicalSetup;
   import org.as3commons.logging.setup.LogSetupLevel;
   
   use namespace log4j;
   
   public final class Log4JStyleSetup
   {
      
      private const _root:HierarchyEntry = new HierarchyEntry("");
      
      private var _threshold:LogSetupLevel;
      
      public const appender:Appenders = new Appenders();
      
      public const logger:LevelSetup = new LevelSetup(this._root);
      
      public const additivity:AdditivitySetup = new AdditivitySetup(this._root);
      
      public function Log4JStyleSetup()
      {
         super();
      }
      
      public function set rootLogger(param1:String) : void
      {
         parseValue(this._root,param1);
      }
      
      public function set threshold(param1:String) : void
      {
         this._threshold = getLevel(param1);
      }
      
      public function compile() : HierarchicalSetup
      {
         var _loc1_:HierarchicalSetup = new HierarchicalSetup(".",this._threshold);
         this._root.applyTo(_loc1_,this.appender.generateAppenders());
         return _loc1_;
      }
   }
}

import Log4JStyleSetup.as$66.log4j;
import flash.utils.Proxy;
import flash.utils.flash_proxy;
import flash.utils.getDefinitionByName;
import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;
import org.as3commons.logging.setup.HierarchicalSetup;
import org.as3commons.logging.setup.ILogTarget;
import org.as3commons.logging.setup.LogSetupLevel;
import org.as3commons.logging.setup.target.mergeTargets;
import org.as3commons.logging.util.instantiate;

use namespace log4j;
use namespace flash_proxy;

dynamic class Appenders extends Proxy
{
   
   log4j var _appenders:Object = {};
   
   public function Appenders()
   {
      super();
   }
   
   override flash_proxy function getProperty(param1:*) : *
   {
      var _loc2_:String = param1;
      return this.log4j::_appenders[_loc2_] = this.log4j::_appenders[_loc2_] || new AppenderGenerator(_loc2_);
   }
   
   override flash_proxy function setProperty(param1:*, param2:*) : void
   {
      (this.flash_proxy::getProperty(param1) as AppenderGenerator).log4j::_value = param2;
   }
   
   log4j function generateAppenders() : Object
   {
      var _loc2_:String = null;
      var _loc3_:ILogTarget = null;
      var _loc1_:Object = {};
      for(_loc2_ in this.log4j::_appenders)
      {
         _loc3_ = AppenderGenerator(this.log4j::_appenders[_loc2_]).getAppender();
         _loc1_[_loc2_] = _loc3_;
      }
      return _loc1_;
   }
}

dynamic class PropertyContainer extends Proxy
{
   
   log4j var _properties:Object = {};
   
   log4j var _name:String;
   
   log4j var _value:*;
   
   public function PropertyContainer(param1:String)
   {
      super();
      this.log4j::_name = param1;
   }
   
   log4j function applyProperty(param1:*, param2:Array) : void
   {
      var value:Object = null;
      var child:String = null;
      var instance:* = param1;
      var stack:Array = param2;
      try
      {
         if(this.log4j::_value === undefined)
         {
            value = instance[this.log4j::_name];
         }
         else
         {
            value = this.log4j::_value;
            instance[this.log4j::_name] = this.log4j::_value;
         }
      }
      catch(e:Error)
      {
         if(LOGGER.warnEnabled)
         {
            LOGGER.warn("Can not access property \'{1}\' of appender \'{0}\': {2}",[stack[0],stack.slice(1,stack.length).concat(log4j::_name).join("."),e]);
         }
         return;
      }
      if(value)
      {
         stack.push(this.log4j::_name);
         for(child in this.log4j::_properties)
         {
            if(child != "Threshold" || stack.length != 0)
            {
               (this.log4j::_properties[child] as PropertyContainer).applyProperty(value,stack);
            }
         }
         stack.pop();
      }
      else
      {
         var _loc4_:int = 0;
         var _loc5_:* = this.log4j::_properties;
         for(child in _loc5_)
         {
            if(LOGGER.warnEnabled)
            {
               LOGGER.warn("Can not set child properties for \'{1}\' of appender \'{0}\' as its \'null\'",[stack[0],stack.slice(1,stack.length).concat(this.log4j::_name).join(".")]);
            }
         }
      }
   }
   
   override flash_proxy function getProperty(param1:*) : *
   {
      var _loc2_:String = param1;
      return this.log4j::_properties[_loc2_] = this.log4j::_properties[_loc2_] || new PropertyContainer(param1);
   }
   
   override flash_proxy function setProperty(param1:*, param2:*) : void
   {
      (this.flash_proxy::getProperty(param1) as PropertyContainer)._value = param2;
   }
}

dynamic class AppenderGenerator extends PropertyContainer
{
   
   public function AppenderGenerator(param1:String)
   {
      super(param1);
   }
   
   log4j function getAppender() : ILogTarget
   {
      var target:ILogTarget = null;
      var cls:* = undefined;
      var stack:Array = null;
      var name:String = null;
      if(log4j::_value is ILogTarget)
      {
         target = log4j::_value;
      }
      else if(log4j::_value is String)
      {
         try
         {
            cls = getDefinitionByName(log4j::_value);
         }
         catch(e:Error)
         {
         }
         if(cls)
         {
            try
            {
               target = ILogTarget(instantiate(cls));
            }
            catch(e:Error)
            {
               if(LOGGER.warnEnabled)
               {
                  LOGGER.warn("Appender \'{0}\' could not be instantiated as \'{1}\' due to error \'{2}\'",[log4j::_name,log4j::_value,e]);
               }
            }
         }
         else if(LOGGER.warnEnabled)
         {
            LOGGER.warn("Appender \'{0}\' can not be instantiated from class \'{1}\' because the class wasn\'t available at runtime.",[log4j::_name,log4j::_value]);
         }
      }
      else if(LOGGER.warnEnabled)
      {
         LOGGER.warn("Appender \'{0}\' could not be used as its no ILogTarget implementation or class name! Defined as: {1}",[log4j::_name,log4j::_value]);
      }
      if(target)
      {
         for(name in log4j::_properties)
         {
            (log4j::_properties[name] as PropertyContainer).applyProperty(target,stack = stack || [log4j::_name]);
         }
      }
      return target;
   }
}

dynamic class LevelSetup extends Proxy
{
   
   log4j var _children:Object = {};
   
   log4j var _entry:HierarchyEntry;
   
   public function LevelSetup(param1:HierarchyEntry)
   {
      super();
      this.log4j::_entry = param1;
   }
   
   override flash_proxy function getProperty(param1:*) : *
   {
      var _loc2_:String = param1;
      return this.log4j::_children[_loc2_] = this.log4j::_children[_loc2_] || new LevelSetup(this.log4j::_entry.child(_loc2_));
   }
   
   override flash_proxy function setProperty(param1:*, param2:*) : void
   {
      parseValue(this.log4j::_entry.child(param1),param2);
   }
}

dynamic class AdditivitySetup extends Proxy
{
   
   internal var _children:Object = {};
   
   internal var _entry:HierarchyEntry;
   
   public function AdditivitySetup(param1:HierarchyEntry)
   {
      super();
      this._entry = param1;
   }
   
   override flash_proxy function getProperty(param1:*) : *
   {
      var _loc2_:String = param1;
      return this._children[_loc2_] = this._children[_loc2_] || new AdditivitySetup(this._entry.child(_loc2_));
   }
   
   override flash_proxy function setProperty(param1:*, param2:*) : void
   {
      var _loc3_:String = param2;
      this._entry.child(param1)._additive = _loc3_.toUpperCase() == "TRUE";
   }
}

class HierarchyEntry
{
   
   internal var _appenders:Array = [];
   
   internal var _level:LogSetupLevel;
   
   internal var _additive:Boolean = true;
   
   internal var _name:String;
   
   internal var _children:Object = new Object();
   
   public function HierarchyEntry(param1:String)
   {
      super();
      this._name = param1;
      this._level = LogSetupLevel.NONE;
   }
   
   public function child(param1:String) : HierarchyEntry
   {
      return this._children[param1] = this._children[param1] || new HierarchyEntry(this._name == "" ? param1 : this._name + "." + param1);
   }
   
   public function applyTo(param1:HierarchicalSetup, param2:Object) : void
   {
      var _loc3_:ILogTarget = null;
      var _loc4_:String = null;
      var _loc5_:HierarchyEntry = null;
      for each(_loc4_ in this._appenders)
      {
         _loc3_ = mergeTargets(_loc3_,param2[_loc4_]);
      }
      param1.setHierarchy(this._name,_loc3_,this._level,this._additive);
      for each(_loc5_ in this._children)
      {
         _loc5_.applyTo(param1,param2);
      }
   }
}

namespace log4j;

function parseValue(param1:HierarchyEntry, param2:String):HierarchyEntry
{
   var _loc6_:String = null;
   var _loc3_:Array = param2.split(",");
   var _loc4_:String = trim(_loc3_.shift());
   var _loc5_:int = int(_loc3_.length);
   while(--_loc5_ - -1)
   {
      _loc6_ = trim(_loc3_[_loc5_]);
      if(_loc6_.length > 0)
      {
         _loc3_[_loc5_] = unesc(_loc6_);
      }
      else
      {
         _loc3_.splice(_loc5_,1);
      }
   }
   param1._level = getLevel(_loc4_);
   param1._appenders = _loc3_.length > 0 ? _loc3_ : null;
   return param1;
}
function unesc(param1:String):String
{
   return param1.replace(/\\([\\tnrb])/g,encodingReplace);
}
function encodingReplace(... rest):String
{
   return tags[rest[1]];
}
function getLevel(param1:String):LogSetupLevel
{
   param1 = param1.toUpperCase();
   var _loc2_:LogSetupLevel = null;
   if(param1 == "DEBUG")
   {
      _loc2_ = LogSetupLevel.DEBUG;
   }
   else if(param1 == "INFO")
   {
      _loc2_ = LogSetupLevel.INFO;
   }
   else if(param1 == "WARN")
   {
      _loc2_ = LogSetupLevel.WARN;
   }
   else if(param1 == "ERROR")
   {
      _loc2_ = LogSetupLevel.ERROR;
   }
   else if(param1 == "FATAL")
   {
      _loc2_ = LogSetupLevel.FATAL;
   }
   else if(param1 == "NONE")
   {
      _loc2_ = LogSetupLevel.NONE;
   }
   else if(param1 == "ALL")
   {
      _loc2_ = LogSetupLevel.ALL;
   }
   return _loc2_;
}
function trim(param1:String):String
{
   return param1.replace(/^\s*/,"").replace(/\s*$/,"");
}
const LOGGER:ILogger = getLogger(Log4JStyleSetup);

const tags:Object = {
   "t":"\t",
   "n":"\n",
   "r":"\r",
   "\\":"\\",
   "b":"\b"
};

