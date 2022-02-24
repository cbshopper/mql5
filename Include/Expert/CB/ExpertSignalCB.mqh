//+------------------------------------------------------------------+
//|                                                     ExpertCB.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#define SELL_FORBIDDEN 9999
#define BUY_FORBIDDEN -9999
#define TRADE_FORBIDDEN -11111111
#define IGNORE_ME -88888888

#include <Expert\ExpertSignal.mqh>

//+------------------------------------------------------------------+
class CExpertSignalCB : public CExpertSignal
  {

protected:
   CExpertSignalCB * m_signalCB;
   void              setSignal(CExpertSignal *sig) { m_signalCB = (CExpertSignalCB*) GetPointer(sig); }
   
public:
                     CExpertSignalCB(void);
                    ~CExpertSignalCB(void);

   virtual double    Direction(void) override;
   double            GetDirection(void)         {return m_direction;}

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CExpertSignalCB::CExpertSignalCB(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CExpertSignalCB::~CExpertSignalCB(void)
  {
  }

//+------------------------------------------------------------------+
//| Detecting the "weighted" direction                               |
//+------------------------------------------------------------------+
double CExpertSignalCB::Direction(void)
  {


   long   mask;
   double direction;
   bool buy_forbidden=false;  // CB
   bool sell_forbidden=false;  // CB

   int longCond= LongCondition();
   int shortCond= ShortCondition();
   double result = 0;
   result = m_weight*(longCond-shortCond);

   int    number=(result==0.0)? 0 : 1;      // number of "voted"
//---
   int    total= 0;
   total= m_filters.Total();

// Print(__FUNCTION__,": number=",number,": result=",result, " total=",total, " m_weight=",m_weight," longCond=",longCond, " shortCond=",shortCond);

//--- loop by filters
   for(int i=0; i<total; i++)
     {
      //--- mask for bit maps
      mask=((long)1)<<i;
      //--- check of the flag of ignoring the signal of filter
      if((m_ignore&mask)!=0)
         continue;

      CExpertSignal *filter=NULL;
      filter=m_filters.At(i);

      //--- check pointer
      //  Print(__FUNCTION__,": filter=",filter);
      if(filter==NULL)
         continue;
    //  setSignal(filter);
   //   void *obj = GetPointer(filter);
   //   CExpertSignalCB * m_signalCB;

     // m_signalCB = (CExpertSignalCB*) GetPointer(obj);
      
      direction=filter.Direction();   // alle Filter in der Kette
      Print(__FUNCTION__,": LOOP: i=",i," of ", total," number=",number,": result=",result, " direction=",direction," filter=",filter);

      //--- the "prohibition" signal
      if(direction==EMPTY_VALUE)
         return(EMPTY_VALUE);

      //--- CB SignalTrend
      if(direction==SELL_FORBIDDEN)
        {
         sell_forbidden=true;
         direction=0;
         number--;
        }
      if(direction==BUY_FORBIDDEN)
        {
         buy_forbidden=true;
         direction=0;
         number--;
        }
      if(direction==TRADE_FORBIDDEN)
        {
         buy_forbidden=true;
         sell_forbidden=true;
         direction=0;
         number--;
        }
      if(direction==IGNORE_ME)
        {
         direction=0;
         number--;
        }
      if(direction != 0.0)
        {
         //--- check of flag of inverting the signal of filter
         if((m_invert&mask)!=0)
            result-=direction;
         else
            result+=direction;

        }
      //   Print(__FUNCTION__,": number=",number,": result=",result, " direction=",direction," trend_direction=",trend_direction);
      number++;

     }

//--- normalization
   if(number!=0)
      result/=number;

//  Print(__FUNCTION__,": result=",result," trend_direction=",trend_direction);
   if(result > 0 && buy_forbidden)
      result=EMPTY_VALUE;
   if(result < 0 && sell_forbidden)
      result=EMPTY_VALUE;
//
   Print(__FUNCTION__,": result=",result," buy_forbidden=",buy_forbidden," sell_forbidden=",sell_forbidden, " number=", number);
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
