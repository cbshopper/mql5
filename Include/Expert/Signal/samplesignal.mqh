//+------------------------------------------------------------------+
//|                                                 SampleSignal.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| include files                                                    |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signal on crossing of the price and the MA                 |
//| entering on the back movement                                    |
//| Type=Signal                                                      |
//| Name=Sample                                                      |
//| Class=CSampleSignal                                              |
//| Page=                                                            |
//| Parameter=PeriodMA,int,12                                        |
//| Parameter=ShiftMA,int,0                                          |
//| Parameter=MethodMA,ENUM_MA_METHOD,MODE_EMA                       |
//| Parameter=AppliedMA,ENUM_APPLIED_PRICE,PRICE_CLOSE               |
//| Parameter=Limit,double,0.0                                       |
//| Parameter=StopLoss,double,50.0                                   |
//| Parameter=TakeProfit,double,50.0                                 |
//| Parameter=Expiration,int,10                                      |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| CSampleSignal.                                                   |
//| Purpose: Class of trading signal generator when price            |
//|             crosses moving average,                              |
//|             entering on the subsequent back movement.            |
//|             It is derived from the CExpertSignal class.          |
//+------------------------------------------------------------------+
class CSampleSignal : public CExpertSignal
  {
protected:
   CiMA               m_MA;               // object to access the values of the moving average
   CiOpen             m_open;             // object to access the bar open prices
   CiClose            m_close;            // object to access the bar close prices
   //--- Setup parameters
   int                m_period_ma;        // averaging period of the MA
   int                m_shift_ma;         // shift of the MA along the time axis
   ENUM_MA_METHOD     m_method_ma;        // averaging method of the MA
   ENUM_APPLIED_PRICE m_applied_ma;       // averaging object of the MA
   double             m_limit;            // level to place a pending order relative to the MA
   double             m_stop_loss;        // level to place a stop loss order relative to the open price
   double             m_take_profit;      // level to place a take profit order relative to the open price
   int                m_expiration;       // lifetime of a pending order in bars

public:
                      CSampleSignal();
   //--- Methods to set the parameters
   void               PeriodMA(int value)                 { m_period_ma=value;              }
   void               ShiftMA(int value)                  { m_shift_ma=value;               }
   void               MethodMA(ENUM_MA_METHOD value)      { m_method_ma=value;              }
   void               AppliedMA(ENUM_APPLIED_PRICE value) { m_applied_ma=value;             }
   void               Limit(double value)                 { m_limit=value;                  }
   void               StopLoss(double value)              { m_stop_loss=value;              }
   void               TakeProfit(double value)            { m_take_profit=value;            }
   void               Expiration(int value)               { m_expiration=value;             }
   //---Method to validate the parameters
   virtual bool       ValidationSettings();
   //--- Method to validate the parameters
   virtual bool       InitIndicators(CIndicators* indicators);
   //--- Methods to generate signals to enter the market
   virtual bool      CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration);
   virtual bool      CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration);
   //--- Methods to generate signals of pending order modification
   virtual bool      CheckTrailingOrderLong(COrderInfo* order,double& price);
   virtual bool      CheckTrailingOrderShort(COrderInfo* order,double& price);

protected:
   //--- Object initialization method
   bool               InitMA(CIndicators* indicators);
   bool               InitOpen(CIndicators* indicators);
   bool               InitClose(CIndicators* indicators);
   //--- Methods to access object data
   double             MA(int index)                       { return(m_MA.Main(index));       }
   double             Open(int index)                     { return(m_open.GetData(index));  }
   double             Close(int index)                    { return(m_close.GetData(index)); }
  };
//+------------------------------------------------------------------+
//| CSampleSignal Constructor.                                       |
//| INPUT:  No.                                                      |
//| OUTPUT: No.                                                      |
//| REMARK: No.                                                      |
//+------------------------------------------------------------------+
void CSampleSignal::CSampleSignal()
  {
//--- Setting the default values
   m_period_ma  =12;
   m_shift_ma   =0;
   m_method_ma  =MODE_EMA;
   m_applied_ma =PRICE_CLOSE;
   m_limit      =0.0;
   m_stop_loss  =50.0;
   m_take_profit=50.0;
   m_expiration =10;
  }
