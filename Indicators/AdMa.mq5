//+------------------------------------------------------------------+
//|                                                        ObvMa.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Accumulation/Distribution with Moving Average"
#include <MovingAverages.mqh>

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_color1  LightSeaGreen
#property indicator_color2  Red
#property indicator_label1  "A/D"
#property indicator_label2  "MA"

//--- input params
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // AD Volume type
input int    InpMaPeriod = 9;   // SMA period for OBV

//--- indicator buffer
double ExtADbuffer[];
double ExtMAbuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME,"A/D MA");
//--- index buffer
   SetIndexBuffer(0,ExtADbuffer);
   SetIndexBuffer(1,ExtMAbuffer);
//--- set index draw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,1);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpMaPeriod);
  }
//+------------------------------------------------------------------+
//| Accumulation/Distribution                                        |
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
//--- check for bars count
   if(rates_total<2)
      return(0); //exit with zero result
//--- get current position
   int pos=prev_calculated-1;
   if(pos<0)
      pos=0;
//--- calculate with appropriate volumes
   if(InpVolumeType==VOLUME_TICK)
      Calculate(rates_total,pos,high,low,close,tick_volume);
   else
      Calculate(rates_total,pos,high,low,close,volume);

//--- calculate Signal
   SimpleMAOnBuffer(rates_total,prev_calculated,0,InpMaPeriod,ExtADbuffer,ExtMAbuffer);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculating with selected volume                                 |
//+------------------------------------------------------------------+
void Calculate(const int rates_total,const int pos,
               const double &high[],
               const double &low[],
               const double &close[],
               const long &volume[])
  {
//--- main cycle
   for(int i=pos; i<rates_total && !IsStopped(); i++)
     {
      //--- get some data from arrays
      double hi=high[i];
      double lo=low[i];
      double cl=close[i];
      //--- calculate new AD
      double sum=(cl-lo)-(hi-cl);
      if(hi==lo)
         sum=0.0;
      else
         sum=(sum/(hi-lo))*volume[i];
      if(i>0)
         sum+=ExtADbuffer[i-1];
      ExtADbuffer[i]=sum;
     }
  }
//+------------------------------------------------------------------+