import React, { useState, useEffect, useRef, ReactNode } from 'react';
import {
  FolderOpen, Download, CheckCircle, Activity, Settings,
  AlertTriangle, Trash2, Minus, X, Play, Home, Palette, RefreshCw,
  ExternalLink, Search, Filter, ChevronRight, ChevronDown, Power,
  Star, Upload, Share2, Keyboard, ChevronLeft, Eye, HelpCircle,
  Rocket, MessageCircle, Sparkles, SplitSquareHorizontal, Image,
  Camera, Heart, Copy, Maximize2, Grid, FolderOpen as FolderOpenIcon,
  Clock, HardDrive, ArrowUpDown, Info, User, LogOut,
  Sun, Moon, Monitor, LayoutGrid, LayoutList, GalleryHorizontal, Loader2, Shield,
  TrendingUp
} from 'lucide-react';
import { invoke, convertFileSrc } from '@tauri-apps/api/core';
import { getCurrentWindow } from '@tauri-apps/api/window';
import { getVersion } from '@tauri-apps/api/app';
import { exit } from '@tauri-apps/plugin-process';
import { open, save } from '@tauri-apps/plugin-dialog';
import { open as shellOpen } from '@tauri-apps/plugin-shell';

import './App.css';
import { ImageComparisonSlider } from './components/ImageComparisonSlider';
import { CachedImage } from './components/CachedImage';
import { StarRating, UserRating } from './components/StarRating';
import { SubmissionWizard } from './components/SubmissionWizard';
import { ModerationPanel } from './components/ModerationPanel';
import { UserProfile } from './components/UserProfile';

const appWindow = getCurrentWindow();

// ============== Helper Functions ==============

// Capitalize first letter of each word (title case)
const toTitleCase = (str: string) => {
  return str.replace(/\b\w/g, char => char.toUpperCase());
};

// Compare semantic versions (returns true if v2 > v1)
const isNewerVersion = (v1: string, v2: string): boolean => {
  const normalize = (v: string) => v.replace(/^v/, '').split('.').map(n => parseInt(n, 10) || 0);
  const parts1 = normalize(v1);
  const parts2 = normalize(v2);
  const maxLen = Math.max(parts1.length, parts2.length);
  for (let i = 0; i < maxLen; i++) {
    const p1 = parts1[i] || 0;
    const p2 = parts2[i] || 0;
    if (p2 > p1) return true;
    if (p2 < p1) return false;
  }
  return false;
};

// ============== Type Definitions ==============

interface ValidationResult {
  is_valid: boolean;
  hytale_path: string | null;
  hytale_version: string | null;
  gshade_installed: boolean;
  gshade_enabled: boolean;
}

// Theme options
type ThemePreference = 'system' | 'light' | 'dark' | 'oled';

// Layout options
type LayoutPreference = 'rows' | 'grid' | 'gallery';

interface AppSettings {
  hytale_path: string | null;
  gshade_enabled: boolean;
  last_preset: string | null;
  tutorial_completed?: boolean;
  theme?: ThemePreference;
  presets_layout?: LayoutPreference;
  gallery_layout?: LayoutPreference;
}

// Tutorial step interface
interface TutorialStep {
  title: string;
  description: string;
  icon: ReactNode;
  anchorId?: string; // ID of element to anchor popover to
  position?: 'modal' | 'right' | 'bottom'; // Where to show the popover
  navigateTo?: 'home' | 'presets' | 'gallery' | 'settings'; // Page to navigate to for this step
  highlight?: string; // CSS selector for element to highlight
}

// Tutorial steps configuration - Interactive guided tour
const TUTORIAL_STEPS: TutorialStep[] = [
  {
    title: "Welcome to OrbisFX Launcher!",
    description: "Let's take a quick tour of the app. I'll show you how to enhance your Hytale experience with beautiful graphics presets. You can skip at any time.",
    icon: <Sparkles size={48} className="text-hytale-accent" />,
    position: 'modal'
  },
  {
    title: "Your Home Dashboard",
    description: "This is your command center! Here you can see your setup status, launch Hytale with one click, and toggle graphics effects on/off. The status card shows if OrbisFX is ready to use.",
    icon: <Home size={48} className="text-hytale-accent" />,
    navigateTo: 'home',
    position: 'modal'
  },
  {
    title: "Browse Graphics Presets",
    description: "Welcome to the Preset Library! Here you'll find community-created graphics presets. Each preset transforms how Hytale looks - from subtle enhancements to dramatic visual overhauls.",
    icon: <Palette size={48} className="text-hytale-accent" />,
    navigateTo: 'presets',
    position: 'modal'
  },
  {
    title: "Installing a Preset",
    description: "Click on any preset card to see details and comparison screenshots. Hit 'Install' to download it. Installed presets appear in 'My Library' where you can activate them with one click!",
    icon: <Download size={48} className="text-hytale-accent" />,
    navigateTo: 'presets',
    anchorId: 'nav-presets',
    position: 'right'
  },
  {
    title: "Your Screenshot Gallery",
    description: "Every screenshot you take in Hytale appears here! You can favorite your best shots, sort them by date or preset, and even copy them to your clipboard. Press the screenshot hotkey in-game to capture moments.",
    icon: <Camera size={48} className="text-hytale-accent" />,
    navigateTo: 'gallery',
    position: 'modal'
  },
  {
    title: "App Settings",
    description: "Configure your Hytale installation path, manage the OrbisFX runtime, and customize your experience. You can also replay this tutorial anytime from here!",
    icon: <Settings size={48} className="text-hytale-accent" />,
    navigateTo: 'settings',
    position: 'modal'
  },
  {
    title: "Quick Launch Button",
    description: "Notice the 'Play Hytale' button in the sidebar? It's always there so you can launch the game from any page. The status indicator shows when you're ready to play.",
    icon: <Play size={48} className="text-hytale-accent" />,
    navigateTo: 'home',
    anchorId: 'nav-discord',
    position: 'right'
  },
  {
    title: "Join Our Community",
    description: "Have questions or want to share your presets? Join our Discord community! Click the Discord button anytime to connect with other OrbisFX users.",
    icon: <MessageCircle size={48} className="text-discord" />,
    anchorId: 'nav-discord',
    position: 'right'
  },
  {
    title: "You're Ready to Go!",
    description: "That's everything! Start by browsing presets and installing one you like. Launch Hytale and enjoy your enhanced graphics. Have fun!",
    icon: <Rocket size={48} className="text-hytale-accent" />,
    navigateTo: 'home',
    position: 'modal'
  }
];

interface Preset {
  id: string;
  name: string;
  author: string;
  description: string;
  thumbnail: string;
  download_url: string;
  version: string;
  category: string;
  filename: string;
  images: string[];
  long_description?: string;
  features?: string[];
  vanilla_image?: string;
  toggled_image?: string;
}

// Source type for installed presets
type PresetSource = 'official' | 'community' | 'local';

interface InstalledPreset {
  id: string;
  name: string;
  version: string;
  filename: string;
  installed_at: string;
  is_active: boolean;
  is_favorite: boolean;
  is_local: boolean;
  source_path?: string;
  source?: PresetSource;
  source_id?: string;
}

interface CommunityPreset {
  id: string;
  slug: string;
  name: string;
  description: string;
  long_description?: string;
  category: string;
  version: string;
  author_name: string;
  author_discord_id: string;
  author_avatar?: string;
  thumbnail_url?: string;
  preset_file_url: string;
  download_count: number;
  status: string;
  created_at: string;
  images: {
    id: string;
    image_type: string;
    pair_index?: number;
    full_image_url: string;
    thumbnail_url?: string;
  }[];
}

interface GShadeHotkeys {
  key_effects: string;
  key_overlay: string;
  key_screenshot: string;
  key_next_preset: string;
  key_prev_preset: string;
}

interface PresetManifest {
  version: string;
  presets: Preset[];
}

interface Screenshot {
  id: string;
  filename: string;
  path: string;
  preset_name?: string;
  timestamp: string;
  is_favorite: boolean;
  file_size: number;
}

// Rating types
interface PresetRatingSummary {
  preset_id: string;
  average_rating: number;
  total_ratings: number;
}

type PresetSortOption = 'name-asc' | 'name-desc' | 'rating-desc' | 'rating-asc' | 'most-rated' | 'category';

type Page = 'home' | 'presets' | 'settings' | 'setup' | 'gallery' | 'moderation' | 'profile';

// Discord user info from auth
interface CurrentUserInfo {
  id: string;
  username: string;
  discriminator: string;
  avatar_url: string;
  banner_url?: string;
  banner_color?: string;
  accent_color?: number;
  display_name: string;
}

// ============== Helper Components ==============

const ProgressBar: React.FC<{ progress: number }> = ({ progress }) => (
  <div className="w-full h-2 bg-[var(--hytale-bg-tertiary)] rounded-full overflow-hidden border border-[var(--hytale-border-primary)] relative">
    <div
      className="h-full progress-bar-gradient transition-all duration-300 ease-out"
      style={{ width: `${progress}%` }}
    />
  </div>
);

const TerminalLog: React.FC<{ logs: string[] }> = ({ logs }) => {
  const endRef = useRef<HTMLDivElement>(null);
  useEffect(() => endRef.current?.scrollIntoView({ behavior: "smooth" }), [logs]);

  return (
    <div className="bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-primary)] rounded-md p-4 font-mono text-xs text-[var(--hytale-text-secondary)] h-32 overflow-y-auto shadow-inner relative">
      {logs.map((log, i) => (
        <div key={i} className={`mb-1 ${log.includes("COMPLETE") ? "text-[var(--hytale-warning)] font-bold" : ""} ${log.includes("Error") ? "text-[var(--hytale-error)]" : ""}`}>
          {log}
        </div>
      ))}
      <div ref={endRef} />
    </div>
  );
};

// Collapsible settings section component - Enhanced styling
const SettingsSection: React.FC<{
  id: string;
  title: string;
  description: string;
  icon: React.ReactNode;
  expanded: boolean;
  onToggle: () => void;
  children: ReactNode;
  badge?: React.ReactNode;
  accentColor?: string;
}> = ({ title, description, icon, expanded, onToggle, children, badge, accentColor }) => (
  <div className={`bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-xl overflow-hidden transition-all duration-200 ${expanded ? 'shadow-lg' : 'hover:border-[var(--hytale-border-hover)]'}`}>
    {/* Accent bar when expanded */}
    {expanded && (
      <div className={`h-0.5 ${accentColor || 'bg-gradient-to-r from-[var(--hytale-accent-blue)] to-purple-500'}`}></div>
    )}
    <button
      onClick={onToggle}
      className="w-full p-5 flex items-center gap-4 hover:bg-[var(--hytale-bg-elevated)]/50 transition-colors text-left group"
    >
      <div className={`w-11 h-11 rounded-xl flex items-center justify-center flex-shrink-0 transition-all duration-200 ${
        expanded
          ? 'bg-[var(--hytale-accent-blue)]/15 ring-1 ring-[var(--hytale-accent-blue)]/30'
          : 'bg-[var(--hytale-bg-elevated)] group-hover:bg-[var(--hytale-bg-hover)]'
      }`}>
        {icon}
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className="font-hytale font-bold text-[var(--hytale-text-primary)] text-base tracking-wide">{title}</span>
          {badge}
        </div>
        <p className="text-[var(--hytale-text-muted)] text-sm font-body mt-0.5">{description}</p>
      </div>
      <div className={`w-8 h-8 rounded-lg flex items-center justify-center transition-all duration-200 ${
        expanded ? 'bg-[var(--hytale-accent-blue)]/20' : 'bg-[var(--hytale-bg-elevated)] group-hover:bg-[var(--hytale-bg-hover)]'
      }`}>
        <ChevronDown
          size={18}
          className={`transition-transform duration-300 ${expanded ? 'rotate-180 text-[var(--hytale-accent-blue)]' : 'text-[var(--hytale-text-dim)]'}`}
        />
      </div>
    </button>
    <div className={`grid transition-all duration-300 ease-in-out ${expanded ? 'grid-rows-[1fr]' : 'grid-rows-[0fr]'}`}>
      <div className="overflow-hidden">
        <div className="px-6 pb-6 pt-2 bg-[var(--hytale-bg-elevated)]/30 border-t border-[var(--hytale-border-card)]">
          {children}
        </div>
      </div>
    </div>
  </div>
);

