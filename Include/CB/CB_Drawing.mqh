//+------------------------------------------------------------------+
//|                                                   CB_Drawing.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
//#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

#define WINDOW_MAIN 0
#define CB_DRAWING_INCLUDED
#include <CB_Draw.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createNameLine(int index,string postfix="")
  {
   return StringFormat("L#%s-%d%s",Program, Time[index],postfix);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createNameText(int index,string postfix="")
  {
   return StringFormat("T#%s-%d%s",Program,Time[index],postfix);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createNameMarker(int index,string postfix="")
  {
   return StringFormat("M#%s-%d%s",Program,Time[index],postfix);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createNameTriAngle(int index,string postfix="")
  {
   return StringFormat("3#%s-%d%s",Program,Time[index],postfix);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createNameLabel(int index,string postfix="")
  {
   return StringFormat("L#%s-%d%s",Program,index,postfix);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TAngle(int index,string text,datetime T0,double P0,datetime T1,double P1
              ,color clr,int offset=0,int width=3)
  {
//  if(!Show.Objects)  return;
   string name=createNameTriAngle(index);
   P0 = P0+offset*Point;
   P1 = P1+offset*Point;
   /*
      if(ObjectMove(name,0,T0,P0))
        {
         ObjectMove(name,1,T1,P1);
        }
        */
   if(ObjectFind(name)<0)
     {
      if(!ObjectCreate(name,OBJ_TRIANGLE,WINDOW_MAIN,T0,P0,T1,P0,T1,P1))
        {
         Alert("ObjectCreate(",name,",TRIANGLE) failed: ",GetLastError());
        }
      else
        {

        }
     }
   if(!ObjectSet(name,OBJPROP_WIDTH,width))
     {
      Alert("ObjectSet(",name,",OBJPROP_WIDTH) failed: ",GetLastError());
     }
   if(!ObjectSet(name,OBJPROP_STYLE,STYLE_DOT))
     {
      Alert("ObjectSet(",name,",OBJPROP_STYLE) failed: ",GetLastError());
     }
   if(!ObjectSet(name,OBJPROP_COLOR,clr)) // Allow color change
      Alert("ObjectSet(",name,",Color) [2] failed: ",GetLastError());

   if(!ObjectSetText(name,text,10))
      Alert("ObjectSetText(",name,") [2] failed: ",GetLastError());
   return name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TLine(int index,string text,string postfix,datetime T0,double P0,datetime T1,double P1
             ,color clr,bool asLine=false,bool ray=false,int offset=0,int width=3)
  {
//  if(!Show.Objects)  return;
   string name=createNameLine(index,postfix);
   P0 = P0+offset*Point;
   P1 = P1+offset*Point;
   if(ObjectMove(name,0,T0,P0))
     {
      ObjectMove(name,1,T1,P1);
     }
   else
      if(!ObjectCreate(name,OBJ_TREND,WINDOW_MAIN,T0,P0,T1,P1))
        {
         Alert("ObjectCreate(",name,",TREND) failed: ",GetLastError());
        }
      else
        {
         if(!ObjectSet(name,OBJPROP_RAY,ray))
           {
            Alert("ObjectSet(",name,",Ray) failed: ",GetLastError());
           }
        }
   if(asLine)
     {
      if(!ObjectSet(name,OBJPROP_WIDTH,width))
        {
         Alert("ObjectSet(",name,",OBJPROP_WIDTH) failed: ",GetLastError());
        }
     }
   if(!ObjectSet(name,OBJPROP_STYLE,STYLE_DOT))
     {
      Alert("ObjectSet(",name,",OBJPROP_STYLE) failed: ",GetLastError());
     }
   if(!ObjectSet(name,OBJPROP_COLOR,clr)) // Allow color change
      Alert("ObjectSet(",name,",Color) [2] failed: ",GetLastError());

   /*
      string  P0t=PriceToStr(P0);
      if(MathAbs(P0-P1)>=Point)
         P0t=StringConcatenate(P0t," to ",PriceToStr(P1));
      if(!ObjectSetText(name,P0t,10))
         Alert("ObjectSetText(",name,") [2] failed: ",GetLastError());
         */
   if(!ObjectSetText(name,text,10))
      Alert("ObjectSetText(",name,") [2] failed: ",GetLastError());
   return name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TLineBAK(int index,string text,datetime T0,double P0,datetime T1,double P1
                ,color clr,bool asLine=false,bool ray=false,int offset=0)
  {
//  if(!Show.Objects)  return;
   string name=createNameLine(index);
   P0 = P0+offset*Point;
   P1 = P1+offset*Point;
   if(ObjectMove(name,0,T0,P0))
     {
      ObjectMove(name,1,T1,P1);
     }
   else
      if(!ObjectCreate(name,OBJ_TREND,WINDOW_MAIN,T0,P0,T1,P1))
        {
         Alert("ObjectCreate(",name,",TREND) failed: ",GetLastError());
        }
      else
        {
         if(!ObjectSet(name,OBJPROP_RAY,ray))
           {
            Alert("ObjectSet(",name,",Ray) failed: ",GetLastError());
           }
        }
   if(asLine)
     {
      if(!ObjectSet(name,OBJPROP_WIDTH,3))
        {
         Alert("ObjectSet(",name,",OBJPROP_WIDTH) failed: ",GetLastError());
        }
     }
   if(!ObjectSet(name,OBJPROP_STYLE,STYLE_DOT))
     {
      Alert("ObjectSet(",name,",OBJPROP_STYLE) failed: ",GetLastError());
     }
   if(!ObjectSet(name,OBJPROP_COLOR,clr)) // Allow color change
      Alert("ObjectSet(",name,",Color) [2] failed: ",GetLastError());

   /*
      string  P0t=PriceToStr(P0);
      if(MathAbs(P0-P1)>=Point)
         P0t=StringConcatenate(P0t," to ",PriceToStr(P1));
      if(!ObjectSetText(name,P0t,10))
         Alert("ObjectSetText(",name,") [2] failed: ",GetLastError());
         */
   if(!ObjectSetText(name,text,10))
      Alert("ObjectSetText(",name,") [2] failed: ",GetLastError());
   return name;
  }
//+------------------------------------------------------------------+
string  DrawLine(int startbar,int stopbar,int signal,int offset=0)
  {
   string ret="";
   double win=0;
   int width=3;

   if(startbar>0)
     {
      color clr=clrGreen;
      string prefix="WIN!";
      if(signal==1)
        {
         win=Close[stopbar]-Close[startbar];
        }
      if(signal==-1)
        {
         win=Close[startbar]-Close[stopbar];
        }
      if(win<0)
        {
         clr=clrRed;
         prefix="LOST!";
         width=5;
        }
      win=NormalizeDouble(win,Digits);
      int pips=(int)(win/Point);
      //string name=StringFormat("LINE %d to %d (%d) %s",startbar,stopbar,pips,prefix);
      string name=StringFormat("%s to %s \nPips=%d\nVal=%f\n(%s) ",TimeToStr(Time[startbar]),TimeToStr(Time[stopbar]),pips,win*MarketInfo(Symbol(),MODE_LOTSIZE)/AccountLeverage(),prefix);
      int index=startbar;
      ret=TLine(index,name,"",Time[startbar],Close[startbar],Time[stopbar],Close[stopbar],
                clr,true,false,offset,width);

      /*
            string TLine(int index,string text,string postfix, datetime T0,double P0,datetime T1,double P1
                   ,color clr,bool asLine=false,bool ray=false,int offset=0,int width=3)
                   */
     }
   return ret;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string  DrawSimpleLine(int startbar,int stopbar,int Y1,int Y2,string label,int offset=0)
  {
   string ret="";
   double win=0;
   int width=3;

   if(startbar>0)
     {
      color clr=clrBlack;
      string name=StringFormat("%s (%s to %s) ",label,TimeToStr(Time[startbar]),TimeToStr(Time[stopbar]));
      int index=startbar;
      ret=TLine(index,name,"",Time[startbar],Y1,Time[stopbar],Y2,clr,true,false,offset,width);
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string  DrawTAngle(int startbar,int stopbar,int signal,int offset=0)
  {
   string ret="";
   double win=0;
   int width=3;

   if(startbar>0)
     {
      color clr=clrGreen;
      string prefix="WIN!";
      if(signal==1)
        {
         win=Close[stopbar]-Close[startbar];
        }
      if(signal==-1)
        {
         win=Close[startbar]-Close[stopbar];
        }
      if(win<0)
        {
         clr=clrRed;
         prefix="LOST!";
         width=5;
        }
      win=NormalizeDouble(win,Digits);
      int pips=(int)(win/Point);
      //string name=StringFormat("LINE %d to %d (%d) %s",startbar,stopbar,pips,prefix);
      string name=StringFormat("%s to %s \nPips=%d\nVal=%f\n(%s) ",TimeToStr(Time[startbar]),TimeToStr(Time[stopbar]),pips,win*MarketInfo(NULL,MODE_LOTSIZE)/AccountLeverage(),prefix);
      int index=startbar;
      ret=TAngle(index,name,Time[startbar],Close[startbar],Time[stopbar],Close[stopbar],clr,offset,width);
     }
   return ret;
  }
//+------------------------------------------------------------------+
void DeleteTLines(string postfix="")
  {
   for(int i=0; i<Bars-1; i++)
     {
      string name = createNameLine(i,postfix);
      bool deleted=ObjectDelete(0,name);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteText(string postfix="")
  {
   for(int i=0; i<Bars-1; i++)
     {
      string name = createNameText(i,postfix);
      bool deleted=ObjectDelete(0,name);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteMarker(string postfix="")
  {
   for(int i=0; i<Bars-1; i++)
     {
      string name = createNameMarker(i,postfix);
      bool deleted=ObjectDelete(0,name);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteLabels(string postfix="")
  {
   for(int i=0; i<Bars-1; i++)
     {
      string name = createNameLabel(i,postfix);
      bool deleted=ObjectDelete(0,name);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteTAngles(string postfix="")
  {
   for(int i=0; i<Bars-1; i++)
     {
      string name = createNameTriAngle(i,postfix);
      bool deleted=ObjectDelete(0,name);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateText(int shift,double Price,string text,string postfix="")
  {
//              const string            name="Text";              // object name
//              const int               sub_window=0;             // subwindow index
//              datetime                time=0;                   // anchor point time
//              double                  price=0;                  // anchor point price
//              const string            text="Text";              // the text itself
   const string            font="Arial";             // font
   const int               font_size=9;             // font size
   const color             clr=clrBlue;               // color
   double                  angle=45.0;                // text slope
   const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER; // anchor type
   const bool              back=false;               // in the background
   const bool              selection=false;          // highlight to move
   const bool              hidden=false;              // hidden in the object list
   const long              z_order=0;

   string name=createNameText(shift,postfix);

   long chart_ID=ChartID();
   datetime t=Time[shift];
   double p=Price;

//--- creating label object (it does not have time/price coordinates)

// if(shift >10000) return;

   if(ObjectFind(chart_ID,name)<0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_TEXT,0,t,p))
        {
         int err=GetLastError();
         Print(__FUNCTION__,"Error: can't create Text \""+name+"\" code #",err);
         return;
        }
     }
   if(true)
     {
      if(p<Low[shift])
        {
         angle=-45.0;
        }

      //    Print(__FUNCTION__,"Text created at shift=",shift," Price=",Price);
      //--- set color to Red
      //    ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clrRed);
      //   ObjectSetText(name,"$",13,"Arial",Red);
      //     ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      //--- set the text
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      //--- set text font
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      //--- set font size
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      //--- set the slope angle of the text
      ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
      //--- set anchor type
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
      //--- set color
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      //--- display in the foreground (false) or background (true)
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      //--- enable (true) or disable (false) the mode of moving the object by mouse
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      //--- hide (true) or display (false) graphical object name in the object list
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      //--- set the priority for receiving the event of a mouse click in the chart
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      //    ObjectSet(obj_name, OBJPROP_COLOR, Red);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateMarker(int shift,double Price,ENUM_OBJECT obj=OBJ_ARROW_CHECK,string Postfix="")
  {
//              const string            name="Text";              // object name
//              const int               sub_window=0;             // subwindow index
//              datetime                time=0;                   // anchor point time
//              double                  price=0;                  // anchor point price
//              const string            text="Text";              // the text itself
   const string            font="Arial";             // font

   string name=createNameMarker(shift,Postfix);
   long chart_ID=ChartID();
   datetime t=Time[shift];
   double p=Price;

//--- creating label object (it does not have time/price coordinates)

// if(shift >10000) return;

   if(ObjectFind(chart_ID,name)<0)
     {
      if(!ObjectCreate(chart_ID,name,obj,0,t,p))
        {
         int err=GetLastError();
         Print(__FUNCTION__,"Error: can't create ARROW \""+name+"\" code #",err);
         return;
        }
     }
   if(true)
     {
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,2);
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,Postfix);
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,Postfix);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,false);
      //     Print(__FUNCTION__,"ARROW created at shift=",shift," Price=",Price);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLabel(int index,string text,ENUM_BASE_CORNER myCorner,int position_x,int position_y,string PostFix)
  {

   color bgColor=clrYellow;
   color fgColor=clrBlack;
   int myFontSize=8;
   string myFont="Arial";
   int mySize=60;

   string name1=createNameLabel(index,PostFix);

   bool ok=true;
   if(ObjectFind(name1)==-1)
     {
      ok=ObjectCreate(name1,OBJ_LABEL,0,0,0);
     }
   if(ok)
     {

      ObjectSet(name1,OBJPROP_CORNER,myCorner);
      ObjectSet(name1,OBJPROP_XDISTANCE,position_x);
      ObjectSet(name1,OBJPROP_YDISTANCE,position_y);
      ObjectSet(name1,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(name1,OBJPROP_XSIZE,mySize);
      ObjectSet(name1,OBJPROP_YSIZE,50);
      ObjectSet(name1,OBJPROP_COLOR,bgColor);

      ObjectSetText(name1,text,myFontSize,myFont,fgColor);
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
void DrawIndicator(string name,int shift,double val0,double val1,bool asDot,color clr=clrBlue)
  {
   if(Bars-1 < shift)
      return;
// print(__FUNCTION__,"Bars="+ Bars);
   string EMAName=name+(string)Time[shift];

   if(ObjectFind(EMAName)==-1)
     {
      ObjectDelete(EMAName);
     }
   if(asDot)
     {
      //   TLine(shift,EMAName,EMAName,iTime(NULL,0,shift),val0,iTime(NULL,0,shift),val0,clr,true,false,0,2);
      ObjectCreate(EMAName,OBJ_TREND,0,iTime(NULL,0,shift),val0,iTime(NULL,0,shift),val0+1*Point);
      ObjectSet(EMAName,OBJPROP_RAY,false);
      ObjectSet(EMAName,OBJPROP_WIDTH,3);
      //  ObjectCreate(EMAName,OBJ_ELLIPSE,0,iTime(NULL,0,shift),val0,iTime(NULL,0,shift),val0);
      ObjectSetInteger(0,EMAName,OBJPROP_COLOR,clr);
     }
   else
     {
      //    TLine(shift,EMAName,EMAName,iTime(NULL,0,shift),val0,iTime(NULL,0,shift+1),val1,clr,true,false,0,2);
      ObjectCreate(EMAName,OBJ_TREND,0,iTime(NULL,0,shift),val0,iTime(NULL,0,shift+1),val1);
      ObjectSet(EMAName,OBJPROP_RAY,false);
      ObjectSetInteger(0,EMAName,OBJPROP_COLOR,clr);
     }
  }
  */
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawOrderLine(int ticket)
  {
   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY))
     {
      double OpenPrice = OrderOpenPrice();
      double ClosePrice= OrderClosePrice();
      datetime OpenTime= OrderOpenTime();
      datetime CloseTime=OrderCloseTime();

      int OpenShift=iBarShift(Symbol(),0,OpenTime,false);
      int CloseShift=iBarShift(Symbol(),0,CloseTime,false);

      DrawSimpleLine(OpenShift,CloseShift,OpenPrice,ClosePrice,(string)ticket,0);
      Print(__FUNCTION__,": OpenShift=",OpenShift, " CloseShift=",CloseShift,
            " OpenTime=", OpenTime, " CloseTime=", CloseTime,
            " OpenPrice=", OpenPrice, " ClosePrice=", ClosePrice);
     }
  }
//+------------------------------------------------------------------+
