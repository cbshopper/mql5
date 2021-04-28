//+------------------------------------------------------------------+
//|                                                     ExpertCB.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>

//#include <Expert\CB\ExpertSignal.mqh>
#include <Expert\CB\PositionCB.mqh>
//#define CExpertSignalCB CExpertSignal
//+------------------------------------------------------------------+
class CExpertCB : public CExpert
  {

protected:
   CPositionInfoCB   m_position;                 // position info object
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
//| Check for position close or limit/stop order delete              |
//+------------------------------------------------------------------+
bool CExpertCB::CheckClose(void)
  {
   double lot;
   lot = m_position.Volume();
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
   if(m_signal != NULL)
     {
      m_signal.SetDirection(true);
      double d = m_signal.Direction();
      //  d=m_signal.Direction();
      // m_signal.setDir(d);
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
  if(m_signal==NULL)
     return false;
   double price=EMPTY_VALUE;
//--- check for long close operations
   if(m_signal.CheckCloseLong(price))
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
    if(m_signal==NULL)
     return false;
   double price=EMPTY_VALUE;
//--- check for short close operations
   if(m_signal.CheckCloseShort(price))
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
  //m_signal.SetDirection();
  // m_signal.Direction(false);
   m_signal.SetDirection(false);
  //   m_signal.SetDirectionX();
 //  Print(__FUNCTION__,": Direction=",m_signal.GetDirection());
//--- check if open positions
   int total=PositionsTotal();
 //  Print(__FUNCTION__,": total Positions=",total);
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
