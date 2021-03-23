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
class CExpertSignalCB : public CExpertSignal
  {

protected:
   int               v_stoploss;
   int               v_takeprofit;
   bool               v_use;
   int           v_delay;
 
public:
                     CExpertSignalCB(void);
                    ~CExpertSignalCB(void);
   int               VStopLevel(void) {return v_stoploss;}
   int               VTakeLevel(void) {return v_takeprofit;}
   bool              VUse(void) {return v_use;}
   int              VDelay(void) {return v_delay;}

   void              VStopLevel(int value) { v_stoploss = value; }
   void              VTakeLevel(int value) { v_takeprofit = value; }
   void              VUse(int value) { v_use = value; if(v_use) {TakeLevel(0); StopLevel(0);}}
   void               VDelay(int value) {v_delay=value*60;}

   virtual double    Direction(void);
   virtual void              SetDirection(void)                             { m_direction=Direction(); }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CExpertSignalCB::CExpertSignalCB(void) : v_stoploss(0),v_takeprofit(0),v_use(false),v_delay(0)
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
   int trend_direction=0;

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
      //--- the "prohibition" signal
      if(direction==EMPTY_VALUE)
         return(EMPTY_VALUE);
      
      //--- CB SignalTrend 
      if (direction==TREND_UP)
      {
        trend_direction=1;
        direction=0;
        number--;
      }
      if (direction==TREND_DN)
      {
        trend_direction=-1;
        direction=0;
        number--;
      }   
      
      //--- check of flag of inverting the signal of filter
      if((m_invert&mask)!=0)
         result-=direction;
      else
         result+=direction;
    //  Print(__FUNCTION__,": number=",number,": result=",result, " direction=",direction," trend_direction=",trend_direction);    
      number++;
     
     }


//--- normalization
   if(number!=0)
      result/=number;

 //  Print(__FUNCTION__,": result=",result," trend_direction=",trend_direction);   
   if(result > 0 && trend_direction<0)
      result=EMPTY_VALUE;
   if(result < 0 && trend_direction>0)
      result=EMPTY_VALUE;
//      
   Print(__FUNCTION__,": result=",result," trend_direction=",trend_direction);   
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+