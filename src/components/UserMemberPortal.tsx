import React, { useState } from 'react';
import {
  UserProfile,
  ExpertAvailability,
  MatchItem,
  ProjectItem,
  CollaborationItem,
  UserRole,
} from '../types';
import { useAuth } from '../context/AuthContext';
import {
  GraduationCap,
  Building2,
  Search,
  User,
  Briefcase,
  Handshake,
  Calendar,
  MapPin,
  Sparkles,
  CheckCircle2,
  Plus,
  LogOut,
  Edit3,
  Save,
  Globe,
  Mail,
  Phone,
  Shield,
  Clock,
  ArrowRight,
  Filter,
  X,
  ExternalLink,
  Award,
} from 'lucide-react';

interface UserMemberPortalProps {
  role: 'expert' | 'organization';
  expertData: {
    id: string;
    email: string;
    profile: UserProfile;
    availabilities: ExpertAvailability[];
  };
  projects: ProjectItem[];
  matches: MatchItem[];
  collaborations: CollaborationItem[];
  onAddAvailability: (avail: Partial<ExpertAvailability>) => void;
  onRespondMatch: (matchId: string, decision: 'accepted' | 'rejected', notes?: string) => void;
  onCreateProject: (proj: Partial<ProjectItem>) => void;
  onUpdateRow: (tableName: string, id: string, updates: Record<string, any>) => void;
  onLogout: () => void;
  onSwitchToAdmin?: () => void;
}

const PORTAL_I18N = {
  en: {
    portalBadge: 'Scholar & Institution Network',
    expertRoleBadge: 'Diaspora Scholar',
    orgRoleBadge: 'Partner University',
    navProfile: 'My Profile',
    navProjects: 'Browse Projects',
    navCollaborations: 'My Collaborations',
    logout: 'Log Out',
    adminReturn: 'Admin Console',
    welcomeBack: 'Welcome back,',
    subtitleExpert: 'Manage your academic profile, declare Algeria visit dates, and discover university research initiatives.',
    subtitleOrg: 'Manage your institutional profile, publish collaboration projects, and connect with world-class diaspora scholars.',
    completeness: 'Profile Completeness',
    completenessTip: 'A complete profile achieves 94% higher match acceptance from institutional partners.',
    editProfile: 'Edit Information',
    saveChanges: 'Save Changes',
    saving: 'Saving…',
    saveSuccess: 'Profile information updated and saved permanently to DZ-Bridge backend.',
    fullName: 'Full Name',
    title: 'Academic Title / Rank',
    institution: 'Affiliation / University',
    email: 'Contact Email',
    phone: 'Phone Number',
    country: 'Country of Residence',
    city: 'City',
    specialty: 'Primary Domain of Expertise',
    bio: 'Professional Biography',
    skills: 'Expertise & Research Keywords',
    skillsHint: 'Comma-separated (e.g. Artificial Intelligence, Microelectronics, Solar Energy)',
    visitDates: 'Upcoming Visit Windows in Algeria',
    addVisit: 'Declare Visit Dates',
    noVisits: 'No visit dates declared yet. Announcing your visit helps Algerian universities invite you.',
    searchPlaceholder: 'Search projects by keyword, university, domain, or skills…',
    filterAll: 'All Domains',
    filterAI: 'Artificial Intelligence',
    filterEnergy: 'Renewable Energy',
    filterHealth: 'Biomedical & Health',
    filterWater: 'Water & Desalination',
    filterAgri: 'AgriTech',
    resultsCount: (n: number) => `${n} active collaboration opportunities`,
    logisticsOffered: 'Logistics Offered by University',
    travelCovered: 'Flight Covered',
    hotelCovered: 'Lodging Provided',
    stipendCovered: 'Research Stipend',
    applyNow: 'Express Interest & Connect',
    applied: 'Interest Expressed',
    matchScore: 'Compatibility Score',
    dates: 'Proposed Dates',
    skillsNeeded: 'Skills Required',
    noProjectsFound: 'No projects match your current search criteria.',
    publishProject: 'Submit New Collaboration Project',
    newProjectTitle: 'New Project Title',
    newProjectDesc: 'Project Description & Research Scope',
    collabsTitle: 'Active Bilateral Collaborations',
    noCollabs: 'No ongoing collaborations yet. Connect with projects above to initiate formal partnerships.',
  },
  fr: {
    portalBadge: 'Réseau Chercheurs & Universités',
    expertRoleBadge: 'Chercheur de la Diaspora',
    orgRoleBadge: 'Université Partenaire',
    navProfile: 'Mon Profil',
    navProjects: 'Explorer les Projets',
    navCollaborations: 'Mes Collaborations',
    logout: 'Se déconnecter',
    adminReturn: 'Console Admin',
    welcomeBack: 'Bienvenue,',
    subtitleExpert: 'Gérez votre profil académique, déclarez vos séjours en Algérie et découvrez les initiatives universitaires.',
    subtitleOrg: 'Gérez le profil de votre institution, publiez des projets de recherche et collaborez avec la diaspora.',
    completeness: 'Complétude du profil',
    completenessTip: 'Un profil complet obtient 94% d’acceptation supplémentaire de la part des institutions partenaires.',
    editProfile: 'Modifier mes informations',
    saveChanges: 'Enregistrer',
    saving: 'Enregistrement…',
    saveSuccess: 'Informations mises à jour et sauvegardées sur le backend DZ-Bridge.',
    fullName: 'Nom complet',
    title: 'Titre académique / Fonction',
    institution: 'Affiliation / Institution',
    email: 'E-mail de contact',
    phone: 'Numéro de téléphone',
    country: 'Pays de résidence',
    city: 'Ville',
    specialty: 'Domaine d’expertise principal',
    bio: 'Biographie professionnelle',
    skills: 'Mots-clés de recherche',
    skillsHint: 'Séparés par des virgules (ex. Intelligence Artificielle, Énergie Solaire)',
    visitDates: 'Périodes de visite prévues en Algérie',
    addVisit: 'Déclarer un séjour',
    noVisits: 'Aucun séjour déclaré pour le moment. Indiquer vos dates permet aux universités de vous solliciter.',
    searchPlaceholder: 'Rechercher des projets par mot-clé, université, domaine…',
    filterAll: 'Tous les domaines',
    filterAI: 'Intelligence Artificielle',
    filterEnergy: 'Énergies Renouvelables',
    filterHealth: 'Biomédical & Santé',
    filterWater: 'Dessalement & Eau',
    filterAgri: 'AgriTech',
    resultsCount: (n: number) => `${n} opportunités de collaboration actives`,
    logisticsOffered: 'Prise en charge logistique offerte',
    travelCovered: 'Billet d’avion pris en charge',
    hotelCovered: 'Hébergement assuré',
    stipendCovered: 'Indemnité de recherche',
    applyNow: 'Manifester mon intérêt',
    applied: 'Intérêt manifesté',
    matchScore: 'Score de compatibilité',
    dates: 'Période proposée',
    skillsNeeded: 'Compétences recherchées',
    noProjectsFound: 'Aucun projet ne correspond à vos critères de recherche.',
    publishProject: 'Déposer un nouveau projet de collaboration',
    newProjectTitle: 'Titre du projet',
    newProjectDesc: 'Description et objectifs scientifiques',
    collabsTitle: 'Collaborations bilatérales actives',
    noCollabs: 'Aucune collaboration en cours pour l’instant. Explorez les projets pour initier des partenariats.',
  },
  ar: {
    portalBadge: 'شبكة الكفاءات والمؤسسات الأكاديمية الجزائرية',
    expertRoleBadge: 'عالم وخبير في المهجر',
    orgRoleBadge: 'جامعة أو مركز بحث شريك',
    navProfile: 'ملفي الشخصي',
    navProjects: 'استعراض المشاريع',
    navCollaborations: 'التعاون والشراكات',
    logout: 'تسجيل الخروج',
    adminReturn: 'لوحة التحكم المركزية',
    welcomeBack: 'مرحباً بك،',
    subtitleExpert: 'قم بإدارة ملفك الأكاديمي، وحدد مواعيد زياراتك للجزائر، واكتشف فرص التعاون ونقل المعرفة مع الجامعات.',
    subtitleOrg: 'أدر ملف جامعتك، واطرح مشاريع بحثية جديدة، واستقطب كفاءات الجالية الجزائرية للمساهمة الوطنية.',
    completeness: 'نسبة اكتمال الملف',
    completenessTip: 'الملفات المكتملة تحظى بنسبة قبول أعلى بـ 94% من الشركاء الجامعيين والمراكز البحثية.',
    editProfile: 'تعديل البيانات',
    saveChanges: 'حفظ التعديلات',
    saving: 'جارٍ الحفظ…',
    saveSuccess: 'تم تحديث البيانات وحفظها نهائياً في النظام المركزي لـ DZ-Bridge.',
    fullName: 'الاسم الكامل',
    title: 'الرتبة الأكاديمية / الوظيفة',
    institution: 'المؤسسة أو الجامعة التابع لها',
    email: 'البريد الإلكتروني للتواصل',
    phone: 'رقم الهاتف',
    country: 'بلد الإقامة',
    city: 'المدينة',
    specialty: 'التخصص العلمي الدقيق',
    bio: 'نبذة تعريفية وسيرة علمية',
    skills: 'الكلمات المفتاحية ومجالات الخبرة',
    skillsHint: 'مفصولة بفواصل (مثال: الذكاء الاصطناعي، أشباه الموصلات، الطاقة الشمسية)',
    visitDates: 'فترات الزيارة المقررة للجزائر',
    addVisit: 'التصريح بفترة زيارة للجزائر',
    noVisits: 'لم يتم تسجيل أي زيارة بعد. الإعلان عن تواريخ قدومك يتيح للجامعات دعوتك رسمياً لإلقاء محاضرات والإشراف.',
    searchPlaceholder: 'ابحث عن المشاريع بالكلمة المفتاحية، اسم الجامعة، التخصص أو المدينة…',
    filterAll: 'كافة المجالات',
    filterAI: 'الذكاء الاصطناعي',
    filterEnergy: 'الطاقات المتجددة',
    filterHealth: 'الصحة والبيوتكنولوجيا',
    filterWater: 'تحلية المياه',
    filterAgri: 'التكنولوجيا الفلاحية',
    resultsCount: (n: number) => `${n} مشروع تعاون متاح حالياً`,
    logisticsOffered: 'التغطية اللوجستية التي توفرها الجامعة',
    travelCovered: 'تذكرة السفر مغطاة',
    hotelCovered: 'الإقامة الفندقية مؤمنة',
    stipendCovered: 'منحة بحث وتنقل',
    applyNow: 'إبداء الاهتمام والاتصال بالجامعة',
    applied: 'تم إرسال الاهتمام',
    matchScore: 'نسبة التوافق العلمي',
    dates: 'الفترة الزمنية المقترحة',
    skillsNeeded: 'المهارات المطلوبة',
    noProjectsFound: 'لا توجد مشاريع مطابقة لمعايير البحث الحالية.',
    publishProject: 'طرح مشروع تعاون أكاديمي جديد',
    newProjectTitle: 'عنوان المشروع',
    newProjectDesc: 'أهداف المشروع والمجال البحثي',
    collabsTitle: 'مشاريع التعاون الثنائية المؤكدة',
    noCollabs: 'لا يوجد تعاون قائم حالياً. تصفح المشاريع أعلاه لبدء شراكة مؤسساتية.',
  },
};

