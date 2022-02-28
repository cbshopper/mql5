//+------------------------------------------------------------------+
//|                                                   CB_Drawing.mqh |
//+------------------------------------------------------------------+

//#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

#define WINDOW_MAIN 0
#define CB_DRAWING_INCLUDED
#include <CB\CB_Draw.mqh>
#include <CB\CB_MT4_object.mqh>
#include <CB\CB_Utils.mqh>

extern string Program;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createNameLine(int index, string postfix = "")
  {
   return StringFormat("L#%s-%d%s", Program, iTime(NULL, 0, index), postfix);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createNameText(int index, string postfix = "")
  {
   return StringFormat("T#%s-%d%s", Program, iTime(NULL, 0, index), postfix);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createNameMarker(int index, string postfix = "")
  {
   return StringFormat("M#%s-%d%s", Program, iTime(NULL, 0, index), postfix);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createNameLabel(int index, string postfix = "")
  {
   return StringFormat("L#%s-%d%s", Program, index, postfix);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TLine(int index, string text, string postfix, datetime T0, double P0, datetime T1, double P1
             , color clr, bool asLine = false, bool ray = false, int offset = 0, int width = 3)
  {
//  if(!Show.Objects)  return;
   string name = createNameLine(index, postfix);
   P0 = P0 + offset * Point();
   P1 = P1 + offset * Point();
   if(ObjectFind(WINDOW_MAIN, name)>=0)
     {
      if(ObjectMove(WINDOW_MAIN, name, 0, T0, P0))
        {
         ObjectMove(WINDOW_MAIN, name, 1, T1, P1);
        }
     }
   else
      if(!ObjectCreate(WINDOW_MAIN, name, OBJ_TREND, WINDOW_MAIN, T0, P0, T1, P1))
        {
         Print("ObjectCreate(", name, ",TREND) failed: ", GetLastError());
        }
      else
        {
         ObjectSetInteger(WINDOW_MAIN, name, OBJPROP_RAY_LEFT, ray);
         ObjectSetInteger(WINDOW_MAIN, name, OBJPROP_RAY_RIGHT, ray);
        }
   if(asLine)
     {
      if(!ObjectSetInteger(WINDOW_MAIN, name, OBJPROP_WIDTH, width))
        {
         Print("ObjectSetInteger(", name, ",OBJPROP_WIDTH) failed: ", GetLastError());
        }
     }
   if(!ObjectSetInteger(WINDOW_MAIN, name, OBJPROP_STYLE, STYLE_DOT))
     {
      Print("ObjectSet(", name, ",OBJPROP_STYLE) failed: ", GetLastError());
     }
   if(!ObjectSetInteger(WINDOW_MAIN, name, OBJPROP_COLOR, clr)) // Allow color change
      Print("ObjectSet(", name, ",Color) [2] failed: ", GetLastError());
   if(!ObjectSetString(WINDOW_MAIN, name, OBJPROP_TEXT, text))
      Print("ObjectSetText(", name, ") [2] failed: ", GetLastError());
   return name;
  }

//+------------------------------------------------------------------+
string  DrawOrderLine(int startbar, int stopbar, int signal, int offset = 0, int width=3, int sl=0, int tp=0)
  {
   string ret = "";
   double winval = 0;
   
   if(startbar > 0)
     {
      color clr = clrGreen;
      string prefix = "WIN!";
      int pips = CalcOrderResultValues(startbar,stopbar,signal,sl,tp,winval);
      /*
      if(signal == 1)
        {
         win = iClose(NULL, 0, stopbar) - iClose(NULL, 0, startbar);
        }
      if(signal == -1)
        {
         win = iClose(NULL, 0, startbar) - iClose(NULL, 0, stopbar);
        }
      
      win = NormalizeDouble(win, Digits());
      pips = (int)(win / Point());
      //string name=StringFormat("LINE %d to %d (%d) %s",startbar,stopbar,pips,prefix);
      double lotsize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_CONTRACT_SIZE);
      long leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
      if(leverage == 0)
         leverage = 1;
      
      double winval = win * lotsize / leverage;
      */
      if(winval < 0)
        {
         clr = clrRed;
         prefix = "LOST!";
        // width += 1;
        }
      
      string name = StringFormat("%s to %s \nPips=%d\nVal=%f\n(%s) ", TimeToString(iTime(NULL, 0, startbar)), TimeToString(iTime(NULL, 0, stopbar)), pips, winval, prefix);
      int index = startbar;
      ret = TLine(index, name, "", iTime(NULL, 0, startbar), iOpen(NULL, 0, startbar), iTime(NULL, 0, stopbar), iOpen(NULL, 0, stopbar), clr, true, false, offset, width);
     }
   return ret;
  }
string  DrawOrderLine(int startbar, int stopbar, int pips, double winval, int offset = 0, int width=3)
  {
   string ret = "";
   
   if(startbar > 0)
     {
      color clr = clrGreen;
      string prefix = "WIN!";
     
      if(winval < 0)
        {
         clr = clrRed;
         prefix = "LOST!";
      //   width += 1;
        }
      
      string name = StringFormat("%s to %s \nPips=%d\nVal=%f\n(%s) ", TimeToString(iTime(NULL, 0, startbar)), TimeToString(iTime(NULL, 0, stopbar)), pips, winval, prefix);
      int index = startbar;
      ret = TLine(index, name, "", iTime(NULL, 0, startbar), iOpen(NULL, 0, startbar), iTime(NULL, 0, stopbar), iOpen(NULL, 0, stopbar), clr, true, false, offset, width);
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string  DrawSimpleLine(int startbar, int stopbar, int Y1, int Y2, string label, int offset = 0)
  {
   string ret = "";
   double win = 0;
   int width = 3;
   if(startbar > 0)
     {
      color clr = clrBlack;
      string name = StringFormat("%s (%s to %s) ", label, TimeToString(iTime(NULL, 0, startbar)), TimeToString(iTime(NULL, 0, stopbar)));
      int index = startbar;
      ret = TLine(index, name, "", iTime(NULL, 0, startbar), Y1, iTime(NULL, 0, stopbar), Y2, clr, true, false, offset, width);
     }
   return ret;
  }

//+------------------------------------------------------------------+
void DeleteTLines(string postfix = "")
  {
   for(int i = 0; i < Bars(NULL, 0) - 1; i++)
     {
      string name = createNameLine(i, postfix);
      bool deleted = ObjectDelete(0, name);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteText(string postfix = "")
  {
   for(int i = 0; i < Bars(NULL, 0) - 1; i++)
     {
      string name = createNameText(i, postfix);
      bool deleted = ObjectDelete(0, name);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteMarker(string postfix = "")
  {
   for(int i = 0; i < Bars(NULL, 0) - 1; i++)
     {
      string name = createNameMarker(i, postfix);
      bool deleted = ObjectDelete(0, name);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteLabels(string postfix = "")
  {
   for(int i = 0; i < Bars(NULL, 0) - 1; i++)
     {
      string name = createNameLabel(i, postfix);
      bool deleted = ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateText(int shift, double Price, string text, string postfix = "")
  {
//              const string            name="Text";              // object name
//              const int               sub_window=0;             // subwindow index
//              datetime                time=0;                   // anchor point time
//              double                  price=0;                  // anchor point price
//              const string            text="Text";              // the text itself
   const string            font = "Arial";           // font
   const int               font_size = 9;           // font size
   const color             clr = clrBlue;             // color
   double                  angle = 45.0;              // text slope
   const ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER; // anchor type
   const bool              back = false;             // in the background
   const bool              selection = false;        // highlight to move
   const bool              hidden = false;            // hidden in the object list
   const long              z_order = 0;
   string name = createNameText(shift, postfix);
   long chart_ID = ChartID();
   datetime t = iTime(NULL, 0, shift);
   double p = Price;
//--- creating label object (it does not have time/price coordinates)
// if(shift >10000) return;
   if(ObjectFind(chart_ID, name) < 0)
     {
      if(!ObjectCreate(chart_ID, name, OBJ_TEXT, 0, t, p))
        {
         int err = GetLastError();
         Print(__FUNCTION__, "Error: can't create Text \"" + name + "\" code #", err);
         return;
        }
     }
   if(true)
     {
      if(p < iLow(NULL, 0, shift))
        {
         angle = -45.0;
        }
      //    Print(__FUNCTION__,"Text created at shift=",shift," Price=",Price);
      //--- set color to Red
      //    ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clrRed);
      //   ObjectSetText(name,"$",13,"Arial",Red);
      //     ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      //--- set the text
      ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
      //--- set text font
      ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
      //--- set font size
      ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
      //--- set the slope angle of the text
      ObjectSetDouble(chart_ID, name, OBJPROP_ANGLE, angle);
      //--- set anchor type
      ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor);
      //--- set color
      ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
      //--- display in the foreground (false) or background (true)
      ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
      //--- enable (true) or disable (false) the mode of moving the object by mouse
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
      ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
      //--- hide (true) or display (false) graphical object name in the object list
      ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
      //--- set the priority for receiving the event of a mouse click in the chart
      ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
      //    ObjectSet(obj_name, OBJPROP_COLOR, Red);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateMarker(int shift, double Price, ENUM_OBJECT obj = OBJ_ARROW_CHECK, string Postfix = "")
  {
//              const string            name="Text";              // object name
//              const int               sub_window=0;             // subwindow index
//              datetime                time=0;                   // anchor point time
//              double                  price=0;                  // anchor point price
//              const string            text="Text";              // the text itself
   const string            font = "Arial";           // font
   string name = createNameMarker(shift, Postfix);
   long chart_ID = ChartID();
   datetime t = iTime(NULL, 0, shift);
   double p = Price;
//--- creating label object (it does not have time/price coordinates)
// if(shift >10000) return;
   if(ObjectFind(chart_ID, name) < 0)
     {
      if(!ObjectCreate(chart_ID, name, obj, 0, t, p))
        {
         int err = GetLastError();
         Print(__FUNCTION__, "Error: can't create ARROW \"" + name + "\" code #", err);
         return;
        }
     }
   if(true)
     {
      ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, 2);
      ObjectSetString(chart_ID, name, OBJPROP_TEXT, Postfix);
      ObjectSetString(chart_ID, name, OBJPROP_TOOLTIP, Postfix);
      ObjectSetInteger(chart_ID, name, OBJPROP_BACK, false);
      //     Print(__FUNCTION__,"ARROW created at shift=",shift," Price=",Price);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLabel(int index, string text, ENUM_BASE_CORNER myCorner, int position_x, int position_y, string PostFix)
  {
   color bgColor = clrYellow;
   color fgColor = clrBlack;
   int myFontSize = 8;
   string myFont = "Arial";
   int mySize = 60;
   string name1 = createNameLabel(index, PostFix);
   bool ok = true;
   if(ObjectFind(WINDOW_MAIN, name1) == -1)
     {
      ok = ObjectCreate(WINDOW_MAIN, name1, OBJ_LABEL, 0, 0, 0);
     }
   if(ok)
     {
      ObjectSetInteger(WINDOW_MAIN, name1, OBJPROP_CORNER, myCorner);
      ObjectSetInteger(WINDOW_MAIN, name1, OBJPROP_XDISTANCE, position_x);
      ObjectSetInteger(WINDOW_MAIN, name1, OBJPROP_YDISTANCE, position_y);
      ObjectSetInteger(WINDOW_MAIN, name1, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(WINDOW_MAIN, name1, OBJPROP_XSIZE, mySize);
      ObjectSetInteger(WINDOW_MAIN, name1, OBJPROP_YSIZE, 50);
      ObjectSetInteger(WINDOW_MAIN, name1, OBJPROP_COLOR, bgColor);
      ObjectSetText(name1, text, myFontSize, myFont, fgColor);
     }
  }
/************
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawOrderLine(int ticket)
  {
   if(HistoryOrderSelect(ticket))
     {
      double OpenPrice = HistoryOrderGetDouble(ticket,ORDER_PRICE_OPEN);
      double Close = HistoryOrderGetDouble(ticket,ORDER_PRICE_CURRENT)
      datetime OpenTime= HistoryOrderGetINTEGER(ticket,OR);
      datetime CloseTime=HistoryDealGetInteger(POSITION;

      int OpenShift=iBarShift(Symbol(),0,OpenTime,false);
      int iClose(NULL,0,Shift=iBarShift(Symbol(),0,iClose(NULL,0,Time,false);

      DrawSimpleLine(OpenShift,iClose(NULL,0,Shift),OpenPrice,iClose(NULL,0,Price),(string)ticket,0);
      Print(__FUNCTION__,": OpenShift=",OpenShift, " iClose(NULL,0,Shift=",iClose(NULL,0,Shift),
            " OpenTime=", OpenTime, " iClose(NULL,0,Time=", iClose(NULL,0,Time),
            " OpenPrice=", OpenPrice, " iClose(NULL,0,Price=", iClose(NULL,0,Price);
     }
  }
//+------------------------------------------------------------------+
****/
