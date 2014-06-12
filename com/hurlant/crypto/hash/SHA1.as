package com.hurlant.crypto.hash
{
   public class SHA1 extends SHABase implements IHash
   {
      
      public function SHA1() {
         super();
      }
      
      public static const HASH_SIZE:int = 20;
      
      override public function getHashSize() : uint {
         return HASH_SIZE;
      }
      
      override protected function core(x:Array, len:uint) : Array {
         var olda:uint = 0;
         var oldb:uint = 0;
         var oldc:uint = 0;
         var oldd:uint = 0;
         var olde:uint = 0;
         var j:uint = 0;
         var t:uint = 0;
         x[len >> 5] = x[len >> 5] | 128 << 24 - len % 32;
         x[(len + 64 >> 9 << 4) + 15] = len;
         var w:Array = [];
         var a:uint = 1732584193;
         var b:uint = 4.023233417E9;
         var c:uint = 2.562383102E9;
         var d:uint = 271733878;
         var e:uint = 3.28537752E9;
         var i:uint = 0;
         while(i < x.length)
         {
            olda = a;
            oldb = b;
            oldc = c;
            oldd = d;
            olde = e;
            j = 0;
            while(j < 80)
            {
               if(j < 16)
               {
                  w[j] = x[i + j] || 0;
               }
               else
               {
                  w[j] = this.rol(w[j - 3] ^ w[j - 8] ^ w[j - 14] ^ w[j - 16],1);
               }
               t = this.rol(a,5) + this.ft(j,b,c,d) + e + w[j] + this.kt(j);
               e = d;
               d = c;
               c = this.rol(b,30);
               b = a;
               a = t;
               j++;
            }
            a = a + olda;
            b = b + oldb;
            c = c + oldc;
            d = d + oldd;
            e = e + olde;
            i = i + 16;
         }
         return [a,b,c,d,e];
      }
      
      private function rol(num:uint, cnt:uint) : uint {
         return num << cnt | num >>> 32 - cnt;
      }
      
      private function ft(t:uint, b:uint, c:uint, d:uint) : uint {
         if(t < 20)
         {
            return b & c | ~b & d;
         }
         if(t < 40)
         {
            return b ^ c ^ d;
         }
         if(t < 60)
         {
            return b & c | b & d | c & d;
         }
         return b ^ c ^ d;
      }
      
      private function kt(t:uint) : uint {
         return t < 20?1518500249:t < 40?1859775393:t < 60?2.400959708E9:3.395469782E9;
      }
      
      override public function toString() : String {
         return "sha1";
      }
   }
}