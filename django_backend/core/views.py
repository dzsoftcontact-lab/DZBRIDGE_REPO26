from django.shortcuts import render
from django.http import JsonResponse, HttpResponse, Http404
import os
from django.conf import settings

FRONTEND_DIR = os.path.abspath(os.path.join(settings.BASE_DIR, '..', 'frontend'))

def test_client_view(request):
    """
    Renders the dedicated, simple HTML front-end test harness for Django REST Framework.
    """
    return render(request, 'test_client.html', {
        'title': 'DZ-Bridge Django REST Framework Interactive Client',
        'api_version': 'v1',
    })

def health_check_view(request):
    """
    Provides a quick health check endpoint for gateway connectivity.
    """
    return JsonResponse({
        'status': 'healthy',
        'service': 'DZ-Bridge Django Backend',
        'framework': 'Django 5.1 + Django REST Framework',
        'database': 'PostgreSQL 16 Relational Engine',
    })

def frontend_page_view(request, page_name='landing_page.html'):
    """
    Directly serves frontend pages on port 8000 if accessed directly.
    """
    if not page_name.endswith('.html'):
        page_name = f"{page_name}.html"
    file_path = os.path.join(FRONTEND_DIR, page_name)
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            return HttpResponse(f.read(), content_type='text/html; charset=utf-8')
    raise Http404(f"Page {page_name} not found")

