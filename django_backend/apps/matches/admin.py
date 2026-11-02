from django.contrib import admin
from .models import Match

@admin.register(Match)
class MatchAdmin(admin.ModelAdmin):
    list_display = ('project', 'expert', 'compatibility_score', 'status', 'notified_at', 'responded_at')
    list_filter = ('status', 'compatibility_score', 'created_at')
    search_fields = ('project__title', 'expert__email')
