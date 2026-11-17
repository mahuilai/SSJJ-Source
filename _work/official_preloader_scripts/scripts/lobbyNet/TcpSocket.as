package lobbyNet
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.Socket;
   import flash.utils.ByteArray;
   
   public class TcpSocket extends EventDispatcher
   {
      
      private var _serverIp:String;
      
      private var _serverPort:uint;
      
      public var socket:Socket;
      
      private var blockedAPC:Array = [];
      
      private var _compressFlag:int;
      
      private var _timeout:uint = 20000;
      
      private var dataLen:int = 0;
      
      private var recvCompressFlag:int = 0;
      
      public function TcpSocket(param1:String, param2:uint)
      {
         super();
         this._serverIp = param1;
         this._serverPort = param2;
         this.socket = new Socket();
         this.socket.endian = "bigEndian";
      }
      
      public function setSocket(param1:Socket) : void
      {
         this.socket = param1;
         this.socket.endian = "bigEndian";
         enable();
      }
      
      public function connect(param1:String = null, param2:uint = 0) : void
      {
         if(socket.connected)
         {
            return;
         }
         if(param1)
         {
            _serverIp = param1;
         }
         if(param2)
         {
            _serverPort = param2;
         }
         enable();
         this.socket.timeout = _timeout;
         this.socket.connect(this._serverIp,this._serverPort);
      }
      
      public function enable() : void
      {
         this.socket.addEventListener("connect",onConnected);
         this.socket.addEventListener("close",onClosed);
         this.socket.addEventListener("ioError",onError);
         this.socket.addEventListener("securityError",secErrorHandler);
         this.socket.addEventListener("socketData",recvData);
      }
      
      public function close() : void
      {
         trace("close#########1");
         this.socket.removeEventListener("connect",onConnected);
         this.socket.removeEventListener("ioError",onError);
         this.socket.removeEventListener("securityError",secErrorHandler);
         this.socket.removeEventListener("socketData",recvData);
         if(socket.connected == false)
         {
            this.socket.addEventListener("ioError",onErrorDoNothing);
         }
         try
         {
            this.socket.close();
         }
         catch(e:Error)
         {
         }
         trace("close#########2");
      }
      
      public function call(param1:String, param2:Array, param3:Boolean = false) : void
      {
         var _loc5_:APC = new APC();
         if(param2 == null)
         {
            param2 = [];
         }
         _loc5_.functionName = param1;
         _loc5_.parameters = param2;
         if(param3)
         {
            _loc5_.isTrace = param3;
         }
         var _loc4_:ByteArray = new ByteArray();
         _loc4_.endian = "bigEndian";
         _loc4_.objectEncoding = 3;
         _loc4_.writeObject(_loc5_);
         if(this.socket != null && this.socket.connected)
         {
            sendBytes(_loc4_);
         }
         else
         {
            blockedAPC.push(_loc4_);
         }
         _loc5_ = null;
      }
      
      private function sendBytes(param1:ByteArray) : void
      {
         if(_compressFlag == 1)
         {
            param1.compress();
         }
         this.socket.writeInt(param1.length + 1);
         this.socket.writeByte(_compressFlag);
         this.socket.writeBytes(param1);
         this.socket.flush();
      }
      
      private function onConnected(param1:Event) : void
      {
         var _loc2_:* = 0;
         _loc2_ = 0;
         while(_loc2_ < blockedAPC.length)
         {
            sendBytes(blockedAPC.shift());
         }
         trace("socket connected");
         dispatchEvent(param1);
      }
      
      private function onClosed(param1:Event) : void
      {
         trace("socket closed");
         this.blockedAPC.length = 0;
         dispatchEvent(param1);
      }
      
      private function onErrorDoNothing(param1:IOErrorEvent) : void
      {
         this.socket.removeEventListener("ioError",onErrorDoNothing);
         param1.stopPropagation();
         trace("socket ioerror");
      }
      
      private function onError(param1:IOErrorEvent) : void
      {
         trace("socket ioerror");
         socket.close();
         this.blockedAPC.length = 0;
         dispatchEvent(param1);
      }
      
      private function secErrorHandler(param1:SecurityErrorEvent) : void
      {
         trace("socket SecurityError");
         socket.close();
         this.blockedAPC.length = 0;
         dispatchEvent(param1);
      }
      
      private function recvData(param1:ProgressEvent) : void
      {
         var _loc2_:ByteArray = null;
         while(true)
         {
            if(dataLen == 0)
            {
               if(socket.connected == false)
               {
                  return;
               }
               if(socket.bytesAvailable < 5)
               {
                  break;
               }
               dataLen = socket.readInt() - 1;
               recvCompressFlag = socket.readByte();
            }
            else
            {
               if(socket.bytesAvailable < dataLen)
               {
                  break;
               }
               _loc2_ = new ByteArray();
               _loc2_.objectEncoding = 3;
               _loc2_.endian = "bigEndian";
               socket.readBytes(_loc2_,0,dataLen);
               dataLen = 0;
               if(recvCompressFlag)
               {
                  _loc2_.uncompress();
               }
               onPacket(_loc2_);
            }
         }
      }
      
      private function onPacket(param1:ByteArray) : void
      {
         var _loc4_:Object = null;
         var _loc2_:APC = null;
         var _loc3_:PacketEvent = null;
         param1.position = 0;
         try
         {
            _loc4_ = param1.readObject();
            _loc2_ = _loc4_ as APC;
            if(_loc2_)
            {
               _loc3_ = new PacketEvent("PACKET_ARRIVE");
               _loc3_.apc = _loc2_;
               dispatchEvent(_loc3_);
            }
         }
         catch(e:Error)
         {
            param1.position = 0;
            trace(e.message);
         }
      }
      
      public function get serverIp() : String
      {
         return this._serverIp;
      }
      
      public function get serverPort() : uint
      {
         return this._serverPort;
      }
      
      public function set compress(param1:Boolean) : void
      {
         _compressFlag = param1 ? 1 : 0;
      }
      
      public function get compress() : Boolean
      {
         return this._compressFlag == 1;
      }
      
      public function set timeout(param1:uint) : void
      {
         _timeout = param1;
      }
      
      public function get timeout() : uint
      {
         return this._timeout;
      }
   }
}

