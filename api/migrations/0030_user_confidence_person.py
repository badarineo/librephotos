# Generated by Django 3.1.14 on 2022-08-08 13:39

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("api", "0029_change_to_text_field"),
    ]

    operations = [
        migrations.AddField(
            model_name="user",
            name="confidence_person",
            field=models.FloatField(default=0.9),
        ),
    ]
