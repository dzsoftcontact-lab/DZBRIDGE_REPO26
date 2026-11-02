from django.contrib import admin
from .models import Rating

@admin.register(Rating)
class RatingAdmin(admin.ModelAdmin):
    list_display = ('collaboration', 'from_user', 'to_user', 'overall_score', 'is_private_admin_only', 'created_at')
    list_filter = ('overall_score', 'is_private_admin_only', 'created_at')
    search_fields = ('from_user__email', 'to_user__email', 'comment')
