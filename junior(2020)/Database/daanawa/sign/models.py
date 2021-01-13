from django.db import models

# Create your models here.

class Member(models.Model):
    userid=models.CharField(max_length=15)
    userpw=models.CharField(max_length=15)
    mem_name=models.CharField(max_length=20)
    age=models.IntegerField(default=1)
    address=models.CharField(max_length=100)
    gender=models.CharField(max_length=10)

class Bucket(models.Model):
    userid=models.ForeignKey(Member, on_delete=models.CASCADE)
    name=models.CharField(max_length=20)
    price=models.IntegerField(default=0)

class Like(models.Model):
    userid=models.ForeignKey(Member, on_delete=models.CASCADE)
    name=models.CharField(max_length=20)
    introduction = models.TextField()
    price=models.IntegerField(default=0)


class Receipt(models.Model):
    userid=models.ForeignKey(Member, on_delete=models.CASCADE)
    address=models.CharField(max_length=100)
    total=models.IntegerField(default=0)
