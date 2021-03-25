//+------------------------------------------------------------------+
//|                                                     ExpertCB.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#define TREND_UP 9999
#define TREND_DN -9999

#include <Expert\ExpertSignal.mqh>

//+------------------------------------------------------------------+
class CExpertExitSignalCB : public CExpertSignal
  {

   double            m_exit_direction;
   int               m_threshold_exit;// threshold level for closing

   CArrayObj         m_filters;        // array of additional filters (maximum number of fileter is 64)


public:
                     CExpertExitSignalCB(void);
                    ~CExpertExitSignalCB(void);

   double            ExitDirection(void);
   bool              CheckExitLong(double &price);
   bool              CheckExitShort(double &price);
   void              ThresholdExit(int value)  { m_threshold_exit=value;  }

   void              SetExitDirection(void)                             { m_exit_direction=ExitDirection(); }

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CExpertExitSignalCB::CExpertExitSignalCB(void) : m_exit_direction(0),m_threshold_exit(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CExpertExitSignalCB::~CExpertExitSignalCB(void)
  {
  }
//+------------------------------------------------------------------+
//| Detecting the "weighted" direction                               |
//+------------------------------------------------------------------+
double CExpertExitSignalCB::ExitDirection(void)
  {
   long   mask;
   double direction;

   int longCond= LongCondition();
   int shortCond= ShortCondition();
   double result =m_weight*(longCond-shortCond);

//   double result=m_weight*(LongCondition()-ShortCondition());

   int    number=(result==0.0)? 0 : 1;      // number of "voted"
//---
   int    total=m_filters.Total();
//--- loop by filters
   for(int i=0; i<total; i++)
     {
      //--- mask for bit maps
      mask=((long)1)<<i;
      //--- check of the flag of ignoring the signal of filter
      if((m_ignore&mask)!=0)
         continue;
      CExpertSignal *filter=m_filters.At(i);
      //--- check pointer
      if(filter==NULL)
         continue;
      direction=filter.Direction();   // alle Filter in der Kette

      result+=direction;
      //  Print(__FUNCTION__,": number=",number,": result=",result, " direction=",direction," trend_direction=",trend_direction);
      number++;

     }


//--- normalization
   if(number!=0)
      result/=number;

//
   Print(__FUNCTION__,": result=",result);
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Generating a signal for closing of a long position               |
//+------------------------------------------------------------------+
bool CExpertExitSignalCB::CheckExitLong(double &price)
  {
   bool   result   =false;
//--- the "prohibition" signal
   if(m_exit_direction==EMPTY_VALUE)
      return(false);
//--- check of exceeding the threshold value
   if(-m_exit_direction>=m_threshold_exit)
     {
      //--- there's a signal
      result=true;
      //--- try to get the level of closing
      if(!CloseLongParams(price))
         result=false;
     }
//--- zeroize the base price
   m_base_price=0.0;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| Generating a signal for closing a short position                 |
//+------------------------------------------------------------------+
bool CExpertExitSignalCB::CheckExitShort(double &price)
  {
   bool   result   =false;
//--- the "prohibition" signal
   if(m_exit_direction==EMPTY_VALUE)
      return(false);
//--- check of exceeding the threshold value
   if(m_exit_direction>=m_threshold_exit)
     {
      //--- there's a signal
      result=true;
      //--- try to get the level of closing
      if(!CloseShortParams(price))
         result=false;
     }
//--- zeroize the base price
   m_base_price=0.0;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
