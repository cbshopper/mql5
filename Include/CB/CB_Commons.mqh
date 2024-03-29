//+------------------------------------------------------------------+
//|                                                      Commons.mqh |
//|                                                   Christof Blank |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"
#property link      ""
//#property strict
//#include <debug_inc.mqh>
//

#include <CB\ErrorMsg.mqh>
#include <cb\CB_MT4helper.mqh>
//#include <cb\CB_Utils.mqh>
//#include <cb\CB_OrderMachine.mqh>
//#include <cb\CB_OrderChangers.mqh>
//#include <cb\CB_Pips&Lots.mqh>
#import "inputbox.dll"
string InputBox(string prompt,string title,string default_value);
#import
//#include <CBTradeFunctions.mqh>

#ifdef COMMON_INPUT
extern string     COMMON_SETTINGS="SESSION TIME SETTING=";
extern bool       SessionTime=true;
extern string     NonTradingHoursSo="23;0";
extern string     NonTradingHoursMo="23;0;1;2";
extern string     NonTradingHoursDi="23;0";
extern string     NonTradingHoursMi="23;0";
extern string     NonTradingHoursDo="23;0";
extern string     NonTradingHoursFr="23;0";
extern string     NonTradingHoursSa="*";
extern string     NonTradingDays="1.1;1.5;24.12;25.12;26.12";
#else
string     COMMON_SETTINGS="SESSION TIME SETTING=";
bool       SessionTime=true;
string     NonTradingHoursSo="*";
string     NonTradingHoursMo="23;0;1;2";
string     NonTradingHoursDi="23;0;1";
string     NonTradingHoursMi="23;0;1";
string     NonTradingHoursDo="23;0;1";
string     NonTradingHoursFr="23;0;1";
string     NonTradingHoursSa="*";
string     NonTradingDays="1.1;1.5;24.12;25.12;26.12";
#endif

string            LIST_SEPERATOR=";";

//+------------------------------------------------------------------+
///Allow trading function - if the extern variable is true then the times are checked otherwise trading is allowed anyway.

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AllowTrading()
  {
   bool ret=false;

   if(SessionTime==true)
     {

      if(CheckSessionTime()==true)
        {
         ret=true;
        }
      else
         ret=false;
     }
   else
      ret=true;

   return(ret);

  }
///Business days function - sets the business days that can be traded ie Monday to Friday.
bool BusinessDay()
  {
   bool ret=false;
   
   if(DayOfWeek()>=1 || DayOfWeek()<6)
      ret=true;
   return ret;
  }
