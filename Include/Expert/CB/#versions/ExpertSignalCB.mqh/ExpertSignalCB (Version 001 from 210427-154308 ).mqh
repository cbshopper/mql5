//+------------------------------------------------------------------+
//|                                                     ExpertCB.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#define SELL_FORBIDDEN 9999
#define BUY_FORBIDDEN -9999

#include <Expert\ExpertSignal.mqh>

//+------------------------------------------------------------------+
class CExpertSignalCB : public CExpertSignal
  {

protected:
public:
                     CExpertSignalCB(void);
                    ~CExpertSignalCB(void);
   void              IsExitSignal(bool value)   {m_exitsignal = value;}
   double            Direction(bool OnlyExit);
   void              SetDirection(bool OnlyExit)         { m_direction=Direction(OnlyExit); }
   double            GetDirection(void)         {return m_direction;}
 
   //--- methods for working with additional filters
   virtual bool      AddFilter(CExpertSignalCB *filter, int asExitSignal);
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

/*
//+------------------------------------------------------------------+
//| Setting an additional filter                                     |
//+------------------------------------------------------------------+
bool CExpertSignalCB::AddFilter(CExpertSignalCB *filter, int asExitSignal)
  {

   filter.SetExit(asExitSignal);
   bool ret = CExpertSignal::AddFilter(filter);
   return(ret);
  }
*/

//+------------------------------------------------------------------+
//| Detecting the "weighted" direction                               |
//+------------------------------------------------------------------+
double CExpertSignal::Direction(bool OnlyExit)
  {
   long   mask;
   double direction;
   bool buy_forbidden=false;  // CB
   bool sell_forbidden=true;  // CB

   int longCond= LongCondition();
   int shortCond= ShortCondition();
   double result = 0;
   result = m_weight*(longCond-shortCond);
//   double result=m_weight*(LongCondition()-ShortCondition());

//--- CB Exit Signal
   if(OnlyExit && !m_exitsignal)
      result =0;


   int    number=(result==0.0)? 0 : 1;      // number of "voted"
//---
   int    total= 0;
   total= m_filters.Total();

   Print(__FUNCTION__,": number=",number,": result=",result, " total=",total);

//--- loop by filters
   for(int i=0; i<total; i++)
     {
      //--- mask for bit maps
      mask=((long)1)<<i;
      //--- check of the flag of ignoring the signal of filter
      if((m_ignore&mask)!=0)
         continue;

      //--- CB Exit Signal
      if(OnlyExit && !m_exitsignal)
         continue;
      //--- CB Exit Signal
      if(!OnlyExit && m_exitsignal)
         continue;

      CExpertSignal *filter=NULL;
      filter=m_filters.At(i);

      //--- check pointer
      Print(__FUNCTION__,": filter=",filter);
      if(filter==NULL)
         continue;

      // if(IsExitSignal(filter))
      //    continue;

      direction=filter.Direction();   // alle Filter in der Kette

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
   Print(__FUNCTION__,": result=",result," buy_forbidden=",buy_forbidden," sell_forbidden=",sell_forbidden);
//--- return the result
   return(result);
  }

//+------------------------------------------------------------------+
