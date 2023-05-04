//+------------------------------------------------------------------+
//|                                  Multi-Symbol-MACD-EMA-v1.01.mq5 |
//|                                    Copyright 2023, Dillon Grech. |
//|                                             https://www.mql5.com |
//|                   YouTube: https://www.youtube.com/c/DillonGrech |
//|                           GitHub: https://github.com/DillonGrech |
//|                           Discord: https://discord.gg/xs3KpdUjSu |
//+------------------------------------------------------------------+
//|                                                  Version Notes 1 |
//| This file uses multi-symbol functionality to create an EA that   |
//| trades trades 28 currencies pairs. This utilises the multi-      |
//| symbol template on my GitHub. This should be taken as an example |
//| only and should not be traded live.                              |
//+------------------------------------------------------------------+
//|                                                    Patch Notes 1 |
//| This file was coded on my youtube channel and can be viewed at:  |
//| https://www.youtube.com/watch?v=Ecoj_nJfgDM                      |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//|                                              Strategy Conditions |
//| Long & short trades, Macd cross trigger with consideration to    |
//| cross location, EMA filter, constant position sizing, static     |
//| SL/TP.                                                           |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright 2023, Dillon Grech"
#property version   "1.01"

//+------------------------------------------------------------------+
//| Expert Setup                                                     |
//+------------------------------------------------------------------+
//Libraries and Setup
#include  <Trade\Trade.mqh> //Include MQL trade object functions
CTrade    *Trade;           //Declaire Trade as pointer to CTrade class
input int MagicNumber = 1;  //Unique Identifier

//Multi-Symbol EA Variables
enum   MULTISYMBOL {Current, All}; 
input  MULTISYMBOL InputMultiSymbol = Current;
string AllTradableSymbols   = "AUDJPY|CADJPY|CHFJPY|EURJPY|GBPJPY|NZDJPY|USDJPY|AUDCHF|CADCHF|EURCHF|GBPCHF|NZDCHF|USDCHF|AUDCAD|EURCAD|GBPCAD|NZDCAD|USDCAD|AUDUSD|EURUSD|GBPUSD|NZDUSD|AUDNZD|EURNZD|GBPNZD|GBPAUD|EURAUD|EURGBP";
int    NumberOfTradeableSymbols;
string SymbolArray[];

//Expert Core Arrays
string          SymbolMetrics[];
int             TicksProcessed[];
static datetime TimeLastTickProcessed[];

//Expert Variables
string ExpertComments = "";
int    TicksReceived  =  0;

//Indicator 1 Variables
string    IndicatorSignal1;
int       MacdHandle[];
input int MacdFast   = 12;
input int MacdSlow   = 26;
input int MacdSignal = 9;

//Indicator 2 Variables
string    IndicatorSignal2;
int       EmaHandle[];
input int EmaPeriod = 200;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //Declare magic number for all trades
   Trade = new CTrade();
   Trade.SetExpertMagicNumber(MagicNumber);  
   
   //Set up multi-symbol EA Tradable Symbols
   if(InputMultiSymbol == Current)
   {
      NumberOfTradeableSymbols = 1;
      ArrayResize(SymbolArray,NumberOfTradeableSymbols);
      SymbolArray[0] = Symbol();
      Print("EA will process ", NumberOfTradeableSymbols, " Symbol: ", SymbolArray[0]);
   } 
   else
   {
      NumberOfTradeableSymbols = StringSplit(AllTradableSymbols, '|', SymbolArray);
      ArrayResize(SymbolArray,NumberOfTradeableSymbols);
      Print("EA will process ", NumberOfTradeableSymbols, " Symbols: ", AllTradableSymbols);
   }
   
   //Resize core arrays for Multi-Symbol EA
   ResizeCoreArrays();   
   
   //Resize indicator arrays for Multi-Symbol EA
   ResizeIndicatorArrays();
   
   //Set Up Multi-Symbol Handles for Indicators
   if(!MacdHandleMultiSymbol() || !EmaHandleMultiSymbol())
       return(INIT_FAILED);
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //Release Indicator Arrays
   ReleaseIndicatorArrays();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //Declare comment variables
   ExpertComments="";
   TicksReceived++;
  
   //Run multi-symbol loop   
   for(int SymbolLoop=0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
   {
      //Store Current Symbol
      string CurrentSymbol = SymbolArray[SymbolLoop];

      //Check for new candle based of opening time of bar
      bool IsNewCandle = false;   
      if(TimeLastTickProcessed[SymbolLoop] != iTime(CurrentSymbol,Period(),0))
      {
         IsNewCandle   = true;
         TimeLastTickProcessed[SymbolLoop]  = iTime(CurrentSymbol,Period(),0);      
      } 
      //Process strategy only if is new candle
      if(IsNewCandle == true)
      {
         TicksProcessed[SymbolLoop]++; 

         //Indicator 1 - Trigger - MACD
         IndicatorSignal1 = GetMacdSignalOpen(SymbolLoop);
         
         //Indicator 2 - Filter - EMA
         IndicatorSignal2 = GetEmaOpenSignal(SymbolLoop);

         //Enter Trades
         if(IndicatorSignal1 == "Long" && IndicatorSignal2 == "Long")
            ProcessTradeOpen(CurrentSymbol, SymbolLoop, ORDER_TYPE_BUY);
         else if(IndicatorSignal1 == "Short" && IndicatorSignal2 == "Short")
            ProcessTradeOpen(CurrentSymbol, SymbolLoop, ORDER_TYPE_SELL);
         
         //Update Symbol Metrics
         SymbolMetrics[SymbolLoop] = CurrentSymbol + 
                                     " | Ticks Processed: " + IntegerToString(TicksProcessed[SymbolLoop])+
                                     " | Last Candle: " + TimeToString(TimeLastTickProcessed[SymbolLoop])+
                                     " | Indicator 1: " + IndicatorSignal1+
                                     " | Indicator 2: " + IndicatorSignal2;
      }
      
      //Update expert comments for each symbol
      ExpertComments = ExpertComments + SymbolMetrics[SymbolLoop] + "\n\r";
   }
   
   //Comment expert behaviour
   Comment("\n\rExpert: ", MagicNumber, "\n\r",
            "MT5 Server Time: ", TimeCurrent(), "\n\r",
            "Ticks Received: ", TicksReceived,"\n\r\n\r",  
            "Symbols Traded:\n\r", 
            ExpertComments
            );
  }