const App: React.FC = () => {
  // Navigation state - start on 'setup' if first launch
  const [currentPage, setCurrentPage] = useState<Page>('home');
  const [isFirstLaunch, setIsFirstLaunch] = useState(true);
  const [setupStep, setSetupStep] = useState(0); // 0: welcome, 1: path, 2: install, 3: done

  // Settings & path state
  const [settings, setSettings] = useState<AppSettings>({
    hytale_path: null,
    gshade_enabled: true,
    last_preset: null,
    theme: 'system',
    presets_layout: 'grid',
    gallery_layout: 'grid'
  });
  const [installPath, setInstallPath] = useState<string>("");
  const [validationStatus, setValidationStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [validationResult, setValidationResult] = useState<ValidationResult | null>(null);

  // Resolved theme (for system preference)
  const [resolvedTheme, setResolvedTheme] = useState<'light' | 'dark' | 'oled'>('dark');

  // Preset state
  const [presets, setPresets] = useState<Preset[]>([]);
  const [installedPresets, setInstalledPresets] = useState<InstalledPreset[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [libraryFilter, setLibraryFilter] = useState<'all' | 'official' | 'community' | 'local'>('all');
  const [presetsLoading, setPresetsLoading] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [presetTab, setPresetTab] = useState<'library' | 'public' | 'community'>('library');
  const [showSubmissionWizard, setShowSubmissionWizard] = useState(false);
  const [communityPresets, setCommunityPresets] = useState<CommunityPreset[]>([]);
  const [communityLoading, setCommunityLoading] = useState(false);
  const [communitySearch, setCommunitySearch] = useState('');
  const [communityCategory, setCommunityCategory] = useState<string>('all');
  const [communitySort, setCommunitySort] = useState<PresetSortOption>('name-asc');
  const [trendingPresets, setTrendingPresets] = useState<CommunityPreset[]>([]);
  const [trendingLoading, setTrendingLoading] = useState(false);

  // Installation state
  const [isInstalling, setIsInstalling] = useState(false);
  const [installProgress, setInstallProgress] = useState(0);
  const [installLogs, setInstallLogs] = useState<string[]>([]);
  const [error, setError] = useState<string | null>(null);

  // Update state
  const [appVersion, setAppVersion] = useState<string>('0.0.0');
  const [updateAvailable, setUpdateAvailable] = useState(false);
  const [latestVersion, setLatestVersion] = useState<string | null>(null);
  const [updateDownloadUrl, setUpdateDownloadUrl] = useState<string | null>(null);
  const [showUpdateModal, setShowUpdateModal] = useState(false);
  const [isDownloadingUpdate, setIsDownloadingUpdate] = useState(false);

  // Tutorial state
  const [showTutorial, setShowTutorial] = useState(false);
  const [tutorialStep, setTutorialStep] = useState(0);

  // Hotkey state
  const [hotkeys, setHotkeys] = useState<GShadeHotkeys | null>(null);

  // Preset detail modal state
  const [selectedPreset, setSelectedPreset] = useState<Preset | null>(null);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [showComparisonView, setShowComparisonView] = useState(false);

  // Community preset detail modal state
  const [selectedCommunityPreset, setSelectedCommunityPreset] = useState<CommunityPreset | null>(null);
  const [communityImageIndex, setCommunityImageIndex] = useState(0);
  const [communityShowComparison, setCommunityShowComparison] = useState(false);

  // Screenshot gallery state
  const [screenshots, setScreenshots] = useState<Screenshot[]>([]);
  const [screenshotsLoading, setScreenshotsLoading] = useState(false);
  const [screenshotFilter, setScreenshotFilter] = useState<'all' | 'favorites'>('all');
  const [screenshotPresetFilter, setScreenshotPresetFilter] = useState<string>('all');
  const [screenshotPresets, setScreenshotPresets] = useState<string[]>([]);
  const [fullscreenScreenshot, setFullscreenScreenshot] = useState<Screenshot | null>(null);
  const [screenshotSearchQuery, setScreenshotSearchQuery] = useState('');
  const [screenshotSort, setScreenshotSort] = useState<'date-desc' | 'date-asc' | 'name-asc' | 'name-desc' | 'size-desc' | 'size-asc' | 'preset-asc' | 'preset-desc' | 'favorites'>('date-desc');

  // Rating state
  const [presetRatings, setPresetRatings] = useState<Record<string, PresetRatingSummary>>({});
  const [myRatings, setMyRatings] = useState<Record<string, number>>({});
  const [presetSort, setPresetSort] = useState<PresetSortOption>('name-asc');
  const [ratingsLoading, setRatingsLoading] = useState(false);

  // Rating modal state - supports both Preset and CommunityPreset
  const [ratingModalPreset, setRatingModalPreset] = useState<Preset | null>(null);
  const [ratingModalCommunityPreset, setRatingModalCommunityPreset] = useState<CommunityPreset | null>(null);
  const [pendingRating, setPendingRating] = useState<number>(0);
  const [ratingSubmitting, setRatingSubmitting] = useState(false);
  const [ratingSuccess, setRatingSuccess] = useState(false);

  // Auth & Moderator state
  const [currentUserDiscordId, setCurrentUserDiscordId] = useState<string | null>(null);
  const [currentUserInfo, setCurrentUserInfo] = useState<CurrentUserInfo | null>(null);
  const [isModerator, setIsModerator] = useState(false);
  const [viewingProfileId, setViewingProfileId] = useState<string | null>(null);

  // Community delete modal state (moderator only)
  const [deleteCommunityModalOpen, setDeleteCommunityModalOpen] = useState(false);
  const [deleteCommunityPresetId, setDeleteCommunityPresetId] = useState<string | null>(null);
  const [deleteCommunityReason, setDeleteCommunityReason] = useState('');
  const [deletingCommunityPreset, setDeletingCommunityPreset] = useState(false);

  // Settings page accordion state
  const [settingsExpanded, setSettingsExpanded] = useState<Record<string, boolean>>({
    game: true,
    runtime: false,
    appearance: false,
    about: false
  });

  // Gallery filter panel state
  const [showGalleryFilters, setShowGalleryFilters] = useState(false);

  // Load settings on mount and check if first launch
  useEffect(() => {
    const init = async () => {
      // Get app version
      try {
        const version = await getVersion();
        setAppVersion(version);
      } catch (e) {
        console.error('Failed to get app version:', e);
      }

      const result = await invoke('load_settings') as { success: boolean; settings: AppSettings };
      if (result.success && result.settings && result.settings.hytale_path) {
        // Settings exist - not first launch
        setSettings(result.settings);
        setInstallPath(result.settings.hytale_path);
        setIsFirstLaunch(false);
        setCurrentPage('home');
        // Show tutorial if not completed
        if (!result.settings.tutorial_completed) {
          setShowTutorial(true);
          setTutorialStep(0);
        }
      } else {
        // First launch - show setup wizard
        setIsFirstLaunch(true);
        setCurrentPage('setup');
      }
      checkForUpdates();

      // Check moderator status if logged in
      try {
        const authResponse = await invoke<{ user: CurrentUserInfo | null; is_authenticated: boolean }>('discord_get_current_user');
        if (authResponse.is_authenticated && authResponse.user) {
          setCurrentUserDiscordId(authResponse.user.id);
          setCurrentUserInfo(authResponse.user);
          const modResult = await invoke<{ success: boolean; is_moderator: boolean }>('check_moderator_status', { discordId: authResponse.user.id });
          if (modResult.success && modResult.is_moderator) {
            setIsModerator(true);
          }
        }
      } catch (e) {
        console.error('Failed to check moderator status:', e);
      }
    };
    init();
  }, []);

  // Validate path when installPath changes
  useEffect(() => {
    if (installPath) {
      validateInstallationPath(installPath);
    }
  }, [installPath]);

  // Theme detection and application
  useEffect(() => {
    const applyTheme = (theme: ThemePreference) => {
      if (theme === 'system') {
        // Detect system preference
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        const resolved = prefersDark ? 'dark' : 'light';
        setResolvedTheme(resolved);
        document.documentElement.setAttribute('data-theme', resolved);
      } else {
        setResolvedTheme(theme as 'light' | 'dark' | 'oled');
        document.documentElement.setAttribute('data-theme', theme);
      }
    };

    // Apply current theme
    applyTheme(settings.theme || 'system');

    // Listen for system theme changes when using 'system' preference
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    const handleSystemThemeChange = () => {
      if (settings.theme === 'system') {
        applyTheme('system');
      }
    };

    mediaQuery.addEventListener('change', handleSystemThemeChange);
    return () => mediaQuery.removeEventListener('change', handleSystemThemeChange);
  }, [settings.theme]);

  const saveSettings = async (newSettings: AppSettings) => {
    try {
      await invoke('save_settings', { settings: newSettings });
      setSettings(newSettings);
    } catch (e) {
      console.error('Failed to save settings:', e);
    }
  };

  const validateInstallationPath = async (path: string) => {
    if (!path) {
      setValidationStatus('idle');
      setValidationResult(null);
      return;
    }
    setValidationStatus('loading');
    try {
      const result: ValidationResult = await invoke('validate_path', { hytaleDir: path });
      setValidationResult(result);
      setValidationStatus(result.is_valid ? 'success' : 'error');
    } catch (e) {
      console.error('Validation failed:', e);
      setValidationStatus('error');
    }
  };

  const handleBrowse = async () => {
    try {
      const selected = await open({
        directory: true,
        multiple: false,
        title: 'Select Hytale Client Directory'
      });
      if (selected && typeof selected === 'string') {
        setInstallPath(selected);
        await saveSettings({ ...settings, hytale_path: selected });
      }
    } catch (e) {
      console.error('Failed to open directory picker:', e);
    }
  };

  const handleLaunchGame = async () => {
    if (!validationResult?.is_valid) {
      setError("Please configure a valid Hytale installation path first.");
      return;
    }
    try {
      const result = await invoke('launch_game', { hytaleDir: installPath }) as { success: boolean; message: string };
      if (!result.success) {
        setError(result.message);
      }
    } catch (e) {
      setError(`Failed to launch game: ${e}`);
    }
  };

  const handleToggleRuntime = async (enabled: boolean) => {
    if (!installPath) return;
    try {
      const result = await invoke('toggle_gshade', { hytaleDir: installPath, enabled }) as { success: boolean; error?: string };
      if (result.success) {
        await saveSettings({ ...settings, gshade_enabled: enabled });
        await validateInstallationPath(installPath);
      } else {
        setError(result.error || 'Failed to toggle runtime');
      }
    } catch (e) {
      console.error('Failed to toggle runtime:', e);
      setError(`Failed to toggle runtime: ${e}`);
    }
  };

  const fetchPresets = async () => {
    setPresetsLoading(true);
    try {
      const result = await invoke('fetch_presets') as { success: boolean; manifest?: PresetManifest; error?: string };
      if (result.success && result.manifest) {
        setPresets(result.manifest.presets);
      }
    } catch (e) {
      console.error('Failed to fetch presets:', e);
    }
    setPresetsLoading(false);
  };

  const loadInstalledPresets = async () => {
    try {
      const result = await invoke('get_installed_presets') as { success: boolean; presets: InstalledPreset[] };
      if (result.success) {
        setInstalledPresets(result.presets);
      }
    } catch (e) {
      console.error('Failed to load installed presets:', e);
    }
  };

  const loadCommunityPresets = async () => {
    setCommunityLoading(true);
    try {
      // Load all community presets - filtering is done client-side
      const result = await invoke<CommunityPreset[]>('fetch_community_presets', {
        page: 1,
        perPage: 100,
        category: null,
        search: null,
      });
      setCommunityPresets(result);
    } catch (e) {
      console.error('Failed to load community presets:', e);
    } finally {
      setCommunityLoading(false);
    }
  };

  // ============== Discord Auth Handlers ==============
  const handleDiscordLogin = async () => {
    try {
      // Start local OAuth callback server
      const port = await invoke<number>('discord_start_oauth_server');
      const authUrl = await invoke<string>('discord_get_auth_url_with_port', { port });

      // Open in default browser
      await shellOpen(authUrl);

      // Poll for OAuth code
      const pollForCode = async (): Promise<string | null> => {
        for (let i = 0; i < 120; i++) {
          await new Promise(resolve => setTimeout(resolve, 1000));
          const code = await invoke<string | null>('discord_check_oauth_code');
          if (code) return code;
        }
        return null;
      };

      const code = await pollForCode();
      if (!code) {
        setError('Login timed out. Please try again.');
        return;
      }

      // Complete OAuth flow
      const response = await invoke<{ user: CurrentUserInfo | null; is_authenticated: boolean }>(
        'discord_complete_oauth', { code, port }
      );

      if (response.is_authenticated && response.user) {
        setCurrentUserDiscordId(response.user.id);
        setCurrentUserInfo(response.user);
        setViewingProfileId(response.user.id);

        // Check moderator status
        const modResult = await invoke<{ success: boolean; is_moderator: boolean }>(
          'check_moderator_status', { discordId: response.user.id }
        );
        if (modResult.success && modResult.is_moderator) {
          setIsModerator(true);
        }
      }
    } catch (err) {
      console.error('Discord login failed:', err);
      setError(`Login failed: ${err}`);
    }
  };

  const handleDiscordLogout = async () => {
    try {
      await invoke('discord_logout');
      setCurrentUserDiscordId(null);
      setCurrentUserInfo(null);
      setIsModerator(false);
      setViewingProfileId(null);
    } catch (err) {
      console.error('Logout failed:', err);
    }
  };

  const loadTrendingPresets = async () => {
    setTrendingLoading(true);
    try {
      const result = await invoke<CommunityPreset[]>('fetch_trending_presets', { limit: 6 });
      setTrendingPresets(result);
    } catch (e) {
      console.error('Failed to load trending presets:', e);
    } finally {
      setTrendingLoading(false);
    }
  };

  // Handle deleting a community preset (moderator only)
  const handleDeleteCommunityPreset = async () => {
    if (!deleteCommunityPresetId || !currentUserDiscordId) return;
    setDeletingCommunityPreset(true);

    try {
      const result = await invoke<{ success: boolean; error?: string }>(
        'delete_community_preset',
        { presetId: deleteCommunityPresetId, discordId: currentUserDiscordId, reason: deleteCommunityReason || null }
      );

      if (result.success) {
        // Remove from local state and close modal
        setCommunityPresets(prev => prev.filter(p => p.id !== deleteCommunityPresetId));
        setDeleteCommunityModalOpen(false);
        setDeleteCommunityPresetId(null);
        setDeleteCommunityReason('');
      } else {
        console.error('Failed to delete preset:', result.error);
        setError(result.error || 'Failed to delete preset');
      }
    } catch (e) {
      console.error('Error deleting preset:', e);
      setError(`Error deleting preset: ${e}`);
    } finally {
      setDeletingCommunityPreset(false);
    }
  };

  // Rating functions
  const loadRatings = async () => {
    setRatingsLoading(true);
    try {
      // Fetch all rating summaries
      const ratingsResult = await invoke('get_preset_ratings') as {
        success: boolean;
        ratings: PresetRatingSummary[];
        error?: string;
      };
      if (ratingsResult.success) {
        const ratingsMap: Record<string, PresetRatingSummary> = {};
        ratingsResult.ratings.forEach(r => {
          ratingsMap[r.preset_id] = r;
        });
        setPresetRatings(ratingsMap);
      }

      // Fetch user's own ratings
      const myRatingsResult = await invoke('get_my_ratings') as {
        success: boolean;
        ratings: Record<string, number>;
        error?: string;
      };
      if (myRatingsResult.success) {
        setMyRatings(myRatingsResult.ratings);
      }
    } catch (e) {
      console.error('Failed to load ratings:', e);
    }
    setRatingsLoading(false);
  };

  // Open rating modal for an official preset
  const openRatingModal = (preset: Preset) => {
    setRatingModalPreset(preset);
    setRatingModalCommunityPreset(null);
    setPendingRating(myRatings[preset.id] || 0);
    setRatingSuccess(false);
    setRatingSubmitting(false);
  };

  // Open rating modal for a community preset
  const openCommunityRatingModal = (preset: CommunityPreset) => {
    setRatingModalCommunityPreset(preset);
    setRatingModalPreset(null);
    setPendingRating(myRatings[preset.id] || 0);
    setRatingSuccess(false);
    setRatingSubmitting(false);
  };

  // Close rating modal
  const closeRatingModal = () => {
    setRatingModalPreset(null);
    setRatingModalCommunityPreset(null);
    setPendingRating(0);
    setRatingSuccess(false);
    setRatingSubmitting(false);
  };

  // Get the currently active rating preset (either official or community)
  const activeRatingPreset = ratingModalPreset || ratingModalCommunityPreset;

  // Submit rating from modal
  const handleSubmitRating = async () => {
    if (!activeRatingPreset || pendingRating < 1 || pendingRating > 5) return;

    setRatingSubmitting(true);
    try {
      const result = await invoke('rate_preset', {
        presetId: activeRatingPreset.id,
        rating: pendingRating
      }) as {
        success: boolean;
        error?: string;
      };
      if (result.success) {
        // Update local state
        setMyRatings(prev => ({ ...prev, [activeRatingPreset.id]: pendingRating }));
        // Refresh ratings to get updated averages
        loadRatings();
        // Show success state
        setRatingSuccess(true);
        // Auto-close after delay
        setTimeout(() => {
          closeRatingModal();
        }, 1500);
      } else {
        setError(result.error || 'Failed to submit rating');
        setRatingSubmitting(false);
      }
    } catch (e) {
      console.error('Failed to rate preset:', e);
      setError(`Failed to submit rating: ${e}`);
      setRatingSubmitting(false);
    }
  };

  const handleDownloadPreset = async (preset: Preset) => {
    if (!installPath) {
      setError("Please configure Hytale installation path first.");
      return;
    }
    try {
      const result = await invoke('download_preset', { preset, hytaleDir: installPath }) as { success: boolean; message?: string; error?: string };
      if (result.success) {
        await loadInstalledPresets();
      } else {
        setError(result.error || 'Failed to download preset');
      }
    } catch (e) {
      setError(`Failed to download preset: ${e}`);
    }
  };

  const handleDeletePreset = async (presetId: string) => {
    if (!installPath) return;
    try {
      await invoke('delete_preset', { presetId, hytaleDir: installPath });
      await loadInstalledPresets();
    } catch (e) {
      console.error('Failed to delete preset:', e);
    }
  };

  const handleActivatePreset = async (presetId: string) => {
    if (!installPath) return;
    try {
      const result = await invoke('activate_preset', { presetId, hytaleDir: installPath }) as { success: boolean; error?: string };
      if (result.success) {
        await loadInstalledPresets();
      } else {
        setError(result.error || 'Failed to activate preset');
      }
    } catch (e) {
      console.error('Failed to activate preset:', e);
      setError(`Failed to activate preset: ${e}`);
    }
  };

  const handleImportPreset = async () => {
    if (!installPath) {
      setError("Please configure Hytale installation path first.");
      return;
    }
    try {
      const selected = await open({
        filters: [{ name: 'GShade Preset', extensions: ['ini'] }],
        multiple: false,
        title: 'Import GShade Preset'
      });
      if (selected && typeof selected === 'string') {
        const filename = selected.split(/[/\\]/).pop() || 'preset.ini';
        const presetName = filename.replace('.ini', '');

        const result = await invoke('import_local_preset', {
          sourcePath: selected,
          hytaleDir: installPath,
          presetName
        }) as { success: boolean; error?: string };

        if (result.success) {
          await loadInstalledPresets();
        } else {
          setError(result.error || 'Failed to import preset');
        }
      }
    } catch (e) {
      console.error('Failed to import preset:', e);
      setError(`Failed to import preset: ${e}`);
    }
  };

  const handleExportPreset = async (presetId: string, filename: string) => {
    if (!installPath) return;
    try {
      const destPath = await save({
        filters: [{ name: 'GShade Preset', extensions: ['ini'] }],
        defaultPath: filename,
        title: 'Export GShade Preset'
      });
      if (destPath) {
        const result = await invoke('export_preset', {
          presetId,
          hytaleDir: installPath,
          destPath
        }) as { success: boolean; error?: string };

        if (!result.success) {
          setError(result.error || 'Failed to export preset');
        }
      }
    } catch (e) {
      console.error('Failed to export preset:', e);
      setError(`Failed to export preset: ${e}`);
    }
  };

  const handleToggleFavorite = async (presetId: string) => {
    try {
      const result = await invoke('toggle_favorite', { presetId }) as { success: boolean; error?: string };
      if (result.success) {
        await loadInstalledPresets();
      } else {
        setError(result.error || 'Failed to toggle favorite');
      }
    } catch (e) {
      console.error('Failed to toggle favorite:', e);
    }
  };

  const loadHotkeys = async () => {
    if (!installPath) return;
    try {
      const result = await invoke('get_gshade_hotkeys', { hytaleDir: installPath }) as { success: boolean; hotkeys?: GShadeHotkeys };
      if (result.success && result.hotkeys) {
        setHotkeys(result.hotkeys);
      }
    } catch (e) {
      console.error('Failed to load hotkeys:', e);
    }
  };

  // ============== Screenshot Handlers ==============

  const loadScreenshots = async () => {
    if (!installPath) return;
    setScreenshotsLoading(true);
    try {
      const result = await invoke('list_screenshots', { hytalePath: installPath }) as { success: boolean; screenshots: Screenshot[] };
      if (result.success) {
        setScreenshots(result.screenshots);
      }
      // Also load preset names for filtering
      const presetsResult = await invoke('get_screenshot_presets', { hytalePath: installPath }) as { success: boolean; presets: string[] };
      if (presetsResult.success) {
        setScreenshotPresets(presetsResult.presets);
      }
    } catch (e) {
      console.error('Failed to load screenshots:', e);
    } finally {
      setScreenshotsLoading(false);
    }
  };

  const handleToggleScreenshotFavorite = async (screenshotId: string) => {
    try {
      const result = await invoke('toggle_screenshot_favorite', { screenshotId }) as { success: boolean; is_favorite: boolean };
      if (result.success) {
        setScreenshots(prev => prev.map(s =>
          s.id === screenshotId ? { ...s, is_favorite: result.is_favorite } : s
        ));
      }
    } catch (e) {
      console.error('Failed to toggle screenshot favorite:', e);
    }
  };

  const handleOpenScreenshotsFolder = async () => {
    if (!installPath) return;
    try {
      await invoke('open_screenshots_folder', { hytalePath: installPath });
    } catch (e) {
      console.error('Failed to open screenshots folder:', e);
    }
  };

  const handleRevealScreenshot = async (screenshotPath: string) => {
    if (!installPath) return;
    try {
      await invoke('reveal_screenshot_in_folder', { screenshotPath, hytalePath: installPath });
    } catch (e) {
      console.error('Failed to reveal screenshot:', e);
    }
  };

  const handleDeleteScreenshot = async (screenshot: Screenshot) => {
    if (!installPath) return;
    if (!confirm(`Delete "${screenshot.filename}"? This cannot be undone.`)) return;
    try {
      const result = await invoke('delete_screenshot', { screenshotPath: screenshot.path, hytalePath: installPath }) as { success: boolean; error?: string };
      if (result.success) {
        setScreenshots(prev => prev.filter(s => s.id !== screenshot.id));
        if (fullscreenScreenshot?.id === screenshot.id) {
          setFullscreenScreenshot(null);
        }
      } else {
        setError(result.error || 'Failed to delete screenshot');
      }
    } catch (e) {
      console.error('Failed to delete screenshot:', e);
    }
  };

  const handleCopyScreenshotToClipboard = async (screenshot: Screenshot) => {
    try {
      // Read the image file and copy to clipboard using the Clipboard API
      const response = await fetch(convertFileSrc(screenshot.path));
      const blob = await response.blob();
      await navigator.clipboard.write([
        new ClipboardItem({ [blob.type]: blob })
      ]);
      // Show a brief success message (could use a toast here)
      console.log('Screenshot copied to clipboard');
    } catch (e) {
      console.error('Failed to copy screenshot to clipboard:', e);
      setError('Failed to copy screenshot to clipboard');
    }
  };

  const handleInstallRuntime = async () => {
    if (!validationResult?.is_valid) {
      setError("Please select a valid installation directory.");
      return;
    }
    setIsInstalling(true);
    setError(null);
    setInstallLogs([]);
    setInstallProgress(0);

    try {
      setInstallLogs(prev => [...prev, "> Initializing OrbisFX Runtime..."]);
      setInstallProgress(20);
      await new Promise(r => setTimeout(r, 300));

      const result = await invoke('install_gshade', { hytaleDir: installPath, presetName: null }) as { success: boolean; message: string };

      if (result.success) {
        setInstallLogs(prev => [...prev, "> Runtime files installed successfully..."]);
        setInstallProgress(100);
        await validateInstallationPath(installPath);
      } else {
        setError("Installation failed: " + result.message);
      }
    } catch (e) {
      setError("Installation failed: " + e);
    }
    setIsInstalling(false);
  };

  const handleUninstallRuntime = async () => {
    if (!installPath) return;
    setIsInstalling(true);
    try {
      await invoke('uninstall_gshade', { hytaleDir: installPath });
      await validateInstallationPath(installPath);
    } catch (e) {
      setError(`Failed to uninstall: ${e}`);
    }
    setIsInstalling(false);
  };

  const checkForUpdates = async () => {
    try {
      const result = await invoke('check_for_updates') as {
        success: boolean;
        update_available?: boolean;
        latest_version?: string;
        download_url?: string;
      };
      if (result.success) {
        setUpdateAvailable(result.update_available || false);
        setLatestVersion(result.latest_version || null);
        setUpdateDownloadUrl(result.download_url || null);
        // Show update modal if update is available
        if (result.update_available) {
          setShowUpdateModal(true);
        }
      }
    } catch (e) {
      console.error('Failed to check for updates:', e);
    }
  };

  const [downloadedUpdatePath, setDownloadedUpdatePath] = useState<string | null>(null);
  const [isInstallingUpdate, setIsInstallingUpdate] = useState(false);

  const handleDownloadUpdate = async () => {
    if (!updateDownloadUrl) return;
    setIsDownloadingUpdate(true);
    try {
      const result = await invoke('download_update', { downloadUrl: updateDownloadUrl }) as {
        success: boolean;
        path?: string;
        error?: string
      };
      if (result.success && result.path) {
        setDownloadedUpdatePath(result.path);
        setError(null);
      } else {
        setError(result.error || 'Failed to download update');
      }
    } catch (e) {
      console.error('Failed to download update:', e);
      setError(`Failed to download update: ${e}`);
    }
    setIsDownloadingUpdate(false);
  };

  const handleInstallUpdateAndRestart = async () => {
    if (!downloadedUpdatePath) return;
    setIsInstallingUpdate(true);
    try {
      const result = await invoke('install_update_and_restart', { updatePath: downloadedUpdatePath }) as {
        success: boolean;
        error?: string
      };
      if (!result.success) {
        setError(result.error || 'Failed to install update');
        setIsInstallingUpdate(false);
      }
      // If successful, the app will close automatically
    } catch (e) {
      console.error('Failed to install update:', e);
      setError(`Failed to install update: ${e}`);
      setIsInstallingUpdate(false);
    }
  };

  const handleCloseUpdateModal = () => {
    setShowUpdateModal(false);
    setDownloadedUpdatePath(null);
  };

  // Tutorial handlers
  const handleTutorialNext = () => {
    if (tutorialStep < TUTORIAL_STEPS.length - 1) {
      const nextStep = TUTORIAL_STEPS[tutorialStep + 1];
      // Navigate to the appropriate page if specified
      if (nextStep.navigateTo) {
        setCurrentPage(nextStep.navigateTo);
      }
      setTutorialStep(tutorialStep + 1);
    } else {
      handleTutorialComplete();
    }
  };

  const handleTutorialBack = () => {
    if (tutorialStep > 0) {
      const prevStep = TUTORIAL_STEPS[tutorialStep - 1];
      // Navigate to the appropriate page if specified
      if (prevStep.navigateTo) {
        setCurrentPage(prevStep.navigateTo);
      }
      setTutorialStep(tutorialStep - 1);
    }
  };

  const handleTutorialSkip = async () => {
    await handleTutorialComplete();
  };

  const handleTutorialComplete = async () => {
    setShowTutorial(false);
    setTutorialStep(0);
    setCurrentPage('home'); // Return to home after tutorial
    await saveSettings({ ...settings, tutorial_completed: true });
  };

  const handleReplayTutorial = () => {
    setShowTutorial(true);
    setTutorialStep(0);
    // Start on home page for the tutorial
    setCurrentPage('home');
  };

  // Load presets when navigating to presets page
  useEffect(() => {
    if (currentPage === 'presets') {
      fetchPresets();
      loadInstalledPresets();
      loadRatings();
    }
    if (currentPage === 'settings') {
      loadHotkeys();
    }
    if (currentPage === 'gallery') {
      loadScreenshots();
    }
  }, [currentPage]);

  // Load community presets when switching to community tab
  useEffect(() => {
    if (currentPage === 'presets' && presetTab === 'community' && communityPresets.length === 0) {
      loadCommunityPresets();
    }
  }, [presetTab, currentPage]);

  // Load trending presets and ratings when on home page
  useEffect(() => {
    if (currentPage === 'home') {
      if (trendingPresets.length === 0) {
        loadTrendingPresets();
      }
      // Also load ratings for the home page
      loadRatings();
    }
  }, [currentPage]);

  // Filter and sort presets
  const filteredPresets = presets
    .filter(p => {
      const matchesCategory = selectedCategory === 'all' || p.category === selectedCategory;
      const matchesSearch = p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                           p.author.toLowerCase().includes(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    })
    .sort((a, b) => {
      const ratingA = presetRatings[a.id];
      const ratingB = presetRatings[b.id];

      switch (presetSort) {
        case 'rating-desc':
          return (ratingB?.average_rating ?? 0) - (ratingA?.average_rating ?? 0);
        case 'rating-asc':
          return (ratingA?.average_rating ?? 0) - (ratingB?.average_rating ?? 0);
        case 'most-rated':
          return (ratingB?.total_ratings ?? 0) - (ratingA?.total_ratings ?? 0);
        case 'name-desc':
          return b.name.localeCompare(a.name);
        case 'category':
          return a.category.localeCompare(b.category) || a.name.localeCompare(b.name);
        case 'name-asc':
        default:
          return a.name.localeCompare(b.name);
      }
    });

  const categories = ['all', ...new Set(presets.map(p => p.category))];

  // Filter and sort community presets (client-side like official presets)
  const communityCategories = ['all', ...new Set(communityPresets.map(p => p.category))];
  const filteredCommunityPresets = communityPresets
    .filter(p => {
      const matchesCategory = communityCategory === 'all' || p.category === communityCategory;
      const matchesSearch = communitySearch === '' ||
        p.name.toLowerCase().includes(communitySearch.toLowerCase()) ||
        p.author_name.toLowerCase().includes(communitySearch.toLowerCase()) ||
        p.description.toLowerCase().includes(communitySearch.toLowerCase());
      return matchesCategory && matchesSearch;
    })
    .sort((a, b) => {
      switch (communitySort) {
        case 'name-desc':
          return b.name.localeCompare(a.name);
        case 'category':
          return a.category.localeCompare(b.category) || a.name.localeCompare(b.name);
        case 'name-asc':
        default:
          return a.name.localeCompare(b.name);
      }
    });

  // Filter and sort screenshots
  const filteredScreenshots = screenshots
    .filter(s => {
      const matchesFavorite = screenshotFilter === 'all' || s.is_favorite;
      const matchesPreset = screenshotPresetFilter === 'all' || s.preset_name === screenshotPresetFilter;
      const matchesSearch = screenshotSearchQuery === '' ||
        s.filename.toLowerCase().includes(screenshotSearchQuery.toLowerCase()) ||
        (s.preset_name?.toLowerCase().includes(screenshotSearchQuery.toLowerCase()) ?? false);
      return matchesFavorite && matchesPreset && matchesSearch;
    })
    .sort((a, b) => {
      switch (screenshotSort) {
        case 'date-desc':
          return parseInt(b.timestamp) - parseInt(a.timestamp);
        case 'date-asc':
          return parseInt(a.timestamp) - parseInt(b.timestamp);
        case 'name-asc':
          return a.filename.localeCompare(b.filename);
        case 'name-desc':
          return b.filename.localeCompare(a.filename);
        case 'size-desc':
          return b.file_size - a.file_size;
        case 'size-asc':
          return a.file_size - b.file_size;
        case 'preset-asc':
          return (a.preset_name || '').localeCompare(b.preset_name || '');
        case 'preset-desc':
          return (b.preset_name || '').localeCompare(a.preset_name || '');
        case 'favorites':
          // Favorites first, then by date desc
          if (a.is_favorite === b.is_favorite) {
            return parseInt(b.timestamp) - parseInt(a.timestamp);
          }
          return a.is_favorite ? -1 : 1;
        default:
          return 0;
      }
    });

  // Check if runtime is installed and enabled for play button
  const canLaunchGame = validationStatus === 'success' && validationResult?.gshade_installed && validationResult?.gshade_enabled;

  // ============== Render Home Page ==============
  const renderHomePage = () => (
    <div className="flex-1 p-6 lg:p-8 overflow-y-auto">
      {/* Film grain overlay */}
      <div className="grain-overlay"></div>

      <div className="max-w-4xl mx-auto space-y-5">
        {/* Simplified Header - no duplicate launch buttons */}
        <header className="mb-2">
          <h1 className="font-hytale font-black text-2xl text-[var(--hytale-text-primary)] uppercase tracking-wide">Home</h1>
          <p className="text-[var(--hytale-text-dim)] text-sm font-body mt-1">
            {validationStatus === 'success'
              ? 'Your Hytale graphics enhancement is ready to go'
              : 'Configure your Hytale installation to get started'
            }
          </p>
        </header>

        {/* Setup Required Alert - only show when not configured */}
        {validationStatus !== 'success' && (
          <div className="bg-[var(--hytale-warning)]/10 border border-[var(--hytale-warning)]/30 rounded-lg p-4 flex items-center gap-4">
            <AlertTriangle size={20} className="text-[var(--hytale-warning)] flex-shrink-0" />
            <div className="flex-1">
              <p className="text-[var(--hytale-text-primary)] text-sm font-medium">Setup Required</p>
              <p className="text-[var(--hytale-text-dim)] text-xs mt-0.5">Configure your Hytale installation path in Settings to get started.</p>
            </div>
            <button
              onClick={() => setCurrentPage('settings')}
              className="px-4 py-2 bg-[var(--hytale-accent-blue)] text-[var(--hytale-text-primary)] text-sm rounded-md flex items-center gap-2 hover:bg-[var(--hytale-accent-blue-hover)] transition-colors"
            >
              <Settings size={14} /> Configure
            </button>
          </div>
        )}

        {/* Runtime Not Installed Alert - only show when game is configured but runtime missing */}
        {validationStatus === 'success' && !validationResult?.gshade_installed && (
          <div className="bg-[var(--hytale-accent-blue)]/10 border border-[var(--hytale-accent-blue)]/30 rounded-lg p-4 flex items-center gap-4">
            <Download size={20} className="text-[var(--hytale-accent-blue)] flex-shrink-0" />
            <div className="flex-1">
              <p className="text-[var(--hytale-text-primary)] text-sm font-medium">Install OrbisFX Runtime</p>
              <p className="text-[var(--hytale-text-dim)] text-xs mt-0.5">Install the graphics runtime to enable preset effects.</p>
            </div>
            <button
              onClick={handleInstallRuntime}
              disabled={isInstalling}
              className="px-4 py-2 bg-[var(--hytale-accent-blue)] text-[var(--hytale-text-primary)] text-sm rounded-md flex items-center gap-2 hover:bg-[var(--hytale-accent-blue-hover)] transition-colors disabled:opacity-50"
            >
              <Download size={14} /> Install
            </button>
          </div>
        )}

        {/* Update Available Alert - more prominent */}
        {updateAvailable && (
          <div
            className="bg-[var(--hytale-warning)]/10 border border-[var(--hytale-warning)]/30 rounded-lg p-4 flex items-center gap-4 cursor-pointer hover:bg-[var(--hytale-warning)]/15 transition-colors"
            onClick={() => setShowUpdateModal(true)}
          >
            <RefreshCw size={20} className="text-[var(--hytale-warning)] flex-shrink-0" />
            <div className="flex-1">
              <p className="text-[var(--hytale-text-primary)] text-sm font-medium">Update Available</p>
              <p className="text-[var(--hytale-text-dim)] text-xs mt-0.5">Version {latestVersion} is available. Click to update.</p>
            </div>
            <ChevronRight size={16} className="text-[var(--hytale-warning)]" />
          </div>
        )}

        {/* Trending Presets Section */}
        {trendingPresets.length > 0 && (
          <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-5">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <TrendingUp size={18} className="text-[var(--hytale-accent-blue)]" />
                <h2 className="text-[var(--hytale-text-primary)] text-sm font-medium">Trending Presets</h2>
              </div>
              <button
                onClick={() => { setPresetTab('community'); setCurrentPage('presets'); }}
                className="text-[var(--hytale-accent-blue)] text-xs hover:underline flex items-center gap-1"
              >
                View all <ChevronRight size={12} />
              </button>
            </div>
            {trendingLoading ? (
              <div className="flex items-center justify-center py-8">
                <Loader2 size={24} className="animate-spin text-[var(--hytale-accent-blue)]" />
              </div>
            ) : (
              <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                {trendingPresets.slice(0, 6).map(preset => (
                  <div
                    key={preset.id}
                    className="bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-lg overflow-hidden hover:border-[var(--hytale-accent-blue)] transition-colors cursor-pointer group"
                    onClick={() => {
                      setSelectedCommunityPreset(preset);
                      setCommunityImageIndex(0);
                      setCommunityShowComparison(false);
                    }}
                  >
                    <div className="aspect-video relative overflow-hidden">
                      {(() => {
                        // Use thumbnail_url, or first image's full_image_url, or fallback to placeholder
                        const imageUrl = preset.thumbnail_url || preset.images?.[0]?.full_image_url;
                        return imageUrl ? (
                          <img
                            src={imageUrl}
                            alt={preset.name}
                            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                          />
                        ) : (
                          <div className="w-full h-full bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
                            <Palette size={24} className="text-[var(--hytale-text-dimmer)]" />
                          </div>
                        );
                      })()}
                    </div>
                    <div className="p-2">
                      <p className="text-[var(--hytale-text-primary)] text-xs font-medium truncate">{preset.name}</p>
                      <div className="mt-1">
                        <StarRating
                          rating={myRatings[preset.id] ?? null}
                          averageRating={presetRatings[preset.id]?.average_rating}
                          totalRatings={presetRatings[preset.id]?.total_ratings ?? 0}
                          size={10}
                          compact={true}
                        />
                      </div>
                      <div className="flex items-center justify-between mt-1">
                        <span className="text-[var(--hytale-text-dimmer)] text-[10px]">
                          by{' '}
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              setViewingProfileId(preset.author_discord_id);
                              setCurrentPage('profile');
                            }}
                            className="text-[var(--hytale-accent-blue)] hover:underline"
                          >
                            {preset.author_name}
                          </button>
                        </span>
                        <span className="text-[var(--hytale-text-dimmer)] text-[10px] flex items-center gap-0.5">
                          <Download size={10} /> {preset.download_count}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* Installation Progress - Hytale Style */}
        {isInstalling && (
          <div className="card-hyfx active p-6">
            <div className="flex justify-between items-center mb-4">
              <div className="flex items-center gap-3">
                <Activity size={20} className="text-[var(--hytale-accent-blue)] animate-spin" />
                <span className="text-[var(--hytale-text-primary)] font-hytale font-bold text-sm uppercase tracking-wider">Installing OrbisFX</span>
              </div>
              <span className="text-[var(--hytale-accent-blue)] font-mono text-sm font-bold">{installProgress}%</span>
            </div>
            <ProgressBar progress={installProgress} />
            <div className="mt-4">
              <TerminalLog logs={installLogs} />
            </div>
          </div>
        )}

        {/* Error Display - Hytale Style */}
        {error && (
          <div className="bg-[var(--hytale-error)]/20 border-2 border-[var(--hytale-error)]/30 text-[var(--hytale-error)] px-5 py-4 rounded-md flex items-start gap-4 animate-fade-in">
            <AlertTriangle size={20} className="flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="font-hytale font-medium uppercase tracking-wide">Error</p>
              <p className="text-sm text-[var(--hytale-error)]/80 mt-1 font-body">{error}</p>
            </div>
            <button onClick={() => setError(null)} className="hover:text-[var(--hytale-text-primary)] transition-colors p-1">
              <X size={18} />
            </button>
          </div>
        )}
      </div>
    </div>
  );

  // ============== Render Presets Page ==============
  const renderPresetsPage = () => (
    <div className="flex-1 p-6 lg:p-8 overflow-y-auto">
      {/* Film grain overlay */}
      <div className="grain-overlay"></div>

      <div className="max-w-5xl mx-auto space-y-4">
        {/* Page Header with Submit Button */}
        <header className="flex items-start justify-between">
          <div>
            <h1 className="font-hytale font-black text-2xl text-[var(--hytale-text-primary)] uppercase tracking-wide">Presets</h1>
            <p className="text-[var(--hytale-text-dim)] text-sm font-body mt-1">Manage your installed presets and discover new ones</p>
          </div>
          {/* Submit Preset Button - Top Right */}
          <button
            onClick={() => setShowSubmissionWizard(true)}
            disabled={installedPresets.filter(p => p.is_local).length === 0}
            className="px-4 py-2 bg-[var(--hytale-accent-blue)] text-white rounded-lg text-sm font-medium flex items-center gap-2 hover:bg-[var(--hytale-accent-blue-hover)] transition-all disabled:opacity-40 disabled:cursor-not-allowed shrink-0"
            title={installedPresets.filter(p => p.is_local).length === 0 ? 'Import a local preset first to submit it' : 'Submit your preset to the community'}
          >
            <Upload size={14} />
            Submit Preset
          </button>
        </header>

        {/* Tab Switcher - Compact */}
        <div className="flex gap-1 bg-[var(--hytale-bg-input)] p-1 rounded-lg">
          <button
            onClick={() => setPresetTab('library')}
            className={`flex-1 py-2.5 px-4 rounded-lg text-sm font-medium flex items-center justify-center gap-2 transition-all ${
              presetTab === 'library'
                ? 'bg-[var(--hytale-bg-card)] text-[var(--hytale-text-primary)] shadow-sm'
                : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-elevated)]'
            }`}
          >
            <CheckCircle size={15} />
            My Library
            {installedPresets.length > 0 && (
              <span className="px-1.5 py-0.5 text-[10px] font-medium bg-[var(--hytale-accent-blue)]/20 text-[var(--hytale-accent-blue)] rounded">{installedPresets.length}</span>
            )}
          </button>
          <button
            onClick={() => setPresetTab('public')}
            className={`flex-1 py-2.5 px-4 rounded-lg text-sm font-medium flex items-center justify-center gap-2 transition-all ${
              presetTab === 'public'
                ? 'bg-[var(--hytale-bg-card)] text-[var(--hytale-text-primary)] shadow-sm'
                : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-elevated)]'
            }`}
          >
            <Sparkles size={15} />
            Official
            {presets.length > 0 && (
              <span className="px-1.5 py-0.5 text-[10px] font-medium bg-[var(--hytale-accent-blue)]/20 text-[var(--hytale-accent-blue)] rounded">{presets.length}</span>
            )}
          </button>
          <button
            onClick={() => setPresetTab('community')}
            className={`flex-1 py-2.5 px-4 rounded-lg text-sm font-medium flex items-center justify-center gap-2 transition-all ${
              presetTab === 'community'
                ? 'bg-[var(--hytale-bg-card)] text-[var(--hytale-text-primary)] shadow-sm'
                : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-elevated)]'
            }`}
          >
            <MessageCircle size={15} />
            Community
          </button>
        </div>

        {/* My Library Tab Content */}
        {presetTab === 'library' && (
          <>
            {/* Toolbar Section - Matches Official/Community Style */}
            <div className="space-y-2">
              <div className="flex flex-wrap gap-3 items-center">
                {/* Search input */}
                <div className="flex-1 min-w-[200px] bg-[var(--hytale-bg-elevated)] rounded-lg flex items-center px-3 transition-colors">
                  <Search size={18} className="text-[var(--hytale-text-dimmer)] shrink-0" />
                  <input
                    type="text"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    placeholder="Search your presets..."
                    className="bg-transparent w-full py-2.5 px-3 text-[var(--hytale-text-primary)] outline-none placeholder-[var(--hytale-text-faint)] text-sm"
                  />
                  {searchQuery && (
                    <button
                      onClick={() => setSearchQuery('')}
                      className="p-1.5 text-[var(--hytale-text-dimmer)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-hover)] rounded-md transition-colors"
                    >
                      <X size={14} />
                    </button>
                  )}
                </div>

                {/* Filter pills - Local/Official */}
                <div className="flex gap-1 bg-[var(--hytale-bg-elevated)] rounded-lg p-1">
                  {(['all', 'official', 'community', 'local'] as const).map(filter => (
                    <button
                      key={filter}
                      onClick={() => setLibraryFilter(filter)}
                      className={`px-3 py-1.5 rounded-md text-xs font-medium capitalize transition-colors whitespace-nowrap ${
                        libraryFilter === filter
                          ? 'bg-[var(--hytale-bg-input)] text-[var(--hytale-text-primary)] shadow-sm'
                          : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)]'
                      }`}
                    >
                      {filter}
                    </button>
                  ))}
                </div>

                {/* Import Button */}
                <button
                  onClick={handleImportPreset}
                  disabled={!installPath}
                  className="px-4 py-2.5 bg-[var(--hytale-accent-blue)]/10 rounded-lg text-[var(--hytale-accent-blue)] text-sm font-medium flex items-center gap-2 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-[var(--hytale-accent-blue)]/20 transition-all shrink-0"
                >
                  <Upload size={15} /> Import
                </button>
              </div>

              {/* Results count */}
              <div className="text-xs text-[var(--hytale-text-dimmer)]">
                {(() => {
                  const count = installedPresets.filter(p => {
                    const matchesSearch = p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                      p.filename.toLowerCase().includes(searchQuery.toLowerCase());
                    const source = p.source || (p.is_local ? 'local' : 'official');
                    const matchesFilter = libraryFilter === 'all' ||
                      (libraryFilter === 'local' && source === 'local') ||
                      (libraryFilter === 'official' && source === 'official') ||
                      (libraryFilter === 'community' && source === 'community');
                    return matchesSearch && matchesFilter;
                  }).length;
                  return count === installedPresets.length
                    ? `${count} preset${count !== 1 ? 's' : ''} installed`
                    : `Showing ${count} of ${installedPresets.length} presets`;
                })()}
              </div>
            </div>

            {/* Installed Presets Grid */}
            {(() => {
              // Filter installed presets by search query and category
              const filteredInstalled = installedPresets.filter(p => {
                const matchesSearch = p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                  p.filename.toLowerCase().includes(searchQuery.toLowerCase());
                const source = p.source || (p.is_local ? 'local' : 'official');
                const matchesFilter = libraryFilter === 'all' ||
                  (libraryFilter === 'local' && source === 'local') ||
                  (libraryFilter === 'official' && source === 'official') ||
                  (libraryFilter === 'community' && source === 'community');
                return matchesSearch && matchesFilter;
              });

              if (filteredInstalled.length === 0 && installedPresets.length === 0) {
                return (
                  <div className="bg-[var(--hytale-bg-card)]/50 rounded-lg p-12 text-center">
                    <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
                      <Upload size={28} className="text-[var(--hytale-text-dimmer)]" />
                    </div>
                    <h3 className="font-hytale font-bold text-[var(--hytale-text-primary)] text-lg mb-2">
                      No Presets Installed Yet
                    </h3>
                    <p className="text-[var(--hytale-text-muted)] text-sm max-w-md mx-auto mb-6">
                      Browse official presets or import your own custom preset files
                    </p>
                    <button
                      onClick={() => setPresetTab('public')}
                      className="px-6 py-2.5 bg-[var(--hytale-accent-blue)] text-[var(--hytale-text-primary)] text-sm font-medium rounded-lg hover:bg-[var(--hytale-accent-blue-hover)] transition-colors"
                    >
                      Browse Official Presets
                    </button>
                  </div>
                );
              }

              if (filteredInstalled.length === 0) {
                return (
                  <div className="bg-[var(--hytale-bg-card)]/50 rounded-lg p-16 text-center">
                    <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
                      <Search size={28} className="text-[var(--hytale-text-dimmer)]" />
                    </div>
                    <p className="text-[var(--hytale-text-primary)] font-medium mb-1">No presets found</p>
                    <p className="text-[var(--hytale-text-dimmer)] text-sm">Try adjusting your search or filters</p>
                  </div>
                );
              }

              const sortedPresets = [...filteredInstalled].sort((a, b) => {
                if (a.is_favorite && !b.is_favorite) return -1;
                if (!a.is_favorite && b.is_favorite) return 1;
                return a.name.localeCompare(b.name);
              });

              return (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {sortedPresets.map((preset, index) => {
                    // Find matching official preset for thumbnail and version check
                    const matchingPreset = presets.find(p => p.id === preset.id);
                    const matchingCommunityPreset = communityPresets.find(p => p.id === preset.id);
                    const thumbnailUrl = matchingPreset?.thumbnail || matchingCommunityPreset?.thumbnail_url;

                    // Determine source type (use new field or fall back to is_local)
                    const sourceType = preset.source || (preset.is_local ? 'local' : (matchingCommunityPreset ? 'community' : 'official'));
                    const sourceLabel = sourceType === 'local' ? 'Local' : sourceType === 'community' ? 'Community' : 'Official';

                    // Check for updates
                    const latestVersion = matchingPreset?.version || matchingCommunityPreset?.version;
                    const hasUpdate = latestVersion && isNewerVersion(preset.version, latestVersion);

                    return (
                      <div
                        key={preset.id}
                        className={`group bg-[var(--hytale-bg-card)] border rounded-lg overflow-hidden cursor-pointer transition-all duration-200 hover:-translate-y-0.5 hover:shadow-lg animate-fade-in-up ${
                          preset.is_active
                            ? 'border-[var(--hytale-success)]/40 hover:border-[var(--hytale-success)]/60'
                            : hasUpdate
                              ? 'border-[var(--hytale-accent-blue)]/40 hover:border-[var(--hytale-accent-blue)]/60'
                              : 'border-[var(--hytale-border-card)] hover:border-[var(--hytale-border-hover)]'
                        }`}
                        style={{ animationDelay: `${Math.min(index * 0.04, 0.25)}s` }}
                        onClick={() => !preset.is_active && handleActivatePreset(preset.id)}
                      >
                        {/* Thumbnail - matching Official/Community style */}
                        <div className="h-40 bg-[var(--hytale-bg-input)] relative overflow-hidden">
                          {thumbnailUrl ? (
                            <CachedImage
                              src={thumbnailUrl}
                              alt={preset.name}
                              className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                            />
                          ) : (
                            <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-[var(--hytale-bg-elevated)] to-[var(--hytale-bg-input)]">
                              <Palette size={36} className="text-[var(--hytale-border-hover)]" />
                            </div>
                          )}

                          {/* Gradient overlay for text readability */}
                          <div className="absolute inset-0 bg-gradient-to-t from-black/40 via-transparent to-transparent"></div>

                          {/* Source badge - top left */}
                          <div className="absolute top-3 left-3 px-2.5 py-1 rounded-md bg-black/50 backdrop-blur-sm text-white text-xs font-medium">
                            {sourceLabel}
                          </div>

                          {/* Status badges - top right */}
                          <div className="absolute top-3 right-3 flex gap-1.5">
                            {hasUpdate && (
                              <div className="px-2.5 py-1 rounded-md bg-[var(--hytale-accent-blue)] text-white text-xs font-medium flex items-center gap-1.5 shadow-lg">
                                <RefreshCw size={12} /> Update
                              </div>
                            )}
                            {preset.is_active && (
                              <div className="px-2.5 py-1 rounded-md bg-[var(--hytale-success)] text-white text-xs font-medium flex items-center gap-1.5 shadow-lg">
                                <CheckCircle size={12} /> Active
                              </div>
                            )}
                          </div>

                          {/* Favorite button - bottom right */}
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleToggleFavorite(preset.id);
                            }}
                            className={`absolute bottom-3 right-3 p-2 rounded-md backdrop-blur-sm transition-all ${
                              preset.is_favorite
                                ? 'bg-[var(--hytale-favorite)]/80 text-white'
                                : 'bg-black/50 text-white/70 hover:text-white hover:bg-black/60'
                            }`}
                          >
                            <Star size={14} fill={preset.is_favorite ? 'currentColor' : 'none'} />
                          </button>
                        </div>

                        {/* Info - matching Official/Community style */}
                        <div className="p-5">
                          <div className="flex justify-between items-start mb-3">
                            <div className="flex-1 min-w-0">
                              <h3 className="font-semibold text-[var(--hytale-text-primary)] text-base truncate">{preset.name}</h3>
                              <p className="text-[var(--hytale-text-dimmer)] text-xs mt-1 truncate">{preset.filename}</p>
                            </div>
                            <div className="flex items-center gap-1.5 ml-3">
                              <span className={`px-2 py-0.5 text-xs rounded-md ${
                                hasUpdate
                                  ? 'bg-[var(--hytale-text-dimmer)]/10 text-[var(--hytale-text-dimmer)] line-through'
                                  : 'bg-[var(--hytale-accent-blue)]/10 text-[var(--hytale-accent-blue)]'
                              }`}>v{preset.version}</span>
                              {hasUpdate && latestVersion && (
                                <span className="px-2 py-0.5 bg-[var(--hytale-accent-blue)]/10 text-[var(--hytale-accent-blue)] text-xs rounded-md">
                                  v{latestVersion}
                                </span>
                              )}
                            </div>
                          </div>

                          {/* Action buttons */}
                          <div className="flex items-center gap-2">
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                handleExportPreset(preset.id, preset.filename);
                              }}
                              className="px-3 py-2 text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-elevated)] text-xs rounded-lg flex items-center gap-1.5 transition-all"
                            >
                              <Download size={12} /> Export
                            </button>
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                handleDeletePreset(preset.id);
                              }}
                              className="px-3 py-2 text-[var(--hytale-text-dimmer)] hover:text-[var(--hytale-error)] hover:bg-[var(--hytale-error)]/10 text-xs rounded-lg flex items-center gap-1.5 transition-all"
                            >
                              <Trash2 size={12} /> Remove
                            </button>
                            <div className="flex-1"></div>
                            {hasUpdate && matchingPreset && (
                              <button
                                onClick={(e) => {
                                  e.stopPropagation();
                                  handleDownloadPreset(matchingPreset);
                                }}
                                className="px-4 py-2 bg-[var(--hytale-accent-blue)] text-[var(--hytale-text-primary)] text-xs font-medium rounded-lg flex items-center gap-1.5 hover:bg-[var(--hytale-accent-blue-hover)] transition-colors"
                              >
                                <RefreshCw size={12} /> Update
                              </button>
                            )}
                            {hasUpdate && matchingCommunityPreset && (
                              <button
                                onClick={async (e) => {
                                  e.stopPropagation();
                                  if (!installPath) return;
                                  try {
                                    const sanitizedName = matchingCommunityPreset.name
                                      .toLowerCase()
                                      .replace(/[^a-z0-9]+/g, '-')
                                      .replace(/^-|-$/g, '');
                                    const destinationPath = `${installPath}\\reshade-presets\\${sanitizedName}.ini`;
                                    await invoke('download_community_preset', {
                                      presetId: matchingCommunityPreset.id,
                                      presetUrl: matchingCommunityPreset.preset_file_url,
                                      destinationPath: destinationPath,
                                      presetName: matchingCommunityPreset.name,
                                      presetVersion: matchingCommunityPreset.version
                                    });
                                    await loadInstalledPresets();
                                  } catch (err) {
                                    console.error('Failed to update preset:', err);
                                    setError(`Failed to update preset: ${err}`);
                                  }
                                }}
                                className="px-4 py-2 bg-[var(--hytale-accent-blue)] text-[var(--hytale-text-primary)] text-xs font-medium rounded-lg flex items-center gap-1.5 hover:bg-[var(--hytale-accent-blue-hover)] transition-colors"
                              >
                                <RefreshCw size={12} /> Update
                              </button>
                            )}
                            {!hasUpdate && !preset.is_active ? (
                              <button
                                onClick={(e) => {
                                  e.stopPropagation();
                                  handleActivatePreset(preset.id);
                                }}
                                className="px-4 py-2 bg-[var(--hytale-accent-blue)] text-[var(--hytale-text-primary)] text-xs font-medium rounded-lg flex items-center gap-1.5 hover:bg-[var(--hytale-accent-blue-hover)] transition-colors"
                              >
                                <Play size={12} /> Activate
                              </button>
                            ) : !hasUpdate && preset.is_active ? (
                              <span className="px-4 py-2 bg-[var(--hytale-success)]/10 text-[var(--hytale-success)] text-xs font-medium rounded-lg flex items-center gap-1.5">
                                <CheckCircle size={12} /> Active
                              </span>
                            ) : null}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              );
            })()}
          </>
        )}

        {/* Official Presets Tab Content */}
        {presetTab === 'public' && (
          <>
            {/* Toolbar Section - Single row layout */}
            <div className="space-y-2">
              <div className="flex flex-wrap gap-3 items-center">
                {/* Search input */}
                <div className="flex-1 min-w-[200px] bg-[var(--hytale-bg-elevated)] rounded-lg flex items-center px-3 transition-colors">
                  <Search size={18} className="text-[var(--hytale-text-dimmer)] shrink-0" />
                  <input
                    type="text"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    placeholder="Search official presets..."
                    className="bg-transparent w-full py-2.5 px-3 text-[var(--hytale-text-primary)] outline-none placeholder-[var(--hytale-text-faint)] text-sm"
                  />
                  {searchQuery && (
                    <button
                      onClick={() => setSearchQuery('')}
                      className="p-1.5 text-[var(--hytale-text-dimmer)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-hover)] rounded-md transition-colors"
                    >
                      <X size={14} />
                    </button>
                  )}
                </div>

                {/* Category pills */}
                <div className="flex gap-1 bg-[var(--hytale-bg-elevated)] rounded-lg p-1">
                  {categories.map(cat => (
                    <button
                      key={cat}
                      onClick={() => setSelectedCategory(cat)}
                      className={`px-3 py-1.5 rounded-md text-xs font-medium capitalize transition-colors whitespace-nowrap ${
                        selectedCategory === cat
                          ? 'bg-[var(--hytale-bg-input)] text-[var(--hytale-text-primary)] shadow-sm'
                          : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)]'
                      }`}
                    >
                      {cat}
                    </button>
                  ))}
                </div>

                {/* Sort dropdown */}
                <div className="relative shrink-0">
                  <select
                    value={presetSort}
                    onChange={(e) => setPresetSort(e.target.value as PresetSortOption)}
                    className="appearance-none bg-[var(--hytale-bg-elevated)] rounded-lg pl-9 pr-9 py-2.5 text-[var(--hytale-text-primary)] text-sm focus:outline-none transition-colors cursor-pointer"
                  >
                    <option value="name-asc">Name A-Z</option>
                    <option value="name-desc">Name Z-A</option>
                    <option value="rating-desc">Highest Rated</option>
                    <option value="rating-asc">Lowest Rated</option>
                    <option value="most-rated">Most Rated</option>
                    <option value="category">By Category</option>
                  </select>
                  <ArrowUpDown size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--hytale-text-dimmer)] pointer-events-none" />
                  <ChevronDown size={14} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--hytale-text-dimmer)] pointer-events-none" />
                </div>
              </div>

              {/* Results count */}
              <div className="text-xs text-[var(--hytale-text-dimmer)]">
                {filteredPresets.length === presets.length
                  ? `${filteredPresets.length} preset${filteredPresets.length !== 1 ? 's' : ''} available`
                  : `Showing ${filteredPresets.length} of ${presets.length} presets`
                }
              </div>
            </div>

            {presetsLoading ? (
              <div className="bg-[var(--hytale-bg-card)]/50 rounded-lg p-16 text-center">
                <div className="w-12 h-12 rounded-full border-2 border-[var(--hytale-border-card)]/30 border-t-[var(--hytale-accent-blue)] animate-spin mx-auto"></div>
                <p className="text-[var(--hytale-text-dim)] text-sm mt-5">Loading presets...</p>
              </div>
            ) : filteredPresets.length === 0 ? (
              <div className="bg-[var(--hytale-bg-card)]/50 rounded-lg p-16 text-center">
                <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
                  <Palette size={28} className="text-[var(--hytale-text-dimmer)]" />
                </div>
                <p className="text-[var(--hytale-text-primary)] font-medium mb-1">No presets found</p>
                <p className="text-[var(--hytale-text-dimmer)] text-sm">Try adjusting your search or filters</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {filteredPresets.map((preset, index) => {
                  const isInstalled = installedPresets.some(ip => ip.id === preset.id);
                  const installedVersion = installedPresets.find(ip => ip.id === preset.id)?.version;
                  const hasUpdate = isInstalled && installedVersion && installedVersion !== preset.version;

                  return (
                    <div
                      key={preset.id}
                      className="group bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg overflow-hidden cursor-pointer transition-all duration-200 hover:-translate-y-0.5 hover:shadow-lg hover:border-[var(--hytale-border-hover)] animate-fade-in-up"
                      style={{ animationDelay: `${Math.min(index * 0.04, 0.25)}s` }}
                      onClick={() => {
                        setSelectedPreset(preset);
                        setCurrentImageIndex(0);
                        setShowComparisonView(false);
                      }}
                    >
                      {/* Thumbnail - taller for better visual impact */}
                      <div className="h-40 bg-[var(--hytale-bg-input)] relative overflow-hidden">
                        {preset.thumbnail ? (
                          <CachedImage
                            src={preset.thumbnail}
                            alt={preset.name}
                            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                          />
                        ) : (
                          <div className="w-full h-full flex items-center justify-center">
                            <Palette size={36} className="text-[var(--hytale-border-hover)]" />
                          </div>
                        )}

                        {/* Gradient overlay for text readability */}
                        <div className="absolute inset-0 bg-gradient-to-t from-black/40 via-transparent to-transparent"></div>

                        {/* Category badge - refined */}
                        <div className="absolute top-3 left-3 px-2.5 py-1 rounded-md bg-black/50 backdrop-blur-sm text-white text-xs font-medium">
                          {toTitleCase(preset.category)}
                        </div>

                        {/* Status badges - refined */}
                        {isInstalled && !hasUpdate && (
                          <div className="absolute top-3 right-3 px-2.5 py-1 rounded-md bg-[var(--hytale-success)] text-white text-xs font-medium flex items-center gap-1.5 shadow-lg">
                            <CheckCircle size={12} /> Installed
                          </div>
                        )}
                        {hasUpdate && (
                          <div className="absolute top-3 right-3 px-2.5 py-1 rounded-md bg-[var(--hytale-warning-amber)] text-[var(--hytale-bg-primary)] text-xs font-medium flex items-center gap-1.5 shadow-lg">
                            <RefreshCw size={12} /> Update
                          </div>
                        )}
                      </div>

                      {/* Info - better spacing */}
                      <div className="p-5">
                        <div className="flex justify-between items-start mb-3">
                          <div className="flex-1 min-w-0">
                            <h3 className="font-semibold text-[var(--hytale-text-primary)] text-base truncate">{preset.name}</h3>
                            <p className="text-[var(--hytale-text-dimmer)] text-xs mt-1">by {preset.author}</p>
                          </div>
                          <span className="px-2 py-0.5 bg-[var(--hytale-accent-blue)]/10 text-[var(--hytale-accent-blue)] text-xs rounded-md ml-3">v{preset.version}</span>
                        </div>

                        {/* Rating display */}
                        <div className="mb-3">
                          <StarRating
                            rating={myRatings[preset.id] ?? null}
                            averageRating={presetRatings[preset.id]?.average_rating}
                            totalRatings={presetRatings[preset.id]?.total_ratings ?? 0}
                            size={14}
                            compact={true}
                          />
                        </div>

                        <p className="text-[var(--hytale-text-dim)] text-sm mb-4 line-clamp-2 leading-relaxed">{preset.description}</p>

                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            handleDownloadPreset(preset);
                          }}
                          disabled={!installPath}
                          className={`w-full py-2.5 text-sm font-medium text-[var(--hytale-text-primary)] rounded-lg flex items-center justify-center gap-2 disabled:opacity-50 transition-all ${
                            isInstalled
                              ? 'bg-[var(--hytale-bg-elevated)] hover:bg-[var(--hytale-bg-hover)]'
                              : 'bg-[var(--hytale-accent-blue)] hover:bg-[var(--hytale-accent-blue-hover)]'
                          }`}
                        >
                          <Download size={14} /> {isInstalled ? (hasUpdate ? 'Update Available' : 'Reinstall') : 'Install Preset'}
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </>
        )}

        {/* Community Tab Content */}
        {presetTab === 'community' && (
          <>
            {/* Toolbar Section - Matches Official Presets Style */}
            <div className="space-y-2">
              <div className="flex flex-wrap gap-3 items-center">
                {/* Search input */}
                <div className="flex-1 min-w-[200px] bg-[var(--hytale-bg-elevated)] rounded-lg flex items-center px-3 transition-colors">
                  <Search size={18} className="text-[var(--hytale-text-dimmer)] shrink-0" />
                  <input
                    type="text"
                    value={communitySearch}
                    onChange={(e) => setCommunitySearch(e.target.value)}
                    placeholder="Search community presets..."
                    className="bg-transparent w-full py-2.5 px-3 text-[var(--hytale-text-primary)] outline-none placeholder-[var(--hytale-text-faint)] text-sm"
                  />
                  {communitySearch && (
                    <button
                      onClick={() => setCommunitySearch('')}
                      className="p-1.5 text-[var(--hytale-text-dimmer)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-hover)] rounded-md transition-colors"
                    >
                      <X size={14} />
                    </button>
                  )}
                </div>

                {/* Category pills */}
                <div className="flex gap-1 bg-[var(--hytale-bg-elevated)] rounded-lg p-1">
                  {communityCategories.map(cat => (
                    <button
                      key={cat}
                      onClick={() => setCommunityCategory(cat)}
                      className={`px-3 py-1.5 rounded-md text-xs font-medium capitalize transition-colors whitespace-nowrap ${
                        communityCategory === cat
                          ? 'bg-[var(--hytale-bg-input)] text-[var(--hytale-text-primary)] shadow-sm'
                          : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)]'
                      }`}
                    >
                      {cat}
                    </button>
                  ))}
                </div>

                {/* Sort dropdown */}
                <div className="relative shrink-0">
                  <select
                    value={communitySort}
                    onChange={(e) => setCommunitySort(e.target.value as PresetSortOption)}
                    className="appearance-none bg-[var(--hytale-bg-elevated)] rounded-lg pl-9 pr-9 py-2.5 text-[var(--hytale-text-primary)] text-sm focus:outline-none transition-colors cursor-pointer"
                  >
                    <option value="name-asc">Name A-Z</option>
                    <option value="name-desc">Name Z-A</option>
                    <option value="category">By Category</option>
                  </select>
                  <ArrowUpDown size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--hytale-text-dimmer)] pointer-events-none" />
                  <ChevronDown size={14} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--hytale-text-dimmer)] pointer-events-none" />
                </div>
              </div>

              {/* Results count */}
              <div className="text-xs text-[var(--hytale-text-dimmer)]">
                {filteredCommunityPresets.length === communityPresets.length
                  ? `${filteredCommunityPresets.length} preset${filteredCommunityPresets.length !== 1 ? 's' : ''} available`
                  : `Showing ${filteredCommunityPresets.length} of ${communityPresets.length} presets`
                }
              </div>
            </div>

            {/* Community Presets Grid */}
            {communityLoading ? (
              <div className="bg-[var(--hytale-bg-card)]/50 rounded-lg p-16 text-center">
                <div className="w-12 h-12 rounded-full border-2 border-[var(--hytale-border-card)]/30 border-t-[var(--hytale-accent-blue)] animate-spin mx-auto"></div>
                <p className="text-[var(--hytale-text-dim)] text-sm mt-5">Loading community presets...</p>
              </div>
            ) : filteredCommunityPresets.length === 0 && communityPresets.length === 0 ? (
              <div className="bg-[var(--hytale-bg-card)]/50 rounded-lg p-12 text-center">
                <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
                  <MessageCircle size={28} className="text-[var(--hytale-text-dimmer)]" />
                </div>
                <h3 className="font-hytale font-bold text-[var(--hytale-text-primary)] text-lg mb-2">
                  No Community Presets Yet
                </h3>
                <p className="text-[var(--hytale-text-muted)] text-sm max-w-md mx-auto">
                  Be one of the first to share your creations with the community!
                </p>
              </div>
            ) : filteredCommunityPresets.length === 0 ? (
              <div className="bg-[var(--hytale-bg-card)]/50 rounded-lg p-16 text-center">
                <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
                  <Palette size={28} className="text-[var(--hytale-text-dimmer)]" />
                </div>
                <p className="text-[var(--hytale-text-primary)] font-medium mb-1">No presets found</p>
                <p className="text-[var(--hytale-text-dimmer)] text-sm">Try adjusting your search or filters</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {filteredCommunityPresets.map((preset, index) => (
                  <div
                    key={preset.id}
                    className={`group bg-[var(--hytale-bg-card)] border rounded-lg overflow-hidden cursor-pointer transition-all duration-200 hover:-translate-y-0.5 hover:shadow-lg animate-fade-in-up ${
                      installedPresets.some(ip => ip.id === preset.id)
                        ? 'border-[var(--hytale-success)]/20 hover:border-[var(--hytale-success)]/40'
                        : 'border-[var(--hytale-border-card)] hover:border-[var(--hytale-border-hover)]'
                    }`}
                    style={{ animationDelay: `${Math.min(index * 0.04, 0.25)}s` }}
                    onClick={() => {
                      setSelectedCommunityPreset(preset);
                      setCommunityImageIndex(0);
                      setCommunityShowComparison(false);
                    }}
                  >
                    {/* Thumbnail - same height as Official presets */}
                    <div className="h-40 bg-[var(--hytale-bg-input)] relative overflow-hidden">
                      {(() => {
                        const imageUrl = preset.thumbnail_url || preset.images?.[0]?.full_image_url;
                        return imageUrl ? (
                          <img src={imageUrl} alt={preset.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
                        ) : (
                          <div className="w-full h-full flex items-center justify-center">
                            <Sparkles size={36} className="text-[var(--hytale-text-dimmer)]" />
                          </div>
                        );
                      })()}
                      {/* Gradient overlay */}
                      <div className="absolute inset-0 bg-gradient-to-t from-black/40 via-transparent to-transparent"></div>

                      {/* Category badge - top left like Official */}
                      <div className="absolute top-3 left-3 px-2.5 py-1 rounded-md bg-black/50 backdrop-blur-sm text-white text-xs font-medium">
                        {toTitleCase(preset.category)}
                      </div>

                      {/* Status badges - top right */}
                      {installedPresets.some(ip => ip.id === preset.id) && (
                        <div className="absolute top-3 right-3 px-2.5 py-1 rounded-md bg-[var(--hytale-success)] text-white text-xs font-medium flex items-center gap-1.5 shadow-lg">
                          <CheckCircle size={12} /> Installed
                        </div>
                      )}

                      {/* Moderator delete button */}
                      {isModerator && (
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            setDeleteCommunityPresetId(preset.id);
                            setDeleteCommunityReason('');
                            setDeleteCommunityModalOpen(true);
                          }}
                          className="absolute bottom-3 left-3 p-2 bg-red-600/80 hover:bg-red-600 rounded-md text-white opacity-0 group-hover:opacity-100 transition-opacity"
                          title="Delete preset (Moderator)"
                        >
                          <Trash2 size={14} />
                        </button>
                      )}
                    </div>
                    {/* Info - same structure as Official presets */}
                    <div className="p-5">
                      <div className="flex justify-between items-start mb-3">
                        <div className="flex-1 min-w-0">
                          <h3 className="font-semibold text-[var(--hytale-text-primary)] text-base truncate">{preset.name}</h3>
                          <p className="text-[var(--hytale-text-dimmer)] text-xs mt-1">
                            by{' '}
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                setViewingProfileId(preset.author_discord_id);
                                setCurrentPage('profile');
                              }}
                              className="text-[var(--hytale-accent-blue)] hover:underline font-medium"
                            >
                              {preset.author_name}
                            </button>
                          </p>
                        </div>
                        <span className="px-2 py-0.5 bg-[var(--hytale-accent-blue)]/10 text-[var(--hytale-accent-blue)] text-xs rounded-md ml-3">v{preset.version}</span>
                      </div>

                      {/* Rating display */}
                      <div className="mb-3">
                        <StarRating
                          rating={myRatings[preset.id] ?? null}
                          averageRating={presetRatings[preset.id]?.average_rating}
                          totalRatings={presetRatings[preset.id]?.total_ratings ?? 0}
                          size={14}
                          compact={true}
                        />
                      </div>

                      <p className="text-[var(--hytale-text-dim)] text-sm mb-4 line-clamp-2 leading-relaxed">{preset.description}</p>

                      {/* Install button - matching Official tab */}
                      <button
                        onClick={async (e) => {
                          e.stopPropagation();
                          if (!installPath) return;
                          try {
                            const sanitizedName = preset.name
                              .toLowerCase()
                              .replace(/[^a-z0-9]+/g, '-')
                              .replace(/^-|-$/g, '');
                            const destinationPath = `${installPath}\\reshade-presets\\${sanitizedName}.ini`;
                            await invoke('download_community_preset', {
                              presetId: preset.id,
                              presetUrl: preset.preset_file_url,
                              destinationPath: destinationPath,
                              presetName: preset.name,
                              presetVersion: preset.version
                            });
                            await loadInstalledPresets();
                          } catch (err) {
                            console.error('Failed to install preset:', err);
                            setError(`Failed to install preset: ${err}`);
                          }
                        }}
                        disabled={!installPath}
                        className={`w-full py-2.5 text-sm font-medium text-[var(--hytale-text-primary)] rounded-lg flex items-center justify-center gap-2 disabled:opacity-50 transition-all ${
                          installedPresets.some(ip => ip.id === preset.id)
                            ? 'bg-[var(--hytale-bg-elevated)] hover:bg-[var(--hytale-bg-hover)]'
                            : 'bg-[var(--hytale-accent-blue)] hover:bg-[var(--hytale-accent-blue-hover)]'
                        }`}
                      >
                        <Download size={14} /> {installedPresets.some(ip => ip.id === preset.id) ? 'Reinstall' : 'Install Preset'}
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );

  // ============== Render Settings Page ==============
  const toggleSettingsSection = (id: string) => {
    setSettingsExpanded(prev => ({ ...prev, [id]: !prev[id] }));
  };

  const renderSettingsPage = () => (
    <div className="flex-1 p-6 lg:p-8 overflow-y-auto">
      {/* Film grain overlay */}
      <div className="grain-overlay"></div>

      <div className="max-w-3xl mx-auto space-y-4">
        {/* Page Header - Enhanced */}
        <header className="mb-6">
          <div className="flex items-center gap-4 mb-3">
            <div className="w-12 h-12 rounded-xl bg-[var(--hytale-bg-elevated)] border border-[var(--hytale-border-card)] flex items-center justify-center">
              <Settings size={22} className="text-[var(--hytale-accent-blue)]" />
            </div>
            <div>
              <h1 className="font-hytale font-black text-2xl text-[var(--hytale-text-primary)] uppercase tracking-wide">Settings</h1>
              <p className="text-[var(--hytale-text-muted)] text-sm font-body">Configure OrbisFX and manage your installation</p>
            </div>
          </div>
        </header>

        {/* Game Setup Section */}
        <SettingsSection
          id="game"
          title="Game Setup"
          description="Configure your Hytale installation path"
          icon={<FolderOpen size={20} className="text-[var(--hytale-accent-blue)]" />}
          expanded={settingsExpanded.game}
          onToggle={() => toggleSettingsSection('game')}
          badge={validationStatus === 'success' ? (
            <span className="text-emerald-400 text-[10px] bg-emerald-500/15 px-2 py-0.5 rounded-full font-medium">Ready</span>
          ) : validationStatus === 'error' ? (
            <span className="text-red-400 text-[10px] bg-red-500/15 px-2 py-0.5 rounded-full font-medium">Error</span>
          ) : null}
        >
          <div className="space-y-4">
            <div className="flex gap-3">
              <input
                type="text"
                value={installPath}
                onChange={(e) => setInstallPath(e.target.value)}
                placeholder="Select Hytale installation folder..."
                className="flex-1 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-lg px-4 py-3 text-[var(--hytale-text-primary)] text-sm font-mono placeholder-[var(--hytale-text-faint)] focus:ring-2 focus:ring-[var(--hytale-accent-blue)]/30 focus:border-[var(--hytale-accent-blue)]/50 focus:outline-none transition-all"
              />
              <button
                onClick={handleBrowse}
                className="px-5 py-3 bg-[var(--hytale-bg-elevated)] border border-[var(--hytale-border-card)] rounded-lg text-[var(--hytale-text-muted)] text-sm font-medium flex items-center gap-2 hover:bg-[var(--hytale-bg-hover)] hover:border-[var(--hytale-border-hover)] hover:text-[var(--hytale-text-primary)] transition-all"
              >
                <FolderOpen size={16} /> Browse
              </button>
            </div>
            {validationStatus === 'success' && (
              <div className="flex items-center gap-3 text-emerald-400 text-sm font-body bg-emerald-500/10 border border-emerald-500/20 rounded-lg px-4 py-3">
                <CheckCircle size={16} />
                <span>Hytale installation detected</span>
              </div>
            )}
            {validationStatus === 'error' && installPath && (
              <div className="flex items-center gap-3 text-red-400 text-sm font-body bg-red-500/10 border border-red-500/20 rounded-lg px-4 py-3">
                <AlertTriangle size={16} />
                <span>Invalid path - Hytale.exe not found</span>
              </div>
            )}
          </div>
        </SettingsSection>

        {/* OrbisFX Runtime Section */}
        <SettingsSection
          id="runtime"
          title="OrbisFX Runtime"
          description={validationResult?.gshade_installed ? 'Manage graphics enhancements' : 'Install graphics runtime'}
          icon={<Power size={20} className={validationResult?.gshade_enabled ? 'text-emerald-400' : 'text-[var(--hytale-accent-blue)]'} />}
          expanded={settingsExpanded.runtime}
          onToggle={() => toggleSettingsSection('runtime')}
          badge={validationResult?.gshade_installed ? (
            <span className={`text-[10px] px-2 py-0.5 rounded-full font-medium ${validationResult?.gshade_enabled ? 'text-emerald-400 bg-emerald-500/15' : 'text-amber-400 bg-amber-500/15'}`}>
              {validationResult?.gshade_enabled ? 'Enabled' : 'Disabled'}
            </span>
          ) : (
            <span className="text-[var(--hytale-text-dimmer)] text-[10px] bg-[var(--hytale-bg-input)] px-2 py-0.5 rounded-full">Not Installed</span>
          )}
        >
          <div className="space-y-5">
            {/* Runtime Toggle */}
            {validationResult?.gshade_installed && (
              <div className="flex items-center justify-between bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-xl p-4">
                <div>
                  <span className="text-[var(--hytale-text-primary)] text-sm font-semibold">Enable Effects</span>
                  <p className="text-[var(--hytale-text-muted)] text-xs mt-0.5">Toggle graphics enhancements on/off</p>
                </div>
                <button
                  onClick={() => handleToggleRuntime(!validationResult?.gshade_enabled)}
                  className={`relative w-14 h-7 rounded-full transition-all duration-200 ${
                    validationResult?.gshade_enabled ? 'bg-emerald-500 shadow-lg shadow-emerald-500/30' : 'bg-[var(--hytale-border-card)]'
                  }`}
                >
                  <div className={`absolute top-0.5 w-6 h-6 bg-white rounded-full shadow-md transition-transform duration-200 ${
                    validationResult?.gshade_enabled ? 'translate-x-7' : 'translate-x-0.5'
                  }`} />
                </button>
              </div>
            )}

            {/* Install/Uninstall Buttons */}
            <div>
              <p className="text-[var(--hytale-text-muted)] text-sm mb-4 font-body leading-relaxed">
                {validationResult?.gshade_installed
                  ? 'OrbisFX runtime is installed. You can reinstall to update or repair.'
                  : 'Install the OrbisFX runtime to enable graphics enhancements.'}
              </p>
              <div className="flex flex-wrap gap-3">
                <button
                  onClick={handleInstallRuntime}
                  disabled={isInstalling || validationStatus !== 'success'}
                  className="px-5 py-2.5 text-sm text-white rounded-lg flex items-center gap-2 disabled:opacity-50 bg-gradient-to-r from-[var(--hytale-accent-blue)] to-purple-600 hover:shadow-lg hover:shadow-[var(--hytale-accent-blue)]/20 transition-all"
                >
                  <Download size={16} /> {validationResult?.gshade_installed ? 'Reinstall' : 'Install'} OrbisFX
                </button>
                {validationResult?.gshade_installed && (
                  <button
                    onClick={handleUninstallRuntime}
                    disabled={isInstalling}
                    className="px-5 py-2.5 text-sm rounded-lg flex items-center gap-2 disabled:opacity-50 text-red-400 border border-red-500/30 hover:bg-red-500/10 transition-all"
                  >
                    <Trash2 size={16} /> Uninstall
                  </button>
                )}
              </div>
            </div>

            {/* Hotkeys */}
            {hotkeys && validationResult?.gshade_installed && (
              <div className="pt-4 border-t border-[var(--hytale-border-card)]">
                <div className="flex items-center gap-2 mb-4">
                  <Keyboard size={16} className="text-[var(--hytale-accent-blue)]" />
                  <span className="text-[var(--hytale-text-primary)] text-sm font-semibold">GShade Hotkeys</span>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                  {[
                    { label: 'Toggle Effects', key: hotkeys.key_effects },
                    { label: 'Toggle Overlay', key: hotkeys.key_overlay },
                    { label: 'Screenshot', key: hotkeys.key_screenshot },
                    { label: 'Next Preset', key: hotkeys.key_next_preset },
                    { label: 'Previous Preset', key: hotkeys.key_prev_preset },
                  ].map((item, idx) => (
                    <div key={idx} className="flex items-center justify-between bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg px-4 py-2.5">
                      <span className="text-[var(--hytale-text-muted)] text-sm font-body">{item.label}</span>
                      <kbd className="bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] text-[var(--hytale-accent-blue)] text-xs px-2.5 py-1 rounded-md font-mono font-medium">{item.key}</kbd>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </SettingsSection>

        {/* Appearance Section */}
        <SettingsSection
          id="appearance"
          title="Appearance"
          description="Theme and layout preferences"
          icon={<Palette size={20} className="text-[var(--hytale-accent-blue)]" />}
          expanded={settingsExpanded.appearance}
          onToggle={() => toggleSettingsSection('appearance')}
        >
          <div className="space-y-6">
            {/* Theme Selection */}
            <div>
              <label className="text-[var(--hytale-text-primary)] text-sm font-semibold mb-4 block">Color Theme</label>
              <div className="grid grid-cols-4 gap-3">
                {([
                  { value: 'system', label: 'System', icon: Monitor },
                  { value: 'light', label: 'Light', icon: Sun },
                  { value: 'dark', label: 'Dark', icon: Moon },
                  { value: 'oled', label: 'OLED', icon: Moon },
                ] as const).map(({ value, label, icon: Icon }) => (
                  <button
                    key={value}
                    onClick={() => saveSettings({ ...settings, theme: value })}
                    className={`flex flex-col items-center gap-2.5 p-4 rounded-xl border transition-all duration-200 ${
                      (settings.theme || 'system') === value
                        ? 'bg-gradient-to-br from-[var(--hytale-accent-blue)]/20 to-purple-500/10 border-[var(--hytale-accent-blue)]/50 ring-2 ring-[var(--hytale-accent-blue)]/30 text-[var(--hytale-text-primary)] shadow-lg shadow-[var(--hytale-accent-blue)]/10'
                        : 'bg-[var(--hytale-bg-input)] border-[var(--hytale-border-card)] text-[var(--hytale-text-muted)] hover:bg-[var(--hytale-bg-elevated)] hover:border-[var(--hytale-border-hover)] hover:text-[var(--hytale-text-secondary)]'
                    }`}
                  >
                    <Icon size={22} className={(settings.theme || 'system') === value ? 'text-[var(--hytale-accent-blue)]' : ''} />
                    <span className="text-xs font-body font-medium">{label}</span>
                  </button>
                ))}
              </div>
              <p className="text-[var(--hytale-text-muted)] text-xs font-body mt-3">
                Currently using: <span className="text-[var(--hytale-accent-blue)] font-medium">{resolvedTheme}</span> theme
              </p>
            </div>

            {/* Layout Preferences */}
            <div className="pt-4 border-t border-[var(--hytale-border-card)]">
              <label className="text-[var(--hytale-text-primary)] text-sm font-semibold mb-4 block">Default Layouts</label>

              {/* Presets Layout */}
              <div className="flex items-center justify-between bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-xl p-4 mb-3">
                <span className="text-[var(--hytale-text-muted)] text-sm font-body">Presets Library</span>
                <div className="flex gap-1 bg-[var(--hytale-bg-card)] rounded-lg p-1 border border-[var(--hytale-border-card)]">
                  {([
                    { value: 'rows', icon: LayoutList, label: 'Rows' },
                    { value: 'grid', icon: LayoutGrid, label: 'Grid' },
                    { value: 'gallery', icon: GalleryHorizontal, label: 'Gallery' },
                  ] as const).map(({ value, icon: Icon, label }) => (
                    <button
                      key={value}
                      onClick={() => saveSettings({ ...settings, presets_layout: value })}
                      title={label}
                      className={`p-2 rounded-md transition-all ${
                        (settings.presets_layout || 'grid') === value
                          ? 'bg-[var(--hytale-accent-blue)] text-white shadow-sm'
                          : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)]'
                      }`}
                    >
                      <Icon size={16} />
                    </button>
                  ))}
                </div>
              </div>

              {/* Gallery Layout */}
              <div className="flex items-center justify-between bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-xl p-4">
                <span className="text-[var(--hytale-text-muted)] text-sm font-body">Screenshot Gallery</span>
                <div className="flex gap-1 bg-[var(--hytale-bg-card)] rounded-lg p-1 border border-[var(--hytale-border-card)]">
                  {([
                    { value: 'rows', icon: LayoutList, label: 'Rows' },
                    { value: 'grid', icon: LayoutGrid, label: 'Grid' },
                    { value: 'gallery', icon: GalleryHorizontal, label: 'Gallery' },
                  ] as const).map(({ value, icon: Icon, label }) => (
                    <button
                      key={value}
                      onClick={() => saveSettings({ ...settings, gallery_layout: value })}
                      title={label}
                      className={`p-2 rounded-md transition-all ${
                        (settings.gallery_layout || 'grid') === value
                          ? 'bg-[var(--hytale-accent-blue)] text-white shadow-sm'
                          : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)]'
                      }`}
                    >
                      <Icon size={16} />
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </SettingsSection>

        {/* About & Help Section */}
        <SettingsSection
          id="about"
          title="About & Help"
          description={`OrbisFX Launcher v${appVersion}`}
          icon={<Info size={20} className="text-[var(--hytale-accent-blue)]" />}
          expanded={settingsExpanded.about}
          onToggle={() => toggleSettingsSection('about')}
          badge={updateAvailable ? (
            <span className="text-amber-400 text-[10px] bg-amber-500/15 px-2 py-0.5 rounded-full font-medium animate-pulse">Update Available</span>
          ) : null}
        >
          <div className="space-y-4">
            {/* Updates */}
            <div className="flex items-center justify-between bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-xl p-4">
              <div className="flex items-center gap-4">
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${updateAvailable ? 'bg-amber-500/15' : 'bg-[var(--hytale-accent-blue)]/15'}`}>
                  <RefreshCw size={18} className={updateAvailable ? 'text-amber-400' : 'text-[var(--hytale-accent-blue)]'} />
                </div>
                <div>
                  <span className="text-[var(--hytale-text-primary)] text-sm font-semibold">Updates</span>
                  <p className="text-[var(--hytale-text-muted)] text-xs font-mono mt-0.5">
                    v{appVersion} {updateAvailable && <span className="text-amber-400">→ v{latestVersion}</span>}
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                {updateAvailable && (
                  <button
                    onClick={() => setShowUpdateModal(true)}
                    className="px-4 py-2 rounded-lg text-xs flex items-center gap-2 bg-gradient-to-r from-amber-500 to-orange-500 text-white font-medium hover:shadow-lg hover:shadow-amber-500/20 transition-all"
                  >
                    <Download size={14} /> Update
                  </button>
                )}
                <button
                  onClick={checkForUpdates}
                  className="px-4 py-2 rounded-lg text-xs flex items-center gap-2 text-[var(--hytale-text-muted)] border border-[var(--hytale-border-card)] hover:text-[var(--hytale-text-primary)] hover:border-[var(--hytale-border-hover)] hover:bg-[var(--hytale-bg-hover)] transition-all"
                >
                  <RefreshCw size={14} /> Check
                </button>
              </div>
            </div>

            {/* Tutorial */}
            <div className="flex items-center justify-between bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-xl p-4">
              <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl bg-purple-500/15 flex items-center justify-center">
                  <HelpCircle size={18} className="text-purple-400" />
                </div>
                <div>
                  <span className="text-[var(--hytale-text-primary)] text-sm font-semibold">Tutorial</span>
                  <p className="text-[var(--hytale-text-muted)] text-xs font-body mt-0.5">
                    {settings.tutorial_completed ? 'Completed ✓' : 'Learn how to use OrbisFX'}
                  </p>
                </div>
              </div>
              <button
                onClick={handleReplayTutorial}
                className="px-4 py-2 rounded-lg text-xs flex items-center gap-2 text-[var(--hytale-text-muted)] border border-[var(--hytale-border-card)] hover:text-[var(--hytale-text-primary)] hover:border-[var(--hytale-border-hover)] hover:bg-[var(--hytale-bg-hover)] transition-all"
              >
                <Play size={14} /> Replay
              </button>
            </div>

            {/* About Info */}
            <div className="text-center pt-6 border-t border-[var(--hytale-border-card)]">
              <div className="w-16 h-16 bg-gradient-to-br from-[var(--hytale-accent-blue)]/20 to-purple-500/20 rounded-2xl p-3 mx-auto mb-4 border border-[var(--hytale-border-card)]">
                <img src="/logo.png" alt="OrbisFX" className="w-full h-full object-contain" />
              </div>
              <h3 className="font-hytale font-bold text-[var(--hytale-text-primary)] text-lg tracking-wide">OrbisFX Launcher</h3>
              <p className="text-transparent bg-clip-text bg-gradient-to-r from-[var(--hytale-accent-blue)] to-purple-500 text-sm mt-1 font-mono font-bold">v{appVersion}</p>
              <p className="text-[var(--hytale-text-muted)] text-xs font-body mt-3">© 2024 OrbisFX Team. All rights reserved.</p>
            </div>
          </div>
        </SettingsSection>
      </div>
    </div>
  );

  // ============== Helper: Format file size ==============
  const formatFileSize = (bytes: number): string => {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  };

  // ============== Helper: Format date ==============
  const formatDate = (timestamp: string): string => {
    // Timestamp is Unix seconds as string from Rust backend
    const seconds = parseInt(timestamp, 10);
    if (isNaN(seconds) || seconds === 0) {
      return 'Unknown date';
    }
    const date = new Date(seconds * 1000); // Convert seconds to milliseconds
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  };

  // ============== Render Gallery Page ==============
  const renderGalleryPage = () => (
    <div className="flex-1 p-6 lg:p-8 overflow-y-auto">
      {/* Film grain overlay */}
      <div className="grain-overlay"></div>

      <div className="max-w-7xl mx-auto space-y-5">
        {/* Page Header - Clean */}
        <header className="mb-2">
          <h1 className="font-hytale font-black text-2xl text-[var(--hytale-text-primary)] uppercase tracking-wide">Screenshot Gallery</h1>
          <p className="text-[var(--hytale-text-dim)] text-sm font-body mt-1">View and manage your GShade screenshots</p>
        </header>

        {/* Search and Filter Bar - Simplified */}
        <div className="space-y-3">
          {/* Main controls row */}
          <div className="flex flex-col lg:flex-row gap-3">
            {/* Search input */}
            <div className="flex-1 bg-[var(--hytale-bg-elevated)] rounded-lg flex items-center px-3 transition-colors">
              <Search size={16} className="text-[var(--hytale-text-dimmer)]" />
              <input
                type="text"
                value={screenshotSearchQuery}
                onChange={(e) => setScreenshotSearchQuery(e.target.value)}
                placeholder="Search by filename or preset..."
                className="bg-transparent w-full py-2.5 px-3 text-[var(--hytale-text-primary)] outline-none placeholder-[var(--hytale-text-faint)] text-sm"
              />
              {screenshotSearchQuery && (
                <button
                  onClick={() => setScreenshotSearchQuery('')}
                  className="p-1 text-[var(--hytale-text-dimmer)] hover:text-[var(--hytale-text-primary)] transition-colors"
                >
                  <X size={14} />
                </button>
              )}
            </div>

            {/* All/Favorites toggle */}
            <div className="flex gap-1 bg-[var(--hytale-bg-elevated)] rounded-lg p-1">
              <button
                onClick={() => setScreenshotFilter('all')}
                className={`px-3 py-1.5 rounded-md text-xs flex items-center gap-1.5 transition-colors ${
                  screenshotFilter === 'all'
                    ? 'bg-[var(--hytale-bg-input)] text-[var(--hytale-text-primary)] shadow-sm'
                    : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)]'
                }`}
              >
                <Grid size={12} /> All
              </button>
              <button
                onClick={() => setScreenshotFilter('favorites')}
                className={`px-3 py-1.5 rounded-md text-xs flex items-center gap-1.5 transition-colors ${
                  screenshotFilter === 'favorites'
                    ? 'bg-[var(--hytale-bg-input)] text-rose-400 shadow-sm'
                    : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)]'
                }`}
              >
                <Heart size={12} fill={screenshotFilter === 'favorites' ? 'currentColor' : 'none'} /> Favorites
              </button>
            </div>

            {/* Filters toggle button */}
            <button
              onClick={() => setShowGalleryFilters(!showGalleryFilters)}
              className={`px-3 py-2 rounded-lg text-sm flex items-center gap-2 transition-colors ${
                showGalleryFilters || screenshotPresetFilter !== 'all' || screenshotSort !== 'date-desc'
                  ? 'bg-[var(--hytale-accent-blue)]/10 text-[var(--hytale-accent-blue)]'
                  : 'bg-[var(--hytale-bg-elevated)] text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]'
              }`}
            >
              <Filter size={14} />
              Filters
              {(screenshotPresetFilter !== 'all' || screenshotSort !== 'date-desc') && (
                <span className="w-1.5 h-1.5 rounded-full bg-[var(--hytale-accent-blue)]"></span>
              )}
              <ChevronDown size={14} className={`transition-transform ${showGalleryFilters ? 'rotate-180' : ''}`} />
            </button>

            {/* Layout Toggle */}
            <div className="flex gap-1 bg-[var(--hytale-bg-elevated)] rounded-lg p-1">
              {([
                { value: 'grid', icon: LayoutGrid },
                { value: 'gallery', icon: GalleryHorizontal },
              ] as const).map(({ value, icon: Icon }) => (
                <button
                  key={value}
                  onClick={() => saveSettings({ ...settings, gallery_layout: value })}
                  className={`p-2 rounded-md transition-all ${
                    (settings.gallery_layout || 'grid') === value
                      ? 'bg-[var(--hytale-bg-input)] text-[var(--hytale-accent-blue)] shadow-sm'
                      : 'text-[var(--hytale-text-dimmer)] hover:text-[var(--hytale-text-primary)]'
                  }`}
                >
                  <Icon size={16} />
                </button>
              ))}
            </div>

            {/* Open folder button */}
            <button
              onClick={handleOpenScreenshotsFolder}
              className="px-3 py-2 bg-[var(--hytale-bg-elevated)] rounded-lg text-[var(--hytale-text-muted)] text-sm flex items-center gap-2 hover:bg-[var(--hytale-bg-hover)] hover:text-[var(--hytale-text-primary)] transition-colors"
            >
              <FolderOpenIcon size={14} /> Open Folder
            </button>
          </div>

          {/* Collapsible filter panel */}
          {showGalleryFilters && (
            <div className="bg-[var(--hytale-bg-elevated)] rounded-lg p-4 flex flex-wrap gap-4 items-center animate-fade-in">
              {/* Preset filter */}
              {screenshotPresets.length > 0 && (
                <div className="flex items-center gap-2">
                  <span className="text-[var(--hytale-text-dim)] text-xs">Preset:</span>
                  <div className="relative">
                    <select
                      value={screenshotPresetFilter}
                      onChange={(e) => setScreenshotPresetFilter(e.target.value)}
                      className="appearance-none bg-[var(--hytale-bg-input)] rounded-lg pl-3 pr-8 py-1.5 text-[var(--hytale-text-primary)] text-sm focus:outline-none transition-colors cursor-pointer"
                    >
                      <option value="all">All ({screenshotPresets.length})</option>
                      {screenshotPresets.map(preset => (
                        <option key={preset} value={preset}>{preset}</option>
                      ))}
                    </select>
                    <ChevronDown size={14} className="absolute right-2 top-1/2 -translate-y-1/2 text-[var(--hytale-text-dimmer)] pointer-events-none" />
                  </div>
                </div>
              )}

              {/* Sort */}
              <div className="flex items-center gap-2">
                <span className="text-[var(--hytale-text-dim)] text-xs">Sort:</span>
                <div className="relative">
                  <select
                    value={screenshotSort}
                    onChange={(e) => setScreenshotSort(e.target.value as typeof screenshotSort)}
                    className="appearance-none bg-[var(--hytale-bg-input)] rounded-lg pl-3 pr-8 py-1.5 text-[var(--hytale-text-primary)] text-sm focus:outline-none transition-colors cursor-pointer"
                  >
                    <option value="date-desc">Newest First</option>
                    <option value="date-asc">Oldest First</option>
                    <option value="name-asc">Name A-Z</option>
                    <option value="name-desc">Name Z-A</option>
                    <option value="size-desc">Largest First</option>
                    <option value="size-asc">Smallest First</option>
                    <option value="preset-asc">Preset A-Z</option>
                    <option value="preset-desc">Preset Z-A</option>
                    <option value="favorites">Favorites First</option>
                  </select>
                  <ChevronDown size={14} className="absolute right-2 top-1/2 -translate-y-1/2 text-[var(--hytale-text-dimmer)] pointer-events-none" />
                </div>
              </div>

              {/* Reset filters button */}
              {(screenshotPresetFilter !== 'all' || screenshotSort !== 'date-desc') && (
                <button
                  onClick={() => {
                    setScreenshotPresetFilter('all');
                    setScreenshotSort('date-desc');
                  }}
                  className="text-[var(--hytale-text-dim)] text-xs hover:text-[var(--hytale-text-primary)] transition-colors flex items-center gap-1"
                >
                  <X size={12} /> Reset
                </button>
              )}
            </div>
          )}
        </div>

        {/* Screenshots Grid */}
        {screenshotsLoading ? (
          <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-12 text-center">
            <div className="w-10 h-10 rounded-full border-2 border-[var(--hytale-border-card)] border-t-[var(--hytale-accent-blue)] animate-spin mx-auto"></div>
            <p className="text-[var(--hytale-text-dim)] text-sm mt-4">Loading screenshots...</p>
          </div>
        ) : filteredScreenshots.length === 0 ? (
          <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-12 text-center">
            <Camera size={32} className="text-[var(--hytale-text-faint)] mx-auto mb-3" />
            <p className="text-[var(--hytale-text-muted)] text-sm">
              {screenshots.length === 0 ? 'No screenshots yet' : 'No matching screenshots'}
            </p>
            <p className="text-[var(--hytale-text-dimmer)] text-xs mt-1">
              {screenshots.length === 0
                ? 'Take screenshots in-game using GShade'
                : 'Try adjusting your filters'}
            </p>
            {screenshots.length === 0 && (
              <button
                onClick={handleOpenScreenshotsFolder}
                className="px-3 py-2 mt-4 bg-[var(--hytale-bg-elevated)] text-[var(--hytale-text-muted)] text-sm rounded-md hover:bg-[var(--hytale-bg-hover)] hover:text-[var(--hytale-text-primary)] transition-colors"
              >
                Open Screenshots Folder
              </button>
            )}
          </div>
        ) : (
          <>
            {/* Results count */}
            <div className="flex items-center text-sm text-[var(--hytale-text-dim)]">
              <span>
                Showing {filteredScreenshots.length} of {screenshots.length} screenshots
              </span>
              {screenshots.filter(s => s.is_favorite).length > 0 && (
                <span className="flex items-center gap-1 ml-3 text-rose-400 text-xs">
                  <Heart size={10} className="fill-current" />
                  {screenshots.filter(s => s.is_favorite).length} favorited
                </span>
              )}
            </div>

            {/* Grid/Gallery Layout */}
            {(() => {
              const isGalleryLayout = (settings.gallery_layout || 'grid') === 'gallery';

              return (
                <div className={isGalleryLayout
                  ? 'grid grid-cols-1 lg:grid-cols-2 gap-6'
                  : 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4'
                }>
                  {filteredScreenshots.map((screenshot, index) => (
                    <div
                      key={screenshot.id}
                      className={`bg-[var(--hytale-bg-card)] border rounded-lg overflow-hidden transition-all duration-200 hover:-translate-y-0.5 hover:shadow-lg animate-fade-in-up ${
                        screenshot.is_favorite
                          ? 'border-rose-500/30 hover:border-rose-500/50'
                          : 'border-[var(--hytale-border-card)] hover:border-[var(--hytale-border-hover)]'
                      }`}
                      style={{ animationDelay: `${Math.min(index * 0.03, 0.3)}s` }}
                    >
                      {/* Thumbnail */}
                      <div
                        className={`bg-[var(--hytale-bg-input)] relative overflow-hidden cursor-pointer ${
                          isGalleryLayout ? 'aspect-[16/9]' : 'aspect-video'
                        }`}
                        onClick={() => setFullscreenScreenshot(screenshot)}
                      >
                        <img
                          src={convertFileSrc(screenshot.path)}
                          alt={screenshot.filename}
                          className="w-full h-full object-cover"
                          loading="lazy"
                        />

                        {/* Favorite badge */}
                        {screenshot.is_favorite && (
                          <div className={`absolute ${isGalleryLayout ? 'top-3 right-3' : 'top-2 right-2'}`}>
                            <Heart size={isGalleryLayout ? 18 : 14} className="text-rose-400 fill-rose-400" />
                          </div>
                        )}

                        {/* Preset badge */}
                        {screenshot.preset_name && (
                          <div className={`absolute ${isGalleryLayout ? 'bottom-3 left-3' : 'bottom-2 left-2'}`}>
                            <span className={`bg-black/60 text-white rounded ${isGalleryLayout ? 'text-sm px-3 py-1' : 'text-xs px-2 py-0.5'}`}>
                              {screenshot.preset_name}
                            </span>
                          </div>
                        )}

                        {/* Gallery mode: overlay actions on hover */}
                        {isGalleryLayout && (
                          <div className="absolute inset-0 bg-black/0 hover:bg-black/40 transition-colors flex items-center justify-center opacity-0 hover:opacity-100">
                            <div className="flex items-center gap-2">
                              <button
                                onClick={(e) => {
                                  e.stopPropagation();
                                  setFullscreenScreenshot(screenshot);
                                }}
                                className="p-3 bg-white/20 rounded-full text-white hover:bg-white/30 transition-colors"
                                title="View fullscreen"
                              >
                                <Maximize2 size={20} />
                              </button>
                            </div>
                          </div>
                        )}
                      </div>

                      {/* Info section */}
                      <div className={isGalleryLayout ? 'p-4' : 'p-3'}>
                        {/* Metadata row */}
                        <div className={`flex items-center justify-between text-[var(--hytale-text-dimmer)] mb-1 ${isGalleryLayout ? 'text-xs' : 'text-[10px]'}`}>
                          <span className="flex items-center gap-1">
                            <Clock size={isGalleryLayout ? 12 : 10} />
                            {formatDate(screenshot.timestamp)}
                          </span>
                          <span>{formatFileSize(screenshot.file_size)}</span>
                        </div>

                        {/* Filename */}
                        <p className={`text-[var(--hytale-text-muted)] truncate ${isGalleryLayout ? 'text-sm' : 'text-xs'}`} title={screenshot.filename}>
                          {screenshot.filename}
                        </p>

                        {/* Actions */}
                        <div className={`flex items-center gap-1 border-t border-[var(--hytale-border-card)] ${isGalleryLayout ? 'mt-3 pt-3' : 'mt-2 pt-2'}`}>
                          <button
                            onClick={() => handleToggleScreenshotFavorite(screenshot.id)}
                            className={`rounded transition-colors ${
                              screenshot.is_favorite
                                ? 'text-rose-400'
                                : 'text-[var(--hytale-text-dimmer)] hover:text-rose-400'
                            } ${isGalleryLayout ? 'p-2' : 'p-1.5'}`}
                            title={screenshot.is_favorite ? 'Remove from favorites' : 'Add to favorites'}
                          >
                            <Heart size={isGalleryLayout ? 14 : 12} fill={screenshot.is_favorite ? 'currentColor' : 'none'} />
                          </button>
                          <button
                            onClick={() => handleCopyScreenshotToClipboard(screenshot)}
                            className={`rounded text-[var(--hytale-text-dimmer)] hover:text-[var(--hytale-accent-blue)] transition-colors ${isGalleryLayout ? 'p-2' : 'p-1.5'}`}
                            title="Copy to clipboard"
                          >
                            <Copy size={isGalleryLayout ? 14 : 12} />
                          </button>
                          <button
                            onClick={() => handleRevealScreenshot(screenshot.path)}
                            className={`rounded text-[var(--hytale-text-dimmer)] hover:text-[var(--hytale-accent-blue)] transition-colors ${isGalleryLayout ? 'p-2' : 'p-1.5'}`}
                            title="Show in folder"
                          >
                            <FolderOpenIcon size={isGalleryLayout ? 14 : 12} />
                          </button>
                          <div className="flex-1"></div>
                          <button
                            onClick={() => handleDeleteScreenshot(screenshot)}
                            className={`rounded text-[var(--hytale-text-dimmer)] hover:text-[var(--hytale-error)] transition-colors ${isGalleryLayout ? 'p-2' : 'p-1.5'}`}
                            title="Delete screenshot"
                          >
                            <Trash2 size={isGalleryLayout ? 14 : 12} />
                          </button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              );
            })()}
          </>
        )}
      </div>

      {/* Fullscreen Modal */}
      {fullscreenScreenshot && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/95 animate-fadeIn"
          onClick={() => setFullscreenScreenshot(null)}
        >
          <div className="relative max-w-[95vw] max-h-[95vh] animate-scaleIn">
            <img
              src={convertFileSrc(fullscreenScreenshot.path)}
              alt={fullscreenScreenshot.filename}
              className="max-w-full max-h-[85vh] object-contain rounded-lg shadow-2xl"
              onClick={(e) => e.stopPropagation()}
            />

            {/* Close button */}
            <button
              onClick={() => setFullscreenScreenshot(null)}
              className="absolute top-4 right-4 w-12 h-12 rounded-full bg-black/70 text-white hover:bg-black/90 transition-colors flex items-center justify-center backdrop-blur-sm"
            >
              <X size={24} />
            </button>

            {/* Info bar */}
            <div
              className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black via-black/80 to-transparent p-6 rounded-b-lg"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between gap-4">
                <div className="flex-1 min-w-0">
                  <p className="text-white text-lg font-medium truncate">{fullscreenScreenshot.filename}</p>
                  <div className="flex items-center gap-4 mt-2 text-sm text-[var(--hytale-text-muted)]">
                    {fullscreenScreenshot.preset_name && (
                      <span className="flex items-center gap-1.5">
                        <Sparkles size={14} />
                        {fullscreenScreenshot.preset_name}
                      </span>
                    )}
                    <span className="flex items-center gap-1.5">
                      <Clock size={14} />
                      {formatDate(fullscreenScreenshot.timestamp)}
                    </span>
                    <span className="flex items-center gap-1.5">
                      <HardDrive size={14} />
                      {formatFileSize(fullscreenScreenshot.file_size)}
                    </span>
                  </div>
                </div>

                {/* Action buttons - larger and more visible */}
                <div className="flex items-center gap-3">
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      handleToggleScreenshotFavorite(fullscreenScreenshot.id);
                      setFullscreenScreenshot(prev => prev ? { ...prev, is_favorite: !prev.is_favorite } : null);
                    }}
                    className={`p-3 rounded-lg transition-all ${
                      fullscreenScreenshot.is_favorite
                        ? 'bg-rose-500/20 text-rose-400 hover:bg-rose-500/30'
                        : 'bg-white/10 text-white/70 hover:text-rose-400 hover:bg-white/20'
                    }`}
                    title={fullscreenScreenshot.is_favorite ? 'Remove from favorites' : 'Add to favorites'}
                  >
                    <Heart size={22} fill={fullscreenScreenshot.is_favorite ? 'currentColor' : 'none'} />
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      handleCopyScreenshotToClipboard(fullscreenScreenshot);
                    }}
                    className="p-3 rounded-lg bg-white/10 text-white/70 hover:text-white hover:bg-white/20 transition-all"
                    title="Copy to clipboard"
                  >
                    <Copy size={22} />
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      handleRevealScreenshot(fullscreenScreenshot.path);
                    }}
                    className="p-3 rounded-lg bg-white/10 text-white/70 hover:text-white hover:bg-white/20 transition-all"
                    title="Show in folder"
                  >
                    <FolderOpenIcon size={22} />
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      handleDeleteScreenshot(fullscreenScreenshot);
                      setFullscreenScreenshot(null);
                    }}
                    className="p-3 rounded-lg bg-white/10 text-white/70 hover:text-[var(--hytale-error)] hover:bg-[var(--hytale-error)]/20 transition-all"
                    title="Delete screenshot"
                  >
                    <Trash2 size={22} />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );

  // ============== Render Setup Wizard ==============
  const renderSetupWizard = () => (
    <div className="flex-1 flex flex-col items-center justify-center p-8 relative">
      {/* Background effects */}
      <div className="absolute inset-0 grid-overlay"></div>
      <div className="absolute top-0 right-0 w-96 h-96 bg-[var(--hytale-accent-blue)] rounded-full blur-[150px] opacity-5 pointer-events-none"></div>

      <div className="max-w-xl w-full relative z-10">
        {/* Welcome Step */}
        {setupStep === 0 && (
          <div className="text-center animate-fade-in">
            <div className="relative inline-block">
              <img src="/logo.png" alt="OrbisFX" className="w-32 h-32 mx-auto mb-6" />
              {/* Floating particles around logo */}
              <div className="particle p1" style={{ top: '10%', left: '0%' }}></div>
              <div className="particle p2" style={{ top: '50%', right: '0%' }}></div>
              <div className="particle p3" style={{ bottom: '10%', left: '20%' }}></div>
            </div>
            <h1 className="font-hytale font-black text-4xl text-[var(--hytale-text-primary)] mb-4 uppercase tracking-wide">Welcome to OrbisFX</h1>
            <p className="text-[var(--hytale-text-secondary)] text-lg mb-8 font-body">Advanced graphics enhancement for Hytale</p>
            <p className="text-[var(--hytale-text-muted)] text-sm mb-8 font-body">
              This wizard will help you set up OrbisFX and configure your Hytale installation.
            </p>
            <button
              onClick={() => setSetupStep(1)}
              className="btn-hyfx-primary px-8 py-4 font-hytale font-bold text-lg text-[var(--hytale-text-primary)] rounded-md uppercase tracking-wider flex items-center gap-3 mx-auto"
            >
              <Play size={20} /> Get Started
            </button>
          </div>
        )}

        {/* Path Selection Step */}
        {setupStep === 1 && (
          <div className="animate-fade-in">
            <h2 className="font-hytale font-bold text-2xl text-[var(--hytale-text-primary)] mb-2 uppercase tracking-wide">Select Game Directory</h2>
            <p className="text-[var(--hytale-text-secondary)] mb-6 font-body">Locate your Hytale installation folder containing Hytale.exe</p>

            <div className="card-hyfx p-6 mb-6">
              <div className="flex gap-3 mb-4">
                <input
                  type="text"
                  value={installPath}
                  onChange={(e) => setInstallPath(e.target.value)}
                  placeholder="C:\Program Files\Hytale..."
                  className="input-hyfx flex-1"
                />
                <button
                  onClick={handleBrowse}
                  className="btn-hyfx-secondary px-5 rounded-md font-hytale font-bold text-sm uppercase flex items-center gap-2"
                >
                  <FolderOpen size={18} /> Browse
                </button>
              </div>
              {validationStatus === 'success' && (
                <p className="text-[var(--hytale-success)] text-sm flex items-center gap-2 font-body">
                  <CheckCircle size={14} /> Hytale installation detected!
                </p>
              )}
              {validationStatus === 'error' && installPath && (
                <p className="text-[var(--hytale-error)] text-sm flex items-center gap-2 font-body">
                  <AlertTriangle size={14} /> Hytale.exe not found in this directory
                </p>
              )}
            </div>

            <div className="flex gap-4">
              <button
                onClick={() => setSetupStep(0)}
                className="btn-hyfx-secondary px-6 py-3 font-hytale font-bold text-sm rounded-md uppercase"
              >
                Back
              </button>
              <button
                onClick={() => setSetupStep(2)}
                disabled={validationStatus !== 'success'}
                className="flex-1 btn-hyfx-primary px-6 py-3 font-hytale font-bold text-sm text-[var(--hytale-text-primary)] rounded-md uppercase disabled:opacity-50"
              >
                Continue
              </button>
            </div>
          </div>
        )}

        {/* Install Runtime Step - Hytale Style */}
        {setupStep === 2 && (
          <div className="animate-fade-in">
            <h2 className="font-hytale font-bold text-2xl text-[var(--hytale-text-primary)] mb-2 uppercase tracking-wide">Install OrbisFX Runtime</h2>
            <p className="text-[var(--hytale-text-secondary)] mb-6 font-body">Install the graphics runtime to enhance your Hytale experience</p>

            <div className="card-hyfx p-6 mb-6">
              {!isInstalling && !validationResult?.gshade_installed && (
                <div className="text-center">
                  <Download size={48} className="text-[var(--hytale-accent-blue)] mx-auto mb-4" />
                  <p className="text-[var(--hytale-text-primary)] font-hytale font-bold mb-2 uppercase">Ready to Install</p>
                  <p className="text-[var(--hytale-text-muted)] text-sm mb-4 font-body">Click below to install the OrbisFX graphics runtime</p>
                  <button
                    onClick={handleInstallRuntime}
                    className="btn-hyfx-primary px-8 py-3 font-hytale font-bold text-[var(--hytale-text-primary)] rounded-md uppercase"
                  >
                    Install OrbisFX
                  </button>
                </div>
              )}

              {isInstalling && (
                <div>
                  <div className="flex justify-between items-center mb-3">
                    <span className="text-[var(--hytale-accent-blue)] font-mono text-sm">Installing... {installProgress}%</span>
                    <Activity size={16} className="text-[var(--hytale-accent-blue)] animate-spin" />
                  </div>
                  <ProgressBar progress={installProgress} />
                  <TerminalLog logs={installLogs} />
                </div>
              )}

              {validationResult?.gshade_installed && !isInstalling && (
                <div className="text-center">
                  <CheckCircle size={48} className="text-[var(--hytale-success)] mx-auto mb-4" />
                  <p className="text-[var(--hytale-text-primary)] font-hytale font-bold mb-2 uppercase">Installation Complete!</p>
                  <p className="text-[var(--hytale-text-muted)] text-sm font-body">OrbisFX runtime has been installed successfully</p>
                </div>
              )}
            </div>

            <div className="flex gap-4">
              <button
                onClick={() => setSetupStep(1)}
                disabled={isInstalling}
                className="btn-hyfx-secondary px-6 py-3 font-hytale font-bold text-sm rounded-md uppercase disabled:opacity-50"
              >
                Back
              </button>
              <button
                onClick={() => setSetupStep(3)}
                disabled={isInstalling || !validationResult?.gshade_installed}
                className="flex-1 btn-hyfx-primary px-6 py-3 font-hytale font-bold text-sm text-[var(--hytale-text-primary)] rounded-md uppercase disabled:opacity-50"
              >
                Continue
              </button>
              {!validationResult?.gshade_installed && !isInstalling && (
                <button
                  onClick={() => setSetupStep(3)}
                  className="text-[var(--hytale-text-muted)] hover:text-[var(--hytale-accent-blue)] text-sm font-body transition-colors"
                >
                  Skip for now
                </button>
              )}
            </div>
          </div>
        )}

        {/* Complete Step - Hytale Style */}
        {setupStep === 3 && (
          <div className="text-center animate-fade-in">
            <div className="w-20 h-20 bg-[var(--hytale-accent-blue)]/10 rounded-md flex items-center justify-center mx-auto mb-6 border-2 border-[var(--hytale-accent-blue)]/30 shadow-[var(--hytale-glow-blue)]">
              <CheckCircle size={40} className="text-[var(--hytale-accent-blue)]" />
            </div>
            <h2 className="font-hytale font-bold text-2xl text-[var(--hytale-text-primary)] mb-2 uppercase tracking-wide">Setup Complete!</h2>
            <p className="text-[var(--hytale-text-secondary)] mb-8 font-body">You're all set to start using OrbisFX</p>

            <button
              onClick={async () => {
                await saveSettings({ ...settings, hytale_path: installPath });
                setIsFirstLaunch(false);
                setCurrentPage('home');
              }}
              className="btn-hyfx-primary px-8 py-4 font-hytale font-bold text-lg text-[var(--hytale-text-primary)] rounded-md uppercase tracking-wider flex items-center gap-3 mx-auto"
            >
              <Home size={20} /> Go to Launcher
            </button>
          </div>
        )}
      </div>
    </div>
  );

  // ============== Main Render ==============
  return (
    <div className="flex h-screen bg-[var(--hytale-bg-primary)] relative overflow-hidden flex-col">
      {/* Background Effects - Hytale Style */}
      <div className="absolute inset-0 bg-[linear-gradient(rgba(89,138,195,0.03)_1px,transparent_1px),linear-gradient(90deg,rgba(89,138,195,0.03)_1px,transparent_1px)] bg-[size:40px_40px] pointer-events-none"></div>
      <div className="absolute top-0 right-0 w-96 h-96 bg-[var(--hytale-accent-blue)] rounded-full blur-[150px] opacity-5 pointer-events-none"></div>

      {/* Title Bar - Hytale Style */}
      <div className="h-10 bg-[var(--hytale-bg-footer)] border-b-2 border-[var(--hytale-border-primary)] flex items-center justify-between px-4 z-20 flex-shrink-0 select-none" style={{ WebkitAppRegion: 'drag' } as React.CSSProperties}>
        <div className="flex items-center gap-2">
          <img src="/logo.png" alt="OrbisFX" className="w-5 h-5" />
          <span className="text-xs uppercase font-hytale font-bold tracking-widest text-[var(--hytale-text-secondary)]">OrbisFX Launcher <span className="text-[var(--hytale-accent-blue)]">v{appVersion}</span></span>
        </div>
        <div className="flex gap-1" style={{ WebkitAppRegion: 'no-drag' } as React.CSSProperties}>
          <button onClick={() => appWindow.minimize()} className="hover:bg-[var(--hytale-border-primary)] p-2 rounded-md transition-colors text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]">
            <Minus size={14} />
          </button>
          <button onClick={() => exit(0)} className="hover:bg-[var(--hytale-error)]/20 p-2 rounded-md transition-colors text-[var(--hytale-text-muted)] hover:text-[var(--hytale-error)]">
            <X size={14} />
          </button>
        </div>
      </div>

      {/* Setup Wizard (shown on first launch) */}
      {currentPage === 'setup' && renderSetupWizard()}

      {/* Main Layout (hidden during setup) */}
      {currentPage !== 'setup' && (
        <div className="flex flex-1 overflow-hidden">
          {/* Sidebar - Hytale Style */}
          <div className="w-60 bg-[var(--hytale-bg-secondary)] border-r-2 border-[var(--hytale-border-primary)] flex flex-col z-10">
            {/* Logo/Brand Area */}
            <div className="p-5 border-b-2 border-[var(--hytale-border-primary)]">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-md border-2 border-[var(--hytale-border-primary)] p-1 bg-[var(--hytale-bg-tertiary)]">
                  <img src="/logo.png" alt="OrbisFX" className="w-full h-full object-contain" />
                </div>
                <div>
                  <h2 className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm uppercase tracking-wide">OrbisFX</h2>
                  <span className="text-[var(--hytale-accent-blue)] text-xs font-mono">Launcher</span>
                </div>
              </div>
            </div>

            {/* Navigation - Hytale Style */}
            <nav className="flex-1 p-4 space-y-2">
              <p className="text-[var(--hytale-text-muted)] text-xs uppercase font-hytale font-bold tracking-wider mb-3 px-3">Navigation</p>
              <button
                id="nav-home"
                onClick={() => setCurrentPage('home')}
                className={`w-full p-3.5 rounded-md flex items-center gap-3 transition-all duration-200 group border-l-2 ${
                  currentPage === 'home'
                    ? 'bg-[var(--hytale-bg-nav)] text-[var(--hytale-accent-blue)] border-[var(--hytale-accent-blue)] shadow-[0_0_10px_var(--hytale-glow-blue)]'
                    : 'text-[var(--hytale-text-secondary)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-tertiary)] border-transparent hover:border-[var(--hytale-border-light)]'
                }`}
              >
                <Home size={18} className={`transition-transform duration-200 ${currentPage === 'home' ? '' : 'group-hover:scale-110'}`} />
                <span className="font-hytale text-sm font-bold uppercase tracking-wide">Home</span>
                {currentPage === 'home' && <ChevronRight size={14} className="ml-auto" />}
              </button>

              <button
                id="nav-presets"
                onClick={() => setCurrentPage('presets')}
                className={`w-full p-3.5 rounded-md flex items-center gap-3 transition-all duration-200 group border-l-2 ${
                  currentPage === 'presets'
                    ? 'bg-[var(--hytale-bg-nav)] text-[var(--hytale-accent-blue)] border-[var(--hytale-accent-blue)] shadow-[0_0_10px_var(--hytale-glow-blue)]'
                    : 'text-[var(--hytale-text-secondary)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-tertiary)] border-transparent hover:border-[var(--hytale-border-light)]'
                }`}
              >
                <Palette size={18} className={`transition-transform duration-200 ${currentPage === 'presets' ? '' : 'group-hover:scale-110'}`} />
                <span className="font-hytale text-sm font-bold uppercase tracking-wide">Presets</span>
                {installedPresets.length > 0 && (
                  <span className="ml-auto badge-hyfx primary">
                    {installedPresets.length}
                  </span>
                )}
                {currentPage === 'presets' && installedPresets.length === 0 && <ChevronRight size={14} className="ml-auto" />}
              </button>

              <button
                id="nav-gallery"
                onClick={() => setCurrentPage('gallery')}
                className={`w-full p-3.5 rounded-md flex items-center gap-3 transition-all duration-200 group border-l-2 ${
                  currentPage === 'gallery'
                    ? 'bg-[var(--hytale-bg-nav)] text-[var(--hytale-accent-blue)] border-[var(--hytale-accent-blue)] shadow-[0_0_10px_var(--hytale-glow-blue)]'
                    : 'text-[var(--hytale-text-secondary)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-tertiary)] border-transparent hover:border-[var(--hytale-border-light)]'
                }`}
              >
                <Camera size={18} className={`transition-transform duration-200 ${currentPage === 'gallery' ? '' : 'group-hover:scale-110'}`} />
                <span className="font-hytale text-sm font-bold uppercase tracking-wide">Gallery</span>
                {screenshots.length > 0 && (
                  <span className="ml-auto badge-hyfx primary">
                    {screenshots.length}
                  </span>
                )}
                {currentPage === 'gallery' && screenshots.length === 0 && <ChevronRight size={14} className="ml-auto" />}
              </button>

              <button
                id="nav-settings"
                onClick={() => setCurrentPage('settings')}
                className={`w-full p-3.5 rounded-md flex items-center gap-3 transition-all duration-200 group border-l-2 ${
                  currentPage === 'settings'
                    ? 'bg-[var(--hytale-bg-nav)] text-[var(--hytale-accent-blue)] border-[var(--hytale-accent-blue)] shadow-[0_0_10px_var(--hytale-glow-blue)]'
                    : 'text-[var(--hytale-text-secondary)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-tertiary)] border-transparent hover:border-[var(--hytale-border-light)]'
                }`}
              >
                <Settings size={18} className={`transition-transform duration-200 ${currentPage === 'settings' ? '' : 'group-hover:scale-110'}`} />
                <span className="font-hytale text-sm font-bold uppercase tracking-wide">Settings</span>
                {currentPage === 'settings' && <ChevronRight size={14} className="ml-auto" />}
              </button>

              {/* Moderation button - only visible to moderators */}
              {isModerator && (
                <button
                  id="nav-moderation"
                  onClick={() => setCurrentPage('moderation')}
                  className={`w-full p-3.5 rounded-md flex items-center gap-3 transition-all duration-200 group border-l-2 ${
                    currentPage === 'moderation'
                      ? 'bg-[var(--hytale-bg-nav)] text-[var(--hytale-accent-blue)] border-[var(--hytale-accent-blue)] shadow-[0_0_10px_var(--hytale-glow-blue)]'
                      : 'text-[var(--hytale-text-secondary)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-tertiary)] border-transparent hover:border-[var(--hytale-border-light)]'
                  }`}
                >
                  <Shield size={18} className={`transition-transform duration-200 ${currentPage === 'moderation' ? '' : 'group-hover:scale-110'}`} />
                  <span className="font-hytale text-sm font-bold uppercase tracking-wide">Moderation</span>
                  {currentPage === 'moderation' && <ChevronRight size={14} className="ml-auto" />}
                </button>
              )}

              {/* Profile button - shows avatar if logged in */}
              <button
                id="nav-profile"
                onClick={() => {
                  setViewingProfileId(currentUserDiscordId);
                  setCurrentPage('profile');
                }}
                className={`w-full p-3.5 rounded-md flex items-center gap-3 transition-all duration-200 group border-l-2 ${
                  currentPage === 'profile'
                    ? 'bg-[var(--hytale-bg-nav)] text-[var(--hytale-accent-blue)] border-[var(--hytale-accent-blue)] shadow-[0_0_10px_var(--hytale-glow-blue)]'
                    : 'text-[var(--hytale-text-secondary)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-tertiary)] border-transparent hover:border-[var(--hytale-border-light)]'
                }`}
              >
                {currentUserInfo ? (
                  <img
                    src={currentUserInfo.avatar_url}
                    alt=""
                    className="w-5 h-5 rounded-full"
                  />
                ) : (
                  <User size={18} className={`transition-transform duration-200 ${currentPage === 'profile' ? '' : 'group-hover:scale-110'}`} />
                )}
                <span className="font-hytale text-sm font-bold uppercase tracking-wide">
                  {currentUserInfo ? currentUserInfo.display_name : 'Profile'}
                </span>
                {currentPage === 'profile' && <ChevronRight size={14} className="ml-auto" />}
              </button>
            </nav>

            {/* Sidebar Footer */}
            <div className="p-4 border-t-2 border-[var(--hytale-border-primary)] space-y-3">
              {/* Status Card */}
              <div className="bg-[var(--hytale-bg-tertiary)] p-4 rounded-md border-2 border-[var(--hytale-border-primary)]">
                <div className="flex items-center gap-3 mb-3">
                  <div className={`w-3 h-3 rounded-full ${validationStatus === 'success' ? 'bg-[var(--hytale-success)] shadow-[0_0_8px_var(--hytale-glow-success)]' : 'bg-[var(--hytale-border-light)]'} ${validationStatus === 'success' ? 'animate-pulse' : ''}`}></div>
                  <span className="text-[var(--hytale-text-primary)] text-xs uppercase font-hytale font-bold tracking-wide">
                    {validationStatus === 'success' ? 'Ready to Play' : 'Setup Required'}
                  </span>
                </div>
                {validationResult?.gshade_installed && (
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-[var(--hytale-text-muted)] font-body">Runtime</span>
                    <span className={validationResult.gshade_enabled ? 'text-[var(--hytale-success)] font-mono' : 'text-[var(--hytale-warning)] font-mono'}>
                      {validationResult.gshade_enabled ? 'Enabled' : 'Disabled'}
                    </span>
                  </div>
                )}
                {!validationResult?.gshade_installed && validationStatus === 'success' && (
                  <p className="text-[var(--hytale-warning)] text-xs font-body">Runtime not installed</p>
                )}
              </div>

              {/* Play Hytale Button - Always visible, disabled when not ready */}
              <button
                onClick={handleLaunchGame}
                disabled={!canLaunchGame}
                className={`w-full p-3 rounded-md flex items-center justify-center gap-2 transition-all duration-200 border-2 ${
                  canLaunchGame
                    ? 'bg-[var(--hytale-accent-blue)] hover:bg-[var(--hytale-accent-blue-hover)] text-[var(--hytale-text-primary)] border-[var(--hytale-accent-blue-hover)] hover:shadow-[0_0_15px_var(--hytale-glow-blue)]'
                    : 'bg-[var(--hytale-bg-tertiary)] text-[var(--hytale-border-light)] border-[var(--hytale-border-primary)] cursor-not-allowed'
                }`}
                title={!canLaunchGame ? (validationStatus !== 'success' ? 'Configure game path first' : 'Install OrbisFX runtime first') : 'Launch Hytale'}
              >
                <Play size={18} className={canLaunchGame ? '' : 'opacity-50'} />
                <span className="font-hytale font-bold text-sm uppercase tracking-wide">Play Hytale</span>
              </button>

              {/* Discord Button */}
              <button
                id="nav-discord"
                onClick={() => shellOpen('https://discord.com/invite/OrbisFX')}
                className="w-full p-3 rounded-md flex items-center justify-center gap-2 bg-[#5865F2] hover:bg-[#4752C4] text-white transition-all duration-200 border-2 border-[#4752C4] hover:shadow-[0_0_15px_rgba(88,101,242,0.3)]"
              >
                <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028 14.09 14.09 0 0 0 1.226-1.994.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z"/>
                </svg>
                <span className="font-hytale font-bold text-sm uppercase tracking-wide">Discord</span>
              </button>
            </div>
          </div>

          {/* Main Content */}
          <main className="flex-1 flex flex-col overflow-hidden bg-[var(--hytale-bg-primary)]">
            {currentPage === 'home' && renderHomePage()}
            {currentPage === 'presets' && renderPresetsPage()}
            {currentPage === 'gallery' && renderGalleryPage()}
            {currentPage === 'settings' && renderSettingsPage()}
            {currentPage === 'moderation' && isModerator && currentUserDiscordId && (
              <div className="flex-1 overflow-y-auto">
                <div className="max-w-6xl mx-auto p-6">
                  <ModerationPanel discordId={currentUserDiscordId} isVisible={true} />
                </div>
              </div>
            )}
            {currentPage === 'profile' && (
              <div className="flex-1 overflow-y-auto">
                <UserProfile
                  currentUser={currentUserInfo}
                  viewingUserId={viewingProfileId}
                  isOwnProfile={viewingProfileId === currentUserDiscordId}
                  onLogin={handleDiscordLogin}
                  onLogout={handleDiscordLogout}
                  onRefreshCommunity={loadCommunityPresets}
                />
              </div>
            )}
          </main>
        </div>
      )}

      {/* Preset Detail Modal - Hytale Style */}
      {selectedPreset && (
        <div
          className="fixed inset-0 bg-[var(--hytale-overlay)] z-50 flex items-center justify-center p-8 backdrop-blur-sm animate-fadeIn"
          onClick={() => setSelectedPreset(null)}
        >
          <div
            className="bg-[var(--hytale-bg-primary)] border-2 border-[var(--hytale-border-primary)] rounded-md max-w-4xl w-full max-h-[90vh] overflow-hidden flex flex-col relative animate-expand-in"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Corner decorations */}
            <div className="corner-tl"></div>
            <div className="corner-tr"></div>
            <div className="corner-bl"></div>
            <div className="corner-br"></div>

            {/* Modal Header */}
            <div className="flex items-center justify-between p-4 border-b-2 border-[var(--hytale-border-primary)]">
              <div>
                <h2 className="font-hytale font-bold text-xl text-[var(--hytale-text-primary)] uppercase tracking-wide">{selectedPreset.name}</h2>
                <p className="text-[var(--hytale-text-muted)] text-sm font-body">by <span className="text-[var(--hytale-accent-blue)]">{selectedPreset.author}</span> • <span className="font-mono">v{selectedPreset.version}</span></p>
              </div>
              <button
                onClick={() => setSelectedPreset(null)}
                className="text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)] transition-colors p-2 hover:bg-[var(--hytale-border-primary)] rounded-md"
              >
                <X size={24} />
              </button>
            </div>

            {/* Modal Content */}
            <div className="flex-1 overflow-y-auto p-6">
              <div className="grid grid-cols-5 gap-6">
                {/* Image Gallery - Left side (3 cols) */}
                <div className="col-span-3">
                  {/* View Toggle - Only show if comparison images are available */}
                  {selectedPreset.vanilla_image && selectedPreset.toggled_image && (
                    <div className="flex gap-2 mb-3">
                      <button
                        onClick={() => setShowComparisonView(false)}
                        className={`flex-1 py-2 px-3 rounded-md font-hytale text-xs uppercase tracking-wide flex items-center justify-center gap-2 transition-all ${
                          !showComparisonView
                            ? 'bg-[var(--hytale-accent-blue)] text-[var(--hytale-text-primary)]'
                            : 'bg-[var(--hytale-bg-tertiary)] border-2 border-[var(--hytale-border-primary)] text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)] hover:border-[var(--hytale-border-light)]'
                        }`}
                      >
                        <Image size={14} /> Gallery
                      </button>
                      <button
                        onClick={() => setShowComparisonView(true)}
                        className={`flex-1 py-2 px-3 rounded-md font-hytale text-xs uppercase tracking-wide flex items-center justify-center gap-2 transition-all ${
                          showComparisonView
                            ? 'bg-[var(--hytale-accent-blue)] text-[var(--hytale-text-primary)]'
                            : 'bg-[var(--hytale-bg-tertiary)] border-2 border-[var(--hytale-border-primary)] text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)] hover:border-[var(--hytale-border-light)]'
                        }`}
                      >
                        <SplitSquareHorizontal size={14} /> Compare
                      </button>
                    </div>
                  )}

                  {/* Comparison Slider View */}
                  {showComparisonView && selectedPreset.vanilla_image && selectedPreset.toggled_image ? (
                    <div className="aspect-video bg-[var(--hytale-bg-tertiary)] rounded-md overflow-hidden mb-3 border-2 border-[var(--hytale-border-primary)]">
                      <ImageComparisonSlider
                        beforeImage={selectedPreset.vanilla_image}
                        afterImage={selectedPreset.toggled_image}
                        beforeLabel="Vanilla"
                        afterLabel="With Preset"
                        className="w-full h-full"
                      />
                    </div>
                  ) : (
                    <>
                      {/* Main Image */}
                      <div className="aspect-video bg-[var(--hytale-bg-tertiary)] rounded-md overflow-hidden mb-3 border-2 border-[var(--hytale-border-primary)]">
                        {(() => {
                          const allImages = [selectedPreset.thumbnail, ...selectedPreset.images];
                          const currentImage = allImages[currentImageIndex] || selectedPreset.thumbnail;
                          return (
                            <CachedImage
                              src={currentImage}
                              alt={selectedPreset.name}
                              className="w-full h-full object-cover"
                            />
                          );
                        })()}
                      </div>

                      {/* Thumbnail Strip */}
                      {selectedPreset.images.length > 0 && (
                        <div className="flex gap-2 overflow-x-auto pb-2">
                          {[selectedPreset.thumbnail, ...selectedPreset.images].map((img, idx) => (
                            <button
                              key={idx}
                              onClick={() => setCurrentImageIndex(idx)}
                              className={`flex-shrink-0 w-20 h-14 rounded-md overflow-hidden border-2 transition-colors ${
                                currentImageIndex === idx
                                  ? 'border-[var(--hytale-accent-blue)] shadow-[var(--hytale-glow-blue)]'
                                  : 'border-[var(--hytale-border-primary)] hover:border-[var(--hytale-border-light)]'
                              }`}
                            >
                              <CachedImage src={img} alt="" className="w-full h-full object-cover" />
                            </button>
                          ))}
                        </div>
                      )}

                      {/* Navigation arrows for slideshow */}
                      {selectedPreset.images.length > 0 && (
                        <div className="flex items-center justify-center gap-4 mt-3">
                          <button
                            onClick={() => setCurrentImageIndex(prev =>
                              prev === 0 ? selectedPreset.images.length : prev - 1
                            )}
                            className="p-2 bg-[var(--hytale-bg-tertiary)] rounded-md border-2 border-[var(--hytale-border-primary)] hover:border-[var(--hytale-border-light)] transition-colors"
                          >
                            <ChevronLeft size={20} className="text-[var(--hytale-text-primary)]" />
                          </button>
                          <span className="text-[var(--hytale-text-muted)] text-sm font-mono">
                            {currentImageIndex + 1} / {selectedPreset.images.length + 1}
                          </span>
                          <button
                            onClick={() => setCurrentImageIndex(prev =>
                              prev === selectedPreset.images.length ? 0 : prev + 1
                            )}
                            className="p-2 bg-[var(--hytale-bg-tertiary)] rounded-md border-2 border-[var(--hytale-border-primary)] hover:border-[var(--hytale-border-light)] transition-colors"
                          >
                            <ChevronRight size={20} className="text-[var(--hytale-text-primary)]" />
                          </button>
                        </div>
                      )}
                    </>
                  )}
                </div>

                {/* Details - Right side (2 cols) */}
                <div className="col-span-2 space-y-4">
                  {/* Category Badge */}
                  <div className="flex items-center gap-2">
                    <span className="badge-hyfx primary capitalize">
                      {selectedPreset.category}
                    </span>
                    {installedPresets.some(ip => ip.id === selectedPreset.id) && (
                      <span className="badge-hyfx success flex items-center gap-1">
                        <CheckCircle size={12} /> Installed
                      </span>
                    )}
                  </div>

                  {/* Description */}
                  <div>
                    <h3 className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm uppercase mb-2 tracking-wide">Description</h3>
                    <p className="text-[var(--hytale-text-secondary)] text-sm leading-relaxed font-body">
                      {selectedPreset.long_description || selectedPreset.description}
                    </p>
                  </div>

                  {/* Features */}
                  {selectedPreset.features && selectedPreset.features.length > 0 && (
                    <div>
                      <h3 className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm uppercase mb-2 tracking-wide">Features</h3>
                      <ul className="space-y-1">
                        {selectedPreset.features.map((feature, idx) => (
                          <li key={idx} className="text-[var(--hytale-text-secondary)] text-sm flex items-center gap-2 font-body">
                            <CheckCircle size={14} className="text-[var(--hytale-success)]" />
                            {feature}
                          </li>
                        ))}
                      </ul>
                    </div>
                  )}

                  {/* Rating Section - Read-only display */}
                  <div className="space-y-3">
                    <h3 className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm uppercase tracking-wide">Rating</h3>

                    {/* Community rating */}
                    <div className="flex items-center gap-3">
                      <span className="text-xs text-[var(--hytale-text-dim)]">Community:</span>
                      <StarRating
                        rating={null}
                        averageRating={presetRatings[selectedPreset.id]?.average_rating}
                        totalRatings={presetRatings[selectedPreset.id]?.total_ratings ?? 0}
                        size={18}
                      />
                    </div>

                    {/* User's rating display */}
                    {myRatings[selectedPreset.id] && (
                      <div className="flex items-center gap-3">
                        <span className="text-xs text-[var(--hytale-text-dim)]">Your rating:</span>
                        <StarRating
                          rating={myRatings[selectedPreset.id]}
                          size={16}
                          showCount={false}
                        />
                      </div>
                    )}
                  </div>

                  {/* Action Buttons */}
                  <div className="pt-4 border-t-2 border-[var(--hytale-border-primary)] space-y-3">
                    {/* Install Button */}
                    <button
                      onClick={() => {
                        handleDownloadPreset(selectedPreset);
                        setSelectedPreset(null);
                      }}
                      disabled={!installPath}
                      className="w-full btn-hyfx-primary py-3 font-hytale font-bold text-[var(--hytale-text-primary)] rounded-md flex items-center justify-center gap-2 disabled:opacity-50"
                    >
                      <Download size={18} />
                      {installedPresets.some(ip => ip.id === selectedPreset.id)
                        ? 'Reinstall Preset'
                        : 'Install Preset'}
                    </button>
                    {!installPath && (
                      <p className="text-[var(--hytale-warning)] text-xs text-center mt-2 font-body">
                        Configure game path in Settings first
                      </p>
                    )}

                    {/* Rate Preset Button */}
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        openRatingModal(selectedPreset);
                      }}
                      className="w-full py-2.5 bg-[var(--hytale-bg-elevated)] hover:bg-[var(--hytale-bg-hover)] border border-[var(--hytale-border-card)] rounded-md flex items-center justify-center gap-2 text-[var(--hytale-text-secondary)] hover:text-[var(--hytale-text-primary)] transition-colors"
                    >
                      <Star size={16} className="text-[var(--hytale-warning-amber)]" />
                      <span className="text-sm font-medium">
                        {myRatings[selectedPreset.id] ? 'Update Rating' : 'Rate Preset'}
                      </span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Community Preset Detail Modal */}
      {selectedCommunityPreset && (
        <div
          className="fixed inset-0 bg-[var(--hytale-overlay)] z-50 flex items-center justify-center p-8 backdrop-blur-sm animate-fadeIn"
          onClick={() => setSelectedCommunityPreset(null)}
        >
          <div
            className="bg-[var(--hytale-bg-primary)] border-2 border-[var(--hytale-border-primary)] rounded-md max-w-4xl w-full max-h-[90vh] overflow-hidden flex flex-col relative animate-expand-in"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="flex items-center justify-between p-4 border-b-2 border-[var(--hytale-border-primary)]">
              <div>
                <h2 className="font-hytale font-bold text-xl text-[var(--hytale-text-primary)] uppercase tracking-wide">{selectedCommunityPreset.name}</h2>
                <p className="text-[var(--hytale-text-muted)] text-sm font-body">
                  by{' '}
                  <button
                    onClick={() => {
                      setViewingProfileId(selectedCommunityPreset.author_discord_id);
                      setCurrentPage('profile');
                      setSelectedCommunityPreset(null);
                    }}
                    className="text-[var(--hytale-accent-blue)] hover:underline"
                  >
                    {selectedCommunityPreset.author_name}
                  </button>
                  {' '}• <span className="font-mono">v{selectedCommunityPreset.version}</span>
                </p>
              </div>
              <button
                onClick={() => setSelectedCommunityPreset(null)}
                className="text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)] transition-colors p-2 hover:bg-[var(--hytale-border-primary)] rounded-md"
              >
                <X size={24} />
              </button>
            </div>

            {/* Modal Body */}
            <div className="flex-1 overflow-y-auto p-4">
              <div className="grid grid-cols-1 lg:grid-cols-5 gap-4">
                {/* Left side - Images */}
                <div className="col-span-3">
                  {/* Check for comparison images (before/after pairs) */}
                  {(() => {
                    const beforeImage = selectedCommunityPreset.images.find(img => img.image_type === 'before');
                    const afterImage = selectedCommunityPreset.images.find(img => img.image_type === 'after');
                    const hasComparison = beforeImage && afterImage;

                    return (
                      <>
                        {/* View Toggle - Only show if comparison images are available */}
                        {hasComparison && (
                          <div className="flex gap-2 mb-3">
                            <button
                              onClick={() => setCommunityShowComparison(false)}
                              className={`flex-1 py-2 px-3 rounded-md font-hytale text-xs uppercase tracking-wide flex items-center justify-center gap-2 transition-all ${
                                !communityShowComparison
                                  ? 'bg-[var(--hytale-accent-blue)] text-white'
                                  : 'bg-[var(--hytale-bg-tertiary)] text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]'
                              }`}
                            >
                              <Image size={14} /> Gallery
                            </button>
                            <button
                              onClick={() => setCommunityShowComparison(true)}
                              className={`flex-1 py-2 px-3 rounded-md font-hytale text-xs uppercase tracking-wide flex items-center justify-center gap-2 transition-all ${
                                communityShowComparison
                                  ? 'bg-[var(--hytale-accent-blue)] text-white'
                                  : 'bg-[var(--hytale-bg-tertiary)] text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]'
                              }`}
                            >
                              <SplitSquareHorizontal size={14} /> Compare
                            </button>
                          </div>
                        )}

                        {/* Comparison Slider View */}
                        {communityShowComparison && hasComparison ? (
                          <div className="aspect-video bg-[var(--hytale-bg-tertiary)] rounded-md overflow-hidden mb-3 border-2 border-[var(--hytale-border-primary)]">
                            <ImageComparisonSlider
                              beforeImage={beforeImage.full_image_url}
                              afterImage={afterImage.full_image_url}
                              beforeLabel="Before"
                              afterLabel="After"
                              className="w-full h-full"
                            />
                          </div>
                        ) : (
                          <>
                            {/* Main Image */}
                            <div className="aspect-video bg-[var(--hytale-bg-tertiary)] rounded-md overflow-hidden mb-3 border-2 border-[var(--hytale-border-primary)]">
                              {(() => {
                                const allImages = selectedCommunityPreset.images.filter(img => img.image_type === 'screenshot' || img.image_type === 'after');
                                const currentImage = allImages[communityImageIndex]?.full_image_url || selectedCommunityPreset.thumbnail_url || selectedCommunityPreset.images[0]?.full_image_url;
                                return currentImage ? (
                                  <img src={currentImage} alt={selectedCommunityPreset.name} className="w-full h-full object-cover" />
                                ) : (
                                  <div className="w-full h-full flex items-center justify-center">
                                    <Sparkles size={48} className="text-[var(--hytale-text-dimmer)]" />
                                  </div>
                                );
                              })()}
                            </div>

                            {/* Thumbnail Strip */}
                            {selectedCommunityPreset.images.length > 1 && (
                              <div className="flex gap-2 overflow-x-auto pb-2">
                                {selectedCommunityPreset.images.filter(img => img.image_type === 'screenshot' || img.image_type === 'after').map((img, idx) => (
                                  <button
                                    key={img.id}
                                    onClick={() => setCommunityImageIndex(idx)}
                                    className={`flex-shrink-0 w-20 h-14 rounded-md overflow-hidden border-2 transition-colors ${
                                      communityImageIndex === idx
                                        ? 'border-[var(--hytale-accent-blue)]'
                                        : 'border-[var(--hytale-border-card)] hover:border-[var(--hytale-border-light)]'
                                    }`}
                                  >
                                    <img src={img.full_image_url} alt="" className="w-full h-full object-cover" />
                                  </button>
                                ))}
                              </div>
                            )}
                          </>
                        )}
                      </>
                    );
                  })()}
                </div>

                {/* Right side - Info */}
                <div className="col-span-2 space-y-4">
                  {/* Category Badge */}
                  <div className="flex items-center gap-2">
                    <span className="badge-hyfx primary capitalize">
                      {selectedCommunityPreset.category}
                    </span>
                    <span className="text-xs text-[var(--hytale-text-dimmer)] flex items-center gap-1">
                      <Download size={12} /> {selectedCommunityPreset.download_count} downloads
                    </span>
                  </div>

                  {/* Rating */}
                  <div className="flex items-center gap-3">
                    <StarRating
                      rating={myRatings[selectedCommunityPreset.id] ?? null}
                      averageRating={presetRatings[selectedCommunityPreset.id]?.average_rating}
                      totalRatings={presetRatings[selectedCommunityPreset.id]?.total_ratings ?? 0}
                      size={16}
                    />
                  </div>

                  {/* Description */}
                  <div>
                    <h3 className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm uppercase mb-2 tracking-wide">Description</h3>
                    <p className="text-[var(--hytale-text-secondary)] text-sm leading-relaxed font-body">
                      {selectedCommunityPreset.long_description || selectedCommunityPreset.description}
                    </p>
                  </div>

                  {/* Created date */}
                  <div className="text-xs text-[var(--hytale-text-dimmer)]">
                    Submitted on {new Date(selectedCommunityPreset.created_at).toLocaleDateString()}
                  </div>

                  {/* Download Button */}
                  <div className="pt-4 border-t border-[var(--hytale-border-card)] space-y-3">
                    <button
                      onClick={async () => {
                        if (!installPath) {
                          setError("Please configure Hytale installation path first.");
                          return;
                        }
                        try {
                          // Generate filename from preset name (sanitize for filesystem)
                          const sanitizedName = selectedCommunityPreset.name
                            .toLowerCase()
                            .replace(/[^a-z0-9]+/g, '-')
                            .replace(/^-|-$/g, '');
                          const destinationPath = `${installPath}\\reshade-presets\\${sanitizedName}.ini`;

                          // Download the preset file
                          await invoke('download_community_preset', {
                            presetId: selectedCommunityPreset.id,
                            presetUrl: selectedCommunityPreset.preset_file_url,
                            destinationPath: destinationPath,
                            presetName: selectedCommunityPreset.name,
                            presetVersion: selectedCommunityPreset.version
                          });
                          // Refresh installed presets
                          await loadInstalledPresets();
                          setSelectedCommunityPreset(null);
                        } catch (e) {
                          console.error('Failed to download community preset:', e);
                          setError(`Failed to install preset: ${e}`);
                        }
                      }}
                      disabled={!installPath}
                      className="w-full btn-hyfx-primary py-3 font-hytale font-bold text-[var(--hytale-text-primary)] rounded-md flex items-center justify-center gap-2 disabled:opacity-50"
                    >
                      <Download size={18} />
                      Install Preset
                    </button>
                    {!installPath && (
                      <p className="text-[var(--hytale-warning)] text-xs text-center mt-2 font-body">
                        Please set your Hytale installation path first
                      </p>
                    )}

                    {/* Rate Button */}
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        openCommunityRatingModal(selectedCommunityPreset);
                      }}
                      className="w-full py-2.5 bg-[var(--hytale-bg-elevated)] hover:bg-[var(--hytale-bg-hover)] border border-[var(--hytale-border-card)] rounded-md flex items-center justify-center gap-2 text-[var(--hytale-text-secondary)] hover:text-[var(--hytale-text-primary)] transition-colors"
                    >
                      <Star size={16} />
                      Rate This Preset
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Rating Modal - supports both official and community presets */}
      {activeRatingPreset && (
        <div
          className="fixed inset-0 bg-[var(--hytale-overlay)] z-[60] flex items-center justify-center p-4 backdrop-blur-sm animate-fadeIn"
          onClick={closeRatingModal}
        >
          <div
            className="bg-[var(--hytale-bg-card)] border-2 border-[var(--hytale-border-primary)] rounded-lg w-full max-w-md overflow-hidden shadow-2xl animate-scaleIn"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header with thumbnail */}
            <div className="relative h-32 bg-[var(--hytale-bg-input)] overflow-hidden">
              {(() => {
                const thumbnailUrl = ratingModalPreset?.thumbnail || ratingModalCommunityPreset?.thumbnail_url;
                return thumbnailUrl ? (
                  <CachedImage
                    src={thumbnailUrl}
                    alt={activeRatingPreset.name}
                    className="w-full h-full object-cover opacity-60"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <Palette size={40} className="text-[var(--hytale-border-hover)]" />
                  </div>
                );
              })()}
              <div className="absolute inset-0 bg-gradient-to-t from-[var(--hytale-bg-card)] to-transparent" />
              <div className="absolute bottom-4 left-4 right-4">
                <h2 className="font-hytale font-bold text-lg text-[var(--hytale-text-primary)] truncate">
                  {activeRatingPreset.name}
                </h2>
                <p className="text-sm text-[var(--hytale-text-dim)]">
                  by {ratingModalPreset?.author || ratingModalCommunityPreset?.author_name}
                </p>
              </div>
              <button
                onClick={closeRatingModal}
                className="absolute top-3 right-3 p-1.5 bg-black/40 rounded-full hover:bg-black/60 transition-colors"
              >
                <X size={16} className="text-white" />
              </button>
            </div>

            {/* Content */}
            <div className="p-6 space-y-6">
              {ratingSuccess ? (
                /* Success State */
                <div className="text-center py-4">
                  <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-[var(--hytale-success)]/20 flex items-center justify-center">
                    <CheckCircle size={32} className="text-[var(--hytale-success)]" />
                  </div>
                  <h3 className="font-hytale font-bold text-lg text-[var(--hytale-text-primary)] mb-2">
                    Thank You!
                  </h3>
                  <p className="text-sm text-[var(--hytale-text-dim)]">
                    Your rating has been submitted successfully.
                  </p>
                </div>
              ) : (
                <>
                  {/* Community Rating */}
                  <div className="text-center">
                    <p className="text-xs text-[var(--hytale-text-dimmer)] uppercase tracking-wide mb-2">
                      Community Rating
                    </p>
                    <div className="flex items-center justify-center gap-2">
                      <StarRating
                        rating={null}
                        averageRating={presetRatings[activeRatingPreset.id]?.average_rating}
                        totalRatings={presetRatings[activeRatingPreset.id]?.total_ratings ?? 0}
                        size={22}
                      />
                    </div>
                  </div>

                  {/* Divider */}
                  <div className="border-t border-[var(--hytale-border-card)]" />

                  {/* Your Rating */}
                  <div className="text-center">
                    <p className="text-xs text-[var(--hytale-text-dimmer)] uppercase tracking-wide mb-3">
                      {myRatings[activeRatingPreset.id] ? 'Update Your Rating' : 'Rate This Preset'}
                    </p>

                    {/* Interactive Stars */}
                    <div className="flex items-center justify-center gap-1 mb-4">
                      {[1, 2, 3, 4, 5].map((star) => (
                        <button
                          key={star}
                          onClick={() => setPendingRating(star)}
                          className="p-1 transition-transform hover:scale-110 focus:outline-none"
                          disabled={ratingSubmitting}
                        >
                          <Star
                            size={36}
                            className={`transition-colors ${
                              star <= pendingRating
                                ? 'fill-[var(--hytale-warning-amber)] text-[var(--hytale-warning-amber)]'
                                : 'text-[var(--hytale-border-card)] hover:text-[var(--hytale-warning-amber)]/50'
                            }`}
                          />
                        </button>
                      ))}
                    </div>

                    {/* Rating Label */}
                    <p className="text-sm text-[var(--hytale-text-secondary)] h-5">
                      {pendingRating === 0 && 'Click a star to rate'}
                      {pendingRating === 1 && 'Poor'}
                      {pendingRating === 2 && 'Fair'}
                      {pendingRating === 3 && 'Good'}
                      {pendingRating === 4 && 'Very Good'}
                      {pendingRating === 5 && 'Excellent!'}
                    </p>
                  </div>

                  {/* Buttons */}
                  <div className="flex gap-3 pt-2">
                    <button
                      onClick={closeRatingModal}
                      className="flex-1 py-2.5 bg-[var(--hytale-bg-elevated)] hover:bg-[var(--hytale-bg-hover)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-secondary)] text-sm font-medium transition-colors"
                      disabled={ratingSubmitting}
                    >
                      Cancel
                    </button>
                    <button
                      onClick={handleSubmitRating}
                      disabled={pendingRating === 0 || ratingSubmitting}
                      className="flex-1 py-2.5 btn-hyfx-primary rounded-md text-[var(--hytale-text-primary)] text-sm font-bold flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                    >
                      {ratingSubmitting ? (
                        <>
                          <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                          Submitting...
                        </>
                      ) : (
                        <>
                          <Star size={16} />
                          Submit Rating
                        </>
                      )}
                    </button>
                  </div>
                </>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Tutorial Modal/Popover */}
      {showTutorial && (() => {
        const currentStep = TUTORIAL_STEPS[tutorialStep];
        const isModal = currentStep.position === 'modal' || !currentStep.anchorId;

        // Get anchor element position for popovers with viewport boundary checking
        const getPopoverStyle = (): React.CSSProperties => {
          if (isModal || !currentStep.anchorId) return {};

          const anchor = document.getElementById(currentStep.anchorId);
          if (!anchor) return {};

          const rect = anchor.getBoundingClientRect();
          const popoverWidth = 320; // max-w-sm is 384px, but content is usually around 320px
          const popoverHeight = 280; // approximate height of popover
          const padding = 16;
          const viewportWidth = window.innerWidth;
          const viewportHeight = window.innerHeight;

          // Calculate initial position (to the right of anchor)
          let left = rect.right + padding;
          let top = rect.top;

          // Check if popover would overflow right edge
          if (left + popoverWidth > viewportWidth - padding) {
            // Position to the left of anchor instead
            left = rect.left - popoverWidth - padding;
            // If still overflowing, center it horizontally
            if (left < padding) {
              left = Math.max(padding, (viewportWidth - popoverWidth) / 2);
            }
          }

          // Check if popover would overflow bottom edge
          if (top + popoverHeight > viewportHeight - padding) {
            // Adjust top position to keep popover in view
            top = Math.max(padding, viewportHeight - popoverHeight - padding);
          }

          // Ensure top is not negative
          if (top < padding) {
            top = padding;
          }

          return {
            position: 'fixed',
            top,
            left,
            transform: 'translateY(0)',
            maxHeight: `calc(100vh - ${padding * 2}px)`,
            overflowY: 'auto',
          };
        };

        // Render centered modal - Hytale Style
        if (isModal) {
          return (
            <div className="fixed inset-0 bg-black/90 flex items-center justify-center z-50 backdrop-blur-sm">
              <div className="bg-[var(--hytale-bg-primary)] rounded-md p-8 max-w-lg w-full mx-4 border-2 border-[var(--hytale-border-primary)] shadow-2xl relative">
                {/* Corner decorations */}
                <div className="corner-tl"></div>
                <div className="corner-tr"></div>
                <div className="corner-bl"></div>
                <div className="corner-br"></div>

                {/* Progress indicator */}
                <div className="flex gap-1 mb-6">
                  {TUTORIAL_STEPS.map((_, idx) => (
                    <div
                      key={idx}
                      className={`flex-1 h-1 rounded-md transition-colors ${
                        idx <= tutorialStep ? 'bg-[var(--hytale-accent-blue)]' : 'bg-[var(--hytale-border-primary)]'
                      }`}
                    />
                  ))}
                </div>

                {/* Step content */}
                <div className="text-center mb-8">
                  <div className="mb-4 flex justify-center">{currentStep.icon}</div>
                  <h3 className="font-hytale font-bold text-2xl text-[var(--hytale-text-primary)] mb-3 uppercase tracking-wide">
                    {currentStep.title}
                  </h3>
                  <p className="text-[var(--hytale-text-secondary)] text-lg leading-relaxed font-body">
                    {currentStep.description}
                  </p>
                </div>

                {/* Step counter */}
                <p className="text-center text-[var(--hytale-text-muted)] text-sm mb-6 font-mono">
                  Step {tutorialStep + 1} of {TUTORIAL_STEPS.length}
                </p>

                {/* Buttons */}
                <div className="flex gap-3">
                  {tutorialStep > 0 ? (
                    <button
                      onClick={handleTutorialBack}
                      className="btn-hyfx-secondary px-4 py-3 rounded-md font-hytale font-bold uppercase tracking-wide flex items-center gap-2"
                    >
                      <ChevronLeft size={18} /> Back
                    </button>
                  ) : (
                    <button
                      onClick={handleTutorialSkip}
                      className="btn-hyfx-secondary px-4 py-3 rounded-md font-hytale font-bold uppercase tracking-wide"
                    >
                      Skip
                    </button>
                  )}
                  <button
                    onClick={handleTutorialNext}
                    className="flex-1 px-4 py-3 btn-hyfx-primary text-[var(--hytale-text-primary)] rounded-md font-hytale font-bold flex items-center justify-center gap-2 uppercase tracking-wide"
                  >
                    {tutorialStep === TUTORIAL_STEPS.length - 1 ? (
                      <>Get Started</>
                    ) : (
                      <>Next <ChevronRight size={18} /></>
                    )}
                  </button>
                </div>
              </div>
            </div>
          );
        }

        // Render popover anchored to element - Hytale Style
        // Get anchor element dimensions for spotlight effect
        const anchorRect = currentStep.anchorId
          ? document.getElementById(currentStep.anchorId)?.getBoundingClientRect()
          : null;

        return (
          <>
            {/* Spotlight overlay - dims everything except the target element */}
            {anchorRect ? (
              <div
                className="fixed inset-0 z-40 pointer-events-auto"
                style={{
                  boxShadow: `0 0 0 9999px rgba(0, 0, 0, 0.85), inset 0 0 0 2px var(--hytale-accent-blue)`,
                  borderRadius: '6px',
                  top: anchorRect.top - 8,
                  left: anchorRect.left - 8,
                  width: anchorRect.width + 16,
                  height: anchorRect.height + 16,
                  position: 'fixed',
                  pointerEvents: 'none',
                }}
              />
            ) : (
              <div className="fixed inset-0 bg-black/85 z-40" />
            )}

            {/* Clickable area outside the spotlight to prevent interaction */}
            <div
              className="fixed inset-0 z-[39]"
              onClick={(e) => e.stopPropagation()}
            />

            {/* Highlight ring around the anchor element */}
            {anchorRect && (
              <div
                className="fixed z-50 ring-2 ring-[var(--hytale-accent-blue)] rounded-md pointer-events-none animate-pulse"
                style={{
                  top: anchorRect.top - 8,
                  left: anchorRect.left - 8,
                  width: anchorRect.width + 16,
                  height: anchorRect.height + 16,
                  boxShadow: 'var(--hytale-glow-blue)',
                }}
              />
            )}

            {/* Popover - Hytale Style */}
            <div
              className="fixed z-50 bg-[var(--hytale-bg-primary)] rounded-md p-6 max-w-sm border-2 border-[var(--hytale-border-primary)] shadow-2xl"
              style={getPopoverStyle()}
            >
              {/* Arrow pointing to anchor */}
              <div
                className="absolute w-3 h-3 bg-[var(--hytale-bg-primary)] border-l-2 border-b-2 border-[var(--hytale-border-primary)] transform -rotate-45"
                style={{ left: -8, top: 20 }}
              />

              {/* Progress indicator */}
              <div className="flex gap-1 mb-4">
                {TUTORIAL_STEPS.map((_, idx) => (
                  <div
                    key={idx}
                    className={`flex-1 h-1 rounded-md transition-colors ${
                      idx <= tutorialStep ? 'bg-[var(--hytale-accent-blue)]' : 'bg-[var(--hytale-border-primary)]'
                    }`}
                  />
                ))}
              </div>

              {/* Step content */}
              <div className="mb-4">
                <div className="flex items-center gap-3 mb-3">
                  <div className="flex-shrink-0">{React.cloneElement(currentStep.icon as React.ReactElement, { size: 28 })}</div>
                  <h3 className="font-hytale font-bold text-lg text-[var(--hytale-text-primary)] uppercase tracking-wide">
                    {currentStep.title}
                  </h3>
                </div>
                <p className="text-[var(--hytale-text-secondary)] text-sm leading-relaxed font-body">
                  {currentStep.description}
                </p>
              </div>

              {/* Step counter */}
              <p className="text-[var(--hytale-text-muted)] text-xs mb-4 font-mono">
                Step {tutorialStep + 1} of {TUTORIAL_STEPS.length}
              </p>

              {/* Buttons */}
              <div className="flex gap-2">
                {tutorialStep > 0 ? (
                  <button
                    onClick={handleTutorialBack}
                    className="btn-hyfx-secondary px-3 py-2 rounded-md text-sm font-hytale font-bold uppercase flex items-center gap-1"
                  >
                    <ChevronLeft size={16} />
                  </button>
                ) : (
                  <button
                    onClick={handleTutorialSkip}
                    className="btn-hyfx-secondary px-3 py-2 rounded-md text-sm font-hytale font-bold uppercase"
                  >
                    Skip
                  </button>
                )}
                <button
                  onClick={handleTutorialNext}
                  className="flex-1 px-3 py-2 btn-hyfx-primary text-[var(--hytale-text-primary)] rounded-md font-hytale font-bold flex items-center justify-center gap-1 text-sm uppercase"
                >
                  {tutorialStep === TUTORIAL_STEPS.length - 1 ? 'Finish' : 'Next'} <ChevronRight size={16} />
                </button>
              </div>
            </div>
          </>
        );
      })()}

      {/* Update Available Modal - Hytale Style */}
      {showUpdateModal && (
        <div className="fixed inset-0 bg-black/90 flex items-center justify-center z-50 backdrop-blur-sm">
          <div className="bg-[var(--hytale-bg-primary)] rounded-md p-8 max-w-md w-full mx-4 border-2 border-[var(--hytale-border-primary)] shadow-2xl relative">
            {/* Corner decorations */}
            <div className="corner-tl"></div>
            <div className="corner-tr"></div>
            <div className="corner-bl"></div>
            <div className="corner-br"></div>

            {/* Header with icon */}
            <div className="flex items-center gap-4 mb-6">
              <div className={`w-14 h-14 ${downloadedUpdatePath ? 'bg-[var(--hytale-success)]/20' : 'bg-[var(--hytale-accent-blue)]/20'} rounded-md flex items-center justify-center flex-shrink-0 border-2 ${downloadedUpdatePath ? 'border-[var(--hytale-success)]/30' : 'border-[var(--hytale-accent-blue)]/30'}`}>
                {downloadedUpdatePath ? (
                  <CheckCircle className="w-7 h-7 text-[var(--hytale-success)]" />
                ) : (
                  <RefreshCw className="w-7 h-7 text-[var(--hytale-accent-blue)]" />
                )}
              </div>
              <div>
                <h3 className="font-hytale font-bold text-xl text-[var(--hytale-text-primary)] uppercase tracking-wide">
                  {downloadedUpdatePath ? 'Update Ready' : 'Update Available'}
                </h3>
                <p className="text-[var(--hytale-text-muted)] text-sm font-body">
                  {downloadedUpdatePath
                    ? 'Update downloaded successfully'
                    : `Version ${latestVersion} is ready to download`}
                </p>
              </div>
            </div>

            {/* Version badge */}
            <div className="bg-[var(--hytale-bg-tertiary)] border-2 border-[var(--hytale-border-primary)] rounded-md p-4 mb-6">
              <div className="flex items-center justify-between">
                <span className="text-[var(--hytale-text-muted)] text-sm font-body">Current version</span>
                <span className="text-[var(--hytale-text-secondary)] font-mono text-sm">v{appVersion}</span>
              </div>
              <div className="flex items-center justify-between mt-2">
                <span className="text-[var(--hytale-text-muted)] text-sm font-body">Latest version</span>
                <span className="text-[var(--hytale-accent-blue)] font-mono text-sm font-bold">v{latestVersion}</span>
              </div>
            </div>

            <p className="text-[var(--hytale-text-secondary)] mb-6 text-sm leading-relaxed font-body">
              {downloadedUpdatePath
                ? 'Click "Install & Restart" to automatically install the update and restart the application.'
                : 'A new version of OrbisFX Launcher is available. Would you like to download it now?'}
            </p>

            {/* Buttons - Different states based on download status */}
            {downloadedUpdatePath ? (
              <div className="flex gap-3">
                <button
                  onClick={handleCloseUpdateModal}
                  className="flex-1 btn-hyfx-secondary px-4 py-3 rounded-md font-hytale font-bold uppercase"
                >
                  Later
                </button>
                <button
                  onClick={handleInstallUpdateAndRestart}
                  disabled={isInstallingUpdate}
                  className="flex-1 px-4 py-3 btn-hyfx-primary text-[var(--hytale-text-primary)] rounded-md font-hytale font-bold flex items-center justify-center gap-2 uppercase"
                >
                  {isInstallingUpdate ? (
                    <>
                      <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                      Installing...
                    </>
                  ) : (
                    <>
                      <Rocket className="w-4 h-4" />
                      Install & Restart
                    </>
                  )}
                </button>
              </div>
            ) : (
              <div className="flex gap-3">
                <button
                  onClick={handleCloseUpdateModal}
                  className="flex-1 btn-hyfx-secondary px-4 py-3 rounded-md font-hytale font-bold uppercase"
                >
                  Later
                </button>
                <button
                  onClick={handleDownloadUpdate}
                  disabled={isDownloadingUpdate}
                  className="flex-1 px-4 py-3 btn-hyfx-primary text-[var(--hytale-text-primary)] rounded-md font-hytale font-bold flex items-center justify-center gap-2 uppercase"
                >
                  {isDownloadingUpdate ? (
                    <>
                      <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                      Downloading...
                    </>
                  ) : (
                    <>
                      <Download className="w-4 h-4" />
                      Download
                    </>
                  )}
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Delete Community Preset Modal (Moderator) */}
      {deleteCommunityModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-[var(--hytale-bg-primary)] border-2 border-[var(--hytale-border-primary)] rounded-lg w-full max-w-md p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-hytale text-lg text-red-400">Delete Community Preset</h3>
              <button
                onClick={() => setDeleteCommunityModalOpen(false)}
                className="text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]"
              >
                <X size={20} />
              </button>
            </div>
            <p className="text-sm text-[var(--hytale-text-muted)] mb-4">
              <strong className="text-red-400">Warning:</strong> This will permanently delete the preset and all associated images. This action cannot be undone.
            </p>
            <textarea
              value={deleteCommunityReason}
              onChange={e => setDeleteCommunityReason(e.target.value)}
              placeholder="Reason for deletion (optional)..."
              className="w-full px-3 py-2 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-primary)] resize-none h-24"
            />
            <div className="flex justify-end gap-2 mt-4">
              <button
                onClick={() => setDeleteCommunityModalOpen(false)}
                className="px-4 py-2 text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]"
              >
                Cancel
              </button>
              <button
                onClick={handleDeleteCommunityPreset}
                disabled={deletingCommunityPreset}
                className="px-4 py-2 bg-red-600 text-white rounded-md font-medium hover:bg-red-700 flex items-center gap-2 disabled:opacity-50"
              >
                {deletingCommunityPreset ? <Loader2 size={14} className="animate-spin" /> : <Trash2 size={14} />}
                Delete Forever
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Submission Wizard Modal */}
      <SubmissionWizard
        isOpen={showSubmissionWizard}
        onClose={() => setShowSubmissionWizard(false)}
        installedPresets={installedPresets.filter(p => p.is_local).map(p => ({
          ...p,
          file_path: p.source_path || '',
          is_local_import: p.is_local
        }))}
        hytalePath={installPath || ''}
        onSubmitSuccess={() => {
          setShowSubmissionWizard(false);
          // Refresh community presets when implemented
        }}
      />
    </div>
  );
};

export default App;
