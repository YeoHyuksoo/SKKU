
from django.urls import path
from . import views

urlpatterns = [
    path('', views.index),
    path('signup/', views.signup),
    path('signin/', views.signin),
    path('menu/', views.menu),
    path('administrator/', views.administrator),
]
