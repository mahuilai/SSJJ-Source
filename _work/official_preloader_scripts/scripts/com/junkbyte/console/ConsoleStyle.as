package com.junkbyte.console
{
   import flash.text.StyleSheet;
   
   public class ConsoleStyle
   {
      
      public var menuFont:String = "Arial";
      
      public var menuFontSize:int = 12;
      
      public var traceFont:String = "Verdana";
      
      public var traceFontSize:int = 11;
      
      public var backgroundColor:uint;
      
      public var backgroundAlpha:Number = 0.9;
      
      public var controlColor:uint = 10027008;
      
      public var controlSize:uint = 5;
      
      public var commandLineColor:uint = 1092096;
      
      public var highColor:uint = 16777215;
      
      public var lowColor:uint = 12632256;
      
      public var logHeaderColor:uint = 12632256;
      
      public var menuColor:uint = 16746496;
      
      public var menuHighlightColor:uint = 14505216;
      
      public var channelsColor:uint = 16777215;
      
      public var channelColor:uint = 39372;
      
      public var priority0:uint = 3831610;
      
      public var priority1:uint = 4495684;
      
      public var priority2:uint = 7846775;
      
      public var priority3:uint = 10539168;
      
      public var priority4:uint = 14085846;
      
      public var priority5:uint = 15329769;
      
      public var priority6:uint = 16768477;
      
      public var priority7:uint = 16755370;
      
      public var priority8:uint = 16742263;
      
      public var priority9:uint = 16720418;
      
      public var priority10:uint = 16720418;
      
      public var priorityC1:uint = 39372;
      
      public var priorityC2:uint = 16746496;
      
      public var topMenu:Boolean = true;
      
      public var showCommandLineScope:Boolean = true;
      
      public var maxChannelsInMenu:int = 7;
      
      public var panelSnapping:int = 3;
      
      public var roundBorder:int = 10;
      
      private var _css:StyleSheet;
      
      public function ConsoleStyle()
      {
         super();
         _css = new StyleSheet();
      }
      
      public function whiteBase() : void
      {
         backgroundColor = 16777215;
         controlColor = 16724787;
         commandLineColor = 6736896;
         highColor = 0;
         lowColor = 3355443;
         logHeaderColor = 4473924;
         menuColor = 13373696;
         menuHighlightColor = 8917248;
         channelsColor = 0;
         channelColor = 26282;
         priority0 = 4497476;
         priority1 = 3379251;
         priority2 = 2258722;
         priority3 = 1135889;
         priority4 = 13056;
         priority5 = 0;
         priority6 = 6684672;
         priority7 = 10027008;
         priority8 = 12255232;
         priority9 = 14483456;
         priority10 = 14483456;
         priorityC1 = 39372;
         priorityC2 = 16737792;
      }
      
      public function big() : void
      {
         traceFontSize = 13;
         menuFontSize = 14;
      }
      
      public function updateStyleSheet() : void
      {
         _css.setStyle("high",{
            "color":hesh(highColor),
            "fontFamily":menuFont,
            "fontSize":menuFontSize,
            "display":"inline"
         });
         _css.setStyle("low",{
            "color":hesh(lowColor),
            "fontFamily":menuFont,
            "fontSize":menuFontSize - 2,
            "display":"inline"
         });
         _css.setStyle("menu",{
            "color":hesh(menuColor),
            "display":"inline"
         });
         _css.setStyle("menuHi",{
            "color":hesh(menuHighlightColor),
            "display":"inline"
         });
         _css.setStyle("chs",{
            "color":hesh(channelsColor),
            "fontSize":menuFontSize,
            "leading":"2",
            "display":"inline"
         });
         _css.setStyle("ch",{
            "color":hesh(channelColor),
            "display":"inline"
         });
         _css.setStyle("tt",{
            "color":hesh(menuColor),
            "fontFamily":menuFont,
            "fontSize":menuFontSize,
            "textAlign":"center"
         });
         _css.setStyle("r",{
            "textAlign":"right",
            "display":"inline"
         });
         _css.setStyle("p",{
            "fontFamily":traceFont,
            "fontSize":traceFontSize
         });
         _css.setStyle("p0",{
            "color":hesh(priority0),
            "display":"inline"
         });
         _css.setStyle("p1",{
            "color":hesh(priority1),
            "display":"inline"
         });
         _css.setStyle("p2",{
            "color":hesh(priority2),
            "display":"inline"
         });
         _css.setStyle("p3",{
            "color":hesh(priority3),
            "display":"inline"
         });
         _css.setStyle("p4",{
            "color":hesh(priority4),
            "display":"inline"
         });
         _css.setStyle("p5",{
            "color":hesh(priority5),
            "display":"inline"
         });
         _css.setStyle("p6",{
            "color":hesh(priority6),
            "display":"inline"
         });
         _css.setStyle("p7",{
            "color":hesh(priority7),
            "display":"inline"
         });
         _css.setStyle("p8",{
            "color":hesh(priority8),
            "display":"inline"
         });
         _css.setStyle("p9",{
            "color":hesh(priority9),
            "display":"inline"
         });
         _css.setStyle("p10",{
            "color":hesh(priority10),
            "fontWeight":"bold",
            "display":"inline"
         });
         _css.setStyle("p-1",{
            "color":hesh(priorityC1),
            "display":"inline"
         });
         _css.setStyle("p-2",{
            "color":hesh(priorityC2),
            "display":"inline"
         });
         _css.setStyle("logs",{
            "color":hesh(logHeaderColor),
            "display":"inline"
         });
      }
      
      public function get styleSheet() : StyleSheet
      {
         return _css;
      }
      
      private function hesh(param1:Number) : String
      {
         return "#" + param1.toString(16);
      }
   }
}

