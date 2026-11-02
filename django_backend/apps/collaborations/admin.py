from django.contrib import admin
from .models import Collaboration

@admin.register(Collaboration)
class CollaborationAdmin(admin.ModelAdmin):
    list_display = ('project', 'expert', 'organization', 'status', 'confirmed_at', 'completed_at')
    list_filter = ('status', 'confirmed_at', 'created_at')
    search_fields = ('project__title', 'expert__email', 'organization__email')
