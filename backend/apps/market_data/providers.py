from abc import ABC, abstractmethod
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional
import logging
import math

logger = logging.getLogger(__name__)


class MarketDataProvider(ABC):
    @abstractmethod
    def get_quote(self, symbol: str) -> Optional[Dict[str, Any]]:
        """Return the latest available quote, or None when unavailable."""

    @abstractmethod
    def get_historical_ohlcv(
        self, symbol: str, period: str = "1mo", interval: str = "1d"
    ) -> List[Dict[str, Any]]:
        """Return timestamped OHLCV rows from the configured provider."""


class YFinanceMarketDataProvider(MarketDataProvider):
    """Yahoo Finance data adapter through yfinance.

    yfinance is an unofficial wrapper around Yahoo Finance's publicly available
    interfaces. The returned quote is the most recent value available to Yahoo,
    which may be delayed or simply the last completed daily bar. It is not a
    guaranteed real-time exchange feed.
    """

    SOURCE = "Yahoo Finance via yfinance (latest available; may be delayed)"

    @staticmethod
    def _finite(value: Any) -> Optional[float]:
        try:
            result = float(value)
            return result if math.isfinite(result) else None
        except (TypeError, ValueError):
            return None

    @staticmethod
    def _fast_value(fast_info: Any, *keys: str) -> Any:
        for key in keys:
            try:
                value = fast_info.get(key)
                if value is not None:
                    return value
            except Exception:
                pass
            try:
                value = getattr(fast_info, key)
                if value is not None:
                    return value
            except Exception:
                pass
        return None

    def get_quote(self, symbol: str) -> Optional[Dict[str, Any]]:
        try:
            import yfinance as yf

            ticker = yf.Ticker(symbol)
            history = ticker.history(
                period="5d", interval="1d", auto_adjust=False,
                actions=False, raise_errors=False,
            )
            if history is None or history.empty:
                logger.info("No Yahoo Finance quote rows for %s", symbol)
                return None

            history = history.dropna(subset=["Close"])
            if history.empty:
                return None

            latest = history.iloc[-1]
            previous = history.iloc[-2] if len(history) > 1 else None
            try:
                fast_info = ticker.fast_info
            except Exception:
                fast_info = {}
            last_price = self._finite(self._fast_value(fast_info, "last_price", "lastPrice"))
            previous_close = self._finite(
                self._fast_value(fast_info, "previous_close", "previousClose")
            )

            # fast_info can be incomplete; use the last completed daily candles
            # as a dependable fallback. Never invent a price when both fail.
            close = self._finite(latest.get("Close"))
            price = last_price if last_price and last_price > 0 else close
            if price is None or price <= 0:
                return None
            if previous_close is None or previous_close <= 0:
                previous_close = self._finite(previous.get("Close")) if previous is not None else None

            change = price - previous_close if previous_close and previous_close > 0 else None
            change_percent = (change / previous_close * 100) if change is not None else None
            volume = self._finite(latest.get("Volume")) or 0
            timestamp = latest.name
            if hasattr(timestamp, "to_pydatetime"):
                timestamp = timestamp.to_pydatetime()
            if getattr(timestamp, "tzinfo", None) is None:
                timestamp = timestamp.replace(tzinfo=timezone.utc)

            currency = self._fast_value(fast_info, "currency")
            return {
                "symbol": symbol,
                "available": True,
                "price": price,
                "change": change,
                "change_percent": change_percent,
                "previous_close": previous_close,
                "volume": int(volume),
                "currency": currency,
                "source": self.SOURCE,
                "timestamp": timestamp.isoformat(),
                "quote_type": "latest_available",
            }
        except Exception as exc:
            logger.warning("yfinance quote failed for %s: %s", symbol, exc, exc_info=True)
            return None

    def get_historical_ohlcv(
        self, symbol: str, period: str = "1mo", interval: str = "1d"
    ) -> List[Dict[str, Any]]:
        allowed_periods = {"1d", "5d", "1mo", "3mo", "6mo", "1y", "2y", "5y", "10y", "ytd", "max"}
        allowed_intervals = {"1m", "2m", "5m", "15m", "30m", "60m", "90m", "1h", "1d", "5d", "1wk", "1mo", "3mo"}
        if period not in allowed_periods or interval not in allowed_intervals:
            raise ValueError("Unsupported yfinance period or interval")

        try:
            import yfinance as yf
            ticker = yf.Ticker(symbol)
            frame = ticker.history(
                period=period, interval=interval, auto_adjust=False,
                actions=False, raise_errors=False,
            )
            if frame is None or frame.empty:
                return []
            result: List[Dict[str, Any]] = []
            for timestamp, row in frame.iterrows():
                open_value = self._finite(row.get("Open"))
                high_value = self._finite(row.get("High"))
                low_value = self._finite(row.get("Low"))
                close_value = self._finite(row.get("Close"))
                if None in (open_value, high_value, low_value, close_value):
                    continue
                dt = timestamp.to_pydatetime() if hasattr(timestamp, "to_pydatetime") else timestamp
                if getattr(dt, "tzinfo", None) is None:
                    dt = dt.replace(tzinfo=timezone.utc)
                volume = self._finite(row.get("Volume")) or 0
                result.append({
                    "timestamp": dt.isoformat(),
                    "open": open_value,
                    "high": high_value,
                    "low": low_value,
                    "close": close_value,
                    "volume": int(volume),
                    "source": "Yahoo Finance via yfinance (historical)",
                })
            return result
        except ValueError:
            raise
        except Exception as exc:
            logger.warning("yfinance history failed for %s: %s", symbol, exc, exc_info=True)
            return []


def get_market_data_provider() -> MarketDataProvider:
    # Keep this factory so the provider can be replaced by a licensed API later.
    return YFinanceMarketDataProvider()
