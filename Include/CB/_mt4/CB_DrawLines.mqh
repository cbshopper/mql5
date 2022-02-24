//+------------------------------------------------------------------+
//|                                                 CB_DrawLines.mqh |
//|                                                   Christof blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof blank"
#property link      "https://www.mql5.com"
#property strict

extern string line1="-------- Line Settings ----------";
extern string BuyStop_LineName = "buystop";
extern string SellStop_LineName = "sellstop";
extern string BuyLimit_LineName = "buylimit";
extern string SellLimit_LineName = "selllimit";

extern color BuyStopColor = clrBlue;
extern color SellStopColor = clrRed;
extern color BuyLimitColor = clrAquamarine;
extern color SellLimitColor = clrGoldenrod;
extern int  linewidth = 3;
extern int  initial_distance=20;
extern bool selected = true;
extern bool ray_linemode = true;
extern int   BackBars = 20;

#ifndef WINDOW_MAIN
#define WINDOW_MAIN 0
#endif

#include <cb\CBUtils5.mqh>

bool drawBuyLine (string name,color colr, int offset=0)
{
   datetime T0,T1;
   double P0, P1;
   T0 = iTime(NULL,0,0);
   T1 = iTime(NULL,0,BackBars);
   if(ObjectFind(name) < 0)
     {
      int h = iHighest(NULL,0,MODE_HIGH,BackBars,0);
      P0 = iHigh(NULL,0,h) + (initial_distance+offset)*Point();
      P1 = P0;
      ObjectCreate(name,OBJ_TREND,WINDOW_MAIN,T1,P1,T0,P0);
      ObjectSet(name,OBJPROP_COLOR,colr);
      commonFormats(name);
      return true;
     }
   return false;  
}
bool drawSellLine (string name,color colr,int offset=0)
{
   datetime T0,T1;
   double P0, P1;
   T0 = iTime(NULL,0,0);
   T1 = iTime(NULL,0,BackBars);
   if(ObjectFind(name) < 0)
     {
      int l = iLowest(NULL,0,MODE_LOW,BackBars,0);
      P0 = iLow(NULL,0,l) - (initial_distance+offset)*Point();
      P1 = P0;
      ObjectCreate(name,OBJ_TREND,WINDOW_MAIN,T1,P1,T0,P0);
      ObjectSet(name,OBJPROP_COLOR,colr);
      commonFormats(name);
      return true;
     }
   return false;  
}
//+------------------------------------------------------------------+
void DrawStopLines()
  {
//---
   drawBuyLine(BuyStop_LineName,BuyStopColor);
   drawSellLine(SellStop_LineName,SellStopColor);
   
  }
//+------------------------------------------------------------------+
void DrawLimitLines()
  {
//---

   drawBuyLine(BuyLimit_LineName,BuyLimitColor,10);
   drawSellLine(SellLimit_LineName,SellLimitColor,10);
   
  }  
//+------------------------------------------------------------------+
/*
void DrawLinesBAK()
  {
//---
   datetime T0,T1;
   double P0, P1;
   string name = BuyStop_TrendName;
   T0 = iTime(NULL,0,0);
   T1 = iTime(NULL,0,BackBars);

   if(ObjectFind(name) < 0)
     {
      int h = iHighest(NULL,0,MODE_HIGH,BackBars,0);
      P0 = High[h] + initial_distance*Point;
      P1 = P0;
      ObjectCreate(name,OBJ_TREND,WINDOW_MAIN,T1,P1,T0,P0);
      ObjectSet(name,OBJPROP_COLOR,BuyColor);
      commonFormats(name);
     }

   name =  SellStop_TrendName;
   if(ObjectFind(name) < 0)
     {
      int l = iLowest(NULL,0,MODE_LOW,BackBars,0);
      P0 = Low[l] - initial_distance*Point;
      P1 = P0;
      ObjectCreate(name,OBJ_TREND,WINDOW_MAIN,T1,P1,T0,P0);
      ObjectSet(name,OBJPROP_COLOR,SellColor);
      commonFormats(name);
     }
  }
  */
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void commonFormats(string name)
  {
   ObjectSet(name,OBJPROP_WIDTH,linewidth);
   ObjectSet(name,OBJPROP_RAY,false);
   ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(name,OBJPROP_RAY,false);
   ObjectSet(name,OBJPROP_SELECTED,selected);
   ObjectSet(name,OBJPROP_RAY_RIGHT,ray_linemode);

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EraseLines()
  {
   ObjectDelete(BuyStop_LineName);
   ObjectDelete(SellStop_LineName);
   ObjectDelete(BuyLimit_LineName);
   ObjectDelete(SellLimit_LineName);


  }