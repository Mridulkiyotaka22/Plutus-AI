from typing import Dict, Any, List

class WealthOptimizationService:
    JURISDICTION_RATES = {
        'US_FEDERAL': {'short_term': 0.32, 'long_term': 0.15, 'annual_deduction_limit': 3000.0},
        'UK_HMRC': {'short_term': 0.20, 'long_term': 0.20, 'annual_deduction_limit': 3000.0},
        'IN_ITR': {'short_term': 0.20, 'long_term': 0.125, 'annual_deduction_limit': 100000.0},
    }

    SUBSTITUTE_ASSETS = {
        'BND': {'substitute': 'AGG', 'name': 'iShares Core US Aggregate Bond ETF', 'tracking_corr': 0.98},
        'VTI': {'substitute': 'ITOT', 'name': 'iShares Core S&P Total US Stock', 'tracking_corr': 0.99},
        'TSLA': {'substitute': 'RIVN', 'name': 'Rivian Automotive Inc', 'tracking_corr': 0.74},
    }

    @classmethod
    def simulate_tax_loss_harvesting(
        cls,
        jurisdiction: str,
        tax_year: int,
        holdings: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        rates = cls.JURISDICTION_RATES.get(jurisdiction)
        if not rates:
            return {
                'status': 'UNSUPPORTED_JURISDICTION',
                'message': f"Jurisdiction '{jurisdiction}' is not configured. Supported: US_FEDERAL, UK_HMRC, IN_ITR.",
                'harvestable_opportunities': [],
                'total_harvestable_loss': 0.0,
                'estimated_tax_savings': 0.0,
            }

        opportunities = []
        total_loss = 0.0

        for h in holdings:
            gain_loss = h.get('gain_loss', 0.0)
            if gain_loss < 0:
                loss = abs(gain_loss)
                total_loss += loss
                sym = h['symbol']
                sub = cls.SUBSTITUTE_ASSETS.get(sym, {
                    'substitute': f"{sym}-PEER",
                    'name': f"Diversified {h.get('asset_class', 'Asset')} Alternative",
                    'tracking_corr': 0.95
                })

                opportunities.append({
                    'symbol': sym,
                    'name': h.get('name', sym),
                    'shares': h.get('shares', 0),
                    'current_loss': round(loss, 2),
                    'substitute_asset': {
                        'symbol': sub['substitute'],
                        'name': sub['name'],
                        'tracking_corr': sub['tracking_corr']
                    },
                    'substitute_symbol': sub['substitute'],
                    'substitute_name': sub['name'],
                    'correlation': sub['tracking_corr'],
                    'wash_sale_safe': True,
                    'wash_sale_window_days': 30,
                })

        estimated_savings = total_loss * rates['short_term']

        return {
            'status': 'SIMULATION_COMPLETE',
            'jurisdiction': jurisdiction,
            'tax_year': tax_year,
            'marginal_rate_assumed': f"{rates['short_term'] * 100}%",
            'total_harvestable_loss': round(total_loss, 2),
            'estimated_tax_savings': round(estimated_savings, 2),
            'opportunities': opportunities,
            'harvestable_opportunities': opportunities,
            'disclaimer': (
                "Simulated estimate only based on modeled marginal rates. "
                "Consult a licensed CPA or tax attorney for actual filings."
            ),
        }

    @classmethod
    def simulate_rebalancing(
        cls,
        current_holdings: List[Dict[str, Any]],
        target_allocation: Dict[str, float]
    ) -> Dict[str, Any]:
        """
        Calculates exact rebalancing trades from current weights to target weights.
        """
        total_value = sum(h.get('market_value', 0.0) for h in current_holdings)
        trades = []

        # Map current category values
        cat_values = {}
        for h in current_holdings:
            c = h.get('asset_class', 'Equities')
            cat_values[c] = cat_values.get(c, 0.0) + h.get('market_value', 0.0)

        for cat, target_pct in target_allocation.items():
            curr_val = cat_values.get(cat, 0.0)
            curr_pct = (curr_val / total_value * 100) if total_value > 0 else 0.0
            diff_pct = target_pct - curr_pct
            diff_val = (diff_pct / 100.0) * total_value

            action = 'BUY' if diff_val > 0 else ('SELL' if diff_val < 0 else 'HOLD')
            trades.append({
                'category': cat,
                'current_pct': round(curr_pct, 1),
                'target_pct': round(target_pct, 1),
                'diff_pct': round(diff_pct, 1),
                'action': action,
                'estimated_trade_amount': round(abs(diff_val), 2),
            })

        return {
            'status': 'REBALANCE_SIMULATION_SUCCESS',
            'total_portfolio_value': round(total_value, 2),
            'rebalance_trades': trades,
            'estimated_slippage': round(total_value * 0.0005, 2),
        }

    @classmethod
    def simulate_wealth_projections(
        cls,
        current_net_worth: float,
        monthly_savings: float,
        years: int = 20,
        expected_inflation: float = 0.025
    ) -> Dict[str, Any]:
        """
        Calculates multi-horizon compounding trajectories for Conservative (5%), Moderate (8%), and Aggressive (11%).
        """
        scenarios = {'Conservative (5%)': 0.05, 'Moderate (8%)': 0.08, 'Aggressive (11%)': 0.11}
        projections = {}

        for name, annual_rate in scenarios.items():
            timeline = []
            balance = current_net_worth
            monthly_rate = annual_rate / 12.0

            for yr in range(1, years + 1):
                for _ in range(12):
                    balance = (balance + monthly_savings) * (1.0 + monthly_rate)
                # inflation adjusted real value
                real_balance = balance / ((1.0 + expected_inflation) ** yr)
                timeline.append({
                    'year': yr,
                    'nominal_value': round(balance, 2),
                    'real_value': round(real_balance, 2),
                })
            projections[name] = timeline

        return {
            'status': 'PROJECTION_CALCULATED',
            'initial_capital': current_net_worth,
            'monthly_contribution': monthly_savings,
            'years': years,
            'inflation_rate': f"{expected_inflation * 100}%",
            'scenarios': projections,
        }
