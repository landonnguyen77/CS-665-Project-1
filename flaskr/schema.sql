-- Investment Management System Database Schema (3NF)
-- CS 665 Project 1

-- Drop existing tables if they exist
DROP TABLE IF EXISTS Watchlists;
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Portfolio;
DROP TABLE IF EXISTS Stocks;
DROP TABLE IF EXISTS Traders;

-- Table 1: Traders
CREATE TABLE Traders (
  Trader_id INTEGER PRIMARY KEY AUTOINCREMENT,
  Username TEXT UNIQUE NOT NULL,
  Password TEXT NOT NULL,
  Email TEXT UNIQUE NOT NULL,
  First_name TEXT NOT NULL,
  Last_name TEXT NOT NULL,
  Phone TEXT,
  Registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  Account_balance NUMERIC(15,2) NOT NULL DEFAULT 0.00,
  Account_status TEXT NOT NULL DEFAULT 'active'
);

-- Table 2: Stocks
CREATE TABLE Stocks (
  Stock_id INTEGER PRIMARY KEY AUTOINCREMENT,
  Ticker_symbol TEXT UNIQUE NOT NULL,
  Company_name TEXT NOT NULL,
  Exchange TEXT NOT NULL,
  Sector TEXT,
  Current_price NUMERIC(10,2),
  Previous_close NUMERIC(10,2),
  Ipo_date DATE
);

-- Table 3: Portfolio
CREATE TABLE Portfolio (
  Portfolio_id INTEGER PRIMARY KEY AUTOINCREMENT,
  Trader_id INTEGER NOT NULL,
  Portfolio_name TEXT NOT NULL,
  Creation_date DATE NOT NULL DEFAULT CURRENT_DATE,
  Cash_balance NUMERIC(15,2) NOT NULL DEFAULT 0.00,
  Is_active INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (Trader_id) REFERENCES Traders(Trader_id)
);

-- Table 4: Transactions
CREATE TABLE Transactions (
  Transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
  Portfolio_id INTEGER NOT NULL,
  Stock_id INTEGER NOT NULL,
  Transaction_type TEXT NOT NULL,
  Order_type TEXT NOT NULL,
  Quantity INTEGER NOT NULL,
  Price_per_share NUMERIC(10,2) NOT NULL,
  Transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
  Status TEXT NOT NULL DEFAULT 'pending',
  FOREIGN KEY (Portfolio_id) REFERENCES Portfolio(Portfolio_id),
  FOREIGN KEY (Stock_id) REFERENCES Stocks(Stock_id)
);

-- Table 5: Watchlists
CREATE TABLE Watchlists (
  Watchlist_id INTEGER PRIMARY KEY AUTOINCREMENT,
  Trader_id INTEGER NOT NULL,
  Stock_id INTEGER NOT NULL,
  Date_added DATE NOT NULL DEFAULT CURRENT_DATE,
  Target_price NUMERIC(10,2),
  FOREIGN KEY (Trader_id) REFERENCES Traders(Trader_id),
  FOREIGN KEY (Stock_id) REFERENCES Stocks(Stock_id)
);
