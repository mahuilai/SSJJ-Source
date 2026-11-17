package view.reconnect
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import lobby.LanguageConfig;
   import res.alert_bg;
   import tools.StringUtils;
   
   public class AlertPanel extends Sprite
   {
      
      private static var _panel:AlertPanel = null;
      
      private var _tipTF:TextField = null;
      
      private var _timeTryTF:TextField = null;
      
      private var _btnSure:SimpleBtn = null;
      
      private var _func:Function = null;
      
      private var _timer:Timer = null;
      
      private var _maxTime:int = 0;
      
      public function AlertPanel()
      {
         super();
         this.initPanel();
      }
      
      public static function showAlert(param1:Sprite, param2:String, param3:Function, param4:Number = 1000, param5:Number = 600) : void
      {
         if(null == _panel)
         {
            _panel = new AlertPanel();
         }
         _panel.closeHandler = param3;
         _panel.msg = param2;
         param1.addChild(_panel);
         _panel.x = (param4 - _panel.width) / 2;
         _panel.y = (param5 - _panel.height) / 2;
      }
      
      public static function showReconnect(param1:Sprite, param2:int = 20, param3:Number = 1000, param4:Number = 600) : void
      {
         if(null == _panel)
         {
            _panel = new AlertPanel();
         }
         _panel.maxTime = param2;
         param1.addChild(_panel);
         _panel.x = (param3 - _panel.width) / 2;
         _panel.y = (param4 - _panel.height) / 2;
      }
      
      public static function hide() : void
      {
         if(null == _panel)
         {
            return;
         }
         _panel.dispose();
         if(null != _panel.parent)
         {
            _panel.parent.removeChild(_panel);
         }
      }
      
      private function initPanel() : void
      {
         this.addChild(new alert_bg());
         this._tipTF = new TextField();
         this.addChild(this._tipTF);
         this._tipTF.x = 22;
         this._tipTF.y = 85;
         this._tipTF.width = 350;
         this._tipTF.height = 25;
         this._tipTF.autoSize = "center";
         this._tipTF.textColor = 16777215;
         this._tipTF.defaultTextFormat = new TextFormat(LanguageConfig.getText("WORD_19"),14,16777215);
         this._tipTF.filters = [new GlowFilter(0,1,2,2,2000)];
         this._timeTryTF = new TextField();
         this.addChild(this._timeTryTF);
         this._timeTryTF.x = 22;
         this._timeTryTF.y = 126;
         this._timeTryTF.width = 350;
         this._timeTryTF.height = 25;
         this._timeTryTF.autoSize = "center";
         this._timeTryTF.textColor = 3407871;
         this._timeTryTF.defaultTextFormat = new TextFormat(LanguageConfig.getText("WORD_19"),16,3407871);
         this._timeTryTF.filters = [new GlowFilter(0,1,2,2,2000)];
         this._btnSure = new SimpleBtn(LanguageConfig.getText("WORD_3233"));
         this.addChild(this._btnSure);
         this._btnSure.x = (this.width - this._btnSure.width) * 0.5;
         this._btnSure.y = 192;
         this._btnSure.addEventListener("click",onBtnSure);
      }
      
      public function dispose() : void
      {
         if(null != this._timer)
         {
            this._timer.removeEventListener("timer",onTimerHandler);
            this._timer.reset();
            this._timer = null;
         }
      }
      
      public function set closeHandler(param1:Function) : void
      {
         this._func = param1;
         if(null != this._timer)
         {
            this._timer.removeEventListener("timer",onTimerHandler);
            this._timer.reset();
         }
         this._timeTryTF.visible = false;
         this._btnSure.visible = true;
      }
      
      public function set msg(param1:String) : void
      {
         this._tipTF.text = param1;
      }
      
      private function onBtnSure(param1:Event) : void
      {
         this._func.apply();
      }
      
      public function set maxTime(param1:int) : void
      {
         this._maxTime = param1;
         this._tipTF.text = StringUtils.substitute(LanguageConfig.getText("WORD_1561"),_maxTime);
         this._timeTryTF.text = StringUtils.substitute(LanguageConfig.getText("WORD_1562"),1);
         if(null != this._timer)
         {
            this._timer.removeEventListener("timer",onTimerHandler);
            this._timer.reset();
         }
         this._timer = new Timer(2000,100);
         this._timer.addEventListener("timer",onTimerHandler);
         this._timer.start();
         this._timeTryTF.visible = true;
         this._btnSure.visible = false;
      }
      
      private function onTimerHandler(param1:TimerEvent) : void
      {
         this._timeTryTF.text = StringUtils.substitute(LanguageConfig.getText("WORD_1562"),this._timer.currentCount + 1);
      }
   }
}

import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFormat;
import lobby.LanguageConfig;
import res.btn_blue;

class SimpleBtn extends Sprite
{
   
   private var _labelTextField:TextField = null;
   
   public function SimpleBtn(param1:String)
   {
      super();
      this.addChild(new btn_blue());
      this._labelTextField = new TextField();
      this.addChild(this._labelTextField);
      this._labelTextField.x = 0;
      this._labelTextField.mouseEnabled = false;
      this._labelTextField.y = 0;
      this._labelTextField.width = this.width;
      this._labelTextField.height = 25;
      this._labelTextField.autoSize = "center";
      this._labelTextField.textColor = 14213096;
      this._labelTextField.defaultTextFormat = new TextFormat(LanguageConfig.getText("WORD_19"),15,14213096);
      this._labelTextField.filters = [new GlowFilter(0,1,2,2,2000)];
      this._labelTextField.text = param1;
      this._labelTextField.y = (this.height - this._labelTextField.height) * 0.5;
      this.buttonMode = true;
   }
}