//+------------------------------------------------------------------+
//| Validation of parameters.                                        |
//| INPUT:  No.                                                      |
//| OUTPUT: true if the settings are correct, otherwise false.       |
//| REMARK: No.                                                      |
//+------------------------------------------------------------------+
bool CSampleSignal::ValidationSettings()
  {
//--- Validation of parameters
   if(m_period_ma<=0)
     {
      printf(__FUNCTION__+": the MA period must be greater than zero");
      return(false);
     }
//--- Successful completion
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of indicators and timeseries.                     |
//| INPUT:  indicators - pointer to the object - collection of       |
//|                      indicators and timeseries.                  |
//| OUTPUT: true in case of success, otherwise false.                |
//| REMARK: No.                                                      |
//+------------------------------------------------------------------+
bool CSampleSignal::InitIndicators(CIndicators* indicators)
  {
//--- Validation of the pointer
   if(indicators==NULL)       return(false);
//--- Initialization of the moving average
   if(!InitMA(indicators))    return(false);
//--- Initialization of the timeseries of open prices
   if(!InitOpen(indicators))  return(false);
//--- Initialization of the timeseries of close prices
   if(!InitClose(indicators)) return(false);
//--- Successful completion
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of the moving average                             |
//| INPUT:  indicators - pointer to the object - collection of       |
//|                      indicators and timeseries.                  |
//| OUTPUT: true in case of success, otherwise false.                |
//| REMARK: No.                                                      |
//+------------------------------------------------------------------+
bool CSampleSignal::InitMA(CIndicators* indicators)
  {
//--- Initialization of the MA object
   if(!m_MA.Create(m_symbol.Name(),m_period,m_period_ma,m_shift_ma,m_method_ma,m_applied_ma))
     {
      printf(__FUNCTION__+": object initialization error");
      return(false);
     }
   m_MA.BufferResize(3+m_shift_ma);
//--- Adding an object to the collection
   if(!indicators.Add(GetPointer(m_MA)))
     {
      printf(__FUNCTION__+": object adding error");
      return(false);
     }
//--- Successful completion
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of the timeseries of open prices.                 |
//| INPUT:  indicators - pointer to the object - collection of       |
//|                      indicators and timeseries.                  |
//| OUTPUT: true in case of success, otherwise false.                |
//| REMARK: No.                                                      |
//+------------------------------------------------------------------+
bool CSampleSignal::InitOpen(CIndicators* indicators)
  {
//--- Initialization of the timeseries object
   if(!m_open.Create(m_symbol.Name(),m_period))
     {
      printf(__FUNCTION__+": object initialization error");
      return(false);
     }
//--- Adding an object to the collection
   if(!indicators.Add(GetPointer(m_open)))
     {
      printf(__FUNCTION__+": object adding error");
      return(false);
     }
//--- Successful completion
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of the timeseries of close prices.                |
//| INPUT:  indicators - pointer to the object - collection of       |
//|                      indicators and timeseries.                  |
//| OUTPUT: true in case of success, otherwise false.                |
//| REMARK: No.                                                      |
//+------------------------------------------------------------------+
bool CSampleSignal::InitClose(CIndicators* indicators)
  {
//--- Initialization of the timeseries object
   if(!m_close.Create(m_symbol.Name(),m_period))
     {
      printf(__FUNCTION__+": object initialization error");
      return(false);
     }
//--- Adding an object to the collection
   if(!indicators.Add(GetPointer(m_close)))
     {
      printf(__FUNCTION__+": object adding error");
      return(false);
     }
//--- Successful completion
   return(true);
  }
//+------------------------------------------------------------------+
//| Check whether a Buy condition is fulfilled                       |
//| INPUT:  price      - variable for open price                     |
//|         sl         - variable for stop loss price,               |
//|         tp         - variable for take profit price              |
//|         expiration - variable for expiration time.               |
//| OUTPUT: true if the condition is fulfilled, otherwise false.     |
//| REMARK: No.                                                      |
//+------------------------------------------------------------------+
bool CSampleSignal::CheckOpenLong(double& price,double& sl,double& tp,datetime& expiration)
  {
//--- Preparing the data
   double spread=m_symbol.Ask()-m_symbol.Bid();
   double ma    =MA(1);
   double unit  =PriceLevelUnit();
//--- Checking the condition
   if(Open(1)<ma && Close(1)>ma && ma>MA(2))
     {
      price=m_symbol.NormalizePrice(ma-m_limit*unit+spread);
      sl   =m_symbol.NormalizePrice(price-m_stop_loss*unit);
      tp   =m_symbol.NormalizePrice(price+m_take_profit*unit);
      expiration+=m_expiration*PeriodSeconds(m_period);
      //--- Condition is fulfilled
      return(true);
     }
//--- Condition is not fulfilled
   return(false);
  }
//+------------------------------------------------------------------+
//| Check whether a Sell condition is fulfilled.                     |
//| INPUT:  price      - variable for open price,                    |
//|         sl         - variable for stop loss,                     |
//|         tp         - variable for take profit                    |
//|         expiration - variable for expiration time.               |
//| OUTPUT: true if the condition is fulfilled, otherwise false.     |
//| REMARK: No.                                                      |
//+------------------------------------------------------------------+
bool CSampleSignal::CheckOpenShort(double& price,double& sl,double& tp,datetime& expiration)
  {
//--- Preparing the data
   double ma  =MA(1);
   double unit=PriceLevelUnit();
//--- Checking the condition
   if(Open(1)>ma && Close(1)<ma && ma<MA(2))
     {
      price=m_symbol.NormalizePrice(ma+m_limit*unit);
      sl   =m_symbol.NormalizePrice(price+m_stop_loss*unit);
      tp   =m_symbol.NormalizePrice(price-m_take_profit*unit);
      expiration+=m_expiration*PeriodSeconds(m_period);
      //--- Condition is fulfilled
      return(true);
     }
//--- Condition is not fulfilled
   return(false);
  }
//+------------------------------------------------------------------+
//| Check whether the condition of modification                      |
//|  of a Buy order is fulfilled.                                    |
//| INPUT:  order - pointer at the object-order,                     |
//|         price - a variable for the new open price.               |
//| OUTPUT: true if the condition is fulfilled, otherwise false.     |
//| REMARK: No.                                                      |
//+------------------------------------------------------------------+
bool CSampleSignal::CheckTrailingOrderLong(COrderInfo* order,double& price)
  {
//--- Checking the pointer
   if(order==NULL) return(false);
//--- Preparing the data
   double spread   =m_symbol.Ask()-m_symbol.Bid();
   double ma       =MA(1);
   double unit     =PriceLevelUnit();
   double new_price=m_symbol.NormalizePrice(ma-m_limit*unit+spread);
//--- Checking the condition
   if(order.PriceOpen()==new_price) return(false);
   price=new_price;
//--- Condition is fulfilled
   return(true);
  }
//+------------------------------------------------------------------+
//| Check whether the condition of modification                      |
//| of a Sell order is fulfilled.                                    |
//| INPUT:  order - pointer at the object-order,                     |
//|         price - a variable for the new open price.               |
//| OUTPUT: true if the condition is fulfilled, otherwise false.     |
//| REMARK: No.                                                      |
//+------------------------------------------------------------------+
bool CSampleSignal::CheckTrailingOrderShort(COrderInfo* order,double& price)
  {
//--- Checking the pointer
   if(order==NULL) return(false);
//--- Preparing the data
   double ma  =MA(1);
   double unit=PriceLevelUnit();
   double new_price=m_symbol.NormalizePrice(ma+m_limit*unit);
//--- Checking the condition
   if(order.PriceOpen()==new_price) return(false);
   price=new_price;
//--- Condition is fulfilled
   return(true);
  }
//+------------------------------------------------------------------+