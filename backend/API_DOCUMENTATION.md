# PLUTUS AI — Backend API Documentation
**Version:** 1.0.0  
**Base URL:** `http://127.0.0.1:8000/api/v1/`  
**Authentication Scheme:** JSON Web Token (JWT) Bearer Authentication via Django SimpleJWT (`Authorization: Bearer <access_token>`).

---

## 1. Authentication Architecture & Security

All private endpoints require the standard HTTP header:
```http
Authorization: Bearer <access_token>
```

Token lifecycles are configured in Django REST Framework:
- Access token validity: 60 minutes
- Refresh token validity: 7 days
- Passwords hashed using PBKDF2 with SHA-256 (Django standard)
- Strict user-isolation: User portfolios, transactions, watchlists, behavioural responses, and conversation threads are bound to `request.user`.

### Error Response Standard
All API endpoints follow a unified error envelope format:
```json
{
  "error": {
    "code": "VALIDATION_ERROR | NOT_FOUND | UNAUTHORIZED | OUT_OF_SCOPE",
    "message": "Human-readable description of error.",
    "details": {}
  }
}
```

---

## 2. Authentication & Profile Endpoints

### 2.1 Register New User
- **Endpoint:** `POST /api/v1/auth/register/`
- **Auth:** Public
- **Request Body:**
```json
{
  "username": "alexandra_vance",
  "email": "alexandra@plutus.ai",
  "password": "SecurePassword123!",
  "first_name": "Alexandra",
  "last_name": "Vance"
}
```
- **Response (`201 Created`):**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": 2,
    "username": "alexandra_vance",
    "email": "alexandra@plutus.ai",
    "first_name": "Alexandra",
    "last_name": "Vance"
  },
  "tokens": {
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6..."
  }
}
```

### 2.2 Obtain JWT Token (Login)
- **Endpoint:** `POST /api/v1/auth/token/`
- **Auth:** Public
- **Request Body:**
```json
{
  "username": "demo_user",
  "password": "PlutusDemoPassword2026!"
}
```
- **Response (`200 OK`):**
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",
  "user": {
    "id": 1,
    "username": "demo_user",
    "email": "demo@plutus.ai",
    "first_name": "Demo",
    "last_name": "Investor"
  }
}
```

### 2.3 Refresh JWT Token
- **Endpoint:** `POST /api/v1/auth/token/refresh/`
- **Auth:** Public
- **Request Body:**
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6..."
}
```
- **Response (`200 OK`):**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6..."
}
```

### 2.4 User Profile & Financial Preferences
- **Endpoint:** `GET /api/v1/auth/profile/` & `PATCH /api/v1/auth/profile/`
- **Auth:** Bearer Token
- **Request Body (for PATCH):**
```json
{
  "base_currency": "USD",
  "tax_jurisdiction": "US_FEDERAL",
  "bio": "Quantitative investor focused on tech and macro hedging."
}
```
- **Response (`200 OK`):**
```json
{
  "id": 1,
  "username": "demo_user",
  "email": "demo@plutus.ai",
  "first_name": "Demo",
  "last_name": "Investor",
  "profile": {
    "base_currency": "USD",
    "tax_jurisdiction": "US_FEDERAL",
    "risk_profile": "MODERATE_AGGRESSIVE",
    "demo_mode": false,
    "created_at": "2026-11-15T22:34:00Z"
  }
}
```

---

## 3. Market Data Endpoints

### 3.1 List Instruments
- **Endpoint:** `GET /api/v1/market/instruments/?asset_class=EQUITY`
- **Auth:** Bearer Token or Public Read
- **Response (`200 OK`):**
```json
[
  {
    "symbol": "NVDA",
    "name": "NVIDIA Corporation",
    "asset_class": "EQUITY",
    "sector": "Semiconductors",
    "current_price": "142.50",
    "change_absolute": "4.20",
    "change_percent": "3.04",
    "day_high": "144.10",
    "day_low": "139.80",
    "volume": 48200000,
    "market_cap": 3520000000000,
    "pe_ratio": "54.2",
    "last_updated": "2026-11-15T22:34:00Z"
  }
]
```

### 3.2 Get Instrument Detail with Historical Series
- **Endpoint:** `GET /api/v1/market/instruments/{symbol}/?timeframe=1M`
- **Auth:** Bearer Token or Public Read
- **Response (`200 OK`):**
```json
{
  "instrument": {
    "symbol": "NVDA",
    "name": "NVIDIA Corporation",
    "current_price": "142.50",
    "change_percent": "3.04"
  },
  "historical_points": [
    {"timestamp": "2026-10-15T16:00:00Z", "close": 134.20, "volume": 32000000},
    {"timestamp": "2026-11-15T16:00:00Z", "close": 142.50, "volume": 48200000}
  ]
}
```

