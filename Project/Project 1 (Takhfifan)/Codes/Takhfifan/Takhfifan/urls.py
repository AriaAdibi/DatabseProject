"""Takhfifan URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.9/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from django.conf import settings
from django.conf.urls.static import static
from django.conf.urls import url
from django.contrib import admin
from django.views.generic import RedirectView

from discounts.views import *

urlpatterns = [
    url(r'^remove/$', remove, name='remove'),
    url(r'^finalize/$', finalize, name='finalize'),
    url(r'^signup$', signup, name='signup'),
    url(r'^login$', login, name='login'),
    url(r'^logout/$', logout, name='logout'),
    url(r'^logout$', RedirectView.as_view(pattern_name='logout', permanent=True)),
    url(r'^edit/$', edit, name='edit'),
    url(r'^edit$', RedirectView.as_view(pattern_name='edit', permanent=True)),
    url(r'^cart/$', show_cart, name='show_cart'),
    url(r'^cart$', RedirectView.as_view(pattern_name='show_cart', permanent=True)),
    url(r'^history/(?P<page>\d+)/$', history, name='history'),
    url(r'^history/(?P<page>\d+)$', RedirectView.as_view(pattern_name='history', permanent=True)),
    url(r'^history/$', RedirectView.as_view(pattern_name='history', permanent=True), {'page': 1}),
    url(r'^history$', RedirectView.as_view(pattern_name='history', permanent=True), {'page': 1}),
    url(r'^addtocart/(?P<couponID>\d+)/$', add_to_cart, name='add_to_cart'),
    url(r'^addtocart/(?P<couponID>\d+)$', RedirectView.as_view(pattern_name='add_to_cart', permanent=True)),
    url(r'^search/(?P<page>\d+)$', search, name='search'),
    url(r'^search$', RedirectView.as_view(pattern_name='search', query_string=True, permanent=True), {'page': 1}),
    url(r'^discount/(?P<discount_id>\d+)/$', show_discount, name='discount'),
    url(r'^discount/(?P<discount_id>\d+)$', RedirectView.as_view(pattern_name='discount', permanent=True)),
    url(r'^category/(?P<category>\w+)/(?P<page>\d+)/$', show_category, name='categories'),
    url(r'^category/(?P<category>\w+)/(?P<page>\d+)$', RedirectView.as_view(pattern_name='categories', permanent=True)),
    url(r'^category/(?P<category>\w+)/$', RedirectView.as_view(pattern_name='categories', permanent=True), {'page': 1}),
    url(r'^category/(?P<category>\w+)$', RedirectView.as_view(pattern_name='categories', permanent=True), {'page': 1}),
    url(r'^$', RedirectView.as_view(pattern_name='categories', permanent=True), {'category': 'new', 'page': 1}, name='home'),
    url(r'^admin/', admin.site.urls)
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)