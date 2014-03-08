package com.ankamagames.jerakine.types.events
{
   import flash.events.Event;
   
   public class ErrorReportedEvent extends Event
   {
      
      public function ErrorReportedEvent(error:Error, text:String, pShowPopup:Boolean=true) {
         super(ERROR,false,false);
         this._error = error;
         this._text = text;
         this._showPopup = pShowPopup;
      }
      
      public static const ERROR:String = "ErrorReportedEvent";
      
      private var _error:Error;
      
      private var _text:String;
      
      private var _showPopup:Boolean;
      
      public function get error() : Error {
         return this._error;
      }
      
      public function get text() : String {
         return this._text;
      }
      
      public function get showPopup() : Boolean {
         return this._showPopup;
      }
      
      public function get errorType() : String {
         if(this.error == null)
         {
            return "";
         }
         var tmp1:Array = this.error.toString().split(":");
         return tmp1[0];
      }
   }
}
