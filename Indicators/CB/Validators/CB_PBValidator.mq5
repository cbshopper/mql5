//+------------------------------------------------------------------+
//|                                                    Validator.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 10
#property indicator_plots   9

//--- plot OpenBUY
#property indicator_label1  "OpenBuy"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  5
//--- plot SELL
#property indicator_label2  "OpenSell"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  5

//--- plot BUY
#property indicator_label3  "CLoseBuy"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot SELL
#property indicator_label4  "CloseSell"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
/*
//--- plot RSI
#property indicator_label5  "RSI"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_DASHDOT
#property indicator_width5  2

//--- plot SLOWMA
#property indicator_label6  "SLOWMA"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrBlue
#property indicator_style6  STYLE_DASHDOT
#property indicator_width6  2
*/
input int                 bb_period = 20;
input int                 bb_shift = 0;
input double              bb_deviation = 1.5;
input int                 ma_period = 20;
input ENUM_TIMEFRAMES     ma_timeframe = PERIOD_D1;
input int                 rsi_period = 14;
input int                 rsi_buylevel = 30;
input int                 rsi_selllevel = 70;
input int                 MinBarPts = 20;
input int                 PBRange = 20;
input bool                UseOC = false;
input double              PBLevel = 3.0;
input int                 OrderBarCount = 4;

int indicator_ptr = 0;
int bb_ptr = 0;
int ma_ptr = 0;
int rsi_ptr = 0;

#include <CB/CB_Drawing.mqh>
#include <CB/CB_Validator.mqh>

