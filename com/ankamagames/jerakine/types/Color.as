package com.ankamagames.jerakine.types
{
   import flash.utils.IExternalizable;
   import com.somerandomdude.colortoolkit.spaces.HSL;
   import com.somerandomdude.colortoolkit.ColorUtil;
   import com.somerandomdude.colortoolkit.Color;
   import com.ankamagames.jerakine.enum.ColorGenerationMethodsEnum;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   
   public class Color extends Object implements IExternalizable
   {
      
      public function Color(color:uint=0) {
         super();
         this.parseColor(color);
      }
      
      public static function toHsl(hex:uint) : HSL {
         return ColorUtil.toHSL(hex as int);
      }
      
      public static function toHex(hsl:HSL) : uint {
         return hsl.color as uint;
      }
      
      public static function setHSLlightness(color:uint, lightness:Number) : uint {
         var hsl:HSL = toHsl(color);
         hsl.lightness = lightness;
         return toHex(hsl);
      }
      
      public static function setHSVSaturation(color:uint, saturation:Number) : uint {
         var hsl:HSL = toHsl(color);
         hsl.saturation = saturation;
         return toHex(hsl);
      }
      
      public static function generateColorList(methode:int) : Array {
         var n:uint = Math.random() * 16777215;
         var motherColor:Color = new com.somerandomdude.colortoolkit.Color(n);
         switch(methode)
         {
            case ColorGenerationMethodsEnum.MONOCHROME:
               return motherColor.monochromeScheme.toHex() as Array;
            case ColorGenerationMethodsEnum.ANALOGOUS:
               return motherColor.analogousScheme.toHex() as Array;
            case ColorGenerationMethodsEnum.COMPLEMENTARY:
               return motherColor.complemenartyScheme.toHex() as Array;
            case ColorGenerationMethodsEnum.COMPOUND:
               return motherColor.compoundScheme.toHex() as Array;
            case ColorGenerationMethodsEnum.TETRAD:
               return motherColor.tetradScheme.toHex() as Array;
            case ColorGenerationMethodsEnum.FLIPPED_COMPOUND:
               return motherColor.flippedCompoundScheme.toHex() as Array;
         }
      }
      
      public var red:uint;
      
      public var green:uint;
      
      public var blue:uint;
      
      public function get color() : uint {
         return (this.red & 255) << 16 | (this.green & 255) << 8 | this.blue & 255;
      }
      
      public function set color(value:uint) : void {
         this.parseColor(value);
      }
      
      public function readExternal(input:IDataInput) : void {
         this.red = input.readUnsignedByte();
         this.green = input.readUnsignedByte();
         this.blue = input.readUnsignedByte();
      }
      
      public function writeExternal(output:IDataOutput) : void {
         output.writeByte(this.red);
         output.writeByte(this.green);
         output.writeByte(this.blue);
      }
      
      public function toString() : String {
         return "[AdvancedColor(R=\"" + this.red + "\",G=\"" + this.green + "\",B=\"" + this.blue + "\")]";
      }
      
      public function release() : void {
         this.red = this.green = this.blue = 0;
      }
      
      public function adjustDarkness(nValue:Number) : void {
         this.red = (1 - nValue) * this.red;
         this.green = (1 - nValue) * this.green;
         this.blue = (1 - nValue) * this.blue;
      }
      
      public function adjustLight(nValue:Number) : void {
         this.red = this.red + nValue * (255 - this.red);
         this.green = this.green + nValue * (255 - this.green);
         this.blue = this.blue + nValue * (255 - this.blue);
      }
      
      private function parseColor(color:uint) : void {
         this.red = (color & 16711680) >> 16;
         this.green = (color & 65280) >> 8;
         this.blue = color & 255;
      }
   }
}
