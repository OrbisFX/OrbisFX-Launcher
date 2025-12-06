import React, { useState, useEffect, useRef, ReactNode } from 'react';
import {
  FolderOpen, Download, ShieldCheck, CheckCircle, Activity, Settings,
  AlertTriangle, Trash2, Minus, X, Play, Home, Palette, RefreshCw,
  ExternalLink, Search, Filter, ChevronRight, Power, Gamepad2,
  Star, Upload, Share2, Keyboard, ChevronLeft, Eye, HelpCircle,
  Rocket, MessageCircle, Sparkles
} from 'lucide-react';
import { invoke } from '@tauri-apps/api/core';
import { getCurrentWindow } from '@tauri-apps/api/window';
import { getVersion } from '@tauri-apps/api/app';
import { exit } from '@tauri-apps/plugin-process';
import { open, save } from '@tauri-apps/plugin-dialog';
import { open as shellOpen } from '@tauri-apps/plugin-shell';

import './App.css';

const appWindow = getCurrentWindow();

// ============== Type Definitions ==============

interface ValidationResult {
  is_valid: boolean;
  hytale_path: string | null;
  hytale_version: string | null;
  reshade_installed: boolean;
  reshade_enabled: boolean;
}

interface AppSettings {
  hytale_path: string | null;
  reshade_enabled: boolean;
  last_preset: string | null;
  tutorial_completed?: boolean;
}

// Tutorial step interface
interface TutorialStep {
  title: string;
  description: string;
  icon: ReactNode;
  anchorId?: string; // ID of element to anchor popover to
  position?: 'modal' | 'right' | 'bottom'; // Where to show the popover
}