### 3.3 Market Benchmark Indices
- **Endpoint:** `GET /api/v1/market/indices/`
- **Response (`200 OK`):**
```json
[
  {"symbol": "SPX", "name": "S&P 500", "price": 5890.20, "change_percent": 0.42},
  {"symbol": "NDX", "name": "Nasdaq 100", "price": 20450.80, "change_percent": 0.88},
  {"symbol": "VIX", "name": "CBOE Volatility Index", "price": 14.85, "change_percent": -4.20}
]
```

---

## 4. Portfolio Management Endpoints

### 4.1 List & Create Portfolios
- **Endpoint:** `GET /api/v1/portfolios/` & `POST /api/v1/portfolios/`
- **Auth:** Bearer Token
- **Request Body (for POST):**
```json
{
  "name": "Tactical Technology Fund",
  "base_currency": "USD",
  "description": "Concentrated tech momentum strategy with macro hedges."
}
```
- **Response (`201 Created`):**
```json
{
  "id": 1,
  "name": "Tactical Technology Fund",
  "base_currency": "USD",
  "total_value": "128450.00",
  "total_cost": "114200.00",
  "unrealized_pnl": "14250.00",
  "unrealized_pnl_percent": "12.48",
  "cash_balance": "8500.00",
  "created_at": "2026-11-15T22:34:00Z"
}
```

### 4.2 Portfolio Summary & Asset Allocation
- **Endpoint:** `GET /api/v1/portfolios/{id}/summary/`
- **Response (`200 OK`):**
```json
{
  "id": 1,
  "name": "Tactical Technology Fund",
  "total_value": 128450.00,
  "invested_capital": 114200.00,
  "unrealized_pnl": 14250.00,
  "return_percentage": 12.48,
  "asset_allocation": [
    {"asset_class": "EQUITY", "value": 105000.00, "weight_percentage": 81.74},
    {"asset_class": "FIXED_INCOME", "value": 14950.00, "weight_percentage": 11.64},
    {"asset_class": "CASH", "value": 8500.00, "weight_percentage": 6.62}
  ],
  "sector_allocation": [
    {"sector": "Information Technology", "weight": 62.4},
    {"sector": "Communication Services", "weight": 19.3},
    {"sector": "Treasury/Cash", "weight": 18.3}
  ]
}
```

### 4.3 Holdings & Positions
- **Endpoint:** `GET /api/v1/portfolios/{id}/holdings/`
- **Response (`200 OK`):**
```json
[
  {
    "id": 1,
    "symbol": "NVDA",
    "name": "NVIDIA Corporation",
    "quantity": "250.0000",
    "average_buy_price": "118.40",
    "current_price": "142.50",
    "market_value": "35625.00",
    "unrealized_pnl": "6025.00",
    "unrealized_pnl_percent": "20.35",
    "weight_percentage": "27.73"
  }
]
```

### 4.4 Record Transaction
- **Endpoint:** `POST /api/v1/portfolios/{id}/transactions/`
- **Request Body:**
```json
{
  "symbol": "AAPL",
  "transaction_type": "BUY",
  "quantity": "50.0000",
  "price": "224.50",
  "fees": "1.50",
  "executed_at": "2026-11-15T15:30:00Z"
}
```
- **Response (`201 Created`):**
```json
{
  "id": 12,
  "symbol": "AAPL",
  "transaction_type": "BUY",
  "quantity": "50.0000",
  "price": "224.50",
  "fees": "1.50",
  "total_amount": "11226.50",
  "executed_at": "2026-11-15T15:30:00Z"
}
```
*Note: Transactions automatically recalculate holding quantity and weighted-average cost basis in a single ACID database transaction.*

---

## 5. Quantitative Analytics & Risk Intelligence

### 5.1 Portfolio Risk Metrics
- **Endpoint:** `GET /api/v1/analytics/portfolio/{id}/risk/`
- **Response (`200 OK`):**
```json
{
  "portfolio_id": 1,
  "volatility_annualized": 0.1684,
  "sharpe_ratio": 1.74,
  "sortino_ratio": 2.38,
  "max_drawdown": -0.0945,
  "value_at_risk_95": 2840.50,
  "conditional_var_95": 3950.20,
  "herfindahl_index": 0.198,
  "top_holdings_concentration_top3": 0.642,
  "benchmark_beta": 1.14
}
```

