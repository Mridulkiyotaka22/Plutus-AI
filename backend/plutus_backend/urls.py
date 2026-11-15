from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/auth/', include('apps.accounts.urls')),
    path('api/v1/profile/', include('apps.accounts.profile_urls')),
    path('api/v1/market/', include('apps.market_data.urls')),
    path('api/v1/watchlists/', include('apps.market_data.watchlist_urls')),
    path('api/v1/dashboard/', include('apps.portfolios.dashboard_urls')),
    path('api/v1/portfolios/', include('apps.portfolios.urls')),
    path('api/v1/analytics/', include('apps.analytics.urls')),
    path('api/v1/behavioural/', include('apps.behavioural_finance.urls')),
    path('api/v1/assistant/', include('apps.assistant.urls')),
    path('api/v1/wealth/', include('apps.wealth.urls')),
    path('api/v1/research/', include('apps.research.urls')),
    path('api/v1/alerts/', include('apps.alerts.urls')),
]
