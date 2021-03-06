//+------------------------------------------------------------------+
//|                                                     ExpertCB.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>

#include <Expert\CB\ExpertSignalCB.mqh>
#include <Expert\CB\PositionCB.mqh>
//#define CExpertSignalCB CExpertSignal
//+------------------------------------------------------------------+
class CExpertCB : public CExpert
  {

protected:
   CPositionInfoCB    m_position;                 // position info object
   // CExpertSignalCB   *m_signal;
   // CExpertSignalCB   *exit_signal;
   CExpertSignalCB   *exit_signal;
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


   bool              VUse(void) {return v_use;}
   int               VDelay(void) {return v_delay;}
   double            VStopLevel(void) {return v_stoploss;}
   double            VTakeLevel(void) {return v_takeprofit;}
   void              VStopLevel(int value) { v_stoploss = value;  m_signal.StopLevel(value); }
   void              VTakeLevel(int value) { v_takeprofit = value; m_signal.TakeLevel(value);  }
   void              VUse(int value) { v_use = value; if(v_use) {m_signal.TakeLevel(0); m_signal.StopLevel(0);}}
   void              VDelay(int value) {v_delay=value*60;}




   bool              CheckClose(void);
   void              MaxPositions(int value) {maxPositions=value;}
   void              MultiOrderMode(bool value) {allowMultiOrder=value;}
   void              MinBarDiff(int value) {minBarDiff=value;}
   //--- processing (main method)
   virtual bool      Processing(void);
   virtual  void      OnTick(void);
   bool              InitSignal(CExpertSignalCB *signal);
   bool              InitIndicators(CIndicators *indicators=NULL);
   bool              InitExitSignal(CExpertSignalCB *signal);
   void              DeinitExitSignal();
   void              Deinit();
   bool              ValidationSettings();
   void              Magic(ulong value);

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CExpertCB::CExpertCB(void): maxPositions(1), allowMultiOrder(false),minBarDiff(2)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CExpertCB::~CExpertCB(void)
  {
  }

//+------------------------------------------------------------------+
//| Initialization signal object                                     |
//+------------------------------------------------------------------+
bool CExpertCB::InitSignal(CExpertSignalCB *signal)
  {
   if(m_signal!=NULL)
      delete m_signal;
//---
   if(signal==NULL)
     {
      if((m_signal=new CExpertSignalCB)==NULL)
         return(false);
     }
   else
      m_signal=signal;
//  CExpert::InitSignal(signal);
   if(!m_signal.Init(GetPointer(m_symbol),m_period,m_adjusted_point))
      return(false);
   m_signal.EveryTick(m_every_tick);
   m_signal.Magic(m_magic);
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
      if((exit_signal=new CExpertSignal)==NULL)
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
   double lot;
   if(m_position.CheckClose(v_delay,v_takeprofit,v_stoploss))   //!changed
      return(CloseAll(lot));
//--- position must be selected before call
   if((lot=m_money.CheckClose(GetPointer(m_position)))!=0.0)
      return(CloseAll(lot));
//--- check for position type
   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      //--- check the possibility of closing the long position / delete pending orders to buy
      if(CheckCloseLong())
        {
         DeleteOrdersLong();
         return(true);
        }
     }
   else
     {
      //--- check the possibility of closing the short position / delete pending orders to sell
      if(CheckCloseShort())
        {
         DeleteOrdersShort();
         return(true);
        }
     }
//--- return without operations
   return(false);
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
      //  d=m_signal.Direction();
      // exit_signal.setDir(d);
      //  if(d != 0)
      Print(__FUNCTION__,": ExitDirection=",d);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertCB::CheckExitSignal()
  {
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

//if(!allowMultiOrder)
//  {
//   return CExpert::Processing();
//  }
   bool ret=false;
//--- calculate signal direction once
   m_signal.SetDirection();
   Print(__FUNCTION__,": Direction=",m_signal.Direction());
//--- check if open positions
   int total=PositionsTotal();
   Print(__FUNCTION__,": total Positions=",total);
   if(total!=0)
     {
      GetExitSignal();
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
   Print(__FUNCTION__,": total Orders=",total);
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
   if((total >= maxPositions))
      return ret;

   if(total>0)
     {
      m_position.SelectByIndex(total - 1);
      if(m_position.Time() >= iTime(NULL,0,minBarDiff))
        {
         return false;
        }
     }

//--- check the possibility of opening a position/setting pending order
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
   Processing();
  }

//+------------------------------------------------------------------+
