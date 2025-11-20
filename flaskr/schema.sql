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

-- Sample Data: At least 10 rows per table

-- Sample Traders (10 users)
INSERT INTO Traders (Username, Password, Email, First_name, Last_name, Phone, Registration_date, Account_balance, Account_status) VALUES
  ('jdoe', 'password123', 'john.doe@email.com', 'John', 'Doe', '555-0101', '2024-01-15', 50000.00, 'active'),
  ('asmith', 'password123', 'alice.smith@email.com', 'Alice', 'Smith', '555-0102', '2024-02-20', 75000.00, 'active'),
  ('bwilson', 'password123', 'bob.wilson@email.com', 'Bob', 'Wilson', '555-0103', '2024-03-10', 100000.00, 'active'),
  ('cjohnson', 'password123', 'carol.johnson@email.com', 'Carol', 'Johnson', '555-0104', '2024-01-25', 25000.00, 'active'),
  ('dlee', 'password123', 'david.lee@email.com', 'David', 'Lee', '555-0105', '2024-04-05', 150000.00, 'active'),
  ('emartin', 'password123', 'emma.martin@email.com', 'Emma', 'Martin', '555-0106', '2024-02-14', 80000.00, 'active'),
  ('fgarcia', 'password123', 'frank.garcia@email.com', 'Frank', 'Garcia', '555-0107', '2024-03-22', 60000.00, 'suspended'),
  ('gmiller', 'password123', 'grace.miller@email.com', 'Grace', 'Miller', '555-0108', '2024-01-30', 90000.00, 'active'),
  ('hdavis', 'password123', 'henry.davis@email.com', 'Henry', 'Davis', '555-0109', '2024-04-12', 45000.00, 'active'),
  ('iwilliams', 'password123', 'ivy.williams@email.com', 'Ivy', 'Williams', '555-0110', '2024-02-28', 120000.00, 'active');

-- Sample Stocks (15 stocks)
INSERT INTO Stocks (Ticker_symbol, Company_name, Exchange, Sector, Current_price, Previous_close, Ipo_date) VALUES
  ('AAPL', 'Apple Inc.', 'NASDAQ', 'Technology', 178.50, 177.25, '1980-12-12'),
  ('TSLA', 'Tesla Inc.', 'NASDAQ', 'Automotive', 242.80, 240.15, '2010-06-29'),
  ('MSFT', 'Microsoft Corporation', 'NASDAQ', 'Technology', 378.91, 376.50, '1986-03-13'),
  ('GOOGL', 'Alphabet Inc.', 'NASDAQ', 'Technology', 141.80, 140.25, '2004-08-19'),
  ('AMZN', 'Amazon.com Inc.', 'NASDAQ', 'E-commerce', 178.35, 176.90, '1997-05-15'),
  ('NVDA', 'NVIDIA Corporation', 'NASDAQ', 'Technology', 495.22, 492.10, '1999-01-22'),
  ('META', 'Meta Platforms Inc.', 'NASDAQ', 'Technology', 485.50, 482.30, '2012-05-18'),
  ('JPM', 'JPMorgan Chase & Co.', 'NYSE', 'Financial', 182.45, 181.20, '1980-03-05'),
  ('V', 'Visa Inc.', 'NYSE', 'Financial', 272.80, 271.45, '2008-03-19'),
  ('WMT', 'Walmart Inc.', 'NYSE', 'Retail', 165.30, 164.85, '1972-08-25'),
  ('DIS', 'The Walt Disney Company', 'NYSE', 'Entertainment', 112.50, 111.80, '1957-11-12'),
  ('NFLX', 'Netflix Inc.', 'NASDAQ', 'Entertainment', 625.40, 622.15, '2002-05-23'),
  ('BA', 'The Boeing Company', 'NYSE', 'Aerospace', 198.75, 197.30, '1934-09-05'),
  ('INTC', 'Intel Corporation', 'NASDAQ', 'Technology', 43.85, 43.20, '1971-10-13'),
  ('AMD', 'Advanced Micro Devices', 'NASDAQ', 'Technology', 168.90, 167.45, '1979-09-01');

