from django.shortcuts import render

from django.http import HttpResponse

from .models import Member, Bucket
from market.models import Computer
from django.contrib import auth
from django.contrib.auth.hashers import make_password, check_password


def index(request):
    return HttpResponse("Hello world")
# Create your views here.


def signup(request):
    if request.method == "POST":
        member = Member.objects.create(userid=request.POST["userid"], userpw=request.POST["userpw"],
                                            mem_name=request.POST["nickname"], age=request.POST["age"],
                                            address=request.POST["address"], gender=request.POST["gender"])
        return render(request, 'sign/signin.html')
    return render(request, 'sign/signup.html')

def signin(request):
    if request.method == "POST":
        user_id=request.POST['userid']
        user_pw=request.POST['userpw']
        user = Member.objects.get(userid=user_id)
        user.id=user.id-1
        if user_pw == user.userpw:
            ##computers = Computer.objects.all()
            ##context = {'computers':computers}
            context = {'user':user}
            return render(request, 'sign/menu.html', context)
        ##user = auth.authenticate(request, userid=userid, userpw=userpw)
        ##if user is not None:
            ##return render(request, 'market/market.html')
    return render(request, 'sign/signin.html')

def menu(request):
    return render(request, 'sign/menu.html')

def administrator(request):
    if request.method == "POST":
        computer = Computer.objects.create(name=request.POST["name"], introduction=request.POST["introduction"],
                                           released=request.POST["released"], price=request.POST["price"])

    return render(request, 'sign/administrator.html')
