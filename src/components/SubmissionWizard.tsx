import { useState, useEffect, useRef, useCallback } from 'react';
import { invoke, convertFileSrc } from '@tauri-apps/api/core';
import { open as shellOpen } from '@tauri-apps/plugin-shell';
import { open as dialogOpen } from '@tauri-apps/plugin-dialog';
import {
  X, User, LogIn, Check, ChevronRight, ChevronLeft,
  Upload, Send, Loader2, AlertCircle, XCircle, Search,
  ImagePlus, Trash2, RefreshCw, Edit3, Plus
} from 'lucide-react';

// Types
interface UserInfo {
  id: string;
  username: string;
  discriminator: string;
  avatar_url: string;
}

// User's existing uploads
interface ExistingPreset {
  id: string;
  slug: string;
  name: string;
  version: string;
  status: string;
  created_at: string;
}

interface AuthResponse {
  user: UserInfo | null;
  is_authenticated: boolean;
}

interface InstalledPreset {
  id: string;
  name: string;
  filename: string;
  file_path: string;
  is_active: boolean;
  is_local_import: boolean;
  is_favorite?: boolean;
}

interface PresetValidation {
  is_valid: boolean;
  name: string | null;
  errors: string[];
  file_size: number;
  file_hash: string;
}

interface ScreenshotInfo {
  id: string;
  path: string;
  filename: string;
  preset_name?: string;
  timestamp: string;
  is_favorite: boolean;
}

interface SelectedImage {
  path: string;
  type: 'before' | 'after' | 'showcase';
  pairIndex: number;
}

interface SubmissionWizardProps {
  isOpen: boolean;
  onClose: () => void;
  installedPresets: InstalledPreset[];
  hytalePath: string;
  onSubmitSuccess?: () => void;
}

const STEPS = ['Login', 'Preset', 'Details', 'Images', 'Review'];
const CATEGORIES = ['Realistic', 'Vibrant', 'Cinematic', 'Fantasy', 'Minimal', 'Vintage', 'Other'];

// Increment semantic version (minor bump by default)
const incrementVersion = (version: string, type: 'major' | 'minor' | 'patch' = 'minor'): string => {
  const parts = version.replace(/^v/, '').split('.').map(n => parseInt(n, 10) || 0);
  while (parts.length < 3) parts.push(0);
  switch (type) {
    case 'major':
      return `${parts[0] + 1}.0.0`;
    case 'minor':
      return `${parts[0]}.${parts[1] + 1}.0`;
    case 'patch':
      return `${parts[0]}.${parts[1]}.${parts[2] + 1}`;
  }
};

// Validate semantic version format
const isValidSemVer = (version: string): boolean => {
  return /^[0-9]+\.[0-9]+\.[0-9]+$/.test(version);
};

// Compare semantic versions (returns 1 if a > b, -1 if a < b, 0 if equal)
const compareSemVer = (a: string, b: string): number => {
  const partsA = a.split('.').map(n => parseInt(n, 10) || 0);
  const partsB = b.split('.').map(n => parseInt(n, 10) || 0);
  for (let i = 0; i < 3; i++) {
    if (partsA[i] > partsB[i]) return 1;
    if (partsA[i] < partsB[i]) return -1;
  }
  return 0;
};