/// CheckSession time function - checks the current time to extern variables .
bool CheckSessionTime()
  {
   datetime now=TimeCurrent();
   int hournow=TimeHour(now);
   int weekday= TimeDayOfWeek(now);
   string sep=LIST_SEPERATOR;                // A separator as a character
   ushort u_sep;                  // The code of the separator character
   u_sep=StringGetCharacter(sep,0);
   string values[];               // An array to get strings
   int cnt=0;

   switch(weekday)
     {
      case 0:
         cnt=StringSplit(NonTradingHoursSo,u_sep,values);
         break;
      case 1:
         cnt=StringSplit(NonTradingHoursMo,u_sep,values);
         break;
      case 2:
         cnt=StringSplit(NonTradingHoursDi,u_sep,values);
         break;
      case 3:
         cnt=StringSplit(NonTradingHoursMi,u_sep,values);
         break;
      case 4:
         cnt=StringSplit(NonTradingHoursDo,u_sep,values);
         break;
      case 5:
         cnt=StringSplit(NonTradingHoursFr,u_sep,values);
         break;
      case 6:
         cnt=StringSplit(NonTradingHoursSa,u_sep,values);
         break;

     }
   int i;
   string shnow=IntegerToString(hournow);
   for(i=0; i<cnt; i++)
     {
      if(values[i]== "*")
         return false;
      if(shnow==values[i])
        {
         return false;
        }
     }

   string exeption_days[];
   cnt  = StringSplit(NonTradingDays,';',exeption_days);
   for(i=0; i<cnt; i++)
     {
      string s = StringFormat("%s.%s",TimeDay(now), TimeMonth(now));
      if(s == exeption_days[i])
         return false;

     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeFrameInc(int tf)
  {

   switch(tf)
     {

      case PERIOD_M1:
         return PERIOD_M5;
      case PERIOD_M5 :
         return PERIOD_M15;
      case PERIOD_M15:
         return PERIOD_M30;
      case PERIOD_M30:
         return PERIOD_H1;
      case PERIOD_H1:
         return PERIOD_H4;
      case PERIOD_H4:
         return PERIOD_D1;
      case PERIOD_D1:
         return PERIOD_W1;
      case PERIOD_W1:
         return PERIOD_MN1;
      case PERIOD_MN1:
         return PERIOD_MN1;
     }
   return tf;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeFrameDec(int tf)
  {

   switch(tf)
     {

      case PERIOD_M1:
         return PERIOD_M1;
      case PERIOD_M5 :
         return PERIOD_M1;
      case PERIOD_M15:
         return PERIOD_M5;
      case PERIOD_M30:
         return PERIOD_M15;
      case PERIOD_H1:
         return PERIOD_M30;
      case PERIOD_H4:
         return PERIOD_H1;
      case PERIOD_D1:
         return PERIOD_H4;
      case PERIOD_W1:
         return PERIOD_D1;
      case PERIOD_MN1:
         return PERIOD_W1;
     }
   return tf;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeFrameChange(int count)
  {
   int i=0;
   int ret=Period();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(count>0)
     {
      for(i=0; i<count; i++)
        {
         ret=TimeFrameInc(ret);
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      for(i=0; i<-count; i++)
        {
         ret=TimeFrameDec(ret);
        }

     }

   return ret;
  }


//+------------------------------------------------------------------+
void EmptyToZero(double &val)
  {
   if(val == EMPTY_VALUE)
      val=0;
  }
  
//+------------------------------------------------------------------+
double EmptyToZero2(double d)
{
   if (d == EMPTY_VALUE) d=0;
   return d;
}  
  
 bool IsNull(double val)
 {
   return (val == 0 || val == EMPTY_VALUE);
 }
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SarSignal(double sar0, double sar1, double price0, double price1)
  {
   if(sar1 > price1 && sar0 < price1)
      return 1;
   if(sar1 < price1 && sar0 > price1)
      return -1;
   return 0;
  } 
  
  //+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OrderTypeString(int type,bool shortname)
  {
   string ret="";
   if(shortname)
     {
      switch(type)
        {
         case OP_BUY:
            ret="BUY";
            break;
         case OP_SELL :
            ret="SELL";
            break;
         case OP_BUYLIMIT :
            ret= "BUY LIM";
            break;
         case OP_BUYSTOP :
            ret = "BUY STOP";
            break;
         case OP_SELLLIMIT :
            ret= "SELL LIM";
            break;
         case OP_SELLSTOP :
            ret = "SELL STOP";
            break;
        }
     }
   else
     {
      switch(type)
        {
         case OP_BUY:
            ret="buy order";
            break;
         case OP_SELL :
            ret="sell order";
            break;
         case OP_BUYLIMIT :
            ret= "buy limit pending order";
            break;
         case OP_BUYSTOP :
            ret = "buy stop pending order";
            break;
         case OP_SELLLIMIT :
            ret= "sell limit pending order";
            break;
         case OP_SELLSTOP :
            ret = "sell stop pending order";
            break;
        }
     }
   return ret;
  }
  
/*  ==> moved to CB_Pips&Lots.mqh
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CheckPriceVal(double val)
  {
   double tval = SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE); //MODE_TICKSIZE);

// Print(__FUNCTION__,": Symbol()=",Symbol(),"  in=",val, " TickValue=",TickValue);

   val =val / tval;
   val = MathRound(val);
   val = val*tval;

//  Print(__FUNCTION__,": out=",val);

   return val;
  }
  */
  //+------------------------------------------------------------------+
//| The function receives chart background color.                    |
//+------------------------------------------------------------------+
color ChartBackColorGet(const long chart_ID=0)
  {
//--- prepare the variable to receive the color
   long result=clrNONE;
//--- reset the error value
   ResetLastError();
//--- receive chart background color
   if(!ChartGetInteger(chart_ID,CHART_COLOR_BACKGROUND,0,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((color)result);
  }
//+--------------------------------------------------------------------------------+
//| The function receives the value of the chart maximum in the main window or a   |
//| subwindow.                                                                     |
//+--------------------------------------------------------------------------------+
double ChartPriceMax(const long chart_ID=0,const int sub_window=0)
  {
//--- prepare the variable to get the result
   double result=EMPTY_VALUE;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetDouble(chart_ID,CHART_PRICE_MAX,sub_window,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return(result);
  }
//+---------------------------------------------------------------------------------+
//| The function receives the value of the chart minimum in the main window or a    |
//| subwindow.                                                                      |
//+---------------------------------------------------------------------------------+
double ChartPriceMin(const long chart_ID=0,const int sub_window=0)
  {
//--- prepare the variable to get the result
   double result=EMPTY_VALUE;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetDouble(chart_ID,CHART_PRICE_MIN,sub_window,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return(result);
  }
  
  //+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OrderMsg(double lots,double sl,int sLPips,double tp,int tPPips)
  {
   string ret="";
   ret=StringFormat("Symbol: %s\nLots: %2f \nSL: %2f (%d Pips)\nTP: %2f (%d Pips)",Symbol(),lots,sl,sLPips,tp,tPPips);

   return ret;

  }
