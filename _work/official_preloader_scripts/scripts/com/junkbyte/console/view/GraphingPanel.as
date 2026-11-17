package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.GraphGroup;
   import com.junkbyte.console.vos.GraphInterest;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class GraphingPanel extends ConsolePanel
   {
      
      public static const FPS:String = "fpsPanel";
      
      public static const MEM:String = "memoryPanel";
      
      private var _group:GraphGroup;
      
      private var _interest:GraphInterest;
      
      private var _infoMap:Object = {};
      
      private var _menuString:String;
      
      private var _type:String;
      
      private var _needRedraw:Boolean;
      
      private var underlay:Shape;
      
      private var graph:Shape;
      
      private var lowTxt:TextField;
      
      private var highTxt:TextField;
      
      public var startOffset:int = 5;
      
      public function GraphingPanel(param1:Console, param2:int, param3:int, param4:String = null)
      {
         super(param1);
         _type = param4;
         registerDragger(bg);
         minWidth = 32;
         minHeight = 26;
         var _loc5_:TextFormat = new TextFormat();
         var _loc6_:Object = style.styleSheet.getStyle("low");
         _loc5_.font = _loc6_.fontFamily;
         _loc5_.size = _loc6_.fontSize;
         _loc5_.color = style.lowColor;
         lowTxt = new TextField();
         lowTxt.name = "lowestField";
         lowTxt.defaultTextFormat = _loc5_;
         lowTxt.mouseEnabled = false;
         lowTxt.height = style.menuFontSize + 2;
         addChild(lowTxt);
         highTxt = new TextField();
         highTxt.name = "highestField";
         highTxt.defaultTextFormat = _loc5_;
         highTxt.mouseEnabled = false;
         highTxt.height = style.menuFontSize + 2;
         highTxt.y = style.menuFontSize - 4;
         addChild(highTxt);
         txtField = makeTF("menuField");
         txtField.height = style.menuFontSize + 4;
         txtField.y = -3;
         registerTFRoller(txtField,onMenuRollOver,linkHandler);
         registerDragger(txtField);
         addChild(txtField);
         underlay = new Shape();
         addChild(underlay);
         graph = new Shape();
         graph.name = "graph";
         graph.y = style.menuFontSize;
         addChild(graph);
         _menuString = "<menu>";
         if(_type == "memoryPanel")
         {
            _menuString += " <a href=\"event:gc\">G</a> ";
         }
         _menuString += "<a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></low></r>";
         init(param2,param3,true);
      }
      
      private function stop() : void
      {
         if(_group)
         {
            console.graphing.remove(_group.name);
         }
      }
      
      public function get group() : GraphGroup
      {
         return _group;
      }
      
      public function reset() : void
      {
         _infoMap = {};
         graph.graphics.clear();
         if(!_group.fixed)
         {
            _group.low = NaN;
            _group.hi = NaN;
         }
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         lowTxt.y = param1 - style.menuFontSize;
         _needRedraw = true;
         var _loc2_:Graphics = underlay.graphics;
         _loc2_.clear();
         _loc2_.lineStyle(1,style.controlColor,0.6);
         _loc2_.moveTo(0,graph.y);
         _loc2_.lineTo(width - startOffset,graph.y);
         _loc2_.lineTo(width - startOffset,param1);
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         lowTxt.width = param1;
         highTxt.width = param1;
         txtField.width = param1;
         txtField.scrollH = txtField.maxScrollH;
         graph.graphics.clear();
         _needRedraw = true;
      }
      
      public function update(param1:GraphGroup, param2:Boolean) : void
      {
         var _loc17_:* = null;
         var _loc6_:String = null;
         var _loc12_:Array = null;
         var _loc13_:Array = null;
         var _loc16_:int = 0;
         var _loc4_:int = 0;
         var _loc8_:int = 0;
         var _loc15_:int = 0;
         var _loc11_:int = 0;
         var _loc19_:Number = NaN;
         var _loc22_:Boolean = false;
         _group = param1;
         var _loc10_:int = 1;
         if(param1.idle > 0)
         {
            _loc10_ = 0;
            if(!_needRedraw)
            {
               return;
            }
         }
         if(_needRedraw)
         {
            param2 = true;
         }
         _needRedraw = false;
         var _loc3_:Array = param1.interests;
         var _loc14_:int = width - startOffset;
         var _loc9_:int = height - graph.y;
         var _loc21_:Number = param1.low;
         var _loc5_:Number = param1.hi;
         var _loc18_:Number = _loc5_ - _loc21_;
         var _loc7_:Boolean = false;
         if(param2)
         {
            TextField(param1.inv ? highTxt : lowTxt).text = String(param1.low);
            TextField(param1.inv ? lowTxt : highTxt).text = String(param1.hi);
            graph.graphics.clear();
         }
         for each(_loc17_ in _loc3_)
         {
            _interest = _loc17_;
            _loc6_ = _interest.key;
            _loc12_ = _infoMap[_loc6_];
            if(_loc12_ == null)
            {
               _loc7_ = true;
               _loc12_ = new Array(_interest.col.toString(16),[]);
               _infoMap[_loc6_] = _loc12_;
            }
            _loc13_ = _loc12_[1];
            if(_loc10_ == 1)
            {
               if(param1.type == 1)
               {
                  _loc16_ = Math.floor(param1.hi / _interest.v);
                  if(_loc16_ > 30)
                  {
                     _loc16_ = 30;
                  }
                  while(_loc16_ > 0)
                  {
                     _loc13_.push(_interest.v);
                     _loc16_--;
                  }
               }
               else
               {
                  _loc13_.push(_interest.v);
               }
            }
            _loc4_ = Math.floor(_loc14_) + 10;
            while(_loc13_.length > _loc4_)
            {
               _loc13_.shift();
            }
            if(param2)
            {
               _loc8_ = int(_loc13_.length);
               graph.graphics.lineStyle(1,_interest.col);
               _loc15_ = _loc14_ > _loc8_ ? _loc8_ : _loc14_;
               _loc11_ = 1;
               while(_loc11_ < _loc15_)
               {
                  _loc19_ = (_loc18_ ? (_loc13_[_loc8_ - _loc11_] - _loc21_) / _loc18_ : 0.5) * _loc9_;
                  if(!param1.inv)
                  {
                     _loc19_ = _loc9_ - _loc19_;
                  }
                  if(_loc19_ < 0)
                  {
                     _loc19_ = 0;
                  }
                  if(_loc19_ > _loc9_)
                  {
                     _loc19_ = _loc9_;
                  }
                  if(_loc11_ == 1)
                  {
                     graph.graphics.moveTo(width,_loc19_);
                  }
                  graph.graphics.lineTo(_loc14_ - _loc11_,_loc19_);
                  _loc11_++;
               }
               if(isNaN(_interest.avg) && _loc18_)
               {
                  _loc19_ = (_interest.avg - _loc21_) / _loc18_ * _loc9_;
                  if(!param1.inv)
                  {
                     _loc19_ = _loc9_ - _loc19_;
                  }
                  if(_loc19_ < 0)
                  {
                     _loc19_ = 0;
                  }
                  if(_loc19_ > _loc9_)
                  {
                     _loc19_ = _loc9_;
                  }
                  graph.graphics.lineStyle(1,_interest.col,0.3);
                  graph.graphics.moveTo(0,_loc19_);
                  graph.graphics.lineTo(_loc14_,_loc19_);
               }
            }
         }
         for(var _loc20_:String in _infoMap)
         {
            for each(_loc17_ in _loc3_)
            {
               if(_loc17_.key == _loc20_)
               {
                  _loc22_ = true;
               }
            }
            if(!_loc22_)
            {
               _loc7_ = true;
               delete _infoMap[_loc20_];
            }
         }
         if(param2 && (_loc7_ || _type))
         {
            updateKeyText();
         }
      }
      
      public function updateKeyText() : void
      {
         var _loc1_:String = "<r><low>";
         if(_type)
         {
            if(isNaN(_interest.v))
            {
               _loc1_ += "no input";
            }
            else if(_type == "fpsPanel")
            {
               _loc1_ += _interest.avg.toFixed(1);
            }
            else
            {
               _loc1_ += _interest.v + "mb";
            }
         }
         else
         {
            for(var _loc2_:String in _infoMap)
            {
               _loc1_ += " <font color=\'#" + _infoMap[_loc2_][0] + "\'>" + _loc2_ + "</font>";
            }
            _loc1_ += " |";
         }
         txtField.htmlText = _loc1_ + _menuString;
         txtField.scrollH = txtField.maxScrollH;
      }
      
      protected function linkHandler(param1:TextEvent) : void
      {
         TextField(param1.currentTarget).setSelection(0,0);
         if(param1.text == "reset")
         {
            reset();
         }
         else if(param1.text == "close")
         {
            if(_type == "fpsPanel")
            {
               console.fpsMonitor = false;
            }
            else if(_type == "memoryPanel")
            {
               console.memoryMonitor = false;
            }
            else
            {
               stop();
            }
            console.panels.removeGraph(_group);
         }
         else if(param1.text == "gc")
         {
            console.gc();
         }
         param1.stopPropagation();
      }
      
      protected function onMenuRollOver(param1:TextEvent) : void
      {
         var _loc2_:String = param1.text ? param1.text.replace("event:","") : null;
         if(_loc2_ == "gc")
         {
            _loc2_ = "Garbage collect::Requires debugger version of flash player";
         }
         console.panels.tooltip(_loc2_,this);
      }
   }
}

