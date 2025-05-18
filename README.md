# AryaPlatform

**AryaPlatform** is an open-source MQL5 library designed to simplify and streamline the development of Expert Advisors, Indicators, and Scripts in MetaTrader 5. This library is the result of years of hands-on experience in the MetaTrader ecosystem and is built around modular and reusable classes that solve common tasks faced by MQL5 developers.

> This project is under active development and will be continuously extended with more utilities and helper classes.

## 📌 Features

- Easy-to-use utility classes to handle trading operations, graphics, and more.
- Written with flexibility and reusability in mind.
- Aimed at improving productivity and reducing boilerplate code in MQL5 development.
- Licensed under GPL, making it fully open-source and community-friendly.

## 📂 Included Modules

The current version of the AryaPlatform includes the following core files:

### `Trades.mqh`
A powerful wrapper class to handle trade operations in MetaTrader 5. It abstracts away many of the complexities involved in order execution, modification, and closure.

**Features:**
- Simplified trade execution (`Buy`, `Sell`, `Close`, etc.)
- Error checking and result reporting
- Customizable parameters for volume, slippage, magic number, etc.
- Integrated with native MQL5 trade handling functions

### `TGline.mqh`
A utility class for drawing trend lines on MetaTrader charts, useful for visualizing technical patterns and strategies.

**Features:**
- Draw and update trend lines easily
- Unique object naming to avoid conflicts
- Customize line color, style, and width
- Handles automatic deletion on chart switch (optional)

## 📦 Installation

1. Clone or download the repository:
   ```bash
   git clone https://github.com/yourusername/AryaPlatform.git
   ```

2. Copy the `.mqh` files you need into your MetaTrader 5 `Include` folder:
   ```
   MQL5/
     Include/
       AryaPlatform/
         Trades.mqh
         TGline.mqh
   ```

3. Include them in your EA or indicator file:
   ```mq5
   #include <AryaPlatform/Trades.mqh>
   #include <AryaPlatform/TGline.mqh>
   ```

## 🛠 Usage Example

Here’s a simple example of how to use the `Trades` class:

```mq5
#include <AryaPlatform/Trades.mqh>

CTradeManager trade;

void OnTick()
{
    if (trade.Buy(0.1))
        Print("Buy order executed!");
    else
        Print("Buy failed: ", trade.LastError());
}
```

And an example using `TGline` to draw a trendline:

```mq5
#include <AryaPlatform/TGline.mqh>

void OnInit()
{
    TGline trend("MyTrend", 0, 100, iTime(_Symbol, PERIOD_H1, 10), iClose(_Symbol, PERIOD_H1, 10),
                                  iTime(_Symbol, PERIOD_H1, 5), iClose(_Symbol, PERIOD_H1, 5));
    trend.SetColor(clRed);
}
```

## 📖 Documentation

Full documentation will be available in the [Wiki section](https://github.com/yourusername/AryaPlatform/wiki) soon. It will include:

- Class usage and examples
- Integration patterns
- Advanced features
- Contribution guide

## 🔧 Contributing

Contributions are welcome! If you’ve built useful MQL5 utilities or improvements, feel free to fork this repository and submit a pull request. All contributions must align with the GPL license.

## 📃 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**. See the [LICENSE](LICENSE) file for details.

---

> AryaPlatform is built by developers, for developers — to save time, reduce bugs, and build powerful MQL5 tools with ease.
