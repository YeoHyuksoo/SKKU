# Generated by Django 3.0.6 on 2020-05-31 06:17

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('sign', '0003_like'),
    ]

    operations = [
        migrations.CreateModel(
            name='Receipt',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('address', models.CharField(max_length=100)),
                ('total', models.IntegerField(default=0)),
                ('userid', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='sign.Member')),
            ],
        ),
    ]
