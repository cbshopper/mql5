//+------------------------------------------------------------------+
//|                                                 CB_Stopploss.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.2"
#property strict
#property indicator_chart_window


//#property indicator_separate_window
#include <cb\CB_Commons.mqh>
#include <cb\CB_MT4.mqh>
#include <cb\CB_MT4_object.mqh>

#define WINDOW_MAIN 0
#define OBJ_TEXT "Lotsize"
#define OBJ_TPLINE "TakeProfit"
#define OBJ_SLLINE "Stoploss"
#define OBJ_ASK "Ask Line"
#define OBJ_PRICELINE "Open Price"
#define OBJ_MaxAccountValue "MaxAccountValue"

input double Risk =  1.0;
input double CRV=1.5;
input bool UseBidLine=true;
input bool ShowTakeProfitLine=true;
input bool ShowAskLine=true;

input double MaxAccountValue=10000;
input int IniatialSLPips=50;
input double InitialLots=1.0;
int    SLPipsFix = 20;

//extern int    TPPipsFix = 20;

double SLValue;
double TPValue=0;
int SLPips = 0;
double Price =0;
double POINT;
//double TickValue =0;
string GlobVarName="";
double Lots=0;
double riskvalue;
double lots_calculated;
int Mode=0;
double LastPrice;
int LastMode=0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnMovePrice()
  {
   double stoppos =   ObjectGetDouble(0,OBJ_SLLINE,OBJPROP_PRICE,0);
   double price =   ObjectGetDouble(0,OBJ_PRICELINE,OBJPROP_PRICE,0);
   double spread = Ask()-Bid();
//if(stoppos> price)  // Sell
   if(LastMode == OP_SELL)
     {
      SLValue = price +  SLPips*POINT;
      TPValue = price -spread - SLPips*POINT*CRV;
     }
   else  // Buy
     {
      SLValue = price - SLPips*POINT;
      TPValue = price + spread + SLPips*POINT*CRV;
     }
   LastPrice = price;

   UpdateLines();
   GetValues(true);
   UpdateLines();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnMoveStop()
  {
   double stoppos =   ObjectGetDouble(0,OBJ_SLLINE,OBJPROP_PRICE,0);
   double price =   ObjectGetDouble(0,OBJ_PRICELINE,OBJPROP_PRICE,0);
   double spread = Ask()-Bid();
//if(stoppos> price)  // Sell
   if(LastMode == OP_SELL)
     {
      SLValue = price +  SLPips*POINT;
      TPValue = price -spread - SLPips*POINT*CRV;
     }
   else  // Buy
     {
      SLValue = price - SLPips*POINT;
      TPValue = price + spread + SLPips*POINT*CRV;
     }
   LastPrice = price;

  // UpdateLines();
   GetValues(true);
   UpdateLines();
//   GetValues(false);
//   UpdateLines();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetValues(bool force)
  {
   double askprice,bidprice;
   
   double money = AccountBalance();
   if(MaxAccountValue> 0 && MaxAccountValue < money )
     money = MaxAccountValue;
      
      
   riskvalue=(money*Risk/100);
   double diff =0;
   double stoppos =   ObjectGetDouble(0,OBJ_SLLINE,OBJPROP_PRICE,0);
   if(UseBidLine)
     {
      bidprice = ObjectGetDouble(0,OBJ_PRICELINE,OBJPROP_PRICE,0);
      bidprice = CheckOpenPrice(bidprice);
      askprice= bidprice ; //+ Ask-Bid;
      askprice = NormalizeDouble(askprice,Digits());
     }
   else
     {
      bidprice = Bid();
      askprice = Ask();
     }

   if(stoppos != SLValue || force)
     {
      if(stoppos < bidprice)
        {
         diff = bidprice - stoppos;
         SLPips = diff/POINT;
         Price = bidprice;
         Mode = OP_BUY;
         LastMode=Mode;
         if(bidprice != Bid())
           {
            if(bidprice < Bid())
               Mode = OP_BUYLIMIT;
            else
               Mode = OP_BUYSTOP ;
           }
        }

      if(stoppos > askprice)
        {
         diff = stoppos-askprice;
         SLPips = diff/POINT;
         Price=askprice;
         Mode = OP_SELL;
         LastMode=Mode;
         if(askprice != Ask())
           {
            if(askprice < Ask())
               Mode = OP_SELLSTOP;
            else
               Mode = OP_SELLLIMIT ;
           }
        }
     }
   if(SLPips==0)
      SLPips=   calculateStopLossPoints(riskvalue,InitialLots); //     IniatialSLPips;
      Print(__FUNCTION__," SlPips 1=",SLPips);
   SLPips=checkSL(SLPips);
 //  Print(__FUNCTION__," SlPips 2=",SLPips);
    
//   Lots=riskvalue/(SLPips*TickValue);
//   Print(__FUNCTION__," Lots1=",Lots, " SLPips=",SLPips," TickValue=",TickValue, " riskvalue=",riskvalue);
   Lots = calculateLotRAW(riskvalue,SLPips);
//    Print(__FUNCTION__," Lots2=",Lots, " SLPips=",SLPips," TickValue=",TickValue, " riskvalue=",riskvalue);
   lots_calculated = NormalizeDouble(Lots,2);
   Lots = CheckLot(Lots);
   Lots = NormalizeDouble(Lots,2);
 Comment("Lot=",Lots, " caclulated:",lots_calculated);
   if(lots_calculated != Lots)
     {
    //  SLPips  =(riskvalue/ Lots)/TickValue;
       SLPips  =(riskvalue/ Lots)/POINT;
       Comment("Lot=",Lots, " caclulated:",lots_calculated);
     }
   AdjustValues(Price, stoppos);


  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AdjustValues(double price, double linepos)
  {
   double spread = Ask()-Bid();
   if(linepos> price)  // Sell
     {
      SLValue = price +  SLPips*POINT;
      TPValue = price -spread - SLPips*POINT*CRV;
     }
   else  // Buy
     {
      SLValue = price - SLPips*POINT;
      TPValue = price + spread + SLPips*POINT*CRV;
     }
   SLValue = CheckPriceVal(SLValue);
   TPValue = CheckPriceVal(TPValue); 
   
   
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CheckOpenPrice(double bidprice)
  {
   bidprice = NormalizeDouble(bidprice, Digits());
   double stoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);

   double stopvalue = NormalizeDouble(stoplevel*POINT,Digits());
   bool priceok = NormalizeDouble(MathAbs(bidprice-Bid()),Digits()) > stopvalue;
   if(!priceok)
     {
      if(bidprice > Bid())
        {
         bidprice = Bid() + stopvalue;
        }
      if(bidprice < Bid())
        {
         bidprice = Bid() - stopvalue;
        }
     }
   bidprice=CheckPriceVal(bidprice);  
   return bidprice;
  }

#ifndef START
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   POINT=Point(); // PipSize(Symbol());
   //TickValue=PipValue(NULL);
  
   if(UseBidLine )
     {
      double p = ObjectGetDouble(0,OBJ_PRICELINE,OBJPROP_PRICE,0);
      if(p<=0 ||  p < ChartPriceMin() || p >  ChartPriceMax())
        {
          HLine(OBJ_PRICELINE,Bid(),clrBlack,true,true);
          LastPrice=Bid();
        }
      //     ShowAskLine=false;
     }
   else
     {
      ObjectDelete(0,OBJ_PRICELINE);
     }
//---
   string s = DoubleToString(MaxAccountValue) + ";" + IntegerToString(UseBidLine);
   HiddenText(OBJ_MaxAccountValue,s);
   EventSetTimer(1);

   GetValues(false);

   UpdateLines();
   
  
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   if(!UseBidLine)
     {
      GetValues(true);
      UpdateLines();
     }

  }


//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   Print(__FUNCTION__,": id=",id," lparam=",lparam," dparam=",dparam," sparam=",sparam);
   if(id == CHARTEVENT_OBJECT_DRAG)
     {
      if(sparam == OBJ_SLLINE)
         OnMoveStop();
      if(sparam == OBJ_PRICELINE)
         OnMovePrice();

     }

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//   GlobalVariableSet(GlobVarName,SLValue);
   ObjectDelete(0,OBJ_TEXT);
//  ObjectDelete(0,OBJ_SLLINE);
   ObjectDelete(0,OBJ_ASK);
   ObjectDelete(0,OBJ_TPLINE);
   if(!UseBidLine )ObjectDelete(0,OBJ_PRICELINE);
   ObjectDelete(0,OBJ_MaxAccountValue);
   EventKillTimer();
  }

#endif
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InfoText(string name,string text)
  {

   if(ObjectFind(WINDOW_MAIN,name)<0)
      ObjectCreate(0,name, OBJ_LABEL, WINDOW_MAIN, 0, 0);
   ObjectSetText(name,text,10, "Verdana", clrBlack);
   ObjectSet(name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSet(name, OBJPROP_XDISTANCE, 20);
   ObjectSet(name, OBJPROP_YDISTANCE, 20);
   ObjectSet(name,OBJPROP_TOOLTIP,text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HiddenText(string name,string text)
  {
   color bk=ChartBackColorGet();
   if(ObjectFind(WINDOW_MAIN,name)<0)
      ObjectCreate(name, OBJ_LABEL, WINDOW_MAIN, 0, 0);
   ObjectSetText(name,text,1, "Verdana", bk);
   ObjectSet(name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSet(name, OBJPROP_XDISTANCE, 0);
   ObjectSet(name, OBJPROP_YDISTANCE, 0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HLine(string name, double P0, color clr,bool bold, bool selected=false)
  {
//      #define WINDOW_MAIN 0
   if(ObjectMove(0,name, 0, iTime(NULL,0,0), P0)) {}
   else
      if(!ObjectCreate(name, OBJ_HLINE, WINDOW_MAIN, iTime(NULL,0,0), P0))
         Alert("ObjectCreate(",name,",HLINE) failed: ", GetLastError());
   if(!ObjectSet(name, OBJPROP_COLOR, clr))   // Allow color change
      Alert("ObjectSet(", name, ",Color) [1] failed: ", GetLastError());
   if(bold)
     {
      if(!ObjectSet(name, OBJPROP_WIDTH, 3))   // Allow color change
         Alert("ObjectSet(", name, ",OBJPROP_WIDTH) [1] failed: ", GetLastError());
     }
   if(!ObjectSetText(name, (string)P0, 10))
      Alert("ObjectSetText(",name,") [3] failed: ", GetLastError());

   if(selected)
     {
      ObjectSetInteger(WINDOW_MAIN,name, OBJPROP_SELECTED, 1);
     }
   else
     {
      ObjectSetInteger(WINDOW_MAIN,name, OBJPROP_SELECTED, 0);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateLines()
  {
   if(SLValue < ChartPriceMin())
      SLValue = ChartPriceMin()+10*Point();
   if(SLValue > ChartPriceMax())
      SLValue = ChartPriceMax() - 10*Point();


   if(UseBidLine)
     {

      double pos =   ObjectGetDouble(0,OBJ_PRICELINE,OBJPROP_PRICE,0);
    /*
      if (pos <= 0)
      {
         pos=Bid;
         HLine(OBJ_PRICELINE,pos,clrBlack,true,true);
         LastPrice =pos;
      }
      */
      if(LastPrice != pos && LastPrice>0 && pos>0)
        {
         HLine(OBJ_PRICELINE,Price,clrBlack,true,true);
         LastPrice =pos;
        }

     }

   HLine(OBJ_SLLINE,SLValue,clrRed,true,true);
   if(ShowTakeProfitLine)
     {
      HLine(OBJ_TPLINE,TPValue,clrDarkGreen,false);
     }
// string msg = StringFormat("Lots: %2.2f SLPips=%2.2f, Riskvalue=%2.2f, PT=%.5f, TV=%f ",Lots, SLPips,riskvalue,POINT,TickValue);
   string msg = StringFormat("%s:%2.2f[%2.2f](%1.2f)@%2.5f SL:%2.2f(%d) TP:%2.2f R:%1.1f%%(%1.1f)(%2.2f)",
                             OrderTypeString(Mode,true),Lots,lots_calculated,MarketInfo(Symbol(),MODE_LOTSTEP),Price, SLValue, SLPips,TPValue,Risk,riskvalue,CRV);
   InfoText(OBJ_TEXT,msg);
//  GlobalVariableSet(GlobVarName,SLValue);
   if(ShowAskLine)
     {
      HLine(OBJ_ASK,Ask(),clrBlue,false);
     }
  }
//+------------------------------------------------------------------+
double CalculateLotSize(double SL,double MaxRiskPerTrade)           //Calculate the size of the position size
  {
   double LotSize=0;
//We get the value of a tick
   double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
//If the digits are 3 or 5 we normalize multiplying by 10
   if(Digits()==3 || Digits()==5)
     {
      nTickValue=nTickValue*10;
     }
//We apply the formula to calculate the position size and assign the value to the variable
   LotSize=(AccountBalance()*MaxRiskPerTrade/100)/(SL*nTickValue);

   LotSize=(AccountBalance()*MaxRiskPerTrade/100)/(SL*POINT);
   
   LotSize = CheckLot(LotSize);

   return LotSize;
  }
  
  /*
//+------------------------------------------------------------------+
double checkSL(double SL)
  {
   double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(SL < StopLevel)
      SL=StopLevel;
   return SL;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
*/