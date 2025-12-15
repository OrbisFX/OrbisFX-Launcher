import { useState, useEffect, useCallback } from 'react';
import { invoke } from '@tauri-apps/api/core';
import {
  User, Upload, CheckCircle, Clock, LogOut, Loader2,
  RefreshCw, Download, AlertTriangle, ChevronRight, Sparkles, X, Image, GitCompare
} from 'lucide-react';
import { MyUploads } from './MyUploads';
import { ImageComparisonSlider } from './ImageComparisonSlider';

interface UserInfo {
  id: string;
  username: string;
  discriminator: string;
  avatar_url: string;
  banner_url?: string;
  banner_color?: string;
  accent_color?: number;
  display_name: string;
}

interface UserStats {
  total_uploads: number;
  approved_count: number;
  pending_count: number;
  rejected_count: number;
  total_downloads: number;
}

interface PresetImage {
  id: string;
  image_type: string;
  pair_index?: number;
  full_image_url: string;
  thumbnail_url?: string;
}

interface PublicPreset {
  id: string;
  slug: string;
  name: string;
  description: string;
  long_description?: string;
  category: string;
  version?: string;
  thumbnail_url?: string;
  preset_file_url?: string;
  download_count: number;
  created_at: string;
  images?: PresetImage[];
}

interface UserProfileProps {
  currentUser: UserInfo | null;
  viewingUserId: string | null;
  isOwnProfile: boolean;
  onLogin: () => void;
  onLogout: () => void;
  onViewPreset?: (presetId: string) => void;
  onRefreshCommunity?: () => void;
  onInstallPreset?: (preset: PublicPreset) => void;
}

