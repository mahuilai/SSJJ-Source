package org.as3commons.logging.util
{
   public final class LogMessageFormatter
   {
      
      private const STATIC_TYPE:int = 1;
      
      private const MESSAGE_TYPE:int = 2;
      
      private const MESSAGE_DQT_TYPE:int = 3;
      
      private const TIME_TYPE:int = 4;
      
      private const TIME_UTC_TYPE:int = 5;
      
      private const LOG_TIME_TYPE:int = 6;
      
      private const DATE_TYPE:int = 7;
      
      private const DATE_UTC_TYPE:int = 8;
      
      private const LOG_LEVEL_TYPE:int = 9;
      
      private const SWF_TYPE:int = 10;
      
      private const SHORT_SWF_TYPE:int = 11;
      
      private const NAME_TYPE:int = 12;
      
      private const SHORT_NAME_TYPE:int = 13;
      
      private const GMT_OFFSET_TYPE:int = 14;
      
      private const PERSON_TYPE:int = 15;
      
      private const AT_PERSON_TYPE:int = 16;
      
      private const TYPES:Object = {
         "message":this.MESSAGE_TYPE,
         "message_dqt":this.MESSAGE_DQT_TYPE,
         "time":this.TIME_TYPE,
         "timeUTC":this.TIME_UTC_TYPE,
         "logTime":this.LOG_TIME_TYPE,
         "date":this.DATE_TYPE,
         "dateUTC":this.DATE_UTC_TYPE,
         "logLevel":this.LOG_LEVEL_TYPE,
         "swf":this.SWF_TYPE,
         "shortSWF":this.SHORT_SWF_TYPE,
         "name":this.NAME_TYPE,
         "shortName":this.SHORT_NAME_TYPE,
         "gmt":this.GMT_OFFSET_TYPE,
         "person":this.PERSON_TYPE,
         "atPerson":this.AT_PERSON_TYPE
      };
      
      private const _now:Date = new Date();
      
      private const _braceRegexp:RegExp = /{(?P<field>[a-zA-Z_]+)}/g;
      
      private var _firstNode:FormatNode;
      
      private var _hasMessageNode:Boolean = false;
      
      private var _hasTimeNode:Boolean = false;
      
      public function LogMessageFormatter(param1:String)
      {
         var _loc3_:Object = null;
         var _loc4_:FormatNode = null;
         var _loc5_:FormatNode = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:FormatNode = null;
         super();
         var _loc2_:int = 0;
         while(true)
         {
            _loc3_ = this._braceRegexp.exec(param1);
            if(!_loc3_)
            {
               break;
            }
            _loc7_ = int(this.TYPES[_loc3_["field"]]);
            if(_loc7_)
            {
               if(_loc2_ != _loc3_["index"])
               {
                  _loc6_ = param1.substring(_loc2_,_loc3_["index"]);
                  _loc5_ = new FormatNode();
                  _loc5_.type = this.STATIC_TYPE;
                  _loc5_.content = _loc6_;
                  if(_loc4_)
                  {
                     _loc4_.next = _loc5_;
                  }
                  else
                  {
                     this._firstNode = _loc5_;
                  }
                  _loc4_ = _loc5_;
               }
               _loc8_ = new FormatNode();
               _loc8_.type = _loc7_;
               if(_loc7_ == this.MESSAGE_TYPE || _loc7_ == this.MESSAGE_DQT_TYPE)
               {
                  this._hasMessageNode = true;
               }
               else if(_loc7_ == this.TIME_TYPE || _loc7_ == this.TIME_UTC_TYPE || _loc7_ == this.DATE_TYPE || _loc7_ == this.DATE_UTC_TYPE || _loc7_ == this.LOG_TIME_TYPE)
               {
                  this._hasTimeNode = true;
               }
               _loc2_ = _loc3_["index"] + _loc3_[0]["length"];
               if(_loc4_)
               {
                  _loc4_.next = _loc8_;
               }
               else
               {
                  this._firstNode = _loc8_;
               }
               _loc4_ = _loc8_;
            }
         }
         if(_loc2_ != param1.length)
         {
            _loc6_ = param1.substring(_loc2_);
            _loc5_ = new FormatNode();
            _loc5_.type = this.STATIC_TYPE;
            _loc5_.content = _loc6_;
            if(_loc4_)
            {
               _loc4_.next = _loc5_;
            }
            else
            {
               this._firstNode = _loc5_;
            }
         }
      }
      
      public function format(param1:String, param2:String, param3:int, param4:Number, param5:String, param6:Array, param7:String) : String
      {
         var _loc10_:int = 0;
         var _loc11_:* = 0;
         var _loc12_:* = undefined;
         var _loc13_:int = 0;
         var _loc14_:String = null;
         var _loc15_:String = null;
         var _loc16_:String = null;
         var _loc17_:String = null;
         var _loc8_:String = "";
         var _loc9_:FormatNode = this._firstNode;
         if(Boolean(this._hasMessageNode) && Boolean(param5) && Boolean(param6))
         {
            _loc10_ = int(param6.length);
            _loc11_ = 0;
            while(_loc11_ < _loc10_)
            {
               _loc12_ = param6[_loc11_];
               param5 = param5.split("{" + _loc11_ + "}").join(_loc12_);
               _loc11_++;
            }
         }
         if(this._hasTimeNode)
         {
            this._now.time = isNaN(param4) ? 0 : START_TIME + param4;
         }
         while(_loc9_)
         {
            _loc13_ = _loc9_.type;
            if(_loc13_ < 7)
            {
               if(_loc13_ < 4)
               {
                  if(_loc13_ == this.STATIC_TYPE)
                  {
                     _loc8_ += _loc9_.content;
                  }
                  else if(_loc13_ == this.MESSAGE_TYPE)
                  {
                     _loc8_ += param5;
                  }
                  else if(param5)
                  {
                     _loc8_ += param5.split("\"").join("\\\"").split("\n").join("\\n");
                  }
                  else
                  {
                     _loc8_ += param5;
                  }
               }
               else if(_loc13_ == this.TIME_TYPE)
               {
                  _loc8_ += this._now.hours + ":" + this._now.minutes + ":" + this._now.seconds + "." + this._now.milliseconds;
               }
               else if(_loc13_ == this.TIME_UTC_TYPE)
               {
                  _loc8_ += this._now.hoursUTC + ":" + this._now.minutesUTC + ":" + this._now.secondsUTC + "." + this._now.millisecondsUTC;
               }
               else
               {
                  _loc14_ = this._now.hoursUTC.toString();
                  if(_loc14_.length == 1)
                  {
                     _loc14_ = "0" + _loc14_;
                  }
                  _loc15_ = this._now.minutesUTC.toString();
                  if(_loc15_.length == 1)
                  {
                     _loc15_ = "0" + _loc15_;
                  }
                  _loc16_ = this._now.secondsUTC.toString();
                  if(_loc16_.length == 1)
                  {
                     _loc16_ = "0" + _loc16_;
                  }
                  _loc17_ = this._now.millisecondsUTC.toString();
                  if(_loc17_.length == 1)
                  {
                     _loc17_ = "00" + _loc17_;
                  }
                  else if(_loc17_.length == 2)
                  {
                     _loc17_ = "0" + _loc17_;
                  }
                  _loc8_ += _loc14_ + ":" + _loc15_ + ":" + _loc16_ + "." + _loc17_;
               }
            }
            else if(_loc13_ < 13)
            {
               if(_loc13_ < 10)
               {
                  if(_loc13_ == this.DATE_TYPE)
                  {
                     _loc8_ += this._now.fullYear + "/" + (this._now.month + 1) + "/" + this._now.date;
                  }
                  else if(_loc13_ == this.DATE_UTC_TYPE)
                  {
                     _loc8_ += this._now.fullYearUTC + "/" + (this._now.monthUTC + 1) + "/" + this._now.dateUTC;
                  }
                  else if(param3)
                  {
                     _loc8_ += LEVEL_NAMES[param3] || "FATAL";
                  }
               }
               else if(_loc13_ == this.SWF_TYPE)
               {
                  _loc8_ += SWF_URL;
               }
               else if(_loc13_ == this.SHORT_SWF_TYPE)
               {
                  _loc8_ += SWF_SHORT_URL;
               }
               else
               {
                  _loc8_ += param1;
               }
            }
            else if(_loc13_ == this.SHORT_NAME_TYPE)
            {
               _loc8_ += param2;
            }
            else if(_loc13_ == this.GMT_OFFSET_TYPE)
            {
               _loc8_ += GMT;
            }
            else if(_loc13_ == this.PERSON_TYPE)
            {
               if(param7)
               {
                  _loc8_ += param7;
               }
            }
            else if(param7)
            {
               _loc8_ += "@" + param7;
            }
            _loc9_ = _loc9_.next;
         }
         return _loc8_;
      }
   }
}

final class FormatNode
{
   
   public var next:FormatNode;
   
   public var content:String;
   
   public var param:int;
   
   public var type:int;
   
   public function FormatNode()
   {
      super();
   }
}
