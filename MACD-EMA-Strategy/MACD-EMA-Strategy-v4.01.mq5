//+------------------------------------------------------------------+
//|                                      MACD-EMA-Strategy-v4.01.mq5 |
//|                                                     Dillon Grech |
//|                                             https://www.mql5.com |
//|                            https://www.youtube.com/c/DillonGrech |
//|            https://github.com/Dillon-Grech/Metatrader-Strategies |
//+------------------------------------------------------------------+
//|                                                  Version Notes 4 |
//| Expert Advisor opens and closes trades based off MACD signal,    |
//| MACD cross location and price to EMA location. Lot size and      |
//| TP/SL is same as per version 3.                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//|                                                    Patch Notes 1 |
//| NA                                                               |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dillon Grech"
#property link      "https://www.mql5.com"
#property version   "4.01"

//Include Functions
#include <Trade\Trade.mqh> //Include MQL trade object functions
CTrade   *Trade;           //Declaire Trade as pointer to CTrade class

//Setup Variables
input int                InpMagicNumber  = 2000001;     //Unique identifier for this expert advisor
input string             InpTradeComment = __FILE__;    //Optional comment for trades
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE; //Applied price for indicators

//Global Variables
string IndicatorMetrics    = "";
int    TicksReceivedCount  = 0; //Counts the number of ticks from oninit function
int    TicksProcessedCount = 0; //Counts the number of ticks procedded from oninit function based off candle opens only
static datetime TimeLastTickProcessed; //Stores the last time a tick was processed based off candle opens only

//MACD Handle and Variables
int   HandleMacd;
int   MacdFast   = 12;
int   MacdSlow   = 26;
int   MacdSignal = 9;

//EMA Handle and Variables
int   HandleEma;
int   EmaPeriod  = 100;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //Declare magic number for all trades
   Trade = new CTrade();
   Trade.SetExpertMagicNumber(InpMagicNumber);
   
   //Set up handle for macd indicator on the oninit
   HandleMacd = iMACD(Symbol(),Period(),MacdFast,MacdSlow,MacdSignal,InpAppliedPrice); 
   Print("Handle for Macd /", Symbol()," / ", EnumToString(Period()),"successfully created");
   
   //Set up handle for EMA indicator on the oninit
   HandleEma = iMA(Symbol(),Period(),EmaPeriod,0,MODE_EMA,InpAppliedPrice);
   Print("Handle for EMA /", Symbol()," / ", EnumToString(Period()),"successfully created");
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //Remove indicator handle from Metatrader Cache
   IndicatorRelease(HandleMacd);
   IndicatorRelease(HandleEma);
   Print("Handle released");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //Counts the number of ticks received  
   TicksReceivedCount++; 
   
   //Checks for new candle
   bool IsNewCandle = false;
   if(TimeLastTickProcessed != iTime(Symbol(),Period(),0))
   {
      IsNewCandle = true;
      TimeLastTickProcessed=iTime(Symbol(),Period(),0);
   }
   
   //If there is a new candle, process any trades
   if(IsNewCandle == true)
   {
      //Counts the number of ticks processed
      TicksProcessedCount++;
      IndicatorMetrics ="";  //Initiate String for indicatorMetrics Variable. This will reset variable each time OnTick function runs.
      StringConcatenate(IndicatorMetrics,Symbol()," | Last Processed: ",TimeLastTickProcessed);

      //Strategy Trigger - MACD
      string OpenSignalMacd = GetMacdOpenSignal(); //Variable will return Long or Short Bias only on a trigger/cross event 
      StringConcatenate(IndicatorMetrics, IndicatorMetrics, " | MACD Bias: ", OpenSignalMacd); //Concatenate indicator values to output comment for user   
      
      //Strategy Filter - EMA
      string OpenSignalEma = GetEmaOpenSignal(); //Variable will return long or short bias if close is above or below EMA.
      StringConcatenate(IndicatorMetrics, IndicatorMetrics, " | EMA Bias: ", OpenSignalEma); //Concatenate indicator values to output comment for user
      
      //Enter Trades
      if(OpenSignalMacd == "Long" && OpenSignalEma == "Long")
         ProcessTradeOpen(ORDER_TYPE_BUY); 
      else if(OpenSignalMacd == "Short" && OpenSignalEma == "Short")
         ProcessTradeOpen(ORDER_TYPE_SELL); 
   }       
      
   //Comment for user
   Comment("\n\rExpert: ", InpMagicNumber, "\n\r",
         "MT5 Server Time: ", TimeCurrent(), "\n\r",
         "Ticks Received: ", TicksReceivedCount,"\n\r",
         "Ticks Processed: ", TicksProcessedCount,"\n\r\n\r",
         "Symbols Traded: \n\r", 
         IndicatorMetrics);         
  }
