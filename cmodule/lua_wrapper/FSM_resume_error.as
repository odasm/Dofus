package cmodule.lua_wrapper
{
   public final class FSM_resume_error extends Machine
   {
      
      public function FSM_resume_error() {
         super();
      }
      
      public static function start() : void {
         var _loc1_:FSM_resume_error = null;
         _loc1_ = new FSM_resume_error();
         FSM_resume_error.gworker = _loc1_;
      }
      
      public static const intRegCount:int = 8;
      
      public static const NumberRegCount:int = 0;
      
      public var i0:int;
      
      public var i1:int;
      
      public var i2:int;
      
      public var i3:int;
      
      public var i4:int;
      
      public var i5:int;
      
      public var i6:int;
      
      override public final function work() : void {
      }
      
      public var i7:int;
   }
}