### 5.2 Asset Correlation Matrix
- **Endpoint:** `GET /api/v1/analytics/portfolio/{id}/correlation/`
- **Response (`200 OK`):**
```json
{
  "assets": ["NVDA", "AAPL", "MSFT", "GOOGL", "TLT"],
  "matrix": [
    [1.00, 0.68, 0.72, 0.61, -0.22],
    [0.68, 1.00, 0.79, 0.65, -0.18],
    [0.72, 0.79, 1.00, 0.71, -0.19],
    [0.61, 0.65, 0.71, 1.00, -0.15],
    [-0.22, -0.18, -0.19, -0.15, 1.00]
  ]
}
```

---

## 6. Behavioural Finance Endpoints

### 6.1 Get Behavioural Assessment Questionnaire
- **Endpoint:** `GET /api/v1/behavioural/questionnaire/`
- **Response (`200 OK`):**
```json
[
  {
    "id": "q1",
    "question": "If your portfolio dropped 20% in a 2-week market sell-off, what action would you take?",
    "category": "LOSS_AVERSION",
    "options": [
      {"text": "Sell all assets into cash immediately to prevent further loss", "score": 10},
      {"text": "Sell a portion of volatile assets into defensive bonds", "score": 25},
      {"text": "Do nothing and let the strategic asset allocation recover", "score": 60},
      {"text": "Deploy reserve cash to aggressively buy discounted assets", "score": 90}
    ]
  }
]
```

### 6.2 Submit Answers & Compute Behavioural Risk Profile
- **Endpoint:** `POST /api/v1/behavioural/questionnaire/submit/`
- **Request Body:**
```json
{
  "answers": [
    {"question_id": "q1", "selected_score": 60},
    {"question_id": "q2", "selected_score": 75},
    {"question_id": "q3", "selected_score": 40}
  ]
}
```
- **Response (`200 OK`):**
```json
{
  "risk_tolerance_score": 68,
  "risk_category": "MODERATE_GROWTH",
  "detected_biases": [
    {
      "name": "Loss Aversion",
      "severity": "MODERATE",
      "description": "Tendency to feel pain from investment losses twice as strongly as equal gains.",
      "mitigation_strategy": "Establish pre-committed rebalancing bands and limit portfolio checking frequency."
    },
    {
      "name": "Overconfidence in Technology",
      "severity": "ELEVATED",
      "description": "High concentration in tech growth assets increases drawdowns during rate hiking cycles."
    }
  ]
}
```

---

## 7. Wealth & Tax Optimisation Endpoints

### 7.1 Tax-Loss Harvesting Simulator
- **Endpoint:** `POST /api/v1/wealth/tax-harvest/`
- **Request Body:**
```json
{
  "portfolio_id": 1,
  "tax_rate_short_term": 0.35,
  "tax_rate_long_term": 0.20
}
```
- **Response (`200 OK`):**
```json
{
  "total_harvestable_losses": 3450.00,
  "estimated_tax_savings": 1207.50,
  "harvestable_opportunities": [
    {
      "symbol": "INTC",
      "unrealized_loss": -2100.00,
      "holding_period_days": 140,
      "substitute_asset": {
        "symbol": "SMH",
        "name": "VanEck Semiconductor ETF",
        "tracking_corr": 0.91
      },
      "wash_sale_safe_date": "2026-12-16"
    }
  ]
}
```

### 7.2 Portfolio Rebalancing Optimizer
- **Endpoint:** `POST /api/v1/wealth/rebalance/`
- **Request Body:**
```json
{
  "portfolio_id": 1,
  "target_allocation": {
    "EQUITY": 0.70,
    "FIXED_INCOME": 0.20,
    "CASH": 0.10
  }
}
```
- **Response (`200 OK`):**
```json
{
  "current_drift_max": 0.1174,
  "rebalance_required": true,
  "suggested_trades": [
    {"symbol": "NVDA", "action": "SELL", "shares": 30, "estimated_value": 4275.00},
    {"symbol": "TLT", "action": "BUY", "shares": 45, "estimated_value": 4275.00}
  ]
}
```

