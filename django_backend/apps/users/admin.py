from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ('email', 'role', 'status', 'is_staff', 'is_superuser', 'created_at')
    list_filter = ('role', 'status', 'is_staff', 'is_superuser', 'created_at')
    search_fields = ('email',)
    ordering = ('-created_at',)
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Permissions', {'fields': ('role', 'status', 'is_staff', 'is_superuser', 'is_active', 'groups', 'user_permissions')}),
        ('Verification', {'fields': ('email_verification_token', 'email_verified_at')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'role', 'password', 'is_staff', 'is_superuser'),
        }),
    )
