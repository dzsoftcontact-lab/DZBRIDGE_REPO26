from django.contrib import admin
from .models import Profile, ExpertAvailability

@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('full_name', 'user', 'organization_name', 'country', 'city', 'is_diaspora', 'created_at')
    list_filter = ('is_diaspora', 'country', 'created_at')
    search_fields = ('full_name', 'organization_name', 'user__email', 'city')

@admin.register(ExpertAvailability)
class ExpertAvailabilityAdmin(admin.ModelAdmin):
    list_display = ('expert', 'city', 'start_date', 'end_date', 'duration_days')
    list_filter = ('city', 'start_date')
    search_fields = ('expert__email', 'city')
