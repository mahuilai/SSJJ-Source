package org.as3commons.logging.util
{
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   
   public function instantiate(param1:Class, param2:Array = null) : *
   {
      var result:* = undefined;
      var l:int = 0;
      var type:Class = param1;
      var args:Array = param2;
      if(Boolean(args) && args.length > 0)
      {
         l = int(int(CACHE[type]) || -1);
         if(l < 0)
         {
            try
            {
               CACHE[type] = l = int(describeType(type).factory.constructor.parameter.length());
            }
            catch(e:Error)
            {
               if(LOGGER.warnEnabled)
               {
                  LOGGER.warn("Could not describe {0} to analyse arguments",[type]);
               }
               CACHE[type] = 0;
            }
         }
         if(l > args.length)
         {
            l = int(args.length);
         }
         if(l == 0)
         {
            result = new type();
         }
         else if(l == 1)
         {
            result = new type(args[0]);
         }
         else if(l == 2)
         {
            result = new type(args[0],args[1]);
         }
         else if(l == 3)
         {
            result = new type(args[0],args[1],args[2]);
         }
         else if(l == 4)
         {
            result = new type(args[0],args[1],args[2],args[3]);
         }
         else if(l == 5)
         {
            result = new type(args[0],args[1],args[2],args[3],args[4]);
         }
         else if(l == 6)
         {
            result = new type(args[0],args[1],args[2],args[3],args[4],args[5]);
         }
         else if(l == 7)
         {
            result = new type(args[0],args[1],args[2],args[3],args[4],args[5],args[6]);
         }
         else if(l == 8)
         {
            result = new type(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
         }
         else if(l == 9)
         {
            result = new type(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8]);
         }
         else if(l == 10)
         {
            result = new type(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9]);
         }
         else if(l == 11)
         {
            result = new type(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10]);
         }
         else if(l == 12)
         {
            result = new type(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10],args[11]);
         }
         else if(l == 13)
         {
            result = new type(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10],args[11],args[12]);
         }
         else
         {
            result = new type(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10],args[11],args[12],args[13]);
         }
      }
      else
      {
         result = new type();
      }
      return result;
   }
}

import flash.utils.Dictionary;
import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

const LOGGER:ILogger = getLogger("org.as3commons.logging.util#instantiate()");

const CACHE:Dictionary = new Dictionary();

