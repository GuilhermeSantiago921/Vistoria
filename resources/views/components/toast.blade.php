{{-- Toast Notification Component --}}
<div x-data="{ 
    show: false, 
    message: '', 
    type: 'success',
    showToast(msg, t = 'success') {
        this.message = msg;
        this.type = t;
        this.show = true;
        setTimeout(() => { this.show = false; }, 4000);
    }
}" 
@toast.window="showToast($event.detail.message, $event.detail.type || 'success')"
class="fixed inset-0 pointer-events-none z-50">
    <div x-show="show"
         x-transition:enter="transition ease-out duration-300"
         x-transition:enter-start="opacity-0 translate-y-4"
         x-transition:enter-end="opacity-100 translate-y-0"
         x-transition:leave="transition ease-in duration-200"
         x-transition:leave-start="opacity-100"
         x-transition:leave-end="opacity-0"
         :class="{
            'toast toast-success': type === 'success',
            'toast toast-error': type === 'error',
            'toast toast-info': type === 'info'
         }"
         class="pointer-events-auto"
         style="display: none;">
        <div class="flex items-center">
            <svg x-show="type === 'success'" class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
            </svg>
            <svg x-show="type === 'error'" class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
            </svg>
            <svg x-show="type === 'info'" class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            <span x-text="message"></span>
        </div>
    </div>
</div>

{{-- Usage Example:
<script>
    // Dispatch toast from anywhere
    window.dispatchEvent(new CustomEvent('toast', {
        detail: { message: 'Vistoria enviada com sucesso!', type: 'success' }
    }));
</script>
--}}
