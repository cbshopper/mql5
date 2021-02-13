
#include <cb\CB_Utils.mqh>
#include <cb\CBUtils5.mqh>
//+//////////////////////////////////////////////////////////////////+
//|               SL AND TP Calculations                             |
//+//////////////////////////////////////////////////////////////////+

int calculateStopLossPoints(double RiskValue,double lots)
  {

   int sl_points=0;
   if(lots>0)
     {
      int stopLevel=SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL ) ;; //MarketInfo(Symbol(),MODE_STOPLEVEL);
      int  tickvalue= TickValue(Symbol());

      sl_points=(int)(RiskValue/(lots*tickvalue)); //- spread);
      sl_points=CheckSLint(sl_points);
     
     }
   return sl_points;
  }  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CheckPriceVal(double val)
  {
   double tval = MarketInfo(Symbol(),MODE_TICKSIZE);

// Print(__FUNCTION__,": Symbol()=",Symbol(),"  in=",val, " TickValue=",TickValue);

   val =val / tval;
   val = MathRound(val);
   val = val*tval;

//  Print(__FUNCTION__,": out=",val);

   return val;
  }
//+//////////////////////////////////////////////////////////////////+
//|                LOT SIZE FUNCTIONS                                |
//+//////////////////////////////////////////////////////////////////+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculateLot(double RiskValue,int sl_points)
  {
   double tickvalue=TickValue(Symbol());
   double lots=RiskValue/(sl_points *tickvalue);
   lots=CheckLot(lots);
   return lots;
  }
