//+------------------------------------------------------------------+
//|                                                  CB_SwapInfo.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window



#define WINDOW_MAIN 0
input string format_buy = "Buy:%2.2f";
input string format_sell = "Sell:%2.2f";

input color  Text_Color = clrBlack; // Text Color
input int    Text_Size = 7; // Text Size
input string Text_Font = "Verdana"; // Text Type
input int    Corner_ = 0; // Corner
input int    Left_Right = 20; // Left - Right
input int    Up_Down = 50; // Up - Dowm
input int    DOTSIZE = 20;
input int    XDIFF=30;

string symbol_basename = "INFO";

void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, symbol_basename);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
      DrawSymbol(true);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSymbol(bool positiv)
  {
   color clrS = clrGray;
   color clrB = clrGray;
   uint twidth,theight;
   int xoffset=0;
   double swap_long = SymbolInfoDouble(Symbol(), SYMBOL_SWAP_LONG);
   double swap_short = SymbolInfoDouble(Symbol(), SYMBOL_SWAP_SHORT);
   double spread = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD);
   string infoB = StringFormat(format_buy,  swap_long);
   string infoS = StringFormat(format_sell,  swap_short);
   if(swap_long > 0)
      clrB = clrGreen;
   if(swap_short > 0)
      clrS = clrGreen;
   DrawDot(symbol_basename + "symbB", clrB,xoffset);
   xoffset=XDIFF;
   DrawInfo(symbol_basename + "InfoN", infoB,xoffset );
   
   TextGetSize(infoB,twidth,theight);
   xoffset+=twidth+XDIFF;
   DrawDot(symbol_basename + "symbS", clrS,xoffset);
   xoffset+=XDIFF;
   DrawInfo(symbol_basename + "InfoS", infoS,xoffset);

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawDot(string name, color clr, int xoffset)
  {
   if(ObjectFind(WINDOW_MAIN,name) != -1)
     {
      ObjectDelete(WINDOW_MAIN,name);
     }
   if(ObjectCreate(WINDOW_MAIN,name, OBJ_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(WINDOW_MAIN,name, OBJPROP_CORNER, Corner_);
      ObjectSetInteger(WINDOW_MAIN,name, OBJPROP_XDISTANCE, Left_Right+xoffset);
      ObjectSetInteger(WINDOW_MAIN,name, OBJPROP_YDISTANCE, Up_Down - DOTSIZE*0.6);
      ObjectSetString(WINDOW_MAIN,name, OBJPROP_TEXT,CharToString(159));
      ObjectSetInteger(WINDOW_MAIN,name,OBJPROP_FONTSIZE,DOTSIZE );
      ObjectSetString(WINDOW_MAIN,name,OBJPROP_FONT, "Wingdings");
      ObjectSetInteger(WINDOW_MAIN,name,OBJPROP_COLOR, clr);

     }
  }
//+------------------------------------------------------------------+
void DrawInfo(string name, string text, int xoffset)
  {
   if(ObjectFind(WINDOW_MAIN,name) != -1)
     {
      ObjectDelete(WINDOW_MAIN,name);
     }
   if(ObjectCreate(WINDOW_MAIN,name, OBJ_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(WINDOW_MAIN,name, OBJPROP_CORNER, Corner_);
      ObjectSetInteger(WINDOW_MAIN,name, OBJPROP_XDISTANCE, Left_Right + xoffset);
      ObjectSetInteger(WINDOW_MAIN,name, OBJPROP_YDISTANCE, Up_Down);
      ObjectSetString(WINDOW_MAIN,name, OBJPROP_TEXT,text);
      ObjectSetInteger(WINDOW_MAIN,name,OBJPROP_FONTSIZE,Text_Size );
      ObjectSetString(WINDOW_MAIN,name,OBJPROP_FONT,Text_Font);
      ObjectSetInteger(WINDOW_MAIN,name,OBJPROP_COLOR, Text_Color);
      
     }
  }
//+------------------------------------------------------------------+
