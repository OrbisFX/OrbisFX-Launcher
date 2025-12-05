import React, { useState, useEffect, useRef } from 'react';
import {
  FolderOpen, Download, ShieldCheck, CheckCircle, Activity, Settings,
  AlertTriangle, Trash2, Minus, X, Play, Home, Palette, RefreshCw,
  ExternalLink, Search, Filter, ChevronRight, Power, Gamepad2,
  Star, Upload, Share2, Keyboard, ChevronLeft, Eye, HelpCircle
} from 'lucide-react';
import { invoke } from '@tauri-apps/api/core';
import { getCurrentWindow } from '@tauri-apps/api/window';
import { exit } from '@tauri-apps/plugin-process';
import { open, save } from '@tauri-apps/plugin-dialog';

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

// Tutorial steps configuration
const TUTORIAL_STEPS = [
  {
    title: "Welcome to OrbisFX Launcher!",
    description: "This quick tutorial will guide you through the main features of the application. You can skip at any time.",
    icon: "🎮"
  },
  {
    title: "Home Dashboard",
    description: "The Home page shows your current setup status, active preset, and quick actions. You can launch Hytale and toggle ReShade from here.",
    icon: "🏠"
  },
  {
    title: "Preset Library",
    description: "Browse and install graphics presets from the community. Click on any preset to see more details and screenshots.",
    icon: "🎨"
  },
  {
    title: "Installing Presets",
    description: "Click 'Install' on any preset to download it. You can then activate it from your installed presets section.",
    icon: "📥"
  },
  {
    title: "Settings",
    description: "Configure your Hytale installation path and other preferences in the Settings page.",
    icon: "⚙️"
  },
  {
    title: "Join Our Community",
    description: "Click the Discord button in the sidebar to join our community for support, preset sharing, and updates!",
    icon: "💬"
  },
  {
    title: "You're All Set!",
    description: "That's everything you need to know. Enjoy enhancing your Hytale experience with OrbisFX!",
    icon: "🚀"
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

  const handleDownloadUpdate = async () => {
    if (!updateDownloadUrl) return;
    setIsDownloadingUpdate(true);
    try {
      const result = await invoke('download_update', { downloadUrl: updateDownloadUrl }) as {
        success: boolean;
        path?: string;
        error?: string
      };
      if (result.success) {
        setShowUpdateModal(false);
        // Show success message
        setError(null);
        alert(`Update downloaded successfully!\n\nSaved to: ${result.path}\n\nPlease close the launcher and run the new version.`);
      } else {
        setError(result.error || 'Failed to download update');
      }
    } catch (e) {
      console.error('Failed to download update:', e);
      setError(`Failed to download update: ${e}`);
    }
    setIsDownloadingUpdate(false);
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
    <div className="flex-1 p-8 overflow-y-auto">
      <div className="max-w-4xl mx-auto">
        {/* Hero Section */}
        <div className="bg-gradient-to-br from-[#141417] to-[#0e0e10] border border-[#2d2d30] rounded-lg p-8 mb-8 relative overflow-hidden">
          <div className="absolute top-0 right-0 w-64 h-64 bg-[#0092cc] rounded-full blur-[120px] opacity-10"></div>

          <div className="flex items-center gap-8 relative z-10">
            <img src="/logo.png" alt="OrbisFX Logo" className="w-24 h-24 object-contain" />
            <div className="flex-1">
              <h1 className="font-hytale font-black text-4xl text-white mb-2">Welcome to OrbisFX</h1>
              <p className="text-[#9ca3af] text-sm mb-4">Advanced graphics enhancement for Hytale</p>

              {validationStatus === 'success' ? (
                <div className="flex flex-col gap-2">
                  <button
                    onClick={handleLaunchGame}
                    disabled={!canLaunchGame}
                    className={`px-8 py-4 font-hytale font-bold text-lg text-white rounded-sm uppercase tracking-wider flex items-center gap-3 ${
                      canLaunchGame
                        ? 'btn-hyfx-primary shadow-[0_0_20px_rgba(0,146,204,0.3)]'
                        : 'bg-[#2d2d30] cursor-not-allowed opacity-60'
                    }`}
                  >
                    <Play size={24} /> Launch Hytale
                  </button>
                  {!validationResult?.reshade_installed && (
                    <div className="flex items-center gap-2 text-yellow-400 text-sm">
                      <AlertTriangle size={16} />
                      <span>The graphics runtime is not installed. Install OrbisFX to play!</span>
                    </div>
                  )}
                  {validationResult?.reshade_installed && !validationResult?.reshade_enabled && (
                    <div className="flex items-center gap-2 text-yellow-400 text-sm">
                      <AlertTriangle size={16} />
                      <span>The graphics runtime is disabled. Enable it in Settings to play.</span>
                    </div>
                  )}
                </div>
              ) : (
                <button
                  onClick={() => setCurrentPage('settings')}
                  className="btn-hyfx-secondary px-6 py-3 font-hytale font-bold text-sm rounded-sm uppercase flex items-center gap-2"
                >
                  <Settings size={18} /> Configure Game Path
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Status Cards */}
        <div className="grid grid-cols-3 gap-4 mb-8">
          {/* Game Status */}
          <div className="bg-[#141417] border border-[#2d2d30] rounded-lg p-5">
            <div className="flex items-center gap-3 mb-3">
              <Gamepad2 size={20} className="text-[#0092cc]" />
              <span className="font-hytale font-bold text-sm text-white uppercase">Game Status</span>
            </div>
            <p className={`text-sm ${validationStatus === 'success' ? 'text-green-400' : 'text-[#6b7280]'}`}>
              {validationStatus === 'success' ? '✓ Ready to play' : 'Not configured'}
            </p>
          </div>

          {/* Runtime Status */}
          <div className="bg-[#141417] border border-[#2d2d30] rounded-lg p-5">
            <div className="flex items-center gap-3 mb-3">
              <ShieldCheck size={20} className="text-[#0092cc]" />
              <span className="font-hytale font-bold text-sm text-white uppercase">Runtime</span>
            </div>
            <p className={`text-sm ${validationResult?.reshade_installed ? (validationResult?.reshade_enabled ? 'text-green-400' : 'text-yellow-400') : 'text-[#6b7280]'}`}>
              {validationResult?.reshade_installed
                ? (validationResult?.reshade_enabled ? '✓ Enabled' : '◐ Disabled')
                : 'Not installed'}
            </p>
          </div>

          {/* Updates */}
          <div className="bg-[#141417] border border-[#2d2d30] rounded-lg p-5">
            <div className="flex items-center gap-3 mb-3">
              <RefreshCw size={20} className="text-[#0092cc]" />
              <span className="font-hytale font-bold text-sm text-white uppercase">Updates</span>
            </div>
            <p className={`text-sm ${updateAvailable ? 'text-yellow-400' : 'text-green-400'}`}>
              {updateAvailable ? `v${latestVersion} available` : '✓ Up to date'}
            </p>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="bg-[#141417] border border-[#2d2d30] rounded-lg p-6">
          <h2 className="font-hytale font-bold text-lg text-white mb-4 uppercase tracking-wider">Quick Actions</h2>
          <div className="grid grid-cols-2 gap-4">
            <button
              onClick={() => setCurrentPage('presets')}
              className="bg-[#1c1c20] hover:bg-[#252528] border border-[#2d2d30] rounded-lg p-4 text-left transition-colors group"
            >
              <Palette size={24} className="text-[#0092cc] mb-2 group-hover:scale-110 transition-transform" />
              <p className="font-hytale font-bold text-white text-sm">Browse Presets</p>
              <p className="text-[#6b7280] text-xs mt-1">Explore the preset library</p>
            </button>

            {validationResult?.reshade_installed ? (
              <button
                onClick={handleUninstallRuntime}
                disabled={isInstalling}
                className="bg-[#1c1c20] hover:bg-[#252528] border border-[#2d2d30] rounded-lg p-4 text-left transition-colors group"
              >
                <Trash2 size={24} className="text-red-400 mb-2 group-hover:scale-110 transition-transform" />
                <p className="font-hytale font-bold text-white text-sm">Uninstall OrbisFX</p>
                <p className="text-[#6b7280] text-xs mt-1">Remove runtime from game</p>
              </button>
            ) : (
              <button
                onClick={handleInstallRuntime}
                disabled={isInstalling || validationStatus !== 'success'}
                className="bg-[#1c1c20] hover:bg-[#252528] border border-[#2d2d30] rounded-lg p-4 text-left transition-colors group disabled:opacity-50"
              >
                <Download size={24} className="text-[#0092cc] mb-2 group-hover:scale-110 transition-transform" />
                <p className="font-hytale font-bold text-white text-sm">Install OrbisFX</p>
                <p className="text-[#6b7280] text-xs mt-1">Set up graphics runtime</p>
              </button>
            )}
          </div>
        </div>

        {/* Installation Progress */}
        {isInstalling && (
          <div className="mt-6 bg-[#141417] border border-[#2d2d30] rounded-lg p-6">
            <div className="flex justify-between items-center mb-3">
              <span className="text-[#0092cc] font-mono text-sm">Installing... {installProgress}%</span>
              <Activity size={16} className="text-[#0092cc] animate-spin" />
            </div>
            <ProgressBar progress={installProgress} />
            <TerminalLog logs={installLogs} />
          </div>
        )}

        {error && (
          <div className="mt-4 bg-red-900/20 border border-red-900/50 text-red-400 px-4 py-3 rounded-lg flex items-center gap-3 text-sm">
            <AlertTriangle size={16} /> {error}
            <button onClick={() => setError(null)} className="ml-auto hover:text-white">
              <X size={16} />
            </button>
          </div>
        )}
      </div>
    </div>
  );

  // ============== Render Presets Page ==============
  const renderPresetsPage = () => (
    <div className="flex-1 p-8 overflow-y-auto">
      <div className="max-w-5xl mx-auto">
        <header className="mb-6">
          <h1 className="font-hytale font-black text-3xl text-white mb-2">Preset Library</h1>
          <p className="text-[#9ca3af] text-sm">Browse and install graphics presets from the community</p>
        </header>

        {/* Search and Filter */}
        <div className="flex gap-4 mb-6">
          <div className="flex-1 bg-[#141417] border border-[#2d2d30] rounded-lg flex items-center px-4">
            <Search size={18} className="text-[#6b7280]" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search presets..."
              className="bg-transparent w-full py-3 px-3 text-white outline-none placeholder-[#6b7280]"
            />
          </div>
          <div className="flex gap-2">
            {categories.map(cat => (
              <button
                key={cat}
                onClick={() => setSelectedCategory(cat)}
                className={`px-4 py-2 rounded-lg font-hytale text-sm capitalize transition-colors ${
                  selectedCategory === cat
                    ? 'bg-[#0092cc] text-white'
                    : 'bg-[#141417] border border-[#2d2d30] text-[#9ca3af] hover:text-white'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>
        </div>

        {/* Installed Presets Section */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-hytale font-bold text-lg text-white flex items-center gap-2">
              <CheckCircle size={18} className="text-green-400" /> Installed Presets
            </h2>
            <button
              onClick={handleImportPreset}
              disabled={!installPath}
              className="btn-hyfx-secondary px-4 py-2 rounded font-hytale text-sm flex items-center gap-2 disabled:opacity-50"
            >
              <Upload size={16} /> Import Local
            </button>
          </div>

          {installedPresets.length === 0 ? (
            <div className="text-center py-8 bg-[#141417] border border-[#2d2d30] rounded-lg">
              <Upload size={32} className="text-[#2d2d30] mx-auto mb-3" />
              <p className="text-[#6b7280] text-sm">No presets installed yet</p>
              <p className="text-[#4b5563] text-xs mt-1">Download from community or import your own</p>
            </div>
          ) : (
            <div className="grid grid-cols-3 gap-4">
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
                  className={`bg-[#141417] border rounded-lg p-4 relative cursor-pointer transition-all ${
                    preset.is_active
                      ? 'border-green-500 ring-1 ring-green-500/30'
                      : 'border-[#2d2d30] hover:border-[#0092cc]/50'
                  }`}
                  onClick={() => !preset.is_active && handleActivatePreset(preset.id)}
                >
                  {/* Top row: Radio + badges + favorite */}
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex items-center gap-2">
                      <div
                        className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                          preset.is_active
                            ? 'border-green-500 bg-green-500'
                            : 'border-[#4b5563]'
                        }`}
                      >
                        {preset.is_active && (
                          <div className="w-2 h-2 rounded-full bg-white"></div>
                        )}
                      </div>
                      {preset.is_local && (
                        <span className="bg-[#0092cc]/20 text-[#0092cc] text-xs px-2 py-0.5 rounded">Local</span>
                      )}
                    </div>
                    <div className="flex items-center gap-1">
                      {preset.is_active && (
                        <span className="bg-green-500 text-white text-xs px-2 py-0.5 rounded font-medium">Active</span>
                      )}
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleToggleFavorite(preset.id);
                        }}
                        className={`p-1 rounded transition-colors ${
                          preset.is_favorite
                            ? 'text-yellow-400 hover:text-yellow-300'
                            : 'text-[#4b5563] hover:text-yellow-400'
                        }`}
                      >
                        <Star size={16} fill={preset.is_favorite ? 'currentColor' : 'none'} />
                      </button>
                    </div>
                  </div>

                  <p className="font-hytale font-bold text-white">{preset.name}</p>
                  <p className="text-[#6b7280] text-xs mt-1">v{preset.version}</p>
                  <p className="text-[#4b5563] text-xs mt-1 truncate">{preset.filename}</p>

                  {/* Action buttons */}
                  <div className="flex items-center gap-3 mt-3">
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleExportPreset(preset.id, preset.filename);
                      }}
                      className="text-[#0092cc] hover:text-[#00b4ff] text-xs flex items-center gap-1"
                    >
                      <Share2 size={12} /> Export
                    </button>
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleDeletePreset(preset.id);
                      }}
                      className="text-red-400 hover:text-red-300 text-xs flex items-center gap-1"
                    >
                      <Trash2 size={12} /> Remove
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Available Presets */}
        <h2 className="font-hytale font-bold text-lg text-white mb-4 flex items-center gap-2">
          <Palette size={18} className="text-[#0092cc]" /> Available Presets
        </h2>

        {presetsLoading ? (
          <div className="text-center py-12">
            <Activity size={32} className="text-[#0092cc] animate-spin mx-auto mb-4" />
            <p className="text-[#9ca3af]">Loading presets...</p>
          </div>
        ) : filteredPresets.length === 0 ? (
          <div className="text-center py-12 bg-[#141417] border border-[#2d2d30] rounded-lg">
            <Palette size={48} className="text-[#2d2d30] mx-auto mb-4" />
            <p className="text-[#6b7280]">No presets found</p>
            <p className="text-[#4b5563] text-sm mt-1">Check back later or try a different search</p>
          </div>
        ) : (
          <div className="grid grid-cols-2 gap-4">
            {filteredPresets.map(preset => {
              const isInstalled = installedPresets.some(ip => ip.id === preset.id);
              const installedVersion = installedPresets.find(ip => ip.id === preset.id)?.version;
              const hasUpdate = isInstalled && installedVersion && installedVersion !== preset.version;

              return (
                <div
                  key={preset.id}
                  className={`bg-[#141417] border rounded-lg overflow-hidden transition-colors group cursor-pointer ${
                    isInstalled ? 'border-green-900/50' : 'border-[#2d2d30] hover:border-[#0092cc]/50'
                  }`}
                  onClick={() => {
                    setSelectedPreset(preset);
                    setCurrentImageIndex(0);
                  }}
                >
                  {/* Thumbnail */}
                  <div className="h-32 bg-[#0a0a0c] relative overflow-hidden">
                    {preset.thumbnail ? (
                      <img src={preset.thumbnail} alt={preset.name} className="w-full h-full object-cover" />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center">
                        <Palette size={32} className="text-[#2d2d30]" />
                      </div>
                    )}
                    <div className="absolute top-2 left-2 bg-[#0092cc]/80 text-white text-xs px-2 py-0.5 rounded capitalize">
                      {preset.category}
                    </div>
                    {isInstalled && (
                      <div className="absolute top-2 right-2 bg-green-500/80 text-white text-xs px-2 py-0.5 rounded flex items-center gap-1">
                        <CheckCircle size={10} /> Installed
                      </div>
                    )}
                    {/* View indicator on hover */}
                    <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                      <div className="bg-[#0092cc] text-white px-3 py-1.5 rounded-full text-sm font-hytale flex items-center gap-2">
                        <Eye size={14} /> View Details
                      </div>
                    </div>
                  </div>

                  {/* Info */}
                  <div className="p-4">
                    <div className="flex justify-between items-start mb-2">
                      <div>
                        <h3 className="font-hytale font-bold text-white">{preset.name}</h3>
                        <p className="text-[#6b7280] text-xs">by {preset.author}</p>
                      </div>
                      <span className="text-[#4b5563] text-xs">v{preset.version}</span>
                    </div>
                    <p className="text-[#9ca3af] text-sm mb-4 line-clamp-2">{preset.description}</p>

                    <div className="flex gap-2">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleDownloadPreset(preset);
                        }}
                        disabled={!installPath}
                        className={`flex-1 py-2 font-hytale font-bold text-sm text-white rounded flex items-center justify-center gap-2 disabled:opacity-50 ${
                          isInstalled
                            ? 'bg-[#2d2d30] hover:bg-[#3d3d40]'
                            : 'btn-hyfx-primary'
                        }`}
                      >
                        <Download size={16} /> {isInstalled ? (hasUpdate ? 'Update' : 'Reinstall') : 'Install'}
                      </button>
                    </div>
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
    <div className="flex-1 p-8 overflow-y-auto">
      <div className="max-w-3xl mx-auto">
        <header className="mb-8">
          <h1 className="font-hytale font-black text-3xl text-white mb-2">Settings</h1>
          <p className="text-[#9ca3af] text-sm">Configure OrbisFX and manage your installation</p>
        </header>

        <div className="space-y-6">
          {/* Game Path */}
          <div className="bg-[#141417] border border-[#2d2d30] rounded-lg p-6">
            <div className="flex items-center gap-3 mb-4">
              <FolderOpen size={20} className="text-[#0092cc]" />
              <span className="font-hytale font-bold text-white uppercase">Game Installation Path</span>
            </div>
            <div className="flex gap-3">
              <input
                type="text"
                value={installPath}
                onChange={(e) => setInstallPath(e.target.value)}
                placeholder="Select Hytale installation folder..."
                className="flex-1 bg-[#0a0a0c] border border-[#2d2d30] rounded px-4 py-3 text-white font-mono text-sm outline-none focus:border-[#0092cc] transition-colors"
              />
              <button
                onClick={handleBrowse}
                className="btn-hyfx-secondary px-5 rounded font-hytale font-bold text-sm uppercase flex items-center gap-2"
              >
                <FolderOpen size={18} /> Browse
              </button>
            </div>
            {validationStatus === 'success' && (
              <p className="text-green-400 text-sm mt-3 flex items-center gap-2">
                <CheckCircle size={14} /> Hytale installation detected
              </p>
            )}
            {validationStatus === 'error' && (
              <p className="text-red-400 text-sm mt-3 flex items-center gap-2">
                <AlertTriangle size={14} /> Invalid path - Hytale.exe not found
              </p>
            )}
          </div>

          {/* Runtime Toggle */}
          <div className="bg-[#141417] border border-[#2d2d30] rounded-lg p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <Power size={20} className="text-[#0092cc]" />
                <div>
                  <span className="font-hytale font-bold text-white uppercase block">Runtime Status</span>
                  <span className="text-[#6b7280] text-sm">Enable or disable the graphics runtime without uninstalling</span>
                </div>
              </div>
              {validationResult?.reshade_installed && (
                <button
                  onClick={() => handleToggleRuntime(!validationResult?.reshade_enabled)}
                  className={`relative w-14 h-7 rounded-full transition-colors ${
                    validationResult?.reshade_enabled ? 'bg-[#0092cc]' : 'bg-[#2d2d30]'
                  }`}
                >
                  <div className={`absolute top-1 w-5 h-5 bg-white rounded-full transition-transform ${
                    validationResult?.reshade_enabled ? 'translate-x-8' : 'translate-x-1'
                  }`} />
                </button>
              )}
              {!validationResult?.reshade_installed && (
                <span className="text-[#6b7280] text-sm">Not installed</span>
              )}
            </div>
          </div>

          {/* Runtime Installation */}
          <div className="bg-[#141417] border border-[#2d2d30] rounded-lg p-6">
            <div className="flex items-center gap-3 mb-4">
              <Download size={20} className="text-[#0092cc]" />
              <span className="font-hytale font-bold text-white uppercase">OrbisFX Installation</span>
            </div>
            <p className="text-[#9ca3af] text-sm mb-4">
              {validationResult?.reshade_installed
                ? 'OrbisFX runtime is currently installed. You can reinstall or uninstall it.'
                : 'Install the OrbisFX runtime to enable graphics enhancements.'}
            </p>
            <div className="flex gap-3">
              <button
                onClick={handleInstallRuntime}
                disabled={isInstalling || validationStatus !== 'success'}
                className="btn-hyfx-primary px-6 py-3 font-hytale font-bold text-sm text-white rounded flex items-center gap-2 disabled:opacity-50"
              >
                <Download size={16} /> {validationResult?.reshade_installed ? 'Reinstall' : 'Install'} OrbisFX
              </button>
              {validationResult?.reshade_installed && (
                <button
                  onClick={handleUninstallRuntime}
                  disabled={isInstalling}
                  className="px-6 py-3 font-hytale font-bold text-sm text-red-400 border border-red-900/50 rounded flex items-center gap-2 hover:bg-red-900/20 transition-colors"
                >
                  <Trash2 size={16} /> Uninstall
                </button>
              )}
            </div>
          </div>

          {/* Hotkeys */}
          {hotkeys && validationResult?.reshade_installed && (
            <div className="bg-[#141417] border border-[#2d2d30] rounded-lg p-6">
              <div className="flex items-center gap-3 mb-4">
                <Keyboard size={20} className="text-[#0092cc]" />
                <div>
                  <span className="font-hytale font-bold text-white uppercase block">ReShade Hotkeys</span>
                  <span className="text-[#6b7280] text-sm">Current keyboard shortcuts (configure in ReShade overlay)</span>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div className="flex items-center justify-between bg-[#0a0a0c] rounded px-4 py-3">
                  <span className="text-[#9ca3af] text-sm">Toggle Effects</span>
                  <kbd className="bg-[#2d2d30] text-white text-xs px-2 py-1 rounded font-mono">{hotkeys.key_effects}</kbd>
                </div>
                <div className="flex items-center justify-between bg-[#0a0a0c] rounded px-4 py-3">
                  <span className="text-[#9ca3af] text-sm">Toggle Overlay</span>
                  <kbd className="bg-[#2d2d30] text-white text-xs px-2 py-1 rounded font-mono">{hotkeys.key_overlay}</kbd>
                </div>
                <div className="flex items-center justify-between bg-[#0a0a0c] rounded px-4 py-3">
                  <span className="text-[#9ca3af] text-sm">Screenshot</span>
                  <kbd className="bg-[#2d2d30] text-white text-xs px-2 py-1 rounded font-mono">{hotkeys.key_screenshot}</kbd>
                </div>
                <div className="flex items-center justify-between bg-[#0a0a0c] rounded px-4 py-3">
                  <span className="text-[#9ca3af] text-sm">Next Preset</span>
                  <kbd className="bg-[#2d2d30] text-white text-xs px-2 py-1 rounded font-mono">{hotkeys.key_next_preset}</kbd>
                </div>
                <div className="flex items-center justify-between bg-[#0a0a0c] rounded px-4 py-3">
                  <span className="text-[#9ca3af] text-sm">Previous Preset</span>
                  <kbd className="bg-[#2d2d30] text-white text-xs px-2 py-1 rounded font-mono">{hotkeys.key_prev_preset}</kbd>
                </div>
              </div>
            </div>
          )}

          {/* Updates */}
          <div className="bg-[#141417] border border-[#2d2d30] rounded-lg p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <RefreshCw size={20} className="text-[#0092cc]" />
                <div>
                  <span className="font-hytale font-bold text-white uppercase block">Check for Updates</span>
                  <span className="text-[#6b7280] text-sm">
                    Current version: v2.0.0 {updateAvailable && `• Latest: v${latestVersion}`}
                  </span>
                </div>
              </div>
              <button
                onClick={checkForUpdates}
                className="btn-hyfx-secondary px-4 py-2 rounded font-hytale font-bold text-sm flex items-center gap-2"
              >
                <RefreshCw size={16} /> Check Now
              </button>
            </div>
            {updateAvailable && (
              <div className="mt-4 p-3 bg-yellow-900/20 border border-yellow-900/50 rounded text-yellow-400 text-sm flex items-center gap-2">
                <AlertTriangle size={16} /> A new version is available!
                <a href="#" className="underline hover:text-yellow-300 flex items-center gap-1">
                  Download v{latestVersion} <ExternalLink size={12} />
                </a>
              </div>
            )}
          </div>

          {/* Tutorial */}
          <div className="bg-[#141417] border border-[#2d2d30] rounded-lg p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <HelpCircle size={20} className="text-[#0092cc]" />
                <div>
                  <span className="font-hytale font-bold text-white uppercase block">Tutorial</span>
                  <span className="text-[#6b7280] text-sm">Learn how to use OrbisFX Launcher</span>
                </div>
              </div>
              <button
                onClick={handleReplayTutorial}
                className="btn-hyfx-secondary px-4 py-2 rounded font-hytale font-bold text-sm flex items-center gap-2"
              >
                <Play size={16} /> Replay Tutorial
              </button>
            </div>
          </div>

          {/* About */}
          <div className="bg-[#141417] border border-[#2d2d30] rounded-lg p-6 text-center">
            <img src="/logo.png" alt="OrbisFX" className="w-16 h-16 mx-auto mb-4" />
            <h3 className="font-hytale font-bold text-white text-lg">OrbisFX Launcher</h3>
            <p className="text-[#6b7280] text-sm mt-1">Version 2.0.0</p>
            <p className="text-[#4b5563] text-xs mt-4">© 2024 OrbisFX Team. All rights reserved.</p>
          </div>
        </div>
      </div>
    </div>
  );

  // ============== Render Setup Wizard ==============
  const renderSetupWizard = () => (
    <div className="flex-1 flex flex-col items-center justify-center p-8">
      <div className="max-w-xl w-full">
        {/* Welcome Step */}
        {setupStep === 0 && (
          <div className="text-center animate-[fadeIn_0.5s_ease-out]">
            <img src="/logo.png" alt="OrbisFX" className="w-32 h-32 mx-auto mb-6" />
            <h1 className="font-hytale font-black text-4xl text-white mb-4">Welcome to OrbisFX</h1>
            <p className="text-[#9ca3af] text-lg mb-8">Advanced graphics enhancement for Hytale</p>
            <p className="text-[#6b7280] text-sm mb-8">
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
          <div className="animate-[fadeIn_0.5s_ease-out]">
            <h2 className="font-hytale font-bold text-2xl text-white mb-2">Select Game Directory</h2>
            <p className="text-[#9ca3af] mb-6">Locate your Hytale installation folder containing Hytale.exe</p>

            <div className="bg-[#141417] border border-[#2d2d30] rounded-lg p-6 mb-6">
              <div className="flex gap-3 mb-4">
                <input
                  type="text"
                  value={installPath}
                  onChange={(e) => setInstallPath(e.target.value)}
                  placeholder="C:\Program Files\Hytale..."
                  className="flex-1 bg-[#0a0a0c] border border-[#2d2d30] rounded px-4 py-3 text-white font-mono text-sm outline-none focus:border-[#0092cc] transition-colors"
                />
                <button
                  onClick={handleBrowse}
                  className="btn-hyfx-secondary px-5 rounded font-hytale font-bold text-sm uppercase flex items-center gap-2"
                >
                  <FolderOpen size={18} /> Browse
                </button>
              </div>
              {validationStatus === 'success' && (
                <p className="text-green-400 text-sm flex items-center gap-2">
                  <CheckCircle size={14} /> Hytale installation detected!
                </p>
              )}
              {validationStatus === 'error' && installPath && (
                <p className="text-red-400 text-sm flex items-center gap-2">
                  <AlertTriangle size={14} /> Hytale.exe not found in this directory
                </p>
              )}
            </div>

            <div className="flex gap-4">
              <button
                onClick={() => setSetupStep(0)}
                className="btn-hyfx-secondary px-6 py-3 font-hytale font-bold text-sm rounded uppercase"
              >
                Back
              </button>
              <button
                onClick={() => setSetupStep(2)}
                disabled={validationStatus !== 'success'}
                className="flex-1 btn-hyfx-primary px-6 py-3 font-hytale font-bold text-sm text-white rounded uppercase disabled:opacity-50"
              >
                Continue
              </button>
            </div>
          </div>
        )}

        {/* Install Runtime Step */}
        {setupStep === 2 && (
          <div className="animate-[fadeIn_0.5s_ease-out]">
            <h2 className="font-hytale font-bold text-2xl text-white mb-2">Install OrbisFX Runtime</h2>
            <p className="text-[#9ca3af] mb-6">Install the graphics runtime to enhance your Hytale experience</p>

            <div className="bg-[#141417] border border-[#2d2d30] rounded-lg p-6 mb-6">
              {!isInstalling && !validationResult?.reshade_installed && (
                <div className="text-center">
                  <Download size={48} className="text-[#0092cc] mx-auto mb-4" />
                  <p className="text-white font-hytale font-bold mb-2">Ready to Install</p>
                  <p className="text-[#6b7280] text-sm mb-4">Click below to install the OrbisFX graphics runtime</p>
                  <button
                    onClick={handleInstallRuntime}
                    className="btn-hyfx-primary px-8 py-3 font-hytale font-bold text-white rounded uppercase"
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
                  <p className="text-white font-hytale font-bold mb-2">Installation Complete!</p>
                  <p className="text-[#6b7280] text-sm">OrbisFX runtime has been installed successfully</p>
                </div>
              )}
            </div>

            <div className="flex gap-4">
              <button
                onClick={() => setSetupStep(1)}
                disabled={isInstalling}
                className="btn-hyfx-secondary px-6 py-3 font-hytale font-bold text-sm rounded uppercase disabled:opacity-50"
              >
                Back
              </button>
              <button
                onClick={() => setSetupStep(3)}
                disabled={isInstalling || !validationResult?.reshade_installed}
                className="flex-1 btn-hyfx-primary px-6 py-3 font-hytale font-bold text-sm text-white rounded uppercase disabled:opacity-50"
              >
                Continue
              </button>
              {!validationResult?.reshade_installed && !isInstalling && (
                <button
                  onClick={() => setSetupStep(3)}
                  className="text-[#6b7280] hover:text-white text-sm"
                >
                  Skip for now
                </button>
              )}
            </div>
          </div>
        )}

        {/* Complete Step */}
        {setupStep === 3 && (
          <div className="text-center animate-[fadeIn_0.5s_ease-out]">
            <div className="w-20 h-20 bg-[#002030] rounded-full flex items-center justify-center mx-auto mb-6 shadow-[0_0_30px_rgba(0,146,204,0.4)]">
              <CheckCircle size={40} className="text-[#0092cc]" />
            </div>
            <h2 className="font-hytale font-bold text-2xl text-white mb-2">Setup Complete!</h2>
            <p className="text-[#9ca3af] mb-8">You're all set to start using OrbisFX</p>

            <button
              onClick={async () => {
                await saveSettings({ ...settings, hytale_path: installPath });
                setIsFirstLaunch(false);
                setCurrentPage('home');
              }}
              className="btn-hyfx-primary px-8 py-4 font-hytale font-bold text-lg text-white rounded-sm uppercase tracking-wider flex items-center gap-3 mx-auto shadow-[0_0_20px_rgba(0,146,204,0.3)]"
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

      {/* Title Bar */}
      <div className="h-10 bg-[#0e0e10] border-b border-[#2d2d30] flex items-center justify-between px-4 z-20 flex-shrink-0 select-none" style={{ WebkitAppRegion: 'drag' } as React.CSSProperties}>
        <div className="flex items-center gap-2">
          <img src="/logo.png" alt="OrbisFX" className="w-5 h-5" />
          <span className="text-xs uppercase font-bold tracking-widest text-[#9ca3af]">OrbisFX Launcher v2.0.0</span>
        </div>
        <div className="flex gap-1" style={{ WebkitAppRegion: 'no-drag' } as React.CSSProperties}>
          <button onClick={() => appWindow.minimize()} className="hover:bg-[#2d2d30] p-2 rounded transition-colors text-[#6b7280] hover:text-white">
            <Minus size={14} />
          </button>
          <button onClick={() => exit(0)} className="hover:bg-red-900/50 p-2 rounded transition-colors text-[#6b7280] hover:text-red-400">
            <X size={14} />
          </button>
        </div>
      </div>

      {/* Setup Wizard (shown on first launch) */}
      {currentPage === 'setup' && renderSetupWizard()}

      {/* Main Layout (hidden during setup) */}
      {currentPage !== 'setup' && (
        <div className="flex flex-1 overflow-hidden">
          {/* Sidebar */}
          <div className="w-56 bg-[#0e0e10] border-r border-[#2d2d30] flex flex-col z-10">
            {/* Navigation */}
            <nav className="flex-1 p-4 space-y-1">
              <button
                onClick={() => setCurrentPage('home')}
                className={`w-full p-3 rounded-lg flex items-center gap-3 transition-colors ${
                  currentPage === 'home'
                    ? 'bg-[#1c1c20] text-[#0092cc] border border-[#2d2d30]'
                    : 'text-[#9ca3af] hover:text-white hover:bg-[#141417]'
                }`}
              >
                <Home size={18} />
                <span className="font-hytale text-sm font-bold">Home</span>
              </button>

              <button
                onClick={() => setCurrentPage('presets')}
                className={`w-full p-3 rounded-lg flex items-center gap-3 transition-colors ${
                  currentPage === 'presets'
                    ? 'bg-[#1c1c20] text-[#0092cc] border border-[#2d2d30]'
                    : 'text-[#9ca3af] hover:text-white hover:bg-[#141417]'
                }`}
              >
                <Palette size={18} />
                <span className="font-hytale text-sm font-bold">Presets</span>
              </button>

              <button
                onClick={() => setCurrentPage('settings')}
                className={`w-full p-3 rounded-lg flex items-center gap-3 transition-colors ${
                  currentPage === 'settings'
                    ? 'bg-[#1c1c20] text-[#0092cc] border border-[#2d2d30]'
                    : 'text-[#9ca3af] hover:text-white hover:bg-[#141417]'
                }`}
              >
                <Settings size={18} />
                <span className="font-hytale text-sm font-bold">Settings</span>
              </button>
            </nav>

            {/* Sidebar Footer */}
            <div className="p-4 border-t border-[#2d2d30] space-y-3">
              {/* Discord Button */}
              <button
                onClick={() => window.open('https://discord.com/invite/OrbisFX', '_blank')}
                className="w-full p-3 rounded-lg flex items-center justify-center gap-2 bg-[#5865F2] hover:bg-[#4752C4] text-white transition-colors"
              >
                <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028 14.09 14.09 0 0 0 1.226-1.994.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z"/>
                </svg>
                <span className="font-medium">Join Discord</span>
              </button>

              {/* Status Card */}
              <div className="bg-[#141417] p-3 rounded-lg border border-[#2d2d30] text-xs">
                <div className="flex items-center gap-2 mb-2">
                  <div className={`w-2 h-2 rounded-full ${validationStatus === 'success' ? 'bg-green-400' : 'bg-[#6b7280]'} animate-pulse`}></div>
                  <span className="text-[#9ca3af] uppercase font-bold">
                    {validationStatus === 'success' ? 'Ready' : 'Not Configured'}
                  </span>
                </div>
                {validationResult?.reshade_installed && (
                  <p className="text-[#6b7280]">
                    Runtime: {validationResult.reshade_enabled ? 'Enabled' : 'Disabled'}
                  </p>
                )}
              </div>
            </div>
          </div>

          {/* Main Content */}
          <main className="flex-1 flex flex-col overflow-hidden">
            {currentPage === 'home' && renderHomePage()}
            {currentPage === 'presets' && renderPresetsPage()}
            {currentPage === 'settings' && renderSettingsPage()}
          </main>
        </div>
      )}

      {/* Preset Detail Modal */}
      {selectedPreset && (
        <div
          className="fixed inset-0 bg-black/80 z-50 flex items-center justify-center p-8"
          onClick={() => setSelectedPreset(null)}
        >
          <div
            className="bg-[#0a0a0c] border border-[#2d2d30] rounded-xl max-w-4xl w-full max-h-[90vh] overflow-hidden flex flex-col"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="flex items-center justify-between p-4 border-b border-[#2d2d30]">
              <div>
                <h2 className="font-hytale font-bold text-xl text-white">{selectedPreset.name}</h2>
                <p className="text-[#6b7280] text-sm">by {selectedPreset.author} • v{selectedPreset.version}</p>
              </div>
              <button
                onClick={() => setSelectedPreset(null)}
                className="text-[#6b7280] hover:text-white transition-colors p-2"
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
                  <div className="aspect-video bg-[#141417] rounded-lg overflow-hidden mb-3">
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
                          className={`flex-shrink-0 w-20 h-14 rounded overflow-hidden border-2 transition-colors ${
                            currentImageIndex === idx
                              ? 'border-[#0092cc]'
                              : 'border-transparent hover:border-[#2d2d30]'
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
                        className="p-2 bg-[#141417] rounded-full hover:bg-[#2d2d30] transition-colors"
                      >
                        <ChevronLeft size={20} className="text-white" />
                      </button>
                      <span className="text-[#6b7280] text-sm">
                        {currentImageIndex + 1} / {selectedPreset.images.length + 1}
                      </span>
                      <button
                        onClick={() => setCurrentImageIndex(prev =>
                          prev === selectedPreset.images.length ? 0 : prev + 1
                        )}
                        className="p-2 bg-[#141417] rounded-full hover:bg-[#2d2d30] transition-colors"
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
                    <span className="bg-[#0092cc]/20 text-[#0092cc] text-xs px-3 py-1 rounded-full capitalize font-medium">
                      {selectedPreset.category}
                    </span>
                    {installedPresets.some(ip => ip.id === selectedPreset.id) && (
                      <span className="bg-green-500/20 text-green-400 text-xs px-3 py-1 rounded-full flex items-center gap-1">
                        <CheckCircle size={12} /> Installed
                      </span>
                    )}
                  </div>

                  {/* Description */}
                  <div>
                    <h3 className="font-hytale font-bold text-white text-sm uppercase mb-2">Description</h3>
                    <p className="text-[#9ca3af] text-sm leading-relaxed">
                      {selectedPreset.long_description || selectedPreset.description}
                    </p>
                  </div>

                  {/* Features */}
                  {selectedPreset.features && selectedPreset.features.length > 0 && (
                    <div>
                      <h3 className="font-hytale font-bold text-white text-sm uppercase mb-2">Features</h3>
                      <ul className="space-y-1">
                        {selectedPreset.features.map((feature, idx) => (
                          <li key={idx} className="text-[#9ca3af] text-sm flex items-center gap-2">
                            <CheckCircle size={14} className="text-green-400" />
                            {feature}
                          </li>
                        ))}
                      </ul>
                    </div>
                  )}

                  {/* Install Button */}
                  <div className="pt-4 border-t border-[#2d2d30]">
                    <button
                      onClick={() => {
                        handleDownloadPreset(selectedPreset);
                        setSelectedPreset(null);
                      }}
                      disabled={!installPath}
                      className="w-full btn-hyfx-primary py-3 font-hytale font-bold text-white rounded-lg flex items-center justify-center gap-2 disabled:opacity-50"
                    >
                      <Download size={18} />
                      {installedPresets.some(ip => ip.id === selectedPreset.id)
                        ? 'Reinstall Preset'
                        : 'Install Preset'}
                    </button>
                    {!installPath && (
                      <p className="text-yellow-500 text-xs text-center mt-2">
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

      {/* Tutorial Modal */}
      {showTutorial && (
        <div className="fixed inset-0 bg-black/90 flex items-center justify-center z-50">
          <div className="bg-[#141417] rounded-xl p-8 max-w-lg w-full mx-4 border border-[#2d2d30] shadow-2xl">
            {/* Progress indicator */}
            <div className="flex gap-1 mb-6">
              {TUTORIAL_STEPS.map((_, idx) => (
                <div
                  key={idx}
                  className={`flex-1 h-1 rounded-full transition-colors ${
                    idx <= tutorialStep ? 'bg-[#0092cc]' : 'bg-[#2d2d30]'
                  }`}
                />
              ))}
            </div>

            {/* Step content */}
            <div className="text-center mb-8">
              <div className="text-5xl mb-4">{TUTORIAL_STEPS[tutorialStep].icon}</div>
              <h3 className="font-hytale font-bold text-2xl text-white mb-3">
                {TUTORIAL_STEPS[tutorialStep].title}
              </h3>
              <p className="text-[#9ca3af] text-lg leading-relaxed">
                {TUTORIAL_STEPS[tutorialStep].description}
              </p>
            </div>

            {/* Step counter */}
            <p className="text-center text-[#6b7280] text-sm mb-6">
              Step {tutorialStep + 1} of {TUTORIAL_STEPS.length}
            </p>

            {/* Buttons */}
            <div className="flex gap-3">
              <button
                onClick={handleTutorialSkip}
                className="flex-1 px-4 py-3 bg-[#2d2d30] hover:bg-[#3d3d40] text-[#9ca3af] rounded-lg transition-colors font-medium"
              >
                Skip Tutorial
              </button>
              <button
                onClick={handleTutorialNext}
                className="flex-1 px-4 py-3 btn-hyfx-primary text-white rounded-lg transition-colors font-hytale font-bold flex items-center justify-center gap-2"
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
      )}

      {/* Update Available Modal */}
      {showUpdateModal && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50">
          <div className="bg-gray-800 rounded-xl p-6 max-w-md w-full mx-4 border border-gray-700">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-12 h-12 bg-blue-500/20 rounded-full flex items-center justify-center">
                <Download className="w-6 h-6 text-blue-400" />
              </div>
              <div>
                <h3 className="text-xl font-bold text-white">Update Available</h3>
                <p className="text-gray-400 text-sm">Version {latestVersion} is now available</p>
              </div>
            </div>
            <p className="text-gray-300 mb-6">
              A new version of OrbisFX Launcher is available. Would you like to download it now?
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setShowUpdateModal(false)}
                className="flex-1 px-4 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded-lg transition-colors"
              >
                Later
              </button>
              <button
                onClick={handleDownloadUpdate}
                disabled={isDownloadingUpdate}
                className="flex-1 px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white rounded-lg transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
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
          </div>
        </div>
      )}
    </div>
  );
};

export default App;
