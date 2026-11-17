package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.KeyBind;
   import com.junkbyte.console.core.LogReferences;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.TextEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   
   public class RollerPanel extends ConsolePanel
   {
      
      public static const NAME:String = "rollerPanel";
      
      private var _settingKey:Boolean;
      
      public function RollerPanel(param1:Console)
      {
         super(param1);
         name = "rollerPanel";
         init(60,100,false);
         txtField = makeTF("rollerPrints");
         txtField.multiline = true;
         txtField.autoSize = "left";
         registerTFRoller(txtField,onMenuRollOver,linkHandler);
         registerDragger(txtField);
         addChild(txtField);
         addEventListener("enterFrame",_onFrame);
         addEventListener("removedFromStage",removeListeners);
      }
      
      private function removeListeners(param1:Event = null) : void
      {
         removeEventListener("enterFrame",_onFrame);
         removeEventListener("removedFromStage",removeListeners);
         if(stage)
         {
            stage.removeEventListener("keyDown",keyDownHandler);
         }
      }
      
      private function _onFrame(param1:Event) : void
      {
         if(!console.stage)
         {
            close();
            return;
         }
         if(_settingKey)
         {
            txtField.htmlText = "<high><menu>Press a key to set [ <a href=\"event:cancel\"><b>cancel</b></a> ]</menu></high>";
         }
         else
         {
            txtField.htmlText = "<low>" + getMapString(false) + "</low>";
            txtField.autoSize = "left";
            txtField.setSelection(0,0);
         }
         width = txtField.width + 4;
         height = txtField.height;
      }
      
      public function getMapString(param1:Boolean) : String
      {
         var _loc16_:String = null;
         var _loc13_:Array = null;
         var _loc8_:DisplayObjectContainer = null;
         var _loc4_:* = 0;
         var _loc6_:* = 0;
         var _loc15_:DisplayObject = null;
         var _loc5_:* = 0;
         var _loc3_:String = null;
         var _loc12_:* = 0;
         var _loc2_:Stage = console.stage;
         var _loc10_:String = "";
         if(!param1)
         {
            _loc16_ = console.rollerCaptureKey ? console.rollerCaptureKey.key : "unassigned";
            _loc10_ = "<menu> <a href=\"event:close\"><b>X</b></a></menu> Capture key: <menu><a href=\"event:capture\">" + _loc16_ + "</a></menu><br/>";
         }
         var _loc14_:Point = new Point(_loc2_.mouseX,_loc2_.mouseY);
         if(_loc2_.areInaccessibleObjectsUnderPoint(_loc14_))
         {
            _loc10_ += "<p9>Inaccessible objects detected</p9><br/>";
         }
         var _loc11_:Array = _loc2_.getObjectsUnderPoint(_loc14_);
         var _loc9_:Dictionary = new Dictionary(true);
         if(_loc11_.length == 0)
         {
            _loc11_.push(_loc2_);
         }
         for each(var _loc7_:DisplayObject in _loc11_)
         {
            _loc13_ = new Array(_loc7_);
            _loc8_ = _loc7_.parent;
            while(_loc8_)
            {
               _loc13_.unshift(_loc8_);
               _loc8_ = _loc8_.parent;
            }
            _loc4_ = _loc13_.length;
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               _loc15_ = _loc13_[_loc6_];
               if(_loc9_[_loc15_] == undefined)
               {
                  _loc9_[_loc15_] = _loc6_;
                  _loc5_ = _loc6_;
                  while(_loc5_ > 0)
                  {
                     _loc10_ += _loc5_ == 1 ? " ∟" : " -";
                     _loc5_--;
                  }
                  _loc3_ = _loc15_.name;
                  if(param1 && console.config.useObjectLinking)
                  {
                     _loc12_ = console.refs.setLogRef(_loc15_);
                     _loc3_ = "<a href=\'event:cl_" + _loc12_ + "\'>" + _loc3_ + "</a> " + console.refs.makeRefTyped(_loc15_);
                  }
                  else
                  {
                     _loc3_ = _loc3_ + " (" + LogReferences.ShortClassName(_loc15_) + ")";
                  }
                  if(_loc15_ == _loc2_)
                  {
                     _loc12_ = console.refs.setLogRef(_loc2_);
                     if(_loc12_)
                     {
                        _loc10_ += "<p3><a href=\'event:cl_" + _loc12_ + "\'><i>Stage</i></a> ";
                     }
                     else
                     {
                        _loc10_ += "<p3><i>Stage</i> ";
                     }
                     _loc10_ += "[" + _loc2_.mouseX + "," + _loc2_.mouseY + "]</p3><br/>";
                  }
                  else if(_loc6_ == _loc4_ - 1)
                  {
                     _loc10_ += "<p5>" + _loc3_ + "</p5><br/>";
                  }
                  else
                  {
                     _loc10_ += "<p2><i>" + _loc3_ + "</i></p2><br/>";
                  }
               }
               _loc6_++;
            }
         }
         return _loc10_;
      }
      
      override public function close() : void
      {
         cancelCaptureKeySet();
         removeListeners();
         super.close();
         console.panels.updateMenu();
      }
      
      private function onMenuRollOver(param1:TextEvent) : void
      {
         var _loc2_:KeyBind = null;
         var _loc3_:String = param1.text ? param1.text.replace("event:","") : "";
         if(_loc3_ == "close")
         {
            _loc3_ = "Close";
         }
         else if(_loc3_ == "capture")
         {
            _loc2_ = console.rollerCaptureKey;
            if(_loc2_)
            {
               _loc3_ = "Unassign key ::" + _loc2_.key;
            }
            else
            {
               _loc3_ = "Assign key";
            }
         }
         else if(_loc3_ == "cancel")
         {
            _loc3_ = "Cancel assign key";
         }
         else
         {
            _loc3_ = null;
         }
         console.panels.tooltip(_loc3_,this);
      }
      
      protected function linkHandler(param1:TextEvent) : void
      {
         TextField(param1.currentTarget).setSelection(0,0);
         if(param1.text == "close")
         {
            close();
         }
         else if(param1.text == "capture")
         {
            if(console.rollerCaptureKey)
            {
               console.setRollerCaptureKey(null);
            }
            else
            {
               _settingKey = true;
               stage.addEventListener("keyDown",keyDownHandler,false,0,true);
            }
            console.panels.tooltip(null);
         }
         else if(param1.text == "cancel")
         {
            cancelCaptureKeySet();
            console.panels.tooltip(null);
         }
         param1.stopPropagation();
      }
      
      private function cancelCaptureKeySet() : void
      {
         _settingKey = false;
         if(stage)
         {
            stage.removeEventListener("keyDown",keyDownHandler);
         }
      }
      
      private function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(!param1.charCode)
         {
            return;
         }
         var _loc2_:String = String.fromCharCode(param1.charCode);
         cancelCaptureKeySet();
         console.setRollerCaptureKey(_loc2_,param1.shiftKey,param1.ctrlKey,param1.altKey);
         console.panels.tooltip(null);
      }
   }
}

