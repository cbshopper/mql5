//+------------------------------------------------------------------+
//|                                   RSI Arrow Out of Zone EA 3.mq5 |
//|                              Copyright © 2020, Vladimir Karputov |
//|                     https://www.mql5.com/ru/market/product/43516 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2020, Vladimir Karputov"
#property link      "https://www.mql5.com/ru/market/product/43516"
#property version   "3.001"
/*
   barabashkakvn Trading engine 3.128
*/
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
//---
CPositionInfo  m_position;                   // object of CPositionInfo class
CTrade         m_trade;                      // object of CTrade class
CSymbolInfo    m_symbol;                     // object of CSymbolInfo class
CAccountInfo   m_account;                    // object of CAccountInfo class
CDealInfo      m_deal;                       // object of CDealInfo class
COrderInfo     m_order;                      // object of COrderInfo class
CMoneyFixedMargin *m_money;                  // object of CMoneyFixedMargin class
//+------------------------------------------------------------------+
//| Enum Lor or Risk                                                 |
//+------------------------------------------------------------------+
enum ENUM_LOT_OR_RISK
  {
   lots_min=0, // Lots Min
   lot=1,      // Constant lot
   risk=2,     // Risk in percent for a deal
  };
//+------------------------------------------------------------------+
//| Enum Trade Mode                                                  |
//+------------------------------------------------------------------+
enum ENUM_TRADE_MODE
  {
   buy=0,      // Allowed only BUY positions
   sell=1,     // Allowed only SELL positions
   buy_sell=2, // Allowed BUY and SELL positions
  };
//--- input parameters
input group             "Trading settings"
input double   InpProfitTarget      = 15;          // Profit target, in deposit money
input double   InpMaximumLoss       = -45;         // Maximum loss, in deposit money
input ushort   InpSignalsFrequency  = 10;          // Search signals, in seconds (< "10" -> only on a new bar)
input group             "Position size management (lot calculation)"
input ENUM_LOT_OR_RISK InpLotOrRisk = risk;        // Money management: Lot OR Risk
input double   InpVolumeLotOrRisk   = 3.0;         // The value for "Money management"
input group             "Trade mode"
input ENUM_TRADE_MODE InpTradeMode  = buy_sell;    // Trade mode:
input group             "Max volume settings"
input double   InpMaxOneVolume      = 1.0;         // Maximum volume of one position (<= '0.0' -> OFF)
input double   InpMaxTotalVolume    = 5.0;         // Maximum volume of all positions (<= '0.0' -> OFF)
input uchar    InpMaxPositions      = 15;          // Maximum number of positions ('0.0' -> OFF)
input group             "Time control"
input bool     InpTimeControl       = true;        // Use time control
input uchar    InpStartHour         = 10;          // Start Hour
input uchar    InpStartMinute       = 01;          // Start Minute
input uchar    InpEndHour           = 15;          // End Hour
input uchar    InpEndMinute         = 02;          // End Minute
input ulong    InpDeviation         = 10;          // Deviation
input group             "RSI Arrow Out of Zone"
input int                  Inp_RSI_ma_period    = 14;          // RSI: averaging period
input ENUM_APPLIED_PRICE   Inp_RSI_applied_price= PRICE_CLOSE; // RSI: type of price
input int                  Inp_RSI_Level_Down   = 35.0;        // RSI: Value Level Down
input double               Inp_RSI_Level_Up     = 65.0;        // RSI: Value Level Up
input group             "Additional features"
input bool     InpOnlyOne           = false;       // Only one positions
input bool     InpReverse           = false;       // Reverse
input bool     InpCloseOpposite     = false;       // Close opposite
input bool     InpPrintLog          = false;       // Print log
input ulong    InpMagic             = 15272261;    // Magic number

input string INDICATORPATH          = "CB\\testing\\rsi_arrow_out_of_zone";
//---
int      handle_iCustom;                        // variable for storing the handle of the iCustom indicator

double   m_adjusted_point;                      // point value adjusted for 3 or 5 points
bool     m_need_close_all           = false;    // close all positions
datetime m_last_signal              = 0;        // "0" -> D'1970.01.01 00:00';
datetime m_prev_bars                = 0;        // "0" -> D'1970.01.01 00:00';
datetime m_last_deal_in             = 0;        // "0" -> D'1970.01.01 00:00';
int      m_bar_current              = 0;
//--- the tactic is this: for positions we strictly monitor the result ***
//+------------------------------------------------------------------+
//| Structure Positions                                              |
//+------------------------------------------------------------------+
struct STRUCT_POSITION
  {
   ENUM_POSITION_TYPE pos_type;              // position type
   double            volume;                 // position volume (if "0.0" -> the lot is "Money management")
   double            lot_coefficient;        // lot coefficient
   bool              waiting_transaction;    // waiting transaction, "true" -> it's forbidden to trade, we expect a transaction
   ulong             waiting_order_ticket;   // waiting order ticket, ticket of the expected order
   bool              transaction_confirmed;  // transaction confirmed, "true" -> transaction confirmed
   //--- Constructor
                     STRUCT_POSITION()
     {
      pos_type                   = WRONG_VALUE;
      volume                     = 0.0;
      lot_coefficient            = 0.0;
      waiting_transaction        = false;
      waiting_order_ticket       = 0;
      transaction_confirmed      = false;
     }
  };
