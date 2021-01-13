from django.shortcuts import render
from django.http import HttpResponse

from .models import Computer
from sign.models import Bucket, Member, Like, Receipt

def index(request, member_id):
    computers = Computer.objects.all()

    context = {'computers':computers}
    ##str = ''
    ##for computer in computers:
    ##    str+="<p>{}<br>".format(computer.name)
    ##str+="</p>"
    ##return HttpResponse(str)
    member_id=member_id+1
    if request.method == "POST":
        if 'piece' in request.POST:
            member = Member.objects.get(id=member_id)
            product = request.POST["piece"]
            computer = Computer.objects.get(id=product)
            print(computer.name)
            Bucket.objects.create(userid=member, name=computer.name, price=computer.price)
        else:
            member = Member.objects.get(id=member_id)
            product = request.POST["like"]
            computer = Computer.objects.get(id=product)
            Like.objects.create(userid=member, name=computer.name, introduction=computer.introduction, price=computer.price)
    return render(request, 'market/market.html', context)

def bucket(request, member_id):
    member_id=member_id+1
    mys = Bucket.objects.filter(userid=member_id)
    likes = Like.objects.filter(userid=member_id)
    members = Member.objects.filter(id=member_id)
    ##context = {'mys':mys, 'likes':likes, 'members':members, 'total':totalprice}
    if request.method == "POST":
        if 'delete' in request.POST:
            did = request.POST["delete"]
            Bucket.objects.filter(id=did, userid=member_id).delete()
            mys = Bucket.objects.filter(userid=member_id)
        else:
            lid = request.POST["like"]
            Like.objects.filter(id=lid, userid=member_id).delete()
            likes = Like.objects.filter(userid=member_id)
    totalprice=0
    for my in mys:
        totalprice+=my.price
    context = {'mys':mys, 'likes':likes, 'members':members, 'total':totalprice}
    return render(request, 'market/bucket.html', context)

def receipt(request, member_id):
    member_id=member_id+1
    mys = Bucket.objects.filter(userid=member_id)
    member = Member.objects.get(id=member_id)
    totalprice=0
    for my in mys:
        totalprice+=my.price
    print(totalprice)
    Receipt.objects.create(userid=member, address=member.address, total=totalprice) 
    receipts = Receipt.objects.filter(userid=member_id)
    context = {'receipts':receipts}
    return render(request, 'market/receipt.html', context)

# Create your views here.
