//+------------------------------------------------------------------+
//|                                                   DLLExample.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


// C#
#import "MQLIntegrationCs.dll"
   int Add(int left,int right);
   int Sub(int left,int right);
   float AddFloat(float left,float right);
   double AddDouble(double left,double right);
   

#import "speak5.dll"
int gSpeak(string text);

#import
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   Print("############ Gateway initiated");
   
   gSpeak("Hallo Christof");
   
   Print("Hello C#: 2+3 = ",Add(2, 3));
  }
//+------------------------------------------------------------------+
