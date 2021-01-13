
from django.urls import path
from . import views

urlpatterns = [
    path('<int:member_id>/', views.index),
    path('<int:member_id>/bucket/', views.bucket),
    path('<int:member_id>/receipt/', views.receipt),
]
