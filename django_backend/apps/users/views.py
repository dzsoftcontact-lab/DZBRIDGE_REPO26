from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView
from django.contrib.auth import get_user_model
from .serializers import RegisterSerializer, UserSerializer, CustomTokenObtainPairSerializer

User = get_user_model()

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]

class CustomLoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

class CurrentUserView(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, *args, **kwargs):
        user = request.user
        full_name = getattr(user, 'email', '')
        org_name = ''
        city = ''
        country = 'Algeria'
        bio = ''
        try:
            if hasattr(user, 'profile') and user.profile:
                full_name = user.profile.full_name or full_name
                org_name = user.profile.organization_name or ''
                city = user.profile.city or ''
                country = user.profile.country or 'Algeria'
                bio = user.profile.bio or ''
        except Exception:
            pass

        data = {
            'id': str(user.id),
            'email': user.email,
            'role': user.role,
            'status': user.status,
            'fullName': full_name,
            'organizationName': org_name or full_name,
            'city': city,
            'country': country,
            'bio': bio,
            'isStaff': user.is_staff,
            'isSuperuser': user.is_superuser,
        }
        return Response({'user': data, **data})

class UserListCreateView(generics.ListCreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    filterset_fields = ['role', 'status']
    search_fields = ['email']

class UserDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

