///+-----------------------------------------------------------------+
//|                                          EA-Template-4-v1.01.mq5 |
//|                                     Copyright 2024, Dillon Grech |
//|                   YouTube: https://www.youtube.com/c/DillonGrech |
//|                           GitHub: https://github.com/DillonGrech |
//|                           Discord: https://discord.gg/xs3KpdUjSu |
//+------------------------------------------------------------------+
//|                                                  Version Notes 1 |
//| This file uses multi-symbol functionality. This EA incorporates  |
//| trigger and filter indicators to find the best combination of    |
//| indicators. Indicator signals are taked from Indicator Library.  |
//| EA will use enums so user can select the indicator and params.   |
//| Risk management will be taked from Risk Library.                 |
//+------------------------------------------------------------------+
//|                                                    Patch Notes 1 |
//| Completed version for the youtube tutorial.                      |
//| Use this file as a template as per the strategy conditions below.|
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//|                                              Strategy Conditions |
//| Long & short trades, 1x EntryTrigger, 2x Filter, 1x Exit Trigger |
//| Exit trigger is also filter indicator 1.                         |
//| Stop loss and take profit uses ATR multiple. ATR TSL is also     |
//| used. Position size is calculated using a percentage of account. |
//| User can select either fixed or compounding position sizing.     |
//+------------------------------------------------------------------+

#property copyright "Copyright 2024, Dillon Grech"
#property version   "1.01"

//+------------------------------------------------------------------+
//| Libraries                                                        |
//+------------------------------------------------------------------+
#import "IndicatorLibrary.ex5"
   int    GetIndicatorHandle(string Indicator, string CurrentSymbol, ENUM_TIMEFRAMES CurrentPeriod);
   string GetIndicatorTrigger(string Indicator, int IndicatorHandle, string CurrentSymbol, ENUM_TIMEFRAMES CurrentPeriod);
   string GetIndicatorFilter(string Indicator, int IndicatorHandle, string CurrentSymbol, ENUM_TIMEFRAMES CurrentPeriod);
   double GetIndicatorValue(int IndicatorHandle, int BufferValue);
#import

#import   "RiskLibrary.ex5"
   void   InitiateTrade(int MagicNumber);
   double GetPrice(string CurrentSymbol, ENUM_ORDER_TYPE OrderType);
   double GetRiskAmount(string RiskMethod,double RiskPercent, double StartingEquity);
   //double GetRiskAmount(string CurrentSymbol, double EntryPrice,  double StopLossPrice, double RiskLots);
   double GetRiskLots(string CurrentSymbol, double EntryPrice, double StopLossPrice, double RiskAmount);
   //double GetTakeProfit(string CurrentSymbol, ENUM_ORDER_TYPE OrderType, double EntryPrice, double StopLossPrice, double RiskReward);
   //double GetStopLoss(string CurrentSymbol, double EntryPrice, ENUM_ORDER_TYPE OrderType, double RiskLots, double RiskAmount);
   ulong  ProcessTradeOpen(string CurrentSymbol, ENUM_ORDER_TYPE OrderType, int MagicNumber, double RiskLots, double EntryPrice, double StopLossPrice, double TakeProfitPrice);
   void   ProcessTradeClose(string CurrentSymbol, ulong Ticket);
   void   ProcessTradeTsl(string CurrentSymbol, ulong Ticket, double NewStopLossPrice);
#import

//+------------------------------------------------------------------+
//| Expert Setup                                                     |
//+------------------------------------------------------------------+
input group "Expert Setup"

//Multi-Symbol EA Variables - User can specify "Current" within input to trade current symbol only
input string AllTradableSymbols = "AUDJPY|CHFJPY|EURJPY|GBPJPY|USDJPY|AUDCHF|CADCHF|EURCHF|GBPCHF|USDCHF|AUDCAD|USDCAD|AUDUSD|EURUSD|GBPUSD|NZDUSD|AUDNZD|EURGBP";
int    NumberOfTradeableSymbols;
string SymbolArray[];