export function UserProfile({
  currentUser,
  viewingUserId,
  isOwnProfile,
  onLogin,
  onLogout,
  onViewPreset,
  onRefreshCommunity,
  onInstallPreset
}: UserProfileProps) {
  const [loading, setLoading] = useState(false);
  const [stats, setStats] = useState<UserStats | null>(null);
  const [publicPresets, setPublicPresets] = useState<PublicPreset[]>([]);
  const [viewedUser, setViewedUser] = useState<UserInfo | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [selectedPreset, setSelectedPreset] = useState<PublicPreset | null>(null);
  const [imageIndex, setImageIndex] = useState(0);
  const [showComparison, setShowComparison] = useState(false);

  const loadProfile = useCallback(async () => {
    if (!viewingUserId) return;
    setLoading(true);
    setError(null);

    try {
      const result = await invoke<{
        success: boolean;
        user?: UserInfo;
        stats?: UserStats;
        presets?: PublicPreset[];
        error?: string;
      }>('get_user_profile', { discordId: viewingUserId });

      console.log('[UserProfile] API response:', result);
      if (result.success) {
        console.log('[UserProfile] User data:', result.user);
        console.log('[UserProfile] Presets:', result.presets);
        setViewedUser(result.user || null);
        setStats(result.stats || null);
        setPublicPresets(result.presets || []);
      } else {
        console.error('[UserProfile] Error:', result.error);
        setError(result.error || 'Failed to load profile');
      }
    } catch (e) {
      setError(`Error: ${e}`);
    } finally {
      setLoading(false);
    }
  }, [viewingUserId]);

  useEffect(() => {
    if (viewingUserId) {
      loadProfile();
    }
  }, [viewingUserId, loadProfile]);

  // Not logged in - show login prompt (only for own profile)
  if (!currentUser && isOwnProfile) {
    return (
      <div className="flex-1 flex items-center justify-center p-8">
        <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-8 max-w-md w-full text-center">
          <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
            <User size={40} className="text-[var(--hytale-text-dim)]" />
          </div>
          <h2 className="font-hytale text-xl font-bold text-[var(--hytale-text-primary)] mb-2">
            Sign In to View Your Profile
          </h2>
          <p className="text-[var(--hytale-text-muted)] text-sm mb-6">
            Connect with Discord to manage your uploads and view your statistics.
          </p>
          <button
            onClick={onLogin}
            className="w-full py-3 px-4 bg-[#5865F2] hover:bg-[#4752C4] text-white rounded-md font-bold flex items-center justify-center gap-2 transition-colors"
          >
            <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
              <path d="M20.317 4.37a19.791 19.791 0 00-4.885-1.515.074.074 0 00-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 00-5.487 0 12.64 12.64 0 00-.617-1.25.077.077 0 00-.079-.037A19.736 19.736 0 003.677 4.37a.07.07 0 00-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 00.031.057 19.9 19.9 0 005.993 3.03.078.078 0 00.084-.028c.462-.63.874-1.295 1.226-1.994a.076.076 0 00-.041-.106 13.107 13.107 0 01-1.872-.892.077.077 0 01-.008-.128 10.2 10.2 0 00.372-.292.074.074 0 01.077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 01.078.01c.12.098.246.198.373.292a.077.077 0 01-.006.127 12.299 12.299 0 01-1.873.892.077.077 0 00-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 00.084.028 19.839 19.839 0 006.002-3.03.077.077 0 00.032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 00-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z"/>
            </svg>
            Sign in with Discord
          </button>
        </div>
      </div>
    );
  }

  // User not found in database (viewing another user's profile who hasn't logged in yet)
  if (!isOwnProfile && !loading && error) {
    return (
      <div className="flex-1 flex items-center justify-center p-8">
        <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-8 max-w-md w-full text-center">
          <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-[var(--hytale-bg-elevated)] flex items-center justify-center">
            <AlertTriangle size={40} className="text-[var(--hytale-warning)]" />
          </div>
          <h2 className="font-hytale text-xl font-bold text-[var(--hytale-text-primary)] mb-2">
            User Not Found
          </h2>
          <p className="text-[var(--hytale-text-muted)] text-sm mb-6">
            This user hasn't created a profile yet. They need to sign in with Discord at least once to appear here.
          </p>
          {error && (
            <p className="text-[var(--hytale-text-dimmer)] text-xs">
              {error}
            </p>
          )}
        </div>
      </div>
    );
  }

  const displayUser = isOwnProfile ? currentUser : viewedUser;
  const accentColor = displayUser?.accent_color
    ? `#${displayUser.accent_color.toString(16).padStart(6, '0')}`
    : displayUser?.banner_color || 'var(--hytale-accent-blue)';

  return (
    <div className="flex-1 overflow-y-auto">
      <div className="max-w-4xl mx-auto p-6 space-y-6">
        {/* Profile Header */}
        <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg overflow-hidden">
          {/* Banner */}
          <div
            className="h-32 relative"
            style={{
              background: displayUser?.banner_url
                ? `url(${displayUser.banner_url}) center/cover`
                : `linear-gradient(135deg, ${accentColor} 0%, var(--hytale-bg-elevated) 100%)`
            }}
          />

          {/* User Info */}
          <div className="px-6 pb-6 bg-[var(--hytale-bg-card)]">
            <div className="flex items-end gap-4 -mt-12">
              <img
                src={displayUser?.avatar_url || '/default-avatar.png'}
                alt="Avatar"
                className="w-24 h-24 rounded-full border-4 border-[var(--hytale-bg-card)] bg-[var(--hytale-bg-elevated)] relative z-10"
              />
              <div className="flex-1 pb-2 pt-14">
                <h1 className="font-hytale text-2xl font-bold text-[var(--hytale-text-primary)]">
                  {displayUser?.display_name || 'Unknown User'}
                </h1>
                <p className="text-[var(--hytale-text-muted)] text-sm">
                  @{displayUser?.username}
                  {displayUser?.discriminator && displayUser.discriminator !== '0' && `#${displayUser.discriminator}`}
                </p>
              </div>
              {isOwnProfile && (
                <button
                  onClick={onLogout}
                  className="px-4 py-2 mb-2 bg-[var(--hytale-bg-elevated)] hover:bg-red-500/20 text-[var(--hytale-text-muted)] hover:text-red-400 rounded-md flex items-center gap-2 transition-colors"
                >
                  <LogOut size={16} />
                  Sign Out
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Stats Cards */}
        {loading ? (
          <div className="flex items-center justify-center py-8">
            <Loader2 size={24} className="animate-spin text-[var(--hytale-accent-blue)]" />
          </div>
        ) : stats && (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-4 text-center">
              <div className="text-2xl font-bold text-[var(--hytale-text-primary)]">{stats.total_uploads}</div>
              <div className="text-xs text-[var(--hytale-text-muted)] uppercase tracking-wide">Total Uploads</div>
            </div>
            <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-4 text-center">
              <div className="text-2xl font-bold text-green-400">{stats.approved_count}</div>
              <div className="text-xs text-[var(--hytale-text-muted)] uppercase tracking-wide flex items-center justify-center gap-1">
                <CheckCircle size={10} /> Approved
              </div>
            </div>
            <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-4 text-center">
              <div className="text-2xl font-bold text-yellow-400">{stats.pending_count}</div>
              <div className="text-xs text-[var(--hytale-text-muted)] uppercase tracking-wide flex items-center justify-center gap-1">
                <Clock size={10} /> Pending
              </div>
            </div>
            <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg p-4 text-center">
              <div className="text-2xl font-bold text-[var(--hytale-accent-blue)]">{stats.total_downloads}</div>
              <div className="text-xs text-[var(--hytale-text-muted)] uppercase tracking-wide flex items-center justify-center gap-1">
                <Download size={10} /> Downloads
              </div>
            </div>
          </div>
        )}

        {/* My Uploads Section (only for own profile) */}
        {isOwnProfile && currentUser && (
          <MyUploads
            discordId={currentUser.id}
            isVisible={true}
            onRefresh={onRefreshCommunity}
          />
        )}

        {/* Public Presets (for viewing other profiles) */}
        {!isOwnProfile && publicPresets.length > 0 && (
          <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg overflow-hidden">
            <div className="flex items-center justify-between p-4 border-b border-[var(--hytale-border-card)]">
              <div className="flex items-center gap-2">
                <Upload size={18} className="text-[var(--hytale-accent-blue)]" />
                <h3 className="font-hytale font-bold text-[var(--hytale-text-primary)]">Published Presets</h3>
                <span className="px-2 py-0.5 bg-[var(--hytale-bg-elevated)] rounded text-xs text-[var(--hytale-text-muted)]">
                  {publicPresets.length}
                </span>
              </div>
              <button
                onClick={loadProfile}
                disabled={loading}
                className="p-1.5 bg-[var(--hytale-bg-elevated)] rounded hover:bg-[var(--hytale-bg-input)] transition-colors"
              >
                <RefreshCw size={14} className={`text-[var(--hytale-text-muted)] ${loading ? 'animate-spin' : ''}`} />
              </button>
            </div>
            <div className="p-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {publicPresets.map((preset, index) => (
                  <div
                    key={preset.id}
                    className="group bg-[var(--hytale-bg-elevated)] border border-[var(--hytale-border-card)] rounded-lg overflow-hidden hover:-translate-y-0.5 hover:shadow-lg hover:border-[var(--hytale-border-hover)] transition-all duration-200 cursor-pointer"
                    style={{ animationDelay: `${Math.min(index * 0.04, 0.25)}s` }}
                    onClick={() => {
                      setSelectedPreset(preset);
                      setImageIndex(0);
                      setShowComparison(false);
                    }}
                  >
                    {/* Thumbnail */}
                    <div className="h-32 bg-[var(--hytale-bg-input)] relative overflow-hidden">
                      {preset.thumbnail_url ? (
                        <img
                          src={preset.thumbnail_url}
                          alt={preset.name}
                          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                        />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center">
                          <Sparkles size={32} className="text-[var(--hytale-text-dimmer)]" />
                        </div>
                      )}
                      <div className="absolute inset-0 bg-gradient-to-t from-black/40 via-transparent to-transparent"></div>
                      <div className="absolute top-2 right-2 px-2 py-0.5 bg-black/50 backdrop-blur-sm rounded text-xs text-white font-medium">
                        {preset.category}
                      </div>
                    </div>
                    {/* Info */}
                    <div className="p-4">
                      <h4 className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm truncate">{preset.name}</h4>
                      <p className="text-[var(--hytale-text-muted)] text-xs mt-1 line-clamp-2">{preset.description}</p>
                      <div className="flex items-center justify-between mt-3 pt-3 border-t border-[var(--hytale-border-card)]/20">
                        <span className="text-xs text-[var(--hytale-text-dimmer)] flex items-center gap-1 bg-[var(--hytale-bg-card)] px-2 py-0.5 rounded">
                          <Download size={10} /> {preset.download_count}
                        </span>
                        <ChevronRight size={14} className="text-[var(--hytale-text-dim)]" />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {error && (
          <div className="p-4 bg-red-500/10 border border-red-500/30 rounded-lg text-red-400 text-sm flex items-center gap-2">
            <AlertTriangle size={16} /> {error}
          </div>
        )}
      </div>

      {/* Preset Detail Modal */}
      {selectedPreset && (() => {
        const images = selectedPreset.images || [];
        const beforeImage = images.find(img => img.image_type === 'before');
        const afterImage = images.find(img => img.image_type === 'after');
        const hasComparison = beforeImage && afterImage;
        const galleryImages = images.filter(img => img.image_type === 'screenshot' || img.image_type === 'after');

        return (
          <div
            className="fixed inset-0 bg-[var(--hytale-overlay)] z-50 flex items-center justify-center p-8 backdrop-blur-sm animate-fadeIn"
            onClick={() => setSelectedPreset(null)}
          >
            <div
              className="bg-[var(--hytale-bg-primary)] border-2 border-[var(--hytale-border-primary)] rounded-md max-w-4xl w-full max-h-[90vh] overflow-hidden flex flex-col relative animate-expand-in"
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <div className="flex items-center justify-between p-4 border-b-2 border-[var(--hytale-border-primary)]">
                <div>
                  <h2 className="font-hytale font-bold text-xl text-[var(--hytale-text-primary)] uppercase tracking-wide">{selectedPreset.name}</h2>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="px-2 py-0.5 bg-[var(--hytale-accent-blue)]/20 text-[var(--hytale-accent-blue)] rounded text-xs font-medium">
                      {selectedPreset.category}
                    </span>
                    {selectedPreset.version && (
                      <span className="text-xs text-[var(--hytale-text-dim)]">v{selectedPreset.version}</span>
                    )}
                  </div>
                </div>
                <button
                  onClick={() => setSelectedPreset(null)}
                  className="text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)] transition-colors p-2 hover:bg-[var(--hytale-border-primary)] rounded-md"
                >
                  <X size={24} />
                </button>
              </div>

              {/* Modal Body */}
              <div className="flex-1 overflow-y-auto p-6">
                <div className="grid grid-cols-5 gap-6">
                  {/* Image Gallery - Left side (3 cols) */}
                  <div className="col-span-3">
                    {/* View Toggle - Only show if comparison images are available */}
                    {hasComparison && (
                      <div className="flex gap-2 mb-3">
                        <button
                          onClick={() => setShowComparison(false)}
                          className={`flex-1 py-2 px-3 rounded-md font-hytale text-xs uppercase tracking-wide flex items-center justify-center gap-2 transition-all ${
                            !showComparison
                              ? 'bg-[var(--hytale-accent-blue)] text-white'
                              : 'bg-[var(--hytale-bg-tertiary)] text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]'
                          }`}
                        >
                          <Image size={14} /> Gallery
                        </button>
                        <button
                          onClick={() => setShowComparison(true)}
                          className={`flex-1 py-2 px-3 rounded-md font-hytale text-xs uppercase tracking-wide flex items-center justify-center gap-2 transition-all ${
                            showComparison
                              ? 'bg-[var(--hytale-accent-blue)] text-white'
                              : 'bg-[var(--hytale-bg-tertiary)] text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]'
                          }`}
                        >
                          <GitCompare size={14} /> Compare
                        </button>
                      </div>
                    )}

                    {/* Comparison Slider View */}
                    {showComparison && hasComparison ? (
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
                          {galleryImages.length > 0 ? (
                            <img
                              src={galleryImages[imageIndex]?.full_image_url || selectedPreset.thumbnail_url}
                              alt={selectedPreset.name}
                              className="w-full h-full object-cover"
                            />
                          ) : selectedPreset.thumbnail_url ? (
                            <img
                              src={selectedPreset.thumbnail_url}
                              alt={selectedPreset.name}
                              className="w-full h-full object-cover"
                            />
                          ) : (
                            <div className="w-full h-full flex items-center justify-center">
                              <Sparkles size={48} className="text-[var(--hytale-text-dimmer)]" />
                            </div>
                          )}
                        </div>

                        {/* Thumbnail Strip */}
                        {galleryImages.length > 1 && (
                          <div className="flex gap-2 overflow-x-auto pb-2">
                            {galleryImages.map((img, idx) => (
                              <button
                                key={img.id}
                                onClick={() => setImageIndex(idx)}
                                className={`flex-shrink-0 w-20 h-14 rounded-md overflow-hidden border-2 transition-colors ${
                                  imageIndex === idx
                                    ? 'border-[var(--hytale-accent-blue)]'
                                    : 'border-[var(--hytale-border-card)] hover:border-[var(--hytale-border-light)]'
                                }`}
                              >
                                <img src={img.thumbnail_url || img.full_image_url} alt="" className="w-full h-full object-cover" />
                              </button>
                            ))}
                          </div>
                        )}
                      </>
                    )}
                  </div>

                  {/* Info Panel - Right side (2 cols) */}
                  <div className="col-span-2 space-y-4">
                    {/* Info Grid */}
                    <div className="grid grid-cols-2 gap-3">
                      <div className="bg-[var(--hytale-bg-elevated)] rounded-lg p-3 text-center">
                        <div className="text-lg font-bold text-[var(--hytale-text-primary)]">{selectedPreset.download_count}</div>
                        <div className="text-xs text-[var(--hytale-text-dim)]">Downloads</div>
                      </div>
                      <div className="bg-[var(--hytale-bg-elevated)] rounded-lg p-3 text-center">
                        <div className="text-lg font-bold text-[var(--hytale-text-primary)]">{selectedPreset.category}</div>
                        <div className="text-xs text-[var(--hytale-text-dim)]">Category</div>
                      </div>
                    </div>

                    {/* Description */}
                    <div className="bg-[var(--hytale-bg-elevated)] rounded-lg p-4">
                      <h4 className="text-xs font-bold text-[var(--hytale-text-dim)] uppercase mb-2">Description</h4>
                      <p className="text-sm text-[var(--hytale-text-primary)] leading-relaxed">{selectedPreset.description}</p>
                    </div>

                    {/* Long Description */}
                    {selectedPreset.long_description && (
                      <div className="bg-[var(--hytale-bg-elevated)] rounded-lg p-4">
                        <h4 className="text-xs font-bold text-[var(--hytale-text-dim)] uppercase mb-2">Details</h4>
                        <p className="text-sm text-[var(--hytale-text-primary)] leading-relaxed whitespace-pre-wrap">{selectedPreset.long_description}</p>
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Modal Footer */}
              <div className="p-4 border-t-2 border-[var(--hytale-border-primary)] flex justify-between">
                <button
                  onClick={() => {
                    onViewPreset?.(selectedPreset.id);
                    setSelectedPreset(null);
                  }}
                  className="px-4 py-2 bg-[var(--hytale-bg-tertiary)] text-[var(--hytale-text-primary)] rounded-md font-medium flex items-center gap-2 hover:bg-[var(--hytale-bg-elevated)] transition-colors"
                >
                  View in Community
                </button>
                {onInstallPreset && (
                  <button
                    onClick={() => {
                      onInstallPreset(selectedPreset);
                      setSelectedPreset(null);
                    }}
                    className="px-5 py-2 bg-[var(--hytale-accent-blue)] text-white rounded-md font-medium flex items-center gap-2 hover:bg-[var(--hytale-accent-blue-hover)] transition-colors"
                  >
                    <Download size={16} /> Install Preset
                  </button>
                )}
              </div>
            </div>
          </div>
        );
      })()}
    </div>
  );
}

