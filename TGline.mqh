//+------------------------------------------------------------------+
//|                                                       TGline.mqh |
//|                                     Copyright 2025, Arya Expert. |
//|                                      arya.originalmail@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Arya Expert."
#property link      "arya.originalmail@gmail.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| EX5 includes                                                     |
//+------------------------------------------------------------------+
#include <AryaLib\Platform\TG\Telegram.mqh>
//--- Object creation class
class TGline
{
    private:
        //variables
        int PostRequest(string &out, const string url, const string params, const int timeout=5000);
        
    protected:
        //Calculation function
        string telegramToken;
        string sender;
        long mchatID;
        
        ulong lastupdate;
        datetime lastdate;
        
        //Class
        CCustomBot cbot;
        
        void SetLastUpdate();
        string ParseTelegramResponse(string json_response);
        long GetChatID();
        
    public:
        //Creators
        TGline();
       ~TGline();
        bool Init(string TelegramBotToken, long MainChatID=0, string SenderName="MQL5");
        bool SendText(string textmsg, bool sdr=false);
        bool SendImage(string photoPath, string describe, bool cflag=false, string photoID="Random");
        bool SendScreenShot(long chartId, string describe="Auto", int width=2048, int height=1152, ENUM_ALIGN_MODE AMOD=ALIGN_RIGHT);
        string NewMsg(void);
};
//--- Prime functions
TGline::TGline(void)
{
    lastupdate = 0;
    lastdate = 0;
}
TGline::~TGline(void)
{
    
}
//--- Post request function
int TGline::PostRequest(string &out, const string url, const string params, const int timeout=5000)
{
    char data[];
    int data_size=StringLen(params);
    StringToCharArray(params,data,0,data_size);

    uchar result[];
    string result_headers;

    //--- application/x-www-form-urlencoded
    int res=WebRequest("POST",url,NULL,NULL,timeout,data,data_size,result,result_headers);
    if(res==200)//OK
    {
    //--- delete BOM
        int start_index=0;
        int size=ArraySize(result);
        for(int i=0; i<fmin(size,8); i++)
        {
            if(result[i]==0xef || result[i]==0xbb || result[i]==0xbf)
                start_index=i+1;
            else
                break;
        }
        //---
        out=CharArrayToString(result,start_index,WHOLE_ARRAY,CP_UTF8);
        return(0);
    }
    else
    {
        if(res==-1)
        {
            return(_LastError);
        }
        else
        {
            //--- HTTP errors
            if(res>=100 && res<=511)
            {
                out=CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
                Print(out);
                return(ERR_HTTP_ERROR_FIRST+res);
            }
            return(res);
        }
    }

    return(0);
}
//--- Init Function
bool TGline::Init(string TelegramBotToken, long MainChatID=0, string SenderName="MQL5")
{
    telegramToken = TelegramBotToken;
    cbot.Token(TelegramBotToken);
    
    sender = SenderName;
    
    if(MainChatID != 0) mchatID = MainChatID;
    else 
    {
        mchatID = GetChatID();
        Print("Chat Id = ",mchatID);
    }
    if(mchatID == 0) return false;
    
    lastupdate= 0; //iTime(_Symbol,PERIOD_M1,0);
    return true;
}
//--- Send Screenshot
bool TGline::SendScreenShot(long chartId,string describe="Auto",int width=2048,int height=1152,ENUM_ALIGN_MODE AMOD=ALIGN_RIGHT)
{
    // آدرس فایل اسکرین‌شات
    string screenshot_path = "Chart_" + ChartSymbol(chartId) + "_" + EnumToString(ChartPeriod(chartId)) + ".png";

    // گرفتن اسکرین‌شات
    bool success = ChartScreenShot(chartId, screenshot_path, width, height, AMOD);
   
    // بررسی موفقیت عملیات
    if(success)
    {
        // Print("Screenshot taken successfully : ", screenshot_path);
      
        string des = describe;
        if (des == "Auto")
        {
            des = "Symbol : " + ChartSymbol(chartId) + " & Timeframe : " + EnumToString(ChartPeriod(chartId)); 
        }
        return SendImage(screenshot_path,des);
    }
    else
    {
        Print("The screenshot encountered an error");
        return false;
    }
}
//--- Sending Picture
bool TGline::SendImage(string photoPath, string describe, bool cflag=false, string photoID="Random")
{
    // Set photo ID
    string pid;
    if(photoID == "Random") pid = "ABC" + IntegerToString(TimeCurrent()) + ":photo";
    else pid = photoID;
    
    // Perform WebRequest
    int statusCode = cbot.SendPhoto(pid,mchatID,photoPath,describe,cflag,15000);
   
    // Check the response status of the web request
    if (statusCode == 0) 
    {
        // If the response status is 200 (OK), print a success message
        // Print("Telegram photo sent successfully!");
        return true;
    }
    else
    {
        // If the response status is not 200 or -1, print the unexpected response code and error code
        PrintFormat("Failed to send photo. Error code: %d, Description: %s", statusCode, GetLastError());
        if (statusCode == 1001) 
        {
           // If the error code is 4014, it means the Telegram API URL is not allowed in the terminal
           Print("Please turn on VPN to solve problem ;)");
        }
        return false;
    }
}
//--- Text send message
bool TGline::SendText(string textmsg, bool sdr=false)
{
    // Make a message
    string msg = (sdr==true) ? (sender + " : " + textmsg) : textmsg;
   
    // Perform WebRequest
    int statusCode = cbot.SendMessage(mchatID,msg);
   
    // Check the response status of the web request
    if (statusCode == 0) 
    {
        // If the response status is 200 (OK), print a success message
        // Print("Telegram message sent successfully!");
        return true;
    }
    else
    {
        // If the response status is not 200 or -1, print the unexpected response code and error code
        PrintFormat("Failed to send message. Error code: %d, Description: %s", statusCode, GetLastError());
        if (statusCode == 1001) 
        {
           // If the error code is 4014, it means the Telegram API URL is not allowed in the terminal
           Print("Please turn on VPN to solve problem ;)");
        }
        return false;
    }
}
// get new messages
string TGline::NewMsg(void)
{
    const string TG_API = "https://api.telegram.org/bot";  // Base URL for Telegram API
    //Print(TimeToString(lastdate));
    // Telegram API URL
    string telegramUrl = TG_API + telegramToken + "/getUpdates"; 
    if (lastupdate > 0)
      telegramUrl += "?offset=" + IntegerToString(lastupdate + 1);
    string out;
    string params="";
    int statusCode;
    
    // Perform WebRequest
    statusCode = PostRequest(out,telegramUrl,params,5000);
    
    // Check the response status of the web request
    if (statusCode == 0) 
    {
        // If the response status is 200 (OK), print a success message
        // Print("Telegram message recive successfully!");
        CJAVal js(NULL,jtUNDEF);
        //---
        bool done=js.Deserialize(out);
        if(!done)
            return("");
        
        bool ok=js["ok"].ToBool();
        if(!ok)
            return("");
        
        int total=ArraySize(js["result"].m_e)-1;
        if(total < 0) return "";
        
        string nmsg="";
        for(int i=0; i<total; i++)
        {
            CJAVal item=js["result"].m_e[i];
            
            long msgcid = item["message"]["chat"]["id"].ToInt();
            //Print("Our chat ID : ",mchatID);
            //Print("msg Chat ID : ",msgcid);
            if(msgcid!=mchatID)
            {
                //Print("Not equal");
                continue;
            }
            
            if(item["message"]["date"].ToInt() <= (long)lastdate) 
                continue;
            
            nmsg += item["message"]["text"].ToStr() + "\n";
        }
        
        CJAVal item=js["result"].m_e[total];
        if(item["message"]["chat"]["id"].ToInt()==mchatID && item["message"]["date"].ToInt()>(long)lastdate)  
            nmsg += item["message"]["text"].ToStr();
        
        if(nmsg!="") 
        {
            lastupdate = item["update_id"].ToInt();
            lastdate = (datetime)item["message"]["date"].ToInt();
        }
        
        return nmsg;
    }
    else
    {
        // If the response status is not 200 or -1, print the unexpected response code and error code
        //PrintFormat("Failed to recive message. Error code: %d, Description: %s", statusCode, GetLastError());
        
    }
    
    return "";
}
//--- Get Chat ID
long TGline::GetChatID(void)
{
    const string TG_API = "https://api.telegram.org/bot";  // Base URL for Telegram API
    
    // Telegram API URL
    string telegramUrl = TG_API + telegramToken + "/getUpdates"; 
    if (lastupdate > 0)
      telegramUrl += "?offset=" + IntegerToString(lastupdate + 1);
    string out;
    string params="";
    int statusCode;
    
    // Perform WebRequest
    statusCode = PostRequest(out,telegramUrl,params,10000);
    
    // Check the response status of the web request
    if (statusCode == 0) 
    {
        // If the response status is 200 (OK), print a success message
        CJAVal js(NULL,jtUNDEF);
        //---
        bool done=js.Deserialize(out);
        if(!done)
            return(0);
        
        bool ok=js["ok"].ToBool();
        if(!ok)
            return(0);
        
        int total=ArraySize(js["result"].m_e);
        if(total <= 0) return 0;
        
        long cid=0;
        CJAVal item=js["result"].m_e[total-1];
        
        if(item["message"]["text"].ToStr() == "/start")
        {
            cid = item["message"]["chat"]["id"].ToInt();
            lastdate = (datetime)item["message"]["date"].ToInt();
            lastupdate = item["update_id"].ToInt();
        }
        
        return cid;
    }
    else
    {
        // If the response status is not 200 or -1, print the unexpected response code and error code
        PrintFormat("Failed to Get Chat ID. Error code: %d, Description: %s", statusCode, GetLastError());
    }
    
    return 0;
}
//+------------------------------------------------------------------+
