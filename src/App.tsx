import React, { useState, useEffect, useRef, ReactNode } from 'react';
import {
  FolderOpen, Download, ShieldCheck, CheckCircle, Activity, Settings,
  AlertTriangle, Trash2, Minus, X, Play, Home, Palette, RefreshCw,
  ExternalLink, Search, Filter, ChevronRight, ChevronDown, Power, Gamepad2,
  Star, Upload, Share2, Keyboard, ChevronLeft, Eye, HelpCircle,
  Rocket, MessageCircle, Sparkles, SplitSquareHorizontal, Image,
  Camera, Heart, Copy, Maximize2, Grid, FolderOpen as FolderOpenIcon,
  Clock, HardDrive, ArrowUpDown, ArrowDownAZ, ArrowUpAZ, ArrowDown01, ArrowUp01,
  Sun, Moon, Monitor, LayoutGrid, LayoutList, GalleryHorizontal
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

const appWindow = getCurrentWindow();

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

type Page = 'home' | 'presets' | 'settings' | 'setup' | 'gallery';

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
  const [presetsLoading, setPresetsLoading] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [presetTab, setPresetTab] = useState<'library' | 'public'>('library');

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

  // Screenshot gallery state
  const [screenshots, setScreenshots] = useState<Screenshot[]>([]);
  const [screenshotsLoading, setScreenshotsLoading] = useState(false);
  const [screenshotFilter, setScreenshotFilter] = useState<'all' | 'favorites'>('all');
  const [screenshotPresetFilter, setScreenshotPresetFilter] = useState<string>('all');
  const [screenshotPresets, setScreenshotPresets] = useState<string[]>([]);
  const [fullscreenScreenshot, setFullscreenScreenshot] = useState<Screenshot | null>(null);
  const [screenshotSearchQuery, setScreenshotSearchQuery] = useState('');
  const [screenshotSort, setScreenshotSort] = useState<'date-desc' | 'date-asc' | 'name-asc' | 'name-desc' | 'size-desc' | 'size-asc' | 'preset-asc' | 'preset-desc' | 'favorites'>('date-desc');

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
    try {
      await invoke('reveal_screenshot_in_folder', { screenshotPath });
    } catch (e) {
      console.error('Failed to reveal screenshot:', e);
    }
  };

  const handleDeleteScreenshot = async (screenshot: Screenshot) => {
    if (!confirm(`Delete "${screenshot.filename}"? This cannot be undone.`)) return;
    try {
      const result = await invoke('delete_screenshot', { screenshotPath: screenshot.path }) as { success: boolean; error?: string };
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
    }
    if (currentPage === 'settings') {
      loadHotkeys();
    }
    if (currentPage === 'gallery') {
      loadScreenshots();
    }
  }, [currentPage]);

  // Filter presets
  const filteredPresets = presets.filter(p => {
    const matchesCategory = selectedCategory === 'all' || p.category === selectedCategory;
    const matchesSearch = p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         p.author.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const categories = ['all', ...new Set(presets.map(p => p.category))];

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
        {/* Hero Section - Keep tech corners here as main feature */}
        <div className="card-hyfx p-6 lg:p-8 relative overflow-hidden">
          {/* Tech corner decorations - kept for hero */}
          <div className="corner-tl"></div>
          <div className="corner-tr"></div>
          <div className="corner-bl"></div>
          <div className="corner-br"></div>

          <div className="flex items-start lg:items-center gap-5 lg:gap-6 relative z-10 flex-col lg:flex-row">
            <div className="w-16 h-16 lg:w-20 lg:h-20 bg-[var(--hytale-bg-input)] rounded-lg p-3 border border-[var(--hytale-border-card)] flex-shrink-0">
              <img src="/logo.png" alt="OrbisFX Logo" className="w-full h-full object-contain" />
            </div>
            <div className="flex-1 w-full">
              <h1 className="font-hytale font-black text-2xl lg:text-3xl text-[var(--hytale-text-primary)] mb-1">Welcome to OrbisFX</h1>
              <p className="text-[var(--hytale-text-dim)] text-sm mb-4">Advanced graphics enhancement for Hytale</p>

              {validationStatus === 'success' ? (
                <div className="space-y-3">
                  <div className="flex flex-wrap gap-2">
                    <button
                      onClick={handleLaunchGame}
                      disabled={!canLaunchGame}
                      className={`px-5 py-2.5 font-medium text-sm text-[var(--hytale-text-primary)] rounded-md flex items-center gap-2 transition-colors ${
                        canLaunchGame
                          ? 'bg-[var(--hytale-accent-blue)] hover:bg-[var(--hytale-accent-blue-hover)]'
                          : 'bg-[var(--hytale-border-hover)] cursor-not-allowed opacity-60'
                      }`}
                    >
                      <Play size={18} /> Launch Hytale
                    </button>
                    {validationResult?.gshade_installed && (
                      <button
                        onClick={() => handleToggleRuntime(!validationResult?.gshade_enabled)}
                        className={`px-3 py-2.5 rounded-md flex items-center gap-2 text-sm transition-colors ${
                          validationResult?.gshade_enabled
                            ? 'text-[var(--hytale-success)] hover:bg-[var(--hytale-success-dim)]'
                            : 'text-[var(--hytale-warning)] hover:bg-[var(--hytale-warning)]/10'
                        }`}
                      >
                        <Power size={16} />
                        {validationResult?.gshade_enabled ? 'Enabled' : 'Disabled'}
                      </button>
                    )}
                  </div>
                  {!validationResult?.gshade_installed && (
                    <div className="flex items-center gap-2 text-[var(--hytale-warning)] text-sm">
                      <AlertTriangle size={14} />
                      <span>Runtime not installed. <button onClick={handleInstallRuntime} className="underline hover:brightness-110">Install now</button></span>
                    </div>
                  )}
                </div>
              ) : (
                <button
                  onClick={() => setCurrentPage('settings')}
                  className="px-4 py-2.5 bg-[var(--hytale-bg-elevated)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-muted)] text-sm flex items-center gap-2 hover:bg-[var(--hytale-bg-hover)] hover:text-[var(--hytale-text-primary)] transition-colors"
                >
                  <Settings size={16} /> Configure Game Path
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Status Cards - Simplified */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
          {/* Game Status */}
          <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-4">
            <div className="flex items-center justify-between mb-2">
              <Gamepad2 size={18} className="text-[var(--hytale-accent-blue)]" />
              <div className={`w-2 h-2 rounded-full ${validationStatus === 'success' ? 'bg-[var(--hytale-success)]' : 'bg-[var(--hytale-text-faint)]'}`}></div>
            </div>
            <span className="text-[var(--hytale-text-dim)] text-xs">Game Status</span>
            <p className={`text-sm font-medium mt-0.5 ${validationStatus === 'success' ? 'text-[var(--hytale-success)]' : 'text-[var(--hytale-text-muted)]'}`}>
              {validationStatus === 'success' ? 'Ready to play' : 'Not configured'}
            </p>
          </div>

          {/* Runtime Status */}
          <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-4">
            <div className="flex items-center justify-between mb-2">
              <ShieldCheck size={18} className="text-[var(--hytale-accent-blue)]" />
              <div className={`w-2 h-2 rounded-full ${validationResult?.gshade_installed ? (validationResult?.gshade_enabled ? 'bg-[var(--hytale-success)]' : 'bg-[var(--hytale-warning)]') : 'bg-[var(--hytale-text-faint)]'}`}></div>
            </div>
            <span className="text-[var(--hytale-text-dim)] text-xs">Runtime</span>
            <p className={`text-sm font-medium mt-0.5 ${validationResult?.gshade_installed ? (validationResult?.gshade_enabled ? 'text-[var(--hytale-success)]' : 'text-[var(--hytale-warning)]') : 'text-[var(--hytale-text-muted)]'}`}>
              {validationResult?.gshade_installed
                ? (validationResult?.gshade_enabled ? 'Enabled' : 'Disabled')
                : 'Not installed'}
            </p>
          </div>

          {/* Updates */}
          <div
            className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-4 cursor-pointer hover:border-[var(--hytale-border-hover)] transition-colors"
            onClick={() => updateAvailable && setShowUpdateModal(true)}
          >
            <div className="flex items-center justify-between mb-2">
              <RefreshCw size={18} className="text-[var(--hytale-accent-blue)]" />
              {updateAvailable && <span className="text-[var(--hytale-warning)] text-xs">New</span>}
            </div>
            <span className="text-[var(--hytale-text-dim)] text-xs">Updates</span>
            <p className={`text-sm font-medium mt-0.5 ${updateAvailable ? 'text-[var(--hytale-warning)]' : 'text-[var(--hytale-success)]'}`}>
              {updateAvailable ? `v${latestVersion} available` : 'Up to date'}
            </p>
          </div>
        </div>

        {/* Quick Actions - Simplified */}
        <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-5">
          <h2 className="text-[var(--hytale-text-primary)] text-sm font-medium mb-4">Quick Actions</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <button
              onClick={() => setCurrentPage('presets')}
              className="bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-lg p-4 text-left hover:border-[var(--hytale-border-hover)] transition-colors group"
            >
              <div className="flex items-center gap-3">
                <Palette size={20} className="text-[var(--hytale-accent-blue)]" />
                <div className="flex-1">
                  <p className="text-[var(--hytale-text-primary)] text-sm">Browse Presets</p>
                  <p className="text-[var(--hytale-text-dimmer)] text-xs mt-0.5">Explore community presets</p>
                </div>
                <ChevronRight size={16} className="text-[var(--hytale-text-faint)] group-hover:text-[var(--hytale-text-dim)] transition-colors" />
              </div>
            </button>

            {validationResult?.gshade_installed ? (
              <button
                onClick={handleUninstallRuntime}
                disabled={isInstalling}
                className="bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-lg p-4 text-left hover:border-[var(--hytale-border-hover)] transition-colors group disabled:opacity-50"
              >
                <div className="flex items-center gap-3">
                  <Trash2 size={20} className="text-[var(--hytale-error)]" />
                  <div className="flex-1">
                    <p className="text-[var(--hytale-text-primary)] text-sm">Uninstall OrbisFX</p>
                    <p className="text-[var(--hytale-text-dimmer)] text-xs mt-0.5">Remove runtime from game</p>
                  </div>
                  <ChevronRight size={16} className="text-[var(--hytale-text-faint)] group-hover:text-[var(--hytale-text-dim)] transition-colors" />
                </div>
              </button>
            ) : (
              <button
                onClick={handleInstallRuntime}
                disabled={isInstalling || validationStatus !== 'success'}
                className="bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-lg p-4 text-left hover:border-[var(--hytale-border-hover)] transition-colors group disabled:opacity-50"
              >
                <div className="flex items-center gap-3">
                  <Download size={20} className="text-[var(--hytale-accent-blue)]" />
                  <div className="flex-1">
                    <p className="text-[var(--hytale-text-primary)] text-sm">Install OrbisFX</p>
                    <p className="text-[var(--hytale-text-dimmer)] text-xs mt-0.5">Set up graphics runtime</p>
                  </div>
                  <ChevronRight size={16} className="text-[var(--hytale-text-faint)] group-hover:text-[var(--hytale-text-dim)] transition-colors" />
                </div>
              </button>
            )}
          </div>
        </div>

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

      <div className="max-w-5xl mx-auto space-y-5">
        {/* Page Header - Clean */}
        <header className="mb-2">
          <h1 className="font-hytale font-black text-2xl text-[var(--hytale-text-primary)] uppercase tracking-wide">Presets</h1>
          <p className="text-[var(--hytale-text-dim)] text-sm font-body mt-1">Manage your installed presets and discover new ones</p>
        </header>

        {/* Tab Switcher - Clean */}
        <div className="flex gap-1 bg-[var(--hytale-bg-input)] p-1 rounded-lg">
          <button
            onClick={() => setPresetTab('library')}
            className={`flex-1 py-2.5 px-4 rounded-md text-sm flex items-center justify-center gap-2 transition-colors ${
              presetTab === 'library'
                ? 'bg-[var(--hytale-bg-card)] text-[var(--hytale-text-primary)]'
                : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)]'
            }`}
          >
            <CheckCircle size={14} />
            My Library
            {installedPresets.length > 0 && (
              <span className="text-xs text-[var(--hytale-accent-blue)]">({installedPresets.length})</span>
            )}
          </button>
          <button
            onClick={() => setPresetTab('public')}
            className={`flex-1 py-2.5 px-4 rounded-md text-sm flex items-center justify-center gap-2 transition-colors ${
              presetTab === 'public'
                ? 'bg-[var(--hytale-bg-card)] text-[var(--hytale-text-primary)]'
                : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)]'
            }`}
          >
            <Sparkles size={14} />
            Public Presets
            {presets.length > 0 && (
              <span className="text-xs text-[var(--hytale-accent-blue)]">({presets.length})</span>
            )}
          </button>
        </div>

        {/* My Library Tab Content */}
        {presetTab === 'library' && (
          <>
            {/* Search and Import Bar - Clean */}
            <div className="flex flex-col lg:flex-row gap-3">
              <div className="flex-1 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md flex items-center px-3 focus-within:border-[var(--hytale-accent-blue)] transition-colors">
                <Search size={16} className="text-[var(--hytale-text-dimmer)]" />
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
                    className="p-1 text-[var(--hytale-text-dimmer)] hover:text-[var(--hytale-text-primary)] transition-colors"
                  >
                    <X size={14} />
                  </button>
                )}
              </div>
              {/* Layout Toggle */}
              <div className="flex gap-1 bg-[var(--hytale-bg-input)] rounded-md p-1">
                {([
                  { value: 'rows', icon: LayoutList },
                  { value: 'grid', icon: LayoutGrid },
                ] as const).map(({ value, icon: Icon }) => (
                  <button
                    key={value}
                    onClick={() => saveSettings({ ...settings, presets_layout: value })}
                    className={`p-2 rounded transition-all ${
                      (settings.presets_layout || 'grid') === value
                        ? 'bg-[var(--hytale-bg-card)] text-[var(--hytale-accent-blue)]'
                        : 'text-[var(--hytale-text-dimmer)] hover:text-[var(--hytale-text-primary)]'
                    }`}
                  >
                    <Icon size={16} />
                  </button>
                ))}
              </div>
              <button
                onClick={handleImportPreset}
                disabled={!installPath}
                className="px-4 py-2.5 bg-[var(--hytale-bg-elevated)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-muted)] text-sm flex items-center gap-2 disabled:opacity-50 hover:bg-[var(--hytale-bg-hover)] hover:text-[var(--hytale-text-primary)] transition-colors"
              >
                <Upload size={14} /> Import Preset
              </button>
            </div>

            {/* Installed Presets Grid */}
            <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-5">

          {(() => {
              // Filter installed presets by search query
              const filteredInstalled = installedPresets.filter(p =>
                p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                p.filename.toLowerCase().includes(searchQuery.toLowerCase())
              );

              if (filteredInstalled.length === 0 && installedPresets.length === 0) {
                return (
                  <div className="text-center py-10">
                    <Upload size={24} className="text-[var(--hytale-text-dimmer)] mx-auto mb-3" />
                    <p className="text-[var(--hytale-text-muted)] text-sm">No presets installed yet</p>
                    <p className="text-[var(--hytale-text-dimmer)] text-xs mt-1">Browse Public Presets or import your own</p>
                    <button
                      onClick={() => setPresetTab('public')}
                      className="px-4 py-2 mt-4 bg-[var(--hytale-accent-blue)] text-[var(--hytale-text-primary)] text-sm rounded-md hover:bg-[var(--hytale-accent-blue-hover)] transition-colors"
                    >
                      Browse Public Presets
                    </button>
                  </div>
                );
              }

              if (filteredInstalled.length === 0) {
                return (
                  <div className="text-center py-10">
                    <Search size={24} className="text-[var(--hytale-text-dimmer)] mx-auto mb-3" />
                    <p className="text-[var(--hytale-text-muted)] text-sm">No matching presets</p>
                    <p className="text-[var(--hytale-text-dimmer)] text-xs mt-1">Try a different search term</p>
                  </div>
                );
              }

              const sortedPresets = [...filteredInstalled].sort((a, b) => {
                if (a.is_favorite && !b.is_favorite) return -1;
                if (!a.is_favorite && b.is_favorite) return 1;
                return a.name.localeCompare(b.name);
              });

              const isGridLayout = (settings.presets_layout || 'grid') === 'grid';

              return (
                <div className={isGridLayout ? 'grid grid-cols-2 lg:grid-cols-3 gap-3' : 'space-y-2'}>
                  {sortedPresets.map((preset, index) => (
                    <div
                      key={preset.id}
                      className={`relative bg-[var(--hytale-bg-input)] border rounded-lg cursor-pointer transition-all duration-200 hover:-translate-y-0.5 animate-fade-in-up ${
                        preset.is_active
                          ? 'border-[var(--hytale-success)]/40'
                          : 'border-[var(--hytale-border-card)] hover:border-[var(--hytale-border-hover)]'
                      } ${isGridLayout ? 'p-3' : 'p-4'}`}
                      style={{ animationDelay: `${Math.min(index * 0.05, 0.25)}s` }}
                      onClick={() => !preset.is_active && handleActivatePreset(preset.id)}
                    >
                      {/* Active indicator */}
                      {preset.is_active && (
                        <div className="absolute left-0 top-1/2 -translate-y-1/2 w-0.5 h-8 bg-[var(--hytale-success)] rounded-r"></div>
                      )}

                      <div className={isGridLayout ? '' : 'flex items-start justify-between'}>
                        <div className={isGridLayout ? '' : 'flex-1 pl-2'}>
                          <div className="flex items-center gap-2 mb-1">
                            <h3 className={`font-medium text-[var(--hytale-text-primary)] ${isGridLayout ? 'text-xs truncate' : 'text-sm'}`}>{preset.name}</h3>
                            {preset.is_active && (
                              <span className="text-[var(--hytale-success)] text-xs shrink-0">Active</span>
                            )}
                          </div>
                          <div className={`flex items-center gap-2 text-xs text-[var(--hytale-text-dimmer)] ${isGridLayout ? 'flex-wrap' : 'gap-3'}`}>
                            <span>v{preset.version}</span>
                            {preset.is_local && (
                              <span className="text-[var(--hytale-accent-blue)]">Local</span>
                            )}
                            {!isGridLayout && (
                              <span className="truncate max-w-[200px]">{preset.filename}</span>
                            )}
                          </div>
                        </div>

                        {!isGridLayout && (
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleToggleFavorite(preset.id);
                            }}
                            className={`p-1.5 rounded transition-colors ${
                              preset.is_favorite
                                ? 'text-[var(--hytale-favorite)]'
                                : 'text-[var(--hytale-text-faint)] hover:text-[var(--hytale-favorite)]'
                            }`}
                          >
                            <Star size={16} fill={preset.is_favorite ? 'currentColor' : 'none'} />
                          </button>
                        )}
                      </div>

                      {/* Actions */}
                      <div className={`flex items-center gap-1 border-t border-[var(--hytale-border-card)] ${isGridLayout ? 'mt-2 pt-2' : 'mt-3 pt-3'}`}>
                        {isGridLayout ? (
                          <>
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                handleToggleFavorite(preset.id);
                              }}
                              className={`p-1 rounded transition-colors ${
                                preset.is_favorite
                                  ? 'text-[var(--hytale-favorite)]'
                                  : 'text-[var(--hytale-text-faint)] hover:text-[var(--hytale-favorite)]'
                              }`}
                            >
                              <Star size={12} fill={preset.is_favorite ? 'currentColor' : 'none'} />
                            </button>
                            <div className="flex-1"></div>
                            {!preset.is_active && (
                              <button
                                onClick={(e) => {
                                  e.stopPropagation();
                                  handleActivatePreset(preset.id);
                                }}
                                className="px-2 py-1 bg-[var(--hytale-accent-blue)] text-[var(--hytale-text-primary)] text-xs rounded flex items-center gap-1 hover:bg-[var(--hytale-accent-blue-hover)] transition-colors"
                              >
                                <Play size={10} />
                              </button>
                            )}
                          </>
                        ) : (
                          <>
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                handleExportPreset(preset.id, preset.filename);
                              }}
                              className="px-2 py-1 text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)] text-xs flex items-center gap-1 transition-colors"
                            >
                              <Download size={12} /> Export
                            </button>
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                handleDeletePreset(preset.id);
                              }}
                              className="px-2 py-1 text-[var(--hytale-text-dimmer)] hover:text-[var(--hytale-error)] text-xs flex items-center gap-1 transition-colors"
                            >
                              <Trash2 size={12} /> Remove
                            </button>
                            <div className="flex-1"></div>
                            {!preset.is_active && (
                              <button
                                onClick={(e) => {
                                  e.stopPropagation();
                                  handleActivatePreset(preset.id);
                                }}
                                className="px-3 py-1 bg-[var(--hytale-accent-blue)] text-[var(--hytale-text-primary)] text-xs rounded flex items-center gap-1 hover:bg-[var(--hytale-accent-blue-hover)] transition-colors"
                              >
                                <Play size={12} /> Activate
                              </button>
                            )}
                          </>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              );
            })()}
            </div>
          </>
        )}

        {/* Public Presets Tab Content */}
        {presetTab === 'public' && (
          <>
            {/* Search and Filter Bar - Clean */}
            <div className="flex flex-col lg:flex-row gap-3">
              <div className="flex-1 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md flex items-center px-3 focus-within:border-[var(--hytale-accent-blue)] transition-colors">
                <Search size={16} className="text-[var(--hytale-text-dimmer)]" />
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Search community presets..."
                  className="bg-transparent w-full py-2.5 px-3 text-[var(--hytale-text-primary)] outline-none placeholder-[var(--hytale-text-faint)] text-sm"
                />
                {searchQuery && (
                  <button
                    onClick={() => setSearchQuery('')}
                    className="p-1 text-[var(--hytale-text-dimmer)] hover:text-[var(--hytale-text-primary)] transition-colors"
                  >
                    <X size={14} />
                  </button>
                )}
              </div>
              <div className="flex gap-1 bg-[var(--hytale-bg-input)] rounded-md p-1 overflow-x-auto">
                {categories.map(cat => (
                  <button
                    key={cat}
                    onClick={() => setSelectedCategory(cat)}
                    className={`px-3 py-1.5 rounded text-xs capitalize transition-colors whitespace-nowrap ${
                      selectedCategory === cat
                        ? 'bg-[var(--hytale-bg-card)] text-[var(--hytale-text-primary)]'
                          : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)]'
                      }`}
                    >
                      {cat}
                    </button>
                  ))}
                </div>
            </div>

            {presetsLoading ? (
              <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-12 text-center">
                <div className="w-10 h-10 rounded-full border-2 border-[var(--hytale-border-card)] border-t-[var(--hytale-accent-blue)] animate-spin mx-auto"></div>
                <p className="text-[var(--hytale-text-dim)] text-sm mt-4">Loading presets...</p>
              </div>
            ) : filteredPresets.length === 0 ? (
              <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-12 text-center">
                <Palette size={32} className="text-[var(--hytale-text-faint)] mx-auto mb-3" />
                <p className="text-[var(--hytale-text-muted)] text-sm">No presets found</p>
                <p className="text-[var(--hytale-text-dimmer)] text-xs mt-1">Try a different search term</p>
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
                      className={`bg-[var(--hytale-bg-card)] border rounded-lg overflow-hidden cursor-pointer transition-all duration-200 hover:-translate-y-0.5 hover:shadow-lg animate-fade-in-up ${
                        isInstalled
                          ? 'border-[var(--hytale-success)]/30 hover:border-[var(--hytale-success)]/40'
                          : 'border-[var(--hytale-border-card)] hover:border-[var(--hytale-border-hover)]'
                      }`}
                      style={{ animationDelay: `${Math.min(index * 0.05, 0.3)}s` }}
                      onClick={() => {
                        setSelectedPreset(preset);
                        setCurrentImageIndex(0);
                        setShowComparisonView(false);
                      }}
                    >
                      {/* Thumbnail */}
                      <div className="h-36 bg-[var(--hytale-bg-input)] relative overflow-hidden">
                        {preset.thumbnail ? (
                          <CachedImage
                            src={preset.thumbnail}
                            alt={preset.name}
                            className="w-full h-full object-cover"
                          />
                        ) : (
                          <div className="w-full h-full flex items-center justify-center">
                            <Palette size={32} className="text-[var(--hytale-border-hover)]" />
                          </div>
                        )}

                        {/* Category badge */}
                        <div className="absolute top-2 left-2 px-2 py-1 rounded bg-black/60 text-white text-xs">
                          {preset.category}
                        </div>

                        {/* Status badges */}
                        {isInstalled && !hasUpdate && (
                          <div className="absolute top-2 right-2 px-2 py-1 rounded bg-[var(--hytale-success)]/80 text-white text-xs flex items-center gap-1">
                            <CheckCircle size={10} /> Installed
                          </div>
                        )}
                        {hasUpdate && (
                          <div className="absolute top-2 right-2 px-2 py-1 rounded bg-[var(--hytale-warning-amber)]/80 text-[var(--hytale-bg-primary)] text-xs flex items-center gap-1">
                            <RefreshCw size={10} /> Update
                          </div>
                        )}
                      </div>

                      {/* Info */}
                      <div className="p-4">
                        <div className="flex justify-between items-start mb-2">
                          <div className="flex-1 min-w-0">
                            <h3 className="font-medium text-[var(--hytale-text-primary)] text-sm truncate">{preset.name}</h3>
                            <p className="text-[var(--hytale-text-dimmer)] text-xs mt-0.5">by {preset.author}</p>
                          </div>
                          <span className="text-[var(--hytale-accent-blue)] text-xs ml-2">v{preset.version}</span>
                        </div>
                        <p className="text-[var(--hytale-text-dim)] text-xs mb-3 line-clamp-2">{preset.description}</p>

                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            handleDownloadPreset(preset);
                          }}
                          disabled={!installPath}
                          className={`w-full py-2 text-xs text-[var(--hytale-text-primary)] rounded flex items-center justify-center gap-1.5 disabled:opacity-50 transition-colors ${
                            isInstalled
                              ? 'bg-[var(--hytale-bg-elevated)] hover:bg-[var(--hytale-bg-hover)]'
                              : 'bg-[var(--hytale-accent-blue)] hover:bg-[var(--hytale-accent-blue-hover)]'
                          }`}
                        >
                          <Download size={12} /> {isInstalled ? (hasUpdate ? 'Update' : 'Reinstall') : 'Install'}
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );

  // ============== Render Settings Page ==============
  const renderSettingsPage = () => (
    <div className="flex-1 p-6 lg:p-8 overflow-y-auto">
      {/* Film grain overlay */}
      <div className="grain-overlay"></div>

      <div className="max-w-3xl mx-auto space-y-5">
        {/* Page Header - Clean */}
        <header className="mb-2">
          <h1 className="font-hytale font-black text-2xl text-[var(--hytale-text-primary)] uppercase tracking-wide">Settings</h1>
          <p className="text-[var(--hytale-text-dim)] text-sm font-body mt-1">Configure OrbisFX and manage your installation</p>
        </header>

        {/* Game Path */}
        <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-5 hover:border-[var(--hytale-border-hover)] transition-colors">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-9 h-9 rounded-md bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
              <FolderOpen size={18} className="text-[var(--hytale-accent-blue)]" />
            </div>
            <div>
              <span className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm">Game Installation Path</span>
              <p className="text-[var(--hytale-text-dimmer)] text-xs font-body">Location of your Hytale client</p>
            </div>
          </div>
          <div className="flex gap-3">
            <input
              type="text"
              value={installPath}
              onChange={(e) => setInstallPath(e.target.value)}
              placeholder="Select Hytale installation folder..."
              className="flex-1 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md px-4 py-2.5 text-[var(--hytale-text-primary)] text-sm font-mono placeholder-[var(--hytale-text-faint)] focus:border-[var(--hytale-accent-blue)] focus:outline-none transition-colors"
            />
            <button
              onClick={handleBrowse}
              className="px-4 py-2.5 bg-[var(--hytale-bg-elevated)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-muted)] text-sm font-medium flex items-center gap-2 hover:bg-[var(--hytale-bg-hover)] hover:text-[var(--hytale-text-primary)] transition-colors"
            >
              <FolderOpen size={16} /> Browse
            </button>
          </div>
          {validationStatus === 'success' && (
            <div className="flex items-center gap-2 mt-3 text-[var(--hytale-success)] text-sm font-body">
              <CheckCircle size={14} /> Hytale installation detected
            </div>
          )}
          {validationStatus === 'error' && installPath && (
            <div className="flex items-center gap-2 mt-3 text-[var(--hytale-error)] text-sm font-body">
              <AlertTriangle size={14} /> Invalid path - Hytale.exe not found
            </div>
          )}
        </div>

        {/* Runtime Toggle */}
        <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-5 hover:border-[var(--hytale-border-hover)] transition-colors">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-md bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
                <Power size={18} className={validationResult?.gshade_enabled ? 'text-[var(--hytale-success)]' : 'text-[var(--hytale-accent-blue)]'} />
              </div>
              <div>
                <span className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm">Runtime Status</span>
                <p className="text-[var(--hytale-text-dimmer)] text-xs font-body">Toggle graphics enhancements on/off</p>
              </div>
            </div>
            {validationResult?.gshade_installed ? (
              <button
                onClick={() => handleToggleRuntime(!validationResult?.gshade_enabled)}
                className={`relative w-14 h-7 rounded-full transition-colors ${
                  validationResult?.gshade_enabled ? 'bg-[var(--hytale-success)]' : 'bg-[var(--hytale-border-card)]'
                }`}
              >
                <div className={`absolute top-0.5 w-6 h-6 bg-white rounded-full shadow transition-transform ${
                  validationResult?.gshade_enabled ? 'translate-x-7' : 'translate-x-0.5'
                }`} />
              </button>
            ) : (
              <span className="text-[var(--hytale-text-dimmer)] text-xs font-body">Not installed</span>
            )}
          </div>
        </div>

        {/* Runtime Installation */}
        <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-5 hover:border-[var(--hytale-border-hover)] transition-colors">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-9 h-9 rounded-md bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
              <Download size={18} className="text-[var(--hytale-accent-blue)]" />
            </div>
            <div>
              <span className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm">OrbisFX Installation</span>
              <p className="text-[var(--hytale-text-dimmer)] text-xs font-body">
                {validationResult?.gshade_installed ? 'Runtime is installed' : 'Install graphics runtime'}
              </p>
            </div>
          </div>
          <p className="text-[var(--hytale-text-dim)] text-sm mb-4 font-body">
            {validationResult?.gshade_installed
              ? 'OrbisFX runtime is currently installed. You can reinstall to update or repair.'
              : 'Install the OrbisFX runtime to enable graphics enhancements.'}
          </p>
          <div className="flex flex-wrap gap-2">
            <button
              onClick={handleInstallRuntime}
              disabled={isInstalling || validationStatus !== 'success'}
              className="px-4 py-2 text-sm text-[var(--hytale-text-primary)] rounded-md flex items-center gap-2 disabled:opacity-50 bg-[var(--hytale-accent-blue)] hover:bg-[var(--hytale-accent-blue-hover)] transition-colors"
            >
              <Download size={14} /> {validationResult?.gshade_installed ? 'Reinstall' : 'Install'} OrbisFX
            </button>
            {validationResult?.gshade_installed && (
              <button
                onClick={handleUninstallRuntime}
                disabled={isInstalling}
                className="px-4 py-2 text-sm rounded-md flex items-center gap-2 disabled:opacity-50 text-[var(--hytale-error)] hover:bg-[var(--hytale-error)]/10 transition-colors"
              >
                <Trash2 size={14} /> Uninstall
              </button>
            )}
          </div>
        </div>

        {/* Hotkeys */}
        {hotkeys && validationResult?.gshade_installed && (
          <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-5 hover:border-[var(--hytale-border-hover)] transition-colors">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-9 h-9 rounded-md bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
                <Keyboard size={18} className="text-[var(--hytale-accent-blue)]" />
              </div>
              <div>
                <span className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm">GShade Hotkeys</span>
                <p className="text-[var(--hytale-text-dimmer)] text-xs font-body">Configure shortcuts in-game via GShade overlay</p>
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
              {[
                { label: 'Toggle Effects', key: hotkeys.key_effects },
                { label: 'Toggle Overlay', key: hotkeys.key_overlay },
                { label: 'Screenshot', key: hotkeys.key_screenshot },
                { label: 'Next Preset', key: hotkeys.key_next_preset },
                { label: 'Previous Preset', key: hotkeys.key_prev_preset },
              ].map((item, idx) => (
                <div key={idx} className="flex items-center justify-between bg-[var(--hytale-bg-input)] rounded-md px-3 py-2">
                  <span className="text-[var(--hytale-text-dim)] text-sm font-body">{item.label}</span>
                  <kbd className="bg-[var(--hytale-bg-elevated)] text-[var(--hytale-accent-blue)] text-xs px-2 py-1 rounded font-mono">{item.key}</kbd>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Updates */}
        <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-5 hover:border-[var(--hytale-border-hover)] transition-colors">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-md bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
                <RefreshCw size={18} className={updateAvailable ? 'text-[var(--hytale-warning)]' : 'text-[var(--hytale-accent-blue)]'} />
              </div>
              <div>
                <span className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm">Updates</span>
                <p className="text-[var(--hytale-text-dimmer)] text-xs font-mono">
                  v{appVersion} {updateAvailable && <span className="text-[var(--hytale-warning)]">→ v{latestVersion}</span>}
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              {updateAvailable && (
                <button
                  onClick={() => setShowUpdateModal(true)}
                  className="px-3 py-1.5 rounded-md text-xs flex items-center gap-1.5 bg-[var(--hytale-warning-amber)] text-[var(--hytale-bg-primary)] hover:brightness-110 transition-colors"
                >
                  <Download size={12} /> Update
                </button>
              )}
              <button
                onClick={checkForUpdates}
                className="px-3 py-1.5 rounded-md text-xs flex items-center gap-1.5 text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-elevated)] transition-colors"
              >
                <RefreshCw size={12} /> Check
              </button>
            </div>
          </div>
        </div>

        {/* Tutorial */}
        <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-5 hover:border-[var(--hytale-border-hover)] transition-colors">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-md bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
                <HelpCircle size={18} className="text-[var(--hytale-accent-blue)]" />
              </div>
              <div>
                <span className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm">Tutorial</span>
                <p className="text-[var(--hytale-text-dimmer)] text-xs font-body">Learn how to use OrbisFX Launcher</p>
              </div>
            </div>
            <button
              onClick={handleReplayTutorial}
              className="px-3 py-1.5 rounded-md text-xs flex items-center gap-1.5 text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)] hover:bg-[var(--hytale-bg-elevated)] transition-colors"
            >
              <Play size={12} /> Replay
            </button>
          </div>
          {settings.tutorial_completed && (
            <div className="mt-3 flex items-center gap-2 text-[var(--hytale-success)] text-xs font-body">
              <CheckCircle size={12} /> Tutorial completed
            </div>
          )}
        </div>

        {/* Appearance Settings */}
        <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-5 hover:border-[var(--hytale-border-hover)] transition-colors">
          <div className="flex items-center gap-3 mb-5">
            <div className="w-9 h-9 rounded-md bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
              <Palette size={18} className="text-[var(--hytale-accent-blue)]" />
            </div>
            <div>
              <span className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm">Appearance</span>
              <p className="text-[var(--hytale-text-dim)] text-xs font-body">Customize the look and feel of the launcher</p>
            </div>
          </div>

          {/* Theme Selection */}
          <div className="mb-5">
            <label className="text-[var(--hytale-text-secondary)] text-xs font-body mb-3 block">Color Theme</label>
            <div className="grid grid-cols-4 gap-2">
              {([
                { value: 'system', label: 'System', icon: Monitor, desc: 'Sync with OS' },
                { value: 'light', label: 'Light', icon: Sun, desc: 'Light mode' },
                { value: 'dark', label: 'Dark', icon: Moon, desc: 'Dark mode' },
                { value: 'oled', label: 'OLED', icon: Moon, desc: 'True black' },
              ] as const).map(({ value, label, icon: Icon }) => (
                <button
                  key={value}
                  onClick={() => saveSettings({ ...settings, theme: value })}
                  className={`flex flex-col items-center gap-2 p-3 rounded-lg border transition-all ${
                    (settings.theme || 'system') === value
                      ? 'bg-[var(--hytale-bg-elevated)] border-[var(--hytale-accent-blue)] text-[var(--hytale-text-primary)]'
                      : 'bg-[var(--hytale-bg-input)] border-[var(--hytale-border-card)] text-[var(--hytale-text-muted)] hover:border-[var(--hytale-border-light)] hover:text-[var(--hytale-text-secondary)]'
                  }`}
                >
                  <Icon size={20} className={settings.theme === value ? 'text-[var(--hytale-accent-blue)]' : ''} />
                  <span className="text-xs font-body font-medium">{label}</span>
                </button>
              ))}
            </div>
            <p className="text-[var(--hytale-text-dimmer)] text-xs font-body mt-2">
              Currently using: <span className="text-[var(--hytale-text-muted)]">{resolvedTheme}</span> theme
            </p>
          </div>

          {/* Layout Preferences */}
          <div className="border-t border-[var(--hytale-border-card)] pt-5">
            <label className="text-[var(--hytale-text-secondary)] text-xs font-body mb-3 block">Default Layouts</label>

            {/* Presets Layout */}
            <div className="flex items-center justify-between mb-3">
              <span className="text-[var(--hytale-text-muted)] text-xs font-body">Presets Library</span>
              <div className="flex gap-1">
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
                        ? 'bg-[var(--hytale-bg-elevated)] text-[var(--hytale-accent-blue)]'
                        : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-muted)] hover:bg-[var(--hytale-bg-card)]'
                    }`}
                  >
                    <Icon size={16} />
                  </button>
                ))}
              </div>
            </div>

            {/* Gallery Layout */}
            <div className="flex items-center justify-between">
              <span className="text-[var(--hytale-text-muted)] text-xs font-body">Screenshot Gallery</span>
              <div className="flex gap-1">
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
                        ? 'bg-[var(--hytale-bg-elevated)] text-[var(--hytale-accent-blue)]'
                        : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-muted)] hover:bg-[var(--hytale-bg-card)]'
                    }`}
                  >
                    <Icon size={16} />
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* About */}
        <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-6 text-center">
          <div className="w-16 h-16 bg-[var(--hytale-bg-elevated)] rounded-lg p-3 mx-auto mb-4">
            <img src="/logo.png" alt="OrbisFX" className="w-full h-full object-contain" />
          </div>
          <h3 className="font-hytale font-bold text-[var(--hytale-text-primary)] text-lg">OrbisFX Launcher</h3>
          <p className="text-[var(--hytale-accent-blue)] text-sm mt-1 font-mono">v{appVersion}</p>
          <p className="text-[var(--hytale-text-dimmer)] text-xs font-body mt-3">© 2024 OrbisFX Team</p>
        </div>
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

        {/* Search and Filter Bar - Clean */}
        <div className="flex flex-col lg:flex-row gap-3">
          {/* Search input */}
          <div className="flex-1 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md flex items-center px-3 focus-within:border-[var(--hytale-accent-blue)] transition-colors">
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

          {/* Filter toggle group */}
          <div className="flex gap-1 bg-[var(--hytale-bg-input)] rounded-md p-1">
            <button
              onClick={() => setScreenshotFilter('all')}
              className={`px-3 py-1.5 rounded text-xs flex items-center gap-1.5 transition-colors ${
                screenshotFilter === 'all'
                  ? 'bg-[var(--hytale-bg-card)] text-[var(--hytale-text-primary)]'
                  : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)]'
              }`}
            >
              <Grid size={12} /> All
            </button>
            <button
              onClick={() => setScreenshotFilter('favorites')}
              className={`px-3 py-1.5 rounded text-xs flex items-center gap-1.5 transition-colors ${
                screenshotFilter === 'favorites'
                  ? 'bg-[var(--hytale-bg-card)] text-rose-400'
                  : 'text-[var(--hytale-text-dim)] hover:text-[var(--hytale-text-primary)]'
              }`}
            >
              <Heart size={12} fill={screenshotFilter === 'favorites' ? 'currentColor' : 'none'} /> Favorites
            </button>
          </div>

          {/* Preset filter dropdown */}
          {screenshotPresets.length > 0 && (
            <div className="relative">
              <select
                value={screenshotPresetFilter}
                onChange={(e) => setScreenshotPresetFilter(e.target.value)}
                className="appearance-none bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md pl-3 pr-8 py-2 text-[var(--hytale-text-primary)] text-sm focus:border-[var(--hytale-accent-blue)] focus:outline-none transition-colors cursor-pointer"
              >
                <option value="all">All Presets ({screenshotPresets.length})</option>
                {screenshotPresets.map(preset => (
                  <option key={preset} value={preset}>{preset}</option>
                ))}
              </select>
              <ChevronDown size={14} className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[var(--hytale-text-dimmer)] pointer-events-none" />
            </div>
          )}

          {/* Sort dropdown */}
          <div className="relative">
            <select
              value={screenshotSort}
              onChange={(e) => setScreenshotSort(e.target.value as typeof screenshotSort)}
              className="appearance-none bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md pl-8 pr-8 py-2 text-[var(--hytale-text-primary)] text-sm focus:border-[var(--hytale-accent-blue)] focus:outline-none transition-colors cursor-pointer"
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
            <ArrowUpDown size={12} className="absolute left-2.5 top-1/2 -translate-y-1/2 text-[var(--hytale-accent-blue)] pointer-events-none" />
            <ChevronDown size={14} className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[var(--hytale-text-dimmer)] pointer-events-none" />
          </div>

          {/* Layout Toggle */}
          <div className="flex gap-1 bg-[var(--hytale-bg-input)] rounded-md p-1">
            {([
              { value: 'grid', icon: LayoutGrid },
              { value: 'gallery', icon: GalleryHorizontal },
            ] as const).map(({ value, icon: Icon }) => (
              <button
                key={value}
                onClick={() => saveSettings({ ...settings, gallery_layout: value })}
                className={`p-2 rounded transition-all ${
                  (settings.gallery_layout || 'grid') === value
                    ? 'bg-[var(--hytale-bg-card)] text-[var(--hytale-accent-blue)]'
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
            className="px-3 py-2 bg-[var(--hytale-bg-elevated)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-muted)] text-sm flex items-center gap-2 hover:bg-[var(--hytale-bg-hover)] hover:text-[var(--hytale-text-primary)] transition-colors"
          >
            <FolderOpenIcon size={14} /> Open Folder
          </button>
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

                  {/* Install Button */}
                  <div className="pt-4 border-t-2 border-[var(--hytale-border-primary)]">
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
                  </div>
                </div>
              </div>
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
    </div>
  );
};

export default App;
