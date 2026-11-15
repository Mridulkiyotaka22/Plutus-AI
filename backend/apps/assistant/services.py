import os
import re
from typing import Dict, Any, Tuple
from django.conf import settings
from apps.portfolios.models import Portfolio
from apps.portfolios.services import PortfolioLedgerService

class DomainClassifier:
    """
    Server-side finance domain classification and safety guardrail.
    Ensures PLUTUS AI only answers finance, investment, market and wealth topics.
    """
    FINANCE_KEYWORDS = [
        'portfolio', 'stock', 'share', 'bond', 'yield', 'dividend', 'market',
        'crypto', 'bitcoin', 'ethereum', 'asset', 'allocation', 'rebalance',
        'tax', 'harvest', 'loss', 'gain', 'p&l', 'sharpe', 'sortino', 'var',
        'drawdown', 'beta', 'risk', 'inflation', 'interest', 'rate', 'fed',
        'liquidity', 'cash', 'etf', 'index', 'nasdaq', 's&p', 'nifty', 'dow',
        'volatility', 'wealth', 'invest', 'hedge', 'trading', 'valuation',
        'pe ratio', 'earnings', 'revenue', 'capital', 'balance', 'nvda', 'aapl',
        'msft', 'tsla', 'bnd', 'gld'
    ]

    OUT_OF_SCOPE_PATTERNS = [
        r'\b(cook|recipe|dinner|food|cake|bake)\b',
        r'\b(movie|film|actor|cinema|hollywood)\b',
        r'\b(football|soccer|basketball|cricket|tennis|game|playstation|xbox)\b',
        r'\b(poem|poetry|rhyme|song|lyrics|rap)\b',
        r'\b(weather|forecast|rain|temperature)\b',
        r'\b(dating|relationship|romance|love)\b',
        r'\b(politics|president|election|vote)\b',
    ]

    @classmethod
    def is_finance_related(cls, prompt: str) -> Tuple[bool, str]:
        prompt_lower = prompt.lower().strip()

        # Check explicit out of scope patterns
        for pattern in cls.OUT_OF_SCOPE_PATTERNS:
            if re.search(pattern, prompt_lower):
                return False, (
                    "I am PLUTUS AI, an assistant dedicated exclusively to financial intelligence, "
                    "wealth management, portfolio diagnostics and markets. "
                    "I cannot assist with general, entertainment or non-financial topics."
                )

        # Check if contains financial vocabulary
        contains_finance = any(kw in prompt_lower for kw in cls.FINANCE_KEYWORDS)
        if not contains_finance and len(prompt_lower.split()) > 3:
            return False, (
                "Your question appears outside the financial domain. "
                "PLUTUS AI is specialized exclusively in market analysis, portfolio performance, "
                "risk management and wealth optimization. Please rephrase with a financial question."
            )

        return True, ""

class FinanceAssistantService:
    @staticmethod
    def answer_query(user, query: str, conversation_id: str = None) -> Dict[str, Any]:
        is_scope, rejection_msg = DomainClassifier.is_finance_related(query)

        if not is_scope:
            return {
                'answer': rejection_msg,
                'is_in_scope': False,
                'sources': ['PLUTUS Domain Guardrail'],
                'disclaimers': 'Query rejected by domain classification safety filter.',
            }

        # Gather authorized portfolio context
        portfolio = Portfolio.objects.filter(user=user, is_default=True).first()
        portfolio_context = ""
        sources = ["PLUTUS Verified Analytics Engine"]

        if portfolio:
            summary = PortfolioLedgerService.get_summary(portfolio)
            holdings = PortfolioLedgerService.calculate_holdings(portfolio)[:5]
            holdings_str = ", ".join([f"{h['symbol']} ({h['allocation_pct']}%)" for h in holdings])
            portfolio_context = (
                f"User Portfolio Summary:\n"
                f"- Total Value: ${summary['total_value']:,.2f}\n"
                f"- Invested Capital: ${summary['invested_capital']:,.2f}\n"
                f"- Daily P&L: +${summary['daily_change']:,.2f} (+{summary['daily_change_pct']}%)\n"
                f"- Overall Return: +${summary['overall_gain']:,.2f} (+{summary['overall_gain_pct']}%)\n"
                f"- Top Holdings: {holdings_str}\n"
            )
            sources.append(f"Portfolio: {portfolio.name}")

        groq_key = getattr(settings, 'GROQ_API_KEY', '') or os.getenv('GROQ_API_KEY', '')

        if groq_key and not groq_key.startswith('gsk_your'):
            try:
                from groq import Groq
                client = Groq(api_key=groq_key)
                system_prompt = (
                    "You are PLUTUS AI, an elite institutional financial intelligence assistant. "
                    "You answer only questions related to finance, wealth, markets, and portfolio management. "
                    "Strictly adhere to factual calculations and financial prudence. "
                    "Never guarantee investment returns and never execute orders. "
                    "Keep answers concise, actionable, and structured with clean markdown.\n\n"
                    f"Verified Context:\n{portfolio_context}"
                )
                chat_completion = client.chat.completions.create(
                    messages=[
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": query}
                    ],
                    model=getattr(settings, 'GROQ_MODEL', 'llama-3.3-70b-versatile'),
                    temperature=0.2,
                    max_tokens=650,
                )
                answer = chat_completion.choices[0].message.content
                sources.append("Groq LLaMA-3.3-70B Analytics")
                return {
                    'answer': answer,
                    'is_in_scope': True,
                    'sources': sources,
                    'disclaimers': 'PLUTUS AI provides educational intelligence and analytics, not formal financial advice.',
                }
            except Exception as e:
                # If Groq call fails, fallback gracefully
                pass

        # Do not fabricate portfolio figures or claim that an LLM response was generated.
        unavailable_answer = (
            "Your question passed PLUTUS AI's finance-topic check, but the live AI service is "
            "not configured or is temporarily unavailable. Configure a valid GROQ_API_KEY in "
            "backend/.env and restart the backend to enable AI-generated explanations. "
            "No portfolio metrics or market facts have been generated for this response."
        )
        return {
            'answer': unavailable_answer,
            'is_in_scope': True,
            'sources': sources + ['PLUTUS AI service configuration status'],
            'disclaimers': 'No live AI answer was produced. Configure GROQ_API_KEY to enable the assistant.',
        }
