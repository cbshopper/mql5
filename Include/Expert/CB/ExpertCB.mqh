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

   bool              CheckExitSignal();
   bool              CheckExitLong(void);
   bool              CheckExitShort(void);
   void              GetExitSignal(void);

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
   virtual  void      OnTick(void);
   virtual bool      InitIndicators(CIndicators *indicators=NULL);

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


bool CExpertCB::InitIndicators(CIndicators *indicators)
  {
    
//--- NULL always comes as the parameter, but here it's not significant for us
   CIndicators *indicators_ptr=GetPointer(m_indicators);
//--- gather information about using of timeseries
   m_used_series|=m_signal.UsedSeries();
   m_used_series|=m_trailing.UsedSeries();
   m_used_series|=m_money.UsedSeries();
//--- create required timeseries
   if(!CExpertBase::InitIndicators(indicators_ptr))
      return(false);
   m_signal.SetPriceSeries(m_open,m_high,m_low,m_close);
   m_signal.SetOtherSeries(m_spread,m_time,m_tick_volume,m_real_volume);
   if(!m_signal.InitIndicators(indicators_ptr))
     {
      Print(__FUNCTION__+": error initialization indicators of signal object");
      return(false);
     }
   m_trailing.SetPriceSeries(m_open,m_high,m_low,m_close);
   m_trailing.SetOtherSeries(m_spread,m_time,m_tick_volume,m_real_volume);
   if(!m_trailing.InitIndicators(indicators_ptr))
     {
      Print(__FUNCTION__+": error initialization indicators of trailing object");
      return(false);
     }
   m_money.SetPriceSeries(m_open,m_high,m_low,m_close);
   m_money.SetOtherSeries(m_spread,m_time,m_tick_volume,m_real_volume);
   if(!m_money.InitIndicators(indicators_ptr))
     {
      Print(__FUNCTION__+": error initialization indicators of money object");
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
//|                                                                  |
//+------------------------------------------------------------------+
void CExpertCB::GetExitSignal()
  {
//  return false;
   m_signal.SetExitDirection();
   double d = m_signal.GetExitDirection();
   if(d != 0)
      Print(__FUNCTION__,": ExitDirection=",d);

 
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
   if(m_signal.CheckExitLong(price))
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
   double price=EMPTY_VALUE;
//--- check for short close operations
   if(m_signal.CheckExitShort(price))
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
   Print(__FUNCTION__,": Direction=",m_signal.GetDirection());
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
   if(total >= maxOrders)
      return ret;

   if(total!=0)
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
