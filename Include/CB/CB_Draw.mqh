//+------------------------------------------------------------------+
//|                                                      CB_Draw.mqh |
//|                                                   Christof blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof blank"
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
void DrawIndicator(string name, int shift, double val0, double val1, bool asDot, color clr = clrBlue)
  {
   if(Bars(NULL, 0) - 1 < shift)
      return;
// print(__FUNCTION__,"Bars(NULL,0)="+ Bars(NULL,0));
   string EMAName = name + (string)iTime(NULL, 0, shift);
   if(ObjectFind(0, EMAName) >= 0)
     {
      ObjectDelete(0, EMAName);
     }
   if(asDot)
     {
      //   TLine(shift,EMAName,EMAName,iTime(NULL,0,shift),val0,iTime(NULL,0,shift),val0,clr,true,false,0,2);
      //     ObjectCreate(EMAName,OBJ_TREND,0,iTime(NULL,0,shift),val0,iTime(NULL,0,shift),val0+1*Point());
      ObjectCreate(0, EMAName, OBJ_TREND, 0, iTime(NULL, 0, shift), val0, iTime(NULL, 0, shift), val0 + 3 * Point());
      ObjectSetInteger(0, EMAName, OBJPROP_RAY, (long)false);
      ObjectSetInteger(0, EMAName, OBJPROP_WIDTH, 3);
      //  ObjectCreate(EMAName,OBJ_ELLIPSE,0,iTime(NULL,0,shift),val0,iTime(NULL,0,shift),val0);
      ObjectSetInteger(0, EMAName, OBJPROP_COLOR, clr);
     }
   else
     {
      //    TLine(shift,EMAName,EMAName,iTime(NULL,0,shift),val0,iTime(NULL,0,shift+1),val1,clr,true,false,0,2);
      ObjectCreate(0, EMAName, OBJ_TREND, 0, iTime(NULL, 0, shift), val0, iTime(NULL, 0, shift + 1), val1);
      ObjectSetInteger(0, EMAName, OBJPROP_RAY, (long)false);
      ObjectSetInteger(0, EMAName, OBJPROP_COLOR, clr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawArrow(string name, int shift, double price, int mode, color clr = clrBlue)
  {
   if(Bars(NULL, 0) - 1 < shift)
      return;
// print(__FUNCTION__,"Bars(NULL,0)="+ Bars(NULL,0));
   string EMAName = name + (string)iTime(NULL, 0, shift);
   if(ObjectFind(0, EMAName) >= 0)
     {
      ObjectDelete(0, EMAName);
     }
   if(mode == ORDER_TYPE_BUY)
     {
      //ObjectCreate(chart_ID,name,OBJ_ARROW_THUMB_UP,sub_window,time,price
      // ObjectCreate(chart_ID,name,OBJ_ARROW_BUY,sub_window,time,price))
      ObjectCreate(0, EMAName, OBJ_ARROW_BUY, 0, iTime(NULL, 0, shift), price);
     }
   else
     {
      ObjectCreate(0, EMAName, OBJ_ARROW_SELL, 0, iTime(NULL, 0, shift), price);
     }
   ObjectSetInteger(0, EMAName, OBJPROP_WIDTH, 3);
//  ObjectCreate(EMAName,OBJ_ELLIPSE,0,iTime(NULL,0,shift),val0,iTime(NULL,0,shift),val0);
   ObjectSetInteger(0, EMAName, OBJPROP_COLOR, clr);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawArrowXL(string name, int shift, double price, int arrow_code = 108, int arrow_width = 3, color clr = clrBlue)
  {
   if(Bars(NULL, 0) - 1 < shift)
      return;
// print(__FUNCTION__,"Bars(NULL,0)="+ Bars(NULL,0));
   string EMAName = name + (string)iTime(NULL, 0, shift);
   if(ObjectFind(0, EMAName) >= 0)
     {
      ObjectDelete(0, EMAName);
     }
   ObjectCreate(0, EMAName, OBJ_ARROW_CHECK, 0, iTime(NULL, 0, shift), price);
   ObjectSetInteger(0, EMAName, OBJPROP_ARROWCODE, arrow_code);
   ObjectSetInteger(0, EMAName, OBJPROP_WIDTH, arrow_width);
//  ObjectCreate(EMAName,OBJ_ELLIPSE,0,iTime(NULL,0,shift),val0,iTime(NULL,0,shift),val0);
   ObjectSetInteger(0, EMAName, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawDot(string name, int shift, double price, color clr = clrBlue, int code = 159, int width = 1)
  {
   if(Bars(NULL, 0) - 1 < shift)
      return;
// print(__FUNCTION__,"Bars(NULL,0)="+ Bars(NULL,0));
   string EMAName = name + (string)iTime(NULL, 0, shift);
   if(ObjectFind(0, EMAName) >= 0)
     {
      ObjectDelete(0, EMAName);
     }
   ObjectCreate(0, EMAName, OBJ_ARROW_BUY, 0, iTime(NULL, 0, shift), price);
   ObjectSetInteger(0, EMAName, OBJPROP_ARROWCODE, code);
   ObjectSetInteger(0, EMAName, OBJPROP_WIDTH, width);
//  ObjectCreate(EMAName,OBJ_ELLIPSE,0,iTime(NULL,0,shift),val0,iTime(NULL,0,shift),val0);
   ObjectSetInteger(0, EMAName, OBJPROP_COLOR, clr);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawInfoText(string name, int shift, double price, string info, int anchor = ANCHOR_LEFT_UPPER, int angle = 0, color clr = clrBlue)
  {
   if(Bars(NULL, 0) - 1 < shift)
      return;
// print(__FUNCTION__,"Bars(NULL,0)="+ Bars(NULL,0));
   string EMAName = name + (string)iTime(NULL, 0, shift);
   if(ObjectFind(0, EMAName) >= 0)
     {
      ObjectDelete(0, EMAName);
     }
   ObjectCreate(0, EMAName, OBJ_TEXT, 0, iTime(NULL, 0, shift), price);
   ObjectSetString(0, EMAName, OBJPROP_TEXT, info);
   ObjectSetString(0, EMAName, OBJPROP_TOOLTIP, info);
   ObjectSetDouble(0, EMAName, OBJPROP_ANGLE, angle);
   ObjectSetInteger(0, EMAName, OBJPROP_ANCHOR, anchor);
//  ObjectSet(EMAName, OBJPROP_WIDTH, width);
//  ObjectCreate(EMAName,OBJ_ELLIPSE,0,iTime(NULL,0,shift),val0,iTime(NULL,0,shift),val0);
   ObjectSetInteger(0, EMAName, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLine(string name, int shift, double val0, double val1, color clr = clrBlue)
  {
   if(Bars(NULL, 0) - 1 < shift)
      return;
   if(val0 == 0 || val0 == EMPTY_VALUE || val1 == 0 || val1 == EMPTY_VALUE)
      return;
// print(__FUNCTION__,"Bars(NULL,0)="+ Bars(NULL,0));
   string EMAName = name + (string)iTime(NULL, 0, shift);
   if(ObjectFind(0, EMAName) >= 0)
     {
      ObjectDelete(0, EMAName);
     }
//    TLine(shift,EMAName,EMAName,iTime(NULL,0,shift),val0,iTime(NULL,0,shift+1),val1,clr,true,false,0,2);
   ObjectCreate(0, EMAName, OBJ_TREND, 0, iTime(NULL, 0, shift), val0, iTime(NULL, 0, shift + 1), val1);
   ObjectSetInteger(0, EMAName, OBJPROP_RAY, (long) false);
   ObjectSetInteger(0, EMAName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, EMAName, OBJPROP_WIDTH, 3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLine(string name, int shift0, int shift1, double val0, double val1, color clr = clrBlue, int width = 1)
  {
   if(Bars(NULL, 0) - 1 < shift1)
      return;
// print(__FUNCTION__,"Bars(NULL,0)="+ Bars(NULL,0));
   string EMAName = name + (string)iTime(NULL, 0, shift0);
   if(ObjectFind(0, EMAName) >= 0)
     {
      ObjectDelete(0, EMAName);
     }
//    TLine(shift,EMAName,EMAName,iTime(NULL,0,shift),val0,iTime(NULL,0,shift+1),val1,clr,true,false,0,2);
   ObjectCreate(EMAName, OBJ_TREND, 0, iTime(NULL, 0, shift0), val0, iTime(NULL, 0, shift1), val1);
   ObjectSetInteger(0, EMAName, OBJPROP_RAY, (long)false);
   ObjectSetInteger(0, EMAName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, EMAName, OBJPROP_WIDTH, width);
  }
//+------------------------------------------------------------------+
