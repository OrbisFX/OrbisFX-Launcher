import { useState, useEffect, useCallback } from 'react';
import { invoke } from '@tauri-apps/api/core';
import {
  Shield, CheckCircle, XCircle, Clock, AlertTriangle,
  Loader2, RefreshCw, User, Calendar, FileText, X, Eye, Trash2, Image
} from 'lucide-react';

// Supabase URL for constructing image URLs
const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://xvnfgmgfthniadpwrxjw.supabase.co';

interface PendingPreset {
  id: string;
  slug: string;
  name: string;
  description: string;
  category: string;
  status: string;
  preset_file_path: string;
  thumbnail_path?: string;
  created_at: string;
  author_name: string;
  author_discord_id: string;
}

interface PresetImage {
  id: string;
  image_type: string;
  pair_index?: number;
  full_image_path: string;
  thumbnail_path?: string;
  display_order: number;
}

interface PresetDetail {
  id: string;
  slug: string;
  name: string;
  description: string;
  long_description?: string;
  category: string;
  version: string;
  status: string;
  preset_file_path: string;
  preset_file_hash?: string;
  thumbnail_path?: string;
  created_at: string;
  updated_at: string;
  based_on_preset_name?: string;
  rejection_reason?: string;
  author_name: string;
  author_discord_id: string;
  author_avatar?: string;
  images?: PresetImage[];
}

interface ModerationStats {
  pending: number;
  approved: number;
  rejected: number;
}

interface ModerationPanelProps {
  discordId: string;
  isVisible: boolean;
}

