//+------------------------------------------------------------------+
//|                                        IndicatorLibrary-v1p3.mq5 |
//|                                    Copyright 2024, Dillon Grech. |
//|                   YouTube: https://www.youtube.com/c/DillonGrech |
//|                           GitHub: https://github.com/DillonGrech |
//|                           Discord: https://discord.gg/xs3KpdUjSu |
//+------------------------------------------------------------------+
//|                                                  Version Notes 1 |
//| This file contains a list of indicators which can be used for    |
//| triggers (entry or exit triggers), filters and getting indicator |
//| values.                                                          |
//|                                                                  |
//+------------------------------------------------------------------+
//|                                                    Patch Notes 3 |
//| Added further indicators to this library. See library contents.  |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//|                                                            NOTES |
//| STRUCTURE                                                        |
//| Indicators must be set up in the following way:                  |
//|    - 1st value specifies the indicator name. Eg Sma              |
//|    - 2nd value is a reference to the indicator conditions        |
//|    - 3rd value onwards is specific indicator parametres          |
//|    - Note. All values must be delimited by '_' charater          |
//|                                                                  |
//| LEGEND                                                           |
//| Indicator and parametres are stored in IndicatorArray[]          |
//|    - IndicatorArray[0]    = name                                 |
//|    - IndicatorArray[1]    = indicator conditions (eg. 'A')       |
//|    - IndicatorArray[2..n] = parameter for n parameters           |
//|                                                                  |
//| EXAMPLE                                                          |
//| Macd_A_12_26_9                                                   |
//|    - IndicatorArray[0] = MACD indicator                          |
//|    - IndicatorArray[1] = Conditions 'A' defined in library below |
//|    - IndicatorArray[2] = 12 - refering to fast MA on MACD        |
//|    - IndicatorArray[3] = 24 - refering to slow MA on MACD        |
//|    - IndicatorArray[4] =  9 - refering to signal line on MACD    |
//|                                                                  |
//| LIBRARY CONTENTS                                                 |
//|---TREND FOLLOWING INDICATORS                                     |
//|   Sma_A_Period - Trigger, Filter - [A,B]                         |
//|   Ema_A_Period - Trigger, Filter - [A,B]                         |
//|   Smma_A_Period - Trigger, Filter - [A,B]                        |
//|   Lwma_A_Period - Trigger, Filter - [A,B]                        |
//|   Frama_A_Period - Trigger, Filter - [A,B]                       |
//|---MOMENTUM INDICATORS                                            |
//|   Rsi_A_Period_UpperThreshold_LowerThreshold - Filter - [A,B]    |
//|---VOLATILITY INDICATORS                                          |
//|   Bb_A_Period_SD_NoCloses - Trigger - [A,B]                      |
//|   Atr_A_Period - NA - [A]                                        |
//|   Adma_A_MaPeriod - Filter - [A]                                 |
//|---OSCILLATOR INDICATORS                                          |
//|   Macd_A_Fast_Slow_Signal - Trigger, Filter - [A,B]              |
//|   Ac_A - Trigger, Filter - [A,B]                                 |
//|---PRICE ACTION INDICATORS                                        |
//|   Don_A_Period - Trigger - [A]                                   |
//|---OTHER INDICATORS                                               |
//|                                                                  |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2024, Dillon Grech"
#property version   "1.01"
//+------------------------------------------------------------------+
//| Set up Inidcator Handle                                          |
//+------------------------------------------------------------------+
int GetIndicatorHandle(string Indicator, string CurrentSymbol, ENUM_TIMEFRAMES CurrentPeriod) export
{
//---SET UP
   //Declare variables
   int    Handle = 0;          //stores indicator handle
   string IndicatorArray[];    //stores indicator array and parameters
   int    NumberOfParameters;  //stores number of indicator parameters, including indicator name
   string IndicatorDetails = "";
   //Get indicator name and parametres
   NumberOfParameters = StringSplit(Indicator, '_', IndicatorArray); //Split indicator and parametres
   ArrayResize(IndicatorArray,NumberOfParameters);                   //Resize array to number of paramentres
   //Print result
   for(int n=0; n < NumberOfParameters; n++)
      IndicatorDetails = IndicatorDetails + IntegerToString(n) + ") " + IndicatorArray[n] + " ";
   Print("EA will process indicator: ", IndicatorDetails, " with ", NumberOfParameters, " parameters for symbol ", CurrentSymbol);

//---CHECK FOR NA INDICATOR
   //If Na Indicator
   if(IndicatorArray[0] == "Na")
   {
      //Get indicator handle
      Print("Handle for " + Indicator + " for " + CurrentSymbol + " created. Handle ID ",Handle,".");
      //Return value
      return 0;
   }

//---TREND FOLLOWING INDICATORS
   //Simple Moving Average Handle
   if(IndicatorArray[0] == "Sma")
   {
      //Get indicator handle
      Handle = iMA(CurrentSymbol,CurrentPeriod,StringToInteger(IndicatorArray[2]),0,MODE_SMA,PRICE_CLOSE);
      //Error handling
      if(Handle == INVALID_HANDLE)
         MessageBox("Failed to create handle for " + Indicator + " indicator for " + CurrentSymbol + ". Error Code " + IntegerToString(GetLastError()));
      else
         Print("Handle for " + Indicator + " for " + CurrentSymbol + " created. Handle ID ",Handle,".");
      //Return value
      return Handle;
   }

   //Exponential Moving Average Handle
   if(IndicatorArray[0] == "Ema")
   {
      //Get indicator handle
      Handle = iMA(CurrentSymbol,CurrentPeriod,StringToInteger(IndicatorArray[2]),0,MODE_EMA,PRICE_CLOSE);
      //Error handling
      if(Handle == INVALID_HANDLE)
         MessageBox("Failed to create handle for " + Indicator + " indicator for " + CurrentSymbol + ". Error Code " + IntegerToString(GetLastError()));
      else
         Print("Handle for " + Indicator + " for " + CurrentSymbol + " created. Handle ID ",Handle,".");
      //Return value
      return Handle;
   }

   //Smoothed Moving Average Handle
   if(IndicatorArray[0] == "Smma")
   {
      //Get indicator handle
      Handle = iMA(CurrentSymbol,CurrentPeriod,StringToInteger(IndicatorArray[2]),0,MODE_SMMA,PRICE_CLOSE);
      //Error handling
      if(Handle == INVALID_HANDLE)
         MessageBox("Failed to create handle for " + Indicator + " indicator for " + CurrentSymbol + ". Error Code " + IntegerToString(GetLastError()));
      else
         Print("Handle for " + Indicator + " for " + CurrentSymbol + " created. Handle ID ",Handle,".");
      //Return value
      return Handle;
   }

   //Linear Weighting Moving Average
   if(IndicatorArray[0] == "Lwma")
   {
      //Get indicator handle
      Handle = iMA(CurrentSymbol,CurrentPeriod,StringToInteger(IndicatorArray[2]),0,MODE_LWMA,PRICE_CLOSE);
      //Error handling
      if(Handle == INVALID_HANDLE)
         MessageBox("Failed to create handle for " + Indicator + " indicator for " + CurrentSymbol + ". Error Code " + IntegerToString(GetLastError()));
      else
         Print("Handle for " + Indicator + " for " + CurrentSymbol + " created. Handle ID ",Handle,".");
      //Return value
      return Handle;
   }

   //Fractal Adaptive Moving Average
   if(IndicatorArray[0] == "Frama")
   {
      //Get indicator handle
      Handle = iFrAMA(CurrentSymbol,CurrentPeriod,StringToInteger(IndicatorArray[2]),0,PRICE_CLOSE);
      //Error handling
      if(Handle == INVALID_HANDLE)
         MessageBox("Failed to create handle for " + Indicator + " indicator for " + CurrentSymbol + ". Error Code " + IntegerToString(GetLastError()));
      else
         Print("Handle for " + Indicator + " for " + CurrentSymbol + " created. Handle ID ",Handle,".");
      //Return value
      return Handle;
   }

//---MOMENTUM INDICATORS
   //RSI Handle
   if(IndicatorArray[0] == "Rsi")
   {
      //Get indicator handle
      Handle = iRSI(CurrentSymbol,CurrentPeriod,StringToInteger(IndicatorArray[2]),PRICE_CLOSE);
      //Error handling
      if(Handle == INVALID_HANDLE)
         MessageBox("Failed to create handle for " + Indicator + " indicator for " + CurrentSymbol + ". Error Code " + IntegerToString(GetLastError()));
      else
         Print("Handle for " + Indicator + " for " + CurrentSymbol + " created. Handle ID ",Handle,".");
      //Return value
      return Handle;
   }

//---VOLATILITY INDICATORS
   //Bollinger Bands
   if(IndicatorArray[0] == "Bb")
   {
      //Get indicator handle
      Handle = iBands(CurrentSymbol,CurrentPeriod,StringToInteger(IndicatorArray[2]),0,StringToInteger(IndicatorArray[3]),PRICE_CLOSE);
      //Error handling
      if(Handle == INVALID_HANDLE)
         MessageBox("Failed to create handle for " + Indicator + " indicator for " + CurrentSymbol + ". Error Code " + IntegerToString(GetLastError()));
      else
         Print("Handle for " + Indicator + " for " + CurrentSymbol + " created. Handle ID ",Handle,".");
      //Return value
      return Handle;
   }

   //Average True Range Handle
   if(IndicatorArray[0] == "Atr")
   {
      //Get indicator handle
      Handle = iATR(CurrentSymbol,CurrentPeriod,StringToInteger(IndicatorArray[2]));
      //Error handling
      if(Handle == INVALID_HANDLE)
         MessageBox("Failed to create handle for " + Indicator + " indicator for " + CurrentSymbol + ". Error Code " + IntegerToString(GetLastError()));
      else
         Print("Handle for " + Indicator + " for " + CurrentSymbol + " created. Handle ID ",Handle,".");
      //Return value
      return Handle;
   }

   //Accumulation/Distribution with Moving Average
   if(IndicatorArray[0] == "Adma")
   {
      //Get indicator handle
      Handle = iCustom(CurrentSymbol,CurrentPeriod,"Custom\\AdMa",VOLUME_TICK,StringToInteger(IndicatorArray[2]));
      //Error handling
      if(Handle == INVALID_HANDLE)
         MessageBox("Failed to create handle for " + Indicator + " indicator for " + CurrentSymbol + ". Error Code " + IntegerToString(GetLastError()));
      else
         Print("Handle for " + Indicator + " for " + CurrentSymbol + " created. Handle ID ",Handle,".");
      //Return value
      return Handle;
   }

//---OSCILLATOR INDICATORS
   //Macd Handles
   if(IndicatorArray[0] == "Macd")
   {
      //Get indicator handle
      Handle = iMACD(CurrentSymbol,CurrentPeriod,StringToInteger(IndicatorArray[2]),StringToInteger(IndicatorArray[3]),StringToInteger(IndicatorArray[4]),PRICE_CLOSE);
      //Error handling
      if(Handle == INVALID_HANDLE)
         MessageBox("Failed to create handle for " + Indicator + " indicator for " + CurrentSymbol + ". Error Code " + IntegerToString(GetLastError()));
      else
         Print("Handle for " + Indicator + " for " + CurrentSymbol + " created. Handle ID ",Handle,".");
      //Return value
      return Handle;
   }

   //Accelerator Oscillator
   if(IndicatorArray[0] == "Ac")
   {
      //Get indicator handle
      Handle = iAC(CurrentSymbol,CurrentPeriod);
      //Error handling
      if(Handle == INVALID_HANDLE)
         MessageBox("Failed to create handle for " + Indicator + " indicator for " + CurrentSymbol + ". Error Code " + IntegerToString(GetLastError()));
      else
         Print("Handle for " + Indicator + " for " + CurrentSymbol + " created. Handle ID ",Handle,".");
      //Return value
      return Handle;
   }

//---PRICE ACTION INDICATORS
   //Donchian Channel
   if(IndicatorArray[0] == "Don")
   {
      //Get indicator handle
      Handle = iCustom(CurrentSymbol,CurrentPeriod,"Custom\\Donchian_Channel",StringToInteger(IndicatorArray[2]));
      //Error handling
      if(Handle == INVALID_HANDLE)
         MessageBox("Failed to create handle for " + Indicator + " indicator for " + CurrentSymbol + ". Error Code " + IntegerToString(GetLastError()));
      else
         Print("Handle for " + Indicator + " for " + CurrentSymbol + " created. Handle ID ",Handle,".");
      //Return value
      return Handle;
   }
   
//---OTHER INDICATORS
//---ERROR HANDLING
   else
   {
      Print("No Handle created for " + Indicator + " for " + CurrentSymbol + ". Handle ID ",Handle,".");
      return 0;
   }
}
//+------------------------------------------------------------------+
//Set up Indicator Trigger Signals
//+------------------------------------------------------------------+
string GetIndicatorTrigger(string Indicator, int IndicatorHandle, string CurrentSymbol, ENUM_TIMEFRAMES CurrentPeriod) export
{
//---SET UP
   //Declare variables
   string IndicatorArray[];   //stores indicator array and parameters
   int    NumberOfParameters; //stores number of indicator parameters, including indicator name
   //Get indicator name and parametres
   NumberOfParameters = StringSplit(Indicator, '_', IndicatorArray); //Split indicator and parametres
   ArrayResize(IndicatorArray,NumberOfParameters);                   //Resize array to number of paramentres

//---CHECK FOR NA INDICATOR
   if(IndicatorArray[0] == "Na")
   {
      return "NA";
   }

//---TREND FOLLOWING INDICATORS
   //Moving average indicator triggers
   //A: Price crosses above moving average (long) or price crosses below moving average (short)
   //B: Price crossed above moving average (short) or price crosses below moving average (long)
   if(IndicatorArray[0] == "Sma" || IndicatorArray[0] == "Ema" || IndicatorArray[0] == "Smma" || IndicatorArray[0] == "Lwma" ||  IndicatorArray[0] == "Frama")
   {
      //Set symbol and indicator buffers
      double    BufferMA[];
      //Define indicator line(s), from not confirmed candle 0, for 3 candles, and store results. NOTE:[prior,current,new]
      bool      FillMA   = CopyBuffer(IndicatorHandle,0,0,3,BufferMA);
      //Error handling for copy buffer
      if(FillMA==false)
      {
         return "Fill Error";
      }
      //Find required signal lines and normalize to 10 places to prevent rounding errors in crossovers
      double    CurrentMA    = NormalizeDouble(BufferMA[1],10);
      double    CurrentPrice = NormalizeDouble(iClose(CurrentSymbol,CurrentPeriod,1), 10); //1 is current confirmed candle closed (0 is new candle)
      double    PriorMA      = NormalizeDouble(BufferMA[0],10);
      double    PriorPrice   = NormalizeDouble(iClose(CurrentSymbol,CurrentPeriod,2), 10); //2 is prior candle closed
      //A: Price crosses above moving average (long) or price crosses below moving average (short)
      if(IndicatorArray[1] == "A")
      {
         if(PriorPrice <= PriorMA && CurrentPrice > CurrentMA)
         {
            return   "Long";
         }
         else if(PriorPrice >= PriorMA && CurrentPrice < CurrentMA)
         {
            return   "Short";
         }
         else
         {
            return   "No Trade";
         }
      }
      //B: Price crossed above moving average (short) or price crosses below moving average (long)
      else if(IndicatorArray[1] == "B")
      {
         if(PriorPrice <= PriorMA && CurrentPrice > CurrentMA)
         {
            return   "Short";
         }
         else if(PriorPrice >= PriorMA && CurrentPrice < CurrentMA)
         {
            return   "Long";
         }
         else
         {
            return   "No Trade";
         }
      }
      //Error handling - if indicator array[1] indicator condition is not found
      else
      {
         return   "Error";
      }
   }

//---MOMENTUM INDICATORS
//---VOLATILITY INDICATORS
   //Bollinger Bands with n consecutive candle close lookback
   //A: n candle closes above upper band (long) or n candle closed below lower band (short) - trend following
   //B: n candle closes above upper band (short) or n candle closed below lower band (long) - mean reversion
   if(IndicatorArray[0] == "Bb")
   {
      //Set symbol and indicator buffers
      double  BufferBbUpper[];
      double  BufferBbMid[];
      double  BufferBbLower[];
      int     BbLength    = StringToInteger(IndicatorArray[4]);
      int     ArrayLength = BbLength +2; //add 2 for array length to factor in start candle and new candle
      //Define indicator line(s), from not confirmed candle 0, for n candles, and store results. NOTE:[start n,...,prior,current,new] INDEX: [0,...,n-3,n-2,n-1]
      //Eg. For 3 candle closes, add 2 to the buffer array to factor in start candle and new candle either side - [Start0,Candle1,Candle2,Candle3,new] INDEX: [0,1,2,3,4]
      bool      FillBbUpper   = CopyBuffer(IndicatorHandle,1,0,ArrayLength,BufferBbUpper);
      bool      FillBbMid     = CopyBuffer(IndicatorHandle,0,0,ArrayLength,BufferBbMid);
      bool      FillBbLower   = CopyBuffer(IndicatorHandle,2,0,ArrayLength,BufferBbLower);
      //Error handling for copy buffer
      if(FillBbUpper==false || FillBbMid==false || FillBbLower==false)
      {
         return "Fill Error";
      }
      //Run candle closes loop for upper band signal
      //Note only need to run for BbLength number of candles, dont run for start and new candles
      bool UpperSignal = true; //store intial starting signal
      for(int n=1; n <= BbLength; n++)
      {
         //Get main variables
         double nPrice   = NormalizeDouble(iClose(CurrentSymbol,CurrentPeriod,ArrayLength-n-1), 10);
         double nBbUpper = NormalizeDouble(BufferBbUpper[n],10);
         //Run initial cross over check when n = 1
         if(n==1)
         {
            //Get initial start variables
            double  StartPrice     = NormalizeDouble(iClose(CurrentSymbol,CurrentPeriod,ArrayLength-n), 10);
            double  StartBbUpper   = NormalizeDouble(BufferBbUpper[0],10);
            //If there was no crossover, then update Long Signal from Long to NA
            if(!(StartPrice <= StartBbUpper && nPrice > nBbUpper))
            {
               UpperSignal = false;
            }
         }
         //else, run check for consecutive candle closes against BB
         else
         {
            //If price is not less than BB, then update Long Signal from Long to NA
            if(!(nPrice > nBbUpper))
            {
               UpperSignal = false;
            }
         }
         //Print conditions for testing
         //Print(n, ") nPrice " , nPrice, " nBbUpper ", nBbUpper, " UpperSignal ", UpperSignal);
      }
      //Run candle loop for lower band signal
      //Note only need to run for BbLength number of candles, dont run for start and new candles
      bool LowerSignal = true; //store starting signal
      for(int n=1; n <= BbLength; n++)
      {
         //Get main variables
         double nPrice   = NormalizeDouble(iClose(CurrentSymbol,CurrentPeriod,ArrayLength-n-1), 10);
         double nBbLower = NormalizeDouble(BufferBbLower[n],10);
         //Run initial cross over check when n = 1
         if(n==1)
         {
            //Get initial start variables
            double  StartPrice     = NormalizeDouble(iClose(CurrentSymbol,CurrentPeriod,ArrayLength-n), 10);
            double  StartBbLower   = NormalizeDouble(BufferBbLower[0],10);
            //If there was no crossover, then update Short Signal from Short to NA
            if(!(StartPrice >= StartBbLower && nPrice < nBbLower))
            { 
               LowerSignal = false;
            }
         }
         //else, run check for consecutive candle closes against BB
         else
         {
            //If price is not less than BB, then update Short Signal from Short to NA
            if(!(nPrice < nBbLower))
            {
               LowerSignal = false;
            }
         }
         //Print conditions for testing
         //Print(n, ") nPrice " , nPrice, " nBbLower ", nBbLower, " LowerBand ", LowerBand);
      }
      //A: n candle closes above upper band (long) or n candle closed below lower band (short) - trend following
      if(IndicatorArray[1] == "A")
      {
         if(UpperSignal == true)
         {
            return   "Long";
         }
         else if(LowerSignal == true)
         {
            return   "Short";
         }
         else
         {
            return  "No Trade";
         }
      }
      //B: Price crossed above moving average (short) or price crosses below moving average (long)
      else if(IndicatorArray[1] == "B")
      {
         if(UpperSignal == true)
         {
            return   "Short";
         }
         else if(LowerSignal == true)
         {
            return   "Long";
         }
         else
         {
            return  "No Trade";
         }
      }
      //Error handling - if indicator array[1] indicator condition is not found
      else
      {
         return   "Error";
      }
   }

//---OSCILLATOR INDICATORS
   //Macd
   //A: Macd and signal line crossover and cross occurs below 0 line (long) or Macd and signal line crossunder and cross occurs above 0 line (short)
   //B: Macd and signal line crossover and cross occurs below 0 line (short) or Macd and signal line crossunder and cross occurs above 0 line (long)
   if(IndicatorArray[0] == "Macd")
   {
      //Set symbol and indicator buffers
      double    BufferMacd[];
      double    BufferSignal[];
      //Define indicator line(s), from not confirmed candle 0, for 3 candles, and store results. NOTE:[prior,current,new]
      bool      FillMacd   = CopyBuffer(IndicatorHandle,0,0,3,BufferMacd);
      bool      FillSignal = CopyBuffer(IndicatorHandle,1,0,3,BufferSignal);
      //Error handling for copy buffer
      if(FillMacd==false || FillSignal==false)
      {
         return "Fill Error";
      }
      //Find required signal lines and normalize to 10 places to prevent rounding errors in crossovers
      double    CurrentMacd   = NormalizeDouble(BufferMacd[1],10);
      double    CurrentSignal = NormalizeDouble(BufferSignal[1],10);
      double    PriorMacd     = NormalizeDouble(BufferMacd[0],10);
      double    PriorSignal   = NormalizeDouble(BufferSignal[0],10);

      //A: Macd and signal line crossover and cross occurs below 0 line (long) or Macd and signal line crossunder and cross occurs above 0 line (short)
      if(IndicatorArray[1] == "A")
      {
         if((PriorMacd <= PriorSignal && CurrentMacd > CurrentSignal) && (CurrentMacd < 0 && CurrentSignal < 0))
         {
            return   "Long";
         }
         else if((PriorMacd >= PriorSignal && CurrentMacd < CurrentSignal) && (CurrentMacd > 0 && CurrentSignal > 0))
         {
            return   "Short";
         }
         else
         {
            return   "No Trade";
         }
      }
      //B: Macd and signal line crossover and cross occurs below 0 line (short) or Macd and signal line crossunder and cross occurs above 0 line (long)
      else if(IndicatorArray[1] == "B")
      {
         if((PriorMacd <= PriorSignal && CurrentMacd > CurrentSignal) && (CurrentMacd < 0 && CurrentSignal < 0))
         {
            return   "Short";
         }
         else if((PriorMacd >= PriorSignal && CurrentMacd < CurrentSignal) && (CurrentMacd > 0 && CurrentSignal > 0))
         {
            return   "Long";
         }
         else
         {
            return   "No Trade";
         }
      }
      //Error handling - if indicator array[1] indicator condition is not found
      else
      {
         return   "Error";
      }
   }

   //Accelerator Oscillator
   //A: AC line crosses over with 0 line (long) or AC line crosses under 0 line (short)
   //B: AC line crosses over with 0 line (short) or AC line crosses under 0 line (long)
   if(IndicatorArray[0] == "Ac")
   {
      //Set symbol and indicator buffers
      double    BufferAc[];
      //Define indicator line(s), from not confirmed candle 0, for 3 candles, and store results. NOTE:[prior,current,new]
      bool      FillAc   = CopyBuffer(IndicatorHandle,0,0,3,BufferAc);
      //Error handling for copy buffer
      if(FillAc==false)
      {
         return "Fill Error";
      }
      //Find required signal lines and normalize to 10 places to prevent rounding errors in crossovers
      double    CurrentAc   = NormalizeDouble(BufferAc[1],10);
      double    PriorAc     = NormalizeDouble(BufferAc[0],10);
      //A: AC line crosses over with 0 line (long) or AC line crosses under 0 line (short)
      if(IndicatorArray[1] == "A")
      {
         if(PriorAc <= 0 && CurrentAc > 0)
         {
            return   "Long";
         }
         else if(PriorAc >= 0 && CurrentAc < 0)
         {
            return   "Short";
         }
         else
         {
            return   "No Trade";
         }
      }
      //B: AC line crosses over with 0 line (short) or AC line crosses under 0 line (long)
      else if(IndicatorArray[1] == "B")
      {
         if(PriorAc <= 0 && CurrentAc > 0)
         {
            return   "Short";
         }
         else if(PriorAc >= 0 && CurrentAc < 0)
         {
            return   "Long";
         }
         else
         {
            return   "No Trade";
         }
      }
      //Error handling - if indicator array[1] indicator condition is not found
      else
      {
         return   "Error";
      }
   }

//---PRICE ACTION INDICATORS
   //Doncian trigger signal cross with price and no new high or low
   //A: Price crosses above upper channel and price has not made a recent high (long) or Price crosses under lower channel and price has not made a recent low (short) - trend
   //B: Price crosses above upper channel and price has not made a recent high (short) or Price crosses under lower channel and price has not made a recent low (long) - mean reversion
   if(IndicatorArray[0] == "Don")
   {
      //Set symbol and indicator buffers
      double  BufferDonUpper[];
      double  BufferDonLower[];
      int     DonLength = StringToInteger(IndicatorArray[1]);
      //Define indicator line(s), from not confirmed candle 0, for n candles, and store results. NOTE:[start n,...,prior,current,new] INDEX: [0,...,n-3,n-2,n-1]
      bool    FillDonUpper   = CopyBuffer(IndicatorHandle,0,0,DonLength,BufferDonUpper);
      bool    FillDonLower   = CopyBuffer(IndicatorHandle,2,0,DonLength,BufferDonLower);
      //Error handling for copy buffer
      if(FillDonUpper==false || FillDonLower==false)
      {
         return "Fill Error";
      }
      //Find required signal lines and normalize to 10 places to prevent rounding errors in crossovers
      double    CurrentDonUpper = NormalizeDouble(BufferDonUpper[DonLength-2],10);
      int       IndexMin        = ArrayMinimum(BufferDonUpper); // get minimum donchain value over don length n days (-1 removing new candle) for upper band
      double    MinDonUpper     = NormalizeDouble(BufferDonUpper[IndexMin],10);
      double    CurrentDonLower = NormalizeDouble(BufferDonLower[DonLength-2],10);
      int       IndexMax        = ArrayMaximum(BufferDonLower); // get maximum donchain value over don length n days (-1 removing new candle) for upper band
      double    MaxDonLower     = NormalizeDouble(BufferDonLower[IndexMax],10);
      double    CurrentPrice    = NormalizeDouble(iClose(CurrentSymbol,CurrentPeriod,1), 10); //1 is current confirmed candle closed (0 is new candle)
      //Print conditions for testing
      //Print("past" , NormalizeDouble(BufferDonUpper[0],10), " CurrentDonUpper ", CurrentDonUpper,". MinDonUpper ", MinDonUpper, ". IndexMin ", IndexMin);
      //Print("past" , NormalizeDouble(BufferDonLower[0],10), " CurrentDonLower ", CurrentDonLower,". MaxDonLower ", MaxDonLower, ". IndexMax ", IndexMax);
      //A: Price crosses above upper channel and price has not made a recent high (long) or Price crosses under lower channel and price has not made a recent low (short) - trend
      if(IndicatorArray[1] == "A")
      {
         //check for trend following
         if(CurrentPrice > CurrentDonUpper && CurrentDonUpper == MinDonUpper)
         {
            return   "Long";
         }
         else if(CurrentPrice < CurrentDonLower && CurrentDonLower == MaxDonLower) 
         {
            return   "Short";
         }
         else
         {
            return  "No Trade";
         }
      }
      //B: Price crosses above upper channel and price has not made a recent high (short) or Price crosses under lower channel and price has not made a recent low (long) - mean reversion
      else if(IndicatorArray[1] == "B")
      {
         if(CurrentPrice > CurrentDonUpper && CurrentDonUpper == MinDonUpper)
         {   
            return   "Short";
         }
         else if(CurrentPrice < CurrentDonLower && CurrentDonLower == MaxDonLower)
         {
            return   "Long";
         }
         else
         {
            return  "No Trade";
         }
      }
      //Error handling - if indicator array[1] indicator condition is not found
      else
      {
         return   "Error";
      }
   }


//---OTHER INDICATORS
//---ERROR HANDLING
   //if indicator array[0] indicator is not found
   else
   {
      return   "Error";
   }
}
//+------------------------------------------------------------------+
//| Set up Indicator Filter Signals                                  |
//+------------------------------------------------------------------+
string GetIndicatorFilter(string Indicator, int IndicatorHandle, string CurrentSymbol, ENUM_TIMEFRAMES CurrentPeriod) export
{
//---SET UP
   // Declare variables
   string IndicatorArray[];   //stores indicator array and parameters
   int    NumberOfParameters; //stores number of indicator parameters, including indicator name
   //Get indicator name and parametres
   NumberOfParameters = StringSplit(Indicator, '_', IndicatorArray); //Split indicator and parametres
   ArrayResize(IndicatorArray,NumberOfParameters);                   //Resize array to number of paramentres

//---CHECK FOR NA INDICATOR
   //If Na Indicator
   if(IndicatorArray[0] == "Na")
   {
      return "NA";
   }

//---TREND FOLLOWING INDICATORS
   //Moving average indicator triggers
   //A: Price is above moving average (long) or price is below moving average (short)
   //B: Price is above moving average (short) or price is below moving average (long)
   if(IndicatorArray[0] == "Sma" || IndicatorArray[0] == "Ema" || IndicatorArray[0] == "Smma" || IndicatorArray[0] == "Lwma" ||  IndicatorArray[0] == "Frama")
   {
      //Set symbol and indicator buffers
      double    BufferMA[];
      //Define indicator line(s), from not confirmed candle 0, for 2 candles, and store results. NOTE:[current,new]
      bool      FillMA   = CopyBuffer(IndicatorHandle,0,0,2,BufferMA);
      //Error handling for copy buffer
      if(FillMA==false)
      {
         return "Fill Error";
      }
      //Find required signal lines and normalize to 10 places to prevent rounding errors in crossovers
      double    CurrentMA   = NormalizeDouble(BufferMA[0],10);
      double    CurrentPrice = NormalizeDouble(iClose(CurrentSymbol,CurrentPeriod,1), 10); //1 is current confirmed candle closed (0 is new candle)
      //A: Price is above moving average (long) or price is below moving average (short)
      if(IndicatorArray[1] == "A")
      {
         if(CurrentPrice > CurrentMA)
         {
            return   "Long";
         }
         else if(CurrentPrice < CurrentMA)
         {
            return   "Short";
         }
         else
         { 
            return   "No Trade";
         }
      }
      //B: Price is above moving average (short) or price is below moving average (long)
      else if(IndicatorArray[1] == "B")
      {
         if(CurrentPrice > CurrentMA)
         {
            return   "Short";
         }
         else if(CurrentPrice < CurrentMA)
         {
            return   "Long";
         }
         else
         {
            return   "No Trade";
         }
      }
      //Error handling - if indicator array[1] indicator condition is not found
      else
      {
         return   "Error";
      }
   }

//---MOMENTUM INDICATORS
   //Rsi
   //A: Rsi is above upper band threshold (long) or Rsi is below upper band threshold (short) - Trend
   //B: Rsi is above upper band threshold (short) or Rsi is below upper band threshold (long) - Mean reversion
   if(IndicatorArray[0] == "Rsi")
   {
      //Set symbol and indicator buffers
      double    BufferRsi[];
      //Define indicator line(s), from not confirmed candle 0, for 2 candles, and store results. NOTE:[current,new]
      bool      FillRsi   = CopyBuffer(IndicatorHandle,0,0,2,BufferRsi);
      //Error handling for copy buffer
      if(FillRsi==false)
      {
         return "Fill Error";
      }
      //Find required signal lines and normalize to 10 places to prevent rounding errors in crossovers
      double CurrentRsi  = NormalizeDouble(BufferRsi[0],10);
      int    UpperBand   = StringToInteger(IndicatorArray[3]);
      int    LowerBand   = StringToInteger(IndicatorArray[4]);
      //A: Rsi is above upper band threshold (long) or Rsi is below upper band threshold (short) - Trend
      if(IndicatorArray[1] == "A")
      {
         if(CurrentRsi > UpperBand)
         {
            return   "Long";
         }
         else if(CurrentRsi < LowerBand)
         {
            return   "Short";
         }
         else
         {
            return   "No Trade";
         }
      }
      //B: Rsi is above upper band threshold (short) or Rsi is below upper band threshold (long) - Mean reversion
      else if(IndicatorArray[1] == "B")
      {
         if(CurrentRsi > UpperBand)
         {
            return   "Short";
         }
         else if(CurrentRsi < LowerBand)
         {
            return   "Long";
         }
         else
         {
            return   "No Trade";
         }
      }
      //Error handling - if indicator array[1] indicator condition is not found
      else
      {
         return   "Error";
      }    
   }

//---VOLATILITY INDICATORS
   //Accumulation/Distribution with Moving Average
   //A: Ac line is above moving average (long) or Ac line is below moving average (short)
   //B: Ac line is above moving average (short) or Ac line is below moving average (long)  
   if(IndicatorArray[0] == "Adma")
   {
      //Set symbol and indicator buffers
      double    BufferAd[];
      double    BufferMa[];
      //Define indicator line(s), from not confirmed candle 0, for 2 candles, and store results. NOTE:[current,new]
      bool      FillAd   = CopyBuffer(IndicatorHandle,0,0,2,BufferAd);
      bool      FillMa   = CopyBuffer(IndicatorHandle,1,0,2,BufferMa);
      //Error handling for copy buffer
      if(FillAd==false || FillMa==false)
      {
         return "Fill Error";
      }
      //Find required signal lines and normalize to 10 places to prevent rounding errors in crossovers
      double    CurrentAd = NormalizeDouble(BufferAd[0],10);
      double    CurrentMa = NormalizeDouble(BufferMa[0],10);
      //A: Ac line is above moving average (long) or Ac line is below moving average (short)
      if(IndicatorArray[1] == "A")
      {
         if(CurrentAd > CurrentMa)
         {
            return   "Long";
         }
         else if(CurrentAd < CurrentMa)
         {
            return   "Short";
         }
         else
         {
            return   "No Trade";
         }
      }
      //B: Ac line is above moving average (short) or Ac line is below moving average (long) 
      else if(IndicatorArray[1] == "B")
      {
         if(CurrentAd > CurrentMa)
         {
            return   "Short";
         }
         else if(CurrentAd < CurrentMa)
         {
            return   "Long";
         }
         else
         {
            return   "No Trade";
         }
      }
      //Error handling - if indicator array[1] indicator condition is not found
      else
      {
         return   "Error";
      }
   }

//---OSCILLATOR INDICATORS
   //Macd
   //A: Macd is above signal line crossover (long) or Macd is below signal line (short)
   //B: Macd is above signal line crossover (short) or Macd is below signal line (long)
   if(IndicatorArray[0] == "Macd")
   {
      //Set symbol and indicator buffers
      double    BufferMacd[];
      double    BufferSignal[];
      //Define indicator line(s), from not confirmed candle 0, for 2 candles, and store results. NOTE:[current,new]
      bool      FillMacd   = CopyBuffer(IndicatorHandle,0,0,2,BufferMacd);
      bool      FillSignal = CopyBuffer(IndicatorHandle,1,0,2,BufferSignal);
      //Error handling for copy buffer
      if(FillMacd==false || FillSignal==false)
      {
         return "Fill Error";
      }
      //Find required signal lines and normalize to 10 places to prevent rounding errors in crossovers
      double    CurrentMacd   = NormalizeDouble(BufferMacd[0],10);
      double    CurrentSignal = NormalizeDouble(BufferSignal[0],10);
      //A: Macd is above signal line crossover (long) or Macd is below signal line (short)
      if(IndicatorArray[1] == "A")
      {
         if(CurrentMacd > CurrentSignal)
         {
            return   "Long";
         }
         else if(CurrentMacd < CurrentSignal)
         {    
            return   "Short";
         }
         else
         {
            return   "No Trade";
         }
      }
      //B: Macd is above signal line crossover (short) or Macd is below signal line (long)
      else if(IndicatorArray[1] == "B")
      {
         if(CurrentMacd > CurrentSignal)
         {
            return   "Short";
         }
         else if(CurrentMacd < CurrentSignal)
         {       
            return   "Long";
         }
         else
         {
            return   "No Trade";
         }
      }
      //Error handling - if indicator array[1] indicator condition is not found
      else
      {
         return   "Error";
      }
   }

   //Accelerator Oscillator
   //A: AC line moves over with 0 line (long) or AC line moves under 0 line (short)
   //B: AC line moves over with 0 line (short) or AC line moves under 0 line (long)
   if(IndicatorArray[0] == "Ac")
   {
      //Set symbol and indicator buffers
      double    BufferAc[];
      //Define indicator line(s), from not confirmed candle 0, for 2 candles, and store results. NOTE:[current,new]
      bool      FillAc   = CopyBuffer(IndicatorHandle,0,0,2,BufferAc);
      //Error handling for copy buffer
      if(FillAc==false)
      {
         return "Fill Error";
      }
      //Find required signal lines and normalize to 10 places to prevent rounding errors in crossovers
      double    CurrentAc   = NormalizeDouble(BufferAc[1],10);
      //A: AC line crosses over with 0 line (long) or AC line crosses under 0 line (short)
      if(IndicatorArray[1] == "A")
      {
         if(CurrentAc > 0)
         {
            return   "Long";
         }
         else if(CurrentAc < 0)
         {
            return   "Short";
         }
         else
         {
            return   "No Trade";
         }
      }
      //B: AC line crosses over with 0 line (short) or AC line crosses under 0 line (long)
      else if(IndicatorArray[1] == "B")
      {
         if(CurrentAc > 0)
         {
            return   "Short";
         }
         else if(CurrentAc < 0)
         {
            return   "Long";
         }
         else
         {
            return   "No Trade";
         }
      }
      //Error handling - if indicator array[1] indicator condition is not found
      else
      {
         return   "Error";
      }
   }

//---PRICE ACTION INDICATORS
//---OTHER INDICATORS
//---ERROR HANDLING
   //if indicator array[0] indicator is not found
   else
   {
      return   "Error";
   }

}

//+------------------------------------------------------------------+
//| Get Indicator Value                                              |
//+------------------------------------------------------------------+
//Get indicator value from handle and indicator buffer value to be returned
double GetIndicatorValue(int IndicatorHandle, int BufferValue) export
{
   //Set symbol and indicator buffers
   double Buffer[];
   //Define indicator line(s), from not confirmed candle 0, for 2 candles, and store results. NOTE:[current,new]
   bool Fill   = CopyBuffer(IndicatorHandle,BufferValue,0,2,Buffer);
   if(Fill==false)
   {
      return(0);
   }
   //Find value
   double Value = NormalizeDouble(Buffer[0],10);
   //Return value
   return(Value);
}
//+------------------------------------------------------------------+