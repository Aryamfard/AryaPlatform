//+------------------------------------------------------------------+
//|                                                       Trades.mqh |
//|                                    Copyright 2024, Arya Experts. |
//|                                          https://t.me/AryaExpert |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Arya Experts."
#property link      "https://t.me/AryaExpert"
#property version   "1.00"
//--- Includes
#include <Trade\Trade.mqh>
//--- Class body
class Trades
{
    private:
        
    protected:
        // Main vars
        string mSymbol;
        ENUM_TIMEFRAMES mPeriod;
        ulong mticket;
        ulong mmagic;
        
        // Functions
        string GetErrorDescription(uint error_code);
        
    public:
        Trades();
       ~Trades();
        bool OpenPos(string pSymbol, ENUM_TIMEFRAMES pPeriod, ENUM_ORDER_TYPE OT, double pVolume, 
                     double pPrice, double pStop, double pProfit, string Cmt);
        void SavePos(ulong pTicket, ENUM_TIMEFRAMES pPeriod);
        bool ClosePos(void);
        
        double OpenPrice(void);
        double StopLoss(void);
        double TakeProfit(void);
        double Volume(void);
        double Profit(void);
        
        datetime OpenTime(void);
        datetime CloseTime(void);
        
        char Direction(void);
        
        bool IsOpen(void);
        bool NewSL(double slValue);
        bool NewTP(double tpValue);
        