//+------------------------------------------------------------------+
//| Expert custom function                                           |
//+------------------------------------------------------------------+
//Resize Core Arrays for multi-symbol EA
void ResizeCoreArrays()
   {
      ArrayResize(SymbolMetrics,         NumberOfTradeableSymbols);
      ArrayResize(TicksProcessed,        NumberOfTradeableSymbols); 
      ArrayResize(TimeLastTickProcessed, NumberOfTradeableSymbols);
   }

//Resize Indicator for multi-symbol EA
void ResizeIndicatorArrays()
   {
      //Indicator Handle Arrays
      ArrayResize(MacdHandle, NumberOfTradeableSymbols);  
      ArrayResize(EmaHandle,  NumberOfTradeableSymbols);         
   }


//Release indicator handles from Metatrader cache for multi-symbol EA
void ReleaseIndicatorArrays()
{
   for(int SymbolLoop=0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
   {
      IndicatorRelease(MacdHandle[SymbolLoop]);
      IndicatorRelease(EmaHandle[SymbolLoop]);
   }
   Print("Handle released for all symbols");   
}

//Set up Macd Handle for Multi-Symbol EA
bool MacdHandleMultiSymbol()
{
   for(int SymbolLoop=0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
      {
         ResetLastError();
         MacdHandle[SymbolLoop] = iMACD(SymbolArray[SymbolLoop],Period(),MacdFast,MacdSlow,MacdSignal,PRICE_CLOSE); 
         if(MacdHandle[SymbolLoop] == INVALID_HANDLE)
         {
            string OutputMessage = "";
            if(GetLastError() == 4302)
               OutputMessage = ". Symbol needs to be added to the Market Watch";
            else  
               StringConcatenate(OutputMessage, ". Error Code ", GetLastError()); 
            MessageBox("Failed to create handle for Macd indicator for " + SymbolArray[SymbolLoop] + OutputMessage);
            return false;
         }
      }
   Print("Handle for Macd for all Symbols successfully created"); 
   return true;     
}

//Custom Function - Get Macd Open Signals
string GetMacdSignalOpen(int SymbolLoop)
{
   //Set symbol and indicator buffers
   const int StartCandle     = 0;
   const int RequiredCandles = 3; //How many candles are required to be stored in Expert. NOTE:[not confirmed,current confirmed, prior]
   const int IndexMacd       = 0; //Macd Line
   const int IndexSignal     = 1; //Signal Line
   double    BufferMacd[];         
   double    BufferSignal[];          
   
   //Define Macd and Signal lines, from not confirmed candle 0, for 3 candles, and store results. NOTE:[prior,current confirmed,not confirmed]
   bool      FillMacd   = CopyBuffer(MacdHandle[SymbolLoop],IndexMacd,  StartCandle,RequiredCandles,BufferMacd);
   bool      FillSignal = CopyBuffer(MacdHandle[SymbolLoop],IndexSignal,StartCandle,RequiredCandles,BufferSignal);
   if(FillMacd==false || FillSignal==false) return "Fill Error"; //If buffers are not completely filled, return to end onTick
   
   //Find required Macd signal lines and normalize to 10 places to prevent rounding errors in crossovers
   double    CurrentMacd   = NormalizeDouble(BufferMacd[1],10);
   double    CurrentSignal = NormalizeDouble(BufferSignal[1],10);
   double    PriorMacd     = NormalizeDouble(BufferMacd[0],10);
   double    PriorSignal   = NormalizeDouble(BufferSignal[0],10);

   //Return Macd Long and Short Signal
   if(PriorMacd <= PriorSignal && CurrentMacd > CurrentSignal && CurrentMacd < 0 && CurrentSignal < 0)
      return   "Long";
   else if (PriorMacd >= PriorSignal && CurrentMacd < CurrentSignal && CurrentMacd > 0 && CurrentSignal > 0)
      return   "Short";
   else
      return   "No Trade";   
}

//Set up Ema Handle for Multi-Symbol EA
bool EmaHandleMultiSymbol()
{
   for(int SymbolLoop=0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
   {
      ResetLastError();
      EmaHandle[SymbolLoop] =  iMA(SymbolArray[SymbolLoop],Period(),EmaPeriod,0,MODE_EMA,PRICE_CLOSE); 
      if(EmaHandle[SymbolLoop] == INVALID_HANDLE)
      {
         string OutputMessage = "";
         if(GetLastError() == 4302)
            OutputMessage = ". Symbol needs to be added to the Market Watch";
         else
            StringConcatenate(OutputMessage, ". Error Code ", GetLastError());
         MessageBox("Failed to create handle for Ema indicator for " + SymbolArray[SymbolLoop] + OutputMessage);
         return false;
      }
   }
   Print("Handle for Ema for all Symbols successfully created");
   return true;
}

//Custom Function - Get EMA Signals based off EMA line and price close - Filter
string GetEmaOpenSignal(int SymbolLoop)
{
   //Set symbol string and indicator buffers
   const int StartCandle     = 0;
   const int RequiredCandles = 2; //How many candles are required to be stored in Expert. NOTE:[not confirmed,current confirmed]
   const int IndexEma        = 0; //Ema Line
   double    BufferEma[];         //Capture 2 candles for EMA [0,1]

   //Populate buffers for EMA line
   bool FillEma   = CopyBuffer(EmaHandle[SymbolLoop],IndexEma,StartCandle,RequiredCandles,BufferEma);
   if(FillEma==false)return("FILL_ERROR");

   //Find required EMA signal lines
   double CurrentEma = NormalizeDouble(BufferEma[1],10);
   
   //Get last confirmed candle price. NOTE:Use last value as this is when the candle is confirmed. Ask/bid gives some errors.
   double CurrentClose = NormalizeDouble(iClose(SymbolArray[SymbolLoop],Period(),0), 10);

   //Submit Ema Long and Short Trades
   if(CurrentClose > CurrentEma)
      return("Long");
   else if (CurrentClose < CurrentEma)
      return("Short");
   else
      return("No Trade");
}

//Process trades to enter buy or sell
bool ProcessTradeOpen(string CurrentSymbol, int SymbolLoop, ENUM_ORDER_TYPE OrderType)
{
   //Set symbol string and variables 
   int    SymbolDigits    = (int) SymbolInfoInteger(CurrentSymbol,SYMBOL_DIGITS); //note - typecast required to remove error
   double Price           = 0.0;
   double StopLossPrice   = 0.0;
   double StopLossSize    = 0.01;
   double TakeProfitPrice = 0.0;
   double TakeProfitSize  = 0.02;

   //Open buy or sell orders
   if(OrderType == ORDER_TYPE_BUY)
   {
      Price           = NormalizeDouble(SymbolInfoDouble(CurrentSymbol, SYMBOL_ASK), SymbolDigits);
      StopLossPrice   = NormalizeDouble(Price - StopLossSize, SymbolDigits);
      TakeProfitPrice = NormalizeDouble(Price + TakeProfitSize, SymbolDigits);
   } 
   else if(OrderType == ORDER_TYPE_SELL)
   {
       Price           = NormalizeDouble(SymbolInfoDouble(CurrentSymbol, SYMBOL_BID), SymbolDigits);
       StopLossPrice   = NormalizeDouble(Price + StopLossSize, SymbolDigits);
       TakeProfitPrice = NormalizeDouble(Price - TakeProfitSize, SymbolDigits);
   }
   
   //Get lot size
   double LotSize = 0.01;
   
   //Close any current positions and open new position
   Trade.PositionClose(CurrentSymbol);
   Trade.SetExpertMagicNumber(MagicNumber);
   Trade.PositionOpen(CurrentSymbol,OrderType,LotSize,Price,StopLossPrice,TakeProfitPrice,__FILE__);

   //Print successful
   Print("Trade Processed For ", CurrentSymbol," OrderType ",OrderType, " Lot Size ", LotSize);
   
   return(true);
}
//+------------------------------------------------------------------+