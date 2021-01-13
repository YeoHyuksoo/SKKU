from django.db import models

# Create your models here.

class Computer(models.Model):
    name = models.CharField(max_length=20)
    introduction = models.TextField()
    released = models.DateTimeField('date released')
    price = models.IntegerField(default=0)

    def __str__(self):
        return self.name

