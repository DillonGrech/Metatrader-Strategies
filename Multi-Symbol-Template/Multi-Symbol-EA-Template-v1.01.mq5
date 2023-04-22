//+------------------------------------------------------------------+
//|                                     Multi-Symbol-EA-Template.mq5 |
//|                                    Copyright 2023, Dillon Grech. |
//|                    YouTube: https://www.youtube.com/@DillonGrech |
//|                           GitHub: https://github.com/DillonGrech |
//|                           Discord: https://discord.gg/xs3KpdUjSu |
//+------------------------------------------------------------------+
//| This template is designed for multi-symbol expert advisors       |
//| within Meta-Trader 5. This type of EA will allow the user to     |
//| trade a portfolio of assets or symbols with one single EA. This  |
//| better simulates real trading conditions allowing for more       |
//| accurate results.                                                |
//| Use this template to populate your own trading strategies, using |
//| indicators and money management conditions.                      |
//| Further information on this template can be found on my YouTube  | 
//| channel.                                                         |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Expert Setup                                                     |
//+------------------------------------------------------------------+
//Property
#property copyright "Copyright 2023, Dillon Grech"
#property version   "1.00"

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
string IndicatorSignal1;
//**Insert indicator handle and variables here**

//Indicator 2 Variables
string IndicatorSignal2;
//**Insert indicator handle and variables here**

//Indicator 3 Variables
string IndicatorSignal3;
//**Insert indicator handle and variables here**



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
   //**Insert indicator handle set up, with multi-symbol functionality here**
   
   //Return successful
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
      
      //Tick Processing
      //**Insert any trade processing conditions (eg. candle open only) here**
      TicksProcessed[SymbolLoop]++; 
      
      //Indicator 1
      //**Insert indicator 1 signal conditions here**
      
      //Indicator 2
      //**Insert indicator 2 signal conditions here**
      
      //Indicator 3
      //**Insert indicator 3 signal conditions here**
      
      //Enter Trades
      if(IndicatorSignal1 == "Long" && IndicatorSignal2 == "Long" && IndicatorSignal3 == "Long")
         ProcessTradeOpen(CurrentSymbol, SymbolLoop, ORDER_TYPE_BUY);
      else if(IndicatorSignal1 == "Short" && IndicatorSignal2 == "Short" && IndicatorSignal3 == "Short")
         ProcessTradeOpen(CurrentSymbol, SymbolLoop, ORDER_TYPE_SELL);
      
      //Update Symbol Metrics
      SymbolMetrics[SymbolLoop] = CurrentSymbol +
                                  " | Ticks Processed: " + IntegerToString(TicksProcessed[SymbolLoop]) +
                                  " | Indicator 1: " + IndicatorSignal1 +
                                  " | Indicator 2: " + IndicatorSignal2 +
                                  " | Indicator 3: " + IndicatorSignal3;
   
      
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
      //**Resize indicator 1 handle here**
      //**Resize indicator 2 handle here**
      //**Resize indicator 3 handle here**

   }

//Release indicator handles from Metatrader cache for multi-symbol EA
void ReleaseIndicatorArrays()
{
   for(int SymbolLoop=0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
      {
         //**Release indicator 1 handle by symbol loop here**
         //**Release indicator 2 handle by symbol loop here**
         //**Release indicator 3 handle by symbol loop here**  
      }
   Print("All Handles released");   
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