double calculateLotRAW(double RiskValue,int sl_points)
  {
   double tickvalue=TickValue(Symbol());
   double lots=RiskValue/(sl_points *tickvalue);
   return lots;
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculateLotX(double Risk_percent,double SL_value,int Mode,double &SL_POINTS)
  {
   double tickvalue=TickValue();
   double riskcapital=AccountInfoDouble(ACCOUNT_BALANCE)*Risk_percent/100;
   double Diff;

 //  RefreshRates();
   if(Mode==OP_BUY)
     {
      Diff=Ask()-SL_value;
     }
   else
     {
      Diff=SL_value-Bid();
     }
   double points=Value2Point(Diff); // Diff/Point;
   SL_POINTS=points;
   double lots=(riskcapital/points)/tickvalue;
   lots=_adjustLots(lots);

   return lots;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculateLot(double betcapital)
  {

   int LotDigits=0;
   double lotsi;
   double ilot_max =MarketInfo(Symbol(),MODE_MAXLOT);
   double ilot_min =MarketInfo(Symbol(),MODE_MINLOT);
   double tick=MarketInfo(Symbol(),MODE_TICKVALUE);
   double lotsize=MarketInfo(Symbol(),MODE_LOTSIZE);
   double tickvalue=TickValue();
// double betcapital=AccountFreeMargin()*Bet/100; //AccountBalance()*Bet/100;

   double marginsize=MarketInfo(Symbol(),MODE_MARGINREQUIRED);
//---
   double  myAccount=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//---
   if(ilot_min==0.01)
      LotDigits=2;
   if(ilot_min==0.1)
      LotDigits=1;
   if(ilot_min==1)
      LotDigits=0;
   lotsi=betcapital/marginsize;
   lotsi=NormalizeDouble(lotsi,LotDigits);
   if(lotsi>=ilot_max)
     {
      lotsi=ilot_max;
     }
   if(lotsi<ilot_min)
     {
      lotsi=ilot_min;
     }
   if(lotsi*marginsize>AccountInfoDouble(ACCOUNT_MARGIN_FREE))
     {
      lotsi=0;
     }
//---
//   Print("AccountBallance="+AccountBalance()+" Capital="+betcapital+" MarginSize="+marginsize+"==> Lots to Trade="+lotsi);
   return(lotsi);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculateLotX(double RiskPercent,int stopLoss)
  {
   double riskval = AccountInfoDouble(ACCOUNT_EQUITY)*(RiskPercent/100.0)/Bid();
 
   double pipValue=PipValue(Symbol());
   double minLot = MarketInfo(Symbol(),MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(),MODE_MAXLOT);
   double lots   = riskval/(stopLoss*pipValue);
   lots=CheckLot(lots);
   return lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CheckLot(double lot)
  {
   double ret=lot;
   double minlot = MarketInfo(Symbol(),MODE_MINLOT);
   double maxlot =MarketInfo(Symbol(),MODE_MAXLOT);
   double lotstep=MarketInfo(Symbol(),MODE_LOTSTEP);
   if(lot < minlot)
      lot = minlot;
   if(lot > maxlot)
      lot = maxlot;
   if(lotstep == 1.0)
     {
      lot = int(lot);
     }
   else
     {
      lot =lot / lotstep;
      lot = MathRound(lot);
      lot = lot*lotstep;
      //  lot=(lot/lotstep)*lotstep;
     }
   return lot;

  }


//+//////////////////////////////////////////////////////////////////+
//|                Ticks and Pips                                |
//+//////////////////////////////////////////////////////////////////+
bool calculatePIPS=false;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PPP()
  {
   double ret=0;
   if(calculatePIPS)
     {
      ret = PipValue(Symbol());
     }
   else
     {
      ret =  MarketInfo(Symbol(),MODE_POINT); // TickValue(); //
     }
//   ret = PipSize(Symbol());
//   ret = TickValue(Symbol());

   return ret;
  }
//|                                                                  |
//+------------------------------------------------------------------+
double _POINT()
  {
   double  ret =SymbolInfoDouble(_Symbol,SYMBOL_POINT)  ; //                            (Symbol(),MODE_POINT);
   if(Digits()%2==1)
     {
      // DE30=1/JPY=3/EURUSD=5 forum.mql4.com/43064#515262
      ret = ret*10;
     }
   return ret;
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TickValue()
  {
   double tickvalue=TickValue(Symbol());
   return tickvalue;
  }
//+------------------------------------------------------------------+
//|  https://www.mql5.com/en/forum/111230/page3
//|  Value of smallest Price Differenz
//+------------------------------------------------------------------+
double TickValue(string symbol)
  {
// Formel: MarketInfo(Symbol(),MODE_TICKVALUE)*point / MarketInfo(Symbol(),MODE_TICKSIZE)
   double tickvalue = MarketInfo(symbol, MODE_TICKVALUE);
   double ticksize  = MarketInfo(symbol, MODE_TICKSIZE);
   double point=MarketInfo(Symbol(),MODE_POINT);
   double tickvaluefix=tickvalue*point/ticksize;    // incl Leverage

   tickvaluefix=NormalizeDouble(tickvaluefix,Digits());

   return tickvaluefix;
  }

//+------------------------------------------------------------------+
//|  Value of Price Differenz for on Pip (letzte Nachkommastelle)    |
//+------------------------------------------------------------------+
double PipValue(string symbol)
  {
   double pipval=0;
   pipval=TickValue(symbol);
   int digits=(int)MarketInfo(symbol,MODE_DIGITS);
   if(digits==3 || digits==5)
     {
      pipval=pipval*10.0;
     }
   pipval=NormalizeDouble(pipval,Digits());
   return pipval;
  }

 //+------------------------------------------------------------------+
//|  Value of Price Differenz for on Pip     |
//+------------------------------------------------------------------+
double PipValuePerLot(string symbol=NULL,double lots=1)
  {
   double pipval=PipValue(symbol);

   pipval= pipval * lots;
   pipval=NormalizeDouble(pipval,Digits()+1);
   return pipval;
  }
//+------------------------------------------------------------------+
//|  Value of Price Differenz for on Pip (letzte Nachkommastelle)    |
//+------------------------------------------------------------------+
double PointValuePerLot(string symbol=NULL,double lots=1)
  {
   double tickval=TickValue(symbol);

   tickval= tickval * lots;
   tickval=NormalizeDouble(tickval,Digits()+1);
   return tickval;
  } 
  
double _adjustLots(double lots)
  {
   lots=lots*AccountInfoInteger(ACCOUNT_LEVERAGE);
   if(lots<0.01) // is money enough for opening 0.01 lot?
     {
      double freemargin =  AccountInfoDouble(ACCOUNT_FREEMARGIN);
      double buymargin=0;
      double sellmargin=0;
      bool okbuymargin =  OrderCalcMargin(ORDER_TYPE_BUY,Symbol(),0.01,Ask(),buymargin);
      bool oksellmargin =  OrderCalcMargin(ORDER_TYPE_SELL,Symbol(),0.01,Bid(),sellmargin);
      if (okbuymargin && oksellmargin && (buymargin<freemargin || sellmargin <freemargin))
        {
         lots=0.0; // not enough
        }
      else
        {
         lots=0.01; // enough; open 0.01
        }
     }
   else
     {
      lots=NormalizeDouble(lots,2);
     }
//  Comment("balance ",AccountBalance(),", risk ",riskcapital,", sl_pips ",sl_pips,", Lots ",Lots,", tickvalue ",tickvalue);

   return lots;
  }

double CheckTP(double val)
  {
   //RefreshRates();
   double ticksize=MarketInfo(Symbol(),MODE_TICKSIZE);
   double pips= ticksize;
   if(ticksize==0.00001|| ticksize==0.001)
      pips=ticksize*10;

   double SPREAD=MarketInfo(Symbol(),MODE_SPREAD);
   double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(val<StopLevel*pips+SPREAD*pips)
      val=StopLevel*pips+SPREAD*pips;
   return(NormalizeDouble(val, Digits()));
  }

double CheckSL(double SL)
  {
   double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(SL < StopLevel)
      SL=StopLevel;
   return SL;
  }

int CheckSLint(int SL)
  {
   int StopLevel=(int)MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(SL < StopLevel)
      SL=StopLevel;
   return SL;
  }  

double checkSL(double SL)
  {
   double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(SL < StopLevel)
      SL=StopLevel;
   return SL;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckStopLossPips(string symbol,int pips)
  {

   int minpips=(int)SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL); ///        MODE_STOPLEVEL);
   if(pips > 0 && pips < minpips)
      return minpips;
   else
      return pips;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  CheckStopLossValue(string symbol, int  mode, double price, double sl)
  {
   int pp =0;
   int pp_org=0;
   double _PT= Point();
   sl =NormalizeDouble(sl,Digits());
   price = NormalizeDouble(price,Digits());
   if(mode == OP_BUY)
     {
      pp_org = (price - sl) / _PT;
     }
   if(mode == OP_SELL)
     {
      pp_org = (sl - price) / _PT;
     }
   if(pp_org <= 0)
     {
      pp =(int)SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
      //      Print(__FUNCTION__,": pp=",pp);
     }
   else
     {
      pp = CheckStopLossPips(symbol,pp_org);
     }
   if(mode == OP_BUY)
     {
      sl = NormalizeDouble(price - pp*_PT, Digits());
     }
   if(mode == OP_SELL)
     {
      sl = NormalizeDouble(price + pp*_PT, Digits());
     }
   Print(__FUNCTION__,": pp_org=",pp_org," pp=",pp, " price=", price, " sl=",sl);
   return  sl;
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EnsureValidStop(string symbol,double price,double &sl)
  {
// Return if no S/L
   if(sl==0)
      return;

   double servers_min_stop=(int)SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL)*Point();

   if(MathAbs(price-sl)<=servers_min_stop)
     {
      // we have to adjust the stop.
      if(price>sl)
         sl=price-servers_min_stop;  // we are long

      else
         if(price<sl)
            sl=price+servers_min_stop;  // we are short

         else
            Print(__FUNCTION__+": EnsureValidStop: error, passed in price == sl, cannot adjust");

      sl=NormalizeDouble(sl,Digits());
     }
  }
