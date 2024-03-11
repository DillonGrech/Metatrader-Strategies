//+------------------------------------------------------------------+
//|                                        IndicatorLibrary-v1p2.mq5 |
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
//|                                                    Patch Notes 2 |
//| Completed version for the youtube tutorial.                      |
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
//|   Ema_A_Period - Trigger, Filter - [A,B]                         |
//|                                                                  |
//|---MOMENTUM INDICATORS                                            |
//|                                                                  |
//|---VOLATILITY INDICATORS                                          |
//|                                                                  |
//|---OSCILLATOR INDICATORS                                          |
//|   Macd_A_Fast_Slow_Signal - Trigger - [A,B]                      |
//|                                                                  |
//|---PRICE ACTION INDICATORS                                        |
//|                                                                  |
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
   //Ema Handles
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

//---MOMENTUM INDICATORS
//---VOLATILITY INDICATORS
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

//---PRICE ACTION INDICATORS
//---OTHER INDICATORS
//---ERROR HANDLING
   else
   {
      Print("No Handle created for " + Indicator + " for " + CurrentSymbol + ". Handle ID ",Handle,".");
      return 0;
   }
}
//+------------------------------------------------------------------+
//| Set up Indicator Trigger Signals                                 |
//+------------------------------------------------------------------+
string GetIndicatorTrigger(string Indicator, int IndicatorHandle, string CurrentSymbol, ENUM_TIMEFRAMES CurrentPeriod) export
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

//---CHECK FOR NA INDICATOR
   //If Na Indicator
   if(IndicatorArray[0] == "Na")
   {
      //Return value
      return "NA";   
   }
//---TREND FOLLOWING INDICATORS
   //Moving average indicator triggers
   //A: Price crosses above moving average (long) or price crosses below moving average (short)
   //B: Price crosses above moving average (short) or price crosses below moving average (long)
   if(IndicatorArray[0] == "Ema")
   {
      //Set symbol and indicator buffers
      double BufferMA[];
      //Define indicator line(s), from not confirmed candle 0, for 3 candles, and store results. NOTE:[prior,current,new]
      bool   FillMA   = CopyBuffer(IndicatorHandle,0,0,3,BufferMA);
      //Error handling for copy buffer
      if(FillMA==false)
      {
         return "Fill Error";
      }
      //Find required signal lines and normalize to 10 places to prevent rounding errors in crossovers
      double CurrentMA    = NormalizeDouble(BufferMA[1],10);
      double CurrentPrice = NormalizeDouble(iClose(CurrentSymbol,CurrentPeriod,1), 10); //1 is current confirmed candle closed (0 is new candle)
      double PriorMA      = NormalizeDouble(BufferMA[0],10);
      double PriorPrice   = NormalizeDouble(iClose(CurrentSymbol,CurrentPeriod,2), 10); //2 is prior candle closed
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
      //B: Price crosses above moving average (short) or price crosses below moving average (long)
      if(IndicatorArray[1] == "B")
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
//---OSCILLATOR INDICATORS
   //Macd
   //A: Macd and signal line crossover and cross occurs below 0 line (long) or Macd and signal line crossunder and cross occurs above 0 line (short)
   //B: Macd and signal line crossover and cross occurs below 0 line (short) or Macd and signal line crossunder and cross occurs above 0 line (long)
   if(IndicatorArray[0] == "Macd")
   {
      //Set symbol and indicator buffers
      double BufferMacd[];
      double BufferSignal[];
      //Define indicator line(s), from not confirmed candle 0, for 3 candles, and store results. NOTE:[prior,current,new]
      bool   FillMacd   = CopyBuffer(IndicatorHandle,0,0,3,BufferMacd);
      bool   FillSignal = CopyBuffer(IndicatorHandle,1,0,3,BufferSignal);  
      //Error handling for copy buffer
      if(FillMacd==false || FillSignal==false)
      {
         return "Fill Error";
      } 
      //Find required signal lines and normalize to 10 places to prevent rounding errors in crossovers
      double CurrentMacd   = NormalizeDouble(BufferMacd[1],10);
      double CurrentSignal = NormalizeDouble(BufferSignal[1],10);
      double PriorMacd     = NormalizeDouble(BufferMacd[0],10);
      double PriorSignal   = NormalizeDouble(BufferSignal[0],10); 
      
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
      if(IndicatorArray[1] == "B")
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

//---PRICE ACTION INDICATORS
//---OTHER INDICATORS
//---ERROR HANDLING
   //Error handling - if indicator array[0] indicator condition is not found
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
   //Declare variables
   int    Handle = 0;          //stores indicator handle
   string IndicatorArray[];    //stores indicator array and parameters
   int    NumberOfParameters;  //stores number of indicator parameters, including indicator name
   string IndicatorDetails = "";   
   //Get indicator name and parametres
   NumberOfParameters = StringSplit(Indicator, '_', IndicatorArray); //Split indicator and parametres
   ArrayResize(IndicatorArray,NumberOfParameters);                   //Resize array to number of paramentres  

//---CHECK FOR NA INDICATOR
   //If Na Indicator
   if(IndicatorArray[0] == "Na")
   {
      //Return value
      return "NA";   
   } 
   
//---TREND FOLLOWING INDICATORS
   //Moving average indicator triggers
   //A: Price is above moving average (long) or price is below moving average (short)
   //B: Price is above moving average (short) or price is below moving average (long)
   if(IndicatorArray[0] == "Ema")
   {
      //Set symbol and indicator buffers
      double BufferMA[];
      //Define indicator line(s), from not confirmed candle 0, for 2 candles, and store results. NOTE:[current,new]
      bool   FillMA   = CopyBuffer(IndicatorHandle,0,0,2,BufferMA);
      //Error handling for copy buffer
      if(FillMA==false)
      {
         return "Fill Error";
      }
      //Find required signal lines and normalize to 10 places to prevent rounding errors in crossovers
      double CurrentMA    = NormalizeDouble(BufferMA[1],10);
      double CurrentPrice = NormalizeDouble(iClose(CurrentSymbol,CurrentPeriod,1), 10); //1 is current confirmed candle closed (0 is new candle)
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
      if(IndicatorArray[1] == "B")
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
//---VOLATILITY INDICATORS
//---OSCILLATOR INDICATORS
//---PRICE ACTION INDICATORS
//---OTHER INDICATORS
//---ERROR HANDLING
   //Error handling - if indicator array[0] indicator condition is not found
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
   return(0.0);
}
//+------------------------------------------------------------------+