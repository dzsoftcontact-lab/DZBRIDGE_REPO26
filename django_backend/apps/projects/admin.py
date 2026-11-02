from django.contrib import admin
from .models import Project, ProjectStatusHistory

@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    list_display = ('title', 'organization', 'location', 'status', 'start_date', 'created_at')
    list_filter = ('status', 'location', 'created_at')
    search_fields = ('title', 'description', 'organization__email')

@admin.register(ProjectStatusHistory)
class ProjectStatusHistoryAdmin(admin.ModelAdmin):
    list_display = ('project', 'from_status', 'to_status', 'changed_by', 'created_at')
    list_filter = ('from_status', 'to_status', 'created_at')
