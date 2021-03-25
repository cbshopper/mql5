//+------------------------------------------------------------------+
//|                                                     ExpertCB.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>

#include <Expert\CB\ExpertSignalCB.mqh>
#include <Expert\CB\ExpertExitSignalCB.mqh>
#include <Expert\CB\PositionCB.mqh>

//+------------------------------------------------------------------+
class CExpertCB : public CExpert
  {

protected:
   CPositionInfoCB    m_position;                 // position info object
   CExpertSignalCB   *m_signal;
   int               maxOrders;
   int               minBarDiff;
   bool              allowMultiOrder;
   CExpertExitSignalCB *m_exit_signal;

   bool              CheckExitSignal();
   bool              CheckExitLong(void);
   bool              CheckExitShort(void);


public:
                     CExpertCB(void);
                    ~CExpertCB(void);
   bool              CheckClose(void);
   virtual bool      InitSignal(CExpertSignalCB *signal);
   void              MaxOrders(int value) {maxOrders=value;}
   void              MultiOrderMode(bool value) {allowMultiOrder=value;}
   int               MaxOrders(void) {return allowMultiOrder;}
   bool              MultiOrderMode(void) {return allowMultiOrder;}
   void              MinBarDiff(int value) {minBarDiff=value;}
   //--- processing (main method)
   virtual bool      Processing(void);
   virtual bool      InitExitSignal(CExpertExitSignalCB *signal=NULL);
   bool              InitExitIndicators(CIndicators *indicators=NULL);
   bool              ValidationExitSettings();
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CExpertCB::CExpertCB(void): maxOrders(2), allowMultiOrder(false),minBarDiff(2)
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
   CExpert::InitSignal(signal);
   return(true);
  }

//+------------------------------------------------------------------+
//| Initialization exit signal object                                     |
//+------------------------------------------------------------------+
bool CExpertCB::InitExitSignal(CExpertExitSignalCB *signal)
  {
   if(m_exit_signal!=NULL)
      delete m_exit_signal;
//---
   m_exit_signal=signal;
   if(m_exit_signal != NULL)
     {
      if(!m_exit_signal.Init(GetPointer(m_symbol),m_period,m_adjusted_point))
         return(false);
      m_exit_signal.EveryTick(m_every_tick);
      m_exit_signal.Magic(m_magic);
      m_init_phase=INIT_PHASE_TUNING; //!!!!!!!!!!!!!!
      return(true);
     }
   return(false);
  }


//+------------------------------------------------------------------+
//| Validation settings                                              |
//+------------------------------------------------------------------+
bool CExpertCB::ValidationExitSettings(void)
  {
   if(!CExpertBase::ValidationSettings())
      return(false);
//--- Check signal parameters
   if(!m_exit_signal.ValidationSettings())
     {
      Print(__FUNCTION__+": error signal parameters");
      return(false);
     }
//--- ok
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertCB::InitExitIndicators(CIndicators *indicators)
  {
//--- NULL always comes as the parameter, but here it's not significant for us
   CIndicators *indicators_ptr=GetPointer(m_indicators);
//--- gather information about using of timeseries
//  m_used_series|=exit_signal.UsedSeries();
//--- create required timeseries
   if(!CExpertBase::InitIndicators(indicators_ptr))
      return(false);
   m_exit_signal.SetPriceSeries(m_open,m_high,m_low,m_close);
   m_exit_signal.SetOtherSeries(m_spread,m_time,m_tick_volume,m_real_volume);
   if(!m_exit_signal.InitIndicators(indicators_ptr))
     {
      Print(__FUNCTION__+": error initialization indicators of signal object");
      return(false);
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
   if(m_position.CheckClose(m_signal.VDelay(),m_signal.VTakeLevel(),m_signal.VStopLevel()))   //!changed
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertCB::CheckExitSignal()
  {
   if(m_exit_signal == NULL)
      return(false);
   m_exit_signal.SetExitDirection();
   Print(__FUNCTION__,": ExitDirection=",m_exit_signal.ExitDirection());

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
      if(CheckCloseShort())
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
   double price=EMPTY_VALUE;
//--- check for long close operations
   if(m_exit_signal.CheckExitLong(price))
      return(CloseLong(price));
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for short position close or limit/stop order delete        |
//+------------------------------------------------------------------+
bool CExpertCB::CheckExitShort(void)
  {
   double price=EMPTY_VALUE;
//--- check for short close operations
   if(m_exit_signal.CheckExitShort(price))
      return(CloseShort(price));
//--- return without operations
   return(false);
  }

//+------------------------------------------------------------------+
//| Main function                                                    |
//+------------------------------------------------------------------+
bool CExpertCB::Processing(void)
  {

   if(!allowMultiOrder)
     {
      return CExpert::Processing();
     }
   bool ret=false;
//--- calculate signal direction once
   m_signal.SetDirection();
   Print(__FUNCTION__,": Direction=",m_signal.Direction());
//--- check if open positions
   int total=PositionsTotal();
   if(total!=0)
     {
      for(int i=total-1; i>=0; i--)
        {
         if(m_position.SelectByIndex(i))
           {
            //-- check exit signal
            if(CheckExitSignal())
              {
               ret=true;
              }
            else
              {
               //--- open position is available
               //--- check the possibility of reverse the position
               if(CheckReverse())
                 {
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
                        ret = true;
                       }
                    }
                 }
              }
           }
        }
     }
   total=PositionsTotal();
   if(total!=0)
     {
      m_position.SelectByIndex(total - 1);
      if(m_position.Time() >= iTime(NULL,0,minBarDiff))
        {
         return false;
        }
     }
   if(total >= maxOrders)
      return ret;

//--- check if plased pending orders
   total=OrdersTotal();
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
//--- check the possibility of opening a position/setting pending order
   if(CheckOpen())
      return(true);
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
