//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#import "inputbox.dll"
string InputBox(uchar &prompt[],uchar &title[],uchar &default_value[]);
#import
// #property show_inputs
extern string header=" --- CREATE ORDER FROM LINES ----";
extern  string comment="";
extern int magicnumber =0;
extern int Slippage = 3;
extern string AssignedIndicator="CB_OrderCalculator";

#define START

#include "..\..\..\Indicators\CB\Orders\CB_OrderCalculator.mq5"
#include <CB\CB_OrderMachine.mqh>
#include <cb\InputBox.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnStart()
  {
   POINT= Point(); // PipSize(Symbol());
// TickValue=PipValue(NULL);

/*
   string s = ObjectGetString(0,OBJ_MaxAccountValue,OBJPROP_TEXT);
   if(s != "")
     {
      string arr[];
      int cnt = StringSplit(s,';',arr);
      if(cnt > 0)
        {
         MaxAccountValue = StringToDouble(arr[0]);
         UseBidLine=StringToInteger(arr[1]);
         //    MessageBox("Parameter: MaxAccountValue=" + MaxAccountValue + " UseBidLine=" + UseBidLine);
        }
     }
*/
   double pos=0;
   bool ok = true;
   if(AssignedIndicator != "")
     {
      ok = checkIndicator(AssignedIndicator);
     }
   if(ok)
     {
      ok = ObjectGetDouble(0,OBJ_SLLINE,OBJPROP_PRICE,0,pos);
      if(ok)
        {
         GetValues(true);
         Price = CheckOpenPrice2(Price);
         string msg = StringFormat("CREATE %s ORDER %s at %f (SL=%.4f[%3.0f],TP=%.4f[%3.0f]) with Lots:",
                                   OrderTypeString(Mode,false),
                                   Symbol(),
                                   NormalizeDouble(Price,Digits()),
                                   NormalizeDouble(SLValue,Digits()),
                                   NormalizeDouble(SLPips,2),
                                   NormalizeDouble(TPValue,Digits()),
                                   NormalizeDouble(SLPips*CRV,2));

         string newlots = InputBoxDouble("Adjust Lots",msg,(string) Lots);
         if(newlots != "")
           {
             Lots = StringToDouble(newlots);
             msg = StringFormat("CREATE %s ORDER %s %2.2f Lots at %f (SL=%.4f[%3.0f],TP=%.4f[%3.0f])",
                               OrderTypeString(Mode,false),
                               Symbol(),
                               Lots,
                               NormalizeDouble(Price,Digits()),
                               NormalizeDouble(SLValue,Digits()),
                               NormalizeDouble(SLPips,2),
                               NormalizeDouble(TPValue,Digits()),
                               NormalizeDouble(SLPips*CRV,2));
           }
         else
           {
            return 1;
           }
         if(MessageBox(msg,  "Script",  MB_YESNO|MB_ICONQUESTION)!=IDYES)
           {
            return(1);
           }
         //----
         GetValues(true);  //refresh!!!!
         Price = CheckOpenPrice2(Price);
         
         COrderMachine OM;
         OM.Init();
         
        // int ticket=OrderSend(Symbol(),Mode,Lots, NormalizeDouble(Price,Digits()),Slippage,NormalizeDouble(SLValue,Digits()),NormalizeDouble(TPValue,Digits()),comment,magicnumber,0);   //DoubleToString
          
         int ticket = OM.OrderSend(Symbol(),Mode,Lots, NormalizeDouble(Price,Digits()),Slippage,NormalizeDouble(SLValue,Digits()),NormalizeDouble(TPValue,Digits()),comment,magicnumber);
          
         OM.Deinit();
         if(ticket<1)
           {
            int error=GetLastError();
            string msg = "Cannot open Order due to Error = " + ErrorDescription(error);
            Print(__FUNCTION__,": ", msg);
            MessageBox(msg);
            return 1;
           }
         /*
         else
         {
          bool ret = OrderModify(ticket, OrderOpenPrice(),NormalizeDouble(SLValue,5),NormalizeDouble(TPValue,5), 0, CLR_NONE);
          if(ret)
            {
             int error=GetLastError();
             string msg = "Cannot change Order due to Error = " + ErrorDescription(error);
             Print(__FUNCTION__,": ", msg);
             MessageBox(msg);
             return 1;

            }
         }
         */
         //----
        // OrderPrint();
         return(0);
        }
      else
        {
         MessageBox("NO Stoploss-Line found!",   "Error") ;
         return(1);
        }
     }
   else
     {
      MessageBox("Assigned Indicator not found: " + AssignedIndicator,   "Error") ;
      return(1);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CheckOpenPrice2(double price)
  {
   price = NormalizeDouble(price, Digits());
   double stoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   double stopvalue = NormalizeDouble(stoplevel*POINT,Digits());
   switch(Mode)
     {
      case OP_SELLLIMIT:
      case OP_BUYSTOP:

         if(NormalizeDouble(MathAbs(price-Ask()),Digits()) <= stopvalue)
            price = Ask() + stopvalue;

         break;
      case OP_SELLSTOP:
      case OP_BUYLIMIT:
         if(NormalizeDouble(MathAbs(price-Bid()),Digits()) <= stopvalue)
            price = Bid() - stopvalue;
         break;

     }
   price=CheckPriceVal(price);
   return price;
  }


//+------------------------------------------------------------------+
bool checkIndicator(string name)
  {
   int cnt = ChartIndicatorsTotal(0,0);
   for(int i =0; i < cnt; i++)
     {
      string indiname = ChartIndicatorName(0,0,i);
      if(indiname == name)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