// Tutorial steps configuration
const TUTORIAL_STEPS: TutorialStep[] = [
  {
    title: "Welcome to OrbisFX Launcher!",
    description: "This quick tutorial will guide you through the main features of the application. You can skip at any time.",
    icon: <Sparkles size={48} className="text-[#0092cc]" />,
    position: 'modal'
  },
  {
    title: "Home Dashboard",
    description: "The Home page shows your current setup status, active preset, and quick actions. You can launch Hytale and toggle ReShade from here.",
    icon: <Home size={48} className="text-[#0092cc]" />,
    anchorId: 'nav-home',
    position: 'right'
  },
  {
    title: "Preset Library",
    description: "Browse and install graphics presets from the community. Click on any preset to see more details and screenshots.",
    icon: <Palette size={48} className="text-[#0092cc]" />,
    anchorId: 'nav-presets',
    position: 'right'
  },
  {
    title: "Installing Presets",
    description: "Click 'Install' on any preset to download it. You can then activate it from your installed presets section.",
    icon: <Download size={48} className="text-[#0092cc]" />,
    anchorId: 'nav-presets',
    position: 'right'
  },
  {
    title: "Settings",
    description: "Configure your Hytale installation path and other preferences in the Settings page.",
    icon: <Settings size={48} className="text-[#0092cc]" />,
    anchorId: 'nav-settings',
    position: 'right'
  },
  {
    title: "Join Our Community",
    description: "Click the Discord button in the sidebar to join our community for support, preset sharing, and updates!",
    icon: <MessageCircle size={48} className="text-[#5865F2]" />,
    anchorId: 'nav-discord',
    position: 'right'
  },
  {
    title: "You're All Set!",
    description: "That's everything you need to know. Enjoy enhancing your Hytale experience with OrbisFX!",
    icon: <Rocket size={48} className="text-[#0092cc]" />,
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

interface ReShadeHotkeys {
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

type Page = 'home' | 'presets' | 'settings' | 'setup';

// ============== Helper Components ==============

const ProgressBar: React.FC<{ progress: number }> = ({ progress }) => (
  <div className="w-full h-2 bg-[#141417] rounded-full overflow-hidden border border-[#2d2d30] relative">
    <div
      className="h-full bg-gradient-to-r from-[#0092cc] to-[#00b0f4] transition-all duration-300 ease-out shadow-[0_0_10px_#0092cc]"
      style={{ width: `${progress}%` }}
    />
  </div>
);

const TerminalLog: React.FC<{ logs: string[] }> = ({ logs }) => {
  const endRef = useRef<HTMLDivElement>(null);
  useEffect(() => endRef.current?.scrollIntoView({ behavior: "smooth" }), [logs]);

  return (
    <div className="bg-[#050505] border border-[#2d2d30] rounded-sm p-4 font-mono text-xs text-[#9ca3af] h-32 overflow-y-auto shadow-inner relative">
      {logs.map((log, i) => (
        <div key={i} className={`mb-1 ${log.includes("COMPLETE") ? "text-[#fcd34d] font-bold" : ""} ${log.includes("Error") ? "text-red-500" : ""}`}>
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
  const [settings, setSettings] = useState<AppSettings>({ hytale_path: null, reshade_enabled: true, last_preset: null });
  const [installPath, setInstallPath] = useState<string>("");
  const [validationStatus, setValidationStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [validationResult, setValidationResult] = useState<ValidationResult | null>(null);

  // Preset state
  const [presets, setPresets] = useState<Preset[]>([]);
  const [installedPresets, setInstalledPresets] = useState<InstalledPreset[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [presetsLoading, setPresetsLoading] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

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
  const [hotkeys, setHotkeys] = useState<ReShadeHotkeys | null>(null);

  // Preset detail modal state
  const [selectedPreset, setSelectedPreset] = useState<Preset | null>(null);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

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
      const result = await invoke('toggle_reshade', { hytaleDir: installPath, enabled }) as { success: boolean; error?: string };
      if (result.success) {
        await saveSettings({ ...settings, reshade_enabled: enabled });
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
        filters: [{ name: 'ReShade Preset', extensions: ['ini'] }],
        multiple: false,
        title: 'Import ReShade Preset'
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
        filters: [{ name: 'ReShade Preset', extensions: ['ini'] }],
        defaultPath: filename,
        title: 'Export ReShade Preset'
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
      const result = await invoke('get_reshade_hotkeys', { hytaleDir: installPath }) as { success: boolean; hotkeys?: ReShadeHotkeys };
      if (result.success && result.hotkeys) {
        setHotkeys(result.hotkeys);
      }
    } catch (e) {
      console.error('Failed to load hotkeys:', e);
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

      const result = await invoke('install_reshade', { hytaleDir: installPath, presetName: null }) as { success: boolean; message: string };

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
      await invoke('uninstall_reshade', { hytaleDir: installPath });
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
      setTutorialStep(tutorialStep + 1);
    } else {
      handleTutorialComplete();
    }
  };

  const handleTutorialSkip = async () => {
    await handleTutorialComplete();
  };

  const handleTutorialComplete = async () => {
    setShowTutorial(false);
    setTutorialStep(0);
    await saveSettings({ ...settings, tutorial_completed: true });
  };

  const handleReplayTutorial = () => {
    setShowTutorial(true);
    setTutorialStep(0);
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
  }, [currentPage]);

  // Filter presets
  const filteredPresets = presets.filter(p => {
    const matchesCategory = selectedCategory === 'all' || p.category === selectedCategory;
    const matchesSearch = p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         p.author.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const categories = ['all', ...new Set(presets.map(p => p.category))];

  // Check if runtime is installed and enabled for play button
  const canLaunchGame = validationStatus === 'success' && validationResult?.reshade_installed && validationResult?.reshade_enabled;

  // ============== Render Home Page ==============
  const renderHomePage = () => (
    <div className="flex-1 p-6 lg:p-8 overflow-y-auto">
      {/* Film grain overlay */}
      <div className="grain-overlay"></div>

      <div className="max-w-4xl mx-auto space-y-6">
        {/* Hero Section - Website Style */}
        <div className="card-hyfx p-6 lg:p-8 relative overflow-hidden">
          {/* Background effects */}
          <div className="absolute top-0 right-0 w-80 h-80 bg-[#0092cc] rounded-full blur-[150px] opacity-10"></div>
          <div className="absolute bottom-0 left-0 w-40 h-40 bg-[#0092cc] rounded-full blur-[100px] opacity-5"></div>

          {/* Tech corner decorations */}
          <div className="corner-tl"></div>
          <div className="corner-tr"></div>
          <div className="corner-bl"></div>
          <div className="corner-br"></div>

          {/* Floating particles */}
          <div className="particle p1" style={{ top: '20%', left: '10%' }}></div>
          <div className="particle p2" style={{ top: '60%', right: '15%' }}></div>
          <div className="particle p3" style={{ bottom: '30%', left: '25%' }}></div>

          <div className="flex items-start lg:items-center gap-6 lg:gap-8 relative z-10 flex-col lg:flex-row">
            <div className="w-20 h-20 lg:w-24 lg:h-24 bg-[#0a0a0c] rounded-sm p-3 border-2 border-[#2d2d30] flex-shrink-0 relative group">
              <img src="/logo.png" alt="OrbisFX Logo" className="w-full h-full object-contain" />
              <div className="absolute inset-0 bg-[#0092cc]/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
            </div>
            <div className="flex-1 w-full">
              <h1 className="font-hytale font-black text-3xl lg:text-4xl text-white mb-2">Welcome to OrbisFX</h1>
              <p className="text-[#9ca3af] text-sm mb-5">Advanced graphics enhancement for Hytale</p>

              {validationStatus === 'success' ? (
                <div className="space-y-3">
                  <div className="flex flex-wrap gap-3">
                    <button
                      onClick={handleLaunchGame}
                      disabled={!canLaunchGame}
                      className={`px-6 lg:px-8 py-3 lg:py-4 font-hytale font-bold text-base lg:text-lg text-white rounded-sm uppercase tracking-wider flex items-center gap-3 transition-all duration-200 ${
                        canLaunchGame
                          ? 'btn-hyfx-primary shadow-[0_0_25px_rgba(0,146,204,0.4)] hover:shadow-[0_0_35px_rgba(0,146,204,0.5)]'
                          : 'bg-[#2d2d30] cursor-not-allowed opacity-60'
                      }`}
                    >
                      <Play size={22} /> Launch Hytale
                    </button>
                    {validationResult?.reshade_installed && (
                      <button
                        onClick={() => handleToggleRuntime(!validationResult?.reshade_enabled)}
                        className={`px-4 py-3 lg:py-4 rounded-sm flex items-center gap-2 font-hytale font-bold text-sm uppercase transition-all duration-200 border-2 ${
                          validationResult?.reshade_enabled
                            ? 'bg-green-500/20 text-green-400 border-green-500/30 hover:bg-green-500/30'
                            : 'bg-yellow-500/20 text-yellow-400 border-yellow-500/30 hover:bg-yellow-500/30'
                        }`}
                      >
                        <Power size={18} />
                        {validationResult?.reshade_enabled ? 'Enabled' : 'Disabled'}
                      </button>
                    )}
                  </div>
                  {!validationResult?.reshade_installed && (
                    <div className="flex items-center gap-2 text-yellow-400 text-sm bg-yellow-500/10 px-4 py-2.5 rounded-sm border-2 border-yellow-500/20">
                      <AlertTriangle size={16} className="flex-shrink-0" />
                      <span className="font-body">Graphics runtime not installed. <button onClick={handleInstallRuntime} className="underline hover:text-yellow-300 font-semibold">Install now</button></span>
                    </div>
                  )}
                </div>
              ) : (
                <button
                  onClick={() => setCurrentPage('settings')}
                  className="btn-hyfx-secondary px-6 py-3 font-hytale font-bold text-sm rounded-sm uppercase flex items-center gap-2 hover:scale-[1.02] transition-transform"
                >
                  <Settings size={18} /> Configure Game Path
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Status Cards - Website Style Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {/* Game Status */}
          <div className="card-hyfx p-5 group">
            <div className="flex items-center justify-between mb-4">
              <div className="w-10 h-10 rounded-sm bg-[#0092cc]/10 flex items-center justify-center group-hover:bg-[#0092cc]/20 transition-colors">
                <Gamepad2 size={20} className="text-[#0092cc]" />
              </div>
              <div className={`w-2.5 h-2.5 rounded-full ${validationStatus === 'success' ? 'bg-green-400 shadow-[0_0_8px_rgba(74,222,128,0.5)]' : 'bg-[#4b5563]'}`}></div>
            </div>
            <span className="font-hytale font-bold text-xs text-[#6b7280] uppercase tracking-wide">Game Status</span>
            <p className={`text-base font-medium mt-1 ${validationStatus === 'success' ? 'text-green-400' : 'text-[#9ca3af]'}`}>
              {validationStatus === 'success' ? 'Ready to play' : 'Not configured'}
            </p>
          </div>

          {/* Runtime Status */}
          <div className="card-hyfx p-5 group">
            <div className="flex items-center justify-between mb-4">
              <div className="w-10 h-10 rounded-sm bg-[#0092cc]/10 flex items-center justify-center group-hover:bg-[#0092cc]/20 transition-colors">
                <ShieldCheck size={20} className="text-[#0092cc]" />
              </div>
              <div className={`w-2.5 h-2.5 rounded-full ${validationResult?.reshade_installed ? (validationResult?.reshade_enabled ? 'bg-green-400 shadow-[0_0_8px_rgba(74,222,128,0.5)]' : 'bg-yellow-400 shadow-[0_0_8px_rgba(250,204,21,0.5)]') : 'bg-[#4b5563]'}`}></div>
            </div>
            <span className="font-hytale font-bold text-xs text-[#6b7280] uppercase tracking-wide">Runtime</span>
            <p className={`text-base font-medium mt-1 ${validationResult?.reshade_installed ? (validationResult?.reshade_enabled ? 'text-green-400' : 'text-yellow-400') : 'text-[#9ca3af]'}`}>
              {validationResult?.reshade_installed
                ? (validationResult?.reshade_enabled ? 'Enabled' : 'Disabled')
                : 'Not installed'}
            </p>
          </div>

          {/* Updates */}
          <div className="card-hyfx p-5 group cursor-pointer" onClick={() => updateAvailable && setShowUpdateModal(true)}>
            <div className="flex items-center justify-between mb-4">
              <div className="w-10 h-10 rounded-sm bg-[#0092cc]/10 flex items-center justify-center group-hover:bg-[#0092cc]/20 transition-colors">
                <RefreshCw size={20} className="text-[#0092cc]" />
              </div>
              {updateAvailable && (
                <span className="badge-hyfx warning animate-pulse">New</span>
              )}
            </div>
            <span className="font-hytale font-bold text-xs text-[#6b7280] uppercase tracking-wide">Updates</span>
            <p className={`text-base font-medium mt-1 ${updateAvailable ? 'text-yellow-400' : 'text-green-400'}`}>
              {updateAvailable ? `v${latestVersion} available` : 'Up to date'}
            </p>
          </div>
        </div>

        {/* Quick Actions - Website Style */}
        <div className="card-hyfx p-6">
          <div className="flex items-center justify-between mb-5">
            <h2 className="font-hytale font-bold text-base text-white uppercase tracking-wider">Quick Actions</h2>
            <span className="text-[#4b5563] text-xs font-mono">Shortcuts</span>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <button
              onClick={() => setCurrentPage('presets')}
              className="bg-[#0a0a0c] hover:bg-[#1a1a1e] border-2 border-[#2d2d30] hover:border-[#4a4a50] rounded-sm p-5 text-left transition-all duration-200 group"
            >
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-sm bg-[#0092cc]/10 flex items-center justify-center group-hover:bg-[#0092cc]/20 transition-colors">
                  <Palette size={24} className="text-[#0092cc] group-hover:scale-110 transition-transform" />
                </div>
                <div className="flex-1">
                  <p className="font-hytale font-bold text-white text-sm">Browse Presets</p>
                  <p className="text-[#6b7280] text-xs mt-1 font-body">Explore community graphics presets</p>
                </div>
                <ChevronRight size={18} className="text-[#4b5563] group-hover:text-[#0092cc] group-hover:translate-x-1 transition-all mt-1" />
              </div>
            </button>

            {validationResult?.reshade_installed ? (
              <button
                onClick={handleUninstallRuntime}
                disabled={isInstalling}
                className="bg-[#0a0a0c] hover:bg-[#1a1a1e] border-2 border-[#2d2d30] hover:border-red-500/40 rounded-sm p-5 text-left transition-all duration-200 group disabled:opacity-50"
              >
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-sm bg-red-500/10 flex items-center justify-center group-hover:bg-red-500/20 transition-colors">
                    <Trash2 size={24} className="text-red-400 group-hover:scale-110 transition-transform" />
                  </div>
                  <div className="flex-1">
                    <p className="font-hytale font-bold text-white text-sm">Uninstall OrbisFX</p>
                    <p className="text-[#6b7280] text-xs mt-1 font-body">Remove runtime from game</p>
                  </div>
                  <ChevronRight size={18} className="text-[#4b5563] group-hover:text-red-400 group-hover:translate-x-1 transition-all mt-1" />
                </div>
              </button>
            ) : (
              <button
                onClick={handleInstallRuntime}
                disabled={isInstalling || validationStatus !== 'success'}
                className="bg-[#0a0a0c] hover:bg-[#1a1a1e] border-2 border-[#2d2d30] hover:border-[#4a4a50] rounded-sm p-5 text-left transition-all duration-200 group disabled:opacity-50"
              >
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-sm bg-[#0092cc]/10 flex items-center justify-center group-hover:bg-[#0092cc]/20 transition-colors">
                    <Download size={24} className="text-[#0092cc] group-hover:scale-110 transition-transform" />
                  </div>
                  <div className="flex-1">
                    <p className="font-hytale font-bold text-white text-sm">Install OrbisFX</p>
                    <p className="text-[#6b7280] text-xs mt-1 font-body">Set up graphics runtime</p>
                  </div>
                  <ChevronRight size={18} className="text-[#4b5563] group-hover:text-[#0092cc] group-hover:translate-x-1 transition-all mt-1" />
                </div>
              </button>
            )}
          </div>
        </div>

        {/* Installation Progress - Website Style */}
        {isInstalling && (
          <div className="card-hyfx active p-6">
            <div className="flex justify-between items-center mb-4">
              <div className="flex items-center gap-3">
                <Activity size={20} className="text-[#0092cc] animate-spin" />
                <span className="text-white font-hytale font-bold text-sm uppercase tracking-wider">Installing OrbisFX</span>
              </div>
              <span className="text-[#0092cc] font-mono text-sm font-bold">{installProgress}%</span>
            </div>
            <ProgressBar progress={installProgress} />
            <div className="mt-4">
              <TerminalLog logs={installLogs} />
            </div>
          </div>
        )}

        {/* Error Display - Website Style */}
        {error && (
          <div className="bg-red-900/20 border-2 border-red-500/30 text-red-400 px-5 py-4 rounded-sm flex items-start gap-4 animate-fade-in">
            <AlertTriangle size={20} className="flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="font-hytale font-medium uppercase tracking-wide">Error</p>
              <p className="text-sm text-red-400/80 mt-1 font-body">{error}</p>
            </div>
            <button onClick={() => setError(null)} className="hover:text-white transition-colors p-1">
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

      <div className="max-w-5xl mx-auto space-y-6">
        {/* Page Header - Website Style */}
        <header className="mb-2">
          <h1 className="font-hytale font-black text-2xl lg:text-3xl text-white mb-1 uppercase tracking-wide">Preset Library</h1>
          <p className="text-[#6b7280] text-sm font-body">Browse and install graphics presets from the community</p>
        </header>

        {/* Search and Filter - Website Style */}
        <div className="flex flex-col lg:flex-row gap-4">
          <div className="flex-1 bg-[#0a0a0c] border-2 border-[#2d2d30] rounded-sm flex items-center px-4 focus-within:border-[#0092cc] focus-within:shadow-[0_0_10px_rgba(0,146,204,0.2)] transition-all">
            <Search size={18} className="text-[#4b5563]" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search presets..."
              className="bg-transparent w-full py-3.5 px-3 text-white outline-none placeholder-[#4b5563] font-mono text-sm"
            />
            {searchQuery && (
              <button onClick={() => setSearchQuery('')} className="text-[#4b5563] hover:text-[#0092cc] transition-colors">
                <X size={16} />
              </button>
            )}
          </div>
          <div className="flex gap-2 overflow-x-auto pb-1">
            {categories.map(cat => (
              <button
                key={cat}
                onClick={() => setSelectedCategory(cat)}
                className={`px-4 py-2.5 rounded-sm font-hytale text-xs uppercase tracking-wide capitalize transition-all whitespace-nowrap ${
                  selectedCategory === cat
                    ? 'btn-hyfx-primary'
                    : 'bg-[#141417] border-2 border-[#2d2d30] text-[#6b7280] hover:text-white hover:border-[#4a4a50]'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>
        </div>

        {/* Installed Presets Section - Website Style */}
        <div className="card-hyfx p-6">
          <div className="flex items-center justify-between mb-5">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-sm bg-green-500/10 flex items-center justify-center">
                <CheckCircle size={20} className="text-green-400" />
              </div>
              <div>
                <h2 className="font-hytale font-bold text-sm text-white uppercase tracking-wide">Installed Presets</h2>
                <p className="text-[#6b7280] text-xs mt-0.5 font-mono">{installedPresets.length} preset{installedPresets.length !== 1 ? 's' : ''} installed</p>
              </div>
            </div>
            <button
              onClick={handleImportPreset}
              disabled={!installPath}
              className="btn-hyfx-secondary px-4 py-2.5 rounded-sm font-hytale text-xs uppercase flex items-center gap-2 disabled:opacity-50"
            >
              <Upload size={14} /> Import
            </button>
          </div>

          {installedPresets.length === 0 ? (
            <div className="text-center py-10 bg-[#0a0a0c] border-2 border-[#2d2d30] rounded-sm relative">
              {/* Corner decorations */}
              <div className="corner-tl"></div>
              <div className="corner-tr"></div>
              <div className="corner-bl"></div>
              <div className="corner-br"></div>

              <div className="w-14 h-14 rounded-sm bg-[#141417] flex items-center justify-center mx-auto mb-4">
                <Upload size={24} className="text-[#4b5563]" />
              </div>
              <p className="text-[#9ca3af] text-sm font-hytale font-medium uppercase tracking-wide">No presets installed yet</p>
              <p className="text-[#4b5563] text-xs mt-1 font-body">Download from community or import your own</p>
            </div>
          ) : (
            <div className="space-y-3">
              {/* Sort: favorites first, then by name */}
              {[...installedPresets]
                .sort((a, b) => {
                  if (a.is_favorite && !b.is_favorite) return -1;
                  if (!a.is_favorite && b.is_favorite) return 1;
                  return a.name.localeCompare(b.name);
                })
                .map(preset => (
                <div
                  key={preset.id}
                  className={`bg-[#141417] border border-[#2d2d30] rounded-sm p-5 cursor-pointer transition-all hover:border-[#4a4a50] ${
                    preset.is_active ? 'border-l-[3px] border-l-green-500' : ''
                  }`}
                  onClick={() => !preset.is_active && handleActivatePreset(preset.id)}
                >
                  {/* Top row: Status dot + Active badge + Star */}
                  <div className="flex items-center justify-between mb-4">
                    {/* Status dot */}
                    <div
                      className={`w-2.5 h-2.5 rounded-full ${
                        preset.is_active
                          ? 'bg-green-500'
                          : 'bg-[#4b5563]'
                      }`}
                    />
                    {/* Right side: badges + favorite */}
                    <div className="flex items-center gap-3">
                      {preset.is_active && (
                        <span className="text-green-500 text-xs font-mono border border-green-500/50 px-2 py-0.5 rounded-sm uppercase tracking-wider">
                          Active
                        </span>
                      )}
                      {preset.is_local && (
                        <span className="text-[#0092cc] text-xs font-mono border border-[#0092cc]/50 px-2 py-0.5 rounded-sm uppercase tracking-wider">
                          Local
                        </span>
                      )}
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleToggleFavorite(preset.id);
                        }}
                        className={`transition-colors ${
                          preset.is_favorite
                            ? 'text-[#fcd34d]'
                            : 'text-[#4b5563] hover:text-[#fcd34d]'
                        }`}
                      >
                        <Star size={16} fill={preset.is_favorite ? 'currentColor' : 'none'} />
                      </button>
                    </div>
                  </div>

                  {/* Preset name */}
                  <h3 className="font-hytale font-bold text-white text-base uppercase tracking-wide mb-1">{preset.name}</h3>

                  {/* Version */}
                  <p className="text-[#6b7280] text-sm font-mono mb-0.5">v{preset.version}</p>

                  {/* Filename */}
                  <p className="text-[#4b5563] text-sm font-mono">{preset.filename}</p>

                  {/* Action links */}
                  <div className="flex items-center gap-6 mt-4">
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleExportPreset(preset.id, preset.filename);
                      }}
                      className="text-[#0092cc] hover:text-[#00b4ff] text-sm flex items-center gap-2 transition-colors font-medium"
                    >
                      <Download size={14} /> EXPORT
                    </button>
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleDeletePreset(preset.id);
                      }}
                      className="text-[#6b7280] hover:text-red-400 text-sm flex items-center gap-2 transition-colors font-medium"
                    >
                      <Trash2 size={14} /> REMOVE
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Available Presets - Website Style Header */}
        <div className="flex items-center gap-3 mt-2">
          <div className="w-10 h-10 rounded-sm bg-[#0092cc]/10 flex items-center justify-center">
            <Palette size={20} className="text-[#0092cc]" />
          </div>
          <div>
            <h2 className="font-hytale font-bold text-sm text-white uppercase tracking-wide">Available Presets</h2>
            <p className="text-[#6b7280] text-xs mt-0.5 font-mono">{filteredPresets.length} preset{filteredPresets.length !== 1 ? 's' : ''} available</p>
          </div>
        </div>

        {presetsLoading ? (
          <div className="text-center py-16 card-hyfx mt-4">
            <Activity size={32} className="text-[#0092cc] animate-spin mx-auto mb-4" />
            <p className="text-[#9ca3af] font-hytale font-medium uppercase tracking-wide">Loading presets...</p>
            <p className="text-[#4b5563] text-xs mt-1 font-body">Fetching from community repository</p>
          </div>
        ) : filteredPresets.length === 0 ? (
          <div className="text-center py-16 card-hyfx mt-4 relative">
            {/* Corner decorations */}
            <div className="corner-tl"></div>
            <div className="corner-tr"></div>
            <div className="corner-bl"></div>
            <div className="corner-br"></div>

            <div className="w-16 h-16 rounded-sm bg-[#0a0a0c] flex items-center justify-center mx-auto mb-4">
              <Palette size={32} className="text-[#4b5563]" />
            </div>
            <p className="text-[#9ca3af] font-hytale font-medium uppercase tracking-wide">No presets found</p>
            <p className="text-[#4b5563] text-xs mt-1 font-body">Check back later or try a different search</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
            {filteredPresets.map(preset => {
              const isInstalled = installedPresets.some(ip => ip.id === preset.id);
              const installedVersion = installedPresets.find(ip => ip.id === preset.id)?.version;
              const hasUpdate = isInstalled && installedVersion && installedVersion !== preset.version;

              return (
                <div
                  key={preset.id}
                  className={`bg-[#141417] border-2 rounded-sm overflow-hidden transition-all group cursor-pointer ${
                    isInstalled
                      ? 'border-green-500/30 hover:border-green-500/50 hover:shadow-[0_0_15px_rgba(74,222,128,0.1)]'
                      : 'border-[#2d2d30] hover:border-[#4a4a50] hover:bg-[#1a1a1e]'
                  }`}
                  onClick={() => {
                    setSelectedPreset(preset);
                    setCurrentImageIndex(0);
                  }}
                >
                  {/* Thumbnail with corner decorations */}
                  <div className="h-36 bg-[#0a0a0c] relative overflow-hidden">
                    {preset.thumbnail ? (
                      <img src={preset.thumbnail} alt={preset.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center">
                        <Palette size={32} className="text-[#2d2d30]" />
                      </div>
                    )}
                    {/* Category badge */}
                    <div className="absolute top-3 left-3 badge-hyfx primary capitalize backdrop-blur-sm">
                      {preset.category}
                    </div>
                    {isInstalled && !hasUpdate && (
                      <div className="absolute top-3 right-3 badge-hyfx success backdrop-blur-sm">
                        <CheckCircle size={12} /> Installed
                      </div>
                    )}
                    {hasUpdate && (
                      <div className="absolute top-3 right-3 badge-hyfx warning animate-pulse backdrop-blur-sm">
                        <RefreshCw size={12} /> Update
                      </div>
                    )}
                    {/* View indicator on hover */}
                    <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent opacity-0 group-hover:opacity-100 transition-opacity flex items-end justify-center pb-4">
                      <div className="bg-[#0a0a0c]/80 backdrop-blur-sm text-white px-4 py-2 rounded-sm text-sm font-hytale flex items-center gap-2 border border-[#0092cc]/50 uppercase tracking-wide">
                        <Eye size={14} /> View Details
                      </div>
                    </div>
                  </div>

                  {/* Info */}
                  <div className="p-5">
                    <div className="flex justify-between items-start mb-2">
                      <div>
                        <h3 className="font-hytale font-bold text-white text-sm">{preset.name}</h3>
                        <p className="text-[#6b7280] text-xs mt-0.5 font-body">by {preset.author}</p>
                      </div>
                      <span className="text-[#0092cc] text-xs bg-[#0092cc]/10 px-2 py-1 rounded-sm font-mono border border-[#0092cc]/20">v{preset.version}</span>
                    </div>
                    <p className="text-[#9ca3af] text-xs mb-4 line-clamp-2 leading-relaxed font-body">{preset.description}</p>

                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleDownloadPreset(preset);
                      }}
                      disabled={!installPath}
                      className={`w-full py-2.5 font-hytale font-bold text-xs text-white rounded-sm flex items-center justify-center gap-2 disabled:opacity-50 transition-all uppercase tracking-wide ${
                        isInstalled
                          ? 'btn-hyfx-secondary'
                          : 'btn-hyfx-primary'
                      }`}
                    >
                      <Download size={14} /> {isInstalled ? (hasUpdate ? 'Update' : 'Reinstall') : 'Install'}
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );

  // ============== Render Settings Page ==============
  const renderSettingsPage = () => (
    <div className="flex-1 p-6 lg:p-8 overflow-y-auto">
      {/* Film grain overlay */}
      <div className="grain-overlay"></div>

      <div className="max-w-3xl mx-auto space-y-6">
        {/* Page Header - Website Style */}
        <header className="mb-2">
          <h1 className="font-hytale font-black text-2xl lg:text-3xl text-white mb-1 uppercase tracking-wide">Settings</h1>
          <p className="text-[#6b7280] text-sm font-body">Configure OrbisFX and manage your installation</p>
        </header>

        {/* Game Path - Website Style */}
        <div className="card-hyfx p-6">
          <div className="flex items-center gap-4 mb-5">
            <div className="w-10 h-10 rounded-sm bg-[#0092cc]/10 flex items-center justify-center">
              <FolderOpen size={20} className="text-[#0092cc]" />
            </div>
            <div>
              <span className="font-hytale font-bold text-white text-sm uppercase tracking-wide">Game Installation Path</span>
              <p className="text-[#6b7280] text-xs mt-0.5 font-body">Location of your Hytale client</p>
            </div>
          </div>
          <div className="flex gap-3">
            <input
              type="text"
              value={installPath}
              onChange={(e) => setInstallPath(e.target.value)}
              placeholder="Select Hytale installation folder..."
              className="input-hyfx flex-1"
            />
            <button
              onClick={handleBrowse}
              className="btn-hyfx-secondary px-5 py-3 rounded-sm font-hytale font-bold text-sm uppercase flex items-center gap-2"
            >
              <FolderOpen size={18} /> Browse
            </button>
          </div>
          {validationStatus === 'success' && (
            <div className="flex items-center gap-2 mt-4 bg-green-500/10 text-green-400 text-sm px-4 py-2.5 rounded-sm border border-green-500/20 font-body">
              <CheckCircle size={16} /> Hytale installation detected
            </div>
          )}
          {validationStatus === 'error' && installPath && (
            <div className="flex items-center gap-2 mt-4 bg-red-500/10 text-red-400 text-sm px-4 py-2.5 rounded-sm border border-red-500/20 font-body">
              <AlertTriangle size={16} /> Invalid path - Hytale.exe not found
            </div>
          )}
        </div>

        {/* Runtime Toggle - Website Style */}
        <div className="card-hyfx p-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className={`w-10 h-10 rounded-sm flex items-center justify-center transition-colors ${
                validationResult?.reshade_enabled ? 'bg-green-500/10' : 'bg-[#0092cc]/10'
              }`}>
                <Power size={20} className={validationResult?.reshade_enabled ? 'text-green-400' : 'text-[#0092cc]'} />
              </div>
              <div>
                <span className="font-hytale font-bold text-white text-sm uppercase tracking-wide">Runtime Status</span>
                <p className="text-[#6b7280] text-xs mt-0.5 font-body">Toggle graphics enhancements on/off</p>
              </div>
            </div>
            {validationResult?.reshade_installed ? (
              <button
                onClick={() => handleToggleRuntime(!validationResult?.reshade_enabled)}
                className={`relative w-16 h-8 rounded-full transition-all duration-300 border-2 ${
                  validationResult?.reshade_enabled
                    ? 'bg-gradient-to-r from-green-500 to-green-600 border-green-400/50 shadow-[0_0_12px_rgba(74,222,128,0.3)]'
                    : 'bg-[#2d2d30] border-[#4b5563]'
                }`}
              >
                <div className={`absolute top-0.5 w-6 h-6 bg-white rounded-full shadow-md transition-all duration-300 ${
                  validationResult?.reshade_enabled ? 'translate-x-8' : 'translate-x-0.5'
                }`} />
              </button>
            ) : (
              <span className="badge-hyfx primary">Not installed</span>
            )}
          </div>
        </div>

        {/* Runtime Installation - Website Style */}
        <div className="card-hyfx p-6">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-10 h-10 rounded-sm bg-[#0092cc]/10 flex items-center justify-center">
              <Download size={20} className="text-[#0092cc]" />
            </div>
            <div>
              <span className="font-hytale font-bold text-white text-sm uppercase tracking-wide">OrbisFX Installation</span>
              <p className="text-[#6b7280] text-xs mt-0.5 font-body">
                {validationResult?.reshade_installed ? 'Runtime is installed' : 'Install graphics runtime'}
              </p>
            </div>
          </div>
          <p className="text-[#9ca3af] text-sm mb-5 leading-relaxed font-body">
            {validationResult?.reshade_installed
              ? 'OrbisFX runtime is currently installed. You can reinstall to update or repair the installation.'
              : 'Install the OrbisFX runtime to enable graphics enhancements in Hytale.'}
          </p>
          <div className="flex flex-wrap gap-3">
            <button
              onClick={handleInstallRuntime}
              disabled={isInstalling || validationStatus !== 'success'}
              className="btn-hyfx-primary px-6 py-3 font-hytale font-bold text-sm text-white rounded-sm flex items-center gap-2 disabled:opacity-50"
            >
              <Download size={16} /> {validationResult?.reshade_installed ? 'Reinstall' : 'Install'} OrbisFX
            </button>
            {validationResult?.reshade_installed && (
              <button
                onClick={handleUninstallRuntime}
                disabled={isInstalling}
                className="btn-hyfx-danger px-6 py-3 font-hytale font-bold text-sm rounded-sm flex items-center gap-2 disabled:opacity-50"
              >
                <Trash2 size={16} /> Uninstall
              </button>
            )}
          </div>
        </div>

        {/* Hotkeys - Website Style */}
        {hotkeys && validationResult?.reshade_installed && (
          <div className="card-hyfx p-6">
            <div className="flex items-center gap-4 mb-5">
              <div className="w-10 h-10 rounded-sm bg-[#0092cc]/10 flex items-center justify-center">
                <Keyboard size={20} className="text-[#0092cc]" />
              </div>
              <div>
                <span className="font-hytale font-bold text-white text-sm uppercase tracking-wide">ReShade Hotkeys</span>
                <p className="text-[#6b7280] text-xs mt-0.5 font-body">Configure shortcuts in-game via ReShade overlay</p>
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {[
                { label: 'Toggle Effects', key: hotkeys.key_effects },
                { label: 'Toggle Overlay', key: hotkeys.key_overlay },
                { label: 'Screenshot', key: hotkeys.key_screenshot },
                { label: 'Next Preset', key: hotkeys.key_next_preset },
                { label: 'Previous Preset', key: hotkeys.key_prev_preset },
              ].map((item, idx) => (
                <div key={idx} className="flex items-center justify-between bg-[#0a0a0c] rounded-sm px-4 py-3 border-2 border-[#2d2d30]">
                  <span className="text-[#9ca3af] text-sm font-body">{item.label}</span>
                  <kbd className="bg-[#1c1c20] text-[#0092cc] text-xs px-3 py-1.5 rounded-sm font-mono border border-[#0092cc]/30">{item.key}</kbd>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Updates - Website Style */}
        <div className="card-hyfx p-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className={`w-10 h-10 rounded-sm flex items-center justify-center ${
                updateAvailable ? 'bg-[#fcd34d]/10' : 'bg-[#0092cc]/10'
              }`}>
                <RefreshCw size={20} className={updateAvailable ? 'text-[#fcd34d]' : 'text-[#0092cc]'} />
              </div>
              <div>
                <span className="font-hytale font-bold text-white text-sm uppercase tracking-wide">Updates</span>
                <p className="text-[#6b7280] text-xs mt-0.5 font-mono">
                  v{appVersion} {updateAvailable && <span className="text-[#fcd34d]">→ v{latestVersion}</span>}
                </p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              {updateAvailable && (
                <button
                  onClick={() => setShowUpdateModal(true)}
                  className="btn-hyfx-primary px-4 py-2.5 rounded-sm font-hytale font-bold text-xs flex items-center gap-2"
                >
                  <Download size={14} /> Update
                </button>
              )}
              <button
                onClick={checkForUpdates}
                className="btn-hyfx-secondary px-4 py-2.5 rounded-sm font-hytale font-bold text-xs flex items-center gap-2"
              >
                <RefreshCw size={14} /> Check
              </button>
            </div>
          </div>
        </div>

        {/* Tutorial - Website Style */}
        <div className="card-hyfx p-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-sm bg-[#0092cc]/10 flex items-center justify-center">
                <HelpCircle size={20} className="text-[#0092cc]" />
              </div>
              <div>
                <span className="font-hytale font-bold text-white text-sm uppercase tracking-wide">Tutorial</span>
                <p className="text-[#6b7280] text-xs mt-0.5 font-body">Learn how to use OrbisFX Launcher</p>
              </div>
            </div>
            <button
              onClick={handleReplayTutorial}
              className="btn-hyfx-secondary px-4 py-2.5 rounded-sm font-hytale font-bold text-xs flex items-center gap-2"
            >
              <Play size={14} /> Replay
            </button>
          </div>
          {settings.tutorial_completed && (
            <div className="mt-4 flex items-center gap-2 text-green-400 text-xs font-body">
              <CheckCircle size={14} /> Tutorial completed
            </div>
          )}
        </div>

        {/* About - Website Style */}
        <div className="card-hyfx p-8 text-center relative">
          {/* Corner decorations */}
          <div className="corner-tl"></div>
          <div className="corner-tr"></div>
          <div className="corner-bl"></div>
          <div className="corner-br"></div>

          <div className="w-20 h-20 bg-[#0a0a0c] rounded-sm p-4 mx-auto mb-5 border-2 border-[#2d2d30]">
            <img src="/logo.png" alt="OrbisFX" className="w-full h-full object-contain" />
          </div>
          <h3 className="font-hytale font-bold text-white text-lg uppercase tracking-wide">OrbisFX Launcher</h3>
          <p className="text-[#6b7280] text-sm mt-2 font-mono">Version {appVersion}</p>
          <div className="w-16 h-px bg-[#0092cc]/30 mx-auto my-4"></div>
          <p className="text-[#4b5563] text-xs font-body">© 2024 OrbisFX Team. All rights reserved.</p>
        </div>
      </div>
    </div>
  );

  // ============== Render Setup Wizard ==============
  const renderSetupWizard = () => (
    <div className="flex-1 flex flex-col items-center justify-center p-8 relative">
      {/* Background effects */}
      <div className="absolute inset-0 grid-overlay"></div>
      <div className="absolute top-0 right-0 w-96 h-96 bg-[#0092cc] rounded-full blur-[150px] opacity-5 pointer-events-none"></div>

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
            <h1 className="font-hytale font-black text-4xl text-white mb-4 uppercase tracking-wide">Welcome to OrbisFX</h1>
            <p className="text-[#9ca3af] text-lg mb-8 font-body">Advanced graphics enhancement for Hytale</p>
            <p className="text-[#6b7280] text-sm mb-8 font-body">
              This wizard will help you set up OrbisFX and configure your Hytale installation.
            </p>
            <button
              onClick={() => setSetupStep(1)}
              className="btn-hyfx-primary px-8 py-4 font-hytale font-bold text-lg text-white rounded-sm uppercase tracking-wider flex items-center gap-3 mx-auto"
            >
              <Play size={20} /> Get Started
            </button>
          </div>
        )}

        {/* Path Selection Step */}
        {setupStep === 1 && (
          <div className="animate-fade-in">
            <h2 className="font-hytale font-bold text-2xl text-white mb-2 uppercase tracking-wide">Select Game Directory</h2>
            <p className="text-[#9ca3af] mb-6 font-body">Locate your Hytale installation folder containing Hytale.exe</p>

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
                  className="btn-hyfx-secondary px-5 rounded-sm font-hytale font-bold text-sm uppercase flex items-center gap-2"
                >
                  <FolderOpen size={18} /> Browse
                </button>
              </div>
              {validationStatus === 'success' && (
                <p className="text-green-400 text-sm flex items-center gap-2 font-body">
                  <CheckCircle size={14} /> Hytale installation detected!
                </p>
              )}
              {validationStatus === 'error' && installPath && (
                <p className="text-red-400 text-sm flex items-center gap-2 font-body">
                  <AlertTriangle size={14} /> Hytale.exe not found in this directory
                </p>
              )}
            </div>

            <div className="flex gap-4">
              <button
                onClick={() => setSetupStep(0)}
                className="btn-hyfx-secondary px-6 py-3 font-hytale font-bold text-sm rounded-sm uppercase"
              >
                Back
              </button>
              <button
                onClick={() => setSetupStep(2)}
                disabled={validationStatus !== 'success'}
                className="flex-1 btn-hyfx-primary px-6 py-3 font-hytale font-bold text-sm text-white rounded-sm uppercase disabled:opacity-50"
              >
                Continue
              </button>
            </div>
          </div>
        )}

        {/* Install Runtime Step - Website Style */}
        {setupStep === 2 && (
          <div className="animate-fade-in">
            <h2 className="font-hytale font-bold text-2xl text-white mb-2 uppercase tracking-wide">Install OrbisFX Runtime</h2>
            <p className="text-[#9ca3af] mb-6 font-body">Install the graphics runtime to enhance your Hytale experience</p>

            <div className="card-hyfx p-6 mb-6">
              {!isInstalling && !validationResult?.reshade_installed && (
                <div className="text-center">
                  <Download size={48} className="text-[#0092cc] mx-auto mb-4" />
                  <p className="text-white font-hytale font-bold mb-2 uppercase">Ready to Install</p>
                  <p className="text-[#6b7280] text-sm mb-4 font-body">Click below to install the OrbisFX graphics runtime</p>
                  <button
                    onClick={handleInstallRuntime}
                    className="btn-hyfx-primary px-8 py-3 font-hytale font-bold text-white rounded-sm uppercase"
                  >
                    Install OrbisFX
                  </button>
                </div>
              )}

              {isInstalling && (
                <div>
                  <div className="flex justify-between items-center mb-3">
                    <span className="text-[#0092cc] font-mono text-sm">Installing... {installProgress}%</span>
                    <Activity size={16} className="text-[#0092cc] animate-spin" />
                  </div>
                  <ProgressBar progress={installProgress} />
                  <TerminalLog logs={installLogs} />
                </div>
              )}

              {validationResult?.reshade_installed && !isInstalling && (
                <div className="text-center">
                  <CheckCircle size={48} className="text-green-400 mx-auto mb-4" />
                  <p className="text-white font-hytale font-bold mb-2 uppercase">Installation Complete!</p>
                  <p className="text-[#6b7280] text-sm font-body">OrbisFX runtime has been installed successfully</p>
                </div>
              )}
            </div>

            <div className="flex gap-4">
              <button
                onClick={() => setSetupStep(1)}
                disabled={isInstalling}
                className="btn-hyfx-secondary px-6 py-3 font-hytale font-bold text-sm rounded-sm uppercase disabled:opacity-50"
              >
                Back
              </button>
              <button
                onClick={() => setSetupStep(3)}
                disabled={isInstalling || !validationResult?.reshade_installed}
                className="flex-1 btn-hyfx-primary px-6 py-3 font-hytale font-bold text-sm text-white rounded-sm uppercase disabled:opacity-50"
              >
                Continue
              </button>
              {!validationResult?.reshade_installed && !isInstalling && (
                <button
                  onClick={() => setSetupStep(3)}
                  className="text-[#6b7280] hover:text-[#0092cc] text-sm font-body transition-colors"
                >
                  Skip for now
                </button>
              )}
            </div>
          </div>
        )}

        {/* Complete Step - Website Style */}
        {setupStep === 3 && (
          <div className="text-center animate-fade-in">
            <div className="w-20 h-20 bg-[#0092cc]/10 rounded-sm flex items-center justify-center mx-auto mb-6 border-2 border-[#0092cc]/30 shadow-[0_0_30px_rgba(0,146,204,0.3)]">
              <CheckCircle size={40} className="text-[#0092cc]" />
            </div>
            <h2 className="font-hytale font-bold text-2xl text-white mb-2 uppercase tracking-wide">Setup Complete!</h2>
            <p className="text-[#9ca3af] mb-8 font-body">You're all set to start using OrbisFX</p>

            <button
              onClick={async () => {
                await saveSettings({ ...settings, hytale_path: installPath });
                setIsFirstLaunch(false);
                setCurrentPage('home');
              }}
              className="btn-hyfx-primary px-8 py-4 font-hytale font-bold text-lg text-white rounded-sm uppercase tracking-wider flex items-center gap-3 mx-auto"
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
    <div className="flex h-screen bg-[#0a0a0c] relative overflow-hidden flex-col">
      {/* Background Effects */}
      <div className="absolute inset-0 bg-[linear-gradient(rgba(0,146,204,0.03)_1px,transparent_1px),linear-gradient(90deg,rgba(0,146,204,0.03)_1px,transparent_1px)] bg-[size:40px_40px] pointer-events-none"></div>
      <div className="absolute top-0 right-0 w-96 h-96 bg-[#0092cc] rounded-full blur-[150px] opacity-5 pointer-events-none"></div>

      {/* Title Bar - Website Style */}
      <div className="h-10 bg-[#0a0a0c] border-b-2 border-[#2d2d30] flex items-center justify-between px-4 z-20 flex-shrink-0 select-none" style={{ WebkitAppRegion: 'drag' } as React.CSSProperties}>
        <div className="flex items-center gap-2">
          <img src="/logo.png" alt="OrbisFX" className="w-5 h-5" />
          <span className="text-xs uppercase font-hytale font-bold tracking-widest text-[#9ca3af]">OrbisFX Launcher <span className="text-[#0092cc]">v{appVersion}</span></span>
        </div>
        <div className="flex gap-1" style={{ WebkitAppRegion: 'no-drag' } as React.CSSProperties}>
          <button onClick={() => appWindow.minimize()} className="hover:bg-[#2d2d30] p-2 rounded-sm transition-colors text-[#6b7280] hover:text-white">
            <Minus size={14} />
          </button>
          <button onClick={() => exit(0)} className="hover:bg-red-900/50 p-2 rounded-sm transition-colors text-[#6b7280] hover:text-red-400">
            <X size={14} />
          </button>
        </div>
      </div>

      {/* Setup Wizard (shown on first launch) */}
      {currentPage === 'setup' && renderSetupWizard()}

      {/* Main Layout (hidden during setup) */}
      {currentPage !== 'setup' && (
        <div className="flex flex-1 overflow-hidden">
          {/* Sidebar - Website Style */}
          <div className="w-60 bg-[#0a0a0c] border-r-2 border-[#2d2d30] flex flex-col z-10">
            {/* Logo/Brand Area */}
            <div className="p-5 border-b-2 border-[#2d2d30]">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-sm border-2 border-[#2d2d30] p-1 bg-[#141417]">
                  <img src="/logo.png" alt="OrbisFX" className="w-full h-full object-contain" />
                </div>
                <div>
                  <h2 className="font-hytale font-bold text-white text-sm uppercase tracking-wide">OrbisFX</h2>
                  <span className="text-[#0092cc] text-xs font-mono">Launcher</span>
                </div>
              </div>
            </div>

            {/* Navigation - Website Style */}
            <nav className="flex-1 p-4 space-y-2">
              <p className="text-[#4b5563] text-xs uppercase font-hytale font-bold tracking-wider mb-3 px-3">Navigation</p>
              <button
                id="nav-home"
                onClick={() => setCurrentPage('home')}
                className={`w-full p-3.5 rounded-sm flex items-center gap-3 transition-all duration-200 group border-l-2 ${
                  currentPage === 'home'
                    ? 'bg-[#141417] text-[#0092cc] border-[#0092cc] shadow-[0_0_10px_rgba(0,146,204,0.1)]'
                    : 'text-[#9ca3af] hover:text-white hover:bg-[#141417] border-transparent hover:border-[#4a4a50]'
                }`}
              >
                <Home size={18} className={`transition-transform duration-200 ${currentPage === 'home' ? '' : 'group-hover:scale-110'}`} />
                <span className="font-hytale text-sm font-bold uppercase tracking-wide">Home</span>
                {currentPage === 'home' && <ChevronRight size={14} className="ml-auto" />}
              </button>

              <button
                id="nav-presets"
                onClick={() => setCurrentPage('presets')}
                className={`w-full p-3.5 rounded-sm flex items-center gap-3 transition-all duration-200 group border-l-2 ${
                  currentPage === 'presets'
                    ? 'bg-[#141417] text-[#0092cc] border-[#0092cc] shadow-[0_0_10px_rgba(0,146,204,0.1)]'
                    : 'text-[#9ca3af] hover:text-white hover:bg-[#141417] border-transparent hover:border-[#4a4a50]'
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
                id="nav-settings"
                onClick={() => setCurrentPage('settings')}
                className={`w-full p-3.5 rounded-sm flex items-center gap-3 transition-all duration-200 group border-l-2 ${
                  currentPage === 'settings'
                    ? 'bg-[#141417] text-[#0092cc] border-[#0092cc] shadow-[0_0_10px_rgba(0,146,204,0.1)]'
                    : 'text-[#9ca3af] hover:text-white hover:bg-[#141417] border-transparent hover:border-[#4a4a50]'
                }`}
              >
                <Settings size={18} className={`transition-transform duration-200 ${currentPage === 'settings' ? '' : 'group-hover:scale-110'}`} />
                <span className="font-hytale text-sm font-bold uppercase tracking-wide">Settings</span>
                {currentPage === 'settings' && <ChevronRight size={14} className="ml-auto" />}
              </button>
            </nav>

            {/* Sidebar Footer - Website Style */}
            <div className="p-4 border-t-2 border-[#2d2d30] space-y-3">
              {/* Status Card */}
              <div className="bg-[#141417] p-4 rounded-sm border-2 border-[#2d2d30]">
                <div className="flex items-center gap-3 mb-3">
                  <div className={`w-3 h-3 rounded-full ${validationStatus === 'success' ? 'bg-green-400 shadow-[0_0_8px_rgba(74,222,128,0.5)]' : 'bg-[#6b7280]'} ${validationStatus === 'success' ? 'animate-pulse' : ''}`}></div>
                  <span className="text-white text-xs uppercase font-hytale font-bold tracking-wide">
                    {validationStatus === 'success' ? 'Ready to Play' : 'Setup Required'}
                  </span>
                </div>
                {validationResult?.reshade_installed && (
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-[#6b7280] font-body">Runtime</span>
                    <span className={validationResult.reshade_enabled ? 'text-green-400 font-mono' : 'text-[#fcd34d] font-mono'}>
                      {validationResult.reshade_enabled ? 'Enabled' : 'Disabled'}
                    </span>
                  </div>
                )}
                {!validationResult?.reshade_installed && validationStatus === 'success' && (
                  <p className="text-[#fcd34d] text-xs font-body">Runtime not installed</p>
                )}
              </div>

              {/* Discord Button - Website Style */}
              <button
                id="nav-discord"
                onClick={() => shellOpen('https://discord.com/invite/OrbisFX')}
                className="w-full p-3 rounded-sm flex items-center justify-center gap-2 bg-[#5865F2] hover:bg-[#4752C4] text-white transition-all duration-200 border-2 border-[#4752C4] hover:shadow-[0_0_15px_rgba(88,101,242,0.3)]"
              >
                <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028 14.09 14.09 0 0 0 1.226-1.994.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z"/>
                </svg>
                <span className="font-hytale font-bold text-sm uppercase tracking-wide">Join Community</span>
              </button>
            </div>
          </div>

          {/* Main Content */}
          <main className="flex-1 flex flex-col overflow-hidden bg-[#0a0a0c]">
            {currentPage === 'home' && renderHomePage()}
            {currentPage === 'presets' && renderPresetsPage()}
            {currentPage === 'settings' && renderSettingsPage()}
          </main>
        </div>
      )}

      {/* Preset Detail Modal - Website Style */}
      {selectedPreset && (
        <div
          className="fixed inset-0 bg-black/90 z-50 flex items-center justify-center p-8 backdrop-blur-sm"
          onClick={() => setSelectedPreset(null)}
        >
          <div
            className="bg-[#0a0a0c] border-2 border-[#2d2d30] rounded-sm max-w-4xl w-full max-h-[90vh] overflow-hidden flex flex-col relative"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Corner decorations */}
            <div className="corner-tl"></div>
            <div className="corner-tr"></div>
            <div className="corner-bl"></div>
            <div className="corner-br"></div>

            {/* Modal Header */}
            <div className="flex items-center justify-between p-4 border-b-2 border-[#2d2d30]">
              <div>
                <h2 className="font-hytale font-bold text-xl text-white uppercase tracking-wide">{selectedPreset.name}</h2>
                <p className="text-[#6b7280] text-sm font-body">by <span className="text-[#0092cc]">{selectedPreset.author}</span> • <span className="font-mono">v{selectedPreset.version}</span></p>
              </div>
              <button
                onClick={() => setSelectedPreset(null)}
                className="text-[#6b7280] hover:text-white transition-colors p-2 hover:bg-[#2d2d30] rounded-sm"
              >
                <X size={24} />
              </button>
            </div>

            {/* Modal Content */}
            <div className="flex-1 overflow-y-auto p-6">
              <div className="grid grid-cols-5 gap-6">
                {/* Image Gallery - Left side (3 cols) */}
                <div className="col-span-3">
                  {/* Main Image */}
                  <div className="aspect-video bg-[#141417] rounded-sm overflow-hidden mb-3 border-2 border-[#2d2d30]">
                    {(() => {
                      const allImages = [selectedPreset.thumbnail, ...selectedPreset.images];
                      const currentImage = allImages[currentImageIndex] || selectedPreset.thumbnail;
                      return (
                        <img
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
                          className={`flex-shrink-0 w-20 h-14 rounded-sm overflow-hidden border-2 transition-colors ${
                            currentImageIndex === idx
                              ? 'border-[#0092cc] shadow-[0_0_10px_rgba(0,146,204,0.3)]'
                              : 'border-[#2d2d30] hover:border-[#4a4a50]'
                          }`}
                        >
                          <img src={img} alt="" className="w-full h-full object-cover" />
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
                        className="p-2 bg-[#141417] rounded-sm border-2 border-[#2d2d30] hover:border-[#4a4a50] transition-colors"
                      >
                        <ChevronLeft size={20} className="text-white" />
                      </button>
                      <span className="text-[#6b7280] text-sm font-mono">
                        {currentImageIndex + 1} / {selectedPreset.images.length + 1}
                      </span>
                      <button
                        onClick={() => setCurrentImageIndex(prev =>
                          prev === selectedPreset.images.length ? 0 : prev + 1
                        )}
                        className="p-2 bg-[#141417] rounded-sm border-2 border-[#2d2d30] hover:border-[#4a4a50] transition-colors"
                      >
                        <ChevronRight size={20} className="text-white" />
                      </button>
                    </div>
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
                    <h3 className="font-hytale font-bold text-white text-sm uppercase mb-2 tracking-wide">Description</h3>
                    <p className="text-[#9ca3af] text-sm leading-relaxed font-body">
                      {selectedPreset.long_description || selectedPreset.description}
                    </p>
                  </div>

                  {/* Features */}
                  {selectedPreset.features && selectedPreset.features.length > 0 && (
                    <div>
                      <h3 className="font-hytale font-bold text-white text-sm uppercase mb-2 tracking-wide">Features</h3>
                      <ul className="space-y-1">
                        {selectedPreset.features.map((feature, idx) => (
                          <li key={idx} className="text-[#9ca3af] text-sm flex items-center gap-2 font-body">
                            <CheckCircle size={14} className="text-green-400" />
                            {feature}
                          </li>
                        ))}
                      </ul>
                    </div>
                  )}

                  {/* Install Button */}
                  <div className="pt-4 border-t-2 border-[#2d2d30]">
                    <button
                      onClick={() => {
                        handleDownloadPreset(selectedPreset);
                        setSelectedPreset(null);
                      }}
                      disabled={!installPath}
                      className="w-full btn-hyfx-primary py-3 font-hytale font-bold text-white rounded-sm flex items-center justify-center gap-2 disabled:opacity-50"
                    >
                      <Download size={18} />
                      {installedPresets.some(ip => ip.id === selectedPreset.id)
                        ? 'Reinstall Preset'
                        : 'Install Preset'}
                    </button>
                    {!installPath && (
                      <p className="text-[#fcd34d] text-xs text-center mt-2 font-body">
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

        // Render centered modal - Website Style
        if (isModal) {
          return (
            <div className="fixed inset-0 bg-black/90 flex items-center justify-center z-50 backdrop-blur-sm">
              <div className="bg-[#0a0a0c] rounded-sm p-8 max-w-lg w-full mx-4 border-2 border-[#2d2d30] shadow-2xl relative">
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
                      className={`flex-1 h-1 rounded-sm transition-colors ${
                        idx <= tutorialStep ? 'bg-[#0092cc]' : 'bg-[#2d2d30]'
                      }`}
                    />
                  ))}
                </div>

                {/* Step content */}
                <div className="text-center mb-8">
                  <div className="mb-4 flex justify-center">{currentStep.icon}</div>
                  <h3 className="font-hytale font-bold text-2xl text-white mb-3 uppercase tracking-wide">
                    {currentStep.title}
                  </h3>
                  <p className="text-[#9ca3af] text-lg leading-relaxed font-body">
                    {currentStep.description}
                  </p>
                </div>

                {/* Step counter */}
                <p className="text-center text-[#6b7280] text-sm mb-6 font-mono">
                  Step {tutorialStep + 1} of {TUTORIAL_STEPS.length}
                </p>

                {/* Buttons */}
                <div className="flex gap-3">
                  <button
                    onClick={handleTutorialSkip}
                    className="flex-1 btn-hyfx-secondary px-4 py-3 rounded-sm font-hytale font-bold uppercase tracking-wide"
                  >
                    Skip Tutorial
                  </button>
                  <button
                    onClick={handleTutorialNext}
                    className="flex-1 px-4 py-3 btn-hyfx-primary text-white rounded-sm font-hytale font-bold flex items-center justify-center gap-2 uppercase tracking-wide"
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

        // Render popover anchored to element - Website Style
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
                  boxShadow: `0 0 0 9999px rgba(0, 0, 0, 0.85), inset 0 0 0 2px #0092cc`,
                  borderRadius: '4px',
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
                className="fixed z-50 ring-2 ring-[#0092cc] rounded-sm pointer-events-none animate-pulse"
                style={{
                  top: anchorRect.top - 8,
                  left: anchorRect.left - 8,
                  width: anchorRect.width + 16,
                  height: anchorRect.height + 16,
                  boxShadow: '0 0 20px rgba(0, 146, 204, 0.5)',
                }}
              />
            )}

            {/* Popover - Website Style */}
            <div
              className="fixed z-50 bg-[#0a0a0c] rounded-sm p-6 max-w-sm border-2 border-[#2d2d30] shadow-2xl"
              style={getPopoverStyle()}
            >
              {/* Arrow pointing to anchor */}
              <div
                className="absolute w-3 h-3 bg-[#0a0a0c] border-l-2 border-b-2 border-[#2d2d30] transform -rotate-45"
                style={{ left: -8, top: 20 }}
              />

              {/* Progress indicator */}
              <div className="flex gap-1 mb-4">
                {TUTORIAL_STEPS.map((_, idx) => (
                  <div
                    key={idx}
                    className={`flex-1 h-1 rounded-sm transition-colors ${
                      idx <= tutorialStep ? 'bg-[#0092cc]' : 'bg-[#2d2d30]'
                    }`}
                  />
                ))}
              </div>

              {/* Step content */}
              <div className="mb-4">
                <div className="flex items-center gap-3 mb-3">
                  <div className="flex-shrink-0">{React.cloneElement(currentStep.icon as React.ReactElement, { size: 28 })}</div>
                  <h3 className="font-hytale font-bold text-lg text-white uppercase tracking-wide">
                    {currentStep.title}
                  </h3>
                </div>
                <p className="text-[#9ca3af] text-sm leading-relaxed font-body">
                  {currentStep.description}
                </p>
              </div>

              {/* Step counter */}
              <p className="text-[#6b7280] text-xs mb-4 font-mono">
                Step {tutorialStep + 1} of {TUTORIAL_STEPS.length}
              </p>

              {/* Buttons */}
              <div className="flex gap-2">
                <button
                  onClick={handleTutorialSkip}
                  className="flex-1 btn-hyfx-secondary px-3 py-2 rounded-sm text-sm font-hytale font-bold uppercase"
                >
                  Skip
                </button>
                <button
                  onClick={handleTutorialNext}
                  className="flex-1 px-3 py-2 btn-hyfx-primary text-white rounded-sm font-hytale font-bold flex items-center justify-center gap-1 text-sm uppercase"
                >
                  Next <ChevronRight size={16} />
                </button>
              </div>
            </div>
          </>
        );
      })()}

      {/* Update Available Modal - Website Style */}
      {showUpdateModal && (
        <div className="fixed inset-0 bg-black/90 flex items-center justify-center z-50 backdrop-blur-sm">
          <div className="bg-[#0a0a0c] rounded-sm p-8 max-w-md w-full mx-4 border-2 border-[#2d2d30] shadow-2xl relative">
            {/* Corner decorations */}
            <div className="corner-tl"></div>
            <div className="corner-tr"></div>
            <div className="corner-bl"></div>
            <div className="corner-br"></div>

            {/* Header with icon */}
            <div className="flex items-center gap-4 mb-6">
              <div className={`w-14 h-14 ${downloadedUpdatePath ? 'bg-green-500/20' : 'bg-[#0092cc]/20'} rounded-sm flex items-center justify-center flex-shrink-0 border-2 ${downloadedUpdatePath ? 'border-green-500/30' : 'border-[#0092cc]/30'}`}>
                {downloadedUpdatePath ? (
                  <CheckCircle className="w-7 h-7 text-green-400" />
                ) : (
                  <RefreshCw className="w-7 h-7 text-[#0092cc]" />
                )}
              </div>
              <div>
                <h3 className="font-hytale font-bold text-xl text-white uppercase tracking-wide">
                  {downloadedUpdatePath ? 'Update Ready' : 'Update Available'}
                </h3>
                <p className="text-[#6b7280] text-sm font-body">
                  {downloadedUpdatePath
                    ? 'Update downloaded successfully'
                    : `Version ${latestVersion} is ready to download`}
                </p>
              </div>
            </div>

            {/* Version badge */}
            <div className="bg-[#141417] border-2 border-[#2d2d30] rounded-sm p-4 mb-6">
              <div className="flex items-center justify-between">
                <span className="text-[#6b7280] text-sm font-body">Current version</span>
                <span className="text-[#9ca3af] font-mono text-sm">v{appVersion}</span>
              </div>
              <div className="flex items-center justify-between mt-2">
                <span className="text-[#6b7280] text-sm font-body">Latest version</span>
                <span className="text-[#0092cc] font-mono text-sm font-bold">v{latestVersion}</span>
              </div>
            </div>

            <p className="text-[#9ca3af] mb-6 text-sm leading-relaxed font-body">
              {downloadedUpdatePath
                ? 'Click "Install & Restart" to automatically install the update and restart the application.'
                : 'A new version of OrbisFX Launcher is available. Would you like to download it now?'}
            </p>

            {/* Buttons - Different states based on download status */}
            {downloadedUpdatePath ? (
              <div className="flex gap-3">
                <button
                  onClick={handleCloseUpdateModal}
                  className="flex-1 btn-hyfx-secondary px-4 py-3 rounded-sm font-hytale font-bold uppercase"
                >
                  Later
                </button>
                <button
                  onClick={handleInstallUpdateAndRestart}
                  disabled={isInstallingUpdate}
                  className="flex-1 px-4 py-3 btn-hyfx-primary text-white rounded-sm font-hytale font-bold flex items-center justify-center gap-2 uppercase"
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
                  className="flex-1 btn-hyfx-secondary px-4 py-3 rounded-sm font-hytale font-bold uppercase"
                >
                  Later
                </button>
                <button
                  onClick={handleDownloadUpdate}
                  disabled={isDownloadingUpdate}
                  className="flex-1 px-4 py-3 btn-hyfx-primary text-white rounded-sm font-hytale font-bold flex items-center justify-center gap-2 uppercase"
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