-- Sample Portfolios (12 portfolios)
INSERT INTO Portfolio (Trader_id, Portfolio_name, Creation_date, Cash_balance, Is_active) VALUES
  (1, 'Growth Portfolio', '2024-01-20', 10000.00, 1),
  (1, 'Dividend Portfolio', '2024-02-15', 15000.00, 1),
  (2, 'Tech Stocks', '2024-02-25', 25000.00, 1),
  (3, 'Conservative Mix', '2024-03-12', 50000.00, 1),
  (3, 'Aggressive Growth', '2024-03-15', 30000.00, 1),
  (4, 'Retirement Fund', '2024-02-01', 20000.00, 1),
  (5, 'Day Trading', '2024-04-08', 75000.00, 1),
  (6, 'Blue Chip Stocks', '2024-02-20', 40000.00, 1),
  (7, 'High Risk High Reward', '2024-03-25', 15000.00, 0),
  (8, 'Long Term Holdings', '2024-02-05', 45000.00, 1),
  (9, 'Startup Portfolio', '2024-04-15', 22000.00, 1),
  (10, 'Balanced Mix', '2024-03-05', 60000.00, 1);

-- Sample Transactions (20 transactions)
INSERT INTO Transactions (Portfolio_id, Stock_id, Transaction_type, Order_type, Quantity, Price_per_share, Transaction_date, Status) VALUES
  (1, 1, 'buy', 'market', 50, 175.30, '2024-01-21', 'executed'),
  (1, 3, 'buy', 'limit', 25, 370.50, '2024-01-25', 'executed'),
  (2, 8, 'buy', 'market', 100, 180.25, '2024-02-16', 'executed'),
  (3, 6, 'buy', 'market', 20, 490.80, '2024-02-26', 'executed'),
  (3, 7, 'buy', 'limit', 15, 480.00, '2024-03-01', 'executed'),
  (4, 10, 'buy', 'market', 200, 163.50, '2024-03-13', 'executed'),
  (5, 2, 'buy', 'market', 30, 235.60, '2024-03-16', 'executed'),
  (5, 2, 'sell', 'limit', 10, 245.00, '2024-04-10', 'executed'),
  (6, 1, 'buy', 'market', 75, 176.80, '2024-02-02', 'executed'),
  (7, 14, 'buy', 'market', 500, 42.50, '2024-04-09', 'executed'),
  (7, 15, 'buy', 'market', 100, 165.30, '2024-04-11', 'executed'),
  (8, 3, 'buy', 'limit', 40, 375.00, '2024-02-21', 'executed'),
  (9, 2, 'buy', 'stop', 25, 240.00, '2024-03-26', 'cancelled'),
  (10, 4, 'buy', 'market', 150, 139.90, '2024-02-06', 'executed'),
  (11, 12, 'buy', 'market', 10, 620.30, '2024-04-16', 'executed'),
  (12, 5, 'buy', 'market', 60, 175.40, '2024-03-06', 'executed'),
  (1, 3, 'sell', 'limit', 10, 380.00, '2024-04-05', 'pending'),
  (3, 6, 'sell', 'market', 5, 495.20, '2024-04-14', 'executed'),
  (7, 14, 'sell', 'stop-limit', 200, 44.00, '2024-04-18', 'pending'),
  (12, 5, 'buy', 'limit', 40, 177.00, '2024-04-17', 'executed');

-- Sample Watchlists (15 entries)
INSERT INTO Watchlists (Trader_id, Stock_id, Date_added, Target_price) VALUES
  (1, 2, '2024-01-22', 250.00),
  (1, 6, '2024-02-10', 500.00),
  (2, 4, '2024-02-26', 145.00),
  (2, 5, '2024-03-01', 180.00),
  (3, 11, '2024-03-14', 115.00),
  (4, 12, '2024-02-05', 630.00),
  (5, 7, '2024-04-10', 490.00),
  (5, 9, '2024-04-12', 275.00),
  (6, 13, '2024-02-22', 200.00),
  (7, 15, '2024-03-28', 170.00),
  (8, 1, '2024-02-08', 185.00),
  (9, 2, '2024-04-17', 260.00),
  (10, 14, '2024-03-10', 45.00),
  (10, 6, '2024-03-12', 505.00),
  (1, 12, '2024-04-01', 640.00);
