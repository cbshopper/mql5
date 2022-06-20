//+------------------------------------------------------------------+
//|                                                         Z3MA.mq5 |
//|                                  Copyright 2020, Hassane Zibara. |
//|                             https://www.mql5.com/en/users/377812 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Hassane Zibara."
#property link      "https://www.mql5.com/en/users/377812"
#property version   "1.00"
#property indicator_chart_window
//--- indicator settings
#property indicator_buffers 5
#property indicator_plots 5

#property indicator_type1 DRAW_ARROW
#property indicator_width1 1
#property indicator_color1 0xFFAA00
#property indicator_label1 "Buy"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 1
#property indicator_color2 0x0000FF
#property indicator_label2 "Sell"

#property indicator_type3 DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_color3 0x00EEFF
#property indicator_label3 "long term"

#property indicator_type4 DRAW_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_color4 0xFFAA00
#property indicator_label4 "fast"

#property indicator_type5 DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_color5 0x0000FF
#property indicator_label5 "slow"

//--- indicator buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];

input string MA1_="Gold";
input int Period1 = 55;
input ENUM_MA_METHOD                   MAMethod1       =  MODE_EMA;     // MA1 method
input ENUM_APPLIED_PRICE               MAPrice1        =  PRICE_CLOSE;     // MA1 price
input string MA2_="blue";
input int Period2 = 9;
input ENUM_MA_METHOD                   MAMethod2       =  MODE_EMA;     // MA2 method
input ENUM_APPLIED_PRICE               MAPrice2        =  PRICE_CLOSE;     // MA2 price
input string MA3_="Red";
input int Period3 = 21;
input ENUM_MA_METHOD                   MAMethod3       =  MODE_EMA;     // MA3 method
input ENUM_APPLIED_PRICE               MAPrice3        =  PRICE_CLOSE;     // MA3 price
datetime time_alert; //used when sending alert
bool Audible_Alerts = true;
double myPoint; //initialized in OnInit
int MA_handle;
double MA[];
int MA_handle2;
double MA2[];
int MA_handle3;
double MA3[];
double Low[];
double High[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else
      if(type == "error")
        {
         Print(type+" | Z3MA @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
        }

      else
         if(type == "indicator")
           {
            Print(type+" | Z3MA @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
            if(Audible_Alerts)
               Alert(type+" | Z3MA @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
           }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, Buffer1);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_ARROW, 241);
   SetIndexBuffer(1, Buffer2);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(1, PLOT_ARROW, 242);
   SetIndexBuffer(2, Buffer3);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   SetIndexBuffer(3, Buffer4);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   SetIndexBuffer(4, Buffer5);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);
//initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   MA_handle = iMA(NULL, PERIOD_CURRENT, Period2, 0, MAMethod2, MAPrice2);
   if(MA_handle < 0)
     {
      Print("The creation of iMA has failed: MA_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }

   MA_handle2 = iMA(NULL, PERIOD_CURRENT, Period3, 0, MAMethod3, MAPrice3);
   if(MA_handle2 < 0)
     {
      Print("The creation of iMA has failed: MA_handle2=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }

   MA_handle3 = iMA(NULL, PERIOD_CURRENT, Period1, 0, MAMethod1, MAPrice1);
   if(MA_handle3 < 0)
     {
      Print("The creation of iMA has failed: MA_handle3=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int limit = rates_total - prev_calculated;
//--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   ArraySetAsSeries(Buffer3, true);
   ArraySetAsSeries(Buffer4, true);
   ArraySetAsSeries(Buffer5, true);
//--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
      ArrayInitialize(Buffer3, EMPTY_VALUE);
      ArrayInitialize(Buffer4, EMPTY_VALUE);
      ArrayInitialize(Buffer5, EMPTY_VALUE);
     }
   else
      limit++;
   datetime Time[];

   if(BarsCalculated(MA_handle) <= 0)
      return(0);
   if(CopyBuffer(MA_handle, 0, 0, rates_total, MA) <= 0)
      return(rates_total);
   ArraySetAsSeries(MA, true);
   if(BarsCalculated(MA_handle2) <= 0)
      return(0);
   if(CopyBuffer(MA_handle2, 0, 0, rates_total, MA2) <= 0)
      return(rates_total);
   ArraySetAsSeries(MA2, true);
   if(BarsCalculated(MA_handle3) <= 0)
      return(0);
   if(CopyBuffer(MA_handle3, 0, 0, rates_total, MA3) <= 0)
      return(rates_total);
   ArraySetAsSeries(MA3, true);
   if(CopyLow(Symbol(), PERIOD_CURRENT, 0, rates_total, Low) <= 0)
      return(rates_total);
   ArraySetAsSeries(Low, true);
   if(CopyHigh(Symbol(), PERIOD_CURRENT, 0, rates_total, High) <= 0)
      return(rates_total);
   ArraySetAsSeries(High, true);
   if(CopyTime(Symbol(), Period(), 0, rates_total, Time) <= 0)
      return(rates_total);
   ArraySetAsSeries(Time, true);
//--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if(i >= MathMin(5000-1, rates_total-1-50))
         continue; //for some old rates to prevent "Array out of range" or slow calculation

      //Indicator Buffer 1
      if(MA[i] > MA2[i]
         && MA[i+1] < MA2[i+1] //Moving Average crosses above Moving Average
         && MA3[i] < MA[i] //Moving Average < Moving Average
         && MA3[i] < MA2[i] //Moving Average < Moving Average
        )
        {
         Buffer1[i] = Low[1+i]; //Set indicator value at Candlestick Low
         if(i == 1 && Time[1] != time_alert)
            myAlert("indicator", "Buy"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(MA[i] < MA2[i]
         && MA[i+1] > MA2[i+1] //Moving Average crosses below Moving Average
         && MA3[i] > MA[i] //Moving Average > Moving Average
         && MA3[i] > MA2[i] //Moving Average > Moving Average
        )
        {
         Buffer2[i] = High[1+i]; //Set indicator value at Candlestick High
         if(i == 1 && Time[1] != time_alert)
            myAlert("indicator", "Sell"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer2[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 3
      if(true)//you can put your condition here
        {
         Buffer3[i] = MA3[i]; //Set indicator value at Moving Average
         if(i == 1 && Time[1] != time_alert)
            time_alert = Time[1];
        }
      else
        {
         Buffer3[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 4
      if(true)//you can put your condition here
        {
         Buffer4[i] = MA[i]; //Set indicator value at Moving Average
         if(i == 1 && Time[1] != time_alert)
            time_alert = Time[1];
        }
      else
        {
         Buffer4[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 5
      if(true)//you can put your condition here
        {
         Buffer5[i] = MA2[i]; //Set indicator value at Moving Average
         if(i == 1 && Time[1] != time_alert)
            time_alert = Time[1];
        }
      else
        {
         Buffer5[i] = EMPTY_VALUE;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