STRUCT_POSITION SPosition[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
     {
      Print(__FILE__," ",__FUNCTION__,", ERROR: CSymbolInfo.Name");
      return(INIT_FAILED);
     }
   RefreshRates();
//---
   m_trade.SetExpertMagicNumber(InpMagic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(InpDeviation);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- check the input parameter "Lots"
   string err_text="";
   if(InpLotOrRisk==lot)
     {
      if(!CheckVolumeValue(InpVolumeLotOrRisk,err_text))
        {
         //--- when testing, we will only output to the log about incorrect input parameters
         if(MQLInfoInteger(MQL_TESTER))
           {
            Print(__FILE__," ",__FUNCTION__,", ERROR: ",err_text);
            return(INIT_FAILED);
           }
         else // if the Expert Advisor is run on the chart, tell the user about the error
           {
            Alert(__FILE__," ",__FUNCTION__,", ERROR: ",err_text);
            return(INIT_PARAMETERS_INCORRECT);
           }
        }
     }
   else
      if(InpLotOrRisk==risk)
        {
         if(m_money!=NULL)
            delete m_money;
         m_money=new CMoneyFixedMargin;
         if(m_money!=NULL)
           {
            if(InpVolumeLotOrRisk<1 || InpVolumeLotOrRisk>100)
              {
               Print(__FILE__," ",__FUNCTION__,", ERROR: ");
               Print("The value for \"Money management\" (",DoubleToString(InpVolumeLotOrRisk,2),") -> invalid parameters");
               Print("   parameter must be in the range: from 1.00 to 100.00");
               return(INIT_FAILED);
              }
            if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
              {
               Print(__FILE__," ",__FUNCTION__,", ERROR: CMoneyFixedMargin.Init");
               return(INIT_FAILED);
              }
            m_money.Percent(InpVolumeLotOrRisk);
           }
         else
           {
            Print(__FILE__," ",__FUNCTION__,", ERROR: Object CMoneyFixedMargin is NULL");
            return(INIT_FAILED);
           }
        }
//--- create handle of the indicator iCustom
   handle_iCustom=iCustom(m_symbol.Name(),Period(),INDICATORPATH,Inp_RSI_ma_period,
                          Inp_RSI_applied_price,
                          Inp_RSI_Level_Down,
                          Inp_RSI_Level_Up);
//--- if the handle is not created
   if(handle_iCustom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
     }
//---
   m_bar_current=(InpSignalsFrequency<10)?1:0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(m_money!=NULL)
      delete m_money;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(m_need_close_all)
     {
      if(IsPositionExists())
        {
         double level;
         if(FreezeStopsLevels(level))
           {
            CloseAllPositions(level);
            return;
           }
         else
            return;
        }
      else
         m_need_close_all=false;
     }
//---
   int size_need_position=ArraySize(SPosition);
   if(size_need_position>0)
     {
      for(int i=size_need_position-1; i>=0; i--)
        {
         if(SPosition[i].waiting_transaction)
           {
            if(!SPosition[i].transaction_confirmed)
              {
               if(InpPrintLog)
                  Print(__FILE__," ",__FUNCTION__,", OK: ","transaction_confirmed: ",SPosition[i].transaction_confirmed);
               return;
              }
            else
               if(SPosition[i].transaction_confirmed)
                 {
                  ArrayRemove(SPosition,i,1);
                  return;
                 }
           }
         if(SPosition[i].pos_type==POSITION_TYPE_BUY)
           {
            if(InpCloseOpposite || InpOnlyOne)
              {
               int      count_buys           = 0;
               double   volume_buys          = 0.0;
               double   volume_biggest_buys  = 0.0;
               int      count_sells          = 0;
               double   volume_sells         = 0.0;
               double   volume_biggest_sells = 0.0;
               CalculateAllPositions(count_buys,volume_buys,volume_biggest_buys,
                                     count_sells,volume_sells,volume_biggest_sells);
               if(InpCloseOpposite)
                 {
                  if(count_sells>0)
                    {
                     double level;
                     if(FreezeStopsLevels(level))
                        ClosePositions(POSITION_TYPE_SELL,level);
                     return;
                    }
                 }
               if(InpOnlyOne)
                 {
                  if(count_buys+count_sells==0)
                    {
                     double level;
                     if(FreezeStopsLevels(level))
                       {
                        SPosition[i].waiting_transaction=true;
                        OpenPosition(i,level);
                       }
                     return;
                    }
                  else
                     ArrayRemove(SPosition,i,1);
                  return;
                 }
              }
            double level;
            if(FreezeStopsLevels(level))
              {
               SPosition[i].waiting_transaction=true;
               OpenPosition(i,level);
              }
            return;
           }
         if(SPosition[i].pos_type==POSITION_TYPE_SELL)
           {
            if(InpCloseOpposite || InpOnlyOne)
              {
               int      count_buys           = 0;
               double   volume_buys          = 0.0;
               double   volume_biggest_buys  = 0.0;
               int      count_sells          = 0;
               double   volume_sells         = 0.0;
               double   volume_biggest_sells = 0.0;
               CalculateAllPositions(count_buys,volume_buys,volume_biggest_buys,
                                     count_sells,volume_sells,volume_biggest_sells);
               if(InpCloseOpposite)
                 {
                  if(count_buys>0)
                    {
                     double level;
                     if(FreezeStopsLevels(level))
                        ClosePositions(POSITION_TYPE_BUY,level);
                     return;
                    }
                 }
               if(InpOnlyOne)
                 {
                  if(count_buys+count_sells==0)
                    {
                     double level;
                     if(FreezeStopsLevels(level))
                       {
                        SPosition[i].waiting_transaction=true;
                        OpenPosition(i,level);
                       }
                     return;
                    }
                  else
                     ArrayRemove(SPosition,i,1);
                  return;
                 }
              }
            double level;
            if(FreezeStopsLevels(level))
              {
               SPosition[i].waiting_transaction=true;
               OpenPosition(i,level);
              }
            return;
           }
        }
     }
//--- close all
   double profit_all=ProfitAllPositions();
   if(profit_all>=InpProfitTarget || profit_all<=InpMaximumLoss)
     {
      m_need_close_all=true;
      return;
     }
//---
   if(InpSignalsFrequency>=10) // search for trading signals no more than once every 10 seconds
     {
      datetime time_current=TimeCurrent();
      if(time_current-m_last_signal>InpSignalsFrequency)
        {
         //--- search for trading signals
         if(!RefreshRates())
           {
            m_prev_bars=0;
            return;
           }
         if(!SearchTradingSignals())
           {
            m_prev_bars=0;
            return;
           }
         m_last_signal=time_current;
        }
     }
//--- we work only at the time of the birth of new bar
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==m_prev_bars)
      return;
   m_prev_bars=time_0;
   if(InpSignalsFrequency<10) // search for trading signals only at the time of the birth of new bar
     {
      if(!RefreshRates())
        {
         m_prev_bars=0;
         return;
        }
      //--- search for trading signals
      if(!SearchTradingSignals())
        {
         m_prev_bars=0;
         return;
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      if(HistoryDealSelect(trans.deal))
         m_deal.Ticket(trans.deal);
      else
         return;
      if(m_deal.Symbol()==m_symbol.Name() && m_deal.Magic()==InpMagic)
        {
         if(m_deal.DealType()==DEAL_TYPE_BUY || m_deal.DealType()==DEAL_TYPE_SELL)
           {
            if(m_deal.Entry()==DEAL_ENTRY_IN || m_deal.Entry()==DEAL_ENTRY_INOUT)
               m_last_deal_in=iTime(m_symbol.Name(),Period(),0);
            int size_need_position=ArraySize(SPosition);
            if(size_need_position>0)
              {
               for(int i=0; i<size_need_position; i++)
                 {
                  if(SPosition[i].waiting_transaction)
                     if(SPosition[i].waiting_order_ticket==m_deal.Order())
                       {
                        Print(__FUNCTION__," Transaction confirmed");
                        SPosition[i].transaction_confirmed=true;
                        break;
                       }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      if(InpPrintLog)
         Print(__FILE__," ",__FUNCTION__,", ERROR: ","RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
     {
      if(InpPrintLog)
         Print(__FILE__," ",__FUNCTION__,", ERROR: ","Ask == 0.0 OR Bid == 0.0");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the position volume                     |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем меньше минимально допустимого SYMBOL_VOLUME_MIN=%.2f",min_volume);
      else
         error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем больше максимально допустимого SYMBOL_VOLUME_MAX=%.2f",max_volume);
      else
         error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем не кратен минимальному шагу SYMBOL_VOLUME_STEP=%.2f, ближайший правильный объем %.2f",
                                        volume_step,ratio*volume_step);
      else
         error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                        volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots,CSymbolInfo &symbol)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=symbol.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=symbol.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=symbol.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
//| Check Freeze and Stops levels                                    |
//+------------------------------------------------------------------+
bool FreezeStopsLevels(double &level)
  {
//--- check Freeze and Stops levels
   /*
      Type of order/position  |  Activation price  |  Check
      ------------------------|--------------------|--------------------------------------------
      Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
      Buy Stop order          |  Ask               |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
      Sell Limit order        |  Bid               |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
      Sell Stop order         |  Bid               |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
      Buy position            |  Bid               |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL
                              |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
      Sell position           |  Ask               |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                              |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL

      Buying is done at the Ask price                 |  Selling is done at the Bid price
      ------------------------------------------------|----------------------------------
      TakeProfit        >= Bid                        |  TakeProfit        <= Ask
      StopLoss          <= Bid                        |  StopLoss          >= Ask
      TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
      Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
   */
   if(!RefreshRates() || !m_symbol.Refresh())
      return(false);
//--- FreezeLevel -> for pending order and modification
   double freeze_level=m_symbol.FreezeLevel()*m_symbol.Point();
   if(freeze_level==0.0)
      freeze_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
//--- StopsLevel -> for TakeProfit and StopLoss
   double stop_level=m_symbol.StopsLevel()*m_symbol.Point();
   if(stop_level==0.0)
      stop_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
   if(freeze_level<=0.0 || stop_level<=0.0)
      return(false);
   level=(freeze_level>stop_level)?freeze_level:stop_level;
   double spread=m_symbol.Spread()*m_symbol.Point()*3.0;
   level=(level>spread)?level:spread;
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Open position                                                    |
//|   double stop_loss                                               |
//|      -> pips * m_adjusted_point (if "0.0" -> the m_stop_loss)    |
//|   double take_profit                                             |
//|      -> pips * m_adjusted_point (if "0.0" -> the m_take_profit)  |
//+------------------------------------------------------------------+
void OpenPosition(const int index,const double level)
  {
   /*
      Buying is done at the Ask price                 |  Selling is done at the Bid price
      ------------------------------------------------|----------------------------------
      TakeProfit        >= Bid                        |  TakeProfit        <= Ask
      StopLoss          <= Bid                        |  StopLoss          >= Ask
      TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
      Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
   */
//--- buy
   if(SPosition[index].pos_type==POSITION_TYPE_BUY)
     {
      OpenBuy(index);
      return;
     }
//--- sell
   if(SPosition[index].pos_type==POSITION_TYPE_SELL)
     {
      OpenSell(index);
      return;
     }
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(const int index)
  {
   double sl=0.0;
   double tp=0.0;
   double long_lot=0.0;
   if(SPosition[index].volume>0.0)
      long_lot=SPosition[index].volume;
   else
     {
      if(InpLotOrRisk==risk)
        {
         long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", OK: ","sl=",DoubleToString(sl,m_symbol.Digits()),
                  ", CheckOpenLong: ",DoubleToString(long_lot,2),
                  ", Balance: ",    DoubleToString(m_account.Balance(),2),
                  ", Equity: ",     DoubleToString(m_account.Equity(),2),
                  ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
         if(long_lot==0.0)
           {
            ArrayRemove(SPosition,index,1);
            if(InpPrintLog)
               Print(__FILE__," ",__FUNCTION__,", ERROR: ","CMoneyFixedMargin.CheckOpenLong returned the value of 0.0");
            return;
           }
        }
      else
         if(InpLotOrRisk==lot)
            long_lot=InpVolumeLotOrRisk;
         else
            if(InpLotOrRisk==lots_min)
               long_lot=m_symbol.LotsMin();
            else
              {
               ArrayRemove(SPosition,index,1);
               return;
              }
     }
   if(SPosition[index].lot_coefficient>0.0)
     {
      long_lot=LotCheck(long_lot*SPosition[index].lot_coefficient,
                        m_symbol);
      if(long_lot==0)
        {
         ArrayRemove(SPosition,index,1);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","LotCheck returned the 0.0");
         return;
        }
     }
//---
   if(InpMaxOneVolume>0.0)
      if(long_lot>InpMaxOneVolume)
        {
         ArrayRemove(SPosition,index,1);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","long lot (",DoubleToString(long_lot,2),
                  ") > Maximum volume of one position (",DoubleToString(InpMaxOneVolume,2),")");
         return;
        }
   if(InpMaxTotalVolume>0.0)
     {
      double all_volumes=CalculateAllVolumes();
      if((long_lot+all_volumes)>InpMaxTotalVolume)
        {
         ArrayRemove(SPosition,index,1);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","long lot (",DoubleToString(long_lot,2),") + all volumes (",
                  DoubleToString(all_volumes,2),") > Maximum volume of all positions (",DoubleToString(InpMaxTotalVolume,2),")");
         return;
        }
     }
//--
   if(m_symbol.LotsLimit()>0.0)
     {
      int      count_buys           = 0;
      double   volume_buys          = 0.0;
      double   volume_biggest_buys  = 0.0;
      int      count_sells          = 0;
      double   volume_sells         = 0.0;
      double   volume_biggest_sells = 0.0;
      CalculateAllPositions(count_buys,volume_buys,volume_biggest_buys,
                            count_sells,volume_sells,volume_biggest_sells);
      if(volume_buys+volume_sells+long_lot>m_symbol.LotsLimit())
        {
         ArrayRemove(SPosition,index,1);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","#0 Buy, Volume Buy (",DoubleToString(volume_buys,2),
                  ") + Volume Sell (",DoubleToString(volume_sells,2),
                  ") + Volume long (",DoubleToString(long_lot,2),
                  ") > Lots Limit (",DoubleToString(m_symbol.LotsLimit(),2),")");
         return;
        }
     }
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check=m_account.FreeMarginCheck(m_symbol.Name(),
                            ORDER_TYPE_BUY,
                            long_lot,
                            m_symbol.Ask());
   double margin_check=m_account.MarginCheck(m_symbol.Name(),
                       ORDER_TYPE_BUY,
                       long_lot,
                       m_symbol.Ask());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Buy(long_lot,m_symbol.Name(),
                     m_symbol.Ask(),sl,tp)) // CTrade::Buy -> "true"
        {
         if(m_trade.ResultDeal()==0)
           {
            if(m_trade.ResultRetcode()==10009) // trade order went to the exchange
              {
               SPosition[index].waiting_transaction=true;
               SPosition[index].waiting_order_ticket=m_trade.ResultOrder();
              }
            else
              {
               SPosition[index].waiting_transaction=false;
               if(InpPrintLog)
                  Print(__FILE__," ",__FUNCTION__,", ERROR: ","#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            if(m_trade.ResultRetcode()==10009)
              {
               SPosition[index].waiting_transaction=true;
               SPosition[index].waiting_order_ticket=m_trade.ResultOrder();
              }
            else
              {
               SPosition[index].waiting_transaction=false;
               if(InpPrintLog)
                  Print(__FILE__," ",__FUNCTION__,", OK: ","#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         SPosition[index].waiting_transaction=false;
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
         if(InpPrintLog)
            PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      ArrayRemove(SPosition,index,1);
      if(InpPrintLog)
         Print(__FILE__," ",__FUNCTION__,", ERROR: ","CAccountInfo.FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(const int index)
  {
   double sl=0.0;
   double tp=0.0;
   double short_lot=0.0;
   if(SPosition[index].volume>0.0)
      short_lot=SPosition[index].volume;
   else
     {
      if(InpLotOrRisk==risk)
        {
         short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", OK: ","sl=",DoubleToString(sl,m_symbol.Digits()),
                  ", CheckOpenLong: ",DoubleToString(short_lot,2),
                  ", Balance: ",    DoubleToString(m_account.Balance(),2),
                  ", Equity: ",     DoubleToString(m_account.Equity(),2),
                  ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
         if(short_lot==0.0)
           {
            ArrayRemove(SPosition,index,1);
            if(InpPrintLog)
               Print(__FILE__," ",__FUNCTION__,", ERROR: ","CMoneyFixedMargin.CheckOpenShort returned the value of \"0.0\"");
            return;
           }
        }
      else
         if(InpLotOrRisk==lot)
            short_lot=InpVolumeLotOrRisk;
         else
            if(InpLotOrRisk==lots_min)
               short_lot=m_symbol.LotsMin();
            else
              {
               ArrayRemove(SPosition,index,1);
               return;
              }
     }
   if(SPosition[index].lot_coefficient>0.0)
     {
      short_lot=LotCheck(short_lot*SPosition[index].lot_coefficient,m_symbol);
      if(short_lot==0)
        {
         ArrayRemove(SPosition,index,1);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","LotCheck returned the 0.0");
         return;
        }
     }
//---
   if(InpMaxOneVolume>0.0)
      if(short_lot>InpMaxOneVolume)
        {
         ArrayRemove(SPosition,index,1);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","short lot (",DoubleToString(short_lot,2),
                  ") > Maximum volume of one position (",DoubleToString(InpMaxOneVolume,2),")");
         return;
        }
   if(InpMaxTotalVolume>0.0)
     {
      double all_volumes=CalculateAllVolumes();
      if((short_lot+all_volumes)>InpMaxTotalVolume)
        {
         ArrayRemove(SPosition,index,1);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","short lot (",DoubleToString(short_lot,2),") + all volumes (",
                  DoubleToString(all_volumes,2),") > Maximum volume of all positions (",DoubleToString(InpMaxTotalVolume,2),")");
         return;
        }
     }
//---
   if(m_symbol.LotsLimit()>0.0)
     {
      int      count_buys           = 0;
      double   volume_buys          = 0.0;
      double   volume_biggest_buys  = 0.0;
      int      count_sells          = 0;
      double   volume_sells         = 0.0;
      double   volume_biggest_sells = 0.0;
      CalculateAllPositions(count_buys,volume_buys,volume_biggest_buys,
                            count_sells,volume_sells,volume_biggest_sells);
      if(volume_buys+volume_sells+short_lot>m_symbol.LotsLimit())
        {
         ArrayRemove(SPosition,index,1);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","#0 Buy, Volume Buy (",DoubleToString(volume_buys,2),
                  ") + Volume Sell (",DoubleToString(volume_sells,2),
                  ") + Volume short (",DoubleToString(short_lot,2),
                  ") > Lots Limit (",DoubleToString(m_symbol.LotsLimit(),2),")");
         return;
        }
     }
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check=m_account.FreeMarginCheck(m_symbol.Name(),
                            ORDER_TYPE_SELL,
                            short_lot,
                            m_symbol.Bid());
   double margin_check=m_account.MarginCheck(m_symbol.Name(),
                       ORDER_TYPE_SELL,
                       short_lot,
                       m_symbol.Bid());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Sell(short_lot,m_symbol.Name(),
                      m_symbol.Bid(),sl,tp)) // CTrade::Sell -> "true"
        {
         if(m_trade.ResultDeal()==0)
           {
            if(m_trade.ResultRetcode()==10009) // trade order went to the exchange
              {
               SPosition[index].waiting_transaction=true;
               SPosition[index].waiting_order_ticket=m_trade.ResultOrder();
              }
            else
              {
               SPosition[index].waiting_transaction=false;
               if(InpPrintLog)
                  Print(__FILE__," ",__FUNCTION__,", ERROR: ","#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            if(m_trade.ResultRetcode()==10009)
              {
               SPosition[index].waiting_transaction=true;
               SPosition[index].waiting_order_ticket=m_trade.ResultOrder();
              }
            else
              {
               SPosition[index].waiting_transaction=false;
               if(InpPrintLog)
                  Print(__FILE__," ",__FUNCTION__,", OK: ","#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         SPosition[index].waiting_transaction=false;
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
         if(InpPrintLog)
            PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      ArrayRemove(SPosition,index,1);
      if(InpPrintLog)
         Print(__FILE__," ",__FUNCTION__,", ERROR: ","CAccountInfo.FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultTrade(CTrade &trade,CSymbolInfo &symbol)
  {
   Print(__FILE__," ",__FUNCTION__,", Symbol: ",symbol.Name()+", "+
         "Code of request result: "+IntegerToString(trade.ResultRetcode())+", "+
         "Code of request result as a string: "+trade.ResultRetcodeDescription(),
         "Trade execution mode: "+symbol.TradeExecutionDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal())+", "+
         "Order ticket: "+IntegerToString(trade.ResultOrder())+", "+
         "Order retcode external: "+IntegerToString(trade.ResultRetcodeExternal())+", "+
         "Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits())+", "+
         "Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits())+", "+
         "Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
  }
//+------------------------------------------------------------------+
//| Get value of buffers                                             |
//+------------------------------------------------------------------+
bool iGetArray(const int handle,const int buffer,const int start_pos,
               const int count,double &arr_buffer[])
  {
   bool result=true;
   if(!ArrayIsDynamic(arr_buffer))
     {
      if(InpPrintLog)
         PrintFormat("ERROR! EA: %s, FUNCTION: %s, this a no dynamic array!",__FILE__,__FUNCTION__);
      return(false);
     }
   ArrayFree(arr_buffer);
//--- reset error code
   ResetLastError();
//--- fill a part of the iBands array with values from the indicator buffer
   int copied=CopyBuffer(handle,buffer,start_pos,count,arr_buffer);
   if(copied!=count)
     {
      //--- if the copying fails, tell the error code
      if(InpPrintLog)
         PrintFormat("ERROR! EA: %s, FUNCTION: %s, amount to copy: %d, copied: %d, error code %d",
                     __FILE__,__FUNCTION__,count,copied,GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type,const double level)
  {
   /*
      Buying is done at the Ask price                 |  Selling is done at the Bid price
      ------------------------------------------------|----------------------------------
      TakeProfit        >= Bid                        |  TakeProfit        <= Ask
      StopLoss          <= Bid                        |  StopLoss          >= Ask
      TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
      Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
   */
   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of current positions
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==InpMagic)
            if(m_position.PositionType()==pos_type)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  bool take_profit_level=((m_position.TakeProfit()!=0.0 && m_position.TakeProfit()-m_position.PriceCurrent()>=level) || m_position.TakeProfit()==0.0);
                  bool stop_loss_level=((m_position.StopLoss()!=0.0 && m_position.PriceCurrent()-m_position.StopLoss()>=level) || m_position.StopLoss()==0.0);
                  if(take_profit_level && stop_loss_level)
                     if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
                        if(InpPrintLog)
                           Print(__FILE__," ",__FUNCTION__,", ERROR: ","CTrade.PositionClose ",m_position.Ticket());
                 }
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  bool take_profit_level=((m_position.TakeProfit()!=0.0 && m_position.PriceCurrent()-m_position.TakeProfit()>=level) || m_position.TakeProfit()==0.0);
                  bool stop_loss_level=((m_position.StopLoss()!=0.0 && m_position.StopLoss()-m_position.PriceCurrent()>=level) || m_position.StopLoss()==0.0);
                  if(take_profit_level && stop_loss_level)
                     if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
                        if(InpPrintLog)
                           Print(__FILE__," ",__FUNCTION__,", ERROR: ","CTrade.PositionClose ",m_position.Ticket());
                 }
              }
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
void CalculateAllPositions(int &count_buys,double &volume_buys,double &volume_biggest_buys,
                           int &count_sells,double &volume_sells,double &volume_biggest_sells)
  {
   count_buys  = 0;
   volume_buys   = 0.0;
   volume_biggest_buys  = 0.0;
   count_sells = 0;
   volume_sells  = 0.0;
   volume_biggest_sells = 0.0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               count_buys++;
               volume_buys+=m_position.Volume();
               if(m_position.Volume()>volume_biggest_buys)
                  volume_biggest_buys=m_position.Volume();
               continue;
              }
            else
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  count_sells++;
                  volume_sells+=m_position.Volume();
                  if(m_position.Volume()>volume_biggest_sells)
                     volume_biggest_sells=m_position.Volume();
                 }
           }
  }
//+------------------------------------------------------------------+
//| Search trading signals                                           |
//+------------------------------------------------------------------+
bool SearchTradingSignals(void)
  {
   if(m_prev_bars==m_last_deal_in) // on one bar - only one deal
      return(true);
   if(!TimeControlHourMinute())
      return(true);
   /*
   //--- Set as an empty value in indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0); -> OversoldBuffer
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0); -> OverboughtBuffer
   */
   double oversold_buffer[],overbought_buffer[];
   ArraySetAsSeries(oversold_buffer,true);
   ArraySetAsSeries(overbought_buffer,true);
   int start_pos=0,count=3;
   if(!iGetArray(handle_iCustom,0,start_pos,count,oversold_buffer) ||
      !iGetArray(handle_iCustom,1,start_pos,count,overbought_buffer))
     {
      return(false);
     }
   int size_need_position=ArraySize(SPosition);
   if(oversold_buffer[m_bar_current]!=0.0)
     {
      if(!InpReverse)
        {
         if(InpTradeMode!=sell)
           {
            if(m_prev_bars==m_last_deal_in) // on one bar - only one deal
               return(true);
            if(InpMaxPositions>0.0)
               if(InpMaxPositions==CalculateAllPositions())
                  return(true);
            ArrayResize(SPosition,size_need_position+1);
            SPosition[size_need_position].pos_type=POSITION_TYPE_BUY;
            if(InpPrintLog)
               Print(__FILE__," ",__FUNCTION__,", OK: ","Signal BUY");
            return(true);
           }
        }
      else
        {
         if(InpTradeMode!=buy)
           {
            if(m_prev_bars==m_last_deal_in) // on one bar - only one deal
               return(true);
            if(InpMaxPositions>0.0)
               if(InpMaxPositions==CalculateAllPositions())
                  return(true);
            ArrayResize(SPosition,size_need_position+1);
            SPosition[size_need_position].pos_type=POSITION_TYPE_SELL;
            if(InpPrintLog)
               Print(__FILE__," ",__FUNCTION__,", OK: ","Signal SELL");
            return(true);
           }
        }
     }
   if(overbought_buffer[m_bar_current]!=0.0)
     {
      if(!InpReverse)
        {
         if(InpTradeMode!=buy)
           {
            if(m_prev_bars==m_last_deal_in) // on one bar - only one deal
               return(true);
            if(InpMaxPositions>0.0)
               if(InpMaxPositions==CalculateAllPositions())
                  return(true);
            ArrayResize(SPosition,size_need_position+1);
            SPosition[size_need_position].pos_type=POSITION_TYPE_SELL;
            if(InpPrintLog)
               Print(__FILE__," ",__FUNCTION__,", OK: ","Signal SELL");
            return(true);
           }
        }
      else
        {
         if(InpTradeMode!=sell)
           {
            if(m_prev_bars==m_last_deal_in) // on one bar - only one deal
               return(true);
            if(InpMaxPositions>0.0)
               if(InpMaxPositions==CalculateAllPositions())
                  return(true);
            ArrayResize(SPosition,size_need_position+1);
            SPosition[size_need_position].pos_type=POSITION_TYPE_BUY;
            if(InpPrintLog)
               Print(__FILE__," ",__FUNCTION__,", OK: ","Signal BUY");
            return(true);
           }
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Is position exists                                               |
//+------------------------------------------------------------------+
bool IsPositionExists(void)
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==InpMagic)
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions(const double level)
  {
   /*
      Buying is done at the Ask price                 |  Selling is done at the Bid price
      ------------------------------------------------|----------------------------------
      TakeProfit        >= Bid                        |  TakeProfit        <= Ask
      StopLoss          <= Bid                        |  StopLoss          >= Ask
      TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
      Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
   */
   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of current positions
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==InpMagic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               bool take_profit_level=(m_position.TakeProfit()!=0.0 && m_position.TakeProfit()-m_position.PriceCurrent()>=level) || m_position.TakeProfit()==0.0;
               bool stop_loss_level=(m_position.StopLoss()!=0.0 && m_position.PriceCurrent()-m_position.StopLoss()>=level) || m_position.StopLoss()==0.0;
               if(take_profit_level && stop_loss_level)
                  if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
                     if(InpPrintLog)
                        Print(__FILE__," ",__FUNCTION__,", ERROR: ","CTrade.PositionClose ",m_position.Ticket());
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               bool take_profit_level=(m_position.TakeProfit()!=0.0 && m_position.PriceCurrent()-m_position.TakeProfit()>=level) || m_position.TakeProfit()==0.0;
               bool stop_loss_level=(m_position.StopLoss()!=0.0 && m_position.StopLoss()-m_position.PriceCurrent()>=level) || m_position.StopLoss()==0.0;
               if(take_profit_level && stop_loss_level)
                  if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
                     if(InpPrintLog)
                        Print(__FILE__," ",__FUNCTION__,", ERROR: ","CTrade.PositionClose ",m_position.Ticket());
              }
           }
  }
//+------------------------------------------------------------------+
//| TimeControl                                                      |
//+------------------------------------------------------------------+
bool TimeControlHourMinute(void)
  {
   if(!InpTimeControl)
      return(true);
   MqlDateTime STimeCurrent;
   datetime time_current=TimeCurrent();
   if(time_current==D'1970.01.01 00:00')
      return(false);
   TimeToStruct(time_current,STimeCurrent);
   if((InpStartHour*60*60+InpStartMinute*60)<(InpEndHour*60*60+InpEndMinute*60)) // intraday time interval
     {
      /*
      Example:
      input uchar    InpStartHour      = 5;        // Start hour
      input uchar    InpEndHour        = 10;       // End hour
      0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15
      _  _  _  _  _  +  +  +  +  +  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  +  +  +  +  +  _  _  _  _  _  _
      */
      if((STimeCurrent.hour*60*60+STimeCurrent.min*60>=InpStartHour*60*60+InpStartMinute*60) &&
         (STimeCurrent.hour*60*60+STimeCurrent.min*60<InpEndHour*60*60+InpEndMinute*60))
         return(true);
     }
   else
      if((InpStartHour*60*60+InpStartMinute*60)>(InpEndHour*60*60+InpEndMinute*60)) // time interval with the transition in a day
        {
         /*
         Example:
         input uchar    InpStartHour      = 10;       // Start hour
         input uchar    InpEndHour        = 5;        // End hour
         0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15
         _  _  _  _  _  _  _  _  _  _  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  _  _  _  _  _  +  +  +  +  +  +
         */
         if(STimeCurrent.hour*60*60+STimeCurrent.min*60>=InpStartHour*60*60+InpStartMinute*60 ||
            STimeCurrent.hour*60*60+STimeCurrent.min*60<InpEndHour*60*60+InpEndMinute*60)
            return(true);
        }
      else
         return(false);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Profit all positions                                             |
//+------------------------------------------------------------------+
double ProfitAllPositions(void)
  {
   double profit=0.0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==InpMagic)
            profit+=m_position.Commission()+m_position.Swap()+m_position.Profit();
//---
   return(profit);
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
int CalculateAllPositions()
  {
   int total=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==InpMagic)
            total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Calculate all volumes                                            |
//+------------------------------------------------------------------+
double CalculateAllVolumes()
  {
   double volumes=0.0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==InpMagic)
            volumes+=m_position.Volume();
//---
   return(volumes);
  }
//+------------------------------------------------------------------+