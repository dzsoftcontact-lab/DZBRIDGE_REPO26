"""
Django management command to create Admin, Expert, or Organization accounts for DZ-Bridge.
"""
from django.core.management.base import BaseCommand, CommandError
from django.contrib.auth import get_user_model
from apps.profiles.models import Profile

User = get_user_model()

class Command(BaseCommand):
    help = 'Create an Admin, Expert, or Organization user account with profile'

    def add_arguments(self, parser):
        parser.add_argument('--role', type=str, required=True, choices=['admin', 'expert', 'organization'],
                            help='Role for the user: admin, expert, or organization')
        parser.add_argument('--email', type=str, required=True, help='Unique user email address')
        parser.add_argument('--password', type=str, required=True, help='Account password')
        parser.add_argument('--name', type=str, required=True, help='Full name of user or primary contact')
        parser.add_argument('--org-name', type=str, default='', help='Organization name (for organization or admin)')
        parser.add_argument('--org-type', type=str, default='University', help='Organization type (e.g. University, Research Institute)')
        parser.add_argument('--country', type=str, default='Algeria', help='Country of residence (default: Algeria)')
        parser.add_argument('--city', type=str, default='Algiers', help='City of residence or operation (default: Algiers)')
        parser.add_argument('--diaspora', action='store_true', help='Flag if expert is in the diaspora')
        parser.add_argument('--expertise', type=str, default='', help='Comma-separated expertise domains (for expert)')
        parser.add_argument('--bio', type=str, default='', help='Biography or mission statement')

    def handle(self, *args, **options):
        role = options['role'].lower()
        email = options['email'].strip().lower()
        password = options['password']
        name = options['name'].strip()
        org_name = options.get('org_name', '').strip()
        org_type = options.get('org_type', 'University').strip()
        country = options.get('country', 'Algeria').strip()
        city = options.get('city', 'Algiers').strip()
        is_diaspora = options.get('diaspora', False)
        bio = options.get('bio', '').strip()

        expertise_raw = options.get('expertise', '')
        expertise_tags = [t.strip() for t in expertise_raw.split(',') if t.strip()] if expertise_raw else []

        if not email or '@' not in email:
            raise CommandError("A valid email address is required.")

        is_staff = (role == 'admin')
        is_superuser = (role == 'admin')

        user, created = User.objects.get_or_create(
            email=email,
            defaults={
                'role': role,
                'status': 'active',
                'is_staff': is_staff,
                'is_superuser': is_superuser,
            }
        )

        user.role = role
        user.status = 'active'
        user.is_staff = is_staff
        user.is_superuser = is_superuser
        user.set_password(password)
        user.save()

        # Build default profile fields if empty
        if not bio:
            if role == 'admin':
                bio = 'DZ-Bridge Platform Administration & Technology Transfer Office.'
            elif role == 'expert':
                bio = f'Expertise in {", ".join(expertise_tags) if expertise_tags else "Applied Science & Technology"}.'
            else:
                bio = f'Higher education and research institution: {org_name or name}.'

        profile_defaults = {
            'full_name': name,
            'organization_name': org_name if org_name else (name if role == 'organization' else ''),
            'organization_type': org_type if role == 'organization' else '',
            'country': country,
            'city': city,
            'is_diaspora': is_diaspora,
            'bio': bio,
            'expertise_tags': expertise_tags if expertise_tags else (['Renewable Energy', 'Artificial Intelligence'] if role == 'expert' else []),
        }

        profile, p_created = Profile.objects.update_or_create(
            user=user,
            defaults=profile_defaults
        )

        status_text = "Created" if created else "Updated"
        role_label = {
            'admin': 'Administrator (MESRS Staff)',
            'expert': 'Expert / Scholar',
            'organization': 'University / Research Institute'
        }.get(role, role)

        self.stdout.write(self.style.SUCCESS(f"\n[OK] Successfully {status_text} {role_label}:"))
        self.stdout.write(f"  • Email    : {user.email}")
        self.stdout.write(f"  • Name     : {profile.full_name}")
        self.stdout.write(f"  • Role     : {user.role}")
        self.stdout.write(f"  • Status   : {user.status}")
        self.stdout.write(f"  • Staff    : {'Yes' if user.is_staff else 'No'}")
        if role == 'admin':
            self.stdout.write(f"  • Admin URL: http://localhost:8000/admin/")
        elif role == 'organization':
            self.stdout.write(f"  • Org Name : {profile.organization_name}")
        elif role == 'expert':
            self.stdout.write(f"  • Country  : {profile.country} (Diaspora: {'Yes' if profile.is_diaspora else 'No'})")
            self.stdout.write(f"  • Domains  : {', '.join(profile.expertise_tags)}")
        self.stdout.write("")
