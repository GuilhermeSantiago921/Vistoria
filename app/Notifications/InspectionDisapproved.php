<?php

namespace App\Notifications;

use App\Models\Inspection;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class InspectionDisapproved extends Notification implements ShouldQueue
{
    use Queueable;

    protected $inspection;

    /**
     * Create a new notification instance.
     */
    public function __construct(Inspection $inspection)
    {
        $this->inspection = $inspection;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->subject('❌ Vistoria NÃO CONFORME - Sistema de Vistoria')
                    ->greeting('Olá ' . $notifiable->name . ',')
                    ->line('Sua vistoria foi analisada e identificamos algumas não conformidades.')
                    ->line('')
                    ->line('**Detalhes da Vistoria:**')
                    ->line('• Placa do Veículo: ' . $this->inspection->vehicle->license_plate)
                    ->line('• Veículo: ' . $this->inspection->vehicle->brand . ' ' . $this->inspection->vehicle->model)
                    ->line('• Ano: ' . $this->inspection->vehicle->year)
                    ->line('• Data da Análise: ' . $this->inspection->updated_at->format('d/m/Y H:i'))
                    ->line('• Mesário: ' . ($this->inspection->analyst->name ?? 'Sistema'))
                    ->line('• Status: **NÃO CONFORME**')
                    ->line('')
                    ->when($this->inspection->notes, function ($message) {
                        return $message->line('**Observações do Mesário:**')
                                      ->line($this->inspection->notes)
                                      ->line('');
                    })
                    ->line('Para mais detalhes sobre as não conformidades encontradas, consulte o relatório completo.')
                    ->action('Ver Relatório Detalhado', route('report.pdf', $this->inspection->id))
                    ->line('Caso tenha dúvidas, entre em contato com nossa equipe técnica.')
                    ->salutation('Atenciosamente, Equipe de Vistoria');
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            'inspection_id' => $this->inspection->id,
            'vehicle_plate' => $this->inspection->vehicle->license_plate,
            'status' => 'disapproved',
            'message' => 'Vistoria reprovada'
        ];
    }
}