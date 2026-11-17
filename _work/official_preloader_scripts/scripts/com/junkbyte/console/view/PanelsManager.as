package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.GraphGroup;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class PanelsManager
   {
      
      private var console:Console;
      
      private var _mainPanel:MainPanel;
      
      private var _ruler:Ruler;
      
      private var _chsPanel:ChannelsPanel;
      
      private var _fpsPanel:GraphingPanel;
      
      private var _memPanel:GraphingPanel;
      
      private var _graphsMap:Object = {};
      
      private var _graphPlaced:uint = 0;
      
      private var _tooltipField:TextField;
      
      private var _canDraw:Boolean;
      
      public function PanelsManager(param1:Console)
      {
         super();
         console = param1;
         _mainPanel = new MainPanel(console);
         _tooltipField = mainPanel.makeTF("tooltip",true);
         _tooltipField.mouseEnabled = false;
         _tooltipField.autoSize = "center";
         _tooltipField.multiline = true;
         addPanel(_mainPanel);
      }
      
      public function addPanel(param1:ConsolePanel) : void
      {
         if(console.contains(_tooltipField))
         {
            console.addChildAt(param1,console.getChildIndex(_tooltipField));
         }
         else
         {
            console.addChild(param1);
         }
         param1.addEventListener("draggingStarted",onPanelStartDragScale,false,0,true);
         param1.addEventListener("scalingStarted",onPanelStartDragScale,false,0,true);
      }
      
      public function removePanel(param1:String) : void
      {
         var _loc2_:ConsolePanel = console.getChildByName(param1) as ConsolePanel;
         if(_loc2_)
         {
            _loc2_.close();
         }
      }
      
      public function getPanel(param1:String) : ConsolePanel
      {
         return console.getChildByName(param1) as ConsolePanel;
      }
      
      public function get mainPanel() : MainPanel
      {
         return _mainPanel;
      }
      
      public function panelExists(param1:String) : Boolean
      {
         return console.getChildByName(param1) as ConsolePanel ? true : false;
      }
      
      public function setPanelArea(param1:String, param2:Rectangle) : void
      {
         var _loc3_:ConsolePanel = getPanel(param1);
         if(_loc3_)
         {
            _loc3_.x = param2.x;
            _loc3_.y = param2.y;
            if(param2.width)
            {
               _loc3_.width = param2.width;
            }
            if(param2.height)
            {
               _loc3_.height = param2.height;
            }
         }
      }
      
      public function updateMenu() : void
      {
         _mainPanel.updateMenu();
         var _loc1_:ChannelsPanel = getPanel("channelsPanel") as ChannelsPanel;
         if(_loc1_)
         {
            _loc1_.update();
         }
      }
      
      public function update(param1:Boolean, param2:Boolean) : void
      {
         _canDraw = !param1;
         _mainPanel.update(!param1 && param2);
         if(!param1)
         {
            if(param2 && _chsPanel != null)
            {
               _chsPanel.update();
            }
         }
      }
      
      public function updateGraphs(param1:Array) : void
      {
         var _loc8_:Object = null;
         var _loc10_:GraphGroup = null;
         var _loc5_:GraphGroup = null;
         var _loc4_:String = null;
         var _loc2_:GraphingPanel = null;
         var _loc7_:Rectangle = null;
         var _loc9_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc3_:int = 0;
         var _loc11_:int = 0;
         _graphPlaced = 0;
         for each(var _loc12_:GraphGroup in param1)
         {
            if(_loc12_.type == 1)
            {
               _loc10_ = _loc12_;
            }
            else if(_loc12_.type == 2)
            {
               _loc5_ = _loc12_;
            }
            else
            {
               _loc4_ = _loc12_.name;
               _loc2_ = _graphsMap[_loc4_] as GraphingPanel;
               if(!_loc2_)
               {
                  _loc7_ = _loc12_.rect;
                  if(_loc7_ == null)
                  {
                     _loc7_ = new Rectangle(NaN,NaN,0,0);
                  }
                  _loc9_ = 100;
                  if(isNaN(_loc7_.x) || isNaN(_loc7_.y))
                  {
                     if(_mainPanel.width < 150)
                     {
                        _loc9_ = 50;
                     }
                     _loc6_ = Math.floor(_mainPanel.width / _loc9_) - 1;
                     if(_loc6_ <= 1)
                     {
                        _loc6_ = 2;
                     }
                     _loc3_ = _graphPlaced % _loc6_;
                     _loc11_ = Math.floor(_graphPlaced / _loc6_);
                     _loc7_.x = _mainPanel.x + _loc9_ + _loc3_ * _loc9_;
                     _loc7_.y = _mainPanel.y + _loc9_ * 0.6 + _loc11_ * _loc9_;
                     _graphPlaced = _graphPlaced + 1;
                  }
                  if(_loc7_.width <= 0 || isNaN(_loc7_.width))
                  {
                     _loc7_.width = _loc9_;
                  }
                  if(_loc7_.height <= 0 || isNaN(_loc7_.height))
                  {
                     _loc7_.height = _loc9_;
                  }
                  _loc2_ = new GraphingPanel(console,_loc7_.width,_loc7_.height);
                  _loc2_.x = _loc7_.x;
                  _loc2_.y = _loc7_.y;
                  _loc2_.name = "graph_" + _loc4_;
                  _graphsMap[_loc4_] = _loc2_;
                  addPanel(_loc2_);
               }
               if(_loc8_ == null)
               {
                  _loc8_ = {};
               }
               _loc8_[_loc4_] = true;
               _loc2_.update(_loc12_,_canDraw);
            }
         }
         for(var _loc13_:String in _graphsMap)
         {
            if(_loc8_ == null || !_loc8_[_loc13_])
            {
               _graphsMap[_loc13_].close();
               delete _graphsMap[_loc13_];
            }
         }
         if(_loc10_ != null)
         {
            if(_fpsPanel == null)
            {
               _fpsPanel = new GraphingPanel(console,80,40,"fpsPanel");
               _fpsPanel.name = "fpsPanel";
               _fpsPanel.x = _mainPanel.x + _mainPanel.width - 160;
               _fpsPanel.y = _mainPanel.y + 15;
               addPanel(_fpsPanel);
               _mainPanel.updateMenu();
            }
            _fpsPanel.update(_loc10_,_canDraw);
         }
         else if(_fpsPanel != null)
         {
            removePanel("fpsPanel");
            _fpsPanel = null;
         }
         if(_loc5_ != null)
         {
            if(_memPanel == null)
            {
               _memPanel = new GraphingPanel(console,80,40,"memoryPanel");
               _memPanel.name = "memoryPanel";
               _memPanel.x = _mainPanel.x + _mainPanel.width - 80;
               _memPanel.y = _mainPanel.y + 15;
               addPanel(_memPanel);
               _mainPanel.updateMenu();
            }
            _memPanel.update(_loc5_,_canDraw);
         }
         else if(_memPanel != null)
         {
            removePanel("memoryPanel");
            _memPanel = null;
         }
         _canDraw = false;
      }
      
      public function removeGraph(param1:GraphGroup) : void
      {
         var _loc2_:GraphingPanel = null;
         if(_fpsPanel && param1 == _fpsPanel.group)
         {
            _fpsPanel.close();
            _fpsPanel = null;
         }
         else if(_memPanel && param1 == _memPanel.group)
         {
            _memPanel.close();
            _memPanel = null;
         }
         else
         {
            _loc2_ = _graphsMap[param1.name];
            if(_loc2_)
            {
               _loc2_.close();
               delete _graphsMap[param1.name];
            }
         }
      }
      
      public function get displayRoller() : Boolean
      {
         return getPanel("rollerPanel") as RollerPanel ? true : false;
      }
      
      public function set displayRoller(param1:Boolean) : void
      {
         var _loc2_:RollerPanel = null;
         if(displayRoller != param1)
         {
            if(param1)
            {
               if(console.config.displayRollerEnabled)
               {
                  _loc2_ = new RollerPanel(console);
                  _loc2_.x = _mainPanel.x + _mainPanel.width - 180;
                  _loc2_.y = _mainPanel.y + 55;
                  addPanel(_loc2_);
               }
               else
               {
                  console.report("Display roller is disabled in config.",9);
               }
            }
            else
            {
               removePanel("rollerPanel");
            }
            _mainPanel.updateMenu();
         }
      }
      
      public function get channelsPanel() : Boolean
      {
         return _chsPanel != null;
      }
      
      public function set channelsPanel(param1:Boolean) : void
      {
         if(channelsPanel != param1)
         {
            console.logs.cleanChannels();
            if(param1)
            {
               _chsPanel = new ChannelsPanel(console);
               _chsPanel.x = _mainPanel.x + _mainPanel.width - 332;
               _chsPanel.y = _mainPanel.y - 2;
               addPanel(_chsPanel);
               _chsPanel.update();
               updateMenu();
            }
            else
            {
               removePanel("channelsPanel");
               _chsPanel = null;
            }
            updateMenu();
         }
      }
      
      public function get memoryMonitor() : Boolean
      {
         return _memPanel != null;
      }
      
      public function get fpsMonitor() : Boolean
      {
         return _fpsPanel != null;
      }
      
      public function tooltip(param1:String = null, param2:ConsolePanel = null) : void
      {
         var _loc5_:Array = null;
         var _loc3_:Rectangle = null;
         var _loc4_:Rectangle = null;
         var _loc7_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc8_:Number = NaN;
         if(param1 && !rulerActive)
         {
            _loc5_ = param1.split("::");
            param1 = _loc5_[0];
            if(_loc5_.length > 1)
            {
               param1 += "<br/><low>" + _loc5_[1] + "</low>";
            }
            console.addChild(_tooltipField);
            _tooltipField.wordWrap = false;
            _tooltipField.htmlText = "<tt>" + param1 + "</tt>";
            if(_tooltipField.width > 120)
            {
               _tooltipField.width = 120;
               _tooltipField.wordWrap = true;
            }
            _tooltipField.x = console.mouseX - _tooltipField.width / 2;
            _tooltipField.y = console.mouseY + 20;
            if(param2)
            {
               _loc3_ = _tooltipField.getBounds(console);
               _loc4_ = new Rectangle(param2.x,param2.y,param2.width,param2.height);
               _loc7_ = _loc3_.bottom - _loc4_.bottom;
               if(_loc7_ > 0)
               {
                  if(_tooltipField.y - _loc7_ > console.mouseY + 15)
                  {
                     _tooltipField.y -= _loc7_;
                  }
                  else if(_loc4_.y < console.mouseY - 24 && _loc3_.y > _loc4_.bottom)
                  {
                     _tooltipField.y = console.mouseY - _tooltipField.height - 15;
                  }
               }
               _loc6_ = _loc3_.left - _loc4_.left;
               _loc8_ = _loc3_.right - _loc4_.right;
               if(_loc6_ < 0)
               {
                  _tooltipField.x -= _loc6_;
               }
               else if(_loc8_ > 0)
               {
                  _tooltipField.x -= _loc8_;
               }
            }
         }
         else if(console.contains(_tooltipField))
         {
            console.removeChild(_tooltipField);
         }
      }
      
      public function startRuler() : void
      {
         if(rulerActive)
         {
            return;
         }
         _ruler = new Ruler(console);
         _ruler.addEventListener("complete",onRulerExit,false,0,true);
         console.addChild(_ruler);
         _mainPanel.updateMenu();
      }
      
      public function get rulerActive() : Boolean
      {
         return _ruler && console.contains(_ruler) ? true : false;
      }
      
      private function onRulerExit(param1:Event) : void
      {
         if(_ruler && console.contains(_ruler))
         {
            console.removeChild(_ruler);
         }
         _ruler = null;
         _mainPanel.updateMenu();
      }
      
      private function onPanelStartDragScale(param1:Event) : void
      {
         var _loc5_:Array = null;
         var _loc4_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:ConsolePanel = null;
         var _loc3_:ConsolePanel = param1.currentTarget as ConsolePanel;
         if(console.config.style.panelSnapping)
         {
            _loc5_ = [0];
            _loc4_ = [0];
            if(console.stage)
            {
               _loc5_.push(console.stage.stageWidth);
               _loc4_.push(console.stage.stageHeight);
            }
            _loc6_ = console.numChildren;
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               _loc2_ = console.getChildAt(_loc7_) as ConsolePanel;
               if(_loc2_ && _loc2_.visible)
               {
                  _loc5_.push(_loc2_.x,_loc2_.x + _loc2_.width);
                  _loc4_.push(_loc2_.y,_loc2_.y + _loc2_.height);
               }
               _loc7_++;
            }
            _loc3_.registerSnaps(_loc5_,_loc4_);
         }
      }
   }
}

