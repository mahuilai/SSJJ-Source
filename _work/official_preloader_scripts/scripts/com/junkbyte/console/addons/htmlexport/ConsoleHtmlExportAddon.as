package com.junkbyte.console.addons.htmlexport
{
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import com.junkbyte.console.ConsoleStyle;
   import com.junkbyte.console.view.MainPanel;
   import com.junkbyte.console.vos.Log;
   import flash.net.FileReference;
   import flash.utils.ByteArray;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   
   public class ConsoleHtmlExportAddon
   {
      
      public static const HTML_REPLACEMENT:String = "{text:\'HTML_REPLACEMENT\'}";
      
      private static var EmbeddedTemplate:Class = template_html;
      
      public var referencesDepth:uint = 1;
      
      protected var console:Console;
      
      public function ConsoleHtmlExportAddon(param1:Console)
      {
         super();
         if(param1 == null)
         {
            param1 = Cc.instance;
         }
         this.console = param1;
      }
      
      public static function addToMenu(param1:String = "export", param2:Console = null) : ConsoleHtmlExportAddon
      {
         var _loc3_:ConsoleHtmlExportAddon = null;
         if(param2 == null)
         {
            param2 = Cc.instance;
         }
         if(param2)
         {
            _loc3_ = new ConsoleHtmlExportAddon(param2);
            param2.addMenu(param1,_loc3_.exportToFile,[],"Export logs to HTML");
         }
         return _loc3_;
      }
      
      public function exportToFile(param1:String = null) : void
      {
         var _loc3_:String = null;
         if(param1 == null)
         {
            param1 = generateFileName();
         }
         var _loc2_:FileReference = new FileReference();
         try
         {
            _loc3_ = exportHTMLString();
            _loc2_["save"](_loc3_,param1);
         }
         catch(err:Error)
         {
            console.report("Failed to save to file: " + err,8);
         }
      }
      
      protected function generateFileName() : String
      {
         var _loc2_:Date = new Date();
         var _loc1_:String = "log@" + _loc2_.getFullYear() + "." + (_loc2_.getMonth() + 1) + "." + (_loc2_.getDate() + 1);
         _loc1_ += "_" + _loc2_.hours + "." + _loc2_.minutes;
         return _loc1_ + ".html";
      }
      
      public function exportHTMLString() : String
      {
         var _loc1_:String = String(new EmbeddedTemplate() as ByteArray);
         return _loc1_.replace("{text:\'HTML_REPLACEMENT\'}",exportJSON());
      }
      
      protected function exportJSON() : String
      {
         var _loc1_:Class = null;
         var _loc3_:Object = exportObject();
         try
         {
            _loc1_ = getDefinitionByName("JSON") as Class;
            return _loc1_["stringify"](_loc3_);
         }
         catch(error:Error)
         {
         }
         var _loc2_:Class = getDefinitionByName("com.adobe.serialization.json.JSON") as Class;
         return _loc2_["encode"](_loc3_);
      }
      
      protected function exportObject() : Object
      {
         var _loc2_:Object = {};
         _loc2_.config = getConfigToEncode();
         _loc2_.ui = getUIDataToEncode();
         _loc2_.logs = getLogsToEncode();
         var _loc1_:ConsoleHTMLRefsGen = new ConsoleHTMLRefsGen(console,referencesDepth);
         _loc1_.fillData(_loc2_);
         return _loc2_;
      }
      
      protected function getConfigToEncode() : Object
      {
         var _loc1_:ConsoleConfig = console.config;
         var _loc2_:Object = convertTypeToObject(_loc1_);
         _loc2_.style = getStyleToEncode();
         return _loc2_;
      }
      
      protected function getStyleToEncode() : Object
      {
         var _loc1_:ConsoleStyle = console.config.style;
         var _loc2_:Object = convertTypeToObject(_loc1_);
         _loc2_.styleSheet = getStyleSheetToEncode(_loc1_);
         return _loc2_;
      }
      
      protected function getStyleSheetToEncode(param1:ConsoleStyle) : Object
      {
         var _loc3_:Object = {};
         for each(var _loc2_:String in param1.styleSheet.styleNames)
         {
            _loc3_[_loc2_] = param1.styleSheet.getStyle(_loc2_);
         }
         return _loc3_;
      }
      
      protected function getUIDataToEncode() : Object
      {
         var _loc2_:Object = {};
         var _loc1_:MainPanel = console.panels.mainPanel;
         _loc2_.viewingPriority = _loc1_.priority;
         _loc2_.viewingChannels = _loc1_.viewingChannels;
         _loc2_.ignoredChannels = _loc1_.ignoredChannels;
         return _loc2_;
      }
      
      protected function getLogsToEncode() : Object
      {
         var _loc2_:Object = null;
         var _loc3_:Array = [];
         var _loc1_:Log = console.logs.last;
         while(_loc1_)
         {
            _loc2_ = convertTypeToObject(_loc1_);
            delete _loc2_.next;
            delete _loc2_.prev;
            _loc3_.push(_loc2_);
            _loc1_ = _loc1_.prev;
         }
         return _loc3_.reverse();
      }
      
      protected function convertTypeToObject(param1:Object) : Object
      {
         var _loc5_:String = null;
         var _loc4_:Object = {};
         var _loc2_:XML = describeType(param1);
         for each(var _loc3_:XML in _loc2_.variable)
         {
            _loc5_ = _loc3_.@name;
            _loc4_[_loc5_] = param1[_loc5_];
         }
         return _loc4_;
      }
   }
}

