//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OrderInfo(int ticket)
  {
   string r,c,b;
   return OrderInfo(ticket,r,c,b);
  }
//+------------------------------------------------------------------+
string OrderInfo(int ticket,string &strRisk,string &strChance,string &strBreakEven)
  {
   string ret="";
   bool ok=false;

   ok=OrderSelect(ticket,SELECT_BY_TICKET);
   if(ok)
     {
      double risk=0;
      double Chance=0;
      int SLPips = 0;
      int TPPips = 0;
      int typ=OrderType();
      string ordertype=OrderTypeString(typ,true);
      double sl = OrderStopLoss();
      double tp = OrderTakeProfit();
      double lots=OrderLots();
      double OPrice=OrderOpenPrice();

      double Account=AccountBalance();
      int type=OrderType();
      double v1=0,v2=0;

      double tickvaluefix=TickValue(Symbol());

      if(type==OP_BUY)
        {
         v1= OPrice-sl;
         v2=tp-OPrice;

        }
      if(type==OP_SELL)
        {
         v1=sl-OPrice;
         v2=OPrice-tp;
        }

      if(sl>0)
         SLPips=Value2Point(v1);
      if(tp>0)
         TPPips=Value2Point(v2);
      risk=NormalizeDouble((lots*SLPips*tickvaluefix*100)/Account,5);
      if(sl==0)
         risk=100.0;
      Chance=NormalizeDouble((lots*TPPips*tickvaluefix*100)/Account,5);
      double be=BreakEven(ticket);
      double crv = 0;
      if(SLPips > 0)
         crv = (double)TPPips/(double)SLPips;
      ret=StringFormat("%s Lots=%1.1f [SL=%d (%.2f%%)] [TP=%d (%.2f%%)] BE=%f C/R=1:%1.1f",ordertype,lots,SLPips,risk,TPPips,Chance,be,crv);
      strRisk=StringFormat("SL=%d (%.2f%%)",SLPips,risk);
      strChance=StringFormat("TP=%d (%.2f%%)",TPPips,Chance);
      strBreakEven=StringFormat("%f",be);
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OrderInfoXL(int ticket)
  {
   string ret="";
   bool ok=false;

   ok=OrderSelect(ticket,SELECT_BY_TICKET);
   if(ok)
     {
      string msg=OrderInfo(ticket);
      ret=StringFormat("Ticket=%d, Magic=%d, Info=%s",ticket,OrderMagicNumber(),msg);
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BreakEven(int ticket)
  {
   double ret=0;
   bool ok=OrderSelect(ticket,SELECT_BY_TICKET);

   if(ok)
     {
      string symb=OrderSymbol();
      double lots=OrderLots();
      double eq= OrderProfit()+OrderCommission()+OrderSwap();
      int type = OrderType();
      if(type==OP_SELL)
         lots=-lots;
      int dig=(int)MarketInfo(symb,MODE_DIGITS);
      double point=MarketInfo(symb,MODE_POINT);
      double COP = lots*MarketInfo(symb, MODE_TICKVALUE);
      double val = MarketInfo(symb, MODE_BID) - point*eq / COP;
      ret=val;
     }
   return ret;
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MACDTrend(int shift,int TimeFrame,int macd_fast,int macd_slow,int macd_level,bool &EntryLevelOk)
  {
   int ret=0;
   double macd0=iMACD(NULL,TimeFrame,macd_fast,macd_slow,9,PRICE_CLOSE,MODE_MAIN,shift);
   double macd1=iMACD(NULL,TimeFrame,macd_fast,macd_slow,9,PRICE_CLOSE,MODE_MAIN,shift+1);
   double macdsig0=iMACD(NULL,TimeFrame,macd_fast,macd_slow,9,PRICE_CLOSE,MODE_SIGNAL,shift);
   double macdsig1=iMACD(NULL,TimeFrame,macd_fast,macd_slow,9,PRICE_CLOSE,MODE_SIGNAL,shift+1);
   int macdval=(int)MathAbs(macd0/Point());
//macdval=macd_level+1;
   if(macd1 < macd0 && macdval > macd_level)
      ret=1;
   if(macd1 > macd0 && macdval > macd_level)
      ret=-1;
   EntryLevelOk=macdval>macd_level;
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int longTrend(int shift,int timeframe,int period,int method,int minDiffPips=0,int shift_diff=1,int MAShift=0)
  {
   int ret=0;
   double m0,m1;
   ret=longTrend(shift,timeframe,period,method,minDiffPips,shift_diff,MAShift,m0,m1);
   return ret;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int longTrend(int shift,int timeframe,int period,int method,int minDiffPips,int shift_diff,int MAShift,double &ma0,double &ma1)
  {
   int trend=0;
   ma0=iMA(NULL, timeframe,period,MAShift,  method,PRICE_CLOSE,shift);
   ma1=iMA(NULL,timeframe,period,MAShift,  method,PRICE_CLOSE,shift+shift_diff);
   if(ma0 > ma1+minDiffPips*Point)
      trend=1;
   if(ma0 < ma1-minDiffPips*Point)
      trend=-1;

   return trend;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int longTrend2(int shift,int timeframe,int periodlong,int periodshort,int method)
  {
   int trend=0;
   double ma0=iMA(NULL, timeframe,periodlong,0,  method,PRICE_CLOSE,shift);
   double ma1=iMA(NULL,timeframe,periodshort,0,  method,PRICE_CLOSE,shift);
   if(ma0 < ma1)
      trend=1;
   if(ma0 > ma1)
      trend=-1;

   return trend;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MAChangeDir(int shift,int xMAFastPeriod,int xMAFastMode,int minDiff,int shiftDiff=1)
  {
   if(shiftDiff<1)
      shiftDiff=1;
   double ma0=iMA(NULL,0,xMAFastPeriod,0,xMAFastMode,PRICE_CLOSE,shift);
   double ma1=iMA(NULL,0,xMAFastPeriod,0,xMAFastMode,PRICE_CLOSE,shift+shiftDiff);
   double ma2=iMA(NULL,0,xMAFastPeriod,0,xMAFastMode,PRICE_CLOSE,shift+2*shiftDiff);
   int ret=0;
// MA dreht von fallend auf steigend
   if(ma2>ma1+minDiff*Point && ma0>ma1+minDiff*Point)
     {
      ret=1;
     }
// MA dreht von steigend auf fallend
   if(ma2<ma1-minDiff*Point && ma0<ma1-minDiff*Point)
     {
      ret=-1;
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckOrderXXXXXXX(int mode,double price,int backbars,int magic)
  {
   bool ret=false;
// Count open Orders in
   int cnt=0;
   for(int i=0; i<OrdersTotal(); i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderType()==mode)
           {
            cnt++;
           }
        }
     }
   return ret;

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckAccountBeforeTrade(double PercentageOfBalance)
  {
   bool ret=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(AccountEquity()<AccountBalance()*(PercentageOfBalance/100.0))
     {
      ret=false;
     }
   return ret;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime LastBarTime=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   bool ret=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(LastBarTime!=Time[0])
     {
      LastBarTime=Time[0];
      ret=true;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      ret=false;
     }
//   ret=true;
//  print(__FUNCTION__+" returns:"+ret);
   return ret;
  }
  
  //+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Check Exist Order                                                |
//+------------------------------------------------------------------+
int CountOpenOrder(int typ,int magic)
  {
   int ret=0;
   int total=OrdersTotal();
   for(int cnt=0; cnt<total; cnt++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      bool ok=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(ok)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic) //Changed 2017-06-01: use MAGIC!
           {
            //        FoundOpenedOrder=True;
            if(OrderType()==typ)
              {
               ret++;
              }
           }
        }
      else
        {
         print(__FUNCTION__+": Error select order:",ErrorMsg(GetLastError()));
        }
     }

   return (ret);
  }
//+------------------------------------------------------------------+
int CalculateOrderTimes(int mode,bool isWinOrder,int Magic,datetime &avgTime,datetime &minTime,datetime &maxTime)
  {
   int ret=0;
   bool result=false;
   double loss=0;
   int cnt=0;
   datetime sumTime=0;
   minTime=0;
   maxTime=0;
   avgTime=0;
   int total= OrdersHistoryTotal();
   for(int i=total-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      bool ok=OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(ok)
        {
         if(Magic!=0 && OrderMagicNumber()!=Magic)
            continue;

         int type=OrderType();
         if(type!=mode && mode!=-1)
            continue;

         double win=OrderProfit();
         if((win>0 && isWinOrder) || (win<0 && !isWinOrder))
           {
            datetime opentime=OrderOpenTime();
            datetime closetime=OrderCloseTime();
            datetime age=closetime-opentime;
            cnt++;
            if(age>maxTime)
               maxTime=age;
            if(age<minTime || minTime==0)
               minTime=age;
            sumTime+=age;

           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(cnt>0)
     {
      avgTime=sumTime/cnt;
      Print(__FUNCTION__,": OrderCount=",cnt," avgTime=",avgTime," minTime=",minTime," maxTime=",maxTime);
     }
   return cnt;
  }
//+------------------------------------------------------------------+
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







//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OrderMsg(double lots,double sl,int SLPips,double tp,int TPPips)
  {
   string ret="";
   ret=StringFormat("Symbol: %s\nLots: %2f \nSL: %2f (%d Pips)\nTP: %2f (%d Pips)",Symbol(),lots,sl,SLPips,tp,TPPips);

   return ret;

  }
//+------------------------------------------------------------------+
//|                   type =-1: all types                            |
//+------------------------------------------------------------------+
int ListOrders(string symbol,int type,int magic,int &OrderList[])
  {
   int ret=0;
   int totalorders=OrdersTotal();
   ArrayResize(OrderList,totalorders);
   for(int j=0; j<totalorders; j++)
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
        {
         print("INFO: ",__FUNCTION__,StringFormat("Order #%d, Type=%d, Symbol=%s, Magic=%d",OrderTicket(),OrderType(),OrderSymbol(),OrderMagicNumber()));
         if(OrderSymbol()==symbol && (OrderMagicNumber()==magic || magic==0) && (OrderType()==type || type==-1))
           {
            OrderList[ret]=OrderTicket();
            ret++;
           }
        }

     }
   print("INFO: ",__FUNCTION__,StringFormat("%d Order found",ret));

   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenOrderCount(string symbol,int type,int magic)
  {
   int ret=0;
   int totalorders=OrdersTotal();
   for(int j=0; j<totalorders; j++)
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
        {
         //        print("INFO: ",__FUNCTION__,StringFormat("Order #%d, Type=%d, Symbol=%s, Magic=%d",OrderTicket(),OrderType(),OrderSymbol(),OrderMagicNumber()));
         if(OrderSymbol()==symbol && (OrderMagicNumber()==magic || magic==0) && (OrderType()==type || type==-1))
           {
            ret++;
           }
        }

     }
// print("INFO: ",__FUNCTION__,StringFormat("%d Order found",ret));

   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LastOrderResult(string symbol,int type,int magic)
  {
   double ret=0;

   int total=OrdersHistoryTotal();
   for(int cnt=total-1; cnt>0; cnt--)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY))
        {
         //--  take last order with profit -----------------------
         if(OrderSymbol()==symbol && (OrderMagicNumber()==magic || magic==0) && (OrderType()==type || type==-1))
           {
            ret=OrderProfit();
            break;
           }
        }
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ListOrders(int &OrderList[],int magic)
  {
   return ListOrders(Symbol(),-1,magic,OrderList);
  }