//Expert Core Arrays
string          SymbolMetrics[];
ulong           TicksProcessed[];
static datetime TimeLastTickProcessed[];
ulong           TicketNumber[];

//Expert Variables
string ExpertComments = "";
int    TicksReceived  =  0;
//+------------------------------------------------------------------+
//| Risk Inputs                                                      |
//+------------------------------------------------------------------+
input group "Risk Inputs"

ENUM_ORDER_TYPE OrderType;
input int MagicNumber  = 1;
double StartingEquity  = 0.0;
double EntryPrice      = 0.0;
double StopLossPrice   = 0.0;
double TakeProfitPrice = 0.0;
double RiskAmount      = 0.0;
double RiskLots        = 0.0;
enum   RISKMETHOD 
{
    Fixed, Compounding
};
input RISKMETHOD RiskMethod;
input double RiskPercent = 0.01;
//input double RiskReward  = 2.0;
input double     TakeProfitAtrMultiple = 2.0;
input double     StopLossAtrMultiple = 1.0;
string IndicatorAtr = "Atr_A_14";
double IndicatorValueAtr;
int    IndicatorHandleAtr[];
input bool IsTsl = true; //Use Trailing Stop Loss?

//+------------------------------------------------------------------+
//| Indicator String Setup                                           |
//+------------------------------------------------------------------+
input group "Indicator Select"

//Indicator Entry 1 String
enum   INDICATORSE1 
{
   Macd_A_12_26_9,Macd_A_5_35_5,Macd_A_8_17_9,Macd_A_10_25_5,Macd_A_13_21_8,Macd_A_15_30_8
};
input INDICATORSE1 InputEnumE1;

//Indicator Filter 1 String
enum   INDICATORSF1 
{
   Ema_A_10,Ema_A_20,Ema_A_30,Ema_A_50,Ema_A_100,Ema_A_150,Ema_A_200,Ema_A_250
   ,Sma_A_10,Sma_A_20,Sma_A_30,Sma_A_50,Sma_A_100,Sma_A_150,Sma_A_200,Sma_A_250
   ,Smma_A_10,Smma_A_20,Smma_A_30,Smma_A_50,Smma_A_100,Smma_A_150,Smma_A_200,Smma_A_250
   ,Lwma_A_10,Lwma_A_20,Lwma_A_30,Lwma_A_50,Lwma_A_100,Lwma_A_150,Lwma_A_200,Lwma_A_250
   ,Frama_A_10,Frama_A_20,Frama_A_30,Frama_A_50,Frama_A_100,Frama_A_150,Frama_A_200,Frama_A_250
};
input INDICATORSF1 InputEnumF1;

//Indicator Filter 2 String
enum   INDICATORSF2 
{
    Na
};
input INDICATORSF2 InputEnumF2;

//+------------------------------------------------------------------+
//| Indicator Setup                                                  |
//+------------------------------------------------------------------+
//Indicator Entry 1 Variables - Entry Trigger
string IndicatorE1 = EnumToString(InputEnumE1);
string IndicatorSignalE1;
int    IndicatorHandleE1[];

//Indicator Filter 1 Variables
string IndicatorF1 = EnumToString(InputEnumF1);
string IndicatorSignalF1;
int    IndicatorHandleF1[];

//Indicator Filter 2 Variables
string IndicatorF2 = EnumToString(InputEnumF2);
string IndicatorSignalF2;
int    IndicatorHandleF2[];

