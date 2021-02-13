//+------------------------------------------------------------------+
//|                                                  TFConverter.mqh |
//|                                                   Christof Blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int stringToTimeFrame(string tfs)
  {
   tfs = StringUpperCase(tfs);
   for(int i=ArraySize(iTfTable)-1; i>=0; i--)
      if(tfs==sTfTable[i] || tfs==""+iTfTable[i])
         return(MathMax(iTfTable[i],Period()));
   return(Period());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
  {
   for(int i=ArraySize(iTfTable)-1; i>=0; i--)
      if(tf==iTfTable[i])
         return(sTfTable[i]);
   return("");
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringUpperCase(string str)
  {
   string   s = str;

   for(int length=StringLen(str)-1; length>=0; length--)
     {
      int char_A = StringGetChar(s, length);
      if((char_A > 96 && char_A < 123) || (char_A > 223 && char_A < 256))
         s = StringSetChar(s, length, char_A - 32);
      else
         if(char_A > -33 && char_A < 0)
            s = StringSetChar(s, length, char_A + 224);
     }
   return(s);
  }
//+------------------------------------------------------------------+
