from django.contrib import admin
from django.urls import path, include, re_path
from django.views.static import serve
from django.conf import settings
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView
from apps.users.views import CustomLoginView, RegisterView, CurrentUserView
from rest_framework_simplejwt.views import TokenRefreshView
from .views import test_client_view, health_check_view, frontend_page_view
from django.shortcuts import redirect

urlpatterns = [
    # 1. Frontend & Compatibility Routes
    path('', frontend_page_view, {'page_name': 'index.html'}, name='index-home'),
    path('index', frontend_page_view, {'page_name': 'index.html'}, name='index-alias'),
    path('index.html', frontend_page_view, {'page_name': 'index.html'}, name='index-file'),
    path('presentation', frontend_page_view, {'page_name': 'index.html'}, name='presentation-alias'),
    path('presentation.html', frontend_page_view, {'page_name': 'index.html'}, name='presentation-file'),
    path('landing', frontend_page_view, {'page_name': 'landing_page.html'}, name='landing-alias'),
    path('landing_page.html', frontend_page_view, {'page_name': 'landing_page.html'}, name='landing-file'),
    path('login', frontend_page_view, {'page_name': 'login.html'}, name='login-alias'),
    path('login.html', frontend_page_view, {'page_name': 'login.html'}, name='login-file'),
    path('signup', frontend_page_view, {'page_name': 'signup.html'}, name='signup-alias'),
    path('signup.html', frontend_page_view, {'page_name': 'signup.html'}, name='signup-file'),
    path('expert', frontend_page_view, {'page_name': 'expert.html'}, name='expert-alias'),
    path('expert.html', frontend_page_view, {'page_name': 'expert.html'}, name='expert-file'),
    path('expert-dashboard', frontend_page_view, {'page_name': 'expert-dashboard.html'}, name='dashboard-alias'),
    path('expert-dashboard.html', frontend_page_view, {'page_name': 'expert-dashboard.html'}, name='dashboard-file'),
    path('expert-profile', frontend_page_view, {'page_name': 'expert-profile.html'}, name='profile-alias'),
    path('expert-profile.html', frontend_page_view, {'page_name': 'expert-profile.html'}, name='profile-file'),
    path('organization-dashboard', frontend_page_view, {'page_name': 'organization-dashboard.html'}, name='org-dashboard-alias'),
    path('organization-dashboard.html', frontend_page_view, {'page_name': 'organization-dashboard.html'}, name='org-dashboard-file'),
    path('manager', lambda req: redirect(f"http://localhost:3000/manager{('?' + req.META.get('QUERY_STRING')) if req.META.get('QUERY_STRING') else ''}"), name='manager-redirect'),
    path('manager/', lambda req: redirect(f"http://localhost:3000/manager{('?' + req.META.get('QUERY_STRING')) if req.META.get('QUERY_STRING') else ''}"), name='manager-slash-redirect'),
    path('console', lambda req: redirect(f"http://localhost:3000/manager{('?' + req.META.get('QUERY_STRING')) if req.META.get('QUERY_STRING') else ''}"), name='console-redirect'),
    path('console/', lambda req: redirect(f"http://localhost:3000/manager{('?' + req.META.get('QUERY_STRING')) if req.META.get('QUERY_STRING') else ''}"), name='console-slash-redirect'),
    path('admin-portal', lambda req: redirect(f"http://localhost:3000/manager{('?' + req.META.get('QUERY_STRING')) if req.META.get('QUERY_STRING') else ''}"), name='admin-portal-redirect'),
    path('admin-portal/', lambda req: redirect(f"http://localhost:3000/manager{('?' + req.META.get('QUERY_STRING')) if req.META.get('QUERY_STRING') else ''}"), name='admin-portal-slash-redirect'),
    path('dashboard', lambda req: redirect(f"http://localhost:3000/manager{('?' + req.META.get('QUERY_STRING')) if req.META.get('QUERY_STRING') else ''}"), name='dashboard-redirect'),
    path('dashboard/', lambda req: redirect(f"http://localhost:3000/manager{('?' + req.META.get('QUERY_STRING')) if req.META.get('QUERY_STRING') else ''}"), name='dashboard-slash-redirect'),

    # Direct Compatibility Authentication Routes for frontend API calls
    path('api/auth/login', CustomLoginView.as_view(), name='api-auth-login-direct-no-slash'),
    path('api/auth/login/', CustomLoginView.as_view(), name='api-auth-login-direct'),
    path('api/auth/register', RegisterView.as_view(), name='api-auth-register-direct-no-slash'),
    path('api/auth/register/', RegisterView.as_view(), name='api-auth-register-direct'),
    path('api/auth/refresh', TokenRefreshView.as_view(), name='api-auth-refresh-direct-no-slash'),
    path('api/auth/refresh/', TokenRefreshView.as_view(), name='api-auth-refresh-direct'),
    path('api/auth/me', CurrentUserView.as_view(), name='api-auth-me-direct-no-slash'),
    path('api/auth/me/', CurrentUserView.as_view(), name='api-auth-me-direct'),
    path('api/profile/me', CurrentUserView.as_view(), name='api-profile-me-direct-no-slash'),
    path('api/profile/me/', CurrentUserView.as_view(), name='api-profile-me-direct'),

    # 2. Simple Frontend Test Harness for DRF (Dedicated Test Client)
    path('test-client/', test_client_view, name='test-client'),
    path('test-client', test_client_view, name='test-client-no-slash'),
    path('health/', health_check_view, name='health-check'),
    
    # 3. Django Admin
    path('admin/', admin.site.urls),
    
    # 4. OpenAPI Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    
    # 5. Core Domain API Routes (v1)
    path('api/v1/auth/', include('apps.users.urls')),
    path('api/v1/profiles/', include('apps.profiles.urls')),
    path('api/v1/projects/', include('apps.projects.urls')),
    path('api/v1/matches/', include('apps.matches.urls')),
    path('api/v1/collaborations/', include('apps.collaborations.urls')),
    path('api/v1/ratings/', include('apps.ratings.urls')),
    path('api/v1/audit/', include('apps.audit.urls')),

    # 6. Static Media & Assets
    re_path(r'^images/(?P<path>.*)$', serve, {'document_root': settings.BASE_DIR / 'images'}),
    re_path(r'^fonts/(?P<path>.*)$', serve, {'document_root': settings.BASE_DIR / 'static' / 'fonts'}),
]
