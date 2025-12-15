import { useState, useEffect, useCallback } from 'react';
import { invoke } from '@tauri-apps/api/core';
import {
  Upload, Clock, CheckCircle, XCircle, AlertTriangle,
  Loader2, RefreshCw, Trash2, X, Edit3, Download, Sparkles, Image, GitCompare,
  Eye, MoreVertical, Calendar
} from 'lucide-react';
import { ImageComparisonSlider } from './ImageComparisonSlider';

interface PresetImage {
  id: string;
  image_type: string;
  pair_index?: number;
  full_image_url: string;
  thumbnail_url?: string;
}

interface MyUpload {
  id: string;
  slug: string;
  name: string;
  description: string;
  long_description?: string;
  category: string;
  status: string;
  version: string;
  thumbnail_url?: string;
  preset_file_url: string;
  rejection_reason?: string;
  download_count: number;
  created_at: string;
  updated_at: string;
  published_at?: string;
  images: PresetImage[];
}

interface MyUploadsProps {
  discordId: string | null;
  isVisible: boolean;
  onRefresh?: () => void;
}

const CATEGORIES = ['Realistic', 'Vibrant', 'Cinematic', 'Fantasy', 'Minimal', 'Vintage', 'Other'];

export function MyUploads({ discordId, isVisible, onRefresh }: MyUploadsProps) {
  const [loading, setLoading] = useState(true);
  const [uploads, setUploads] = useState<MyUpload[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  // Selected preset for detail modal
  const [selectedUpload, setSelectedUpload] = useState<MyUpload | null>(null);
  const [imageIndex, setImageIndex] = useState(0);
  const [showComparison, setShowComparison] = useState(false);

  // Delete modal state
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [deletePresetId, setDeletePresetId] = useState<string | null>(null);
  const [deleting, setDeleting] = useState(false);

  // Edit modal state
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [editPreset, setEditPreset] = useState<MyUpload | null>(null);
  const [editName, setEditName] = useState('');
  const [editDescription, setEditDescription] = useState('');
  const [editCategory, setEditCategory] = useState('');
  const [editing, setEditing] = useState(false);

  const loadUploads = useCallback(async () => {
    if (!discordId) return;
    setLoading(true);
    setError(null);

    try {
      // Note: discord_id removed - now uses authenticated user from stored tokens
      const result = await invoke<{ success: boolean; presets?: MyUpload[] | null; error?: string }>(
        'get_my_uploads', {}
      );
      
      if (result.success) {
        setUploads(result.presets || []);
      } else {
        setError(result.error || 'Failed to load uploads');
      }
    } catch (e) {
      setError(`Error: ${e}`);
    } finally {
      setLoading(false);
    }
  }, [discordId]);

  useEffect(() => {
    if (isVisible && discordId) {
      loadUploads();
    }
  }, [isVisible, discordId, loadUploads]);

  const handleDelete = async () => {
    if (!deletePresetId || !discordId) return;
    setDeleting(true);

    try {
      // Note: discord_id removed - now uses authenticated user from stored tokens
      const result = await invoke<{ success: boolean; error?: string }>(
        'delete_my_preset', { presetId: deletePresetId }
      );

      if (result.success) {
        setUploads(prev => prev.filter(u => u.id !== deletePresetId));
        setDeleteModalOpen(false);
        setDeletePresetId(null);
        setSuccessMessage('Preset deleted successfully');
        setTimeout(() => setSuccessMessage(null), 3000);
        onRefresh?.();
      } else {
        setError(result.error || 'Failed to delete');
      }
    } catch (e) {
      setError(`Error: ${e}`);
    } finally {
      setDeleting(false);
    }
  };

  const openEditModal = (upload: MyUpload) => {
    setEditPreset(upload);
    setEditName(upload.name);
    setEditDescription(upload.description);
    setEditCategory(upload.category);
    setEditModalOpen(true);
  };

  const handleEdit = async () => {
    if (!editPreset || !discordId) return;
    setEditing(true);
    setError(null);

    try {
      const result = await invoke<{ success: boolean; was_approved?: boolean; error?: string }>(
        'update_my_preset', {
          presetId: editPreset.id,
          discordId,
          name: editName !== editPreset.name ? editName : null,
          description: editDescription !== editPreset.description ? editDescription : null,
          category: editCategory !== editPreset.category ? editCategory : null,
        }
      );

      if (result.success) {
        // Update local state
        setUploads(prev => prev.map(u =>
          u.id === editPreset.id
            ? { ...u, name: editName, description: editDescription, category: editCategory, status: 'pending' }
            : u
        ));
        setEditModalOpen(false);
        setEditPreset(null);

        const wasApproved = result.was_approved;
        setSuccessMessage(
          wasApproved
            ? 'Preset updated! It will need to be re-approved before appearing in the community list.'
            : 'Preset updated! It is now pending review.'
        );
        setTimeout(() => setSuccessMessage(null), 5000);
        onRefresh?.();
      } else {
        setError(result.error || 'Failed to update preset');
      }
    } catch (e) {
      setError(`Error: ${e}`);
    } finally {
      setEditing(false);
    }
  };

  const getStatusBadge = (status: string, size: 'sm' | 'md' = 'sm') => {
    const baseClasses = size === 'md'
      ? 'px-3 py-1.5 rounded-md text-xs font-semibold flex items-center gap-1.5 shadow-lg'
      : 'px-2.5 py-1 rounded-md text-xs font-medium flex items-center gap-1.5';

    switch (status) {
      case 'approved':
        return (
          <span className={`${baseClasses} bg-[var(--hytale-success)] text-white`}>
            <CheckCircle size={size === 'md' ? 14 : 12} /> Approved
          </span>
        );
      case 'rejected':
        return (
          <span className={`${baseClasses} bg-red-500 text-white`}>
            <XCircle size={size === 'md' ? 14 : 12} /> Rejected
          </span>
        );
      case 'pending':
        return (
          <span className={`${baseClasses} bg-amber-500 text-white`}>
            <Clock size={size === 'md' ? 14 : 12} /> Pending
          </span>
        );
      default:
        return <span className={`${baseClasses} bg-gray-500/50 text-white`}>{status}</span>;
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  };

  if (!isVisible || !discordId) return null;

  // Calculate stats
  const approvedCount = uploads.filter(u => u.status === 'approved').length;
  const pendingCount = uploads.filter(u => u.status === 'pending').length;
  const rejectedCount = uploads.filter(u => u.status === 'rejected').length;
  const totalDownloads = uploads.reduce((sum, u) => sum + u.download_count, 0);

  return (
    <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg overflow-hidden">
      {/* Header */}
      <div className="p-5 border-b border-[var(--hytale-border-card)]">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-lg bg-[var(--hytale-accent-blue)]/20 flex items-center justify-center">
              <Upload size={20} className="text-[var(--hytale-accent-blue)]" />
            </div>
            <div>
              <h3 className="font-hytale font-bold text-lg text-[var(--hytale-text-primary)]">My Uploads</h3>
              <p className="text-xs text-[var(--hytale-text-muted)]">Manage your community presets</p>
            </div>
          </div>
          <button
            onClick={loadUploads}
            disabled={loading}
            className="p-2.5 bg-[var(--hytale-bg-elevated)] border border-[var(--hytale-border-card)] rounded-lg hover:bg-[var(--hytale-bg-input)] hover:border-[var(--hytale-border-hover)] transition-all"
            title="Refresh"
          >
            <RefreshCw size={16} className={`text-[var(--hytale-text-muted)] ${loading ? 'animate-spin' : ''}`} />
          </button>
        </div>

        {/* Stats Bar */}
        {uploads.length > 0 && (
          <div className="grid grid-cols-4 gap-3">
            <div className="bg-[var(--hytale-bg-elevated)] rounded-lg p-3 text-center">
              <div className="text-xl font-bold text-[var(--hytale-text-primary)]">{uploads.length}</div>
              <div className="text-[10px] text-[var(--hytale-text-dimmer)] uppercase tracking-wide">Total</div>
            </div>
            <div className="bg-[var(--hytale-success)]/10 border border-[var(--hytale-success)]/20 rounded-lg p-3 text-center">
              <div className="text-xl font-bold text-[var(--hytale-success)]">{approvedCount}</div>
              <div className="text-[10px] text-[var(--hytale-success)]/70 uppercase tracking-wide">Approved</div>
            </div>
            <div className="bg-amber-500/10 border border-amber-500/20 rounded-lg p-3 text-center">
              <div className="text-xl font-bold text-amber-400">{pendingCount}</div>
              <div className="text-[10px] text-amber-400/70 uppercase tracking-wide">Pending</div>
            </div>
            <div className="bg-[var(--hytale-accent-blue)]/10 border border-[var(--hytale-accent-blue)]/20 rounded-lg p-3 text-center">
              <div className="text-xl font-bold text-[var(--hytale-accent-blue)]">{totalDownloads}</div>
              <div className="text-[10px] text-[var(--hytale-accent-blue)]/70 uppercase tracking-wide">Downloads</div>
            </div>
          </div>
        )}
      </div>

      {/* Success Message */}
      {successMessage && (
        <div className="mx-5 mt-5 p-4 bg-[var(--hytale-success)]/10 border border-[var(--hytale-success)]/30 rounded-lg text-[var(--hytale-success)] text-sm flex items-center gap-3">
          <CheckCircle size={18} /> {successMessage}
        </div>
      )}

      {/* Content - Card Grid */}
      <div className="p-5">
        {loading ? (
          <div className="flex flex-col items-center justify-center py-16">
            <Loader2 size={32} className="animate-spin text-[var(--hytale-accent-blue)] mb-3" />
            <p className="text-sm text-[var(--hytale-text-muted)]">Loading your presets...</p>
          </div>
        ) : error ? (
          <div className="p-4 bg-red-500/10 border border-red-500/30 rounded-lg text-red-400 text-sm flex items-center gap-3">
            <AlertTriangle size={18} /> {error}
          </div>
        ) : uploads.length === 0 ? (
          <div className="text-center py-16">
            <div className="w-20 h-20 mx-auto mb-5 rounded-2xl bg-[var(--hytale-bg-elevated)] border border-[var(--hytale-border-card)] flex items-center justify-center">
              <Upload size={36} className="text-[var(--hytale-text-dimmer)]" />
            </div>
            <p className="font-hytale font-bold text-lg text-[var(--hytale-text-primary)] mb-2">No presets uploaded yet</p>
            <p className="text-sm text-[var(--hytale-text-muted)] max-w-xs mx-auto">Share your shader presets with the community! Click "Submit Preset" to get started.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {uploads.map((upload, index) => (
              <div
                key={upload.id}
                className="group bg-[var(--hytale-bg-elevated)] border border-[var(--hytale-border-card)] rounded-lg overflow-hidden hover:-translate-y-0.5 hover:shadow-lg hover:border-[var(--hytale-border-hover)] transition-all duration-200 cursor-pointer animate-fade-in-up"
                style={{ animationDelay: `${Math.min(index * 0.04, 0.25)}s` }}
                onClick={() => {
                  setSelectedUpload(upload);
                  setImageIndex(0);
                  setShowComparison(false);
                }}
              >
                {/* Thumbnail */}
                <div className="h-32 bg-[var(--hytale-bg-input)] relative overflow-hidden">
                  {upload.thumbnail_url ? (
                    <img
                      src={upload.thumbnail_url}
                      alt={upload.name}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center">
                      <Sparkles size={32} className="text-[var(--hytale-text-dimmer)]" />
                    </div>
                  )}
                  {/* Gradient overlay */}
                  <div className="absolute inset-0 bg-gradient-to-t from-black/40 via-transparent to-transparent"></div>

                  {/* Status badge - top left */}
                  <div className="absolute top-2 left-2">
                    {getStatusBadge(upload.status)}
                  </div>

                  {/* Category badge - top right */}
                  <div className="absolute top-2 right-2 px-2 py-0.5 bg-black/50 backdrop-blur-sm rounded text-xs text-white font-medium">
                    {upload.category}
                  </div>
                </div>

                {/* Info */}
                <div className="p-4">
                  <h4 className="font-hytale font-bold text-[var(--hytale-text-primary)] text-sm truncate">{upload.name}</h4>
                  <p className="text-[var(--hytale-text-muted)] text-xs mt-1 line-clamp-2">{upload.description}</p>

                  {/* Rejection reason if rejected */}
                  {upload.status === 'rejected' && upload.rejection_reason && (
                    <div className="mt-2 px-2 py-1.5 bg-red-500/10 border border-red-500/20 rounded text-xs text-red-400">
                      <strong>Rejected:</strong> {upload.rejection_reason}
                    </div>
                  )}

                  <div className="flex items-center justify-between mt-3 pt-3 border-t border-[var(--hytale-border-card)]/20">
                    <span className="text-xs text-[var(--hytale-text-dimmer)]">v{upload.version}</span>
                    <span className="text-xs text-[var(--hytale-text-dimmer)] flex items-center gap-1 bg-[var(--hytale-bg-card)] px-2 py-0.5 rounded">
                      <Download size={10} /> {upload.download_count}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Preset Detail Modal */}
      {selectedUpload && (() => {
        const images = selectedUpload.images || [];
        const beforeImage = images.find(img => img.image_type === 'before');
        const afterImage = images.find(img => img.image_type === 'after');
        const hasComparison = beforeImage && afterImage;
        const galleryImages = images.filter(img => img.image_type === 'screenshot' || img.image_type === 'after');

        return (
          <div
            className="fixed inset-0 bg-[var(--hytale-overlay)] z-50 flex items-center justify-center p-8 backdrop-blur-sm animate-fadeIn"
            onClick={() => setSelectedUpload(null)}
          >
            <div
              className="bg-[var(--hytale-bg-primary)] border-2 border-[var(--hytale-border-primary)] rounded-md max-w-4xl w-full max-h-[90vh] overflow-hidden flex flex-col relative animate-expand-in"
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <div className="flex items-center justify-between p-4 border-b-2 border-[var(--hytale-border-primary)]">
                <div className="flex items-center gap-3">
                  <div>
                    <h2 className="font-hytale font-bold text-xl text-[var(--hytale-text-primary)] uppercase tracking-wide">{selectedUpload.name}</h2>
                    <div className="flex items-center gap-2 mt-1">
                      {getStatusBadge(selectedUpload.status)}
                      <span className="text-xs text-[var(--hytale-text-dim)]">v{selectedUpload.version}</span>
                    </div>
                  </div>
                </div>
                <button
                  onClick={() => setSelectedUpload(null)}
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
                              src={galleryImages[imageIndex]?.full_image_url || selectedUpload.thumbnail_url}
                              alt={selectedUpload.name}
                              className="w-full h-full object-cover"
                            />
                          ) : selectedUpload.thumbnail_url ? (
                            <img
                              src={selectedUpload.thumbnail_url}
                              alt={selectedUpload.name}
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
                        <div className="text-lg font-bold text-[var(--hytale-text-primary)]">{selectedUpload.download_count}</div>
                        <div className="text-xs text-[var(--hytale-text-dim)]">Downloads</div>
                      </div>
                      <div className="bg-[var(--hytale-bg-elevated)] rounded-lg p-3 text-center">
                        <div className="text-lg font-bold text-[var(--hytale-text-primary)]">{selectedUpload.category}</div>
                        <div className="text-xs text-[var(--hytale-text-dim)]">Category</div>
                      </div>
                    </div>

                    {/* Description */}
                    <div className="bg-[var(--hytale-bg-elevated)] rounded-lg p-4">
                      <h4 className="text-xs font-bold text-[var(--hytale-text-dim)] uppercase mb-2">Description</h4>
                      <p className="text-sm text-[var(--hytale-text-primary)] leading-relaxed">{selectedUpload.description}</p>
                    </div>

                    {/* Long Description */}
                    {selectedUpload.long_description && (
                      <div className="bg-[var(--hytale-bg-elevated)] rounded-lg p-4">
                        <h4 className="text-xs font-bold text-[var(--hytale-text-dim)] uppercase mb-2">Details</h4>
                        <p className="text-sm text-[var(--hytale-text-primary)] leading-relaxed whitespace-pre-wrap">{selectedUpload.long_description}</p>
                      </div>
                    )}

                    {/* Rejection Reason (if rejected) */}
                    {selectedUpload.status === 'rejected' && selectedUpload.rejection_reason && (
                      <div className="bg-red-500/10 border border-red-500/30 rounded-lg p-4">
                        <h4 className="text-xs font-bold text-red-400 uppercase mb-2 flex items-center gap-1">
                          <XCircle size={12} /> Rejection Reason
                        </h4>
                        <p className="text-sm text-red-300">{selectedUpload.rejection_reason}</p>
                      </div>
                    )}

                    {/* Pending notice */}
                    {selectedUpload.status === 'pending' && (
                      <div className="bg-yellow-500/10 border border-yellow-500/30 rounded-lg p-4">
                        <h4 className="text-xs font-bold text-yellow-400 uppercase mb-2 flex items-center gap-1">
                          <Clock size={12} /> Pending Review
                        </h4>
                        <p className="text-sm text-yellow-300">Your preset is awaiting moderation. This usually takes 24-48 hours.</p>
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Modal Footer - Actions */}
              <div className="p-4 border-t-2 border-[var(--hytale-border-primary)] flex justify-between">
                <button
                  onClick={() => {
                    setDeletePresetId(selectedUpload.id);
                    setDeleteModalOpen(true);
                    setSelectedUpload(null);
                  }}
                  className="px-4 py-2 bg-red-600/20 text-red-400 rounded-md font-medium flex items-center gap-2 hover:bg-red-600/30 transition-colors"
                >
                  <Trash2 size={16} /> Delete
                </button>
                <button
                  onClick={() => {
                    openEditModal(selectedUpload);
                    setSelectedUpload(null);
                  }}
                  className="px-5 py-2 bg-[var(--hytale-accent-blue)] text-white rounded-md font-medium flex items-center gap-2 hover:bg-[var(--hytale-accent-blue-hover)] transition-colors"
                >
                  <Edit3 size={16} /> Edit Preset
                </button>
              </div>
            </div>
          </div>
        );
      })()}

      {/* Delete Confirmation Modal */}
      {deleteModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-[var(--hytale-bg-primary)] border-2 border-[var(--hytale-border-primary)] rounded-lg w-full max-w-sm p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-hytale text-lg text-red-400">Delete Upload</h3>
              <button onClick={() => setDeleteModalOpen(false)} className="text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]">
                <X size={20} />
              </button>
            </div>
            <p className="text-sm text-[var(--hytale-text-muted)] mb-4">
              Are you sure you want to delete this preset? This action cannot be undone.
            </p>
            <div className="flex justify-end gap-2">
              <button onClick={() => setDeleteModalOpen(false)} className="px-4 py-2 text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]">
                Cancel
              </button>
              <button
                onClick={handleDelete}
                disabled={deleting}
                className="px-4 py-2 bg-red-600 text-white rounded-md font-medium hover:bg-red-700 flex items-center gap-2 disabled:opacity-50"
              >
                {deleting ? <Loader2 size={14} className="animate-spin" /> : <Trash2 size={14} />}
                Delete
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Edit Modal */}
      {editModalOpen && editPreset && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-[var(--hytale-bg-primary)] border-2 border-[var(--hytale-border-primary)] rounded-lg w-full max-w-md p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-hytale text-lg text-[var(--hytale-text-primary)]">Edit Preset</h3>
              <button onClick={() => setEditModalOpen(false)} className="text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]">
                <X size={20} />
              </button>
            </div>

            {editPreset.status === 'approved' && (
              <div className="mb-4 p-3 bg-yellow-500/10 border border-yellow-500/30 rounded-md text-yellow-400 text-xs">
                <AlertTriangle size={12} className="inline mr-1" />
                This preset is currently approved. Editing will require re-approval and it will be hidden until approved again.
              </div>
            )}

            <div className="space-y-4">
              <div>
                <label className="block text-xs text-[var(--hytale-text-dim)] mb-1">Name</label>
                <input
                  type="text"
                  value={editName}
                  onChange={e => setEditName(e.target.value)}
                  className="w-full px-3 py-2 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-primary)]"
                />
              </div>
              <div>
                <label className="block text-xs text-[var(--hytale-text-dim)] mb-1">Description</label>
                <textarea
                  value={editDescription}
                  onChange={e => setEditDescription(e.target.value)}
                  rows={3}
                  className="w-full px-3 py-2 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-primary)] resize-none"
                />
              </div>
              <div>
                <label className="block text-xs text-[var(--hytale-text-dim)] mb-1">Category</label>
                <select
                  value={editCategory}
                  onChange={e => setEditCategory(e.target.value)}
                  className="w-full px-3 py-2 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-primary)]"
                >
                  {CATEGORIES.map(cat => (
                    <option key={cat} value={cat}>{cat}</option>
                  ))}
                </select>
              </div>
            </div>

            <div className="flex justify-end gap-2 mt-6">
              <button onClick={() => setEditModalOpen(false)} className="px-4 py-2 text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]">
                Cancel
              </button>
              <button
                onClick={handleEdit}
                disabled={editing || (!editName.trim())}
                className="px-4 py-2 bg-[var(--hytale-accent-blue)] text-white rounded-md font-medium hover:bg-[var(--hytale-accent-blue-hover)] flex items-center gap-2 disabled:opacity-50"
              >
                {editing ? <Loader2 size={14} className="animate-spin" /> : <Edit3 size={14} />}
                Save Changes
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