        string OrderSymbol(void) {return mSymbol;};
        ENUM_TIMEFRAMES OrderPeriod(void) {return mPeriod;};
        ulong OrderTicket(void) {return mticket;};
        ulong OrderMagicNumber(void) {return mmagic;};
        ENUM_ORDER_TYPE OrderType(void);
};
// Function to get error description
string Trades::GetErrorDescription(uint error_code)
{
    switch(error_code)
    {
        case 10004: return "Requote";
        case 10006: return "Request rejected";
        case 10007: return "Request canceled by trader";
        case 10008: return "Order placed";
        case 10009: return "Request completed";
        case 10010: return "Only part of the request was completed";
        case 10011: return "Request processing error";
        case 10012: return "Request canceled by timeout";
        case 10013: return "Invalid request";
        case 10014: return "Invalid volume in the request";
        case 10015: return "Invalid price in the request";
        case 10016: return "Invalid stops in the request";
        case 10017: return "Trade is disabled";
        case 10018: return "Market is closed";
        case 10019: return "Insufficient funds";
        case 10020: return "Prices changed";
        case 10021: return "There are no quotes to process the request";
        case 10022: return "Invalid order expiration date in the request";
        case 10023: return "Order state changed";
        case 10024: return "Too frequent requests";
        case 10025: return "No changes in request";
        case 10026: return "Autotrading disabled by server";
        case 10027: return "Autotrading disabled by client terminal";
        case 10028: return "Request locked for processing";
        case 10029: return "Order or position frozen";
        case 10030: return "Invalid order filling type";
        default: return "Unknown error";
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trades::Trades()
{
    mSymbol = NULL;
    mPeriod = NULL;
    mticket = 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trades::~Trades()
{
    
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Trades::OpenPos(string pSymbol, ENUM_TIMEFRAMES pPeriod, ENUM_ORDER_TYPE OT, double pVolume, 
                      double pPrice, double pStop, double pProfit, string Cmt)
{
    CTrade trd;
    bool res = false;
    if(OT == ORDER_TYPE_BUY || OT == ORDER_TYPE_SELL)
        res = trd.PositionOpen(pSymbol,OT,pVolume,pPrice,pStop,pProfit,Cmt);
    else if(OT == ORDER_TYPE_BUY_STOP)
        res = trd.BuyStop(pVolume,pPrice,pSymbol,pStop,pProfit,0,0,Cmt);
    else if(OT == ORDER_TYPE_BUY_LIMIT)
        res = trd.BuyLimit(pVolume,pPrice,pSymbol,pStop,pProfit,0,0,Cmt);
    else if(OT == ORDER_TYPE_SELL_STOP)
        res = trd.SellStop(pVolume,pPrice,pSymbol,pStop,pProfit,0,0,Cmt);
    else if(OT == ORDER_TYPE_SELL_LIMIT)
        res = trd.SellLimit(pVolume,pPrice,pSymbol,pStop,pProfit,0,0,Cmt);
    
    if(!res)
    {
        // Get the error code
        uint error_code = trd.ResultRetcode();
        
        // Print the error message
        Print("Failed to open order. Error code: ", error_code, " - ", GetErrorDescription(error_code));
        return res;
    }
    mticket = trd.ResultOrder();
    mmagic = trd.RequestMagic();
    mPeriod = pPeriod;
    mSymbol = pSymbol;
    return res;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trades::SavePos(ulong pTicket,ENUM_TIMEFRAMES pPeriod)
{
    if(!PositionSelectByTicket(pTicket))
    {
        Print("Error: ticket ", pTicket, " not found.");
        return;
    }
    
    mticket = pTicket;
    mPeriod = pPeriod;
    mSymbol = PositionGetString(POSITION_SYMBOL);
    mmagic = PositionGetInteger(POSITION_MAGIC);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Trades::ClosePos(void)
{
    CTrade trd;
    
    if(PositionSelectByTicket(mticket))
        return trd.PositionClose(mticket);
    
    if(OrderSelect(mticket))
        return trd.OrderDelete(mticket);
    
    return false;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Trades::OpenPrice(void)
{
    // Check if the ticket corresponds to an open position
    if (PositionSelectByTicket(mticket))
    {
        return PositionGetDouble(POSITION_PRICE_OPEN);
    }

    // If not found in open positions, check the order history
    if (HistoryOrderSelect(mticket))
    {
        double pPrice = 0;
        if(HistoryOrderGetDouble(mticket,ORDER_PRICE_OPEN,pPrice)) return pPrice;
    }

    // If the ticket is not found, return an error value
    Print("Error: Get Open Price with ticket ", mticket, " not found.");
    return -1;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Trades::StopLoss(void)
{
    // Check if the ticket corresponds to an open position
    if (PositionSelectByTicket(mticket))
    {
        return PositionGetDouble(POSITION_SL);
    }

    // If not found in open positions, check the order history
    if (HistoryOrderSelect(mticket))
    {
        double pSL = 0;
        if(HistoryOrderGetDouble(mticket,ORDER_SL,pSL)) return pSL;
    }

    // If the ticket is not found, return an error value
    Print("Error: Get SL with ticket ", mticket, " not found.");
    return -1;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Trades::TakeProfit(void)
{
    // Check if the ticket corresponds to an open position
    if (PositionSelectByTicket(mticket))
    {
        return PositionGetDouble(POSITION_TP);
    }

    // If not found in open positions, check the order history
    if (HistoryOrderSelect(mticket))
    {
        double pTP = 0;
        if(HistoryOrderGetDouble(mticket,ORDER_TP,pTP)) return pTP;
    }

    // If the ticket is not found, return an error value
    Print("Error: Get TP with ticket ", mticket, " not found.");
    return -1;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Trades::Volume(void)
{
    // Check if the ticket corresponds to an open position
    if (PositionSelectByTicket(mticket))
    {
        return PositionGetDouble(POSITION_VOLUME);
    }

    // If not found in open positions, check the order history
    if (HistoryOrderSelect(mticket))
    {
        double pVol = 0;
        if(HistoryOrderGetDouble(mticket,ORDER_VOLUME_CURRENT,pVol)) return pVol;
    }

    // If the ticket is not found, return an error value
    Print("Error: Get Volume with ticket ", mticket, " not found.");
    return -1;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Trades::Profit(void)
{
    // Check if the ticket corresponds to an open position
    if (PositionSelectByTicket(mticket))
    {
        return PositionGetDouble(POSITION_PROFIT);
    }
    
    // Retrieve the deal information by the given ticket
    if (!HistorySelectByPosition(mticket))
    {
        Print("Error: Unable to find deal with ticket ", mticket);
        return 0.0;
    }
    
    double totalProfit = 0.0;
    
    // Iterate through all deals linked to the ticket
    for (int i = HistoryDealsTotal() - 1; i >= 0; i--)
    {
        ulong dealTicket = HistoryDealGetTicket(i);
        if (dealTicket > 0)
        {
            // Extract deal information
            if (HistoryDealSelect(dealTicket))
            {
                if (HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID) == mticket)
                {
                    totalProfit += HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
                }
            }
        }
    }
    
    return totalProfit/2;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Trades::OpenTime(void)
{
    // Check if the ticket corresponds to an open position
    if (PositionSelectByTicket(mticket))
    {
        return (datetime)PositionGetInteger(POSITION_TIME);
    }

    // If not found in open positions, check the order history
    datetime end=iTime(_Symbol,PERIOD_M1,0);                 // current server time
    datetime start=end-12*PeriodSeconds(PERIOD_MN1);         // set the beginning time to 24 hours ago

    //--- request in the cache of the program the needed interval of the trading history
    HistorySelect(start,end);
    //--- obtain the number of deals in the history
    int deals=HistoryDealsTotal();
    //--- scan through all of the deals in the history
    for(int i=0;i<deals;i++)
    {
        ulong deal_ticket=HistoryDealGetTicket(i);
        if(deal_ticket>0) // obtain into the cache the deal, and work with it
        {
            ENUM_DEAL_ENTRY entry_type=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal_ticket,DEAL_ENTRY);
            datetime time             =(datetime)HistoryDealGetInteger(deal_ticket,DEAL_TIME);
            long order_magic          =HistoryDealGetInteger(deal_ticket,DEAL_MAGIC);
            
            //--- process the deals with the indicated DEAL_MAGIC
            if(order_magic==mmagic && entry_type==DEAL_ENTRY_IN)
            {
                return time;
            }
        }
        else // unsuccessful attempt to obtain a deal
        {
            PrintFormat("We couldn't select a deal, with the index %d. Error %d",
                        i,GetLastError());
        }
    }

    // If the ticket is not found, return an error value
    Print("Error: Get Open Time with ticket ", mticket, " not found.");
    return 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Trades::CloseTime(void)
{
    // Check if the ticket corresponds to an open position
    if (PositionSelectByTicket(mticket))
    {
        return 0;
    }

    // If not found in open positions, check the order history
    datetime end=iTime(_Symbol,PERIOD_M1,0);                 // current server time
    datetime start=end-12*PeriodSeconds(PERIOD_MN1);         // set the beginning time to 24 hours ago

    //--- request in the cache of the program the needed interval of the trading history
    HistorySelect(start,end);
    //--- obtain the number of deals in the history
    int deals=HistoryDealsTotal();
    //--- scan through all of the deals in the history
    for(int i=0;i<deals;i++)
    {
        ulong deal_ticket=HistoryDealGetTicket(i);
        if(deal_ticket>0) // obtain into the cache the deal, and work with it
        {
            ENUM_DEAL_ENTRY entry_type=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal_ticket,DEAL_ENTRY);
            datetime time             =(datetime)HistoryDealGetInteger(deal_ticket,DEAL_TIME);
            long order_magic          =HistoryDealGetInteger(deal_ticket,DEAL_MAGIC);
            
            //--- process the deals with the indicated DEAL_MAGIC
            if(order_magic==mmagic && entry_type==DEAL_ENTRY_OUT)
            {
                return time;
            }
        }
        else // unsuccessful attempt to obtain a deal
        {
            PrintFormat("We couldn't select a deal, with the index %d. Error %d",
                        i,GetLastError());
        }
    }

    // If the ticket is not found, return an error value
    Print("Error: Get Close Time with ticket ", mticket, " not found.");
    return 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
char Trades::Direction(void)
{
    ENUM_ORDER_TYPE ot=-1;
    // Check if the ticket corresponds to an open position
    if (PositionSelectByTicket(mticket))
        ot = (ENUM_ORDER_TYPE)PositionGetInteger(POSITION_TYPE);
    else if(HistoryOrderSelect(mticket))
        ot = (ENUM_ORDER_TYPE)HistoryOrderGetInteger(mticket,ORDER_TYPE);
    else
    {
        // If the ticket is not found, return an error value
        Print("Error: Get Direction with ticket ", mticket, " not found.");
        return 'o';
    }
    
    if(ot==ORDER_TYPE_BUY || ot==ORDER_TYPE_BUY_STOP || ot==ORDER_TYPE_BUY_LIMIT || ot==ORDER_TYPE_BUY_STOP_LIMIT)
        return 'u';
    else if(ot==ORDER_TYPE_SELL || ot==ORDER_TYPE_SELL_STOP || ot==ORDER_TYPE_SELL_LIMIT || ot==ORDER_TYPE_SELL_STOP_LIMIT)
        return 'd';
    else return 'o';
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE Trades::OrderType(void)
{
    ENUM_ORDER_TYPE ot=-1;
    // Check if the ticket corresponds to an open position
    if (PositionSelectByTicket(mticket))
        ot = (ENUM_ORDER_TYPE)PositionGetInteger(POSITION_TYPE);
    else if(OrderSelect(mticket))
        ot = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
    else if(HistoryOrderSelect(mticket))
        ot = (ENUM_ORDER_TYPE)HistoryOrderGetInteger(mticket,ORDER_TYPE);
    else
    {
        // If the ticket is not found, return an error value
        Print("Error: Get Order Type with ticket ", mticket, " not found.");
        return -1;
    }
    
    return ot;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Trades::IsOpen(void)
{
    // Check if the ticket corresponds to an open position
    if(PositionSelectByTicket(mticket) || OrderSelect(mticket)) return true;
    else return false;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Trades::NewSL(double slValue)
{
    CTrade trd;
    double ltp = TakeProfit();
    return trd.PositionModify(mticket,slValue,ltp);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Trades::NewTP(double tpValue)
{
    CTrade trd;
    double lsl = StopLoss();
    return trd.PositionModify(mticket,lsl,tpValue);
}

//+------------------------------------------------------------------+