//+------------------------------------------------------------------+
//| Custom function                                                  |
//+------------------------------------------------------------------+
//Custom Function to get MACD signals
string GetMacdOpenSignal()
{
   //Set symbol string and indicator buffers
   string    CurrentSymbol    = Symbol();
   const int StartCandle      = 0;
   const int RequiredCandles  = 3; //How many candles are required to be stored in Expert 
   
   //Indicator Variables and Buffers
   const int IndexMacd        = 0; // Macd Line
   const int IndexSignal      = 1; // Signal Line
   double    BufferMacd[];         // [prior,current confirmed,not confirmed]    
   double    BufferSignal[];       // [prior,current confirmed,not confirmed]       
   
   //Define Macd and Signal lines, from not confirmed candle 0, for 3 candles, and store results 
   bool      FillMacd   = CopyBuffer(HandleMacd,IndexMacd,  StartCandle,RequiredCandles,BufferMacd);
   bool      FillSignal = CopyBuffer(HandleMacd,IndexSignal,StartCandle,RequiredCandles,BufferSignal);
   if(FillMacd==false || FillSignal==false) 
      return "Buffer Not Full MACD"; // If buffers are not completely filled, return to end onTick

   //Find required Macd signal lines and normalize to 10 places to prevent rounding errors in crossovers
   double    CurrentMacd   = NormalizeDouble(BufferMacd[1],10);
   double    CurrentSignal = NormalizeDouble(BufferSignal[1],10);
   double    PriorMacd     = NormalizeDouble(BufferMacd[0],10);
   double    PriorSignal   = NormalizeDouble(BufferSignal[0],10);
   
   //Submit Macd Long and Short Trades
   //If MACD cross over Signal Line and cross occurs below 0 line - Long
   if(PriorMacd <= PriorSignal && CurrentMacd > CurrentSignal && CurrentMacd < 0 && CurrentSignal < 0)
      return   "Long";
   //If MACD cross under Signal Line and cross occurs above 0 line- Short
   else if(PriorMacd >= PriorSignal && CurrentMacd < CurrentSignal && CurrentMacd > 0 && CurrentSignal > 0)
      return   "Short";
   else
   //If no cross of MACD and Signal Line - No Trades
      return   "No Trade";
}

//Custom function that returns long and short signals based off EMA and Close price.
string GetEmaOpenSignal()
{
   //Set symbol string and indicator buffers
   string    CurrentSymbol    = Symbol();
   const int StartCandle      = 0;
   const int RequiredCandles  = 2; //How many candles are required to be stored in Expert 
   
   //Indicator Variables and Buffers
   const int IndexEma         = 0; //EMA Line
   double    BufferEma [];         //[current confirmed,not confirmed]    

   //Define EMA, from not confirmed candle 0, for 2 candles, and store results 
   bool      FillEma   = CopyBuffer(HandleEma,IndexEma,  StartCandle,RequiredCandles,BufferEma);
   if(FillEma==false) 
      return "Buffer Not Full Ema"; //If buffers are not completely filled, return to end onTick

   //Gets the current confirmed EMA value
   double CurrentEma   = NormalizeDouble(BufferEma[1],10);
   double CurrentClose = NormalizeDouble(iClose(Symbol(),Period(),0), 10);

   //Submit Ema Long and Short Trades
   if(CurrentClose > CurrentEma)
      return("Long");
   else if (CurrentClose < CurrentEma)
      return("Short");
   else
      return("No Trade");
}

//Processes open trades for buy and sell
bool ProcessTradeOpen(ENUM_ORDER_TYPE OrderType)
{
   //Set symbol string and variables
   string CurrentSymbol   = Symbol();  
   double Price           = 0;
   double StopLossPrice   = 0;
   double TakeProfitPrice = 0;

   //Get price, stop loss, take profit for open and close orders
   if(OrderType == ORDER_TYPE_BUY)
   {
      Price           = NormalizeDouble(SymbolInfoDouble(CurrentSymbol, SYMBOL_ASK), Digits());
      StopLossPrice   = NormalizeDouble(Price - 0.01, Digits());
      TakeProfitPrice = NormalizeDouble(Price + 0.02, Digits());
   }
   else if(OrderType == ORDER_TYPE_SELL)
   {
      Price           = NormalizeDouble(SymbolInfoDouble(CurrentSymbol, SYMBOL_BID), Digits());
      StopLossPrice   = NormalizeDouble(Price + 0.01, Digits());
      TakeProfitPrice = NormalizeDouble(Price - 0.02, Digits());  
   }
   
   //Get lot size
   double LotSize = 1;
   
   //Exit any trades that are currently open. Enter new trade.
   Trade.PositionClose(CurrentSymbol);
   Trade.PositionOpen(CurrentSymbol,OrderType,LotSize,Price,StopLossPrice,TakeProfitPrice,InpTradeComment);
   
   //Add in any error handling
   Print("Trade Processed For ", CurrentSymbol," OrderType ",OrderType, " Lot Size ", LotSize);
   return(true);
}
//+------------------------------------------------------------------+