export function ModerationPanel({ discordId, isVisible }: ModerationPanelProps) {
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState<ModerationStats>({ pending: 0, approved: 0, rejected: 0 });
  const [pendingPresets, setPendingPresets] = useState<PendingPreset[]>([]);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  // Detail modal state
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [selectedPreset, setSelectedPreset] = useState<PresetDetail | null>(null);
  const [detailLoading, setDetailLoading] = useState(false);

  // Rejection modal state
  const [rejectModalOpen, setRejectModalOpen] = useState(false);
  const [rejectPresetId, setRejectPresetId] = useState<string | null>(null);
  const [rejectReason, setRejectReason] = useState('');

  // Delete modal state
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [deletePresetId, setDeletePresetId] = useState<string | null>(null);
  const [deleteReason, setDeleteReason] = useState('');

  const loadData = useCallback(async () => {
    if (!discordId) return;
    setLoading(true);
    setError(null);

    try {
      console.log('[Moderation] Loading data for:', discordId);

      // Load stats
      const statsResult = await invoke<{ success: boolean; pending?: number; approved?: number; rejected?: number; error?: string }>(
        'get_moderation_stats', { discordId }
      );
      console.log('[Moderation] Stats result:', statsResult);

      if (statsResult.success) {
        setStats({
          pending: statsResult.pending || 0,
          approved: statsResult.approved || 0,
          rejected: statsResult.rejected || 0
        });
      }

      // Load pending presets
      const presetsResult = await invoke<{ success: boolean; presets?: PendingPreset[] | null; error?: string }>(
        'get_pending_presets', { discordId }
      );
      console.log('[Moderation] Presets result:', presetsResult);

      if (presetsResult.success) {
        // Handle null (no presets) as empty array
        setPendingPresets(presetsResult.presets || []);
      } else {
        setError(presetsResult.error || 'Failed to load presets');
      }
    } catch (e) {
      console.error('[Moderation] Load error:', e);
      setError(`Failed to load moderation data: ${e}`);
    } finally {
      setLoading(false);
    }
  }, [discordId]);

  useEffect(() => {
    if (isVisible && discordId) {
      loadData();
    }
  }, [isVisible, discordId, loadData]);

  const handleApprove = async (presetId: string) => {
    setActionLoading(presetId);
    setError(null);
    try {
      console.log('[Moderation] Approving preset:', presetId);
      const result = await invoke<{ success: boolean; error?: string; rows_updated?: number }>(
        'approve_preset', { presetId, discordId }
      );
      console.log('[Moderation] Approve result:', result);

      if (result.success) {
        // Optimistically remove from local state immediately
        setPendingPresets(prev => prev.filter(p => p.id !== presetId));
        // Then reload all data
        await loadData();
      } else {
        setError(result.error || 'Failed to approve preset');
      }
    } catch (e) {
      console.error('[Moderation] Approve error:', e);
      setError(`Error: ${e}`);
    } finally {
      setActionLoading(null);
    }
  };

  const openRejectModal = (presetId: string) => {
    setRejectPresetId(presetId);
    setRejectReason('');
    setRejectModalOpen(true);
  };

  const handleReject = async () => {
    if (!rejectPresetId) return;
    setActionLoading(rejectPresetId);
    setRejectModalOpen(false);

    try {
      const result = await invoke<{ success: boolean; error?: string }>(
        'reject_preset', { presetId: rejectPresetId, discordId, reason: rejectReason || null }
      );
      if (result.success) {
        setSuccessMessage('Preset rejected successfully');
        setDetailModalOpen(false);
        setSelectedPreset(null);
        await loadData();
        setTimeout(() => setSuccessMessage(null), 3000);
      } else {
        setError(result.error || 'Failed to reject preset');
      }
    } catch (e) {
      setError(`Error: ${e}`);
    } finally {
      setActionLoading(null);
      setRejectPresetId(null);
    }
  };

  const openDetailModal = async (presetId: string) => {
    setDetailLoading(true);
    setDetailModalOpen(true);
    setError(null);

    try {
      const result = await invoke<{ success: boolean; preset?: PresetDetail; error?: string }>(
        'get_preset_for_moderation', { presetId, discordId }
      );

      if (result.success && result.preset) {
        setSelectedPreset(result.preset);
      } else {
        setError(result.error || 'Failed to load preset details');
        setDetailModalOpen(false);
      }
    } catch (e) {
      setError(`Error loading preset: ${e}`);
      setDetailModalOpen(false);
    } finally {
      setDetailLoading(false);
    }
  };

  const handleApproveFromDetail = async () => {
    if (!selectedPreset) return;
    await handleApprove(selectedPreset.id);
    setDetailModalOpen(false);
    setSelectedPreset(null);
    setSuccessMessage('Preset approved successfully');
    setTimeout(() => setSuccessMessage(null), 3000);
  };

  const openDeleteModal = (presetId: string) => {
    setDeletePresetId(presetId);
    setDeleteReason('');
    setDeleteModalOpen(true);
  };

  const handleDelete = async () => {
    if (!deletePresetId) return;
    setActionLoading(deletePresetId);
    setDeleteModalOpen(false);

    try {
      const result = await invoke<{ success: boolean; error?: string }>(
        'delete_preset', { presetId: deletePresetId, discordId, reason: deleteReason || null }
      );
      if (result.success) {
        setSuccessMessage('Preset deleted successfully');
        setDetailModalOpen(false);
        setSelectedPreset(null);
        await loadData();
        setTimeout(() => setSuccessMessage(null), 3000);
      } else {
        setError(result.error || 'Failed to delete preset');
      }
    } catch (e) {
      setError(`Error: ${e}`);
    } finally {
      setActionLoading(null);
      setDeletePresetId(null);
    }
  };

  const getImageUrl = (path: string) => {
    return `${SUPABASE_URL}/storage/v1/object/public/community-images/${path}`;
  };

  if (!isVisible) return null;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Shield size={24} className="text-[var(--hytale-accent-blue)]" />
          <h2 className="font-hytale text-xl text-[var(--hytale-text-primary)]">Moderation Panel</h2>
        </div>
        <button
          onClick={loadData}
          disabled={loading}
          className="p-2 bg-[var(--hytale-bg-card)] rounded-md hover:bg-[var(--hytale-bg-elevated)] transition-colors"
        >
          <RefreshCw size={16} className={`text-[var(--hytale-text-muted)] ${loading ? 'animate-spin' : ''}`} />
        </button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-3 gap-4">
        <StatCard icon={<Clock size={20} />} label="Pending" value={stats.pending} color="yellow" />
        <StatCard icon={<CheckCircle size={20} />} label="Approved" value={stats.approved} color="green" />
        <StatCard icon={<XCircle size={20} />} label="Rejected" value={stats.rejected} color="red" />
      </div>

      {successMessage && (
        <div className="p-3 bg-green-500/10 border border-green-500/30 rounded-md text-green-400 text-sm flex items-center gap-2">
          <CheckCircle size={16} /> {successMessage}
        </div>
      )}

      {error && (
        <div className="p-3 bg-red-500/10 border border-red-500/30 rounded-md text-red-400 text-sm flex items-center gap-2">
          <AlertTriangle size={16} /> {error}
        </div>
      )}

      {/* Pending Presets List */}
      <div className="bg-[var(--hytale-bg-card)] border border-[var(--hytale-border-card)] rounded-lg overflow-hidden">
        <div className="p-4 border-b border-[var(--hytale-border-card)]">
          <h3 className="font-hytale text-lg text-[var(--hytale-text-primary)]">Pending Review</h3>
        </div>

        {loading ? (
          <div className="p-8 flex items-center justify-center">
            <Loader2 size={24} className="animate-spin text-[var(--hytale-accent-blue)]" />
          </div>
        ) : pendingPresets.length === 0 ? (
          <div className="p-8 text-center text-[var(--hytale-text-muted)]">
            <CheckCircle size={32} className="mx-auto mb-2 text-green-400" />
            <p>No pending presets to review</p>
          </div>
        ) : (
          <div className="divide-y divide-[var(--hytale-border-card)]">
            {pendingPresets.map(preset => (
              <div
                key={preset.id}
                className="p-4 hover:bg-[var(--hytale-bg-elevated)] transition-colors cursor-pointer"
                onClick={() => openDetailModal(preset.id)}
              >
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1 min-w-0">
                    <h4 className="font-bold text-[var(--hytale-text-primary)] truncate">{preset.name}</h4>
                    <p className="text-sm text-[var(--hytale-text-muted)] line-clamp-2 mt-1">{preset.description}</p>
                    <div className="flex items-center gap-4 mt-2 text-xs text-[var(--hytale-text-dim)]">
                      <span className="flex items-center gap-1"><User size={12} /> {preset.author_name}</span>
                      <span className="flex items-center gap-1"><FileText size={12} /> {preset.category}</span>
                      <span className="flex items-center gap-1"><Calendar size={12} /> {new Date(preset.created_at).toLocaleDateString()}</span>
                    </div>
                  </div>
                  <div className="flex gap-2" onClick={e => e.stopPropagation()}>
                    <button
                      onClick={() => openDetailModal(preset.id)}
                      className="px-3 py-1.5 bg-[var(--hytale-accent-blue)] text-white rounded-md text-sm font-medium hover:bg-[var(--hytale-accent-blue-hover)] transition-colors flex items-center gap-1"
                    >
                      <Eye size={14} /> View
                    </button>
                    <button
                      onClick={() => handleApprove(preset.id)}
                      disabled={actionLoading === preset.id}
                      className="px-3 py-1.5 bg-green-600 text-white rounded-md text-sm font-medium hover:bg-green-700 transition-colors disabled:opacity-50 flex items-center gap-1"
                    >
                      {actionLoading === preset.id ? <Loader2 size={14} className="animate-spin" /> : <CheckCircle size={14} />}
                      Approve
                    </button>
                    <button
                      onClick={() => openRejectModal(preset.id)}
                      disabled={actionLoading === preset.id}
                      className="px-3 py-1.5 bg-red-600 text-white rounded-md text-sm font-medium hover:bg-red-700 transition-colors disabled:opacity-50 flex items-center gap-1"
                    >
                      <XCircle size={14} /> Reject
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Reject Modal - higher z-index to appear above Detail Modal */}
      {rejectModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-center justify-center p-4">
          <div className="bg-[var(--hytale-bg-primary)] border-2 border-[var(--hytale-border-primary)] rounded-lg w-full max-w-md p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-hytale text-lg text-[var(--hytale-text-primary)]">Reject Preset</h3>
              <button onClick={() => setRejectModalOpen(false)} className="text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]">
                <X size={20} />
              </button>
            </div>
            <p className="text-sm text-[var(--hytale-text-muted)] mb-4">Provide a reason for rejection (optional but recommended):</p>
            <textarea
              value={rejectReason}
              onChange={e => setRejectReason(e.target.value)}
              placeholder="e.g., Preset contains copyrighted content..."
              className="w-full px-3 py-2 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-primary)] resize-none h-24"
            />
            <div className="flex justify-end gap-2 mt-4">
              <button onClick={() => setRejectModalOpen(false)} className="px-4 py-2 text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]">
                Cancel
              </button>
              <button onClick={handleReject} className="px-4 py-2 bg-red-600 text-white rounded-md font-medium hover:bg-red-700">
                Reject Preset
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Modal - higher z-index to appear above Detail Modal */}
      {deleteModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-center justify-center p-4">
          <div className="bg-[var(--hytale-bg-primary)] border-2 border-[var(--hytale-border-primary)] rounded-lg w-full max-w-md p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-hytale text-lg text-red-400">Delete Preset</h3>
              <button onClick={() => setDeleteModalOpen(false)} className="text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]">
                <X size={20} />
              </button>
            </div>
            <p className="text-sm text-[var(--hytale-text-muted)] mb-4">
              <strong className="text-red-400">Warning:</strong> This will permanently delete the preset and all associated images. This action cannot be undone.
            </p>
            <textarea
              value={deleteReason}
              onChange={e => setDeleteReason(e.target.value)}
              placeholder="Reason for deletion (optional)..."
              className="w-full px-3 py-2 bg-[var(--hytale-bg-input)] border border-[var(--hytale-border-card)] rounded-md text-[var(--hytale-text-primary)] resize-none h-24"
            />
            <div className="flex justify-end gap-2 mt-4">
              <button onClick={() => setDeleteModalOpen(false)} className="px-4 py-2 text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]">
                Cancel
              </button>
              <button onClick={handleDelete} className="px-4 py-2 bg-red-600 text-white rounded-md font-medium hover:bg-red-700 flex items-center gap-1">
                <Trash2 size={14} /> Delete Forever
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Detail Modal */}
      {detailModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-[var(--hytale-bg-primary)] border-2 border-[var(--hytale-border-primary)] rounded-lg w-full max-w-4xl max-h-[90vh] overflow-hidden flex flex-col">
            {/* Modal Header */}
            <div className="flex items-center justify-between p-4 border-b border-[var(--hytale-border-card)]">
              <h3 className="font-hytale text-lg text-[var(--hytale-text-primary)]">
                {detailLoading ? 'Loading...' : selectedPreset?.name || 'Preset Details'}
              </h3>
              <button
                onClick={() => { setDetailModalOpen(false); setSelectedPreset(null); }}
                className="text-[var(--hytale-text-muted)] hover:text-[var(--hytale-text-primary)]"
              >
                <X size={20} />
              </button>
            </div>

            {/* Modal Content */}
            <div className="flex-1 overflow-y-auto p-6">
              {detailLoading ? (
                <div className="flex items-center justify-center py-12">
                  <Loader2 size={32} className="animate-spin text-[var(--hytale-accent-blue)]" />
                </div>
              ) : selectedPreset ? (
                <div className="space-y-6">
                  {/* Metadata Section */}
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="text-xs text-[var(--hytale-text-dim)] uppercase">Author</label>
                      <p className="text-[var(--hytale-text-primary)] flex items-center gap-2">
                        <User size={14} /> {selectedPreset.author_name}
                      </p>
                    </div>
                    <div>
                      <label className="text-xs text-[var(--hytale-text-dim)] uppercase">Category</label>
                      <p className="text-[var(--hytale-text-primary)]">{selectedPreset.category}</p>
                    </div>
                    <div>
                      <label className="text-xs text-[var(--hytale-text-dim)] uppercase">Version</label>
                      <p className="text-[var(--hytale-text-primary)]">{selectedPreset.version}</p>
                    </div>
                    <div>
                      <label className="text-xs text-[var(--hytale-text-dim)] uppercase">Submitted</label>
                      <p className="text-[var(--hytale-text-primary)]">{new Date(selectedPreset.created_at).toLocaleString()}</p>
                    </div>
                    {selectedPreset.based_on_preset_name && (
                      <div className="col-span-2">
                        <label className="text-xs text-[var(--hytale-text-dim)] uppercase">Based On</label>
                        <p className="text-[var(--hytale-text-primary)]">{selectedPreset.based_on_preset_name}</p>
                      </div>
                    )}
                  </div>

                  {/* Description */}
                  <div>
                    <label className="text-xs text-[var(--hytale-text-dim)] uppercase">Description</label>
                    <p className="text-[var(--hytale-text-primary)] mt-1">{selectedPreset.description}</p>
                    {selectedPreset.long_description && (
                      <p className="text-[var(--hytale-text-muted)] mt-2 text-sm">{selectedPreset.long_description}</p>
                    )}
                  </div>

                  {/* Images */}
                  {selectedPreset.images && selectedPreset.images.length > 0 && (
                    <div>
                      <label className="text-xs text-[var(--hytale-text-dim)] uppercase mb-2 block">
                        <Image size={14} className="inline mr-1" /> Images ({selectedPreset.images.length})
                      </label>
                      <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                        {selectedPreset.images.map((img) => (
                          <div key={img.id} className="relative group">
                            <img
                              src={getImageUrl(img.full_image_path)}
                              alt={img.image_type}
                              className="w-full h-32 object-cover rounded-md border border-[var(--hytale-border-card)]"
                            />
                            <div className="absolute bottom-1 left-1 px-1.5 py-0.5 bg-black/70 rounded text-xs text-white">
                              {img.image_type}
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Preset File Info */}
                  <div>
                    <label className="text-xs text-[var(--hytale-text-dim)] uppercase">Preset File</label>
                    <p className="text-[var(--hytale-text-muted)] text-sm font-mono">{selectedPreset.preset_file_path}</p>
                  </div>
                </div>
              ) : null}
            </div>

            {/* Modal Footer with Actions */}
            {selectedPreset && (
              <div className="flex items-center justify-between p-4 border-t border-[var(--hytale-border-card)] bg-[var(--hytale-bg-card)]">
                <button
                  onClick={() => openDeleteModal(selectedPreset.id)}
                  className="px-4 py-2 bg-red-900/50 text-red-400 rounded-md font-medium hover:bg-red-900/70 flex items-center gap-2"
                >
                  <Trash2 size={16} /> Delete
                </button>
                <div className="flex gap-2">
                  <button
                    onClick={() => { openRejectModal(selectedPreset.id); }}
                    disabled={actionLoading === selectedPreset.id}
                    className="px-4 py-2 bg-red-600 text-white rounded-md font-medium hover:bg-red-700 flex items-center gap-2"
                  >
                    <XCircle size={16} /> Reject
                  </button>
                  <button
                    onClick={handleApproveFromDetail}
                    disabled={actionLoading === selectedPreset.id}
                    className="px-4 py-2 bg-green-600 text-white rounded-md font-medium hover:bg-green-700 flex items-center gap-2"
                  >
                    {actionLoading === selectedPreset.id ? <Loader2 size={16} className="animate-spin" /> : <CheckCircle size={16} />}
                    Approve
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

function StatCard({ icon, label, value, color }: { icon: React.ReactNode; label: string; value: number; color: 'yellow' | 'green' | 'red' }) {
  const colorClasses = {
    yellow: 'text-yellow-400 bg-yellow-400/10 border-yellow-400/30',
    green: 'text-green-400 bg-green-400/10 border-green-400/30',
    red: 'text-red-400 bg-red-400/10 border-red-400/30'
  };

  return (
    <div className={`p-4 rounded-lg border ${colorClasses[color]}`}>
      <div className="flex items-center gap-2 mb-2">
        {icon}
        <span className="text-sm font-medium">{label}</span>
      </div>
      <p className="text-2xl font-bold">{value}</p>
    </div>
  );
}

