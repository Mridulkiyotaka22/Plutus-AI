from decimal import Decimal
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('portfolios', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='portfolio',
            name='base_currency',
            field=models.CharField(default='INR', max_length=10),
        ),
        migrations.AlterField(
            model_name='portfolio',
            name='cash_balance',
            field=models.DecimalField(decimal_places=2, default=Decimal('0.00'), max_digits=16),
        ),
    ]