double         PBValues[];
double         BBUpperValues[];
double         BBMidleValues[];
double         BBLowerValues[];
double         RSIValues[];
double         MaValues[];                  // dynamic array for numerical values of Moving Average

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
 {
//--- indicator buffers mapping
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  int first = InitSignalBuffers();
//** BUFFERS for used Indictor(s)
//--- indicator buffers mapping
  SetIndexBuffer(first + 0, PBValues, INDICATOR_CALCULATIONS);
  first++;
  SetIndexBuffer(first + 0, BBUpperValues, INDICATOR_DATA);
  PlotIndexSetString(first, PLOT_LABEL, "Upper");
  PlotIndexSetInteger(first, PLOT_DRAW_TYPE, DRAW_LINE);
  PlotIndexSetInteger(first, PLOT_LINE_COLOR, clrBlack);
  PlotIndexSetInteger(first, PLOT_LINE_STYLE, STYLE_SOLID);
  first++;
  SetIndexBuffer(first + 0, BBMidleValues, INDICATOR_DATA);
  PlotIndexSetString(first, PLOT_LABEL, "Middle");
  PlotIndexSetInteger(first, PLOT_DRAW_TYPE, DRAW_LINE);
  PlotIndexSetInteger(first, PLOT_LINE_COLOR, clrBlack);
  PlotIndexSetInteger(first, PLOT_LINE_STYLE, STYLE_SOLID);
  first++;
  SetIndexBuffer(first + 0, BBLowerValues, INDICATOR_DATA);
  PlotIndexSetString(first, PLOT_LABEL, "Lower");
  PlotIndexSetInteger(first, PLOT_DRAW_TYPE, DRAW_LINE);
  PlotIndexSetInteger(first, PLOT_LINE_COLOR, clrBlack);
  PlotIndexSetInteger(first, PLOT_LINE_STYLE, STYLE_SOLID);
  first++;
  SetIndexBuffer(first + 0, MaValues, INDICATOR_DATA);
  PlotIndexSetString(first, PLOT_LABEL, "DEMA");
  PlotIndexSetInteger(first, PLOT_DRAW_TYPE, DRAW_LINE);
  PlotIndexSetInteger(first, PLOT_LINE_COLOR, clrRed);
  PlotIndexSetInteger(first, PLOT_LINE_STYLE, STYLE_SOLID);
  first++;
  SetIndexBuffer(first + 0, RSIValues, INDICATOR_CALCULATIONS);
//
//--- setting the arrays in timeseries
  ArraySetAsSeries(PBValues, true);
  ArraySetAsSeries(BBUpperValues, true);
  ArraySetAsSeries(BBMidleValues, true);
  ArraySetAsSeries(BBLowerValues, true);
  ArraySetAsSeries(MaValues, true);
  ArraySetAsSeries(RSIValues, true);
//---
  indicator_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/new/PowerBar", PBRange, UseOC);
  bb_ptr = iBands(NULL, PERIOD_CURRENT, bb_period, bb_shift, bb_deviation, PRICE_CLOSE);
  ma_ptr = iDEMA(NULL, ma_timeframe, ma_period, bb_shift, PRICE_CLOSE);
  rsi_ptr = iRSI(NULL, PERIOD_CURRENT, rsi_period, PRICE_CLOSE);
//     StartOffset=0;   // wg. Signal an richtiger Position
  return(INIT_SUCCEEDED);
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  OnDeinit(
  const int  reason         // deinitialization reason code
)
 {
  DeleteTLines();
 }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
 {
//---
  ArraySetAsSeries(open, true);
  ArraySetAsSeries(close, true);
  ArraySetAsSeries(high, true);
  ArraySetAsSeries(low, true);
  int calculated = BarsCalculated(indicator_ptr);
  if(calculated < rates_total)
   {
    return(0);
   }
  /*
  calculated = BarsCalculated(ma2_ptr);
  if(calculated < rates_total)
  {
   return(0);
  }
  */
  int to_copy;
  if(prev_calculated > rates_total || prev_calculated < 0)
    to_copy = rates_total;
  else
   {
    to_copy = rates_total - prev_calculated;
    if(prev_calculated > 0)
      to_copy++;
   }
//   to_copy = rates_total;
//    to_copy=1000;
// Print(__FILE__, __FUNCTION__," rates_total=",rates_total," prev_calculated=",prev_calculated," to_copy=", to_copy, " calculated=",calculated );
//if(IsStopped())
//   return(0); //Checking for stop flag
  if(CopyBuffer(indicator_ptr, 0, 0, to_copy, PBValues) <= 0)
   {
    Print("Getting data_ptr(0) is failed! Error", GetLastError());
    return(0);
   }
  if(CopyBuffer(bb_ptr, 0, 0, to_copy, BBMidleValues) <= 0)
   {
    Print("Getting data_ptr(1) is failed! Error", GetLastError());
    return(0);
   }
  if(CopyBuffer(bb_ptr, 1, 0, to_copy, BBUpperValues) <= 0)
   {
    Print("Getting data_ptr(1) is failed! Error", GetLastError());
    return(0);
   }
  if(CopyBuffer(bb_ptr, 2, 0, to_copy, BBLowerValues) <= 0)
   {
    Print("Getting data_ptr(1) is failed! Error", GetLastError());
    return(0);
   }
  if(CopyBuffer(ma_ptr, 0, 0, to_copy, MaValues) <= 0)
   {
    Print("Getting data_ptr(1) is failed! Error", GetLastError());
    return(0);
   }
  if(CopyBuffer(rsi_ptr, 0, 0, to_copy, RSIValues) <= 0)
   {
    Print("Getting data_ptr(1) is failed! Error", GetLastError());
    return(0);
   }
  int limit = calculated - 2 ;
  for(int shift = limit - 2; shift > 0; shift--)
   {
    BuySignalOpenBuffer[shift] = EMPTY_VALUE;
    SellSignalOpenBuffer[shift] = EMPTY_VALUE;
    BuySignalCloseBuffer[shift] = EMPTY_VALUE;
    SellSignalCloseBuffer[shift] = EMPTY_VALUE;
    //   int index = shift;
    bool tendenceUp = BBMidleValues[shift] > BBMidleValues[shift + 1] > BBMidleValues[shift + 1];
    bool tendenceDn  = BBMidleValues[shift] < BBMidleValues[shift + 1] < BBMidleValues[shift + 1];
    double diffHiLo = BBUpperValues[shift] - BBLowerValues[shift];
    double diffHiLo1 = BBUpperValues[shift] - BBLowerValues[shift + 2];  // !!! limit-2
    bool expanding = diffHiLo1 < diffHiLo;
    double diffHiMi = BBLowerValues[shift] - BBMidleValues[shift];
    double diffMiLo = BBMidleValues[shift] - BBLowerValues[shift];
    int diffHiLoPts = diffHiLo / Point();
    int diffHiMiPts = diffHiMi / Point();
    int diffMiLoPts = diffHiLo / Point();
    double val = PBValues[shift];
    double close_value = iClose(Symbol(), PERIOD_CURRENT, shift); // close[shift];
    double open_value = iOpen(Symbol(), PERIOD_CURRENT, shift); //open[shift];
    double barlengh = MathAbs(open_value - close_value);
    int divx = 1;
    double overlap1 = 0.25;
    double signal_value = close_value < open_value ? low[shift] - 20 * Point() : high[shift] + 20 * Point();
    double val2 = MathAbs(open_value - close_value);
    double Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);  // Ask price
    double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);  // Bid price
    //--- Declare bool type variables to hold our Buy and Sell Conditions
    
    double rsi_value = RSIValues[shift];
    double MA_value = MaValues[shift];
    //--- Declare bool type variables to hold our Buy and Sell Conditions
   bool Buy_Condition =(close[shift] <BBLowerValues[shift] &&   //closing candle under lowest BB
                        rsi_value<rsi_buylevel &&          // rsi value lower than oversold limit
                         close[shift]>MA_value);     // closing candle above MA    

   bool Sell_Condition = (close[shift] > BBUpperValues[shift] &&  //closing candle above Highest BB
                          rsi_value>rsi_selllevel &&          // rsi value higher than overbought limit
                          close[shift]<MA_value);    // closing candle under MA    
                          
    
    /******
    bool Buy_Condition = (close[shift] > BBLowerValues[shift] && open[shift] < BBLowerValues[shift]);   // White (bull) candle crossed the Lower Band from below to above
    Buy_Condition = Buy_Condition && MaValues[shift] > MaValues[shift + 1]; // and DEMA is growing up
    // Buy_Condition = Buy_Condition && MaValues[shift + 1] > MaValues[shift + 2];
    Buy_Condition = Buy_Condition && barlengh > MinBarPts * Point();
    //
    bool Sell_Condition = (close[shift] < BBUpperValues[shift] && open[shift] > BBUpperValues[shift]) ;  // Black (bear) candle crossed the Upper Band from above to below
    Sell_Condition = Sell_Condition  &&   MaValues[shift] < MaValues[shift + 1];
    // Sell_Condition = Sell_Condition  && MaValues[shift + 1] < MaValues[shift + 2]; // and DEMA is falling down
    Sell_Condition = Sell_Condition && barlengh > MinBarPts * Point();
     *******/
    //
    bool Buy_Close = (close[shift] < BBUpperValues[shift] && open[shift] > BBUpperValues[shift]);        // Black candle crossed the Upper Band from above to below
    bool Sell_Close = (close[shift] > BBLowerValues[shift] && open[shift] < BBLowerValues[shift]);     // White candle crossed the Lower Band from below to above
   
    
    
    
    //
    if(Buy_Condition)
      BuySignalOpenBuffer[shift] = signal_value;
    if(Sell_Condition)
      SellSignalOpenBuffer[shift] = signal_value;
    if(Buy_Close)
      BuySignalCloseBuffer[shift] = signal_value;
    if(Sell_Close)
      SellSignalCloseBuffer[shift] = signal_value;
    /*****************
    if(val2 > diffHiLo || val > PBLevel)   //&& expanding )
    //if(val > PBLevel)    // Powerbar Level Filter
     {


      if(open_value < close_value)
       {

        // Bullish Candle -----------------------------------------------------------------------
        if(open_value < BBUpperValues[shift] && close_value > BBUpperValues[shift])  // cross upper line
         {
          BuySignalCloseBuffer[shift] = signal_value ;
          if(close_value - BBUpperValues[shift] < barlengh* overlap1)
           {
            BuySignalOpenBuffer[shift] = signal_value;
           }
          else
           {
            SellSignalOpenBuffer[shift] = signal_value;
           }
         }
        else if(open_value > BBLowerValues[shift]   && close_value < BBMidleValues[shift])   // bewteen lines
         {
          //     if(tendenceDn && spreading && open_value < BBMidleValues[shift])
           {
            BuySignalOpenBuffer[shift] = signal_value;
           }
         }
        else if(open_value < BBLowerValues[shift]   && close_value > BBLowerValues[shift])   // cross lower line
         {
          if((close_value - BBLowerValues[shift]) > (close_value - open_value) / divx)
           {
            BuySignalOpenBuffer[shift] = signal_value;
           }
         }
        else if(open_value < BBLowerValues[shift] && close_value < BBLowerValues[shift])  // under lower line
         {
          BuySignalOpenBuffer[shift] = signal_value;
         }
       }
      else
       {
        // Bearish Candle --------------------------------------------------------------------------
        if(open_value > BBUpperValues[shift] && close_value > BBUpperValues[shift])  // above upper line
         {
          SellSignalOpenBuffer[shift] = signal_value;
         }
        else if(open_value > BBUpperValues[shift] && close_value < BBUpperValues[shift])  // cross upper line
         {
          //     if(  (BBUpperValues[shift] - close_value) < (open_value - close_value) / divx )
           {
            SellSignalOpenBuffer[shift] = signal_value;
           }
         }
        else if(open_value < BBUpperValues[shift]   && close_value > BBMidleValues[shift])   // bewteen lines
         {
          //   if(tendenceUp && spreading && open_value > BBMidleValues[shift])
           {
            SellSignalOpenBuffer[shift]              = signal_value;
           }
         }
        else if(open_value > BBLowerValues[shift]   && close_value < BBLowerValues[shift])   // cross lower line
         {
          if(BBLowerValues[shift] - close_value < barlengh* overlap1)
           {
            SellSignalOpenBuffer[shift] = signal_value;
           }
          else
           {
            BuySignalOpenBuffer[shift] = signal_value;
           }
         }
       }
     }
       ***/
   }
  /*
  for(int shift = limit; shift > 0; shift--)
  {
   int closebar = shift > OrderBarCount ? shift - OrderBarCount : 1;
   if(BuySignalOpenBuffer[shift] != EMPTY_VALUE)
    {
     BuySignalCloseBuffer[closebar] = open[closebar];
    }
   if(SellSignalOpenBuffer[shift] != EMPTY_VALUE)
    {
     SellSignalCloseBuffer[closebar] = open[closebar];
    }

  }
  */
  DrawOrderLines();
//--- return value of prev_calculated for next call
  return(rates_total);
 }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
