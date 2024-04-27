//+------------------------------------------------------------------+
//|                                                        ObvMa.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "On Balance Vol SMA"

//--- indicator settings
#property indicator_separate_window
#property script_show_inputs
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_color2  Red
#property indicator_label1  "OBV"
#property indicator_label2  "MA"

//--- input parametrs
input int    obvPeriod = 14;  // OBV period
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volumes
input int    maPeriod = 9;   // SMA period for OBV
input int    maShift  = 0;
input ENUM_TIMEFRAMES  maTimeframe = 0; // Current timeframe by default

//--- indicator buffer
double ExtOBVBuffer[];
double maBuffer[];
//+------------------------------------------------------------------+
//| On Balance vol initialization function                        |
//+------------------------------------------------------------------+
void OnInit()
  {
   //define indicator buffer
   SetIndexBuffer(0,ExtOBVBuffer);
   SetIndexBuffer(1,maBuffer);
   
   //set indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,0);   
   
   // Set the indicator short name and create plots
   IndicatorSetString(INDICATOR_SHORTNAME, "OBV w/ SMA");
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, obvPeriod);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, maPeriod);
  }
//+------------------------------------------------------------------+
//| On Balance vol                                                |
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
   if(rates_total<2)
      return(0);
//--- starting calculation
   int pos=prev_calculated-1;
//--- correct position, when it's first iteration
   if(pos<1)
     {
      pos=1;
      if(InpVolumeType==VOLUME_TICK)
         ExtOBVBuffer[0]=(double)tick_volume[0];
      else
         ExtOBVBuffer[0]=(double)volume[0];
     }
//--- main cycle
   if(InpVolumeType==VOLUME_TICK)
      CalculateOBV(pos,rates_total,close,tick_volume);
   else
      CalculateOBV(pos,rates_total,close,volume);
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate OBV by volume argument                                 |
//+------------------------------------------------------------------+
void CalculateOBV(int start_pos,
                  int rates_total,
                  const double& close[],
                  const long& volume[])
  {
   for(int i=start_pos; i<rates_total && !IsStopped(); i++)
     {
      double vol=(double)volume[i];
      double prev_close=close[i-1];
      double curr_close=close[i];
      //--- fill ExtOBVBuffer
      if(curr_close<prev_close)
         ExtOBVBuffer[i]=ExtOBVBuffer[i-1]-vol;
      else
        {
         if(curr_close>prev_close)
            ExtOBVBuffer[i]=ExtOBVBuffer[i-1]+vol;
         else
            ExtOBVBuffer[i]=ExtOBVBuffer[i-1];
        }
     }
  }
//+------------------------------------------------------------------+