export const UserMemberPortal: React.FC<UserMemberPortalProps> = ({
  role,
  expertData,
  projects,
  matches,
  collaborations,
  onAddAvailability,
  onRespondMatch,
  onCreateProject,
  onUpdateRow,
  onLogout,
  onSwitchToAdmin,
}) => {
  const { user, lang, setLang, theme, toggleTheme } = useAuth();
  const isAr = lang === 'ar';
  const isOrg = role === 'organization';

  const t = (k: keyof typeof PORTAL_I18N['en'], ...args: any[]) => {
    const dict = PORTAL_I18N[lang] || PORTAL_I18N['en'];
    const val = (dict as any)[k] || (PORTAL_I18N['en'] as any)[k];
    if (typeof val === 'function') return val(...args);
    return val || '';
  };

  const [activeTab, setActiveTab] = useState<'profile' | 'projects' | 'collaborations'>('profile');
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [saveSuccessMsg, setSaveSuccessMsg] = useState<string | null>(null);

  // Dedicated Organization defaults
  const orgDefaultName = user?.organizationName || (user?.role === 'organization' ? user.fullName : null) || 'ESI Algiers (École Nationale Supérieure d\'Informatique)';
  const orgDefaultTitle = 'Directorate of Research, Doctoral Studies & Tech Transfer';
  const orgDefaultAffil = user?.organizationName || 'ESI Algiers';
  const orgDefaultEmail = (user?.role === 'organization' ? user.email : null) || 'direction@esi.dz';
  const orgDefaultPhone = user?.phoneNumber || '+213 21 00 20 26';
  const orgDefaultCountry = user?.country || 'Algeria';
  const orgDefaultCity = user?.city || 'Algiers';
  const orgDefaultSpecialty = user?.specialty || 'Computer Science, Artificial Intelligence & Distributed Systems';
  const orgDefaultBio = user?.bio || 'National Higher School of Computer Science (ESI Algiers), leading Algerian Grande École dedicated to computer engineering, high-performance computing, and technology transfer partnerships with diaspora scholars.';
  const orgDefaultSkills = 'Artificial Intelligence, Cybersecurity, High Performance Computing, Data Science, Software Engineering';

  // Profile Form States properly separated by role
  const [fullName, setFullName] = useState(() => {
    if (isOrg) return orgDefaultName;
    return (user?.role === 'expert' ? user.fullName : null) || expertData.profile.fullName || 'Dr. Belgacem Haba';
  });

  const [titleOrRank, setTitleOrRank] = useState(() => {
    if (isOrg) return orgDefaultTitle;
    return expertData.profile.titleOrRank || 'Senior Research Fellow & VP';
  });

  const [affiliation, setAffiliation] = useState(() => {
    if (isOrg) return orgDefaultAffil;
    return (user?.role === 'expert' ? user.organizationName : null) || expertData.profile.affiliation || 'ADEIA / Univ. of Biskra';
  });

  const [email, setEmail] = useState(() => {
    if (isOrg) return orgDefaultEmail;
    return (user?.role === 'expert' ? user.email : null) || expertData.email || 'belgacem.haba@algerian-scholars.dz';
  });

  const [phone, setPhone] = useState(() => {
    if (isOrg) return orgDefaultPhone;
    return expertData.profile.phoneNumber || '+213 21 00 12 34';
  });

  const [country, setCountry] = useState(() => {
    if (isOrg) return orgDefaultCountry;
    return expertData.profile.country || 'United States';
  });

  const [city, setCity] = useState(() => {
    if (isOrg) return orgDefaultCity;
    return expertData.profile.city || 'San Jose';
  });

  const [specialty, setSpecialty] = useState(() => {
    if (isOrg) return orgDefaultSpecialty;
    return expertData.profile.expertiseTags?.[0] || 'Microelectronics & 3D Packaging';
  });

  const [bio, setBio] = useState(() => {
    if (isOrg) return orgDefaultBio;
    return expertData.profile.bio || 'Algerian diaspora scholar and inventor with over 500 patents, committed to technology transfer and doctoral mentoring in Algerian universities.';
  });

  const [skillsStr, setSkillsStr] = useState(() => {
    if (isOrg) return orgDefaultSkills;
    return (expertData.profile.expertiseTags || []).join(', ') || 'Artificial Intelligence, Semiconductors, 3D Packaging, Nanotechnology';
  });

  // Keep state in sync whenever role or logged-in user changes
  React.useEffect(() => {
    if (isOrg) {
      setFullName(user?.organizationName || (user?.role === 'organization' ? user.fullName : null) || 'ESI Algiers (École Nationale Supérieure d\'Informatique)');
      setTitleOrRank(orgDefaultTitle);
      setAffiliation(user?.organizationName || 'ESI Algiers');
      setEmail((user?.role === 'organization' ? user.email : null) || 'direction@esi.dz');
      setPhone(user?.phoneNumber || '+213 21 00 20 26');
      setCountry(user?.country || 'Algeria');
      setCity(user?.city || 'Algiers');
      setSpecialty(user?.specialty || orgDefaultSpecialty);
      setBio(user?.bio || orgDefaultBio);
      setSkillsStr(orgDefaultSkills);
    } else {
      setFullName((user?.role === 'expert' ? user.fullName : null) || expertData.profile.fullName || 'Dr. Belgacem Haba');
      setTitleOrRank(expertData.profile.titleOrRank || 'Senior Research Fellow & VP');
      setAffiliation((user?.role === 'expert' ? user.organizationName : null) || expertData.profile.affiliation || 'ADEIA / Univ. of Biskra');
      setEmail((user?.role === 'expert' ? user.email : null) || expertData.email || 'belgacem.haba@algerian-scholars.dz');
      setPhone(expertData.profile.phoneNumber || '+213 21 00 12 34');
      setCountry(expertData.profile.country || 'United States');
      setCity(expertData.profile.city || 'San Jose');
      setSpecialty(expertData.profile.expertiseTags?.[0] || 'Microelectronics & 3D Packaging');
      setBio(expertData.profile.bio || 'Algerian diaspora scholar and inventor with over 500 patents, committed to technology transfer and doctoral mentoring in Algerian universities.');
      setSkillsStr((expertData.profile.expertiseTags || []).join(', ') || 'Artificial Intelligence, Semiconductors, 3D Packaging, Nanotechnology');
    }
  }, [role, user]);

  // Availability modal states
  const [showAddAvail, setShowAddAvail] = useState(false);
  const [availCity, setAvailCity] = useState('Algiers');
  const [availStart, setAvailStart] = useState('2026-11-01');
  const [availEnd, setAvailEnd] = useState('2026-11-20');
  const [availNotes, setAvailNotes] = useState('Keynote lectures, doctoral workshops, and joint laboratory research.');

  // Project search & filter
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedDomain, setSelectedDomain] = useState<string>('all');
  const [appliedProjects, setAppliedProjects] = useState<Record<string, boolean>>({});

  // Organization New Project Modal
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [newProjTitle, setNewProjTitle] = useState('');
  const [newProjDesc, setNewProjDesc] = useState('');
  const [newProjSkills, setNewProjSkills] = useState('Artificial Intelligence, Data Science');
  const [newProjLocation, setNewProjLocation] = useState('Algiers');

  // Handle Profile Save with Backend Persistence
  const handleSaveProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);

    const skillsArray = skillsStr.split(',').map((s) => s.trim()).filter(Boolean);

    // Update in-memory profile object
    expertData.profile.fullName = fullName;
    expertData.profile.titleOrRank = titleOrRank;
    expertData.profile.affiliation = affiliation;
    expertData.profile.phoneNumber = phone;
    expertData.profile.country = country;
    expertData.profile.city = city;
    expertData.profile.bio = bio;
    expertData.profile.expertiseTags = skillsArray;

    // Persist permanently to backend users table and DB
    try {
      const token = localStorage.getItem('dzb-token');
      const updates = {
        fullName,
        full_name: fullName,
        organizationName: affiliation,
        organization_name: affiliation,
        phoneNumber: phone,
        country,
        city,
        specialty,
        bio,
        skills: skillsArray,
      };

      await fetch(`/api/data/users/${expertData.id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: JSON.stringify(updates),
      });

      onUpdateRow('users', expertData.id, updates);
    } catch (err) {
      console.warn('Backend profile update note:', err);
    }

    setIsSaving(false);
    setIsEditing(false);
    setSaveSuccessMsg(t('saveSuccess'));
    setTimeout(() => setSaveSuccessMsg(null), 4000);
  };

  // Handle Availability Submit
  const handleAddAvailSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const s = new Date(availStart);
    const end = new Date(availEnd);
    const diff = Math.max(1, Math.round((end.getTime() - s.getTime()) / (1000 * 60 * 60 * 24)) + 1);

    onAddAvailability({
      city: availCity,
      startDate: availStart,
      endDate: availEnd,
      durationDays: diff,
      notes: availNotes,
    });
    setShowAddAvail(false);
    setSaveSuccessMsg(
      isAr
        ? `تم تسجيل فترة الزيارة في ${availCity} (${diff} يوماً) بنجاح!`
        : `Visit window in ${availCity} (${diff} days) registered permanently.`
    );
    setTimeout(() => setSaveSuccessMsg(null), 4000);
  };

  // Handle Organization Create Project
  const handleCreateProjectSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newProjTitle || !newProjDesc) return;
    const skills = newProjSkills.split(',').map((s) => s.trim()).filter(Boolean);

    onCreateProject({
      title: newProjTitle,
      description: newProjDesc,
      skillsRequired: skills.length > 0 ? skills : ['Artificial Intelligence'],
      location: newProjLocation,
      startDate: '2026-11-10',
      endDate: '2026-11-25',
      logisticsOffered: { travel: true, lodging: true, stipend: true },
    });

    setShowCreateModal(false);
    setNewProjTitle('');
    setNewProjDesc('');
    setSaveSuccessMsg(
      isAr
        ? 'تم طرح مشروع التعاون بنجاح وإدراجه في قائمة المشاريع الوطنية!'
        : 'Collaboration initiative published successfully to the national platform.'
    );
    setTimeout(() => setSaveSuccessMsg(null), 4000);
  };

  // Handle Express Interest in Project
  const handleApplyToProject = (proj: ProjectItem) => {
    setAppliedProjects((prev) => ({ ...prev, [proj.id]: true }));
    onRespondMatch(proj.id, 'accepted', 'Scholar expressed interest in this collaboration initiative.');
    setSaveSuccessMsg(
      isAr
        ? `تم إبداء اهتمامك بمشروع "${proj.title}"! تم إشعار إدارة الجامعة لربط الاتصال.`
        : `Interest expressed for "${proj.title}"! The university dean has been notified.`
    );
    setTimeout(() => setSaveSuccessMsg(null), 4000);
  };

  // Filtered projects
  const filteredProjects = projects.filter((p) => {
    const q = searchQuery.toLowerCase().trim();
    const matchQuery =
      !q ||
      p.title.toLowerCase().includes(q) ||
      p.description.toLowerCase().includes(q) ||
      p.organizationName.toLowerCase().includes(q) ||
      p.location.toLowerCase().includes(q) ||
      p.skillsRequired.some((s) => s.toLowerCase().includes(q));

    if (!matchQuery) return false;

    if (selectedDomain === 'ai') return p.skillsRequired.some((s) => /ai|intelligence|machine|deep|vision/i.test(s));
    if (selectedDomain === 'energy') return p.skillsRequired.some((s) => /energy|solar|hydrogen|renewable|photovoltaic/i.test(s));
    if (selectedDomain === 'health') return p.skillsRequired.some((s) => /health|bio|medical|pharma/i.test(s));
    if (selectedDomain === 'water') return p.skillsRequired.some((s) => /water|desalination|irrigation|hydrology/i.test(s));
    if (selectedDomain === 'agri') return p.skillsRequired.some((s) => /agri|soil|crop|food/i.test(s));

    return true;
  });

  const userInitials = fullName
    .split(' ')
    .filter(Boolean)
    .map((n) => n[0])
    .join('')
    .slice(0, 2)
    .toUpperCase() || 'DZ';

  return (
    <div
      dir={isAr ? 'rtl' : 'ltr'}
      className="min-h-screen bg-[var(--bg-page)] text-[var(--text-primary)] font-['DM_Sans',system-ui,-apple-system,sans-serif] antialiased flex flex-col"
    >
      {/* ------------------------------------------------------------- */}
      {/* 1. TOP HEADER (MATCHING LANDING PAGE STYLING)                 */}
      {/* ------------------------------------------------------------- */}
      <header className="sticky top-0 z-40 bg-[color-mix(in_srgb,var(--bg-page)_92%,transparent)] backdrop-blur-md border-b border-[var(--border)] transition-colors">
        <div className="max-w-[1240px] mx-auto px-4 sm:px-6 h-[72px] flex items-center justify-between gap-4">
          {/* Logo & Platform Name */}
          <div className="flex items-center gap-3">
            <div className="w-[36px] h-[36px] rounded-xl bg-[var(--plum-800)] text-white font-['Fraunces',serif] font-bold text-base flex items-center justify-center shadow-xs">
              DZ
            </div>
            <div>
              <span className="font-semibold text-lg tracking-tight text-[var(--text-primary)]">
                DZ-Bridge
              </span>
              <span className="hidden sm:inline-block ms-2 px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-[var(--accent-lavender-subtle)] text-[var(--brand)] border border-[var(--border)]">
                {role === 'organization' ? t('orgRoleBadge') : t('expertRoleBadge')}
              </span>
            </div>
          </div>

          {/* Navigation Tabs in Landing Page Style */}
          <nav className="flex items-center gap-1 sm:gap-2 p-1 rounded-full bg-[var(--bg-surface)] border border-[var(--border)] shadow-xs">
            <button
              type="button"
              onClick={() => setActiveTab('profile')}
              className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-medium transition ${
                activeTab === 'profile'
                  ? 'bg-[var(--brand)] text-white font-semibold shadow-xs'
                  : 'text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-subtle)]'
              }`}
            >
              <User className="w-3.5 h-3.5" />
              <span>{t('navProfile')}</span>
            </button>

            <button
              type="button"
              onClick={() => setActiveTab('projects')}
              className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-medium transition ${
                activeTab === 'projects'
                  ? 'bg-[var(--brand)] text-white font-semibold shadow-xs'
                  : 'text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-subtle)]'
              }`}
            >
              <Briefcase className="w-3.5 h-3.5" />
              <span>{t('navProjects')}</span>
              <span className="ms-1 px-1.5 py-0.2 rounded-full text-[10px] bg-[var(--gold-500)] text-[var(--plum-900)] font-bold">
                {projects.length}
              </span>
            </button>

            <button
              type="button"
              onClick={() => setActiveTab('collaborations')}
              className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-medium transition ${
                activeTab === 'collaborations'
                  ? 'bg-[var(--brand)] text-white font-semibold shadow-xs'
                  : 'text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-subtle)]'
              }`}
            >
              <Handshake className="w-3.5 h-3.5" />
              <span>{t('navCollaborations')}</span>
              {collaborations.length > 0 && (
                <span className="ms-1 px-1.5 py-0.2 rounded-full text-[10px] bg-emerald-100 text-emerald-900 font-bold">
                  {collaborations.length}
                </span>
              )}
            </button>
          </nav>

          {/* Right Controls: Trilingual, Theme, and Log out */}
          <div className="flex items-center gap-2">
            {/* Admin Switcher if authorized */}
            {onSwitchToAdmin && (
              <button
                type="button"
                onClick={onSwitchToAdmin}
                className="hidden lg:flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-purple-50 text-purple-900 border border-purple-200 hover:bg-purple-100 transition"
              >
                <Shield className="w-3 h-3" />
                <span>{t('adminReturn')}</span>
              </button>
            )}

            {/* Language Switcher */}
            <div className="flex items-center bg-[var(--bg-surface)] p-0.5 rounded-full border border-[var(--border)] text-[11px] font-medium shadow-xs">
              <button
                onClick={() => setLang('en')}
                className={`px-2 py-0.5 rounded-full transition ${
                  lang === 'en' ? 'bg-[var(--brand)] text-white font-bold' : 'text-[var(--text-secondary)]'
                }`}
              >
                EN
              </button>
              <button
                onClick={() => setLang('fr')}
                className={`px-2 py-0.5 rounded-full transition ${
                  lang === 'fr' ? 'bg-[var(--brand)] text-white font-bold' : 'text-[var(--text-secondary)]'
                }`}
              >
                FR
              </button>
              <button
                onClick={() => setLang('ar')}
                className={`px-2 py-0.5 rounded-full transition font-['Cairo',sans-serif] ${
                  lang === 'ar' ? 'bg-[var(--brand)] text-white font-bold' : 'text-[var(--text-secondary)]'
                }`}
              >
                عربي
              </button>
            </div>

            {/* Theme Toggle */}
            <button
              type="button"
              onClick={toggleTheme}
              className="w-8 h-8 rounded-full flex items-center justify-center text-[var(--text-primary)] hover:bg-[var(--bg-subtle)] transition border border-[var(--border)] shadow-xs"
              aria-label="Toggle Theme"
            >
              {theme === 'dark' ? (
                <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
                  <path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z" />
                </svg>
              ) : (
                <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
                  <circle cx="12" cy="12" r="4" />
                  <path d="M12 2.5v2.2M12 19.3v2.2M2.5 12h2.2M19.3 12h2.2M5.3 5.3l1.6 1.6M17.1 17.1l1.6 1.6M5.3 18.7l1.6-1.6M17.1 6.9l1.6-1.6" />
                </svg>
              )}
            </button>

            {/* User Pill & Logout Button */}
            <button
              type="button"
              onClick={onLogout}
              className="h-8 px-3 rounded-full bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 text-xs font-semibold transition flex items-center gap-1.5 shadow-xs"
              title="Log out and return to homepage"
            >
              <LogOut className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">{t('logout')}</span>
            </button>
          </div>
        </div>
      </header>

      {/* ------------------------------------------------------------- */}
      {/* 2. HERO GREETING BANNER IN LANDING PAGE STYLE                 */}
      {/* ------------------------------------------------------------- */}
      <section className="relative pt-8 pb-10 px-4 sm:px-6 overflow-hidden border-b border-[var(--border)] bg-[radial-gradient(45%_55%_at_50%_30%,color-mix(in_srgb,var(--accent-gold)_12%,transparent),transparent_70%),linear-gradient(180deg,var(--accent-lavender-subtle),var(--bg-page))]">
        <div className="max-w-[1160px] mx-auto flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div className="space-y-2">
            <div className="inline-flex items-center gap-2 text-xs uppercase font-['DM_Mono',monospace] tracking-widest text-[var(--text-accent)]">
              <span className="w-4 h-[1.5px] bg-[var(--gold-500)]" />
              <span>{role === 'organization' ? 'DZ-Bridge University Portal' : 'DZ-Bridge Diaspora Network'}</span>
              <span className="w-4 h-[1.5px] bg-[var(--gold-500)]" />
            </div>
            <h1 className="text-3xl sm:text-4xl font-['Fraunces',serif] font-semibold text-[var(--text-primary)] tracking-tight">
              {t('welcomeBack')} <span className="text-[var(--text-accent)]">{fullName}</span>
            </h1>
            <p className="text-xs sm:text-sm text-[var(--text-secondary)] max-w-2xl leading-relaxed">
              {role === 'organization' ? t('subtitleOrg') : t('subtitleExpert')}
            </p>
          </div>

          {/* Quick Header CTA */}
          <div className="flex flex-wrap items-center gap-3">
            {role === 'organization' ? (
              <button
                type="button"
                onClick={() => setShowCreateModal(true)}
                className="h-11 px-5 rounded-full bg-[var(--brand)] text-white hover:bg-[var(--brand-hover)] font-medium text-xs transition shadow-sm flex items-center gap-2"
              >
                <Plus className="w-4 h-4" />
                <span>{t('publishProject')}</span>
              </button>
            ) : (
              <button
                type="button"
                onClick={() => setShowAddAvail(true)}
                className="h-11 px-5 rounded-full bg-[var(--gold-500)] text-[var(--plum-900)] hover:bg-[var(--gold-700)] hover:text-white font-medium text-xs transition shadow-sm flex items-center gap-2"
              >
                <Calendar className="w-4 h-4" />
                <span>{t('addVisit')}</span>
              </button>
            )}
          </div>
        </div>
      </section>

      {/* Toast Notification Alert */}
      {saveSuccessMsg && (
        <div className="max-w-[1160px] mx-auto px-4 sm:px-6 pt-4">
          <div className="p-3.5 rounded-xl bg-emerald-50 border border-emerald-300 text-emerald-900 text-xs font-semibold flex items-center justify-between shadow-xs animate-in fade-in">
            <span className="flex items-center gap-2">
              <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
              <span>{saveSuccessMsg}</span>
            </span>
            <button onClick={() => setSaveSuccessMsg(null)} className="text-emerald-700 hover:text-emerald-950">
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}

      {/* ------------------------------------------------------------- */}
      {/* 3. MAIN WORKSPACE CONTENT                                     */}
      {/* ------------------------------------------------------------- */}
      <main className="flex-1 max-w-[1160px] w-full mx-auto px-4 sm:px-6 py-8">
        {/* =========================================================== */}
        {/* TAB 1: PROFILE MANAGEMENT & EDITING                         */}
        {/* =========================================================== */}
        {activeTab === 'profile' && (
          <div className="space-y-6">
            {/* Top Completeness Card */}
            <div className="p-6 rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-5">
              <div className="flex items-center gap-4">
                <div className="w-16 h-16 rounded-2xl bg-[var(--brand)] text-[var(--gold-500)] font-['Fraunces',serif] font-bold text-2xl flex items-center justify-center shadow-md shrink-0">
                  {userInitials}
                </div>
                <div>
                  <h2 className="text-xl font-bold font-['Fraunces',serif] text-[var(--text-primary)]">
                    {fullName}
                  </h2>
                  <p className="text-xs text-[var(--text-secondary)] flex items-center gap-2 mt-0.5">
                    <span>{titleOrRank}</span>
                    <span>·</span>
                    <span className="font-semibold">{affiliation}</span>
                  </p>
                  <p className="text-[11px] text-[var(--text-muted)] flex items-center gap-3 mt-1.5">
                    <span className="flex items-center gap-1">
                      <MapPin className="w-3 h-3 text-[var(--gold-500)]" />
                      <span>{city}, {country}</span>
                    </span>
                    <span className="flex items-center gap-1">
                      <Mail className="w-3 h-3 text-[var(--gold-500)]" />
                      <span>{email}</span>
                    </span>
                  </p>
                </div>
              </div>

              {/* Progress & Edit Toggle */}
              <div className="flex flex-col sm:flex-row sm:items-center gap-4 md:border-s md:border-[var(--border)] md:ps-6">
                <div>
                  <div className="flex items-center justify-between text-xs font-semibold mb-1">
                    <span>{t('completeness')}</span>
                    <span className="text-[var(--gold-700)] font-mono font-bold">92%</span>
                  </div>
                  <div className="w-36 h-2 rounded-full bg-[var(--bg-subtle)] overflow-hidden">
                    <div className="h-full bg-[var(--gold-500)] rounded-full w-[92%]" />
                  </div>
                  <span className="text-[10px] text-[var(--text-muted)] block mt-1">Verified Member</span>
                </div>

                <button
                  type="button"
                  onClick={() => setIsEditing(!isEditing)}
                  className={`h-10 px-5 rounded-full text-xs font-semibold transition flex items-center gap-1.5 shadow-xs ${
                    isEditing
                      ? 'bg-[var(--bg-subtle)] text-[var(--text-primary)] border border-[var(--border)]'
                      : 'bg-[var(--brand)] text-white hover:bg-[var(--brand-hover)]'
                  }`}
                >
                  <Edit3 className="w-3.5 h-3.5" />
                  <span>{isEditing ? 'Cancel Edit' : t('editProfile')}</span>
                </button>
              </div>
            </div>

            {/* Edit Profile Form vs View Details */}
            {isEditing ? (
              <form onSubmit={handleSaveProfile} className="p-7 rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] shadow-sm space-y-5 animate-in fade-in">
                <div className="flex items-center justify-between pb-4 border-b border-[var(--border)]">
                  <div>
                    <h3 className="text-lg font-bold font-['Fraunces',serif] text-[var(--text-primary)]">
                      {t('editProfile')}
                    </h3>
                    <p className="text-xs text-[var(--text-secondary)]">
                      {t('completenessTip')}
                    </p>
                  </div>
                  <button
                    type="submit"
                    disabled={isSaving}
                    className="h-10 px-6 rounded-full bg-[var(--brand)] text-white hover:bg-[var(--brand-hover)] font-semibold text-xs transition shadow-sm flex items-center gap-2 disabled:opacity-50"
                  >
                    <Save className="w-4 h-4" />
                    <span>{isSaving ? t('saving') : t('saveChanges')}</span>
                  </button>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                      {t('fullName')} *
                    </label>
                    <input
                      type="text"
                      value={fullName}
                      onChange={(e) => setFullName(e.target.value)}
                      required
                      className="w-full h-11 px-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm focus:outline-none focus:border-[var(--brand)] focus:ring-1 focus:ring-[var(--brand)]"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                      {t('title')}
                    </label>
                    <input
                      type="text"
                      value={titleOrRank}
                      onChange={(e) => setTitleOrRank(e.target.value)}
                      className="w-full h-11 px-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm focus:outline-none focus:border-[var(--brand)] focus:ring-1 focus:ring-[var(--brand)]"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                      {t('institution')} *
                    </label>
                    <input
                      type="text"
                      value={affiliation}
                      onChange={(e) => setAffiliation(e.target.value)}
                      required
                      className="w-full h-11 px-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm focus:outline-none focus:border-[var(--brand)] focus:ring-1 focus:ring-[var(--brand)]"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                      {t('specialty')} *
                    </label>
                    <input
                      type="text"
                      value={specialty}
                      onChange={(e) => setSpecialty(e.target.value)}
                      required
                      className="w-full h-11 px-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm focus:outline-none focus:border-[var(--brand)] focus:ring-1 focus:ring-[var(--brand)]"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                      {t('country')} *
                    </label>
                    <input
                      type="text"
                      value={country}
                      onChange={(e) => setCountry(e.target.value)}
                      required
                      className="w-full h-11 px-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm focus:outline-none focus:border-[var(--brand)] focus:ring-1 focus:ring-[var(--brand)]"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                      {t('city')}
                    </label>
                    <input
                      type="text"
                      value={city}
                      onChange={(e) => setCity(e.target.value)}
                      className="w-full h-11 px-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm focus:outline-none focus:border-[var(--brand)] focus:ring-1 focus:ring-[var(--brand)]"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                      {t('email')}
                    </label>
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      className="w-full h-11 px-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm focus:outline-none focus:border-[var(--brand)] focus:ring-1 focus:ring-[var(--brand)]"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                      {t('phone')}
                    </label>
                    <input
                      type="text"
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      className="w-full h-11 px-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm focus:outline-none focus:border-[var(--brand)] focus:ring-1 focus:ring-[var(--brand)]"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                    {t('skills')}
                  </label>
                  <input
                    type="text"
                    value={skillsStr}
                    onChange={(e) => setSkillsStr(e.target.value)}
                    placeholder={t('skillsHint')}
                    className="w-full h-11 px-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm focus:outline-none focus:border-[var(--brand)] focus:ring-1 focus:ring-[var(--brand)]"
                  />
                  <span className="text-[11px] text-[var(--text-muted)] block mt-1">{t('skillsHint')}</span>
                </div>

                <div>
                  <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                    {t('bio')}
                  </label>
                  <textarea
                    rows={4}
                    value={bio}
                    onChange={(e) => setBio(e.target.value)}
                    className="w-full p-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm focus:outline-none focus:border-[var(--brand)] focus:ring-1 focus:ring-[var(--brand)] leading-relaxed"
                  />
                </div>

                <div className="pt-2 flex justify-end gap-3">
                  <button
                    type="button"
                    onClick={() => setIsEditing(false)}
                    className="h-10 px-5 rounded-full border border-[var(--border)] text-xs font-semibold hover:bg-[var(--bg-subtle)]"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    disabled={isSaving}
                    className="h-10 px-6 rounded-full bg-[var(--brand)] text-white hover:bg-[var(--brand-hover)] font-semibold text-xs transition shadow-sm flex items-center gap-2"
                  >
                    <Save className="w-4 h-4" />
                    <span>{isSaving ? t('saving') : t('saveChanges')}</span>
                  </button>
                </div>
              </form>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {/* Left 2 Cols: Biography & Skills */}
                <div className="md:col-span-2 space-y-6">
                  {/* Bio Card */}
                  <div className="p-6 rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] shadow-sm space-y-3">
                    <h3 className="text-base font-bold font-['Fraunces',serif] text-[var(--text-primary)]">
                      {t('bio')}
                    </h3>
                    <p className="text-sm text-[var(--text-secondary)] leading-relaxed whitespace-pre-line">
                      {bio}
                    </p>
                  </div>

                  {/* Skills tags Card */}
                  <div className="p-6 rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] shadow-sm space-y-3">
                    <h3 className="text-base font-bold font-['Fraunces',serif] text-[var(--text-primary)]">
                      {t('skills')}
                    </h3>
                    <div className="flex flex-wrap gap-2">
                      {skillsStr.split(',').map((s) => s.trim()).filter(Boolean).map((skill, idx) => (
                        <span
                          key={idx}
                          className="px-3 py-1.5 rounded-full text-xs font-medium bg-[var(--accent-lavender-subtle)] text-[var(--brand)] border border-[var(--border)]"
                        >
                          {skill}
                        </span>
                      ))}
                    </div>
                  </div>
                </div>

                {/* Right Col: Algeria Visit Windows / Logistics */}
                <div className="space-y-6">
                  {role === 'expert' ? (
                    <div className="p-6 rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] shadow-sm space-y-4">
                      <div className="flex items-center justify-between">
                        <h3 className="text-sm font-bold font-['Fraunces',serif] text-[var(--text-primary)]">
                          {t('visitDates')}
                        </h3>
                        <button
                          type="button"
                          onClick={() => setShowAddAvail(true)}
                          className="text-xs text-[var(--text-brand)] font-bold hover:underline flex items-center gap-1"
                        >
                          <Plus className="w-3.5 h-3.5" />
                          <span>Add</span>
                        </button>
                      </div>

                      {expertData.availabilities.length === 0 ? (
                        <div className="p-4 rounded-xl bg-[var(--bg-subtle)] border border-dashed border-[var(--border)] text-center text-xs text-[var(--text-muted)]">
                          {t('noVisits')}
                        </div>
                      ) : (
                        <div className="space-y-2.5">
                          {expertData.availabilities.map((avail) => (
                            <div key={avail.id} className="p-3.5 rounded-xl border border-[var(--border)] bg-[var(--bg-subtle)] space-y-1">
                              <div className="flex items-center justify-between text-xs font-bold text-[var(--text-primary)]">
                                <span className="flex items-center gap-1">
                                  <MapPin className="w-3 h-3 text-[var(--gold-500)]" />
                                  <span>{avail.city}</span>
                                </span>
                                <span className="text-[10px] font-mono px-2 py-0.5 rounded-full bg-[var(--gold-500)] text-[var(--plum-900)] font-bold">
                                  {avail.durationDays} days
                                </span>
                              </div>
                              <div className="text-[11px] text-[var(--text-secondary)] font-mono">
                                {avail.startDate} → {avail.endDate}
                              </div>
                              {avail.notes && (
                                <p className="text-[11px] text-[var(--text-muted)] italic pt-0.5">
                                  "{avail.notes}"
                                </p>
                              )}
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  ) : (
                    <div className="p-6 rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] shadow-sm space-y-4">
                      <h3 className="text-sm font-bold font-['Fraunces',serif] text-[var(--text-primary)]">
                        {t('logisticsOffered')}
                      </h3>
                      <div className="space-y-2 text-xs text-[var(--text-secondary)]">
                        <div className="flex items-center gap-2 p-2 rounded-lg bg-emerald-50 text-emerald-900 border border-emerald-200">
                          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                          <span>{t('travelCovered')} (International Airfare)</span>
                        </div>
                        <div className="flex items-center gap-2 p-2 rounded-lg bg-emerald-50 text-emerald-900 border border-emerald-200">
                          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                          <span>{t('hotelCovered')} (University Residence / Hotel)</span>
                        </div>
                        <div className="flex items-center gap-2 p-2 rounded-lg bg-emerald-50 text-emerald-900 border border-emerald-200">
                          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                          <span>{t('stipendCovered')} (MESRS Standard Honorarium)</span>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* Trust & Verification Pill */}
                  <div className="p-5 rounded-[22px] bg-[radial-gradient(ellipse_at_top,color-mix(in_srgb,var(--gold-500)_15%,transparent),transparent)] border border-[var(--border)] space-y-2 text-center">
                    <Award className="w-6 h-6 text-[var(--gold-500)] mx-auto" />
                    <h4 className="text-xs font-bold text-[var(--text-primary)]">
                      Algerian Scholar Award Foundation
                    </h4>
                    <p className="text-[11px] text-[var(--text-muted)] leading-relaxed">
                      Affiliated national network ensuring confidentiality, merit-based matchmaking, and technology transfer integrity.
                    </p>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}

        {/* =========================================================== */}
        {/* TAB 2: SEARCH & BROWSE COLLABORATION PROJECTS               */}
        {/* =========================================================== */}
        {activeTab === 'projects' && (
          <div className="space-y-6">
            {/* Search Bar & Filters */}
            <div className="p-6 rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] shadow-sm space-y-4">
              <div className="flex flex-col sm:flex-row gap-3">
                <div className="relative flex-1">
                  <Search className="w-4 h-4 text-[var(--text-muted)] absolute left-3.5 rtl:right-3.5 rtl:left-auto top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    placeholder={t('searchPlaceholder')}
                    className="w-full h-12 ps-10 pe-4 rtl:ps-4 rtl:pe-10 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm focus:outline-none focus:border-[var(--brand)] focus:ring-1 focus:ring-[var(--brand)]"
                  />
                  {searchQuery && (
                    <button
                      onClick={() => setSearchQuery('')}
                      className="absolute right-3.5 rtl:left-3.5 rtl:right-auto top-1/2 -translate-y-1/2 text-xs text-[var(--text-muted)] hover:text-[var(--text-primary)]"
                    >
                      Clear
                    </button>
                  )}
                </div>

                {role === 'organization' && (
                  <button
                    type="button"
                    onClick={() => setShowCreateModal(true)}
                    className="h-12 px-6 rounded-xl bg-[var(--brand)] text-white hover:bg-[var(--brand-hover)] font-semibold text-xs transition shadow-sm flex items-center justify-center gap-2 shrink-0"
                  >
                    <Plus className="w-4 h-4" />
                    <span>{t('publishProject')}</span>
                  </button>
                )}
              </div>

              {/* Domain Filter Pills */}
              <div className="flex flex-wrap items-center gap-2 pt-1 border-t border-[var(--border)]">
                <span className="text-xs text-[var(--text-muted)] flex items-center gap-1 font-medium pe-1">
                  <Filter className="w-3.5 h-3.5" />
                  <span>Domain:</span>
                </span>

                {[
                  { id: 'all', label: t('filterAll') },
                  { id: 'ai', label: t('filterAI') },
                  { id: 'energy', label: t('filterEnergy') },
                  { id: 'health', label: t('filterHealth') },
                  { id: 'water', label: t('filterWater') },
                  { id: 'agri', label: t('filterAgri') },
                ].map((chip) => (
                  <button
                    key={chip.id}
                    type="button"
                    onClick={() => setSelectedDomain(chip.id)}
                    className={`px-3 py-1.5 rounded-full text-xs transition font-medium ${
                      selectedDomain === chip.id
                        ? 'bg-[var(--brand)] text-white font-semibold shadow-2xs'
                        : 'bg-[var(--bg-subtle)] text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--border)]'
                    }`}
                  >
                    {chip.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Results Counter */}
            <div className="flex items-center justify-between text-xs text-[var(--text-secondary)] px-1">
              <span>{t('resultsCount', filteredProjects.length)}</span>
              <span className="font-mono text-[11px] text-[var(--text-muted)]">Verified MESRS Projects</span>
            </div>

            {/* Projects Grid */}
            {filteredProjects.length === 0 ? (
              <div className="p-12 text-center rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] space-y-3">
                <Briefcase className="w-10 h-10 text-[var(--text-muted)] mx-auto opacity-50" />
                <h3 className="text-base font-bold font-['Fraunces',serif] text-[var(--text-primary)]">
                  {t('noProjectsFound')}
                </h3>
                <p className="text-xs text-[var(--text-muted)] max-w-md mx-auto">
                  Try adjusting your search terms or clearing the domain filter to view all national opportunities.
                </p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                {filteredProjects.map((proj) => {
                  const isApplied = appliedProjects[proj.id];
                  return (
                    <div
                      key={proj.id}
                      className="p-6 rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] hover:border-[var(--brand)] transition shadow-sm hover:shadow-md flex flex-col justify-between space-y-4"
                    >
                      <div className="space-y-3">
                        {/* Header: University + Location */}
                        <div className="flex items-start justify-between gap-3">
                          <div className="flex items-center gap-2">
                            <div className="w-8 h-8 rounded-lg bg-[var(--accent-lavender-subtle)] text-[var(--brand)] flex items-center justify-center font-bold text-xs shrink-0">
                              <Building2 className="w-4 h-4" />
                            </div>
                            <div>
                              <div className="font-bold text-xs text-[var(--text-primary)] leading-tight">
                                {proj.organizationName}
                              </div>
                              <div className="text-[10px] text-[var(--text-muted)] flex items-center gap-1 mt-0.5">
                                <MapPin className="w-3 h-3 text-[var(--gold-500)]" />
                                <span>{proj.location || 'Algeria'}</span>
                              </div>
                            </div>
                          </div>

                          <span className="px-2.5 py-1 rounded-full text-[10px] font-mono font-bold bg-amber-50 text-amber-900 border border-amber-200">
                            98.2% Match
                          </span>
                        </div>

                        {/* Title & Description */}
                        <div>
                          <h4 className="text-base font-bold font-['Fraunces',serif] text-[var(--text-primary)] leading-snug">
                            {proj.title}
                          </h4>
                          <p className="text-xs text-[var(--text-secondary)] leading-relaxed mt-1.5 line-clamp-3">
                            {proj.description}
                          </p>
                        </div>

                        {/* Logistics Badges */}
                        <div className="flex flex-wrap gap-1.5 pt-1">
                          {proj.logisticsOffered?.travel && (
                            <span className="px-2 py-0.5 rounded-md text-[10px] font-semibold bg-emerald-50 text-emerald-800 border border-emerald-200">
                              ✈️ {t('travelCovered')}
                            </span>
                          )}
                          {proj.logisticsOffered?.lodging && (
                            <span className="px-2 py-0.5 rounded-md text-[10px] font-semibold bg-blue-50 text-blue-800 border border-blue-200">
                              🏨 {t('hotelCovered')}
                            </span>
                          )}
                          {proj.logisticsOffered?.stipend && (
                            <span className="px-2 py-0.5 rounded-md text-[10px] font-semibold bg-amber-50 text-amber-800 border border-amber-200">
                              💵 {t('stipendCovered')}
                            </span>
                          )}
                        </div>

                        {/* Required Skills tags */}
                        <div className="flex flex-wrap gap-1.5 pt-1">
                          {proj.skillsRequired.map((skill, sIdx) => (
                            <span
                              key={sIdx}
                              className="px-2 py-0.5 rounded-md text-[10px] font-medium bg-[var(--bg-subtle)] text-[var(--text-secondary)] border border-[var(--border)]"
                            >
                              {skill}
                            </span>
                          ))}
                        </div>
                      </div>

                      {/* Footer & Action */}
                      <div className="pt-3 border-t border-[var(--border)] flex items-center justify-between gap-3 text-xs">
                        <div className="flex items-center gap-1.5 text-[11px] text-[var(--text-muted)] font-mono">
                          <Calendar className="w-3.5 h-3.5 text-[var(--gold-500)]" />
                          <span>{proj.startDate} → {proj.endDate}</span>
                        </div>

                        {role === 'expert' ? (
                          <button
                            type="button"
                            onClick={() => handleApplyToProject(proj)}
                            disabled={isApplied}
                            className={`h-9 px-4 rounded-full text-xs font-semibold transition flex items-center gap-1.5 shadow-2xs ${
                              isApplied
                                ? 'bg-emerald-100 text-emerald-800 border border-emerald-300 cursor-default'
                                : 'bg-[var(--brand)] text-white hover:bg-[var(--brand-hover)]'
                            }`}
                          >
                            {isApplied ? (
                              <>
                                <CheckCircle2 className="w-3.5 h-3.5" />
                                <span>{t('applied')}</span>
                              </>
                            ) : (
                              <>
                                <span>{t('applyNow')}</span>
                                <ArrowRight className="w-3 h-3 rtl:rotate-180" />
                              </>
                            )}
                          </button>
                        ) : (
                          <span className="text-[11px] font-mono uppercase text-[var(--text-brand)] font-bold">
                            {proj.status}
                          </span>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        )}

        {/* =========================================================== */}
        {/* TAB 3: MY COLLABORATIONS & ACTIVE PARTNERSHIPS              */}
        {/* =========================================================== */}
        {activeTab === 'collaborations' && (
          <div className="space-y-6">
            <div className="p-6 rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] shadow-sm space-y-2">
              <h3 className="text-lg font-bold font-['Fraunces',serif] text-[var(--text-primary)]">
                {t('collabsTitle')}
              </h3>
              <p className="text-xs text-[var(--text-secondary)]">
                All confirmed institutional protocols and bilateral research initiatives verified by MESRS.
              </p>
            </div>

            {collaborations.length === 0 ? (
              <div className="p-12 text-center rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] space-y-3">
                <Handshake className="w-10 h-10 text-[var(--text-muted)] mx-auto opacity-50" />
                <h4 className="text-base font-bold font-['Fraunces',serif] text-[var(--text-primary)]">
                  {t('noCollabs')}
                </h4>
                <button
                  type="button"
                  onClick={() => setActiveTab('projects')}
                  className="mt-2 h-10 px-5 rounded-full bg-[var(--brand)] text-white hover:bg-[var(--brand-hover)] text-xs font-semibold"
                >
                  {t('navProjects')}
                </button>
              </div>
            ) : (
              <div className="space-y-4">
                {collaborations.map((collab) => (
                  <div
                    key={collab.id}
                    className="p-6 rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-5"
                  >
                    <div className="space-y-2">
                      <div className="flex items-center gap-2.5">
                        <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold font-mono uppercase bg-emerald-100 text-emerald-900 border border-emerald-300">
                          {collab.status}
                        </span>
                        <span className="text-xs text-[var(--text-muted)] font-mono">
                          ID: {collab.id}
                        </span>
                      </div>

                      <h4 className="text-base font-bold font-['Fraunces',serif] text-[var(--text-primary)]">
                        {collab.projectTitle}
                      </h4>

                      <div className="text-xs text-[var(--text-secondary)] flex flex-wrap items-center gap-4">
                        <span className="flex items-center gap-1.5 font-medium">
                          <Building2 className="w-3.5 h-3.5 text-[var(--gold-500)]" />
                          <span>{collab.organizationName}</span>
                        </span>
                        <span>·</span>
                        <span className="flex items-center gap-1.5 font-medium">
                          <GraduationCap className="w-3.5 h-3.5 text-[var(--gold-500)]" />
                          <span>{collab.expertName}</span>
                        </span>
                      </div>

                      {collab.notes && (
                        <p className="text-xs text-[var(--text-muted)] italic pt-1">
                          "{collab.notes}"
                        </p>
                      )}
                    </div>

                    <div className="flex items-center gap-3 shrink-0">
                      <span className="text-xs font-mono text-emerald-700 bg-emerald-50 px-3 py-1.5 rounded-xl border border-emerald-200 font-semibold flex items-center gap-1.5">
                        <CheckCircle2 className="w-4 h-4" />
                        <span>Protocol Active</span>
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}
      </main>

      {/* ------------------------------------------------------------- */}
      {/* MODAL 1: ADD AVAILABILITY (EXPERT VISIT TO ALGERIA)           */}
      {/* ------------------------------------------------------------- */}
      {showAddAvail && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="w-full max-w-md p-6 rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] shadow-2xl space-y-4 animate-in zoom-in-95">
            <div className="flex items-center justify-between pb-3 border-b border-[var(--border)]">
              <h3 className="text-base font-bold font-['Fraunces',serif] text-[var(--text-primary)]">
                {t('addVisit')}
              </h3>
              <button onClick={() => setShowAddAvail(false)} className="text-[var(--text-muted)] hover:text-[var(--text-primary)]">
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddAvailSubmit} className="space-y-3.5">
              <div>
                <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                  Target City in Algeria *
                </label>
                <select
                  value={availCity}
                  onChange={(e) => setAvailCity(e.target.value)}
                  className="w-full h-11 px-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm"
                >
                  <option value="Algiers">Algiers (الجزائر العاصمة)</option>
                  <option value="Oran">Oran (وهران)</option>
                  <option value="Constantine">Constantine (قسنطينة)</option>
                  <option value="Biskra">Biskra (بسكرة)</option>
                  <option value="Annaba">Annaba (عنابة)</option>
                  <option value="Batna">Batna (باتنة)</option>
                  <option value="Tlemcen">Tlemcen (تلمسان)</option>
                  <option value="Setif">Sétif (سطيف)</option>
                  <option value="Ouargla">Ouargla (ورقلة)</option>
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                    Start Date *
                  </label>
                  <input
                    type="date"
                    value={availStart}
                    onChange={(e) => setAvailStart(e.target.value)}
                    required
                    className="w-full h-11 px-3 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-xs font-mono"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                    End Date *
                  </label>
                  <input
                    type="date"
                    value={availEnd}
                    onChange={(e) => setAvailEnd(e.target.value)}
                    required
                    className="w-full h-11 px-3 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-xs font-mono"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                  Scope of Mission / Collaboration Objectives
                </label>
                <textarea
                  rows={3}
                  value={availNotes}
                  onChange={(e) => setAvailNotes(e.target.value)}
                  placeholder="Doctoral seminars, masterclasses, thesis jury, joint laboratory research…"
                  className="w-full p-3 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-xs"
                />
              </div>

              <div className="pt-2 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowAddAvail(false)}
                  className="h-10 px-4 rounded-full border border-[var(--border)] text-xs font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="h-10 px-5 rounded-full bg-[var(--brand)] text-white hover:bg-[var(--brand-hover)] text-xs font-semibold"
                >
                  Confirm & Publish
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ------------------------------------------------------------- */}
      {/* MODAL 2: ORGANIZATION SUBMIT NEW PROJECT                      */}
      {/* ------------------------------------------------------------- */}
      {showCreateModal && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="w-full max-w-lg p-6 rounded-[22px] bg-[var(--bg-surface)] border border-[var(--border)] shadow-2xl space-y-4 animate-in zoom-in-95">
            <div className="flex items-center justify-between pb-3 border-b border-[var(--border)]">
              <h3 className="text-base font-bold font-['Fraunces',serif] text-[var(--text-primary)]">
                {t('publishProject')}
              </h3>
              <button onClick={() => setShowCreateModal(false)} className="text-[var(--text-muted)] hover:text-[var(--text-primary)]">
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateProjectSubmit} className="space-y-3.5">
              <div>
                <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                  {t('newProjectTitle')} *
                </label>
                <input
                  type="text"
                  value={newProjTitle}
                  onChange={(e) => setNewProjTitle(e.target.value)}
                  placeholder="e.g. Advanced Nanotechnology Workshop for Solar PV"
                  required
                  className="w-full h-11 px-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                  {t('newProjectDesc')} *
                </label>
                <textarea
                  rows={4}
                  value={newProjDesc}
                  onChange={(e) => setNewProjDesc(e.target.value)}
                  placeholder="Describe research goals, masterclasses, and expected outcomes…"
                  required
                  className="w-full p-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                  {t('skillsNeeded')} (comma-separated)
                </label>
                <input
                  type="text"
                  value={newProjSkills}
                  onChange={(e) => setNewProjSkills(e.target.value)}
                  className="w-full h-11 px-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold mb-1 text-[var(--text-secondary)]">
                  City Location *
                </label>
                <input
                  type="text"
                  value={newProjLocation}
                  onChange={(e) => setNewProjLocation(e.target.value)}
                  required
                  className="w-full h-11 px-3.5 rounded-xl border border-[var(--border-strong)] bg-[var(--bg-surface)] text-sm"
                />
              </div>

              <div className="pt-2 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowCreateModal(false)}
                  className="h-10 px-4 rounded-full border border-[var(--border)] text-xs font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="h-10 px-6 rounded-full bg-[var(--brand)] text-white hover:bg-[var(--brand-hover)] text-xs font-semibold shadow-sm"
                >
                  Publish Initiative
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ------------------------------------------------------------- */}
      {/* 4. FOOTER IN LANDING PAGE STYLE                               */}
      {/* ------------------------------------------------------------- */}
      <footer className="mt-auto py-6 border-t border-[var(--border)] bg-[var(--bg-subtle)] text-xs text-[var(--text-secondary)]">
        <div className="max-w-[1160px] mx-auto px-4 sm:px-6 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <span className="w-5 h-5 rounded-md bg-[var(--plum-800)] text-white flex items-center justify-center font-bold text-[10px]">
              DZ
            </span>
            <span>© 2026 DZ-Bridge · Algerian Scholar Award Foundation</span>
          </div>

          <div className="flex items-center gap-3">
            <button onClick={onLogout} className="hover:underline font-semibold text-[var(--text-brand)]">
              {t('logout')}
            </button>
          </div>
        </div>
      </footer>
    </div>
  );
};
