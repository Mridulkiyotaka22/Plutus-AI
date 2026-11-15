from decimal import Decimal
from typing import List, Dict, Any
from .models import Portfolio, Transaction, TransactionType
from apps.market_data.models import Instrument

class PortfolioLedgerService:
    @staticmethod
    def calculate_holdings(portfolio: Portfolio) -> List[Dict[str, Any]]:
        """
        Derives current holdings from the transaction ledger using Average Cost Basis.
        """
        transactions = Transaction.objects.filter(portfolio=portfolio).order_by('trade_date')
        holdings_map = {}

        for tx in transactions:
            if not tx.instrument:
                continue
            symbol = tx.instrument.symbol
            if symbol not in holdings_map:
                holdings_map[symbol] = {
                    'instrument': tx.instrument,
                    'shares': Decimal('0'),
                    'total_cost': Decimal('0'),
                }

            record = holdings_map[symbol]
            if tx.type == TransactionType.BUY:
                record['shares'] += tx.shares
                record['total_cost'] += (tx.shares * tx.price) + tx.fees
            elif tx.type == TransactionType.SELL:
                if record['shares'] > 0:
                    avg_cost = record['total_cost'] / record['shares']
                    sell_shares = min(tx.shares, record['shares'])
                    record['shares'] -= sell_shares
                    record['total_cost'] -= (sell_shares * avg_cost)

        holdings_list = []
        total_portfolio_value = Decimal('0')

        # First pass to compute values
        computed = []
        for symbol, data in holdings_map.items():
            shares = data['shares']
            if shares <= Decimal('0.0001'):
                continue
            avg_cost = (data['total_cost'] / shares) if shares > 0 else Decimal('0')
            current_price = data['instrument'].current_price
            market_value = shares * current_price
            gain_loss = market_value - data['total_cost']
            gain_loss_pct = (gain_loss / data['total_cost'] * 100) if data['total_cost'] > 0 else Decimal('0')

            total_portfolio_value += market_value
            computed.append({
                'symbol': symbol,
                'name': data['instrument'].name,
                'asset_class': data['instrument'].get_asset_type_display(),
                'shares': float(shares),
                'avg_cost': float(avg_cost),
                'current_price': float(current_price),
                'market_value': float(market_value),
                'gain_loss': float(gain_loss),
                'gain_loss_pct': float(gain_loss_pct),
            })

        # Second pass to compute allocation percentage
        for item in computed:
            item['allocation_pct'] = round(
                (item['market_value'] / float(total_portfolio_value) * 100), 2
            ) if total_portfolio_value > 0 else 0.0
            holdings_list.append(item)

        return sorted(holdings_list, key=lambda x: x['market_value'], reverse=True)

    @staticmethod
    def get_summary(portfolio: Portfolio) -> Dict[str, Any]:
        """Return a summary based only on this portfolio's stored records.

        Daily P&L is available only when a real portfolio snapshot exists. No
        synthetic baseline, return estimate, or demo metric is substituted.
        """
        holdings = PortfolioLedgerService.calculate_holdings(portfolio)
        holdings_value = sum(h['market_value'] for h in holdings)
        cash_balance = float(portfolio.cash_balance)
        total_value = holdings_value + cash_balance

        transactions = list(Transaction.objects.filter(portfolio=portfolio))
        cash_flows = [tx for tx in transactions if tx.type in (TransactionType.DEPOSIT, TransactionType.WITHDRAWAL)]
        if cash_flows:
            invested = sum(
                float(tx.amount) if tx.type == TransactionType.DEPOSIT else -float(tx.amount)
                for tx in cash_flows
            )
        else:
            buys = sum(float(tx.amount) + float(tx.fees) for tx in transactions if tx.type == TransactionType.BUY)
            sells = sum(float(tx.amount) - float(tx.fees) for tx in transactions if tx.type == TransactionType.SELL)
            invested = max(buys - sells, 0.0)

        latest_snapshot = portfolio.snapshots.order_by('-timestamp').first()
        daily_change = float(latest_snapshot.daily_change) if latest_snapshot else 0.0
        daily_change_pct = float(latest_snapshot.daily_change_pct) if latest_snapshot else 0.0

        overall_gain = total_value - invested if invested > 0 else 0.0
        overall_gain_pct = (overall_gain / invested * 100) if invested > 0 else 0.0
        has_activity = bool(transactions)

        return {
            'portfolio_id': str(portfolio.id),
            'name': portfolio.name,
            'base_currency': portfolio.base_currency,
            'total_value': round(total_value, 2),
            'invested_capital': round(invested, 2),
            'cash_balance': round(cash_balance, 2),
            'holdings_value': round(holdings_value, 2),
            'daily_change': round(daily_change, 2),
            'daily_change_pct': round(daily_change_pct, 2),
            'daily_change_available': latest_snapshot is not None,
            'overall_gain': round(overall_gain, 2),
            'overall_gain_pct': round(overall_gain_pct, 2),
            'holdings_count': len(holdings),
            'has_activity': has_activity,
            'status': 'DATA_AVAILABLE' if has_activity else 'NO_PORTFOLIO_ACTIVITY',
        }
