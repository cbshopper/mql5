//+------------------------------------------------------------------+
//|                                                     ExpertCB.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

/* / Template:
in Input Declarations:
input int            Expert_MaxPositions           = 10;        // max. open Positions
input bool           Expert_AllowMultiOrders    = true;      // allow multiple open Positions
input int            Expert_MinBarDiff          = 2;        // min Bar diff between Positions
input int            Expert_VDelayMinutes   =60;          // delay of virtual stops
input bool           Expert_VUse            = false;      // use VTAKE/VSTOP instead fo Take/Stop


in CODE:
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
==> insert:
   ExtExpert.MultiOrderMode(Expert_AllowMultiOrders);
   ExtExpert.MaxPositions(Expert_MaxPositions);
   ExtExpert.MinBarDiff(Expert_MinBarDiff);
   ExtExpert.StopLevel(Signal_StopLevel);
   ExtExpert.TakeLevel(Signal_TakeLevel);
   ExtExpert.VDelay(Expert_VDelayMinutes);
   ExtExpert.VUse(Expert_VUse);
<== insert;
*/



#define CEXPERT_CB

#include <Expert\Expert.mqh>

//#include <Expert\CB\ExpertSignal.mqh>
#include <Expert\CB\PositionCB.mqh>
#include <Expert\CB\ExpertSignalCB.mqh>
//#define CExpertSignalCB CExpertSignal
//+------------------------------------------------------------------+
class CExpertCB : public CExpert
  {

protected:
   CPositionInfoCB    m_position;                 // position info object
   CExpertSignalCB    *m_signalCB ;                   // trading signals object
   CExpertSignalCB    *exit_signal;                   // trading signals object
   int               maxPositions;
   int               minBarDiff;
   bool              allowMultiOrder;

   bool              CheckExitSignal();
   bool              CheckExitLong(void);
   bool              CheckExitShort(void);
   void              GetExitSignal(void);

   int               v_stoploss;
   int               v_takeprofit;
   bool              v_use;
   int               v_delay;


public:
                     CExpertCB(void);
                    ~CExpertCB(void);
   bool              Init(string symbol,ENUM_TIMEFRAMES period,bool every_tick,ulong magic=0);

/*
   void              StopLevel(int value) { v_stoploss = value; if (m_signal != NULL) m_signal.StopLevel(value); }
   void              TakeLevel(int value) { v_takeprofit = value; if (m_signal != NULL) m_signal.TakeLevel(value);  }
   void              VUse(int value) { v_use = value; if(v_use) {m_signal.TakeLevel(0); m_signal.StopLevel(0);}}
   */
   void              StopLevel(int value) { v_stoploss = value;  }
   void              TakeLevel(int value) { v_takeprofit = value;   }
   void              VUse(int value) { v_use = value; }

   void              VDelay(int value) {v_delay=value*60;}




   virtual         bool              CheckClose(void) override;
   void              MaxPositions(int value) {maxPositions=value;}
   void              MultiOrderMode(bool value) {allowMultiOrder=value;}
   void              MinBarDiff(int value) {minBarDiff=value;}
   //--- processing (main method)
   virtual bool      Processing(void);
   virtual  void      OnTick(void);
   //  bool              InitSignal(CExpertSignal *signal);
   bool              InitIndicators(CIndicators *indicators=NULL);
   //bool              InitExitSignal(CExpertSignal *signal);
   virtual bool      InitExitSignal(CExpertSignalCB *signal=NULL);
   void              DeinitExitSignal();
   void              Deinit();
   bool              ValidationSettings();
   void              Magic(ulong value);
   void              SetSignal(CExpertSignal *sig) { m_signalCB = (CExpertSignalCB*) GetPointer(sig); }

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CExpertCB::CExpertCB(void): maxPositions(1),
   allowMultiOrder(false),
   minBarDiff(2),
   v_use(false),
   v_delay(0),
   v_stoploss(0),
   v_takeprofit(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CExpertCB::~CExpertCB(void)
  {
  }

//+------------------------------------------------------------------+
//| Initialization and checking for input parameters                 |
//+------------------------------------------------------------------+
bool CExpertCB::Init(string symbol,ENUM_TIMEFRAMES period,bool every_tick,ulong magic)
  {
//--- returns false if the EA is initialized on a symbol/timeframe different from the current one
   if(symbol!=::Symbol() || period!=::Period())
     {
      PrintFormat(__FUNCTION__+": wrong symbol or timeframe (must be %s:%s)",symbol,EnumToString(period));
      return(false);
     }
//--- initialize common information
   if(m_symbol==NULL)
     {
      if((m_symbol=new CSymbolInfo)==NULL)
         return(false);
     }
   if(!m_symbol.Name(symbol))
      return(false);
   m_period    =period;
   m_every_tick=every_tick;
   m_magic     =magic;
   SetMarginMode();
   if(every_tick)
      TimeframeAdd(WRONG_VALUE);            // add all periods
   else
      TimeframeAdd(period);                 // add specified period
//--- tuning for 3 or 5 digits
   int digits_adjust=(m_symbol.Digits()==3 || m_symbol.Digits()==5) ? 10 : 1;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- initializing objects expert
   if(!InitTrade(magic))
     {
      Print(__FUNCTION__+": error initialization trade object");
      return(false);
     }
   if(!InitSignal())
     {
      Print(__FUNCTION__+": error initialization signal object");
      return(false);
     }
   if(!InitExitSignal())
     {
      Print(__FUNCTION__+": error initialization signal object");
      return(false);
     }
   if(!InitTrailing())
     {
      Print(__FUNCTION__+": error initialization trailing object");
      return(false);
     }
   if(!InitMoney())
     {
      Print(__FUNCTION__+": error initialization money object");
      return(false);
     }
   if(!InitParameters())
     {
      Print(__FUNCTION__+": error initialization parameters");
      return(false);
     }
//--- initialization for working with trade history
   PrepareHistoryDate();
   HistoryPoint();
//--- primary initialization is successful, pass to the phase of tuning
   m_init_phase=INIT_PHASE_TUNING;
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization signal object                                     |
//+------------------------------------------------------------------+
bool CExpertCB::InitExitSignal(CExpertSignalCB *signal)
  {
   if(exit_signal!=NULL)
      delete exit_signal;
//---
   if(signal==NULL)
     {
      if((exit_signal=new CExpertSignalCB)==NULL)
         return(false);
     }
   else
      exit_signal=signal;
//--- initializing signal object
   if(!exit_signal.Init(GetPointer(m_symbol),m_period,m_adjusted_point))
      return(false);
   exit_signal.EveryTick(m_every_tick);
   exit_signal.Magic(m_magic);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Sets magic number for object and its dependent objects           |
//+------------------------------------------------------------------+
void CExpertCB::Magic(ulong value)
  {
   if(exit_signal!=NULL)
      exit_signal.Magic(value);

   CExpert::Magic(value);
  }
//+------------------------------------------------------------------+
//| Deinitialization signal object                                   |
//+------------------------------------------------------------------+
void CExpertCB::DeinitExitSignal(void)
  {
   if(exit_signal!=NULL)
     {
      delete exit_signal;
      exit_signal=NULL;
     }
  }

//+------------------------------------------------------------------+
//| Deinitialization expert                                          |
//+------------------------------------------------------------------+
void CExpertCB::Deinit(void)
  {
   DeinitExitSignal();
   CExpert::Deinit();

  }
//+------------------------------------------------------------------+
//| Validation settings                                              |
//+------------------------------------------------------------------+
bool CExpertCB::ValidationSettings(void)
  {

   if(!CExpert::ValidationSettings())
     {
      return false;
     }

   if(exit_signal!=NULL)
     {
      if(!exit_signal.ValidationSettings())
        {
         Print(__FUNCTION__+": error exit signal parameters");
         return(false);
        }
     }
//--- ok
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertCB::InitIndicators(CIndicators *indicators)
  {
   if(!CExpert::InitIndicators(indicators))
     {
      return false;
     }
   if(exit_signal!=NULL)
     {
      CIndicators *indicators_ptr=GetPointer(m_indicators);
      m_used_series|=exit_signal.UsedSeries();
      exit_signal.SetPriceSeries(m_open,m_high,m_low,m_close);
      exit_signal.SetOtherSeries(m_spread,m_time,m_tick_volume,m_real_volume);

      if(!exit_signal.InitIndicators(indicators_ptr))
        {
         Print(__FUNCTION__+": error initialization indicators of exit signal object");
         return(false);
        }
     }
//--- ok
   return(true);

  }



//+------------------------------------------------------------------+
//| Check for position close or limit/stop order delete              |
//+------------------------------------------------------------------+
bool CExpertCB::CheckClose(void)
  {
   double lot = m_position.Volume();

//--- extended, from PostionCB.mqh
   if(v_use)
     {
      {m_signal.TakeLevel(0); m_signal.StopLevel(0);}
      if(m_position.CheckClose(v_delay,v_takeprofit,v_stoploss))   //!changed
         return(CloseAll(lot));
     }
//---
   bool ret = CExpert::CheckClose();
   return ret;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpertCB::GetExitSignal()
  {
//  return false;
//Print(__FUNCTION__);
   if(exit_signal != NULL)
     {
      exit_signal.SetDirection();
      double d = exit_signal.Direction();
      Print(__FUNCTION__,": ExitDirection=",d);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertCB::CheckExitSignal()
  {
  if (exit_signal==NULL) return false; 
  
   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      //--- check the possibility of closing the long position / delete pending orders to buy
      if(CheckExitLong())
        {
         DeleteOrdersLong();
         return(true);
        }
     }
   else
     {
      //--- check the possibility of closing the short position / delete pending orders to sell
      if(CheckExitShort())
        {
         DeleteOrdersShort();
         return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for long position close or limit/stop order delete         |
//+------------------------------------------------------------------+
bool CExpertCB::CheckExitLong(void)
  {
   if(exit_signal==NULL)
      return false;
   double price=EMPTY_VALUE;
//--- check for long close operations
   if(exit_signal.CheckCloseLong(price))
     {
      Print(__FUNCTION__,": CheckExitLong=true");
      return(CloseLong(price));
     }
   Print(__FUNCTION__,": CheckExitLong=false");
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for short position close or limit/stop order delete        |
//+------------------------------------------------------------------+
bool CExpertCB::CheckExitShort(void)
  {
   if(exit_signal==NULL)
      return false;
   double price=EMPTY_VALUE;
//--- check for short close operations
   if(exit_signal.CheckCloseShort(price))
     {
      Print(__FUNCTION__,": CheckExitShort=true");
      return(CloseShort(price));
     }
   Print(__FUNCTION__,": CheckExitShort=false");
//--- return without operations
   return(false);
  }

//+------------------------------------------------------------------+
//| Main function                                                    |
//+------------------------------------------------------------------+
bool CExpertCB::Processing(void)
  {

   bool ret=false;
//--- calculate signal direction once
//m_signal.SetDirection();
// m_signal.Direction(false);
//   m_signal.SetDirection();
   SetSignal(m_signal);
   m_signalCB.SetDirection();
   Print(__FUNCTION__,": ENTRY Direction=",m_signalCB.GetDirection());
//--- check if open positions
   int total=PositionsTotal();
//  Print(__FUNCTION__,": total Positions=",total);
   if(total!=0)
     {
      exit_signal.SetDirection();
      Print(__FUNCTION__,": EXIT Direction=",exit_signal.GetDirection());
      for(int i=total-1; i>=0; i--)
        {
         if(m_position.SelectByIndex(i))
           {
            //-- check exit signal
            if(CheckExitSignal())
               //     if (false)
              {
               Print(__FUNCTION__,": CheckExitSignal=true");
               ret=true;
              }
            else
              {
               //--- open position is available
               //--- check the possibility of reverse the position
               if(CheckReverse())
                 {
                  Print(__FUNCTION__,": CheckReverse=true");
                  ret=true;
                 }
               else
                 {
                  //--- check the possibility of closing the position/delete pending orders
                  if(!CheckClose())
                    {
                     //--- check the possibility of modifying the position
                     if(CheckTrailingStop())
                       {
                        Print(__FUNCTION__,": CheckTrailingStop=true");
                        ret = true;
                       }
                    }
                  else
                    { Print(__FUNCTION__,": CheckClose=true");}
                 }
              }
           }
        }
     }

//--- check if plased pending orders
   total=OrdersTotal();
//   Print(__FUNCTION__,": total Orders=",total);
   if(total!=0)
     {
      for(int i=total-1; i>=0; i--)
        {
         m_order.SelectByIndex(i);
         if(m_order.Symbol()!=m_symbol.Name())
            continue;
         if(m_order.OrderType()==ORDER_TYPE_BUY_LIMIT || m_order.OrderType()==ORDER_TYPE_BUY_STOP)
           {
            //--- check the ability to delete a pending order to buy
            if(CheckDeleteOrderLong())
               return(true);
            //--- check the possibility of modifying a pending order to buy
            if(CheckTrailingOrderLong())
               return(true);
           }
         else
           {
            //--- check the ability to delete a pending order to sell
            if(CheckDeleteOrderShort())
               return(true);
            //--- check the possibility of modifying a pending order to sell
            if(CheckTrailingOrderShort())
               return(true);
           }
         //--- return without operations
         return(false);
        }
     }
   total=PositionsTotal();
   if(!allowMultiOrder)
      maxPositions=1;
   Print(__FUNCTION__,": ????????????????? ENTRY Direction=",m_signalCB.GetDirection(), " total=",total," maxPositions=",maxPositions);


   if((total >= maxPositions))
      return ret;

   if(total>0  && minBarDiff>0)
     {
      m_position.SelectByIndex(total - 1);
      if(m_position.Time() >= iTime(NULL,0,minBarDiff))
        {
         return false;
        }
     }

//--- check the possibility of opening a position/setting pending order
   Print(__FUNCTION__,": ????????????????? Direction=",m_signalCB.GetDirection());
   if(CheckOpen())
      return(true);
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| OnTick handler                                                   |
//+------------------------------------------------------------------+
void CExpertCB::OnTick(void)
  {

// Processing(); return;
//--- check process flag
   if(!m_on_tick_process)
      return;
//--- updated quotes and indicators
   if(!Refresh())
      return;
//--- expert processing
   CExpertCB::Processing();
  }

//+------------------------------------------------------------------+