export function SubmissionWizard({
  isOpen,
  onClose,
  installedPresets,
  hytalePath,
  onSubmitSuccess
}: SubmissionWizardProps) {
  // Auth state
  const [user, setUser] = useState<UserInfo | null>(null);
  const [authLoading, setAuthLoading] = useState(false);

  // Wizard state
  const [step, setStep] = useState(0);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Cancel ref for OAuth polling
  const oauthCancelledRef = useRef(false);

  // Screenshot state
  const [screenshots, setScreenshots] = useState<ScreenshotInfo[]>([]);
  const [screenshotsLoading, setScreenshotsLoading] = useState(false);
  const [screenshotSearch, setScreenshotSearch] = useState('');
  const [imageSelectionMode, setImageSelectionMode] = useState<'before_after' | 'showcase'>('before_after');

  // Form state
  const [selectedPreset, setSelectedPreset] = useState<InstalledPreset | null>(null);
  const [presetValidation, setPresetValidation] = useState<PresetValidation | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    longDescription: '',
    category: 'Realistic',
    basedOnPreset: '',
  });

  // Image selection: before image, after image, and showcase images
  const [beforeImage, setBeforeImage] = useState<string | null>(null);
  const [afterImage, setAfterImage] = useState<string | null>(null);
  const [showcaseImages, setShowcaseImages] = useState<string[]>([]);
  const [acceptedTerms, setAcceptedTerms] = useState(false);

  // Update detection state
  const [existingUploads, setExistingUploads] = useState<ExistingPreset[]>([]);
  const [existingUploadsLoading, setExistingUploadsLoading] = useState(false);
  const [existingUploadsLoaded, setExistingUploadsLoaded] = useState(false);
  const [matchingExistingPreset, setMatchingExistingPreset] = useState<ExistingPreset | null>(null);
  const [showUpdateModal, setShowUpdateModal] = useState(false);
  const [isUpdateMode, setIsUpdateMode] = useState(false);
  const [newVersion, setNewVersion] = useState('');
  const [changelog, setChangelog] = useState('');
  const [versionBumpType, setVersionBumpType] = useState<'major' | 'minor' | 'patch'>('minor');

  // Load screenshots when wizard opens
  const loadScreenshots = useCallback(async () => {
    if (!hytalePath) return;
    setScreenshotsLoading(true);
    try {
      const result = await invoke<{ success: boolean; screenshots: ScreenshotInfo[] }>('list_screenshots', { hytalePath });
      if (result.success) {
        setScreenshots(result.screenshots);
      }
    } catch (e) {
      console.error('Failed to load screenshots:', e);
    } finally {
      setScreenshotsLoading(false);
    }
  }, [hytalePath]);

  // Load user's existing uploads
  // Note: discord_id removed - now uses authenticated user from stored tokens
  const loadExistingUploads = useCallback(async (_discordId: string) => {
    setExistingUploadsLoading(true);
    try {
      const result = await invoke<{ success: boolean; presets?: ExistingPreset[]; error?: string }>('get_my_uploads', {});
      if (result.success && result.presets && Array.isArray(result.presets)) {
        setExistingUploads(result.presets);
      }
    } catch (e) {
      console.error('Failed to load existing uploads:', e);
    } finally {
      setExistingUploadsLoading(false);
      setExistingUploadsLoaded(true);
    }
  }, []);

  // Check if preset name matches any existing uploads
  const checkForExistingPreset = useCallback((presetName: string) => {
    const normalizedName = presetName.toLowerCase().trim();
    const match = existingUploads.find(p =>
      p.name.toLowerCase().trim() === normalizedName
    );
    setMatchingExistingPreset(match || null);
    if (match) {
      // Pre-populate version with incremented version
      setNewVersion(incrementVersion(match.version, versionBumpType));
    }
  }, [existingUploads, versionBumpType]);

  // Update version when bump type changes
  useEffect(() => {
    if (matchingExistingPreset) {
      setNewVersion(incrementVersion(matchingExistingPreset.version, versionBumpType));
    }
  }, [versionBumpType, matchingExistingPreset]);

  // Check auth and load screenshots on mount
  useEffect(() => {
    if (isOpen) {
      checkAuth();
      loadScreenshots();
    }
  }, [isOpen, loadScreenshots]);

  // Load existing uploads when user is authenticated
  useEffect(() => {
    if (user?.id) {
      loadExistingUploads(user.id);
    }
  }, [user?.id, loadExistingUploads]);

  // Check for existing preset when name changes or uploads finish loading
  useEffect(() => {
    if (formData.name && user) {
      checkForExistingPreset(formData.name);
    } else {
      setMatchingExistingPreset(null);
    }
  }, [formData.name, user, checkForExistingPreset, existingUploads.length]);

  const checkAuth = async () => {
    try {
      const response = await invoke<AuthResponse>('discord_get_current_user');
      if (response.is_authenticated && response.user) {
        setUser(response.user);
        setStep(1); // Skip login step
      }
    } catch (err) {
      console.error('Auth check failed:', err);
    }
  };

  const handleCancelOAuth = () => {
    console.log('[OAuth] User cancelled login');
    oauthCancelledRef.current = true;
    setAuthLoading(false);
    setError(null);
    // Clear any pending OAuth code
    invoke('discord_clear_oauth_code').catch(() => {});
  };

  const handleDiscordLogin = async () => {
    setAuthLoading(true);
    setError(null);
    oauthCancelledRef.current = false;

    try {
      console.log('[OAuth] Starting OAuth server...');
      // Start local OAuth callback server
      const port = await invoke<number>('discord_start_oauth_server');
      console.log('[OAuth] Server started on port:', port);

      const authUrl = await invoke<string>('discord_get_auth_url_with_port', { port });
      console.log('[OAuth] Auth URL:', authUrl);

      // Open in default browser using Tauri shell
      await shellOpen(authUrl);
      console.log('[OAuth] Browser opened, polling for code...');

      // Poll for OAuth code (with cancellation support)
      const pollForCode = async (): Promise<string | null> => {
        for (let i = 0; i < 120; i++) { // Poll for 2 minutes
          // Check if cancelled
          if (oauthCancelledRef.current) {
            console.log('[OAuth] Polling cancelled by user');
            return null;
          }

          await new Promise(resolve => setTimeout(resolve, 1000));
          const code = await invoke<string | null>('discord_check_oauth_code');
          if (code) {
            console.log('[OAuth] Received code:', code.substring(0, 10) + '...');
            return code;
          }
          if (i % 10 === 0) {
            console.log('[OAuth] Still polling... attempt', i + 1);
          }
        }
        return null;
      };

      const code = await pollForCode();

      // Check if cancelled before proceeding
      if (oauthCancelledRef.current) {
        return;
      }

      if (!code) {
        throw new Error('Login timed out. Please try again.');
      }

      console.log('[OAuth] Completing OAuth flow...');
      // Complete OAuth flow
      const response = await invoke<AuthResponse>('discord_complete_oauth', { code, port });
      console.log('[OAuth] Response:', response);

      if (response.is_authenticated && response.user) {
        setUser(response.user);
        setStep(1); // Move to preset selection
      } else {
        throw new Error('Authentication failed');
      }
    } catch (err) {
      // Don't show error if user cancelled
      if (!oauthCancelledRef.current) {
        console.error('[OAuth] Error:', err);
        setError(`Login failed: ${err}`);
      }
    } finally {
      if (!oauthCancelledRef.current) {
        setAuthLoading(false);
      }
    }
  };

  const handlePresetSelect = async (preset: InstalledPreset) => {
    setSelectedPreset(preset);
    setError(null);

    try {
      const validation = await invoke<PresetValidation>('validate_preset_for_submission', {
        filePath: preset.file_path
      });
      setPresetValidation(validation);

      if (validation.is_valid && validation.name) {
        const presetName = validation.name || preset.name;
        setFormData(prev => ({ ...prev, name: presetName }));

        // Immediately check for existing preset match
        const normalizedName = presetName.toLowerCase().trim();
        const match = existingUploads.find(p =>
          p.name.toLowerCase().trim() === normalizedName
        );
        setMatchingExistingPreset(match || null);
        if (match) {
          setNewVersion(incrementVersion(match.version, versionBumpType));
        }
      }
    } catch (err) {
      setError(`Validation failed: ${err}`);
    }
  };

  // Image selection handlers
  const handleSetBeforeImage = (path: string) => {
    setBeforeImage(prev => prev === path ? null : path);
  };

  const handleSetAfterImage = (path: string) => {
    setAfterImage(prev => prev === path ? null : path);
  };

  const handleToggleShowcase = (path: string) => {
    setShowcaseImages(prev => {
      if (prev.includes(path)) {
        return prev.filter(p => p !== path);
      }
      if (prev.length >= 5) return prev; // Max 5 showcase images
      return [...prev, path];
    });
  };

  const handleAddExternalImages = async () => {
    try {
      const selected = await dialogOpen({
        multiple: true,
        filters: [{ name: 'Images', extensions: ['png', 'jpg', 'jpeg', 'webp'] }]
      });
      if (selected) {
        // dialogOpen returns string | string[] | null depending on multiple option
        const paths = Array.isArray(selected) ? selected : [selected];
        setShowcaseImages(prev => [...prev, ...paths].slice(0, 5));
      }
    } catch (e) {
      console.error('Failed to open file dialog:', e);
    }
  };

  // Get all selected images for submission
  const getAllSelectedImages = (): SelectedImage[] => {
    const images: SelectedImage[] = [];
    if (beforeImage) {
      images.push({ path: beforeImage, type: 'before', pairIndex: 1 });
    }
    if (afterImage) {
      images.push({ path: afterImage, type: 'after', pairIndex: 1 });
    }
    showcaseImages.forEach(path => {
      images.push({ path, type: 'showcase', pairIndex: 0 });
    });
    return images;
  };

  // Filter screenshots by search
  const filteredScreenshots = screenshots.filter(s => {
    if (!screenshotSearch) return true;
    const search = screenshotSearch.toLowerCase();
    return s.filename.toLowerCase().includes(search) ||
           (s.preset_name?.toLowerCase().includes(search));
  });

  const canProceed = () => {
    switch (step) {
      case 0: return user !== null;
      case 1: return selectedPreset && presetValidation?.is_valid;
      case 2: return formData.name.trim() && formData.description.trim();
      case 3: return beforeImage && afterImage; // Must have before/after pair
      case 4: return acceptedTerms;
      default: return false;
    }
  };

  const handleNext = () => {
    if (canProceed() && step < STEPS.length - 1) {
      setStep(step + 1);
    }
  };

  const handleBack = () => {
    if (step > 0) {
      setStep(step - 1);
    }
  };

  // Check if we should show update modal before submitting
  const handleSubmitClick = () => {
    if (matchingExistingPreset && !isUpdateMode) {
      // Show modal to choose between update and new
      setShowUpdateModal(true);
    } else {
      handleSubmit();
    }
  };

  // Handle choice from update modal
  const handleUpdateChoice = (updateExisting: boolean) => {
    setShowUpdateModal(false);
    setIsUpdateMode(updateExisting);
    if (updateExisting) {
      // User chose to update - submit as update
      handleUpdatePreset();
    } else {
      // User chose to submit as new
      handleSubmit();
    }
  };

  // Submit as new preset
  const handleSubmit = async () => {
    if (!selectedPreset || !user) return;

    setIsSubmitting(true);
    setError(null);

    const allImages = getAllSelectedImages();

    try {
      // Trim all text inputs before sending
      const result = await invoke<{success: boolean; message: string; preset_id?: string}>('submit_community_preset', {
        request: {
          name: formData.name.trim(),
          description: formData.description.trim(),
          long_description: formData.longDescription?.trim() || null,
          category: formData.category,
          based_on_preset_name: formData.basedOnPreset?.trim() || null,
          preset_file_path: selectedPreset.file_path,
          image_paths: allImages.map(img => ({
            local_path: img.path,
            image_type: img.type,
            pair_index: img.pairIndex,
          })),
        }
      });

      if (result.success) {
        onSubmitSuccess?.();
        onClose();
        // Show success toast or notification
      } else {
        setError(result.message);
      }
    } catch (err) {
      setError(`Submission failed: ${err}`);
    } finally {
      setIsSubmitting(false);
    }
  };

  // Update existing preset
  const handleUpdatePreset = async () => {
    if (!matchingExistingPreset || !user) return;

    setIsSubmitting(true);
    setError(null);

    try {
      // Trim all text inputs before sending
      // Note: discord_id removed - now uses authenticated user from stored tokens
      const result = await invoke<{success: boolean; message?: string; error?: string}>('update_my_preset', {
        presetId: matchingExistingPreset.id,
        name: formData.name.trim(),
        description: formData.description.trim(),
        longDescription: formData.longDescription?.trim() || null,
        category: formData.category,
        version: newVersion,
        changelog: changelog?.trim() || null,
      });

      if (result.success) {
        onSubmitSuccess?.();
        onClose();
      } else {
        setError(result.message || result.error || 'Update failed');
      }
    } catch (err) {
      setError(`Update failed: ${err}`);
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-[var(--hytale-overlay)] z-50 flex items-center justify-center p-4 backdrop-blur-sm animate-fadeIn">
      <div 
        className="bg-[var(--hytale-bg-primary)] border-2 border-[var(--hytale-border-primary)] rounded-md w-full max-w-2xl max-h-[85vh] flex flex-col relative animate-expand-in"
        onClick={e => e.stopPropagation()}
      >
        {/* Corner decorations */}
        <div className="corner-tl"></div>
        <div className="corner-tr"></div>
        <div className="corner-bl"></div>
        <div className="corner-br"></div>

        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b-2 border-[var(--hytale-border-primary)]">
          <div>
            <h2 className="font-hytale font-bold text-xl text-[var(--hytale-text-primary)] uppercase tracking-wide">
              Submit Your Preset
            </h2>
            <p className="text-[var(--hytale-text-muted)] text-sm">Share with the community</p>
          </div>
          <button onClick={onClose} className="text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)] p-2 hover:bg-[var(--hytale-border-primary)] rounded-md">
            <X size={24} />
          </button>
        </div>

        {/* Progress Steps */}
        <div className="flex px-4 py-3 border-b border-[var(--hytale-border-card)] bg-[var(--hytale-bg-input)]">
          {STEPS.map((stepName, idx) => (
            <div key={stepName} className="flex-1 flex items-center">
              <div className={`w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold ${
                idx < step ? 'bg-[var(--hytale-success)] text-white' :
                idx === step ? 'bg-[var(--hytale-accent-blue)] text-white' :
                'bg-[var(--hytale-bg-elevated)] text-[var(--hytale-text-dim)]'
              }`}>
                {idx < step ? <Check size={14} /> : idx + 1}
              </div>
              <span className={`ml-2 text-xs hidden sm:inline ${
                idx === step ? 'text-[var(--hytale-text-primary)]' : 'text-[var(--hytale-text-dim)]'
              }`}>{stepName}</span>
              {idx < STEPS.length - 1 && (
                <div className={`flex-1 h-0.5 mx-2 ${
                  idx < step ? 'bg-[var(--hytale-success)]' : 'bg-[var(--hytale-border-card)]'
                }`} />
              )}
            </div>
          ))}
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-6">
          {error && (
            <div className="mb-4 p-3 bg-red-500/10 border border-red-500/30 rounded-md flex items-center gap-2 text-red-400 text-sm">
              <AlertCircle size={16} />
              {error}
            </div>
          )}
          
          {/* Step 0: Login */}
          {step === 0 && (
            <div className="text-center py-8">
              <User size={48} className="mx-auto mb-4 text-[var(--hytale-accent-blue)]" />
              <h3 className="font-hytale text-lg text-[var(--hytale-text-primary)] mb-2">Sign in with Discord</h3>
              <p className="text-[var(--hytale-text-muted)] text-sm mb-6">
                Connect your Discord account to submit presets and build your reputation.
              </p>

              {authLoading ? (
                <div className="space-y-4">
                  <div className="flex items-center justify-center gap-3 text-[var(--hytale-text-muted)]">
                    <Loader2 size={20} className="animate-spin text-[var(--hytale-accent-blue)]" />
                    <span>Waiting for Discord login...</span>
                  </div>
                  <p className="text-xs text-[var(--hytale-text-dim)]">
                    Complete the login in your browser, then return here.
                  </p>
                  <button
                    onClick={handleCancelOAuth}
                    className="px-4 py-2 bg-[var(--hytale-bg-elevated)] text-[var(--hytale-text-muted)] rounded-md flex items-center gap-2 mx-auto hover:bg-[var(--hytale-bg-input)] hover:text-[var(--hytale-text-primary)] transition-colors border border-[var(--hytale-border-card)]"
                  >
                    <XCircle size={16} />
                    Cancel Login
                  </button>
                </div>
              ) : (
                <button
                  onClick={handleDiscordLogin}
                  className="px-6 py-3 bg-[#5865F2] text-white rounded-md font-bold flex items-center gap-2 mx-auto hover:bg-[#4752C4] transition-colors"
                >
                  <LogIn size={18} />
                  Continue with Discord
                </button>
              )}
            </div>
          )}

          {/* Step 1: Select Preset */}
          {step === 1 && (
            <div>
              <h3 className="font-hytale text-lg text-[var(--hytale-text-primary)] mb-4">Select a Preset</h3>
              <div className="space-y-2 max-h-[40vh] overflow-y-auto">
                {installedPresets.filter(p => p.is_local_import).map(preset => (
                  <div
                    key={preset.id}
                    onClick={() => handlePresetSelect(preset)}
                    className={`p-3 rounded-md cursor-pointer border transition-all ${
                      selectedPreset?.id === preset.id
                        ? 'border-[var(--hytale-accent-blue)] bg-[var(--hytale-accent-blue)]/10'
                        : 'border-[var(--hytale-border-card)] bg-[var(--hytale-bg-input)] hover:border-[var(--hytale-border-hover)]'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="font-bold text-[var(--hytale-text-primary)]">{preset.name}</p>
                        <p className="text-xs text-[var(--hytale-text-dim)]">{preset.filename}</p>
                      </div>
                      {selectedPreset?.id === preset.id && (
                        <Check size={18} className="text-[var(--hytale-accent-blue)]" />
                      )}
                    </div>
                  </div>
                ))}
                {installedPresets.filter(p => p.is_local_import).length === 0 && (
                  <div className="text-center py-8 text-[var(--hytale-text-muted)]">
                    <Upload size={32} className="mx-auto mb-2 opacity-50" />
                    <p>No local presets found</p>
                    <p className="text-xs">Import a preset first to submit it</p>
                  </div>
                )}
              </div>
              {presetValidation && !presetValidation.is_valid && (
                <div className="mt-4 p-3 bg-red-500/10 border border-red-500/30 rounded-md text-sm">
                  <p className="font-bold text-red-400 mb-1">Validation Errors:</p>
                  <ul className="list-disc list-inside text-red-300">
                    {presetValidation.errors.map((err, i) => <li key={i}>{err}</li>)}
                  </ul>
                </div>
              )}

              {/* Loading indicator for existing uploads check */}
              {existingUploadsLoading && selectedPreset && (
                <div className="mt-4 p-3 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md">
                  <div className="flex items-center gap-2 text-[var(--hytale-text-muted)]">
                    <Loader2 size={14} className="animate-spin" />
                    <span className="text-xs">Checking for existing uploads...</span>
                  </div>
                </div>
              )}

              {/* Early update detection indicator */}
              {matchingExistingPreset && selectedPreset && !existingUploadsLoading && (
                <div className="mt-4 p-3 bg-[var(--hytale-accent-blue)]/10 border border-[var(--hytale-accent-blue)]/30 rounded-md">
                  <div className="flex items-start gap-3">
                    <Edit3 size={18} className="text-[var(--hytale-accent-blue)] mt-0.5 flex-shrink-0" />
                    <div>
                      <p className="text-sm font-medium text-[var(--hytale-text-primary)]">
                        Update Mode
                      </p>
                      <p className="text-xs text-[var(--hytale-text-muted)] mt-1">
                        You already uploaded "<span className="text-[var(--hytale-accent-blue)]">{matchingExistingPreset.name}</span>"
                        {' '}(v{matchingExistingPreset.version}). Continuing will update your existing preset.
                      </p>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Step 2: Details */}
          {step === 2 && (
            <div className="space-y-4">
              <h3 className="font-hytale text-lg text-[var(--hytale-text-primary)] mb-4">Preset Details</h3>
              
              <div>
                <label className="block text-sm text-[var(--hytale-text-muted)] mb-1">Name *</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={e => setFormData(prev => ({ ...prev, name: e.target.value }))}
                  className="w-full px-3 py-2 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-primary)] focus:border-[var(--hytale-accent-blue)] outline-none"
                  placeholder="My Awesome Preset"
                />
              </div>

              <div>
                <label className="block text-sm text-[var(--hytale-text-muted)] mb-1">Short Description *</label>
                <textarea
                  value={formData.description}
                  onChange={e => setFormData(prev => ({ ...prev, description: e.target.value }))}
                  className="w-full px-3 py-2 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-primary)] focus:border-[var(--hytale-accent-blue)] outline-none resize-none"
                  rows={2}
                  placeholder="A brief description of what this preset does..."
                />
              </div>

              <div>
                <label className="block text-sm text-[var(--hytale-text-muted)] mb-1">Category</label>
                <select
                  value={formData.category}
                  onChange={e => setFormData(prev => ({ ...prev, category: e.target.value }))}
                  className="w-full px-3 py-2 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-primary)] focus:border-[var(--hytale-accent-blue)] outline-none"
                >
                  {CATEGORIES.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                </select>
              </div>
            </div>
          )}

          {/* Step 3: Images */}
          {step === 3 && (
            <div className="space-y-4">
              {/* Mode Toggle */}
              <div className="flex gap-2 mb-4">
                <button
                  onClick={() => setImageSelectionMode('before_after')}
                  className={`flex-1 py-2 px-3 rounded-md text-sm font-medium transition-colors ${
                    imageSelectionMode === 'before_after'
                      ? 'bg-[var(--hytale-accent-blue)] text-white'
                      : 'bg-[var(--hytale-bg-input)] text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]'
                  }`}
                >
                  Before/After Pair {beforeImage && afterImage ? '✓' : '(Required)'}
                </button>
                <button
                  onClick={() => setImageSelectionMode('showcase')}
                  className={`flex-1 py-2 px-3 rounded-md text-sm font-medium transition-colors ${
                    imageSelectionMode === 'showcase'
                      ? 'bg-[var(--hytale-accent-purple)] text-white'
                      : 'bg-[var(--hytale-bg-input)] text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]'
                  }`}
                >
                  Showcase ({showcaseImages.length}/5)
                </button>
              </div>

              {/* Before/After Mode */}
              {imageSelectionMode === 'before_after' && (
                <div>
                  <p className="text-sm text-[var(--hytale-text-muted)] mb-3">
                    Select a <span className="text-red-400 font-medium">Before</span> and <span className="text-green-400 font-medium">After</span> screenshot to show the effect of your preset.
                  </p>

                  {/* Selected Preview */}
                  <div className="flex gap-4 mb-4">
                    <div className="flex-1">
                      <p className="text-xs text-red-400 mb-1 font-medium">BEFORE (without preset)</p>
                      <div className="aspect-video bg-[var(--hytale-bg-input)] rounded-md border border-dashed border-red-400/50 flex items-center justify-center overflow-hidden">
                        {beforeImage ? (
                          <div className="relative w-full h-full group">
                            <img src={convertFileSrc(beforeImage)} alt="Before" className="w-full h-full object-cover" />
                            <button
                              onClick={() => setBeforeImage(null)}
                              className="absolute top-1 right-1 p-1 bg-black/60 rounded opacity-0 group-hover:opacity-100 transition-opacity"
                            >
                              <Trash2 size={14} className="text-white" />
                            </button>
                          </div>
                        ) : (
                          <span className="text-[var(--hytale-text-dimmer)] text-sm">Click an image below</span>
                        )}
                      </div>
                    </div>
                    <div className="flex-1">
                      <p className="text-xs text-green-400 mb-1 font-medium">AFTER (with preset)</p>
                      <div className="aspect-video bg-[var(--hytale-bg-input)] rounded-md border border-dashed border-green-400/50 flex items-center justify-center overflow-hidden">
                        {afterImage ? (
                          <div className="relative w-full h-full group">
                            <img src={convertFileSrc(afterImage)} alt="After" className="w-full h-full object-cover" />
                            <button
                              onClick={() => setAfterImage(null)}
                              className="absolute top-1 right-1 p-1 bg-black/60 rounded opacity-0 group-hover:opacity-100 transition-opacity"
                            >
                              <Trash2 size={14} className="text-white" />
                            </button>
                          </div>
                        ) : (
                          <span className="text-[var(--hytale-text-dimmer)] text-sm">Click an image below</span>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Selection buttons */}
                  <div className="flex gap-2 mb-3">
                    <span className="text-xs text-[var(--hytale-text-dim)]">Clicking an image will set it as:</span>
                    <button
                      onClick={() => {}}
                      className={`text-xs px-2 py-0.5 rounded ${!beforeImage ? 'bg-red-500/20 text-red-400' : 'bg-[var(--hytale-bg-elevated)] text-[var(--hytale-text-dim)]'}`}
                    >
                      {!beforeImage ? '→ Before' : 'Before ✓'}
                    </button>
                    <button
                      onClick={() => {}}
                      className={`text-xs px-2 py-0.5 rounded ${beforeImage && !afterImage ? 'bg-green-500/20 text-green-400' : 'bg-[var(--hytale-bg-elevated)] text-[var(--hytale-text-dim)]'}`}
                    >
                      {!afterImage ? '→ After' : 'After ✓'}
                    </button>
                  </div>
                </div>
              )}

              {/* Showcase Mode */}
              {imageSelectionMode === 'showcase' && (
                <div>
                  <p className="text-sm text-[var(--hytale-text-muted)] mb-3">
                    Add up to 5 additional screenshots to showcase your preset. (Optional)
                  </p>

                  {/* Selected Showcase Images */}
                  {showcaseImages.length > 0 && (
                    <div className="flex gap-2 mb-3 overflow-x-auto pb-2">
                      {showcaseImages.map((path, i) => (
                        <div key={i} className="relative flex-shrink-0 w-24 h-16 rounded overflow-hidden group">
                          <img src={convertFileSrc(path)} alt="" className="w-full h-full object-cover" />
                          <button
                            onClick={() => setShowcaseImages(prev => prev.filter(p => p !== path))}
                            className="absolute top-0.5 right-0.5 p-0.5 bg-black/60 rounded opacity-0 group-hover:opacity-100 transition-opacity"
                          >
                            <X size={12} className="text-white" />
                          </button>
                        </div>
                      ))}
                    </div>
                  )}

                  {/* Add from file button */}
                  <button
                    onClick={handleAddExternalImages}
                    className="w-full py-2 border border-dashed border-[var(--hytale-border-card)] rounded-md text-sm text-[var(--hytale-text-muted)] hover:border-[var(--hytale-accent-blue)] hover:text-[var(--hytale-accent-blue)] transition-colors flex items-center justify-center gap-2 mb-3"
                  >
                    <ImagePlus size={16} />
                    Add images from files...
                  </button>
                </div>
              )}

              {/* Search and Refresh */}
              <div className="flex gap-2">
                <div className="flex-1 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md flex items-center px-2">
                  <Search size={14} className="text-[var(--hytale-text-dimmer)]" />
                  <input
                    type="text"
                    value={screenshotSearch}
                    onChange={e => setScreenshotSearch(e.target.value)}
                    placeholder="Search screenshots..."
                    className="bg-transparent w-full py-1.5 px-2 text-sm text-[var(--hytale-text-primary)] outline-none"
                  />
                </div>
                <button
                  onClick={loadScreenshots}
                  disabled={screenshotsLoading}
                  className="p-2 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md hover:bg-[var(--hytale-bg-elevated)] transition-colors"
                >
                  <RefreshCw size={14} className={`text-[var(--hytale-text-muted)] ${screenshotsLoading ? 'animate-spin' : ''}`} />
                </button>
              </div>

              {/* Screenshot Grid */}
              <div className="max-h-[30vh] overflow-y-auto border border-[var(--hytale-border-card)] rounded-md p-2 bg-[var(--hytale-bg-input)]">
                {screenshotsLoading ? (
                  <div className="flex items-center justify-center py-8">
                    <Loader2 size={24} className="animate-spin text-[var(--hytale-accent-blue)]" />
                  </div>
                ) : filteredScreenshots.length === 0 ? (
                  <div className="text-center py-8 text-[var(--hytale-text-muted)]">
                    <p className="text-sm">No screenshots found</p>
                    <p className="text-xs mt-1">Take some screenshots in Hytale first!</p>
                  </div>
                ) : (
                  <div className="grid grid-cols-4 gap-2">
                    {filteredScreenshots.slice(0, 50).map(screenshot => {
                      const isSelectedBefore = beforeImage === screenshot.path;
                      const isSelectedAfter = afterImage === screenshot.path;
                      const isSelectedShowcase = showcaseImages.includes(screenshot.path);

                      return (
                        <div
                          key={screenshot.id}
                          onClick={() => {
                            if (imageSelectionMode === 'before_after') {
                              if (!beforeImage) {
                                handleSetBeforeImage(screenshot.path);
                              } else if (!afterImage && screenshot.path !== beforeImage) {
                                handleSetAfterImage(screenshot.path);
                              }
                            } else {
                              if (!isSelectedBefore && !isSelectedAfter) {
                                handleToggleShowcase(screenshot.path);
                              }
                            }
                          }}
                          className={`relative aspect-video rounded overflow-hidden cursor-pointer border-2 transition-all ${
                            isSelectedBefore ? 'border-red-400 ring-1 ring-red-400' :
                            isSelectedAfter ? 'border-green-400 ring-1 ring-green-400' :
                            isSelectedShowcase ? 'border-purple-400' :
                            'border-transparent hover:border-[var(--hytale-border-hover)]'
                          }`}
                        >
                          <img
                            src={convertFileSrc(screenshot.path)}
                            alt=""
                            className="w-full h-full object-cover"
                            loading="lazy"
                          />
                          {isSelectedBefore && (
                            <div className="absolute top-0.5 left-0.5 px-1 py-0.5 bg-red-500 text-white text-[10px] font-bold rounded">
                              BEFORE
                            </div>
                          )}
                          {isSelectedAfter && (
                            <div className="absolute top-0.5 left-0.5 px-1 py-0.5 bg-green-500 text-white text-[10px] font-bold rounded">
                              AFTER
                            </div>
                          )}
                          {isSelectedShowcase && (
                            <div className="absolute inset-0 bg-purple-500/20 flex items-center justify-center">
                              <Check size={16} className="text-white" />
                            </div>
                          )}
                          {screenshot.preset_name && (
                            <div className="absolute bottom-0.5 left-0.5 px-1 py-0.5 bg-black/60 text-white text-[9px] rounded truncate max-w-[90%]">
                              {screenshot.preset_name}
                            </div>
                          )}
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>

              {/* Status */}
              <p className="text-xs text-[var(--hytale-text-dim)]">
                {beforeImage && afterImage ? (
                  <span className="text-green-400">✓ Before/After pair selected</span>
                ) : (
                  <span className="text-yellow-400">⚠ Select a before and after image to continue</span>
                )}
                {showcaseImages.length > 0 && ` • ${showcaseImages.length} showcase image${showcaseImages.length > 1 ? 's' : ''}`}
              </p>
            </div>
          )}

          {/* Step 4: Review */}
          {step === 4 && (
            <div>
              <h3 className="font-hytale text-lg text-[var(--hytale-text-primary)] mb-4">Review & Submit</h3>

              {/* Preset Info */}
              <div className="bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md p-4 mb-4">
                <div className="flex gap-4">
                  {/* Before/After Preview */}
                  <div className="flex gap-1">
                    {beforeImage && (
                      <div className="relative w-16 h-12 rounded overflow-hidden">
                        <img src={convertFileSrc(beforeImage)} alt="Before" className="w-full h-full object-cover" />
                        <div className="absolute bottom-0 left-0 right-0 bg-red-500/80 text-white text-[8px] text-center">Before</div>
                      </div>
                    )}
                    {afterImage && (
                      <div className="relative w-16 h-12 rounded overflow-hidden">
                        <img src={convertFileSrc(afterImage)} alt="After" className="w-full h-full object-cover" />
                        <div className="absolute bottom-0 left-0 right-0 bg-green-500/80 text-white text-[8px] text-center">After</div>
                      </div>
                    )}
                  </div>
                  <div className="flex-1">
                    <h4 className="font-bold text-[var(--hytale-text-primary)]">{formData.name}</h4>
                    <p className="text-sm text-[var(--hytale-text-muted)] line-clamp-2">{formData.description}</p>
                    <p className="text-xs text-[var(--hytale-accent-blue)] mt-1">{formData.category}</p>
                  </div>
                </div>

                {/* Showcase images */}
                {showcaseImages.length > 0 && (
                  <div className="mt-3 pt-3 border-t border-[var(--hytale-border-card)]">
                    <p className="text-xs text-[var(--hytale-text-dim)] mb-2">+ {showcaseImages.length} showcase image{showcaseImages.length > 1 ? 's' : ''}</p>
                    <div className="flex gap-1">
                      {showcaseImages.slice(0, 4).map((path, i) => (
                        <div key={i} className="w-12 h-8 rounded overflow-hidden">
                          <img src={convertFileSrc(path)} alt="" className="w-full h-full object-cover" />
                        </div>
                      ))}
                      {showcaseImages.length > 4 && (
                        <div className="w-12 h-8 rounded bg-[var(--hytale-bg-elevated)] flex items-center justify-center text-xs text-[var(--hytale-text-dim)]">
                          +{showcaseImages.length - 4}
                        </div>
                      )}
                    </div>
                  </div>
                )}
              </div>

              {/* Existing preset indicator */}
              {matchingExistingPreset && (
                <div className="bg-[var(--hytale-accent-orange)]/10 border border-[var(--hytale-accent-orange)]/30 rounded-md p-3 mb-4 flex items-start gap-3">
                  <Edit3 size={18} className="text-[var(--hytale-accent-orange)] mt-0.5 flex-shrink-0" />
                  <div>
                    <p className="text-sm text-[var(--hytale-text-primary)] font-medium">
                      This will update your existing preset
                    </p>
                    <p className="text-xs text-[var(--hytale-text-muted)] mt-1">
                      Current version: <span className="font-mono">{matchingExistingPreset.version}</span>
                      {' • '}You'll choose the new version on submit.
                    </p>
                  </div>
                </div>
              )}

              <label className="flex items-start gap-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={acceptedTerms}
                  onChange={e => setAcceptedTerms(e.target.checked)}
                  className="mt-1"
                />
                <span className="text-sm text-[var(--hytale-text-muted)]">
                  I confirm this preset is my own work or I have permission to share it.
                  I agree to the community guidelines.
                </span>
              </label>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="flex items-center justify-between p-4 border-t-2 border-[var(--hytale-border-primary)] bg-[var(--hytale-bg-input)]">
          <button
            onClick={handleBack}
            disabled={step === 0}
            className="px-4 py-2 text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)] disabled:opacity-30 flex items-center gap-1"
          >
            <ChevronLeft size={16} /> Back
          </button>
          
          {step < STEPS.length - 1 ? (
            <button
              onClick={handleNext}
              disabled={!canProceed()}
              className="px-6 py-2 bg-[var(--hytale-accent-blue)] text-white rounded-md font-bold flex items-center gap-2 disabled:opacity-50 hover:bg-[var(--hytale-accent-blue-hover)] transition-colors"
            >
              Next <ChevronRight size={16} />
            </button>
          ) : (
            <button
              onClick={handleSubmitClick}
              disabled={!canProceed() || isSubmitting}
              className="px-6 py-2 bg-[var(--hytale-success)] text-white rounded-md font-bold flex items-center gap-2 disabled:opacity-50 hover:brightness-110 transition-all"
            >
              {isSubmitting ? <Loader2 size={16} className="animate-spin" /> : <Send size={16} />}
              {matchingExistingPreset ? 'Continue' : 'Submit Preset'}
            </button>
          )}
        </div>
      </div>

      {/* Update Choice Modal */}
      {showUpdateModal && matchingExistingPreset && (
        <div className="fixed inset-0 bg-black/60 z-[60] flex items-center justify-center p-4 backdrop-blur-sm animate-fadeIn">
          <div className="bg-[var(--hytale-bg-primary)] border-2 border-[var(--hytale-border-primary)] rounded-md w-full max-w-md p-6 animate-expand-in">
            <h3 className="font-hytale text-lg text-[var(--hytale-text-primary)] mb-4 flex items-center gap-2">
              <AlertCircle size={20} className="text-[var(--hytale-accent-orange)]" />
              Existing Preset Detected
            </h3>

            <p className="text-sm text-[var(--hytale-text-muted)] mb-4">
              You already have a preset named <strong className="text-[var(--hytale-text-primary)]">"{matchingExistingPreset.name}"</strong> (v{matchingExistingPreset.version}).
            </p>

            <div className="space-y-3 mb-6">
              {/* Version bump options */}
              <div className="bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md p-3">
                <p className="text-xs text-[var(--hytale-text-dim)] mb-2">Version bump type:</p>
                <div className="flex gap-2">
                  {(['patch', 'minor', 'major'] as const).map(type => (
                    <button
                      key={type}
                      onClick={() => setVersionBumpType(type)}
                      className={`px-3 py-1 text-xs rounded-md border transition-all ${
                        versionBumpType === type
                          ? 'bg-[var(--hytale-accent-blue)] border-[var(--hytale-accent-blue)] text-white'
                          : 'border-[var(--hytale-border-card)] text-[var(--hytale-text-muted)] hover:border-[var(--hytale-accent-blue)]'
                      }`}
                    >
                      {type.charAt(0).toUpperCase() + type.slice(1)}
                    </button>
                  ))}
                </div>
                <div className="mt-2 flex items-center gap-2">
                  <span className="text-xs text-[var(--hytale-text-dim)]">New version:</span>
                  <input
                    type="text"
                    value={newVersion}
                    onChange={e => setNewVersion(e.target.value)}
                    className={`px-2 py-1 text-xs font-mono rounded border bg-[var(--hytale-bg-elevated)] ${
                      isValidSemVer(newVersion) && matchingExistingPreset && compareSemVer(newVersion, matchingExistingPreset.version) > 0
                        ? 'border-[var(--hytale-accent-green)] text-[var(--hytale-accent-green)]'
                        : 'border-red-500 text-red-400'
                    }`}
                    style={{ width: '80px' }}
                  />
                </div>
                {(!isValidSemVer(newVersion) || (matchingExistingPreset && compareSemVer(newVersion, matchingExistingPreset.version) <= 0)) && (
                  <p className="text-xs text-red-400 mt-1">
                    {!isValidSemVer(newVersion)
                      ? 'Invalid format (use X.Y.Z)'
                      : 'Version must be greater than current'}
                  </p>
                )}
              </div>

              {/* Changelog */}
              <div>
                <label className="text-xs text-[var(--hytale-text-dim)] mb-1 block">Changelog (optional)</label>
                <textarea
                  value={changelog}
                  onChange={e => setChangelog(e.target.value)}
                  placeholder="What's new in this version?"
                  className="w-full px-3 py-2 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md text-sm text-[var(--hytale-text-primary)] placeholder:text-[var(--hytale-text-dim)] resize-none"
                  rows={2}
                />
              </div>
            </div>

            <div className="flex gap-3">
              <button
                onClick={() => handleUpdateChoice(true)}
                disabled={!isValidSemVer(newVersion) || (matchingExistingPreset ? compareSemVer(newVersion, matchingExistingPreset.version) <= 0 : false)}
                className="flex-1 px-4 py-2 bg-[var(--hytale-accent-blue)] text-white rounded-md font-bold flex items-center justify-center gap-2 hover:brightness-110 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Edit3 size={16} />
                Update to v{newVersion}
              </button>
              <button
                onClick={() => handleUpdateChoice(false)}
                className="flex-1 px-4 py-2 bg-[var(--hytale-bg-elevated)] border border-[var(--hytale-border-card)] text-[var(--hytale-text-primary)] rounded-md font-bold flex items-center justify-center gap-2 hover:border-[var(--hytale-accent-blue)] transition-all"
              >
                <Plus size={16} />
                Submit as New
              </button>
            </div>

            <button
              onClick={() => setShowUpdateModal(false)}
              className="w-full mt-3 px-4 py-2 text-sm text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)] transition-colors"
            >
              Cancel
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

export default SubmissionWizard;

