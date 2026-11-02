from django.contrib import admin
from .models import ActivityLog

@admin.register(ActivityLog)
class ActivityLogAdmin(admin.ModelAdmin):
    list_display = ('action_type', 'user', 'user_role', 'entity_type', 'ip_address', 'created_at')
    list_filter = ('action_type', 'user_role', 'entity_type', 'created_at')
    search_fields = ('action_type', 'user__email', 'entity_type')
    readonly_fields = ('id', 'user', 'user_role', 'action_type', 'entity_type', 'entity_id', 'ip_address', 'metadata', 'created_at')