//Indicator Exit 1 Variables - Exit Trigger
string IndicatorX1 = EnumToString(InputEnumF1);
string IndicatorSignalX1;
int    IndicatorHandleX1[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //Store Starting Equity
   StartingEquity = AccountInfoDouble(ACCOUNT_BALANCE);
   
   //Initiate C Trade
   InitiateTrade(MagicNumber);
   
   //Set up multi-symbol EA Tradable Symbols
   InitMultiSymbol();

   //Resize Arrays for Multi-Symbol EA
   ResizeCoreArrays();   
   
   //Resize Indicator Arrays for Multi-Symbol EA
   ResizeIndicatorArrays();

   //Initiate indicator handles for multi-symbol
   if(!InitIndicatorHanldes())
       return(INIT_FAILED);
      
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //Release Indicator Arrays
   ReleaseIndicatorHandles();
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
      //Store symbol vairables
      string CurrentSymbol = SymbolArray[SymbolLoop]; //Get current symbol

      
      //Check for new candle based of opening time of bar 
      if(TimeLastTickProcessed[SymbolLoop] != iTime(CurrentSymbol,Period(),0))
      {
         //Add to tick processed counter and store last tick processed for symbol
         TicksProcessed[SymbolLoop]++; 
         TimeLastTickProcessed[SymbolLoop]  = iTime(CurrentSymbol,Period(),0);      
         
         //Get any open position directions, reset on each run
         string PositionDirection = "NA";                  
         if(PositionSelectByTicket(TicketNumber[SymbolLoop]) == true)
         {
            if (PositionGetInteger(POSITION_TYPE) == 0)
               PositionDirection = "Long";
            else if (PositionGetInteger(POSITION_TYPE) == 1)
               PositionDirection = "Short";
         }
         else
            PositionDirection = "NA";
         
         //Get Indicator Values
         IndicatorValueAtr = GetIndicatorValue(IndicatorHandleAtr[SymbolLoop],0);
           
         //Get Indicator Signals
         IndicatorSignalE1 = GetIndicatorTrigger(IndicatorE1, IndicatorHandleE1[SymbolLoop], CurrentSymbol, Period());
         IndicatorSignalF1 = GetIndicatorFilter(IndicatorF1,  IndicatorHandleF1[SymbolLoop], CurrentSymbol, Period());
         IndicatorSignalF2 = GetIndicatorFilter(IndicatorF2,  IndicatorHandleF2[SymbolLoop], CurrentSymbol, Period());
         IndicatorSignalX1 = GetIndicatorTrigger(IndicatorX1, IndicatorHandleX1[SymbolLoop], CurrentSymbol, Period());
                     
         //Enter Long Trades
         if(
            (PositionDirection == "Short" || PositionDirection == "NA") && //enter if no current trades or short trades
            (IndicatorSignalE1 == "Long"                              ) && //enter on long trigger
            (IndicatorSignalF1 == "Long"  || IndicatorSignalF1 == "NA") && //enter on long filter or no filter indicator is selected
            (IndicatorSignalF2 == "Long"  || IndicatorSignalF2 == "NA")    //enter on long filter or no filter indicator is selected
         )
         {
            OrderType          = ORDER_TYPE_BUY;
            EntryPrice         = GetPrice(CurrentSymbol, OrderType);
            StopLossPrice      = NormalizeDouble(EntryPrice - (IndicatorValueAtr*StopLossAtrMultiple),  (int) SymbolInfoInteger(CurrentSymbol,SYMBOL_DIGITS));
            TakeProfitPrice    = NormalizeDouble(EntryPrice + (IndicatorValueAtr*TakeProfitAtrMultiple), (int) SymbolInfoInteger(CurrentSymbol,SYMBOL_DIGITS));
            RiskAmount         = GetRiskAmount(EnumToString(RiskMethod),RiskPercent,StartingEquity);
            RiskLots           = GetRiskLots(CurrentSymbol,EntryPrice, StopLossPrice, RiskAmount);
            TicketNumber[SymbolLoop]  = ProcessTradeOpen(CurrentSymbol, OrderType, MagicNumber, RiskLots, EntryPrice, StopLossPrice, TakeProfitPrice); //Open positions and store ticket
            PositionDirection         = "Long";                                                                //Store position direction
         }        
         //Enter Short Trades
         else if(
            (PositionDirection == "Long"  || PositionDirection == "NA") && //enter if no current trades or short trades
            (IndicatorSignalE1 == "Short"                             ) && //enter on short trigger
            (IndicatorSignalF1 == "Short" || IndicatorSignalF1 == "NA") && //enter on short filter or no filter indicator is selected
            (IndicatorSignalF2 == "Short" || IndicatorSignalF2 == "NA")    //enter on short filter or no filter indicator is selected
         )
         {
            OrderType          = ORDER_TYPE_SELL;
            EntryPrice         = GetPrice(CurrentSymbol, OrderType);
            StopLossPrice      = NormalizeDouble(EntryPrice + (IndicatorValueAtr*StopLossAtrMultiple),  (int) SymbolInfoInteger(CurrentSymbol,SYMBOL_DIGITS));
            TakeProfitPrice    = NormalizeDouble(EntryPrice - (IndicatorValueAtr*TakeProfitAtrMultiple), (int) SymbolInfoInteger(CurrentSymbol,SYMBOL_DIGITS));
            RiskAmount         = GetRiskAmount(EnumToString(RiskMethod),RiskPercent,StartingEquity);
            RiskLots           = GetRiskLots(CurrentSymbol,EntryPrice, StopLossPrice, RiskAmount);
            TicketNumber[SymbolLoop]  = ProcessTradeOpen(CurrentSymbol, OrderType, MagicNumber, RiskLots, EntryPrice, StopLossPrice, TakeProfitPrice); //Open positions and store ticket
            PositionDirection         = "Short";                                                                //Store position direction
         }     
         //Exit Trades  
         else if(
            (PositionDirection == "Long"  && IndicatorSignalX1 == "Short") || //exit long trades on exit indicator short signal
            (PositionDirection == "Short" && IndicatorSignalX1 == "Long")     //exit short trades on exit indicator long signal
         )
         {   
            ProcessTradeClose(CurrentSymbol,TicketNumber[SymbolLoop]);
         }    
         //Modify Trades Trades  
         else if(
            IsTsl == true &&
            PositionDirection == "Long"
         )
         {
            OrderType               = ORDER_TYPE_BUY;  
            double Price            = GetPrice(CurrentSymbol, OrderType);
            double NewStopLossPrice = NormalizeDouble(Price - (IndicatorValueAtr*StopLossAtrMultiple),(int) SymbolInfoInteger(CurrentSymbol,SYMBOL_DIGITS));   
            ProcessTradeTsl(CurrentSymbol, TicketNumber[SymbolLoop], NewStopLossPrice);    
         }
         else if(
            IsTsl == true &&
            PositionDirection == "Short"
         )
         {
            OrderType               = ORDER_TYPE_SELL;  
            double Price            = GetPrice(CurrentSymbol, OrderType);
            double NewStopLossPrice = NormalizeDouble(Price + (IndicatorValueAtr*StopLossAtrMultiple),(int) SymbolInfoInteger(CurrentSymbol,SYMBOL_DIGITS));   
            ProcessTradeTsl(CurrentSymbol, TicketNumber[SymbolLoop], NewStopLossPrice);          
         }         
                           
         //Update Symbol Metrics
         SymbolMetrics[SymbolLoop] = CurrentSymbol + 
                                     " | Ticks Processed: " + IntegerToString(TicksProcessed[SymbolLoop]) +
                                     " | Last Candle: " + TimeToString(TimeLastTickProcessed[SymbolLoop]) +
                                     " | Open Ticket: " + IntegerToString(TicketNumber[SymbolLoop]) +
                                     " | Open Ticket Direction: " + PositionDirection +
                                     " | Entry 1 (" + IntegerToString(IndicatorHandleE1[SymbolLoop])+") : " + IndicatorSignalE1 +
                                     " | Filter 1 (" + IntegerToString(IndicatorHandleF1[SymbolLoop])+") : " + IndicatorSignalF1 +
                                     " | Filter 2 (" + IntegerToString(IndicatorHandleF2[SymbolLoop])+") : " + IndicatorSignalF2 +
                                     " | Exit 1 (" + IntegerToString(IndicatorHandleX1[SymbolLoop])+") : " + IndicatorSignalX1                     
                                     ;
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
//| Multi-Symbol Custom Functions                                    |
//+------------------------------------------------------------------+
//Initiate MultiSymbol Function
void InitMultiSymbol() 
{
   //Set up symbol arrays
   //If current symbol, select symbol from EA settings
   if(AllTradableSymbols == "Current")
   {
      NumberOfTradeableSymbols = 1;
      ArrayResize(SymbolArray,NumberOfTradeableSymbols);
      SymbolArray[0] = Symbol();
      Print("EA will process ", NumberOfTradeableSymbols, " Symbol: ", SymbolArray[0]);
   } 
   //Else test all symbols
   else
   {
      NumberOfTradeableSymbols = StringSplit(AllTradableSymbols, '|', SymbolArray);
      ArrayResize(SymbolArray,NumberOfTradeableSymbols);
      Print("EA will process ", NumberOfTradeableSymbols, " Symbols: ", AllTradableSymbols);
   }
}

//Resize core arrays for multi-symbol EA
void ResizeCoreArrays()
{
   //Resize core arrays for Multi-Symbol EA
   ArrayResize(SymbolMetrics,         NumberOfTradeableSymbols);
   ArrayResize(TicksProcessed,        NumberOfTradeableSymbols); 
   ArrayResize(TimeLastTickProcessed, NumberOfTradeableSymbols);
   ArrayResize(TicketNumber,          NumberOfTradeableSymbols);
}
//+------------------------------------------------------------------+
//| Indicator library custom functions                               |
//+------------------------------------------------------------------+
//Resize indicator arrays for Multi-Symbol EA
void ResizeIndicatorArrays()
{
   ArrayResize(IndicatorHandleAtr, NumberOfTradeableSymbols);
   ArrayResize(IndicatorHandleE1, NumberOfTradeableSymbols);
   ArrayResize(IndicatorHandleF1, NumberOfTradeableSymbols);
   ArrayResize(IndicatorHandleF2, NumberOfTradeableSymbols);
   ArrayResize(IndicatorHandleX1, NumberOfTradeableSymbols);
}

//Release indicator handles from Metatrader cache for multi-symbol EA
void ReleaseIndicatorHandles()
{
   for(int SymbolLoop=0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
   {
      IndicatorRelease(IndicatorHandleAtr[SymbolLoop]);
      IndicatorRelease(IndicatorHandleE1[SymbolLoop]);
      IndicatorRelease(IndicatorHandleF1[SymbolLoop]);
      IndicatorRelease(IndicatorHandleF2[SymbolLoop]);
      IndicatorRelease(IndicatorHandleX1[SymbolLoop]);
   }
   Print("Handle released for all symbols");   
}

//Set up Indicator1 Handle for Multi-Symbol EA
bool InitIndicatorHanldes()
{
   for(int SymbolLoop=0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
   {
      IndicatorHandleAtr[SymbolLoop] = GetIndicatorHandle(IndicatorAtr, SymbolArray[SymbolLoop],Period());
      IndicatorHandleE1[SymbolLoop] = GetIndicatorHandle(IndicatorE1, SymbolArray[SymbolLoop],Period());
      IndicatorHandleF1[SymbolLoop] = GetIndicatorHandle(IndicatorF1, SymbolArray[SymbolLoop],Period());
      IndicatorHandleF2[SymbolLoop] = GetIndicatorHandle(IndicatorF2, SymbolArray[SymbolLoop],Period());
      IndicatorHandleX1[SymbolLoop] = GetIndicatorHandle(IndicatorX1, SymbolArray[SymbolLoop],Period());
   }
   return true;     
}