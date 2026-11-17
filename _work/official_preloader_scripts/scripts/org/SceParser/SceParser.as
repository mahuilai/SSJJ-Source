package org.SceParser
{
   import wdnative.*;
   
   public class SceParser
   {
      
      public function SceParser()
      {
         super();
      }
      
      public static function get MAX_MESHNAME_LEN() : int
      {
         return _wrap_MAX_MESHNAME_LEN_get();
      }
      
      public static function createSceParser(param1:int, param2:int, param3:int) : int
      {
         return _wrap_createSceParser(param1,param2,param3);
      }
      
      public static function getSceHeader(param1:int, param2:int) : Boolean
      {
         return _wrap_getSceHeader(param1,param2);
      }
      
      public static function getSceLadderCount(param1:int) : int
      {
         return _wrap_getSceLadderCount(param1);
      }
      
      public static function getSceMaterial(param1:int, param2:int, param3:int) : Boolean
      {
         return _wrap_getSceMaterial(param1,param2,param3);
      }
      
      public static function getSceTexture(param1:int, param2:int, param3:int) : Boolean
      {
         return _wrap_getSceTexture(param1,param2,param3);
      }
      
      public static function getSceUnique(param1:int, param2:int) : Boolean
      {
         return _wrap_getSceUnique(param1,param2);
      }
      
      public static function getSceLightProbes(param1:int, param2:int, param3:int) : int
      {
         return _wrap_getSceLightProbes(param1,param2,param3);
      }
      
      public static function getScePvs(param1:int, param2:int, param3:int) : int
      {
         return _wrap_getScePvs(param1,param2,param3);
      }
      
      public static function getSceVertex(param1:int, param2:int, param3:int) : Boolean
      {
         return _wrap_getSceVertex(param1,param2,param3);
      }
      
      public static function getSceTriagleVertices(param1:int, param2:int, param3:int, param4:int, param5:int) : Boolean
      {
         return _wrap_getSceTriagleVertices(param1,param2,param3,param4,param5);
      }
      
      public static function getSceTriangle(param1:int, param2:int, param3:int) : Boolean
      {
         return _wrap_getSceTriangle(param1,param2,param3);
      }
      
      public static function getSceMesh(param1:int, param2:int, param3:int) : Boolean
      {
         return _wrap_getSceMesh(param1,param2,param3);
      }
      
      public static function freeSceParser(param1:int) : void
      {
         _wrap_freeSceParser(param1);
      }
   }
}

