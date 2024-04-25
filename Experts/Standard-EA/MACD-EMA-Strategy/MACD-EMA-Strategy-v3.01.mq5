//+------------------------------------------------------------------+
//|                                      MACD-EMA-Strategy-v3.01.mq5 |
//|                                                     Dillon Grech |
//|                                             https://www.mql5.com |
//|                            https://www.youtube.com/c/DillonGrech |
//|            https://github.com/Dillon-Grech/Metatrader-Strategies |
//+------------------------------------------------------------------+
//|                                                  Version Notes 3 |
//| Expert Advisor adds in function to check whether a new candle    |
//| has been created. This function is useful if the strategy only   |
//| enters or exits trades after the current candle has closed and   |
//| there is confirmation to enter or exit a trade.                  |
//+------------------------------------------------------------------+
//|                                                    Patch Notes 1 |
//| NA                                                               |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dillon Grech"
#property link      "https://www.mql5.com"
#property version   "3.01"

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

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //Declare magic number for all trades
   Trade = new CTrade();
   Trade.SetExpertMagicNumber(InpMagicNumber);
   
   //Set up handle for macd indicator on the oninit
   HandleMacd =  iMACD(Symbol(),Period(),MacdFast,MacdSlow,MacdSignal,InpAppliedPrice); 
   Print("Handle for Macd /", Symbol()," / ", EnumToString(Period()),"successfully created");
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Remove indicator handle from Metatrader Cache
   IndicatorRelease(HandleMacd);
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
   //If MACD cross over Signal Line - Long
   if(PriorMacd <= PriorSignal && CurrentMacd > CurrentSignal)
      return   "Long";
   //If MACD cross under Signal Line - Short
   else if(PriorMacd >= PriorSignal && CurrentMacd < CurrentSignal)
      return   "Short";
   else
   //If no cross of MACD and Signal Line - No Trades
      return   "No Trade";
}
//+------------------------------------------------------------------+