### 7.3 Monte Carlo Wealth Projections
- **Endpoint:** `POST /api/v1/wealth/projections/`
- **Request Body:**
```json
{
  "initial_wealth": 128450.00,
  "monthly_contribution": 1500.00,
  "years": 20,
  "expected_return": 0.08,
  "volatility": 0.15,
  "simulations_count": 1000
}
```
- **Response (`200 OK`):**
```json
{
  "years": 20,
  "percentile_10th": 684200.00,
  "percentile_50th_median": 1184900.00,
  "percentile_90th": 1948500.00,
  "probability_of_reaching_million": 0.68
}
```

---

## 8. PLUTUS Finance-Only AI Assistant

### 8.1 Finance AI Chat with Server-Side Guardrails
- **Endpoint:** `POST /api/v1/assistant/chat/`
- **Auth:** Bearer Token
- **Request Body:**
```json
{
  "message": "Can you analyze my portfolio concentration and explain why NVDA at 27% might pose a risk?",
  "portfolio_id": 1,
  "conversation_id": "conv_94821"
}
```

- **Response (`200 OK`):**
```json
{
  "conversation_id": "conv_94821",
  "reply": "Your portfolio has a Herfindahl-Hirschman Index of 0.198, reflecting elevated concentration risk. NVDA currently accounts for 27.73% of your total equity allocation. While semiconductor demand remains strong, holding over a quarter of total assets in a single stock exposes your capital to idiosyncratic downside if earnings multiple compression or export restrictions occur. Consider sizing individual positions below 15% and diversifying into broader semiconductor ETFs like SMH to maintain sector exposure with reduced single-issuer risk.",
  "domain_classification": {
    "is_financial": true,
    "confidence": 0.99,
    "topics": ["portfolio_risk", "concentration", "asset_allocation"]
  },
  "sources": [
    {"source": "Backend Analytics Service", "metric": "HHI: 0.198, NVDA weight: 27.73%"}
  ]
}
```

#### Out-of-Scope Enforcement
If a user submits a non-financial query:
- **Request:** `{"message": "Write me a Python script to scrape Twitter posts."}`
- **Response (`200 OK`):**
```json
{
  "reply": "I am PLUTUS AI, an assistant dedicated exclusively to quantitative financial analysis, portfolio intelligence, risk modeling, and wealth planning. I cannot answer queries unrelated to finance, markets, or economics.",
  "domain_classification": {
    "is_financial": false,
    "confidence": 1.0,
    "topics": ["general_coding"]
  }
}
```

---

## 9. Research Intelligence Endpoints

### 9.1 Quantitative Research Models
- **Endpoint:** `GET /api/v1/research/models/`
- **Response (`200 OK`):**
```json
[
  {
    "id": "model_regime_switch",
    "name": "Markov Regime Switching Volatility Forecaster",
    "version": "v2.4.1",
    "asset_universe": "US_LARGE_CAP",
    "target_horizon": "10_DAYS",
    "status": "PRODUCTION",
    "metrics": {
      "sharpe": 1.92,
      "max_drawdown": -0.078,
      "hit_ratio": 0.634,
      "calmar_ratio": 2.46
    },
    "last_backtested": "2026-11-15T00:00:00Z"
  }
]
```

---

## 10. Alerts & Activity Endpoints

### 10.1 List & Manage Alerts
- **Endpoint:** `GET /api/v1/alerts/` & `POST /api/v1/alerts/read-all/`
- **Response (`200 OK`):**
```json
[
  {
    "id": 1,
    "title": "Drift Alert: NVDA Position Exceeds 25%",
    "message": "NVDA currently represents 27.73% of your portfolio, crossing your defined rebalance threshold.",
    "severity": "WARNING",
    "is_read": false,
    "created_at": "2026-11-15T21:10:00Z"
  }
]
```


## Authentication updates

- `POST /api/v1/auth/register/` creates an account with username, unique email, password and password confirmation.
- `POST /api/v1/auth/token/` accepts the `username` field with either a username or an email address, plus password.
- `POST /api/v1/auth/token/refresh/` rotates/refreshes an access token.
- `GET /api/v1/profile/` returns the authenticated user's profile and account preferences.
- All portfolio and user-specific endpoints require a valid Bearer access token.


## Dashboard

- `GET /api/v1/dashboard/` returns the authenticated user's default portfolio summary, holdings, allocation, recent transactions and saved portfolio snapshots.
- It creates an empty `INR` portfolio with a zero cash balance when the account has no portfolio yet. This is an account workspace record, not seeded investment/demo data.
- Benchmark rows marked as sample/demo are excluded. Risk summary and AI insight are returned as null until there are validated data/AI services to supply them.
